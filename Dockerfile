FROM ubuntu:18.04 as swift_builder
RUN apt-get update && \
        apt-get install -y build-essential make tar xz-utils bzip2 gzip sed \
        libz-dev unzip patchelf curl libedit-dev python2.7 python2.7-dev libxml2 \
        git libxml2-dev uuid-dev libssl-dev bash patch
ENV SWIFT_VERSION=5.0.3 \
        LLVM_VERSION=9.0.0
RUN curl -L http://releases.llvm.org/${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04.tar.xz | tar --strip-components 1 -C /usr/local/ -xJv
RUN curl -L https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1604/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz | tar --strip-components 1 -C / -xz

ENV SWIFT_PROTOBUF_VERSION$=1.7.0
RUN mkdir -p /swift-protobuf && \
        curl -L https://github.com/apple/swift-protobuf/archive/${SWIFT_PROTOBUF_VERSION}.tar.gz | tar --strip-components 1 -C /swift-protobuf -xz
RUN apt-get install -y libcurl4-openssl-dev
RUN cd /swift-protobuf && \
        swift build -c release
RUN mkdir -p /protoc-gen-swift && \
        cp /swift-protobuf/.build/x86_64-unknown-linux/release/protoc-gen-swift /protoc-gen-swift/
RUN cp /lib64/ld-linux-x86-64.so.2 \
        $(ldd /protoc-gen-swift/protoc-gen-swift | awk '{print $3}' | grep /lib | sort | uniq) \
        /protoc-gen-swift/
RUN find /protoc-gen-swift/ -name 'lib*.so*' -exec patchelf --set-rpath /protoc-gen-swift {} \; && \
        for p in protoc-gen-swift; do \
        patchelf --set-interpreter /protoc-gen-swift/ld-linux-x86-64.so.2 /protoc-gen-swift/${p}; \
        done
