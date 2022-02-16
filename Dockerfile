FROM debian:9

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git wget pkg-config lxc-dev libzmq3-dev \
    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libtool \
    liblz4-dev graphviz && \
    apt-get clean


WORKDIR /home

# Install Go

ENV GOLANG_VERSION=go1.17.1.linux-amd64
ENV ROCKSDB_VERSION=v6.22.1
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin
ENV CGO_CFLAGS="-I/opt/rocksdb/include"
ENV CGO_LDFLAGS="-L/opt/rocksdb -ldl -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4"

# install and configure go
RUN cd /opt && wget https://dl.google.com/go/$GOLANG_VERSION.tar.gz && \
    tar xf $GOLANG_VERSION.tar.gz
RUN ln -s /opt/go/bin/go /usr/bin/go
RUN mkdir -p $GOPATH
RUN echo -n "GO version: " && go version
RUN echo -n "GOPATH: " && echo $GOPATH

WORKDIR /home
# install rocksdb
RUN cd /opt && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git
RUN cd /opt/rocksdb && CFLAGS=-fPIC CXXFLAGS=-fPIC make -j 4 release
RUN strip /opt/rocksdb/ldb /opt/rocksdb/sst_dump && \
    cp /opt/rocksdb/ldb /opt/rocksdb/sst_dump /build


WORKDIR /home
# Install ZeroMQ
RUN apt-get install -y autoconf automake
RUN git clone https://github.com/zeromq/libzmq && \
    cd libzmq && \
    git checkout v4.2.1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install
