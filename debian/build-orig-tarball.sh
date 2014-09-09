#!/bin/bash
set -e

CWD=$(dirname $0 | xargs readlink -f)
PKG=$(dpkg-parsechangelog -l${CWD}/changelog | grep ^Source | sed 's/Source: //')
TIMESTAMP=$(TZ="UTC" date +%Y%m%d%H%M%S)
TEMPDIR=$(mktemp -d)

function cleanup {
  echo "Removing ${TEMPDIR}"
  rm -rf "${TEMPDIR}"
}
trap cleanup EXIT

# generate original source tarball
echo "# Building orig tarball in ${TEMPDIR}"
git clone https://github.com/libressl-portable/portable ${TEMPDIR}/${PKG}
cd ${TEMPDIR}/${PKG} && ./dist.sh

# repacking with correct version number
VERSION=$(cat ${TEMPDIR}/${PKG}/VERSION)
OPENBSD_COMMIT=$(cd ${TEMPDIR}/${PKG}/openbsd && git log -1 --format=%h)
PORTABLE_COMMIT=$(cd ${TEMPDIR}/${PKG} && git log -1 --format=%h)
TARVERSION=${VERSION}~git${TIMESTAMP}+${OPENBSD_COMMIT}+${PORTABLE_COMMIT}

echo "# Repacking version ${TARVERSION}"
DESTFILENAME=$(readlink -f "${CWD}/../${PKG}_${TARVERSION}.orig.tar.xz")
mkdir -p "${PKG}-${TARVERSION}"
tar -x -z --directory "${PKG}-${TARVERSION}" --strip-components=1 -f ${TEMPDIR}/${PKG}/${PKG}-${VERSION}.tar.gz
DIR=$(readlink -f "${PKG}-${TARVERSION}")
cd ${TEMPDIR}/${PKG}/openbsd && git log --pretty="format:%ad  %aN%n%n%x09* %s%n%n%w(72,8,8)%b%n" > "${DIR}/ChangeLog-openbsd"
cd ${TEMPDIR}/${PKG} && git log --pretty="format:%ad  %aN%n%n%x09* %s%n%n%w(72,8,8)%b%n" > "${DIR}/ChangeLog-portable"
cp "${TEMPDIR}/${PKG}/VERSION" "${PKG}-${TARVERSION}"
cp "${TEMPDIR}/${PKG}/OPENBSD_BRANCH" "${PKG}-${TARVERSION}"
find -L "${PKG}-${TARVERSION}" -xdev -type f -print | sort \
    | XZ_OPT="-6v" tar -caf "${DESTFILENAME}" -T- --owner=root --group=root --mode=a+rX
rm -rf "${PKG}-${TARVERSION}"
echo "New tarball saved as ${DESTFILENAME}"
