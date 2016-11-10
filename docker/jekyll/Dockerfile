# Use jekyll image based on alpine
FROM jekyll/jekyll
MAINTAINER Ben Eills <ben@beneills.com>

# Copy all repo files into build directory
# TODO exclude unwanted ones
COPY . /build

# This is where we put the generated site
VOLUME /compiled

# Install some dependencies
RUN apk update && apk upgrade && apk --update add \
    build-base ruby-dev python

# Work in source files directory
WORKDIR /build
RUN chmod 1777 *

# Install bundler dependencies
RUN bundle install

# By default, build source
CMD bundle exec jekyll build --destination /compiled
