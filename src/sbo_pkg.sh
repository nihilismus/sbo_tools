#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me [directory]

About:
$me creates an Slackware package using an SlackBuild script from
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
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
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

touch $directory/.writable >/dev/null 2>&1 || true
if [ ! -f $directory/.writable ]; then
    echo "$me: Error, no write permissions in $directory"
    exit 1
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

echo "$me: Executing $info_file"
source $info_file

md5sums=($(echo $MD5SUM))
num_md5sums=$(echo $MD5SUM | wc -w)
downloads=$DOWNLOAD

ARCH=${ARCH:-$(uname -m)}
if [ "$ARCH" = "x86_64" ] && [ ! -z "$DOWNLOAD_x86_64" ] && [ ! -z "$MD5SUM_x86_64" ]; then
    md5sums=($(echo $MD5SUM_x86_64))
    num_md5sums=$(echo $MD5SUM_x86_64 | wc -w)
    downloads=$DOWNLOAD_x86_64
fi

if [ -z "$md5sums" ]; then
    echo "$me: Error, no md5 message digest in $info_file"
    exit 1
fi

if [ ! -f "$slackbuild_file" ]; then
    echo "$me: Error $slackbuild_file does not exist."
    exit 1
fi

echo "$me: Downloading $downloads"

wget \
    --progress=bar \
    --no-check-certificate \
    --timeout=60 \
    --no-clobber \
    --continue \
    $downloads 2>&1 | tee $package.log

downloaded_files=( "$(grep -e 'saved' -e 'already there' $package.log | \
    sed -e 's/^.* - //g' -e 's/ saved .*//g' \
    -e 's/^File //g' -e 's/ already there.*//g' \
    -e 's/'\''//g' -e 's/'\`'//g' -e 's/'\‘'//g' -e 's/'\’'//g' -e 's/'\“'//g' -e 's/'\”'//g')" )

echo "$me: Checking MD5 message digest"

index=0
while [[ $index -lt $num_md5sums ]]; do
    error=0;
    echo ${md5sums[$index]}  ${downloaded_files[$index]} | md5sum -c - || error=1
    if [ $error != 0 ]; then
        echo "$me: Error, md5 does not match for ${downloaded_files[$index]}"
        exit 1
    fi
    index=$index+1
done

echo "$me: Executing $package.SlackBuild"
sh $package.SlackBuild || exit 1
rm -f $package.log

echo "$me: done"
