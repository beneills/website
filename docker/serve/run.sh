#!/bin/sh

# Run nginx serving the site on port 4005
docker run -p 4005:80 beneills-serve:v1
