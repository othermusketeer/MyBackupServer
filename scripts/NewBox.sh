#!/bin/sh
#
# This preps the Pi
#
#
export supDOMAIN = "example.com"
export supHOST = "host"
export supIP = ""
export supSSHPort = 22
export supDefinedDNS = $FALSE


initNewPi() {
	

	return $FALSE
}

haveSudoUsers() {

	return $FALSE
}

setupHostName() {
	echo "${supHOST}" > /etc/hostname
	/etc/init.d/hostname.sh
	# maybe rewrite /etc/hosts
cat > /etc/hosts <<EOF
127.0.0.1       ${supHOST}.${supDOMAIN} ${supHOST}.local ${supHOST} localhost.localdomain localhost

## TODO from SCRIPT Check and correct this, and then uncomment
#${supIP}    ${supHOST}.${supDOMAIN}  ${supHOST}.local  ${supHOST}

## SCRIPT DYNDNS=NO ##
## 0.0.0.0    ${supHOST}.${supDOMAIN} ${supHOST}
## ================ ##

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF
	return $TRUE
}

setupResolvConf() {
	# in /etc/resolv.conf :  "domain host.domain.tld"  "search host.domain.tld" "nameserver 1.2.3.4"
}

setupNetwork() {
	# if network not setup
	echo "host.domain.tld" > /etc/hostname
	/etc/init.d/hostname.sh start
}

setupUserAtHost() {
	# ssh-keygen -t rsa [ -C "Comment field" ] [ -f ~/.ssh/file ]
}

resetSSHhostKeys() {
rm -f /etc/ssh/ssh_host_*
cat << EOF > /etc/init.d/ssh_gen_host_keys
#!/bin/sh
#
## BEGIN INIT INFO
# Provides:          Generates new ssh host keys on first boot
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Generates new ssh host keys on first boot
# Description:       Generates new ssh host keys on first boot
#
## END INIT INFO
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ""
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ""
insserv -r /etc/init.d/ssh_gen_host_keys
rm -f \$0
EOF
chmod a+x /etc/init.d/ssh_gen_host_keys
insserv /etc/init.d/ssh_gen_host_keys
}
+
reconfigureLocality() {
	dpkg-reconfigure tzdata
	# reconf locale
	dpkg-reconfigure locales
}

setupScreenrc() {
RCFILE="~/.screenrc"
cat << EOF > "$RCFILE"
# Enable 256-color mode when screen is started with TERM=xterm-256color
# Taken from: http://frexx.de/xterm-256-notes/
#
# Note that TERM != "xterm-256color" within a screen window. Rather it is
# "screen" or "screen-bce"
# 

# terminfo and termcap for nice 256 color terminal
# allow bold colors - necessary for some reason
attrcolor b ".I"

altscreen on
attrcolor i "+b"
autodetach on
caption always
scrollback 2000
utf8 on
defutf8 on
startup_message off
time


# tell screen how to set colors. AB = background, AF=foreground
termcapinfo xterm-256color 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'
EOF
}

# TODO: Where do I put this again!?! Its been so long since I used Linux.
#if [ ! -z "$TERMCAP" ] && [ "$TERM" == "screen" ]; then                         
#    export TERMCAP=$(echo $TERMCAP | sed -e 's/Co#8/Co#256/g')                  
#fi 

