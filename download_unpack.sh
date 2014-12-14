#!/bin/sh

if [ $# -ne 2 ]; then
	echo "insufficient number of arguments" >&2
	exit 1
fi

pkg="$1"
url="$2"

echo "working on $pkg" >&2

mkdir -p "cache.tmp/$pkg"

curl --location --silent "$url" | ./extract_binary_control.py | tar -C "cache.tmp/$pkg" --exclude=./md5sums -xz
