Introduction
============

This is the source code for binarycontrol.debian.net.

It allows to search all unpacked Debian Sid amd64 binary package control
archives using codesearch.

The file `search` is a CGI script and essential a frontend for the `csearch`
command.

The file `setup.sh` updates the local file cache and the search index using the
http.debian.net mirror. To safe bandwidth, only the head of each binary package
is downloaded (the `control.tar.gz` is at the start of the debian package
archive).

Requirements
============

 - a web server (I use nginx and fcgiwrap)
 - codesearch

License
=======

Copyright 2014 Johannes Schauer <j.schauer@email.de>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
