#!/bin/bash!

#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2025, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

year=$(date +%Y)
find ${PWD} -type f -exec sed -i "s/2018-2025/2018-${year}/g" {} +
