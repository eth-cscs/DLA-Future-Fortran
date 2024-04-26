ARG BUILD_IMAGE
ARG DEPLOY_BASE_IMAGE

ARG BUILD=/DLAF-Fortran-build
ARG SOURCE=/DLAF-Fortran
ARG DEPLOY=/root/DLAF-Fortran.bundle

FROM $BUILD_IMAGE as builder

ARG BUILD
ARG SOURCE
ARG DEPLOY

# Build DLA-Fortran
COPY . ${SOURCE}

SHELL ["/bin/bash", "-c"]

ARG NUM_PROCS
# Note: we force spack to build in ${BUILD} creating a link to it
RUN spack repo rm --scope site dla-future-fortran-repo && \
    spack repo add ${SOURCE}/spack && \
    spack -e ci develop --no-clone --path ${SOURCE} --build-directory ${BUILD} dla-future-fortran@main build_type=Debug && \
    spack -e ci concretize -f && \
    spack -e ci --config "config:flags:keep_werror:all" install --jobs ${NUM_PROCS} --keep-stage --verbose

# Prune and bundle binaries
RUN mkdir ${BUILD}-tmp && cd ${BUILD} && \
    export TEST_BINARIES=`PATH=${SOURCE}/ci:$PATH ctest --show-only=json-v1 | jq '.tests | .[] | select(has("command")) | .command | .[-1]' | tr -d \"` && \
    echo "Binary sizes:" && \
    ls -lh ${TEST_BINARIES} && \
    ls -lh src/lib* && \
    libtree -d ${DEPLOY} ${TEST_BINARIES} && \
    rm -rf ${DEPLOY}/usr/bin && \
    libtree -d ${DEPLOY} $(which ctest addr2line) && \
    cp -L ${SOURCE}/ci/mpi-ctest ${DEPLOY}/usr/bin && \
    echo "$TEST_BINARIES" | xargs -I{file} find -samefile {file} -exec cp --parents '{}' ${BUILD}-tmp ';' && \
    find -name CTestTestfile.cmake -exec cp --parents '{}' ${BUILD}-tmp ';' && \
    rm -rf ${BUILD} && \
    mv ${BUILD}-tmp ${BUILD}

# Deploy MKL separately, since it dlopen's some libs
ARG USE_MKL
RUN if [ "$USE_MKL" = "ON" ]; then \
      export MKL_LIB=$(dirname $(find $(spack location -i intel-oneapi-mkl) -name libmkl_core.so)) && \
      libtree -d ${DEPLOY} \
      ${MKL_LIB}/libmkl_avx2.so.2 \
      ${MKL_LIB}/libmkl_avx512.so.2 \
      ${MKL_LIB}/libmkl_core.so \
      ${MKL_LIB}/libmkl_def.so.2 \
      ${MKL_LIB}/libmkl_intel_thread.so \
      ${MKL_LIB}/libmkl_mc3.so.2 \
      ${MKL_LIB}/libmkl_sequential.so \
      ${MKL_LIB}/libmkl_tbb_thread.so \
      ${MKL_LIB}/libmkl_vml_avx2.so.2 \
      ${MKL_LIB}/libmkl_vml_avx512.so.2 \
      ${MKL_LIB}/libmkl_vml_cmpt.so.2 \
      ${MKL_LIB}/libmkl_vml_def.so.2 \
      ${MKL_LIB}/libmkl_vml_mc3.so.2 ; \
    fi

FROM $DEPLOY_BASE_IMAGE

# Set JFrog autoclean policy
LABEL com.jfrog.artifactory.retention.maxDays="7"
LABEL com.jfrog.artifactory.retention.maxCount="10"

ENV DEBIAN_FRONTEND noninteractive

ARG BUILD
ARG DEPLOY

ARG EXTRA_APTGET_DEPLOY
# glibc-tools is needed for libSegFault on ubuntu:22.04
# tzdata is needed to print correct time
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends \
      ${EXTRA_APTGET_DEPLOY} \
      glibc-tools \
      tzdata && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder ${BUILD} ${BUILD}
COPY --from=builder ${DEPLOY} ${DEPLOY}

ENV PATH="${DEPLOY}/usr/bin:$PATH"

# Automatically print stacktraces on segfault
ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libSegFault.so

RUN echo "${DEPLOY}/usr/lib/" > /etc/ld.so.conf.d/dlaf.conf && ldconfig

WORKDIR ${BUILD}
