# Ralf's kernel notes

A small static technical blog for <https://ralf.shltr.eu>, built with
[Zola](https://www.getzola.org/) and the
[Colorized theme](https://www.getzola.org/themes/colorized/).

## Preview locally

The project requires Zola **0.23.4 or newer**. This checkout has a local 0.23.6
binary at `.tools/zola`; it is ignored by Git. On another machine, install Zola
or put a downloaded binary at that location.

```sh
git submodule update --init --recursive
make preview
```

Open <http://127.0.0.1:1111>. Changes refresh automatically. Stop with Ctrl+C.
Draft posts are included in this preview, but excluded from a normal build.

## Write a post

Create `content/blog/a-descriptive-name/index.md`. Images and diagrams belong
beside it, so Markdown can refer to them by filename.

```markdown
+++
title = "A descriptive title"
date = 2026-10-03
description = "A short summary for the article list and search engines."
draft = true

[taxonomies]
tags = ["ovpn", "kernel"]
+++

Start the article here.

## First section

Write normal Markdown, with fenced code blocks for examples.
```

Remove `draft = true` when ready to publish. Keep the directory name stable:
it forms the article URL. Edit the name and subtitle in `zola.toml`, and the
about page in `content/about.md`.

The initial sample post is ordinary content so you can inspect it without
extra options. Replace or remove it before launching the real blog.

## Build and check

```sh
make check
make build
```

`make check` validates the site and internal links without fetching external
links. To also check external links, run `./scripts/zola check`.
The generated site is in `public/`, which is ignored by Git.

## Publish to Shellter

Publishing means building the HTML locally and copying **only `public/`'s
contents** into Shellter's `~/public_html/`. Git pushes back up the source;
they do not publish the website.

Enable the webspace with `webspace on` in your Shellter shell. Use your existing
SSH configuration, or create an alias called `shellter` with the hostname,
username `ralf`, port, and identity provided by Shellter. Authenticate the host
key normally before the first connection. Both machines need `rsync`.

First inspect the planned upload:

```sh
./scripts/publish --dry-run shellter
```

Then publish:

```sh
./scripts/publish shellter
```

The dry run connects to the server to compare files but does not upload them.
The real upload makes `public_html/` match the built site, including deleting
obsolete files in that directory. Use this only when that webspace is dedicated
to this blog. It preserves the provider-managed `public_html` link. The helper
checks the local output size before uploading. It has not yet been tested
against the remote host.

Shellter can build with Zola too, but local building avoids depending on the
host's installed Zola version.

## Search engines

Static HTML can be crawled and indexed. The site includes descriptions,
canonical links, `sitemap.xml`, and `robots.txt` pointing to the sitemap.
**The placeholder version has `preview_only = true` in `zola.toml`, which adds
`noindex` to the HTML.** Set it to `false` when real content is ready. Robots
are allowed to fetch pages so they can read the `noindex` instruction.

After launch, optionally verify the URL-prefix property `https://ralf.shltr.eu/`
in Google Search Console using an HTML verification file in `static/`, and
submit `https://ralf.shltr.eu/sitemap.xml`. Discovery, indexing, and ranking
are separate steps; a sitemap does not guarantee inclusion.

## Git and theme updates

The theme is a Git submodule pinned to a specific commit. Clone this repository
with `git clone --recurse-submodules` on another machine. Site-specific
templates live in `templates/`; leave the theme checkout unmodified.

To deliberately update the theme:

```sh
git submodule update --remote themes/colorized
make check
make preview
git add themes/colorized
git commit -m "Update Colorized theme"
```

Review the theme's release notes before updating; an update can require a newer
Zola version. Commit the source and theme pointer, never `public/` or `.tools/`.
Once an empty GitHub repository exists, add its URL as `origin` and push `main`.
