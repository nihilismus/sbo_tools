#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me [directory]

About:
$me creates a Slackware package using a SlackBuild script from
http://www.slackbuilds.org.

directory is the SlackBuild script's directory and should cointain all
necesary files to build the package.

If directory is not specified, $me will use the current working
directory as the SlackBuild script's directory.
EOF
}

set -e

case $# in
    0)
        directory=$(pwd)
        ;;
    1)
        if [ $1 = "--help" ]; then
            usage
            exit
        fi
        directory=$1
        ;;
    *)
        usage
        exit 1
        ;;
esac

if [ ! -d $directory/ ]; then
    echo "$me: Error, $directory is not a directory"
    exit 1
fi

touch $directory/.writable 2>&1
if [ $? -ne 0 ]; then
    echo "$me: Error, you do not have write permission in $directory"
fi
rm -f $directory/.writable

echo "$me: Changing working directory $directory"
cd $directory

package=$(basename $directory)
info_file=$(pwd)/$package.info
slackbuild_file=$(pwd)/$package.SlackBuild

if [ ! -f $info_file ]; then
    echo "$me: Error $info_file does not exist."
    exit 1
fi

if [ ! -f $slackbuild_file ]; then
    echo "$me: Error $slackbuild_file does not exist."
    exit 1
fi

echo "$me: Executing $info_file"
source $info_file

echo "$me: Downloading $DOWNLOAD"

wget \
    --progress=bar \
    --no-check-certificate \
    --timeout=60 \
    --no-clobber \
    --continue \
    --no-use-server-timestamps \
    $DOWNLOAD

# The newest file *must be* the source code from $DOWNLOAD
download_file=$(ls -1t | head -1)
md5sum_file=$(md5sum $download_file | awk '{print $1}')

if [ $md5sum_file != $MD5SUM ]; then
    echo "$me: Error, MD5 message digest does not match for $download_file"
    echo "  MD5 expected: $MD5SUM"
    echo "  MD5 obtained: $md5sum_file"
    exit 1
fi

echo "$me: Executing $package.SlackBuild"
sh $package.SlackBuild || exit 1

echo "$me: done"
