#!/bin/sh

# Author:   D'Artagnan Palmer
# License:  Copyright (c) 2014, The MIT License (MIT)
# Summary:  Setup server to receive connections from backup

#	You should only have to run this once
#
#	2014/6/7	Added conditionals to carry out actions only if needed. Added root permision check.
#

# please end it with "/"
BU_BASE=/var/backups/external/
BU_GROUP=ebackups
BU_USER_PREFIX="bu_"
ROOTUID="0"

# Check/ensure user has root privileges.
# From StackOverflow answer by mhoareau, http://stackoverflow.com/a/6362626/3453155
if [ "$(id -u)" -ne "$ROOTUID" ] ; then
    echo "This script must be executed with root privileges."
    exit 1
fi


if [ ! -r "${BU_BASE}" ]; then
	echo "Adding base directory '${BU_BASE}'..."
	mkdir "${BU_BASE}"
	chown root:root "${BU_BASE}"
	chmod 755 "$BU_BASE"
else
	echo "Base directory '${BU_BASE}' already exists..."
fi

getent group ${BU_GROUP} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Add group '${BU_GROUP}'..."
	addgroup ${BU_GROUP}
else
	echo "Group '${BU_GROUP}' already exists..."
fi

grep '^Subsystem sftp internal-sftp' /etc/ssh/sshd_config
if [ $? -ne 0 ]; then
	echo "Modifying sshd_config to support sftp backups..."
	cp -a /etc/ssh/sshd_config /etc/ssh/sshd_conf.orig.bu
	sed -i -e 's/Subsystem sftp .*$/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config
	echo "Match group ${BU_GROUP}" >> /etc/ssh/sshd_config
	echo "ChrootDirectory ${BU_BASE}" >> /etc/ssh/sshd_config
	echo "X11Forwarding no" >> /etc/ssh/sshd_config
	echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
	echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
else
	echo "Modifications to sshd_config seem to not be needed..."
fi
echo ""

echo "Group '${BU_GROUP}' will back up to directory '${BU_BASE}'."

echo ""
echo "SetupBackupServer.sh is now done."
