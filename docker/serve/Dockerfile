# Use latest stable version from https://hub.docker.com/_/nginx/
FROM nginx:1.10.2-alpine
MAINTAINER Ben Eills <ben@beneills.com>

# The location of the generated website
ARG compiled

# Copy built sources into served directory
COPY ${compiled} /usr/share/nginx/html

# TODO Copy configuration file
#COPY nginx.conf /etc/nginx/nginx.conf
