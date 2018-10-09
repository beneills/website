---
layout: page
title: Productive Computer Setup
permalink: computer-setup/
description: how I quickly set up my computer to be productive
completion: first draft
---

I've switched from a highly-customized AwesomeWM setup to a keep-most-defaults Xubuntu desktop.  This page describes how to replicate what I did.  Note that much of my work is in Emacs, which I have customized extensively in my configuration repository.

## System Criteria

I've used many different operating systems and sub-components such as window managers.

This page describes the system I currently{% fn %} use, and intend to use into the near future, which fulfils three criteria:

1. the system is quick to set up (guideline time: < 3 hours) and easy to re-install

2. it allows productive and efficient work (i.e. never gets in the way of doing actual stuff)

3. it is resilient, not relying on chains of breakable components

## Outline of System

The system uses:

+ the latest [Xubuntu](http://xubuntu.org/) (13.10 at current time, although the version is unimportant)

+ an [install](https://github.com/beneills/install) git repository, hosted on Github, automating common install tasks

+ a [configuration](https://github.com/beneills/configuration) git repository of configuration dotfiles

+ intelligent keybindings, using the Super key, largely taken from Awesome WM

+ dmenu, Guake, making panels autohide and other visuals

+ Chrome stuff

+ Emacs

## In Depth

### Xubuntu

Chosen for being stable, maintained, having up-to-date packages available with a lightweight and nice looking UI.  No more worrying about package versions or messing with aesthetic stuff to make it look nice: it already does.

### Install

In here is:

+ a plaintext list of Ubuntu packages that can be installed via `cat apt-package-list | xargs sudo apt-get install`

+ a similar list of Ruby Gems

+ an update script to produce the above two lists (of explicitly installed packages, excluding dependencies)

+ a synopsis of what I did upon install: `2014-01-01.log`


### Configuration

A git repo of most of my important dotfiles (including my emacs.d/) and scripts to add new files and create the appropriate symlinks.

### Keybindings

Most importantly, I add `ctrl:nocaps` to `/etc/default/keyboard` to make Emacs and command line much easier to use.

Through Settings -> Keyboard I setup keybindings to launch Emacs (Super+E), Anki (super+A), etc.

I also have Super+d to launch dmenu_run, Super+s to toggle the Guake terminal, a lock key to start xscreensaver and the PrintScreen key to run `ksnapshot --region`

Through Settings -> Window Manager I change window management keybindings to resemble Awesome's:

+ Super+m to maximize window
+ Super+Tab to cycle workspace windows
+ Alt+Tab to cycle application's windows
+ Super+n to change to workspace n
+ Super+Shift+n to move window to workspace n

### dmenu, Guake, ...

I recommend everyone tries dmenu (Ubuntu package: suckless-tools), and Guake is fantastic as an always-accessible terminal (add to autostart applications).

I leave the bottom panel settings as default, and add my most common app launchers to it.

The top panel I set to 18px and autohide.  This gives me 100% of screen real estate for applications themselves.

### Chrome

I install the `chromium-browser` Ubuntu package via the above, and sign in to my Google Apps account to sync everything.

Extensions: AdBlock Plus, FastestFox, Pocket, RSS Subcription

#### Bookmarks

I have a pretty strict bookmarks hierarchy, the most important folders being: *Inbox*, *R/W/L*, *Sites* and *Pin*

The idea is that *everything* goes into *Inbox* initially, making bookmarking a page being as easy as Ctrl+d, then processing *Inbox* weekly

*R/W/L* contains stuff to read, watch and listen to.  I think this idea came from [Getting Things Done](http://en.wikipedia.org/wiki/Getting_Things_Done).

*Sites* contains sites I like to browse regularly: LifeHacker, Less Wrong, etc.

*Pin* contains my pinned pages.  When you close the main Chrome browser window before a non-toolbar one, you lose all your pinned tabs.  I think this design choice sucks, and it certainly does not reflect the way I use pinned tabs (permanently), but I get around this by maintaining this folder.  If/when you lose your pinned tabs, just open all tabs in this folder and right-click pin each.

<img src="/images/bookmarks.png" />


Pinned tabs are: Gmail, Google Calendar, [Beeminder](https://www.beeminder.com/), Google Keep


Keyword search engines are very important for me.  A partial list is:

**a**: amazon UK

**wa**: WolframAlpha query

**fe**: WordReference English-French

**ff2**: Google Translate French-English

**r**: Ruby Documentation

**y**: Youtube



{% footnotes %}
   {% fnbody %}
	   January 2014
   {% endfnbody %}
{% endfootnotes %}
