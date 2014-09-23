---
layout: page
title: Draft Versioning
permalink: draft-versioning/
description: configure git versioning for the markdown composition app <a href="https://play.google.com/store/apps/details?id=com.mvilla.draft&hl=en">Draft</a>
completion: complete
---

I use the Android app [Draft](https://play.google.com/store/apps/details?id=com.mvilla.draft&hl=en) to compose Markdown documents.  This syncs them with my Dropbox account, however lacks versioning, or even undo functionality.  Some reviews on the Google Play site indicated that users has inadvertently deleted data while typing, so I needed a solution to:

1. protect my data, and
2. version control it

Since all the data passes through Dropbox, I set out to have my [Linode](https://www.linode.com/) server mirror the Dropbox files, and auto-commit them to Git using [GitWatch](https://github.com/nevik/gitwatch).

## The Process

We install headless Dropbox:

{% highlight bash %}
# install from https://www.dropbox.com/install2
dropbox start
{% endhighlight %}

and GitWatch:

{% highlight bash %}
sudo aptitude install inotify-tools
wget -O ~/bin/gitwatch.sh https://raw.github.com/nevik/gitwatch/master/gitwatch.sh
chmod +x ~/bin/gitwatch.sh
{% endhighlight %}

then test:

{% highlight bash %}
dropbox start
~/bin/gitwatch.sh ~/Dropbox/Draft > /dev/null &
cd ~/Dropbox/Draft; watch git log -n 1 # now, make an edit!
{% endhighlight %}

Now, we make everything start at startup by putting the following at the end of into `crontab -e`:

{% highlight bash %}
@reboot ~/.dropbox-dist/dropboxd
@reboot ~/bin/gitwatch.sh ~/Dropbox/Draft
{% endhighlight %}
