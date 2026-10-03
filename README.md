# Ralf's kernel notes

[![Build and publish blog](https://github.com/ralflici/webspace/actions/workflows/site.yml/badge.svg)](https://github.com/ralflici/webspace/actions/workflows/site.yml)

A small static technical blog for <https://ralf.shltr.eu>, built with
[Zola](https://www.getzola.org/) and the
[Colorized theme](https://www.getzola.org/themes/colorized/).

## Preview locally

The theme requires Zola **0.23.4 or newer**. CI pins **0.23.6** and verifies
the downloaded release checksum. On Linux x86_64, install that same version:

```sh
./scripts/install-zola
```

The binary at `.tools/zola` is ignored by Git. On another platform, install
Zola manually; `scripts/zola` also supports a `zola` binary on your PATH.

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

## Automatic publishing with GitHub Actions

[Build and publish blog](https://github.com/ralflici/webspace/actions/workflows/site.yml)
runs on pushes to `main`, pull requests targeting `main`, and manual runs.

- Every run checks the content and scripts, builds with pinned Zola, and saves
  the production files as an artifact named `site` for seven days.
- Successful `main` runs deploy that exact artifact to <https://ralf.shltr.eu>
  when the repository variable `SHELLTER_DEPLOY_ENABLED` equals `true`.
- Pull requests build only. Draft posts are excluded from production builds.
- Runs on the same branch are serialized so an upload is not interrupted by
  a newer run. An older commit is skipped if `main` has already moved on.

The deploy job uses the `shellter` GitHub environment, a dedicated SSH key,
and the verified Ed25519 host key committed in
`.github/deployment/shellter_known_hosts`. SSH rejects an unexpected host key
and never falls back to password authentication. A provider host-key change
must be verified before updating that file.

### One-time deployment setup

The initial setup has been completed for this repository, with a dedicated key
at `~/.ssh/webspace-actions` and its private key stored in the `shellter`
environment secret. The steps below document how to recreate the setup.

1. Create a dedicated, passphrase-free Ed25519 key for this automation. Keep
   the private key outside the repository. For example:

   ```sh
   ssh-keygen -t ed25519 -N '' -C 'GitHub Actions: ralflici/webspace' -f ~/.ssh/webspace-actions
   ```

2. Add its public key to Shellter's `~/.ssh/authorized_keys`, prefixed with
   `restrict` to disable forwarding, PTY allocation, and user startup hooks.
   Enable `webspace on` if needed.
3. Create the `shellter` environment in repository Settings → Environments,
   and add its secret `SHELLTER_SSH_KEY` containing the complete private key:

   ```sh
   gh secret set SHELLTER_SSH_KEY --repo ralflici/webspace --env shellter < ~/.ssh/webspace-actions
   ```

4. Before enabling automatic uploads, select **Run workflow** on the Actions
   page, choose `main`, and tick **Check deployment access without uploading
   files**. Or use:

   ```sh
   gh workflow run site.yml --repo ralflici/webspace --ref main -f dry_run=true
   ```

5. After the dry run succeeds, enable automatic publishing:

   ```sh
   gh variable set SHELLTER_DEPLOY_ENABLED --repo ralflici/webspace --body true
   ```

Push an update to `main`, or run the workflow manually with the dry-run option
unchecked, to publish. Setting the variable to `false` disables uploads while
keeping builds active. Manual dry runs remain available when uploads are
disabled. To revoke deployment access, remove the dedicated public key from
Shellter and delete the corresponding GitHub secret.

Actions logs show which build or upload failed; the job summary links to the
published site. `scp` overwrites matching files but leaves old remote files
in place, so renamed or deleted pages need manual cleanup. Uploads are not
atomic: a failed transfer may leave a partially updated site; rerun the workflow
to complete it.

## Publish manually to Shellter

Publishing means building the HTML locally and copying **only the generated
files** into Shellter's `~/public_html/`. The helper builds into `.cache/publish/`
so it does not interfere with a running local preview. This remains useful as
a fallback to automatic publishing.

Enable the webspace with `webspace on` in your Shellter shell. Use your existing
SSH configuration, or create an alias called `shellter` with the hostname,
username `ralf`, port, and identity provided by Shellter. Authenticate the host
key normally before the first connection. Uploads use `scp` through SSH's SFTP
subsystem; no Zola or rsync installation is needed on the server.

First inspect the planned upload:

```sh
./scripts/publish --dry-run shellter
```

Then publish:

```sh
./scripts/publish shellter
```

The dry run checks SSH access and whether `~/public_html/` is writable, then
lists the local files it would upload. It does not compare file contents or
change remote files. The real upload copies all generated files, overwriting
matching filenames and leaving other remote files in place. If you rename or
remove a page, its old remote files need manual cleanup. It preserves the
provider-managed `public_html` link. The helper checks the local output size
before uploading. CI uses the same upload helper with its downloaded artifact;
it does not rebuild the site during deployment.

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
The `origin` remote is `git@github.com:ralflici/webspace.git`. A normal update is:

```sh
git add content/
git commit -m "Add a new article"
git push origin main
```
