#!/usr/bin/env bash

set -e

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me

About:
$me synchronize /usr/ports with slackbuilds.org repository,
based on the version of your Slackware system.
EOF
}

if [ $# -ne 0 ]; then
    usage
    exit
fi

if [ $(id --user) -ne 0 ]; then
    echo "$me: Error, just the root user can execute this script"
    exit 1
fi

if [ -f /usr/ports/in_use ]; then
    echo "$me: Error, there is another instance in execution"
    exit 1
else
    touch /usr/ports/in_use
fi

# Get a list of available repositories at slackbuilds.org
sbo_rsync_modules="$(rsync slackbuilds.org::slackbuilds 2>/dev/null | awk '{print $5}' | sed 's/^.$//')"

if [ -z "$sbo_rsync_modules" ]; then
    echo "$me: Error, the list of available repositories at slackbuilds.org could be not retrieved"
    exit 1
fi

# Detect the matching repository for the Slackware version in this system
for module in $sbo_rsync_modules; do
    if grep $module /etc/slackware-version 1>/dev/null 2>/dev/null; then
        slk_version=$module
    fi
done

if [ -z "$slk_version" ]; then
    echo "$me: Error, can find a repository for '$(cat /etc/slackware-version)' at slackbuilds.org"
    exit 1
fi

echo "$me: rsync:://slackbuilds.org/slackbuilds/$slk_version => /usr/ports"
echo -n "$me: synchronizing in 5 segs "
for dot in 1 2 3 4 5; do
    sleep 1
    echo -n '.'
done

echo
echo

rsync_error=0
rsync \
    --protect-args \
    --human-readable \
    --archive \
    --compress \
    --verbose \
    --delete \
    --delete-after \
    --delete-excluded \
    --no-perms \
    --no-owner \
    --no-group \
    --exclude='/*/*.tar.gz' \
    --exclude='/*/*.tar.gz.asc' \
    --exclude='/in_use' \
    --safe-links \
    "slackbuilds.org::slackbuilds/$slk_version/" /usr/ports || rsync_error=$? && true

if [ $rsync_error -ne 0 ]; then
    echo
    echo "$me: Error, rsync execution failed"
    rm -f /usr/ports/in_use
    exit 1
fi

echo
echo "$me: done"
