#!/bin/sh
#
# Author:   D'Artagnan Palmer
# License:  Copyright (c) 2014, The MIT License (MIT)
# Summary:  Setup server to receive connections from backup

#  You should only have to run this once

# please end it with "/"
BU_BASE=/var/backups/external/
BU_GROUP=ebackups
BU_USER_PREFIX="bu_"

mkdir "${BU_BASE}"
chown root:root "${BU_BASE}"
chmod 755 "$BU_BASE"

addgroup ${BU_GROUP}

sed -i -e 's/Subsystem sftp .*$/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config

echo ""
echo "Match group ebackups" >> /etc/ssh/sshd_config
echo "ChrootDirectory ${BU_BASE}" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
