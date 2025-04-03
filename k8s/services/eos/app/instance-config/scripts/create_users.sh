#!/usr/bin/env bash

set -xeuo pipefail

shopt -s expand_aliases
alias eos="eos -r 0 0"

yum install -y openldap-clients

# eos access allow user svc-restic
# eos access allow user svc-immich
#
# eos mkdir -p "/eos/services/immich"
# eos mkdir -p "/eos/services/immich/thumbs"
# eos mkdir -p "/eos/services/immich/upload"
# eos mkdir -p "/eos/services/immich/encoded-video"
# eos chown -R app_immich:users /eos/services/immich
# eos chown -R app_immich:users /eos/services/immich/thumbs
# eos chown -R app_immich:users /eos/services/immich/upload
# eos chown -R app_immich:users /eos/services/immich/encoded-video
# eos chmod 2700 /eos/services/immich
#
# eos attr -r set sys.mask="700" /eos/services/immich
# eos attr -r set sys.mtime.propagation="1" /eos/services/immich
# eos attr -r set sys.forced.atomic="1" /eos/services/immich
#
# eos attr -r set sys.acl="u:app_immich:rwx,u:app_restic:rw" /eos/services/immich

create_user() {
  username="${1}"
  uid="${2}"
  if ! echo "${username}" | grep ^svc-; then
    homedir="/eos/user/${username}"
  else
    homedir="/eos/service/${username}"
  fi

  if eos ls "${homedir}"; then
    return
  fi

  eos access allow user "${username}"

  # Base directories
  eos mkdir -p "${homedir}"
  eos chown "${uid}:${uid}" "${homedir}"
  eos chmod 2700 "${homedir}"
  if ! echo "${username}" | grep ^svc-; then
    eos mkdir -p "${homedir}/Documents"
  fi

  # Base attributes
  eos attr -r set sys.owner.auth="*" "${homedir}"
  eos attr -r set sys.mask="700" "${homedir}"
  eos attr -r set sys.mtime.propagation="1" "${homedir}"
  eos attr -r set sys.forced.atomic="1" "${homedir}"
  eos attr -r set sys.versioning="10" "${homedir}"

  # ACLs
  eos attr -r set sys.acl="u:${username}:rwx,u:svc-nextcloud:rwx,u:svc-restic:rx" "${homedir}"

  if echo "${username}" | grep ^svc-; then
    return
  fi

  # User only directories

  ## Immich
  eos mkdir "/eos/service/svc-immich/library/${username}"
  eos ln -s "${homedir}/Photos" "/eos/service/svc-immich/library/${username}"
  eos attr -r set sys.acl="u:svc-immich:rwx,u:${username}:rx,u:svc-nextcloud:rx,u:svc-restic:rx" "/eos/service/svc-immich/library/${username}"
}

ldapsearch -LLL \
  -H ldap://ak-outpost-ldap-outpost.services-authentik.svc.c.k3s.fsn.lama.tel/ \
  -x -D "cn=$(cat /ldap-creds/username),ou=users,dc=eos,dc=lama-corp,dc=space" -w "$(cat /ldap-creds/key)" \
  -b 'ou=users,dc=eos,dc=lama-corp,dc=space' '(objectClass=user)' \
  cn |
  grep ^cn | cut -d' ' -f2 |
  grep -v '^ak-outpost' |
  while read -r username; do
    uid="$(id -u "${username}")"
    create_user "${username}" "${uid}"
  done

pkill nslcd
pkill nscd
