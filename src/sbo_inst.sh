#!/usr/bin/env bash

me=$(basename $0)

set -f
set -e

usage() {
cat << EOF
Usage:
$me [-n] [string]

About:
$me searches (incase sensitive) for a package name matching the
given string inside /var/log/packages and print a formated output
with the last status change time for each file which would (in most
cases) indicate the date that package was installed.

Options:
-n: print just the matching names.

Examples:

  This prints all packages that starts with 'lib*'.
    $me 'lib*'

  This prints just the names of all packages that end with '_SBo'.
    $me -n '*_SBo'

EOF
}

search() {
    find /var/log/packages/ -maxdepth 1 -mindepth 1 -type f \
        -iname "$1" -printf '%CY-%Cm-%Cd  %CH:%CM:%CS  %f\n' | \
        sed 's/\.0\{10\}//' | sed 's/$/\n/' | \
        sed '/^ *$/d' | sort -r
}

case $# in
    0)
        search '*'
        exit
        ;;
    1)
        if [ $1 = "--help" ]; then
            usage
            exit
        fi

        if [ $1 = "-n" ]; then
            search '*' | awk '{print $3}'
            exit
        fi

        result=$(search "$1" | awk '{print $1" "$2" "$3"\\n"}')
        if [ -z "$result" ]; then
            echo "$me: Error, no results for '$1'"
            exit 1
        fi

        echo -e $result | sed -e 's/^ //' -e '/^$/d'
        exit
        ;;
    2)
        if [ $1 = "-n" ]; then
            result=$(search "$2" | awk '{print $3"\\n"}')
            if [ -z "$result" ]; then
                echo "$me: Error, no results for '$2'"
                exit 1
            fi

            echo -e $result | sed -e 's/^ //' -e '/^$/d'
            exit
        fi

        usage
        exit 1
        ;;
    *)
        usage
        exit 1
        ;;
esac
