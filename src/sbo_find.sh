#!/usr/bin/env bash

me=$(basename $0)


usage() {
cat << EOF
Usage:
$me SlackBuild_name

About:
$me searches for a SlackBuild directory in the local repository
matching the given SlackBuild_name. It makes the search in case
insensitive. You can use the wildcard '*' in SlackBuild_name,
and if this is the case you must enclose it with single quotes
to avoid pathname expansion by the shell.

Examples:

  This prints all SlackBuilds directories inside the repository:
    $me '*'

  This prints all SlackBuilds directories that starts with 'py'.
    $me 'py*'

  This prints all SlackBuilds directories that ends with 'kernel'.
    $me '*kernel'

  This print all SlackBuilds directories that has 'font' in their
  name.
    $me font
EOF
}

SBO_LOCAL_REPOSITORY=${SBO_LOCAL_REPOSITORY:-/usr/ports}

set -f
set -e

if [ -z "$SLACKWARE_VERSION" ]; then
    echo "$me: Error, enviroment variable SLACKWARE_VERSION is not defined"
    exit 1
fi

SBO_LOCAL_REPOSITORY=$SBO_LOCAL_REPOSITORY/$SLACKWARE_VERSION

if [ ! -d $SBO_LOCAL_REPOSITORY/ ]; then
    echo "$me: Error, directory $SBO_LOCAL_REPOSITORY does not exist."
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
            results=$(find $SBO_LOCAL_REPOSITORY/ -maxdepth 2 -mindepth 2 -type d -iname "*$search*")
        else
            results=$(find $SBO_LOCAL_REPOSITORY/ -maxdepth 2 -mindepth 2 -type d -iname "$search")
        fi
        ;;
    2)
        search=$2
        if [ $1 = "-e" ]; then
            results=$(find $SBO_LOCAL_REPOSITORY/ -maxdepth 2 -mindepth 2 -type d -iname "$search")
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
