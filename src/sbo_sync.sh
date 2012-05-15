#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me

About:
$me synchronize a local repository of Slackware build scripts
from http://www.slackbuilds.org project.

The local repository is set to /usr/ports.
EOF
}

set -e

if [ $# -ne 0 ]; then
    usage
    exit
fi

if [ $(id --user) -ne 0 ]; then
    echo "$me: Error, you do not have root permissions."
    exit 1
fi

slk_version=13.37
local_repository="/usr/ports/$slk_version"

if [ ! -d $local_repository/ ]; then
    echo "$me: Error, directory $local_repository does not exist."
    exit 1
fi

if [ ! -f $local_repository/ChangeLog.txt ]; then
    echo "$me: Error, file $local_repository/ChangeLog.txt does not exist."
    exit 1
fi

touch $local_repository/.writable 2>&1
if [ $? -ne 0 ]; then
    echo "$me: Error, $local_repository is not writable"
    exit 1
fi
rm -f $local_repository/.writable

sbo_rsync_server="slackbuilds.org"
sbo_rsync_module="slackbuilds/$slk_version"

# As a "security" step before executing rsync.
cd $local_repository/ || exit 1

echo "$me: rsync:://$sbo_rsync_server/$sbo_rsync_module => $(pwd)"
sleep 5

rsync \
    --protect-args \
    --human-readable \
    --archive \
    --compress \
    --verbose \
    --delete \
    --delete-excluded \
    --no-perms \
    --no-owner \
    --no-group \
    --exclude='/*/*.tar.gz' \
    --exclude='/*/*.tar.gz.asc' \
    "$sbo_rsync_server"::"$sbo_rsync_module/" .

if [ $? -ne 0 ]; then
    echo "$me: Error, there was an error with rsync execution"
    exit 1
fi

echo "$me: done"
