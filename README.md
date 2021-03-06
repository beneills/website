# Personal website ([beneills.com](beneills.com))

[![Build Status](https://travis-ci.org/beneills/website.svg?branch=master)](https://travis-ci.org/beneills/website)


## Building

### Host machine build/test
```bash
# Install dependencies
bundle install

# Build site in the _site directory
jekyll build

# (optional) Serve site locally for testing
jekyll serve
```

### Docker build

The following will generate the site in `_site`:
```bash
docker/generate.sh
```

## Deploying

The files in the `gh-pages` branch will be served by Github pages.

In order to deploy a branch (e.g. `master`), test, commit push the changes. Then run:
```bash
./tools/deploy.sh
```

## Editing

### Footnotes

Add:

```html
body text<sup><a href="#fn:1" rel="footnote">2</a></sup>
```

and:

```html
<li id="fn:1">
  <p>footnote text</p>
</li>
```

### Embedded math

```
$$ um_{i=0}^{inf} { rac{1}{n^2} } = rac{pi^2}{6}$$

this \\(\sum = 5\\) is inline math
```

### Gists

```
{% gist 4980411 %}
```

## Future changes

- Exclude Docker files themselves from serve image
- Put sources in subdirectory of repo
- Add SSL certificates
- Rename images
- Push to private registry
- Deploy to serve website
