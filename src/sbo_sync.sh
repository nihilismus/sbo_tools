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

# Get a list of slackware versions available at SBo's rsyncd
sbo_rsync_modules=$(rsync slackbuilds.org::slackbuilds | awk '{print $5}' | \
    sed 's/^.$//')

if [ -z "$sbo_rsync_modules" ]; then
    echo "$me: Error, while contacting slackbuilds.org"
    exit 1
fi

# Detect the slackware version from /etc/slackware-version
slk_version=""
for module in $sbo_rsync_modules; do
    matched=$(grep "$module" /etc/slackware-version || echo '')
    if [ ! -z "$matched" ]; then
        slk_version=$module
    fi
done

if [ -z "$slk_version" ]; then
    echo "$me: Error, the version of Slackware could not be determined."
    echo "  This means that you have an incorrect content in /etc/slackware-version"
    echo "  or that SBo still does not have a repository for '$(cat /etc/slackware-version)'"
    exit 1
fi

local_repository="/usr/ports/$slk_version"

if [ ! -d $local_repository/ ]; then
    mkdir -p $local_repository
    touch $local_repository/ChangeLog.txt
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
echo -n "$me: synchronizing in 5 segs "
for dot in 1 2 3 4 5; do
    sleep 1
    echo -n '.'
done
echo

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
