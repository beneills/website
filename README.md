# Personal website ([beneills.com](beneills.com))

[![Build Status](https://travis-ci.org/beneills/website.svg?branch=master)](https://travis-ci.org/beneills/website)


## Building/Deploying

### Local build/test
```bash
# Install dependencies
bundle install

# Build site in _site/ directory
jekyll build

# (optional) Serve site locally for testing
jekyll serve
```

### Deploying SSL certificates to `hyper.sh`

```bash
# Create a volume to hold SSL information (10GiB is the minimum)
hyper volume create --size=10 --name ssl

# Copy SSL certificates to volume
tar czf - ssl/* | hyper exec -i website bash -c "cd /ssl && cat - | tar xz"
```

### Building and deploying to `hyper.sh`

```bash
# Generate metadata
HYPER_IP=209.177.92.197
LATEST_HASH=$(git log -1 --pretty=format:%h)
IMAGE_NAME=beneills/website:$LATEST_HASH

# Build new docker image locally
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME

# Deploy new container
OLD_IMAGES=$(hyper images --quiet beneills/website)
hyper pull $IMAGE_NAME
EXISTING_CONTAINER=$(hyper ps --filter name=website --quiet)
hyper stop $EXISTING_CONTAINER
hyper rm $EXISTING_CONTAINER
hyper run --tty --size=s1 --detach --publish 80 --publish 443 --volume ssl:/ssl --name website $IMAGE_NAME
hyper fip attach $HYPER_IP website

# Test HTTP GET for root endpoint
curl -sSf $HYPER_IP > /dev/null

# Cleanup old images
echo "Old images: $OLD_IMAGES"
echo "Delete with:"
echo "hyper rmi $OLD_IMAGES"
```

### New Docker images for building and deploying

```bash
# Create a new jekyll container
./docker/jekyll/build.sh

# Generate a serve image
./docker/generate.sh

# Serve lcoally
./docker/serve/run.sh

```

## Editing

### Footnotes

Add:

```html
body text<sup><a href="#fn:1" rel="footnote">2</a></sup>
```

and:

```html
<li id="fn:1">
  <p>footnote text</p>
</li>
```

### Embedded math

```
$$ um_{i=0}^{inf} { rac{1}{n^2} } = rac{pi^2}{6}$$

this \\(\sum = 5\\) is inline math
```

### Gists

```
{% gist 4980411 %}
```

## Future changes

- Exclude Docker files themselves from serve image
- Put sources in subdirectory of repo
- Add SSL certificates
- Rename images
- Push to private registry
- Deploy to serve website
