ARG DEPS_IMAGE
FROM $DEPS_IMAGE

# Set JFrog autoclean policy
LABEL com.jfrog.artifactory.retention.maxDays="7"
LABEL com.jfrog.artifactory.retention.maxCount="10"

ARG BUILD=/DLAF-Fortran-build
ARG SOURCE=/DLAF-Fortran
ARG BIN=${BUILD}/bin/

# Build DLA-Fortran
COPY . ${SOURCE}

SHELL ["/bin/bash", "-c"]

ARG NUM_PROCS
# Note: we force spack to build in ${BUILD} creating a link to it
RUN spack repo rm --scope site dla-future-fortran-repo && \
    spack repo add ${SOURCE}/spack && \
    spack -e ci develop --no-clone --path ${SOURCE} --build-directory ${BUILD} dla-future-fortran@main build_type=Debug && \
    spack -e ci concretize -f && \
    spack -e ci --config "config:flags:keep_werror:all" install --jobs ${NUM_PROCS} --keep-stage --verbose && \
    find ${BUILD} -name CMakeFiles -exec rm -rf {} +

RUN mkdir -p ${BIN} && cp -L ${SOURCE}/ci/mpi-ctest ${BIN}
ENV PATH="${BIN}:$PATH"

# Automatically print stacktraces on segfault
ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libSegFault.so

WORKDIR ${BUILD}
