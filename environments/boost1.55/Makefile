all: build

install: build
	cd boost_1_55_0 && \
	./b2 install

build: boost_1_55/b2
	cd boost_1_55_0 && \
	./b2 stage

boost_1_55/b2: boost_1_55/bootstrap.sh
	cd boost_1_55_0 && \
	./bootstrap.sh --prefix=${BUILDENV_PATH}

boost_1_55/bootstrap.sh: boost-1.55.tar.gz
	tar xfv boost-1.55.tar.gz

boost-1.55.tar.gz:
	wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download -O $@
