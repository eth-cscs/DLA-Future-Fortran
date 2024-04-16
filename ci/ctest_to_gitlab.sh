#!/bin/bash

#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2024, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

IMAGE="$1"
THREADS_PER_NODE="$2"
SLURM_CONSTRAINT="$3"

BASE_TEMPLATE="
include:
  - remote: 'https://gitlab.com/cscs-ci/recipes/-/raw/master/templates/v2/.cscs.yml'

image: $IMAGE

stages:
  - test

variables:
  SLURM_EXCLUSIVE: ''
  SLURM_EXACT: ''
  SLURM_CONSTRAINT: $SLURM_CONSTRAINT
  MPICH_MAX_THREAD_SAFETY: multiple

{{JOBS}}
"

JOB_TEMPLATE="
tests:
  stage: test
  extends: .daint
  variables:
    SLURM_CPUS_PER_TASK: {{CPUS_PER_TASK}}
    SLURM_NTASKS: {{NTASKS}}
    SLURM_TIMELIMIT: '15:00'
    SLURM_UNBUFFEREDIO: 1
    SLURM_WAIT: 0
    PULL_IMAGE: 'YES'
    USE_MPI: 'YES'
    DISABLE_AFTER_SCRIPT: 'YES'
  script: mpi-ctest"

JOBS=""

N=6
C=$(( THREADS_PER_NODE / N ))

JOB=`echo "$JOB_TEMPLATE" | sed "s|{{LABEL}}|$label|g" \
                          | sed "s|{{NTASKS}}|$N|g" \
                          | sed "s|{{CPUS_PER_TASK}}|$C|g"`

JOBS="$JOBS$JOB"

echo "${BASE_TEMPLATE/'{{JOBS}}'/$JOBS}"
