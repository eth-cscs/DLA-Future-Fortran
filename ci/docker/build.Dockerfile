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

# Install Spack
ARG SPACK_REPO=https://github.com/spack/spack
ARG SPACK_COMMIT
ENV SPACK_ROOT=/opt/spack-$SPACK_COMMIT
ARG SPACK_PACKAGES_REPO=https://github.com/spack/spack-packages
ARG SPACK_PACKAGES_COMMIT
ENV SPACK_PACKAGES_ROOT=/opt/spack-packages-$SPACK_PACKAGES_COMMIT
RUN mkdir -p $SPACK_ROOT \
    && curl -OL $SPACK_REPO/archive/$SPACK_COMMIT.tar.gz \
    && tar -xzvf $SPACK_COMMIT.tar.gz -C /opt && rm -f $SPACK_COMMIT.tar.gz \
    && mkdir -p $SPACK_PACKAGES_ROOT \
    && curl -OL $SPACK_PACKAGES_REPO/archive/$SPACK_PACKAGES_COMMIT.tar.gz \
    && tar -xzvf $SPACK_PACKAGES_COMMIT.tar.gz -C /opt && rm -f $SPACK_PACKAGES_COMMIT.tar.gz

ENV PATH $SPACK_ROOT/bin:/root/.local/bin:$PATH

RUN spack repo add $SPACK_PACKAGES_ROOT/repos/spack_repo/builtin

# Find compilers and define which compiler we want to use
ARG COMPILER
RUN spack external find gcc && \
    spack config add "packages:cxx:require:'${COMPILER}'" && \
    spack config add "packages:c:require:'${COMPILER}'" && \
    spack config add "packages:fortran:require:gcc"

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
RUN spack mirror add ${SPACK_BUILDCACHE} https://binaries.spack.io/${SPACK_BUILDCACHE}
RUN spack mirror add develop https://binaries.spack.io/develop && \
    spack buildcache keys --install --trust --force && \
    spack mirror rm develop

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
RUN spack -e ci concretize
RUN spack -e ci spec -lI --cover edges

# Install dependencies
ARG NUM_PROCS
RUN spack -e ci install --jobs ${NUM_PROCS} --fail-fast --only=dependencies

# Make CTest executable available
RUN ln -s `spack -e ci location -i cmake`/bin/ctest /usr/bin/ctest
