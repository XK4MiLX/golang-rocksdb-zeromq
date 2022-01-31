FROM debian:9

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git wget pkg-config lxc-dev libzmq3-dev \
    libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libtool \
    liblz4-dev graphviz && \
    apt-get clean


WORKDIR /home

# Install Go

RUN wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz && tar xf go1.17.1.linux-amd64.tar.gz && \
    mv go /opt/go && \
    ln -s /opt/go/bin/go /usr/bin/go

ENV GOPATH=/home/go
ENV PATH=$PATH:$GOPATH/bin

WORKDIR /home
# Install RocksDB
RUN git clone https://github.com/facebook/rocksdb.git && \
    cd rocksdb && \ 
    git checkout v6.22.1 && \
    CFLAGS=-fPIC CXXFLAGS=-fPIC make release 

ENV CGO_CFLAGS="-I/home/rocksdb/include"
ENV CGO_LDFLAGS="-L/home/rocksdb -lrocksdb -lstdc++ -lm -lz -ldl -lbz2 -lsnappy -llz4"

WORKDIR /home
# Install ZeroMQ
RUN apt-get install -y autoconf automake
RUN git clone https://github.com/zeromq/libzmq && \
    cd libzmq && \
    git checkout v4.3.4 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install
