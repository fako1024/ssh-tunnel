#!/bin/sh

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
/usr/sbin/sshd -D -f ${HOME}/sshd_config
