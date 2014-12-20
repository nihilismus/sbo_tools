#!/usr/bin/env bash

set -e
set -f

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me directory

About:
$me displays information about a package build script directory.
It reads its info, SlackBuild and slack-desc files to display
a formated output. If a list of directories are passed as parameters
then displays information for earch one.
EOF
}

get_info() {
    packagename=`basename $1`
    packagedesc="$1/slack-desc"
    packageinfo="$1/$packagename.info"
    packageslk="$1/$packagename.SlackBuild"

    required_files="$packagedesc $packageinfo $packageslk"
    fail=""
    for file in $required_files
    do
        if [ ! -r "$file" ]; then
           fail+="$(basename $file),"
        fi
    done
    fail=$(echo $fail | sed 's/,$//')

    if [ ! -z "$fail" ]; then
        echo "${0##*/}: Error, cant find $fail inside $1"
        exit 1
    fi

    # Get information from slack-desc file
    about=$(sed -n '/^'$packagename':/ s/^'$packagename': // p' $packagedesc | sed q | sed '/[ \t\v\f]\+/ !d')

    # Get information from info file
    source $packageinfo

    # Get information from SlackBuild file
    build=$(sed -n '/^BUILD=/ p' $packageslk | \
        head -1 | \
        sed -e 's/BUILD//g' -e 's/=//' -e 's/${:-// ' -e 's/} *$//' -e 's/"//g')

    case $2 in
        "version")
            echo $VERSION
            ;;
        "build")
            echo $build
            ;;
         *)
            md5sums=$MD5SUM
            num_md5sums=$(echo $MD5SUM | wc -w)
            downloads=$DOWNLOAD
            ARCH=${ARCH:-$(uname -m)}
            if [ "$ARCH" = "x86_64" ] && [ ! -z "$DOWNLOAD_x86_64" ] && [ ! -z "$MD5SUM_x86_64" ]; then
                md5sums=$MD5SUM_x86_64
                num_md5sums=$(echo $MD5SUM_x86_64 | wc -w)
                downloads=$DOWNLOAD_x86_64
            fi
            if [ $num_md5sums -gt 1 ]; then
                md5sums=$(echo $md5sums | sed 's/\s/\\n    /g' | sed 's/^/\\n    /')
                downloads=$(echo $downloads | sed 's/\s/\\n    /g' | sed 's/^/\\n    /')
            fi
            # Print information we've got.
            echo "Package:  $PRGNAM"
            echo "  Location:  $1"
            echo "  About:  $about"
            echo "  Version:  $VERSION"
            echo "  Build:  $build"
            echo "  Homepage:  $HOMEPAGE"
            echo "  Maintainer:  $MAINTAINER"
            echo "  Maintainer Email:  $EMAIL"
            if [ ! -z "$APPROVED" ]; then
                    echo "  Approved by SBo Admin(s):  $APPROVED"
            fi
            num_requires=$(echo "$REQUIRES" | sed 's/%README.*%//' | wc -w)
            if [ $num_requires -gt 0 ]; then
                REQUIRES=$(echo $REQUIRES | sed 's/%README.*%//')
                echo -n "  Requires:  "
                if [ $num_requires -gt 1 ]; then
                    echo
                    for require in $(echo $REQUIRES | sed 's/%README.*%//'); do
                        echo "    "$(sbo_find -e $require)
                    done
                else
                    echo $(sbo_find -e $(echo $REQUIRES | sed 's/%README.*%//'))
                fi
            fi
            echo -e "  Source(s) URL:  $downloads"
            echo -e "  Source(s) MD5:  $md5sums"
        ;;
    esac
}

directories=$(find /usr/ports/ -type d -mindepth 1 -maxdepth 1  -exec basename {} \; 2>/dev/null)
if [ -z "$directories" ]; then
    echo "$me: Error, /usr/ports seems to be empty"
    exit 1
fi

case $# in
    0)
        get_info $(pwd)
        ;;
    1)
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit
        fi

        if [ -d "$1" ]; then
            cd "$1"
            get_info $(pwd)
        else
            echo "$me: Error, '$1' is not a directory"
            exit 1
        fi
        ;;
    2)
        case $1 in
            "-v")
                get_info $2 version
            ;;
            "-b")
                get_info $2 build
            ;;
            *)
                usage
                exit 1
            ;;
        esac
        ;;
    *)
        usage
        exit
        ;;
esac
