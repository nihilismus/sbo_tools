#!/usr/bin/env bash

set -e

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me

About:
$me checks for the existance of differences in version and build between packages
installed and the SlackBuilds at the local repository.
EOF
}

check_update() {
    pkg_nw=$(echo $1 | tr - ' ' | wc --words)
    pkg_build=$(echo $1 | tr - ' ' | awk '{print $'$pkg_nw'}')
    pkg_ba=$(expr $pkg_nw - 1)
    pkg_arch=$(echo $1 | tr - ' ' | awk '{print $'$pkg_ba'}')
    pkg_bv=$(expr $pkg_nw - 2)
    pkg_version=$(echo $1 | tr - ' ' | awk '{print $'$pkg_bv'}')

    pkg_prgnam=$(echo $1 | tr - ' ' | sed -n "s/$pkg_build$//p" | \
        sed -n "s/$pkg_arch $//p" | sed -n "s/$pkg_version $//p" | sed 's/ *$//' | tr ' ' -)

    result=$(sbo_find -e $pkg_prgnam)

    if ! echo "$result" | grep -i 'no results' 1>/dev/null; then
        source $result/$pkg_prgnam.info ||  true
        port_version=$VERSION
        rawbuild=$(sed -n '/^BUILD=/p' $result/$pkg_prgnam.SlackBuild)
        build=$(echo $rawbuild | sed -e 's/BUILD//g' -e 's/=//g' -e 's/\$//g' \
                -e 's/{//g' -e 's/://g' -e 's/-//g' -e 's/}//g')
        if [ ! -z "$build" ]; then
            port_build=$build
        else
            port_build=x
        fi
        pkg_build=$(echo $pkg_build | sed -n 's/\(^.\).*/\1/p')
        aux_version=$(echo $pkg_version | sed -n "/^$port_version/ p")

        update_version=false
        if [ -z "$aux_version" ]; then
                update_version=true
        fi

        update_build=false
        aux_build=$(echo $pkg_build | sed -n "/^$port_build/ p")
        if [ -z "$aux_build" ]; then
                update_build=true
        fi

        if $update_version || $update_build ; then
            echo -e "$result  $pkg_version->$port_version  $pkg_build->$port_build"
        fi
    fi
}

packages=""
if ! sbo_inst -n '*_SBo' | grep -i 'no results' 1>/dev/null; then
    packages=$(sbo_inst -n '*_SBo')
fi

if [ -n "$TAG" ] && ! sbo_inst -n "*$TAG" | grep -i 'no results' 1>/dev/null; then
    packages="$packages $(sbo_inst -n "*$TAG")"
fi

for package in $packages; do
    check_update $package
done