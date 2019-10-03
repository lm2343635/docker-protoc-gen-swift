FROM ubuntu:18.04 as swift_builder
RUN apt-get update && \
        apt-get install -y build-essential make tar xz-utils bzip2 gzip sed \
        libz-dev unzip patchelf curl libedit-dev python2.7 python2.7-dev libxml2 \
        git libxml2-dev uuid-dev libssl-dev bash patch
ENV SWIFT_VERSION=5.0.3 \
        LLVM_VERSION=9.0.0
RUN curl -L http://releases.llvm.org/${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04.tar.xz | tar --strip-components 1 -C /usr/local/ -xJv
RUN curl -L https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz | tar --strip-components 1 -C / -xz

RUN apt install -y wget vim

ENV PROTOBUF_VERSION=3.9.2
RUN cd /tmp && \
        wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && \
        unzip -d protoc protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && \
        cp /tmp/protoc/bin/protoc /usr/local/bin && \
        rm -rf *

ENV GRPC_SWIFT_VERSION=0.9.1
RUN cd /tmp && \
        wget https://github.com/grpc/grpc-swift/archive/${GRPC_SWIFT_VERSION}.zip && \
        unzip ${GRPC_SWIFT_VERSION}.zip && \
        cd grpc-swift-${GRPC_SWIFT_VERSION} && make plugin && \
        cp protoc-gen-swift* /usr/local/bin && \
        rm -rf /tmp/*
