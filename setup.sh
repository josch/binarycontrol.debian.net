#!/bin/sh

set -x

ARCH="amd64"
MIRROR="http://http.debian.net/debian"

rm -rf cache.tmp
mkdir -p cache.tmp

# this could be done with chdist but we want to keep the dependencies minimal
for SUITE in "testing" "unstable"; do
	DIRECTORY="`pwd`/debian-$SUITE-$ARCH"

	export APT_CONFIG=$DIRECTORY/etc/apt/apt.conf

	mkdir -p $DIRECTORY/etc/apt/trusted.gpg.d/
	mkdir -p $DIRECTORY/etc/apt/apt.conf.d/
	mkdir -p $DIRECTORY/etc/apt/sources.list.d/
	mkdir -p $DIRECTORY/etc/apt/preferences.d/
	mkdir -p $DIRECTORY/var/lib/apt/lists/partial/
	mkdir -p $DIRECTORY/var/lib/dpkg/
	mkdir -p $DIRECTORY/var/cache/apt/apt-file/
	mkdir -p $DIRECTORY/var/cache/apt/archives/partial

	# we have to also set Apt::Architectures to avoid foreign architectures
	# from the host influencing this
	cat << END > "$APT_CONFIG"
Apt {
   Architecture "$ARCH";
   Architectures "$ARCH";
};

Dir "$DIRECTORY";
Dir::State::status "$DIRECTORY/var/lib/dpkg/status";

Acquire::Check-Valid-Until false;
END

	for keyring in debian-archive-keyring.gpg debian-archive-removed-keys.gpg; do
		cp /usr/share/keyrings/$keyring $DIRECTORY/etc/apt/trusted.gpg.d/
	done

	touch $DIRECTORY/var/lib/dpkg/status

	echo deb $MIRROR $SUITE main > $DIRECTORY/etc/apt/sources.list

	apt-get update

	# for all available package, get the download url and feed that one
	# to ./download_unpack.sh
	#
	# the first xargs makes sure to run `apt-get download` with multiple
	# packages at a time as it would otherwise be the bottleneck
	#
	# the second xargs distributes the downloads to more than one process
	# at a time. This number could be higher but is as low as it is to not
	# max out cpu usage
	apt-cache dumpavail | awk '/^Package:/ {print $2}' | sort \
		| xargs apt-get --print-uris download \
		| sed -ne "s/^'\([^']\+\)'\s\+\([^_]\+\)_.*/\2 $SUITE \1/p" \
		| sort \
		| xargs --max-procs=2 --max-args=3 ./download_unpack.sh
done

rm -rf cache csearchindex
mv cache.tmp cache

CSEARCHINDEX=./csearchindex cindex cache
