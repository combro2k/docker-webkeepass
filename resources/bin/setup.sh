#!/bin/bash

trap '{ echo -e "error ${?}\nthe command executing at the time of the error was\n${BASH_COMMAND}\non line ${BASH_LINENO[0]}" && tail -n 10 ${INSTALL_LOG} && exit $? }' ERR

export DEBIAN_FRONTEND="noninteractive"

# Packages
export PACKAGES=(
    'git'
    'libexpat1-dev'
    'libssl-dev'
    'libxml2-dev'
)

pre_install() {
	apt-get update -q 2>&1 || return 1
	apt-get install -yq ${PACKAGES[@]} 2>&1 || return 1

    chmod +x /usr/local/bin/* || return 1

    return 0
}

install_webkeepass(){
    perlbrew init 2>&1 || return 1

    perlbrew install -n perl-5.22.0 --as webkeepass 2>&1 || return 1

    perlbrew use webkeepass 2>&1 || return 1

    cpanm -nq Dist::Zilla 2>&1 || return 1
    git clone https://github.com/sukria/WebKeePass.git /srv/webkeepass 2>&1 || return 1

    cd /srv/webkeepass 2>&1 || return 1

    dzil authordeps | cpanm -fnq 2>&1 || true
    dzil listdeps | cpanm -fnq 2>&1 || return 1
    cpanm -fnq Dancer2 Digest::SHA1 Dancer2::Plugin::Ajax XML::Parser || return 1

    return 0
}

post_install() {
    apt-get autoremove 2>&1 || return 1
	apt-get autoclean 2>&1 || return 1
	rm -fr /var/lib/apt 2>&1 || return 1

	return 0
}

build() {
	if [ ! -f "${INSTALL_LOG}" ]
	then
		touch "${INSTALL_LOG}" || exit 1
	fi

	tasks=(
	    'pre_install'
        'install_webkeepass'
	)

	for task in ${tasks[@]}
	do
		echo "Running build task ${task}..." || exit 1
#		${task} | tee -a "${INSTALL_LOG}" > /dev/null 2>&1 || exit 1
        ${task} | tee -a "${INSTALL_LOG}" || exit 1
	done
}

if [ $# -eq 0 ]
then
	echo "No parameters given! (${@})"
	echo "Available functions:"
	echo

	compgen -A function

	exit 1
else
	for task in ${@}
	do
		echo "Running ${task}..." 2>&1  || exit 1
		${task} || exit 1
	done
fi
