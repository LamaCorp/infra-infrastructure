#!/usr/bin/env bash

set -xeuo pipefail

alias eos='eos -r 0 0'
shopt -s expand_aliases

init_probe() {
  # shellcheck disable=SC2124
  local cmd=$@
  local max_wait=180
  local sleep=5
  start_time=$(date +%s)
  rc=-1
  while [ $rc -ne 0 ];
  do
    set +e
    # shellcheck disable=SC2086
    timeout --preserve-status $sleep $cmd >/dev/null 2>&1
    rc=$?
    set -e

    # Bail out after max_wait
    tot_wait=$(($(date +%s)-start_time))
    echo "        $tot_wait seconds... (timeout at $max_wait)"
    if [ $tot_wait -ge $max_wait ]; then
      echo "ERROR: cmd \`$cmd\` failed after $tot_wait secs. Giving up."
      exit 1
    fi
    sleep $sleep
  done
}

# Wait for the MGM to be online before registering the node and the filesystem
echo "INFO: Checking the MGM is online..."
echo "INFO: EOS_MGM_URL=${EOS_MGM_URL:-}"
init_probe eos ns
echo "INFO: MGM is online."

# Start the FST process in background so that we can run other commands
echo "INFO: Starting FST..."
/opt/eos/xrootd/bin/xrootd -n fst -c /etc/xrd.cf.fst -m -Rdaemon >/dev/null 2>&1 &

# Local variables
DATADIR="/fst_storage/fst-${FST_INSTANCE}"
UUID=$(uuidgen)
HOSTNAME=$(hostname -f)
SPACE="${SPACE:-default}"
GROUPSIZE=0
GROUPMOD=24
CONFIG=rw

# If there is an eos fsid || fsuuid, bail out
if [ -f "$DATADIR/.eosfsid" ] || [ -f "$DATADIR/.eosfsuuid" ]; then
  echo "INFO: FS IDs already exist. Not configuring any further"
  echo "INFO: FS uuid is $(cat "$DATADIR/.eosfsuuid")"
  exit 0
fi

# Write filesystem identifier
echo "INFO: FS uuid is $UUID"
echo "$UUID" > "$DATADIR/.eosfsuuid"
chown daemon:daemon "$DATADIR/.eosfsuuid"

# If needed, create the EOS space
if [ "$(eos space ls "$SPACE" -m | wc -l)" -eq 0 ]; then
  echo "INFO: Space $SPACE does not exist. Creating..."
  eos space define "$SPACE" $GROUPSIZE $GROUPMOD
  eos space set "$SPACE" on
fi

# Set this node on
echo "INFO: Enabling node..."
eos node set "$HOSTNAME:1095" on

# Register filesystem
echo "INFO: Registering filesystem..."
eos fs add "$UUID" "$HOSTNAME:1095" "$DATADIR" "$SPACE" $CONFIG

# @note Enable the scheduling group the fst has been added to.
#       ref. https://gitlab.cern.ch/eos/eos-charts/-/issues/41
echo "INFO: Enabling scheduling group..."
eos group set "$(eos fs ls -m | grep "$UUID" | grep -o "schedgroup=[^,' ']*" | cut -d= -f2)" on
