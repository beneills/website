set -e

IMAGE_TAG=beneills-jekyll
OUTPUT_DIRECTORY=$(greadlink -f $(dirname $0)/../_docker_site)

# Go to website root so that we can copy jekyll sources
pushd $(dirname $0)/.. > /dev/null

# Create an output directory
mkdir "$OUTPUT_DIRECTORY"

# Build the Docker image
docker build \
  --file docker/Dockerfile \
  --tag "$IMAGE_TAG" \
  .

# Run the Docker image
docker run \
  --mount "type=bind,source=$OUTPUT_DIRECTORY,destination=/compiled" \
  "$IMAGE_TAG"

# Go back to original directory
popd
