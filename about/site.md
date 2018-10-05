---
layout: page
title: About the Site
comments: false
description: its hosting, content, and future
---

## Task List
Maintained as an org-mode file.

## Software
This is hosted as a [Jekyll](http://jekyllrb.com/) blog, but makes use of other Jekyll features far more than the blogging stuff.  The source is available on [Github](https://github.com/beneills/website).  If I wrote the site again, I'd investigate [Octopress](http://octopress.org/) for apparently easier site admin (although it's pretty easy as-is).  The resultant static HTML directory tree is easy to host anywhere.  I've moved away from Github Pages, since I use custom plugins{% fn %}.

I use [JVectorMap](http://jvectormap.com/) to draw my [places map](about/author/#toc_2), alongside JQuery for other stuff.

## Hosting
Hosted with [nginx](http://nginx.org/) on my very own 1GB [Linode](https://www.linode.com/) instance in London.  I host other projects here also.




{% footnotes %}
   {% fnbody %}
  <a href="http://github.com/beneills/website/tree/master/_plugins">plugin source</a>
	<ul>
        <li>footnotes</li>
        <li>table of contents</li>
        <li>RSS</li>
	  </ul>


  {% endfnbody %}
{% endfootnotes %}
