#!/bin/sh

if [ $# -ne 3 ]; then
	echo "wrong number of arguments (expect 3, got $#)" >&2
	exit 1
fi

pkg="$1"
suite="$2"
url="$3"

echo "working on $suite, $pkg" >&2

mkdir -p "cache.tmp/$suite/$pkg"

curl --retry 2 --location --silent "$url" | dpkg-deb --ctrl-tarfile /dev/stdin | tar -C "cache.tmp/$suite/$pkg" --exclude=./md5sums -x
