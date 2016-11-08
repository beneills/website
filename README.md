# Beneills.com

[![Build Status](https://travis-ci.org/beneills/website.svg?branch=master)](https://travis-ci.org/beneills/website)

## How to add footnotes

Add:

    body text<sup><a href="#fn:1" rel="footnote">2</a></sup>

and:

    <li id="fn:1">
    	<p>footnote text</p>
    </li>


## How to add math

    $$ um_{i=0}^{inf} { rac{1}{n^2} } = rac{pi^2}{6}$$

    this \\(\sum = 5\\) is inline math

## How to add gist

     {% gist 4980411 %}

## Setting up hyper.sh with SSL certificates

```shell
# Create a volume to hold SSL information (10GiB is the minimum)
hyper volume create --size=10 --name ssl

# Copy SSL certificates to volume
tar czf - ssl/* | hyper exec -i website bash -c "cd /ssl && cat - | tar xz"
```

## Building and deploying

```shell
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
hyper run -d -p 80 --name website $IMAGE_NAME
EXISTING_CONTAINER=$(hyper ps --filter name=website --quiet)
hyper stop $EXISTING_CONTAINER
hyper rm $EXISTING_CONTAINER
hyper run --tty --size=s1 --detach --publish 80 --volume ssl:ssl/ --name website beneills/website:2994001
hyper fip attach $HYPER_IP website

# Test HTTP GET for root endpoint
curl -sSf $HYPER_IP > /dev/null

# Cleanup old images
echo "Old images: $OLD_IMAGES"
echo "Delete with:"
echo "hyper rmi $OLD_IMAGES"
```
