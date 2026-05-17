# Contributing to bazel-compile-commands-extractor (helly25 fork)

Thanks for considering a contribution. This document is short on purpose;
please read all of it before opening a pull request.

## Before opening a PR

Read these three top-level docs:

- [`LICENSE.md`](./LICENSE.md) — the licence (held by Hedron Vision
  Inc.) that controls all code in this repository, **including your
  contribution**.
- [`FORK.md`](./FORK.md) — why this repository exists as a
  separately-maintained fork, what shipped in the 2026-05-17 sweep, and
  how we cross-link upstream.
- [`LEGAL.md`](./LEGAL.md) — the licensing context of the fork, the
  operating rules we follow while upstream is dormant, and the explicit
  commitment we make to comply if Hedron Vision Inc. reasserts
  stewardship.

**By signing off your commits (see below) you confirm that you have read
these documents and that your contribution is offered under the terms
of `LICENSE.md`.**

## Two requirements on every commit

Both are enforced by automated checks; pull requests that do not satisfy
them cannot be merged.

### 1. DCO sign-off

Every commit in your PR must carry a `Signed-off-by:` trailer
certifying you have the right to submit the code under the licence.
This is the [Developer Certificate of Origin](https://developercertificate.org/) —
the same mechanism the Linux kernel and many other large projects use.

Add it automatically with `-s`:

```shell
git commit -s -m "your commit message"
```

A repository check enforces this on every PR. If you forget on existing
commits, re-sign with:

```shell
git rebase --signoff main      # adds sign-off to every commit on your branch
```

### 2. Cryptographic signature

Every commit must be signed (GPG or SSH). This is enforced repo-wide by
a GitHub ruleset; unsigned pushes are rejected. See
[GitHub's signing-commits docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
if you have not set this up before.

### Make both automatic

Once per machine:

```shell
git config --global commit.gpgsign true   # auto-sign every commit
git config --global format.signOff true   # auto-add Signed-off-by
# If you'd rather sign with SSH (Git 2.34+):
# git config --global gpg.format ssh
# git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

## Branch protections in plain English

- `main` is protected: every change lands via PR with at least one
  approval, linear history (no merge commits via web), required review
  thread resolution, signed commits, DCO sign-off.
- Other branches require signed commits but no PR review.
- Release tags (`*.*.*`, `v*.*.*`) cannot be force-pushed, deleted, or
  updated; they must be signed.

## Development setup

See [`ImplementationReadme.md`](./ImplementationReadme.md) for how to
clone, install development dependencies, and run the test loop.

## Cross-linking upstream

If your fix or feature corresponds to an existing PR or issue in the
original [hedronvision/bazel-compile-commands-extractor][upstream]
repository, please:

- Link the upstream PR / issue in your PR description.
- Credit the original author in your commit message — e.g.
  `Backport of hedronvision/bazel-compile-commands-extractor#N (original-author)`.
- After your PR is merged, post a short comment on the upstream PR /
  issue pointing at the merged helly25 PR. We do this consistently;
  rationale and examples in
  [`FORK.md`](./FORK.md#how-we-did-the-sweep).

[upstream]: https://github.com/hedronvision/bazel-compile-commands-extractor
