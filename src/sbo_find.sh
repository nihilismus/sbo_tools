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

set -f
set -e

slk_version=13.37
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
        if [ $1 = "--help" ]; then
            usage
            exit
        fi
        search=$1
        asterisk=$(echo $1 | grep '*' || echo '')
        if [ -z "$asterisk" ]; then
            results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -iname "*$search*")
        else
            results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -iname "$search")
        fi
        ;;
    2)
        search=$2
        if [ $1 = "-e" ]; then
            results=$(find $local_repository/ -maxdepth 2 -mindepth 2 -type d -iname "$search")
        else
            usage
            exit
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

if [ -z "$results" ]; then
    echo "$me: Error, no results for '$search'"
    exit 1
fi

echo $results | sed 's/ /\n/g'
