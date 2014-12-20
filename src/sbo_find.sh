#!/usr/bin/env bash

set -e
set -f

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me [-e] string

About:
$me searches for an SlackBuild directory in the local repository matching
the given string in insensitive case. To search in sensitive case, use the
-e option.
EOF
}

search() {
    if ! echo $1 | grep '*' 1>/dev/null; then
       find /usr/ports \
            -maxdepth 2 -mindepth 2 -type d -iname "*$1*" | grep -v '.git'
    else
       find /usr/ports \
            -maxdepth 2 -mindepth 2 -type d -iname "$1" | grep -v '.git'
    fi
    echo
}

search_exactly() {
    find /usr/ports -maxdepth 2 -mindepth 2 -type d -name "$(echo $1 | sed 's/\*//g')"
}

case $# in
    0)
        usage
        exit 1
        ;;
    1)
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit
        fi
        string="$1"
        results=$(search "$string")
        ;;
    2)
        if [ $1 = "-e" ]; then
            string="$2"
            results=$(search_exactly "$string")
        else
            usage
            exit 1
        fi
        ;;
esac

if [ -z "$results" ]; then
    echo "$me: No results for '$string'"
else
    echo $results | sed 's/ /\n/g' | sort
fi