---
layout: page
title: Embedded Triggers
permalink: embedded-triggers/
description: triggers/TODO items within documents themselves
draft: true
---

Often, documents are created with a guaranteed obsolescence.  These come with the burden of maintenance, and worse, it is not always obvious when they become obsolete.

An example of this is the year of copyright present on many webpages: assuming that this is not generated programmatically, it is necessary for the maintainer to update it yearly, and therefore necessary for a recurring reminder to be stored somewhere:

+ the maintainer's memory
+ a calendar application

The problem with this approach is that we have two separate locations for our "copyright year system".  If we decide to change the system in some way, e.g. switch to a monthly copyright, we have to modify **both** to keep them in sync.

**We don't want the mental burden of managing the linkage between the multiple system components, and the loss of durability.**

## The Solution

We store as much metadata as possible **within** the one location.  In practice, this means in the same file or project directory.

This is already done by some who put tags such as **TODO** or **FIXME** in their code file comments.  Let's take this as a basis, and extend it.


test
again
and again
