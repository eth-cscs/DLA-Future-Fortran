ARG BASE_IMAGE=ubuntu:24.04
FROM $BASE_IMAGE

# Set JFrog autoclean policy
LABEL com.jfrog.artifactory.retention.maxDays="21"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="$PATH:/opt/spack/bin" \
    SPACK_COLOR=always
ENTRYPOINT []

CMD [ "/bin/bash" ]
SHELL ["/bin/bash", "-c"]

ARG EXTRA_APTGET
RUN apt-get -yqq update && \
    apt-get -yqq install --no-install-recommends \
    software-properties-common \
    build-essential gfortran \
    autoconf automake libssl-dev ninja-build pkg-config \
    gawk git tar \
    wget curl ca-certificates gpg-agent tzdata \
    python3 python3-setuptools \
    glibc-tools jq strace \
    patchelf unzip file gnupg2 libncurses-dev \
    ${EXTRA_APTGET} && \
    rm -rf /var/lib/apt/lists/*

# Install Spack
ARG SPACK_REPO=https://github.com/spack/spack
ARG SPACK_COMMIT
ENV SPACK_ROOT=/opt/spack-$SPACK_COMMIT
ARG SPACK_PACKAGES_REPO=https://github.com/spack/spack-packages
ARG SPACK_PACKAGES_COMMIT
ENV SPACK_PACKAGES_ROOT=/opt/spack-packages-$SPACK_PACKAGES_COMMIT
RUN mkdir -p $SPACK_ROOT && \
    curl -Ls "https://api.github.com/repos/spack/spack/tarball/$SPACK_COMMIT" | tar --strip-components=1 -xz -C ${SPACK_ROOT} && \
    mkdir -p $SPACK_PACKAGES_ROOT && \
    curl -Ls "https://api.github.com/repos/spack/spack-packages/tarball/$SPACK_PACKAGES_COMMIT" | tar --strip-components=1 -xz -C ${SPACK_PACKAGES_ROOT}

ENV PATH $SPACK_ROOT/bin:/root/.local/bin:$PATH

RUN spack repo add --scope site $SPACK_PACKAGES_ROOT/repos/spack_repo/builtin

# FIXME: Workaround until CE provides full MPI replacement
ARG ALPS_CLUSTER_CONFIG_COMMIT
ENV ALPS_CLUSTER_CONFIG_COMMIT=$ALPS_CLUSTER_CONFIG_COMMIT
RUN mkdir -p /opt/alps-cluster-config && \
    curl -Ls "https://api.github.com/repos/eth-cscs/alps-cluster-config/tarball/$ALPS_CLUSTER_CONFIG_COMMIT" | \
    tar --strip-components=1 -xz -C /opt/alps-cluster-config && \
    spack repo add --scope site /opt/alps-cluster-config/site/spack_repo/alps

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

# Add custom Spack repo
ARG SPACK_DLAF_FORTRAN_REPO
COPY $SPACK_DLAF_FORTRAN_REPO /user_repo
RUN spack repo add --scope site /user_repo

ARG SPACK_ENVIRONMENT
ARG COMMON_SPACK_ENVIRONMENT
ARG ENV_VIEW=/view

# Create Spack environment named `ci`
COPY $SPACK_ENVIRONMENT /spack_environment/spack.yaml
COPY $COMMON_SPACK_ENVIRONMENT /spack_environment/
RUN spack env create --with-view ${ENV_VIEW} ci /spack_environment/spack.yaml
RUN spack -e ci concretize
RUN spack -e ci spec -lI --cover edges

# Install dependencies
ARG NUM_PROCS
RUN spack -e ci install --jobs ${NUM_PROCS} --fail-fast --only=dependencies

# Make CTest executable available
RUN ln -s `spack -e ci location -i cmake`/bin/ctest /usr/bin/ctest

RUN echo ${ENV_VIEW}/lib/ > /etc/ld.so.conf.d/dlaff.conf && ldconfig
