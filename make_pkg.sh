#!/usr/bin/env bash

NAME='superlu'
VERSION=4.3
BUILT_PRODUCTS_DIR='./Products'
PACKAGE_DIR="."
TEMP_DIR="Mechatronix_pkg"
PLATFORM=`uname`

mkdir -p ${BUILT_PRODUCTS_DIR}/usr/lib
mkdir -p ${BUILT_PRODUCTS_DIR}/usr/include/superlu
cp lib/* ${BUILT_PRODUCTS_DIR}/usr/lib
cp SRC/*.h ${BUILT_PRODUCTS_DIR}/usr/include/superlu

function build_deb {
  ARCH=`dpkg --print-architecture`
  WORK_DIR="${PACKAGE_DIR}/${NAME}_${VERSION}_${ARCH}"
  echo
  echo "Building tarball package for version ${NAME}_${VERSION}_${ARCH}"
  
  echo "> Populating working dir ${WORK_DIR}"
  mkdir -p "${WORK_DIR}/DEBIAN"
  cat > "${WORK_DIR}/DEBIAN/control" <<EOF
Package: ${NAME}
Version: ${VERSION}
Section: misc
Priority: optional
Homepage: http://crd-legacy.lbl.gov/~xiaoye/SuperLU/
Architecture: ${ARCH}
Depends: libatlas-dev, libatlas-base-dev, libatlas3-base, libblas3, libblas-dev
Suggests: 
Maintainer: Paolo Bosetti <paolo.bosetti@unitn.it>
Description: SuperLU libraries, rel. ${VERSION}.
EOF
  (cd "${BUILT_PRODUCTS_DIR}/usr/lib"; ln -s "lib${NAME}_${VERSION}.a" "lib${NAME}.a")
  cp -r "${BUILT_PRODUCTS_DIR}/usr" "${WORK_DIR}"
  
  echo "> Removing hidden files"
  find . -name ".AppleDouble" -exec rm -rf {} \; &> /dev/null
  find . -name ".DS_Store" -exec rm {} \; &> /dev/null
  find . -name "._*" -exec rm {} \; &> /dev/null

  echo "> Fixing permissions"
  find . -regextype posix-extended -regex ".*\.(h|hh|hxx|tmpl)" \
    -exec chmod a-x {} \; &> /dev/null
  
  echo "> Creating tarball"
  tar czf "${WORK_DIR}.tgz" --exclude '.*' -C "${WORK_DIR}" "usr"
  
  echo "> Bundling .deb package"
  fakeroot dpkg-deb --build "${WORK_DIR}"
  
  echo "> Clean up"
  rm -rf "${WORK_DIR}"  
  
  echo
  echo "Done generating tarball ${WORK_DIR}.tgz"
  echo "  and package ${WORK_DIR}.deb"
  echo "> Install tarball with the command:"
  echo "  $ sudo tar xvf -C / ${WORK_DIR}.tgz"
  echo "> Install package with the command:"
  echo "  $ sudo dpkg -i ${WORK_DIR}.deb"
  echo
}

build_deb
