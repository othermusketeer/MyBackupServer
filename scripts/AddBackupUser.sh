#!/bin/sh
#
# Author:   D'Artagnan Palmer
# License:  Copyright (c) 2014, The MIT License (MIT)
# Summary:  Add a new user, and configure to allow receiving backups
#
#
#
#	2014/6/7	Added conditionals to carry out actions only if needed. Added root permission check.
#	2014/6/7	Fixed a typo causing an error with variables ('{$'->'${'). Reformatted progress messages.
#	2014/6/7	Added null redirects. Quoted some directory paths. Made created users --disable-login
#	2014/6/8	Fixed user creation. Had conflated options for useradd and adduser. Write check missing NOT.
#

BU_USER="$1"
KEY_COMMENT="$2"
KEY_PASSWORD="$3"
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

getent group ${BU_GROUP} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "ERROR: The specified GID for backups, '${BU_GROUP}', does not exist!"
	echo "ERROR:     You need to run SetupBackServer.sh first. Aborting!!!"
	exit 2
fi

if [ ! -r "${BU_BASE}" ]; then
	echo "ERROR: Unable to read base directory used for backups, '${BU_BASE}'!"
	echo "ERROR:     You might need to run SetupBackServer.sh first. Aborting!!!"
	exit 3
fi

echo ""
echo "Configuring backups for '${BU_USER}' (${KEY_COMMENT})."
echo "Defaults:"
echo "    Group: ${BU_GROUP}     User Prefix: ${BU_USER_PREFIX}"
echo "    Base: ${BU_BASE}"
echo ""

id -u  ${BU_USER_PREFIX}${BU_USER} >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
	echo "*** Adding user '${BU_USER_PREFIX}${BU_USER}'..."
	useradd -c "${BU_USER} Backup" -d /${BU_USER} -g ${BU_GROUP} -M -N -s /bin/false ${BU_USER_PREFIX}${BU_USER}
	if [ $? -ne 0 ]; then
		echo "ERROR: Unable to create user '${BU_USER_PREFIX}${BU_USER}'! Aborting!!!"
		exit 10
	fi
else
	echo "ERROR: User '${BU_USER_PREFIX}${BU_USER}' already exists! Aborting!!!"
	exit 4
fi

# If backup directory exists, make sure its suitable. If it doesn't, make it.
if [ -d "${BU_BASE}${BU_USER}" ]; then
	echo "WARNING: Backup directory '${BU_BASE}${BU_USER}' exists! Checking suitability..."
	sleep 2
	if [ -n "$(find "${BU_BASE}${BU_USER}" -user "${BU_USER_PREFIX}${BU_USER}" -print -prune -o -prune)" ]; then
		echo "    The user ownership is right. Still checking..."
		if [ -n "$(find "${BU_BASE}${BU_USER}" -group "${BU_GROUP}" -print -prune -o -prune)" ]; then
			echo "    The group ownership is also right. Proceeding after a delay..."
			sleep 2
		else
			echo "    ERROR: User ownership is wrong! Aborting!!!"
			exit 5
		fi
	else
		echo "    ERROR: Group ownership is wrong! Aborting!!!"
		exit 6
	fi
else
	echo "*** Creating backup directory '${BU_BASE}${BU_USER}'..."
	mkdir "${BU_BASE}${BU_USER}"
	if [ ! -w "${BU_BASE}${BU_USER}" ]; then
		echo "ERROR: Unable to create directory '${BU_BASE}${BU_USER}'! Aborting!!!"
		exit 11
	fi
	chown ${BU_USER_PREFIX}${BU_USER}:${BU_GROUP} ${BU_BASE}${BU_USER}
	chmod o-rwx "${BU_BASE}${BU_USER}"
	chmod g-w "${BU_BASE}${BU_USER}"
fi

if [ ! -d "${BU_BASE}${BU_USER}/.ssh" ]; then
	echo "*** SSH credentials directory doesn't exist. Creating..."
	mkdir "${BU_BASE}${BU_USER}/.ssh"
fi

if [ -d "${BU_BASE}${BU_USER}/.ssh" ]; then
	echo "*** Enforcing ownership and permissions of SSH credentials directory..."
	chown ${BU_USER_PREFIX}${BU_USER} "${BU_BASE}${BU_USER}/.ssh"
	chmod 600 "${BU_BASE}${BU_USER}/.ssh"
else
	echo "ERROR: SSH credentials folder doesn't exist, even after trying to create it! Aborting!!!"
	exit 7
fi

if [ ! -w "${BU_BASE}${BU_USER}/.ssh" ]; then
	echo "WARNING: No write access to credentials directory. Temporarily fixing..."
	chown root "${BU_BASE}${BU_USER}/.ssh"
	chmod 600 "${BU_BASE}${BU_USER}/.ssh"
fi

if [ -w "${BU_BASE}${BU_USER}/.ssh" ]; then
	if [ -z "${KEY_PASSWORD}" ]; then
		echo "WARNING: No password specified (argument #3 to this script) for SSH key!"
		echo "    Key will not be password protected! Proceeding after delay..."
		sleep 2
	fi
	echo "*** Generating RSA key..."
	ssh-keygen -q -t rsa -C "$KEY_COMMENT" -N "${KEY_PASSWORD}" -f "${BU_BASE}${BU_USER}/.ssh/backup_rsa"
else
	echo "ERROR: Unable to write to SSH credentials directory! Aborting!!!"
	exit 8
fi

if [ -r "${BU_BASE}${BU_USER}/.ssh/backup_rsa" ]; then
	echo "*** Reading RSA fingerprint..."
	KEY_FINGERPRINT=$(ssh-keygen -l -f "${BU_BASE}${BU_USER}/.ssh/backup_rsa")
	echo "*** Enforcing ownerships and permissions on SSH credentials directory..."
	chmod -R 600 "${BU_BASE}${BU_USER}/.ssh"
	chown -R ${BU_USER_PREFIX}${BU_USER} "${BU_BASE}${BU_USER}/.ssh"
else
	echo "ERROR: Something went wrong generating the RSA key! Aborting!!!"
	exit 9
fi

echo ""
echo "********************************************************************"
echo "Configuration for user '${BU_USER}:"
echo "    Login:  ${BU_USER_PREFIX}${BU_USER}        Group:  ${BU_GROUP}"
echo "    Directory:  ${BU_BASE}${BU_USER}"
echo "    RSA fingerprint: ${KEY_FINGERPRINT}"
echo "********************************************************************"
echo ""

# TODO: copy or email public key to user. For security reasons, maybe not.

echo "Script completed for user ${BU_USER} (${BU_BASE}${BU_USER})."
echo ""