#!/usr/bin/env python

from ansible.module_utils.common.text.converters import to_native

"""
    Manipulate kresd configuration
"""


class FilterModule:
    """
    Gives access to filters for jinja templating
    """

    def filters(self):
        """
        Returns filters associated with this object
        """
        return {
            "kresd_make_listener": self.kresd_make_listener,
            "kresd_make_views": self.kresd_make_views,
            "kresd_make_policy": self.kresd_make_policy,
        }

    KRESD_LISTENER_FIELDS = {
        "ip": {"types": [str]},
        "port": {"types": [int]},
        "opts": {"types": [dict]},
    }

    KRESD_VIEW_FIELDS = {
        "addr": {"types": [str, list], "required": False},
        "tsig": {"types": [str, list], "required": False},
        "policies": {"types": [list]},
    }

    @staticmethod
    def kresd_dict_to_singleline_str(variable):
        """
        From dict creates its lua representation
        Ex : { 'kind' : 'dns', 'freebind' : True, 'port': 53 }
        -> { kind = 'dns', freebind = true, port = 53 }
        """

        def get_dict_key_value_as_str(key):
            # return "key: val"
            value = variable[key]
            if isinstance(value, bool):
                value_out = str(value).lower()
            elif value.isnumeric():
                value_out = str(value)
            elif isinstance(value, dict):
                value_out = FilterModule.kresd_dict_to_singleline_str(value)
            else:
                value_out = "'{}'".format(value)
            return "{} = {}".format(key, value_out)

        if isinstance(variable, dict):
            keys = variable.keys()
            return (
                "{ " + ", ".join(get_dict_key_value_as_str(key) for key in keys) + " }"
            )
        return variable

    @staticmethod
    def kresd_check_object(_object, kresd_object_fields, kresd_object_name):
        """
        Check object validity from a mapping of fields and types
        """
        for _field_name, _field in kresd_object_fields.items():
            if not _field_name in _object and (
                not "required" in _field or _field["required"]
            ):
                raise ValueError(
                    to_native(
                        'kresd {} must have "{}" attribute'.format(
                            kresd_object_name, _field_name
                        )
                    )
                )
            if _field_name in _object:
                _type_found = False
                for _type in _field["types"]:
                    if isinstance(_object[_field_name], _type):
                        _type_found = True
                        break
                if not _type_found:
                    raise ValueError(
                        to_native(
                            'Invalid type for kresd {} "{}" attribute'.format(
                                kresd_object_name, _field_name
                            )
                        )
                    )

    @staticmethod
    def kresd_policy_suffix_table_to_str(policy_suffix_table):
        """
        From object suffix table creates kresd kresd config string
        Ex : { 'todnames' : [ 'epita.fr', 'epita.net' ] }
        -> policy.todnames({'epita.fr', 'epita.net'})
        """
        return "policy.todnames({{ {} }})".format(
            ", ".join(["'" + dname + "'" for dname in policy_suffix_table["todnames"]])
        )

    @staticmethod
    def kresd_policy_to_str(policy, kresd_rpz):
        policy_args = ["policy.{_action}".format(_action=policy["action"].upper())]

        if policy["type"] == "suffix":
            policy_args.append(
                FilterModule.kresd_policy_suffix_table_to_str(policy["suffix_table"])
            )

        if policy["type"] == "rpz":
            _rpz = kresd_rpz.get(policy["rpz"])
            if not _rpz:
                raise ValueError(
                    to_native(
                        "kresd rpz policy must refer to rpz defined in kresd_rpz dict"
                    )
                )
            policy_args.append("rpz_{}_zone_path".format(policy["rpz"]))

        return "policy.{_type}({_policy_args})".format(
            _type=policy["type"], _policy_args=", ".join(policy_args)
        )

    def kresd_make_listener(self, listener):
        """
        From object listener creates kresd listener
        Ex : { 'ip' : '0.0.0.0', 'port' : 53, 'opts': { 'kind': 'dns', freebind: True } }
        -> net.listen('0.0.0.0', 53, { kind = 'dns', freebind = true })
        """
        self.kresd_check_object(listener, self.KRESD_LISTENER_FIELDS, "listener")

        return "net.listen('{}', {}, {})".format(
            listener["ip"],
            listener["port"],
            self.kresd_dict_to_singleline_str(listener.get("opts", {})),
        )

    def kresd_make_views(self, kresd_view, kresd_rpz):
        """
        From object view creates kresd view(s)
        Ex:
            addr: "10.224.32.1"
            policies:
              - type: suffix
                action: pass
                suffix_table:
                  todnames:
                    - epita.fr
                    - epita.net
              - type: all
                action: deny

        -> view:addr('10.224.32.1', policy.suffix(policy.PASS, policy.todnames({'epita.fr', 'epita.net'})))
           view:addr('10.224.32.1', policy.all(policy.DENY))
        """
        self.kresd_check_object(kresd_view, self.KRESD_VIEW_FIELDS, "view")

        if kresd_view.get("addr") and kresd_view.get("tsig"):
            raise ValueError(to_native("kresd view cannot be both addr and tsig"))
        _type = "addr" if kresd_view.get("addr") else "tsig"

        _selectors = []
        if isinstance(kresd_view[_type], list):
            _selectors = kresd_view[_type]
        else:
            _selectors.append(kresd_view[_type])

        # Build policies
        _policies = []
        VALID_POLICY_ACTIONS = ["pass", "deny"]
        for policy in kresd_view["policies"]:
            if not (policy["action"] in VALID_POLICY_ACTIONS):
                raise ValueError(
                    to_native(
                        "kresd policy action must be one of {}".format(
                            str(VALID_POLICY_ACTIONS)
                        )
                    )
                )
            _policies.append(FilterModule.kresd_policy_to_str(policy, kresd_rpz))

        # Build views
        ret = []
        for _selector in _selectors:
            for policy in _policies:
                ret.append(
                    "view:{_type}('{_selector}', {_policy})".format(
                        _type=_type, _selector=_selector, _policy=policy
                    )
                )

        return "\n".join(ret)

    def kresd_make_policy(self, kresd_policy, kresd_rpz):
        """
        From object view creates kresd view(s)
        Ex:
            type: suffix
            action: pass
            suffix_table:
              todnames:
                - epita.fr
                - epita.net

        -> policy.add(policy.suffix(policy.PASS, policy.todnames({'epita.fr', 'epita.net'})))

        Ex:
            type: rpz
            action: deny
            rpz: |
              $TTL 3600
              cri.epita.fr.     A   10.224.32.1

        -> policy.add(policy.rpz(policy.DENY, ))
        """
        _str = FilterModule.kresd_policy_to_str(kresd_policy, kresd_rpz)
        return "policy.add({})".format(_str)
