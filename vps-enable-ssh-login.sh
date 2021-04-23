#!/bin/bash

cat <<EOF > /etc/ssh/sshd_config
PermitRootLogin yes
PasswordAuthentication yes
EOF

service sshd restart

exit 0