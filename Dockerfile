ARG LLVM_VERSION=800
ARG ARCH=amd64
ARG LIBRARIES=/opt/trailofbits/libraries
ARG DISTRO_BASE=ubuntu18.04

#FROM trailofbits/remill/llvm${LLVM_VERSION}-${DISTRO_BASE}-${arch}:latest as base
FROM trailofbits/remill:llvm${LLVM_VERSION}-${DISTRO_BASE}-${ARCH} as base
ARG LIBRARIES

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -qqy ninja-build python2.7 wget zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# needed for 20.04 support until we migrate to py3
RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py && python2.7 get-pip.py

# Build in the remill build directory
RUN mkdir -p /remill/tools/anvill
WORKDIR /remill/tools/anvill

COPY . ./

#TODO(artem): find a way to use remill commit id; for now just use latest build of remill
# RUN cd /remill && git checkout -b temp $(</remill/tools/anvill/.remil_commit_id) && cd /remill/tools/anvill

ENV PATH="${LIBRARIES}/llvm/bin:${LIBRARIES}/cmake/bin:${LIBRARIES}/protobuf/bin:${PATH}"
ENV CC="${LIBRARIES}/llvm/bin/clang"
ENV CXX="${LIBRARIES}/llvm/bin/clang++"
ENV TRAILOFBITS_LIBRARIES="${LIBRARIES}"

RUN cd /remill/build && \
    cmake -G Ninja .. && cmake --build . --target install && \
    cd .. && rm -rf build

