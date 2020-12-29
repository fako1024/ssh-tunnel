#!/bin/sh

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
/usr/sbin/sshd -D -f /etc/ssh/sshd_config
