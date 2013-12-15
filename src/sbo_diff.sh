#!/usr/bin/env bash

me=$(basename $0)

usage() {
cat << EOF
Usage:
$me

About:
$me checks if exists an update for a package installed
from SBo's SlackBuilds.

EOF
}

checkupdate() {
    pkg_nw=$(echo $1 | tr - ' ' | wc --words)
    pkg_build=$(echo $1 | tr - ' ' | awk '{print $'$pkg_nw'}')
    pkg_ba=$(expr $pkg_nw - 1)
    pkg_arch=$(echo $1 | tr - ' ' | awk '{print $'$pkg_ba'}')
    pkg_bv=$(expr $pkg_nw - 2)
    pkg_version=$(echo $1 | tr - ' ' | awk '{print $'$pkg_bv'}')
    pkg_prgnam=$(echo $1 | tr - ' ' | sed -n "s/$pkg_build$//p" | \
        sed -n "s/$pkg_arch $//p" | sed -n "s/$pkg_version $//p" | sed 's/ *$//' | tr ' ' -)
    result=$(sbo_find -e $pkg_prgnam)
    if [ $? -eq 0 ]; then
        update_version=false
        update_build=false
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
        if [ -z "$aux_version" ]; then
                update_version=true
        fi
        aux_build=$(echo $pkg_build | sed -n "/^$port_build/ p")
        if [ -z "$aux_build" ]; then
                update_build=true
        fi
        if [ "$update_version" == true ] || [ "$update_build" == true ]; then
            echo -e "$result  $pkg_version->$port_version  $pkg_build->$port_build"
        fi
    fi
}

if [ ! -z "$TAG" ]; then
    pkgsbytag=$(sbo_inst -n "*$TAG")
    if [ $? -ne 0 ]; then
        pkgsbytag=""
    fi
fi

pkgsbysbo=$(sbo_inst -n '*_SBo')
if [ $? -ne 0 ]; then
    pkgsbysbo=""
fi

if [ -n "$pkgsbytag" -o -n "$pkgsbysbo" ]; then
    for pkgs in $pkgsbytag $pkgsbysbo
    do
        checkupdate $pkgs
    done
fi
