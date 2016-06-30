---
layout: state_of_the_realm
date: 2016-06-30
title: Explanation
permalink: state_of_the_realm_explanation/
completion: 100%
listed: false
---

### Conception

The motivation behind this was to provide a high-level view of the state of the United Kingdom: politics, economics and society, which
made it easy for the reader to follow arguments via heavy annotations.  These are like [typed](https://en.wikipedia.org/wiki/Type_theory), [parameterized](https://en.wikipedia.org/wiki/Parameter) traditional footnotes.

### Annotations

A _fact_ &mdash; something true beyond reasonable doubt and backed up empirically in the evidence &mdash; is marked with an _f_ and an identifying number, e.g.: all men are mortal {% fact 1 %}. You can see the evidence by clicking the superscript link.  Similarly. this is a _conjecture_: all trees are green {% conjecture 2 %}.  Conjectures are not necessarily true, but are still backed up with external evidence.  _Statements_, like this, are propositions not explicitly backed up {% statement 3 %}.  _Inferences_ are deductions from other statements, for example: this document covers facts, conjectures and statements {% inference f1 c2 s3 %}. Footnotes are more flexible, usually with explanation or context {% footnote 4 %}.


{% evidence %}
  {% piece fact-1 %}
    Here you'd find evidence for the assertion.
  {% endpiece %}

  {% piece conjecture-2 %}
    Likewise, here would be evidence for the conjecture.
  {% endpiece %}

  {% piece statement-3 %}
    _TODO eliminate the need for statement evidence pieces._
  {% endpiece %}

  {% piece footnote-4 %}
    Explanation.
  {% endpiece %}
{% endevidence %}
