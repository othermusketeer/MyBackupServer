#!/bin/sh
#
# Author:   D'Artagnan Palmer
# License:  Copyright (c) 2014, The MIT License (MIT)
# Summary:  Add a new user, and configure to allow receiving backups

BU_USER="$1"
KEY_COMMENT="$2"
KEY_PASSWORD="$3"
# please end it with "/"
BU_BASE=/var/backups/external/
BU_GROUP=ebackups
BU_USER_PREFIX="bu_"

# -d homedir, -g groupid, -N (no create group), -M (no create homedir)
useradd ${BU_USER_PREFIX}${BU_USER} -d /${BU_USER} -g ${BU_GROUP} -N -M

mkdir ${BU_BASE}${BU_USER}
chown ${BU_USER_PREFIX}${BU_USER}:${BU_GROUP} ${BU_BASE}${BU_USER}
chmod o-rwx ${BU_BASE}${BU_USER}
mkdir "${BU_BASE}{$BU_USER}/.ssh"
chown ${BU_USER_PREFIX}${BU_USER} "${BU_BASE}{$BU_USER}/.ssh"
chmod 600 "${BU_BASE}{$BU_USER}/.ssh"
ssh-keygen -t rsa -C "$KEY_COMMENT" -N "${KEY_PASSWORD}" -f "${BU_BASE}{$BU_USER}/.ssh/backup_rsa"
chown -R ${BU_USER_PREFIX}${BU_USER} "${BU_BASE}{$BU_USER}/.ssh"
chmod -R 600 "${BU_BASE}{$BU_USER}/.ssh"
