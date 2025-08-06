FROM ubuntu24.04

COPY lib64 /usr/lib
COPY packages.yaml /root/.spack/packages.yaml
COPY alps-cluster-config/site /root/site
