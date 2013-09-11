#!/usr/bin/env ruby

# Adapted again by Ben Eills (http://beneills.com)
# Adapted by Ryan Florence (http://ryanflorence.com) 
# original by Chris Dinger: http://www.houseofding.com/2009/03/create-an-rss-feed-of-your-git-commits/
# 
# Takes one, two, or three arguments
# 1. Repository path (required) - the path to the repository
# 2. The url to put as the <link> for both channel and items
# 3. the repository name, defaults to directory name of the repository
#
# Command line usage:
# ruby gitrss.rb /path/to/repo > feed.rss
# ruby gitrss.rb /path/to/repo http://example.com > feed.rss
# ruby gitrss.rb /path/to/repo http://example.com repo_name > feed.rss

repository_path = File.dirname(File.dirname(File.expand_path(__FILE__)))
url = "http://beneills.com/"
repository_name = "beneills.com"
feed_path = File.join(repository_path, "feed.xml")

Dir.chdir repository_path


git_history = `git log --max-count=10 --name-status`
entries = git_history.split("\ncommit ")

rss = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
  <rss version=\"2.0\">

  <channel>
    <title>#{repository_name}</title>
    <description>Git commits to #{repository_name}</description>
    <link>#{url}</link>
    <lastBuildDate>#{Time.now}</lastBuildDate>
    <pubDate>#{Time.now}</pubDate>
"

entries.each do |entry|
  guid = entry.gsub(/^.*commit /ms, '').gsub(/\n.*$/ms, '')
  author_name = entry.gsub(/^.*Author: /ms, '').gsub(/ <.*$/ms, '')
  date = entry.gsub(/^.*Date: +/ms, '').gsub(/\n.*$/ms, '')
  comments = entry.gsub(/^.*Date[^\n]*/ms, '')

  added = /^A\s+(.+)$/.match(entry)
  modified = /^M\s+(.+)$/.match(entry)
  path = if added
           added[1]
         elsif modified
           modified[1]
         else
           ""
         end
  resource = File.join(url, path)
  title = if added
            "Added #{File.basename(path, File.extname(path))}"
          elsif modified
            "Modified #{File.basename(path, File.extname(path))}"
          else
            "New commit"
          end

  rss += "
    <item>
      <title>#{title}</title>
      <description>#{author_name} made a commit on #{date}</description>
      <content><![CDATA[
        <pre>#{comments}</pre>
    ]]></content>
      <link>#{resource}</link>
      <guid isPermaLink=\"false\">#{guid}</guid>
      <pubDate>#{date}</pubDate>
    </item>"
end 

rss += "
  </channel>
</rss>"


# save
puts "Saving to: #{feed_path}"
File.open(feed_path, 'w') {|f| f.write(rss) }
