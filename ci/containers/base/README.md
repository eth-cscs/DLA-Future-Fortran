# Base imgaes for Cray-MPICH

## Eiger

Preparation steps:

```bash
mkdir lib64
cp -a /usr/lib64/libxpmem.* lib64/

git clone https://github.com/eth-cscs/alps-cluster-config.git

cp alps-cluster-config/daint/packages.yaml packages.yaml
```

Modify `packages.yaml`:

```diff
    xpmem:
      buildable: false
      externals:
      - spec: xpmem@2.9.6
        prefix: /usr
    libfabric:
-     buildable: false
-     externals:
-     - spec: libfabric@1.15.2.0
-       prefix: /opt/cray/libfabric/1.15.2.0/
+     require: "@1.15.2.0"
    slurm:
      buildable: false
      externals:
      - spec: slurm@23-11-7
        prefix: /usr
```

> [!note]
> The container engine (CE) will replace `libfabric` with the system one when running the container. Make sure to use the same version.

Build and push the container:

```bash
export TAG="v1.0"
CSCS_REGISTRY="jfrog.svc.cscs.ch/docker-ci-ext/657496524998283"
podman login jfrog.svc.cscs.ch

podman build -f zen2.Containerfile -t $CSCS_REGISTRY/base-images/zen2-devel-ubuntu24.04:$TAG

podman push $CSCS_REGISTRY/base-images/zen2-devel-ubuntu24.04:$TAG
```
