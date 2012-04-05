#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me

About:
$me synchronize a local repository of Slackware build scripts
from http://www.slackbuilds.org project.

The local repository is defined by the enviroment variable
SBO_LOCAL_REPOSITORY, by default it is set to /usr/ports.

Based in the enviroment variable SLACKWARE_VERSION, the remote
repository would be syncronized in SBO_LOCAL_REPOSITORY, since
there is not default value for this variable so must be defined.
EOF
}

SBO_LOCAL_REPOSITORY=${SBO_LOCAL_REPOSITORY:-/usr/ports}

set -e

if [ $# -ne 0 ]; then
    usage
    exit
fi

if [ $(id --user) -ne 0 ]; then
    echo "$me: Error, you do not have root permissions."
    exit 1
fi

if [ -z "$SLACKWARE_VERSION" ]; then
    echo "$me: Error, enviroment variable SLACKWARE_VERSION is not defined"
    exit 1
fi

SBO_LOCAL_REPOSITORY=$SBO_LOCAL_REPOSITORY/$SLACKWARE_VERSION

if [ ! -d $SBO_LOCAL_REPOSITORY/ ]; then
    echo "$me: Error, directory $SBO_LOCAL_REPOSITORY does not exist."
    exit 1
fi

if [ ! -f $SBO_LOCAL_REPOSITORY/ChangeLog.txt ]; then
    echo "$me: Error, file $SBO_LOCAL_REPOSITORY/ChangeLog.txt does not exist."
    exit 1
fi

touch $SBO_LOCAL_REPOSITORY/.writable 2>&1
if [ $? -ne 0 ]; then
    echo "$me: Error, you do not have write permission in $SBO_LOCAL_REPOSITORY"
    exit 1
fi
rm -f $SBO_LOCAL_REPOSITORY/.writable

sbo_rsync_server="slackbuilds.org"
sbo_rsync_module="slackbuilds/$SLACKWARE_VERSION"

# As a "security" step before executing rsync.
cd $SBO_LOCAL_REPOSITORY/ || exit 1

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
    echo "$0: Error, there was an error with rsync execution"
    exit 1
fi

echo "$0: done"
