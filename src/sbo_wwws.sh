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
    resource="result/?search=$1"

    result="$(lynx -noredir -dump "$server/$resource" 2>/dev/null | \
        grep -a $server/repository | \
        sed 's/^.*repository/\/usr\/ports/' | sort | uniq)"

    echo "Search Results for '$1':"

    for directory in $result; do
        package="$(echo $directory | cut -d '/' -f 5,6)"

        about=""
        if [ -f "/usr/ports/$package/slack-desc" ]; then
            about=$(grep -A 1 'handy-ruler' /usr/ports/$package/slack-desc | \
                tail -1 | sed -e 's/^.* (//' -e 's/) *$//')
            echo "/usr/ports/$package  $about"
        fi
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
