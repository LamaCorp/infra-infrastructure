#!/usr/bin/env python

from copy import deepcopy


class FilterModule:
    session_types = {
        "peers": "peer",
        "upstreams": "upstream",
        "customers": "customer",
        "cores": "core",
        "looking_glasses": "lookingglass",
        "telemetries": "telemetry",
    }

    def filters(self):
        return {
            "make_bgp_sessions_list": self.make_bgp_sessions_list,
        }

    def make_bgp_sessions_list(self, bgp_sessions):
        sessions = []
        for type_ in self.session_types.keys():
            if not type_ in bgp_sessions:
                continue

            defaults = bgp_sessions.get("defaults", {})
            defaults.update(bgp_sessions[type_].get("defaults", {}))

            for session in bgp_sessions[type_].get("sessions", []):
                data = deepcopy(defaults)
                data.update(session)
                data["type"] = self.session_types[type_]

                if "v4" in data.get("remote", {}):
                    data["protocol_number"] = 4
                    data["protocol"] = "v4"
                    if "irr" in data:
                        data[
                            "bgpq3_cmd"
                        ] = f"bgpq3 -b -A -m 24 -4 -l AS_SET_FOR_{data['asn']}_{data['alias'].upper()}_4 {data['irr']}"
                    sessions.append(deepcopy(data))
                if "v6" in data.get("remote", {}):
                    data["protocol_number"] = 6
                    data["protocol"] = "v6"
                    if "irr" in data:
                        data[
                            "bgpq3_cmd"
                        ] = f"bgpq3 -b -A -m 48 -6 -l AS_SET_FOR_{data['asn']}_{data['alias'].upper()}_6 {data['irr']}"
                    sessions.append(deepcopy(data))

        return sessions
