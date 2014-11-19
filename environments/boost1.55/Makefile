VERSION := 1.55.0
SRC := boost_$(subst .,_,${VERSION})
PKG := ${SRC}.tar.gz
RESULT := ${BUILDENV_PATH_boost1_55}/include/boost/version.hpp

all:

${RESULT}: install
	ls ${SRC}/b2
	ls ${RESULT}

install: build
	cd ${SRC} && \
	./b2 install

build: ${SRC}/b2
	cd ${SRC} && \
	./b2 stage

${SRC}/b2: ${SRC}/bootstrap.sh
	cd ${SRC} && \
	./bootstrap.sh --prefix=${BUILDENV_PATH_boost1_55}

${SRC}/bootstrap.sh: ${PKG}
	tar xfv ${PKG}

${PKG}:
	wget http://sourceforge.net/projects/boost/files/boost/${VERSION}/${PKG}/download -O $@
