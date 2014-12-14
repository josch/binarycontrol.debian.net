#!/bin/sh


set -e

ARCH="amd64"
DIST="sid"
MIRROR="http://http.debian.net/debian"
DIRECTORY="`pwd`/debian-$DIST-$ARCH"

#FIXME: if the host has more than one arch enabled then those Packages files will be downloaded as well

APT_OPTS=""
APT_OPTS=$APT_OPTS" -o Apt::Architecture=$ARCH"
APT_OPTS=$APT_OPTS" -o Dir::Etc::TrustedParts=$DIRECTORY/etc/apt/trusted.gpg.d"
APT_OPTS=$APT_OPTS" -o Dir::Etc::Trusted=$DIRECTORY/etc/apt/trusted.gpg"
APT_OPTS=$APT_OPTS" -o Dir=$DIRECTORY/"
APT_OPTS=$APT_OPTS" -o Dir::Etc=$DIRECTORY/etc/apt/"
APT_OPTS=$APT_OPTS" -o Dir::Etc::SourceList=$DIRECTORY/etc/apt/sources.list"
APT_OPTS=$APT_OPTS" -o Dir::State=$DIRECTORY/var/lib/apt/"
APT_OPTS=$APT_OPTS" -o Dir::State::Status=$DIRECTORY/var/lib/dpkg/status"
APT_OPTS=$APT_OPTS" -o Dir::Cache=$DIRECTORY/var/cache/apt/"
APT_OPTS=$APT_OPTS" -o Acquire::Check-Valid-Until=false" # because we use snapshot

mkdir -p $DIRECTORY
mkdir -p $DIRECTORY/etc/apt/
mkdir -p $DIRECTORY/etc/apt/trusted.gpg.d/
mkdir -p $DIRECTORY/etc/apt/sources.list.d/
mkdir -p $DIRECTORY/etc/apt/preferences.d/
mkdir -p $DIRECTORY/var/lib/apt/
mkdir -p $DIRECTORY/var/lib/apt/lists/partial/
mkdir -p $DIRECTORY/var/lib/dpkg/
mkdir -p $DIRECTORY/var/cache/apt/
mkdir -p $DIRECTORY/var/cache/apt/apt-file/

cp /etc/apt/trusted.gpg.d/* $DIRECTORY/etc/apt/trusted.gpg.d/

touch $DIRECTORY/var/lib/dpkg/status

echo deb $MIRROR $DIST main > $DIRECTORY/etc/apt/sources.list

apt-get $APT_OPTS update

mkdir -p cache.tmp

apt-cache $APT_OPTS dumpavail | awk '/^Package:/ {print $2}' | sort \
	| xargs apt-get $APT_OPTS --print-uris download \
	| sed -ne "s/^'\([^']\+\)'\s\+\([^_]\+\)_.*/\2 \1/p" \
	| xargs --max-procs=8 --max-args=2 ./download_unpack.sh

rm -rf cache csearchindex
mv cache.tmp cache

CSEARCHINDEX=./csearchindex cindex cache
