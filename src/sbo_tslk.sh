#!/usr/bin/env bash

set -e
set -f

me=$(basename $0)

usage() {
cat << EOF
Usage: $me PRGNAM [TYPE]

About:
$me creates a set of files based in the content of http://slackbuilds.org/templates/

The first option, PRGNAM, is the name of the package while the second is the type of
template: cmake, perl, python or rubygem, by default is autotools.

EOF
}

prgnam=$1
if [ -z "${prgnam}" ]; then
  usage
  exit 1
fi

type=$2
if [ -z "${type}" ]; then
  type=autotools
fi

mkdir -p ${prgnam}
cd ${prgnam}

for file in README ${prgnam}.SlackBuild ${prgnam}.info doinst.sh slack-desc; do
  if [ -f "$file" ]; then
    echo "Error: $file already exists!"
    exit 1
  fi
done

source="http://slackbuilds.org/templates"
template="${type}-template.SlackBuild"

# README
echo "$me: Creating README ..."
wget --quiet "$source/README" -O - > \
  README

# prgnam.SlackBuild
echo "$me: Creating ${prgnam}.SlackBuild for ${type} ..."
wget --quiet "$source/$template" -O - | \
  sed '/^# |.*#$/,/^# |.* #$/d' | \
  sed 's/\t#.*$//' | \
  sed 's/[ \t]*$//' > ${prgnam}.SlackBuild
if [ -n "$SBO_MAINTAINER_COPYRIGHT" ]; then
  sed -i "s/\(# Copyright \).*$/\1$(date +%Y) ${SBO_MAINTAINER_COPYRIGHT}/" \
    ${prgnam}.SlackBuild
fi

# prgnam.info
echo "$me: Creating ${prgnam}.info ..."
wget --quiet "$source/template.info" -O - > \
  ${prgnam}.info
sed -i \
  's/=.*$/=""/' \
  ${prgnam}.info
sed -i \
  "s/^PRGNAM=.*/PRGNAM=\"${prgnam}\"/" \
  ${prgnam}.info
if [ -n "$SBO_MAINTAINER_NAME" ]; then
  sed -i \
    "s/^MAINTAINER=.*/MAINTAINER=\"${SBO_MAINTAINER_NAME}\"/" \
    ${prgnam}.info
fi
if [ -n "$SBO_MAINTAINER_EMAIL" ]; then
  sed -i \
    "s/^EMAIL=.*/EMAIL=\"${SBO_MAINTAINER_EMAIL}\"/" \
    ${prgnam}.info
fi

# doinst.sh
echo "$me: Creating doinst.sh ..."
wget --quiet "$source/doinst.sh" -O - > \
  doinst.sh

# slack-desc
echo "$me: Creating slack-desc ..."
wget --quiet "$source/slack-desc" -O - > \
  slack-desc

sed -i \
  "s/<\{,1\}appname>\{,1\}/${prgnam}/g" \
  ${prgnam}.SlackBuild \
  ${prgnam}.info \
  slack-desc

echo "$me: done"
