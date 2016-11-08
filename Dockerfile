# Use a Ruby 2.3 base
FROM phusion/passenger-ruby23:0.9.19

MAINTAINER Ben Eills <ben@beneills.com>

# Install lighttpd
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install lighttpd && apt-get clean

# Remove default site and config
RUN rm -rf /var/www/html/* /etc/lighttpd/lighttpd.conf

# Install config
COPY conf/lighttpd.conf /etc/lighttpd/lighttpd.conf

# Expose web sever on (container) port 80
EXPOSE 80

# Change to temporary directory and grab Jekyll sources (excluding build site)
WORKDIR /tmp/source
COPY . .
RUN rm -rf _site/

# Install Python 2.7 (needed for Pygments)
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python2.7 && apt-get clean
RUN ln -s python2.7 /usr/bin/python

# Install Ruby app dependencies
RUN bundle install

# Build site
RUN bundle exec jekyll build

# Move built site to served directory
RUN mv _site/* /var/www/html/

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Run the web server upon container startup
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
