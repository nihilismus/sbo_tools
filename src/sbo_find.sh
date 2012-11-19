#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me SlackBuild_name

About:
$me searches for an SlackBuild directory in the local repository
matching the given SlackBuild_name. It makes the search in case
insensitive. You can use the wildcard '*' in SlackBuild_name,
and if this is the case you must enclose it with single quotes
to avoid pathname expansion by the shell.

Examples:

  This prints all SlackBuilds directories inside the repository:

    $me '*'

  This prints all SlackBuilds directories that starts with 'py':

    $me 'py*'

  This prints all SlackBuilds directories that ends with 'kernel':

    $me '*kernel'

  This prints all SlackBuilds directories that has 'font' in their
  name:

    $me font

  This prints the SlackBuild directory that match exactly
  'virtualbox-kernel':

    $me -e virtualbox-kernel

  in contrast with:
    $me virtualbox-kernel
EOF
}

search() {
    asterisk=$(echo $1 | grep '*' || echo '')
    if [ -z "$asterisk" ]; then
        results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -iname "*$1*")
    else
        results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -iname "$1")
    fi
    echo $results
}

searchexactly() {
    string=$(echo $1 | sed 's/\*//g')
    results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -name "$string")
    echo $results
}

set -f
set -e

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
            exit
        fi
        results=$(search $1)
        ;;
    *)
        results=""
        if [ $1 = "-e" ]; then
            for string in $@
            do
                shift
                results="$results $(searchexactly $1)"
            done
        fi
        for string in $@
        do
            results="$results $(search $1)"
        done
        ;;
esac

# To erase blank spaces in case there is no result
results=$(echo $results)

if [ -z "$results" ]; then
    exit 1
fi

echo $results | sed 's/ /\n/g'
