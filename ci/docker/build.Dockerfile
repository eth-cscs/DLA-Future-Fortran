ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

# Set JFrog autoclean policy
LABEL com.jfrog.artifactory.retention.maxDays="21"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="$PATH:/opt/spack/bin:/opt/libtree" \
    SPACK_COLOR=always
SHELL ["/bin/bash", "-c"]

ARG EXTRA_APTGET
RUN apt-get -yqq update && \
    apt-get -yqq install --no-install-recommends \
    software-properties-common \
    build-essential gfortran \
    autoconf automake libssl-dev ninja-build pkg-config \
    ${EXTRA_APTGET} \
    gawk \
    python3 python3-distutils \
    git tar wget curl ca-certificates gpg-agent jq tzdata \
    patchelf unzip file gnupg2 libncurses-dev && \
    rm -rf /var/lib/apt/lists/*

# Install libtree for packaging
RUN mkdir -p /opt/libtree && \
    curl -Lfso /opt/libtree/libtree https://github.com/haampie/libtree/releases/download/v2.0.0/libtree_x86_64 && \
    chmod +x /opt/libtree/libtree

# This is the spack version we want to have
ARG SPACK_SHA
ENV SPACK_SHA=$SPACK_SHA

# Install Spack
RUN mkdir -p /opt/spack && \
    curl -Ls "https://api.github.com/repos/spack/spack/tarball/$SPACK_SHA" | tar --strip-components=1 -xz -C /opt/spack

# Find compilers and efine which compiler we want to use
ARG COMPILER
RUN spack compiler find && \
    spack config add "packages:all:require:[\"%${COMPILER}\"]"

RUN spack external find \
    autoconf \
    automake \
    bzip2 \
    cuda \
    diffutils \
    findutils \
    git \
    ninja \
    m4 \
    ncurses \
    openssl \
    perl \
    pkg-config \
    xz

# Enable Spack build cache
ARG SPACK_BUILDCACHE
#RUN spack mirror add ${SPACK_BUILDCACHE} https://binaries.spack.io/${SPACK_BUILDCACHE}
#RUN spack buildcache keys --install --trust

# Add custom Spack repo
ARG SPACK_DLAF_FORTRAN_REPO
COPY $SPACK_DLAF_FORTRAN_REPO /user_repo
RUN spack repo add --scope site /user_repo

ARG SPACK_ENVIRONMENT
ARG COMMON_SPACK_ENVIRONMENT

# Create Spack environment named `ci`
COPY $SPACK_ENVIRONMENT /spack_environment/spack.yaml
COPY $COMMON_SPACK_ENVIRONMENT /spack_environment/
RUN spack env create --without-view ci /spack_environment/spack.yaml

# Install dependencies
ARG NUM_PROCS
RUN spack -e ci install --jobs ${NUM_PROCS} --fail-fast --only=dependencies

# Make CTest executable available
RUN ln -s `spack -e ci location -i cmake`/bin/ctest /usr/bin/ctest