rewriteThis() {
# TODO: Rewrite this
# Install Utilities (all)
apt-get install htop rsync bzip2 p7zip less nano ccze \
rar unrar unzip zip p7zip-full lzop lzip lzma ntp lshw hwinfo \
sshfs screen lsof bash-completion attr curl cabextract elinks \
grep gawk hexedit hexer ifstat iftop lslk lsof lzop memstat \
mtr-tiny nethogs openssl screen sed sqlite python-sqlite \
sqlite3 ssl-cert sun-java6-jre ncurses-term openssl-blacklist \
supercat sysv-rc-conf time unattended-upgrades unace wget locate
# ----

# Install Utilities (physical)
apt-get install fakeroot build-essential hdparm ntfs-3g bash-doc parted ntfs-3g ntfsprogs fuse-utils \
cpufrequtils dosfstools e2fsprogs firmware-linux firmware-linux-nonfree ntp

apt-get install lm-sensors binutils-doc cpp-doc gcc-doc python-smbus glibc-doc libstdc++6-4.4-doc \
read-edid make-doc parted-doc i2c-tools lm-sensors
# ----

# Install Multimedia
apt-get install aacgain aacplusenc alsa-base alsa-utils alsa-tools \
alsa-oss amrnb amrwb armenc avidemux-cli avinfo cutmp3 \
deb-multimedia-keyring faac ffmpeg ffpegthumbnailer ffmsindex \
flac flvtool2 h264enc id3tool lame linux-sound-base mediainfo mimms \
mjpegtools mp3gain mp3split mpg123 mpg321 normalize-audio sox \
vorgisgain x264 mp3check mp3info mp3val mp4-utils vorbis-tools 
# ---

# Mysql Installs
mysql-client mysql-server python-mysqldb libdbd-mysql-perl libclass-dbi-perl libdbd-sqlite3-perl libdbd-sqlite2-perl \
libclass-dbi-sqlite-perl libdbi-perl libdatetime-format-dbi-perl python-sqlite python-pysqlite2
# ---

# write to motd or issue
echo <<EOF
This computer system is the private property of its owner, whether individual, corporate or government. It is
for authorized use only. Users (authorized or unauthorized) have no explicit or implicit expectation of
privacy.

Any or all uses of this system and all files on this system may be intercepted, monitored, recorded, copied,
audited, inspected, and disclosed to your employer, to authorized site, government, and law enforcement
personnel, as well as authorized officials of government agencies, both domestic and foreign.

By using this system, the user consents to such interception, monitoring, recording, copying, auditing,
inspection, and disclosure at the discretion of such personnel or officials.


        UNAUTHORIZED OR IMPROPER USE OF THIS SYSTEM MAY RESULT
        IN CIVIL AND CRIMINAL PENALTIES AND ADMINISTRATIVE OR
        DISCIPLINARY ACTION, AS APPROPRIATE !!


By continuing to use this system you indicate your awareness of and consent to these terms and conditions of
use. LOG OFF IMMEDIATELY if you do not agree to the conditions stated in this warning. However, if you are
authorized personal with no bad intentions please continue. Have a nice day! :-)
EOF

}

installWebmin() {
# TODO: Update this
Webmin Install
# http://www.webmin.com/deb.html
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.600_all.deb
apt-get update
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl \
apt-show-versions python
dpkg --install webmin_1.600_all.deb
# ## make webmin inetd managed
/etc/webmin/stop
# remove session=1 from miniserv.conf
if [ `grep -P -m 1 -i -c '^inetd\s*=\s*.*$' /etc/webmin/miniserv.conf  2>/dev/null` == 0 ]; then
    echo 'inetd=1' | sudo tee -a /etc/webmin/miniserv.conf
else
    sed -i -r 's/inetd\s*=\s*.*?/inetd=1/i' /etc/webmin/miniserv.conf
fi
sed -i -r 's/^session\s*=\s*.*?$/# entry session=1 removed/i' /etc/webmin/miniserv.conf
# edit /etc/services, add webmin 10000/tcp
if [ `grep -P -m 1 -i -c '^\s*webmin\s*stream\s*tcp' /etc/inetd.conf` == 0 ]; then
    echo 'webmin stream tcp nowait root /usr/share/webmin/miniserv.pl miniserv.pl /etc/webmin/miniserv.conf' \
        | sudo tee -a /etc/inetd.conf
fi
service openbsd-inetd reload
# firewall ports 10000-10010 local network

}

addAllRepos() {
	# TODO: Check the sed regex
	#sed --quiet -i -r -e 's@(deb\s+(?:http|https|ftp)\:\/\/[^\/]+\/debian*\s+(?:squeeze|wheezy|etch|jessie|sid|lenny|sarge).*$@\1 main contrib non-free@i'
	sed -r -e 's@(deb(?:-src)?	\s+(?:http|https|ftp)\:\/\/[^\/]+\/\S*\s+(?:squeeze|wheezy|etch|jessie|sid|lenny|sarge)(\/updates)?\s*.*$@\1 main contrib non-free@i' /etc/apt/sources.list
	apt-get update
}

secureRoot() {
	if haveSudoUsers(); then
		chmod 700 /root
		usermod -L root
	else
		# TODO: Warn about no sudo users, and maybe call addSudoer
	fi
}

installEditors() {
	apt-get install vim vim-doc vim-scripts vim-addon-manager less nano ccze ctags
}

setAptProxy() {
cat > /etc/apt/apt.conf.d/01proxy <<EOF
Acquire::http { Proxy "http://plum:3142"; };
EOF
}

setAptNoRecomends() {
cat > /etc/apt/apt.conf.d/10recommends <<EOF
APT "";
APT::Install-Recommends "false";
EOF
apt-get update
}

setupSSH() {
	# if not installed SSH

	apt-get update
	apt-get install --no-install-recommends ssh tcpd openssh-blacklist openssh-blacklist-extra

}

addSudoer() {
	# ensure SSH is setup up, otherwise complain
}