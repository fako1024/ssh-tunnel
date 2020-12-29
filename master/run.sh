#!/bin/sh

RETRY_DELAY="${RETRY_DELAY:-10}"

if [ "$SERVERS" == "" ]; then
  echo "Missing SERVERS environment variable"
  exit 1
fi

mkdir -p /root/.ssh

# Deploy host key
if [ ! -f "/config/host_key" ]; then
  echo "/config/host_key file not found / mounted"
  exit 1
fi
cp /config/host_key /ssh_host_ecdsa_key || exit 1

# Deploy known public host keys
if [ ! -f "/config/known_hosts" ]; then
  echo "/config/known_hosts file not found / mounted"
  exit 1
fi
cp /config/known_hosts /root/.ssh/known_hosts || exit 1

# Deploy public keys
if [ ! -f "/config/authorized_keys" ]; then
  echo "/config/authorized_keys file not found / mounted"
  exit 1
fi
cp /config/authorized_keys /root/.ssh/authorized_keys || exit 1

# Deploy private key
if [ ! -f "/config/key" ]; then
  echo "/config/key file not found / mounted"
  exit 1
fi
cp /config/key /root/.ssh/id_ecdsa || exit 1

# Ensure permissions are correct
chown -R root.root /root/.ssh || exit 1
chmod 644 /root/.ssh/authorized_keys || exit 1
chmod 644 /root/.ssh/known_hosts || exit 1
chmod 600 /ssh_host_ecdsa_key || exit 1
chmod 600 /root/.ssh/id_ecdsa || exit 1

# Start the server
/usr/sbin/sshd -f /etc/ssh/sshd_config

# continuously try to connect to the remote server
loop() {
  while true; do
    if [ "$BIND_IP" == "" ]; then
      echo "Connecting to ${SERVER} ..."
      ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=1 -N -R 2223:localhost:2222 -p 2222 root@$1
    else
      echo "Connecting to ${SERVER} from ${BIND_IP} ..."
      ssh -b ${BIND_IP} -o ServerAliveInterval=60 -o ServerAliveCountMax=1 -N -R 2223:localhost:2222 -p 2222 root@$1
    fi
    echo "Connection to ${SERVER} lost, retrying in ${RETRY_DELAY}s"
    sleep ${RETRY_DELAY}
  done
}

IFS=","
for SERVER in ${SERVERS}; do
  loop $SERVER &
done

sleep infinity
