#!/bin/sh

RETRY_DELAY="${RETRY_DELAY:-10}"

if [ "$SERVERS" == "" ]; then
  echo "Missing SERVERS environment variable"
  exit 1
fi

mkdir -p /home/tunnel/.ssh

# Deploy host key
if [ ! -f "/config/host_key" ]; then
  echo "/config/host_key file not found / mounted"
  exit 1
fi
cp /config/host_key /home/tunnel/ssh_host_ecdsa_key || exit 1

# Deploy known public host keys
if [ ! -f "/config/known_hosts" ]; then
  echo "/config/known_hosts file not found / mounted"
  exit 1
fi
cp /config/known_hosts /home/tunnel/.ssh/known_hosts || exit 1

# Deploy public keys
if [ ! -f "/config/authorized_keys" ]; then
  echo "/config/authorized_keys file not found / mounted"
  exit 1
fi
cp /config/authorized_keys /home/tunnel/.ssh/authorized_keys || exit 1

# Deploy private key
if [ ! -f "/config/key" ]; then
  echo "/config/key file not found / mounted"
  exit 1
fi
cp /config/key /home/tunnel/.ssh/id_ecdsa || exit 1

# Ensure permissions are correct
chown -R tunnel.tunnel /home/tunnel/.ssh || exit 1
chmod 644 /home/tunnel/.ssh/authorized_keys || exit 1
chmod 644 /home/tunnel/.ssh/known_hosts || exit 1
chmod 600 /home/tunnel/ssh_host_ecdsa_key || exit 1
chmod 600 /home/tunnel/.ssh/id_ecdsa || exit 1

# Start the server
/usr/sbin/sshd -f ${HOME}/sshd_config

# continuously try to connect to the remote server
loop() {
  while true; do
    if [ "$BIND_IP" == "" ]; then
      echo "Connecting to ${SERVER} ..."
      ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=1 -N -R 2223:localhost:2222 -p 2222 tunnel@$1
    else
      echo "Connecting to ${SERVER} from ${BIND_IP} ..."
      ssh -b ${BIND_IP} -o ServerAliveInterval=60 -o ServerAliveCountMax=1 -N -R 2223:localhost:2222 -p 2222 tunnel@$1
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
