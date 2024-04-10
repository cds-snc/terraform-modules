#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#
# Downloads the Lambda's Python dependencies and packages them into a deterministic zip file.
# This will limit the number of times the Lambda layer is recreated by only updating the layer
# when the `requirements.txt` file changes.
#

# Parse input
eval "$(jq -r '@sh "export PYTHON_VERSION=\(.python_version) SRC_DIR=\(.src_dir)"')"

# Download dependencies
docker run -v "${SRC_DIR}":/var/task public.ecr.aws/sam/build-${PYTHON_VERSION} \
    /bin/sh -c "pip install -r lambda/requirements.txt -t lambda/layer/python/; exit" \
    > /dev/null 2>&1

# Generate a deterministic zip file
# This is done by removing the compiled bytecode and setting the timestamp of the
# downloaded files to the same date.
find "${SRC_DIR}/lambda/layer" | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf  > /dev/null 2>&1
find "${SRC_DIR}/lambda/layer" -exec touch -t 197001010000 {} + > /dev/null 2>&1
cd "${SRC_DIR}/lambda/layer"
zip -r -X "${SRC_DIR}/lambda/decrypt_deps.zip" python/ > /dev/null 2>&1

# Produce output
jq -n \
    --arg layer_zip "${SRC_DIR}/lambda/decrypt_deps.zip" \
    '{"layer_zip":$layer_zip}'