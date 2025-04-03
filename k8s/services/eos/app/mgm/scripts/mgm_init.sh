#!/usr/bin/env bash

set -xeuo pipefail

/mkcert-ssl.sh

init_probe() {
  # shellcheck disable=SC2124
  local cmd=$@
  local max_wait=180
  local sleep=5
  start_time=$(date +%s)
  rc=-1

  while [ $rc -ne 0 ]; do
    # shellcheck disable=SC2086
    timeout --preserve-status $sleep $cmd >/dev/null 2>&1
    rc=$?

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

echo "INFO: Checking QDB is running..."
init_probe redis-cli -h qdb.services-eos.svc.c.k3s.fsn.lama.tel -p 7777 ping
echo "INFO: QDB is online."

echo "INFO: Starting MQ..."
/opt/eos/xrootd/bin/xrootd -n mq -c /etc/xrd.cf.mq -m -Rdaemon &
sleep 5

# Start the MGM process in background so that we can run other commands
echo "INFO: Starting MGM..."
/opt/eos/xrootd/bin/xrootd -n mgm -c /etc/xrd.cf.mgm -m -Rdaemon &

EOS_MGM_URL="root://localhost"
export EOS_MGM_URL
echo "INFO: Checking the MGM is online..."
echo "INFO: EOS_MGM_URL=${EOS_MGM_URL:-}"
init_probe eos -r 0 0 ns
echo "INFO: MGM is online."

# Check if a previous configuration already exists. If so, don't touch.
echo "INFO: Looking for previous EOS configurations..."
if [ "$(eos -b config ls | grep -cw 'enable_sss')" -eq 1 ]; then
  echo "  ✓ EOS configurations found. Exiting."
  exit 0
fi
echo "  ✓ None found."

# Enable SSS
echo "INFO: Enabling mapping via SSS..."
eos -b vid enable sss
eos -b vid enable krb5

# Add daemon to sudoers list
echo "INFO: Adding daemon to sudoers list..."
eos -b vid set membership daemon +sudo

### Save config and leave
echo "INFO: Saving configuration..."
eos -b config save enable_sss -f
eos -b config save default -f
