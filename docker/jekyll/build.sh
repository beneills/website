# Go to website root so that we can copy jekyll sources
pushd $(dirname $0)/../.. > /dev/null

# Build docker image
docker build --file docker/jekyll/Dockerfile --tag beneills-jekyll:v1 .

# Go back to original directory
popd
