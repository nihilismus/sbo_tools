#!/usr/bin/env bash

set -f
set -e

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me [[-n] string|directory]

About:
$me searches (incase sensitive) for a package name matching the
given string inside /var/log/packages and print a formated output
with the last status change time for each file which would (in most
cases) indicate the date that package was installed.

In case of a directory then it gets information from directory.info
and directory.SlackBuild to see if the SlackBuild is installed
(same VERSION and BUILD), if this is the case then prints a
formated output just as the previous paragraph.
EOF
}

search() {
    find /var/log/packages/ -maxdepth 1 -mindepth 1 -type f \
        -iname "$1" -printf '%CY-%Cm-%Cd  %CH:%CM:%CS  %f\n' | \
        sed 's/\.[0-9]\{10\}//' | sed 's/$/\n/' | \
        sed '/^ *$/d' | sort -r
}

case $# in
    0)
        search '*'
        exit
        ;;
    1)
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit
        fi

        if [ "$1" = "-n" ]; then
            search '*' | awk '{print $3}'
            exit
        fi

        if [ -d "$1" ]; then
            if sbo_info "$1" 1>/dev/null 2>/dev/null; then
                package=$(sbo_info "$1" | grep -E 'Package:' | sed 's/.*  //')
                version=$(sbo_info "$1" | grep -E 'Version:' | sed 's/.*  //')
                build=$(sbo_info "$1" | grep 'Build:' | sed 's/.*  //')
                result=$(search "$package-$version*-*-$build*" | awk '{print $3"\\n"}')

                if [ -z "$result" ]; then
                    echo "$me: $(basename $1) is not installed."
                    exit 1
                fi

                echo -e $result | sed -e 's/^ //' -e '/^$/d'
                exit 0
            else
                sbo_info "$1" | sed 's/sbo_info/sbo_inst/g'
                exit 1
            fi
        fi

        asterisk=$(echo "$1" | grep '*' || echo '')
        if [ -z "$asterisk" ]; then
            result=$(search "*$1*" | awk '{print $1" "$2" "$3"\\n"}')
        else
            result=$(search "$1" | awk '{print $1" "$2" "$3"\\n"}')
        fi

        if [ -z "$result" ]; then
            echo "$me: No results for '$1'"
            exit
        fi

        echo -e $result | sed -e 's/^ //' -e '/^$/d'
        exit
        ;;
    2)
        if [ "$1" = "-n" ]; then
            asterisk=$(echo "$2" | grep '*' || echo '')
            if [ -z "$asterisk" ]; then
                result=$(search "*$2*" | awk '{print $3"\\n"}')
            else
                result=$(search "$2" | awk '{print $3"\\n"}')
            fi

            if [ -z "$result" ]; then
                echo "$me: No results for '$2'"
                exit
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
