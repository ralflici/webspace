+++
title = "A first look at the kernel notes"
date = 2026-10-03
description = "A placeholder article to try the blog's typography, code blocks, tables, and diagrams."

[taxonomies]
tags = ["ovpn", "kernel", "testing"]
+++

This is a **layout sample**, rather than a technical reference. It gives me a place to try the kind of content I expect to publish here: explanations, small code examples, diagrams, and notes from testing.

## Why keep these notes?

A debugging session often ends with a working fix and a few useful observations scattered across terminal output, commit messages, and mailing-list replies. A longer article can put those pieces together.

The aim is to explain the question, follow the relevant code, and show enough evidence for someone else to reproduce the result.

## Code and commands

Here is a small, illustrative C example to check syntax highlighting. It is not code from ovpn:

```c
/* An illustration for this layout sample. */
static bool packet_fits(size_t packet_len, size_t buffer_len)
{
    return packet_len <= buffer_len;
}
```

Short commands should be easy to read and copy:

```bash
git log --oneline -- drivers/net/ovpn/
git diff --stat
```

Inline references such as `struct sk_buff`, `drivers/net/ovpn/`, and `git bisect` should stand out without interrupting the paragraph.

## Following a path

Diagrams can give a reader a useful overview before the details. This one shows the writing workflow for the blog:

![Markdown and images are transformed by Zola into static HTML, then uploaded to Shellter.](writing-workflow.svg)

### Recording the evidence

For a real investigation, I would include the revision under test, the environment, the command used, and the observed result.

| Item | What to record |
| --- | --- |
| Revision | Commit identifier and relevant patches |
| Environment | Kernel configuration and test setup |
| Reproducer | Commands or a small program |
| Result | Expected behavior and observed behavior |

> A useful explanation should make it possible to follow the reasoning and repeat the experiment.

## What comes next

Future posts might cover:

- How a particular part of ovpn works.
- A bug investigation, from the first symptom to the fix.
- Running kernel tests and understanding their results.
- Small networking details that deserve a longer explanation.

For now, this page is just a first look. [About this blog](@/about.md).
