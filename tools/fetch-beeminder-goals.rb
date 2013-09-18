#!/usr/bin/env ruby
#
# Fetch my goals and print to stdout
#

require "highline/import"
require "open-uri"

profile_url = "https://www.beeminder.com/beneills"

goal_template = <<END
<div class="beeminder-goal">
<a href="%{goal_url}" target="_blank">
<img src="%{graph_url}" title="%{goal_name}" alt="%{goal_name} Beeminder goal" onload="handleBeeminderImageLoad(this)" style="display: none;" />
</a>
</div>
END
.gsub("\n", "")

goals_template = <<END
<div class="beeminder-goals">
%{goals}
</div>
END
.gsub("\n", "")


person_short_name = profile_url.split( "/" )[-1]
body = open(profile_url).read
goals = body.split(/<div class=\"archive\">/)[0]
  .scan(/\/goals\/([\w-]+)/).uniq.map { |g| g[0] }

puts goals_template % {goals: goals.map do |goal_name|
    goal_url = File.join( profile_url, "goals", goal_name)
    graph_url = File.join( goal_url, "/graph?style=thumb")
    goal_template % {goal_name: goal_name,
      goal_url: goal_url,
      graph_url: graph_url}
  end.join()}
