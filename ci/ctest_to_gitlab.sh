#!/bin/bash

#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

IMAGE="$1"
THREADS_MAX_PER_TASK="$2"
THREADS_PER_NODE="$3"
SLURM_CONSTRAINT="$4"
RUNNER="$5"

STAGES="
  - test
"
TIMELIMIT="15:00"
ARTIFACTS="
  artifacts:
    when: always
    paths:
      - output/
"

BASE_TEMPLATE="
include:
  - remote: 'https://gitlab.com/cscs-ci/recipes/-/raw/master/templates/v2/.ci-ext.yml'

image: $IMAGE

stages:
$STAGES

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
  extends: $RUNNER
  variables:
    SLURM_CPUS_PER_TASK: {{CPUS_PER_TASK}}
    SLURM_NTASKS: {{NTASKS}}
    SLURM_TIMELIMIT: '$TIMELIMIT'
    SLURM_UNBUFFEREDIO: 1
    SLURM_WAIT: 0
    PULL_IMAGE: 'YES'
    USE_MPI: 'YES'
    DISABLE_AFTER_SCRIPT: 'YES'
  script: mpi-ctest
  $ARTIFACTS
"

JOBS=""

N=6
C=$(( THREADS_PER_NODE / N ))

if [ $C -gt $THREADS_MAX_PER_TASK ]; then
  C=$THREADS_MAX_PER_TASK
fi

JOB=`echo "$JOB_TEMPLATE" | sed "s|{{NTASKS}}|$N|g" \
                          | sed "s|{{CPUS_PER_TASK}}|$C|g"`

JOBS="$JOBS$JOB"

echo "${BASE_TEMPLATE/'{{JOBS}}'/$JOBS}"
