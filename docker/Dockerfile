# Use jekyll image based on alpine
FROM jekyll/jekyll:stable
MAINTAINER Ben Eills <ben@beneills.com>

# The site sources (repository root)
COPY . /source

# This is where we put the generated site
VOLUME /compiled

# Install some dependencies
RUN apk update && apk upgrade && apk --update add \
    build-base ruby-dev python

# Work in source files directory
WORKDIR /source

# Install bundler dependencies
RUN bundle install

# By default, build source
CMD bundle exec jekyll build --destination /compiled
