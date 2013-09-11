#!/usr/bin/env ruby

#
# Check a page or post against some common criteria
#
# from: http://www.gwern.net/About#writing-checklist
#

filename = ARGV.first

raise "No file specified" if filename.nil?

# spelling
system "emacsclient -c #{filename}"

# maruku
system "maruku --html --output /tmp/maruku_out.html #{filename}"
system "xdg-open /tmp/maruku_out.html"

# linkchecker
system "linkchecker /tmp/maruku_out.html"
