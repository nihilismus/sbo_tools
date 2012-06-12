#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me string [string2 string3 stringN]

About:
$me acts as a command-line interface to SBo's form search.

Given a string, send a request to http://slackbuilds.org/result/
and display a formated output.

Examples:

  $me php

  $me vim emacs

Notes:

Since this depends on http://slackbuilds.org/result/ (and their
security) you can not use wildcards in the string.
EOF
}

set -e

search() {
    server="http://slackbuilds.org"
    resource="result/?search=$1&sv=$slk_version"

    result=$(lynx -dump "$server/$resource" | grep \
        "$server/repository/" | \
        sed 's/^.*repository/\/usr\/ports/' | \
        sed "/\/usr\/ports\/$slk_version\/$/d" | sort)

    echo "Search Results for '$1':"

    for directory in $result; do
        about=""
        if [ -f "$directory/slack-desc" ]; then
            about=$(grep -A 1 'handy-ruler' $directory/slack-desc | \
                tail -1 | sed -e 's/^.* (//' -e 's/) *$//')
        fi
        echo $directory $about | sed -e 's/\/ / /' \
            -e 's/  */ /g' -e 's/\/$//'
    done
}

directories=$(find /usr/ports/ -type d -mindepth 1 -maxdepth 1  -exec basename {} \;)
if [ -z "$directories" ]; then
    echo "$me: Error, /usr/ports seems to be empty"
    exit 1
fi

# Detect the slackware version from /etc/slackware-version
for directory in $directories; do
    matched=$(grep "$directory" /etc/slackware-version || echo '')
    if [ ! -z "$matched" ]; then
        slk_version=$directory
    fi
done

local_repository="/usr/ports/$slk_version"

if [ ! -d $local_repository/ ]; then
    echo "$me: Error, directory $local_repository does not exist."
    exit 1
fi

case $# in
    0)
        usage
        exit 1
        ;;
    1)
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit 1
        else
            search $1
        fi
        ;;
    *)
        for string in $@; do
            search $string
        done
        ;;
esac
