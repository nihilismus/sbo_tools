#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me package_directory

About:
It displays information about a package build script directory from
the local repository. It reads its info, SlackBuild and slack-desc
files to display a formated output.

Examples:

  Search SlackBuilds with 'libsigc' in its name and print
  information about them:

    $me \$(sbo_find libsigc++)

  To stress your system:

    $me \$(sbo_find '*')
EOF
}

getinfo() {
    packagename=`basename $1`
    packagedesc="$1/slack-desc"
    packageinfo="$1/$packagename.info"
    packageslk="$1/$packagename.SlackBuild"

    required_files="$packagedesc $packageinfo $packageslk"
    for file in $required_files
    do
        if [ ! -r "$file" ]; then
           fail+="$(basename $file),"
        fi
    done

    if [ ! -z "$fail" ]; then
        echo "${0##*/}: Error, cant find $fail inside $1"
    else
        # Get information from slack-desc file
        about=$(sed -n '/^'$packagename':/ s/^'$packagename': // p' $packagedesc | sed q | sed '/[ \t\v\f]\+/ !d')

        # Get information from info file
        source $packageinfo

        # Get information from SlackBuild file
        build=$(sed -n '/^BUILD=/ p' $packageslk | \
            head -1 | \
            sed -e 's/BUILD//g' -e 's/=//' -e 's/${:-// ' -e 's/} *$//' -e 's/"//g')

        # Print information we've got.
        echo "Package:  $PRGNAM"
        echo "  Location:  $1"
        echo "  About:  $about"
        echo "  Version:  $VERSION"
        echo "  Build:  $build"
        echo "  Homepage:  $HOMEPAGE"
        echo "  Source URL:  "$(echo $DOWNLOAD | xargs)
        echo "  Source MD5:  "$(echo $MD5SUM | xargs)
        echo "  Maintainer:  $MAINTAINER"
        echo "  Maintainer Email:  $EMAIL"
        echo "  Approved by SBo Admin(s):  $APPROVED"
    fi
}

set -e
set -f

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
        getinfo $(pwd)
        exit
        ;;
    1)
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit
        fi
        if [ -d "$1" ]; then
            cd "$1"
            getinfo $(pwd)
        else
            echo "$me: Error, $1 is not a directory"
        fi
        exit
        ;;
    *)
        cwd=$(pwd)
        for string in $@
        do
            if [ -d "$string" ]; then
                cd "$string"
                getinfo $(pwd)
                cd "$cwd"
            else
                echo "$me: Error, $string is not a directory"
            fi
        done
        exit
        ;;
esac
