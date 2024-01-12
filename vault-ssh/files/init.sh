#/usr/bin/sh

apt-get update
apt install -y openssh-server curl

mkdir /var/run/sshd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
curl -k -o /etc/ssh/trusted-user-ca-keys.pem https://haproxy/v1/ssh-client-signer/public_key
echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem" >> /etc/ssh/sshd_config

useradd -m ubuntu -s /bin/bash


/usr/sbin/sshd -D