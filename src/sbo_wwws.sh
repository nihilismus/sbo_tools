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
    resource="result/?search=$1&sv=13.37"

    result=$(lynx -dump "$server/$resource" | grep \
        "$server/repository/" | \
        sed 's/^.*repository/\/usr\/ports/' | \
        sed '/\/usr\/ports\/13.37\/$/d' | sort)

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
