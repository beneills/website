#!/bin/sh

echo "# Determining beneills-jekyll image version"
BENEILLS_JEKYLL_VERSION=v1
echo "Using version ${BENEILLS_JEKYLL_VERSION}"

echo "# Make a temporary directory to hold compiled Jekyll output"
pushd `dirname $0` > /dev/null
COMPILED="$(pwd)/.compiled"
popd > /dev/null
echo "${COMPILED}"

echo "# Run the Jekyll Docker container to compile site sources"
docker run --rm -v "${COMPILED}:/compiled" "beneills-jekyll:${BENEILLS_JEKYLL_VERSION}"

echo "# Creating beneills-serve image version"
BENEILLS_SERVE_VERSION="$(date +%Y-%m-%d_%H%M%S)"
echo "Using version ${BENEILLS_SERVE_VERSION}"

pwd
echo "# Build the serve container containing nginx and the compiled site"
docker build --file serve/Dockerfile --build-arg "compiled=${COMPILED}" --tag "beneills-serve:v1" .
