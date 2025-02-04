#!/bin/bash!

year=$(date +%Y)
find ${PWD} -type f -exec sed -i "s/2018-2025/2018-${year}/g" {} +
