# Legal posture of the helly25 fork

## Goal

Our goal is to keep a viable, actively-maintained fork available for the
community **as long as upstream remains dormant**. If
[Hedron Vision Inc.][hedron-co] reasserts active stewardship — by
resuming maintenance, relicensing the project, asking us to wind the
fork down, or any other direction — **we will comply with that choice**.

The original license in [`LICENSE.md`](./LICENSE.md) continues to
control. We are not relicensing the original code, we are not removing
the copyright line, and we are not asserting any rights inconsistent
with that license.

This document records the research we did before starting the fork, the
plain-English read of the license, and the operating rules we set
ourselves while upstream remains inactive. It is **not legal advice** —
none of the maintainers of this fork are lawyers. If you are evaluating
this fork for use in a context where the license matters materially to
your organisation, read [`LICENSE.md`](./LICENSE.md) for yourself and
consult counsel.

---

## What the license says

The license is custom: source-available, contribution-encouraging,
proprietary. It is **not OSI-approved open source**. The full text is
authoritative; this section is a plain-English summary.

| Clause | What it grants / restricts |
|---|---|
| Grant | Non-exclusive license to **run** the software "for your own personal, internal development productivity, free of charge." Explicitly includes **internal use at a company** and **internal customization/distribution of changes**. |
| Public forks | Permitted, but "only as a **temporary** means of contributing those improvements back to the main repository" (the hard-coded URL points at [hedronvision/bazel-compile-commands-extractor][upstream]). |
| Contributor IP assignment | "Hedron retains all right, title, and interest in and to all such contributions." Public contributions become Hedron's property. |
| Commercial restriction | Recipients "agree to not charge others for their use of this Software or for using your changes to this Software." |
| Revocability | "this is a revocable license." |
| Auto-termination | The license terminates automatically if the recipient files a lawsuit against Hedron. |
| Warranty / liability | Standard "AS IS" disclaimer. |

The license is held by **Hedron Vision Incorporated**.

---

## Status of Hedron Vision Inc.

We did public-records and public-statements research before starting the
fork, to understand whether the original entity is still in a position
to maintain the project itself or to respond to contributions.

### Corporate entity

- **Hedron Vision Incorporated** — Delaware C-corporation, filed
  2019-04-09; registered with the California Secretary of State as
  document #4264725.
- As of **2026-03-25** (last verification we have), the California SoS
  lists the entity as **active** with "Good" standing across SoS,
  Franchise Tax Board, Agent, and the Victims of Corporate Fraud
  Compensation Fund.
- Crunchbase lists 2 employees, ~$550K raised, with Founders Fund and
  Sequoia Capital among the backers.
- The corporate website at [hedronvision.com][hedron-web] remains live,
  with **no acquisition / shutdown / sunset notice** posted as of this
  writing.

**Net:** the legal entity is **not dissolved**. It is, however,
**operationally dormant for OSS-maintenance purposes** — see below.

### The "joined Google DeepMind" event (December 2024)

In December 2024 Hedron Vision posted on LinkedIn, verbatim:

> "Hedron Vision has joined Google DeepMind! We set out to create
> universal holographic displays, and along the way we built products
> and technologies used around the world, **a chunk of which will
> continue to live on inside Google**."

— Hedron Vision, [LinkedIn post][hedron-linkedin].

The founder and CEO, **Christopher Peterson Sauer**
([@cpsauer][cpsauer-gh]), now lists his bio as:

> "AI Researcher [@google-deepmind][gdm-gh]. Formerly, founder
> [@hedronvision][hedron-gh]. Stanford Engineering valedictorian.
> ex-Google, Oculus, Dropbox."

The pattern is consistent with an **acqui-hire**: the team joined
Google as employees; *some* IP transferred to Google; the corporate
shell appears to have survived. Crucially, the phrase **"a chunk of"**
makes clear that not all Hedron Vision technology became Google's —
the LinkedIn post talks about holographic-display tech, not Bazel
tooling, and Google operates its own internal compile-command
infrastructure. So the copyright in this repository almost certainly
remains with the (now-dormant) Hedron Vision Inc. shell rather than
sitting inside Google's portfolio.

### Repository activity since the acqui-hire

- Last meaningful (non-CI) commit upstream: **2024-06-28**.
- Two subsequent merges (2024-10-08, 2025-08-11) were pre-commit-CI
  autoupdates only — no human review of pending PRs.
- ~30 open PRs accumulated on the upstream repository between
  2022 and 2026 with no maintainer triage.
- Multiple long-standing issues with available fixes remained unmerged.
- Bazel 9 (released April 2026) removed the native `py_binary` /
  `cc_binary` rules, breaking the tool's `bazel run @hedron_compile_commands//:refresh_all`
  invocation out of the box.

The combination — founder employed full-time at Google DeepMind,
funded company functionally dormant, ~30 unreviewed PRs, current Bazel
broken — is what motivated this fork.

---

## Where the fork sits relative to the license

Two clauses are in **tension** with this fork's posture. We are
transparent about both, and document our reasoning rather than gloss
over them.

### 1. The "temporary fork only" clause

The license permits public forks **"only as a temporary means of
contributing those improvements back to the main repository."** A
long-lived fork positioned as the de-facto active version is not
literally a temporary staging area.

Our position: when the upstream contribution channel is functionally
unreachable (no human reviewer for ~2 years, founder at a different
employer), the contribute-back condition cannot be satisfied in
principle. A licensor that lets the contribution channel lapse cannot
reasonably bind licensees to that channel. The fork remains *prepared
to act as a contribution channel back to Hedron* — every PR landed
here is cross-linked to the corresponding upstream PR/issue, and the
upstream remote is still tracked in this repository — so the spirit of
the clause is honoured even where its letter cannot be.

This is a frustration-of-purpose / implied-licence argument. It is not
airtight. It is part of why our [goal statement](#goal) commits us to
wind the fork down if Hedron asks.

### 2. The contributor IP assignment

The license says: "Hedron retains all right, title, and interest in and
to all such contributions." Strictly read, every commit made to this
fork is owned by Hedron Vision Inc.

In practice the enforceability of "I assigned my copyright by clicking
through a license" is jurisdiction-dependent, and ours is not a click-through
arrangement to begin with. The clause is a cloud rather than a
clean transfer. We mention it because contributors deserve to know.

We do not ask contributors to sign a CLA. By contributing to this fork
you accept the same terms as the original `LICENSE.md`, with all the
caveats above.

---

## Operating rules while upstream is dormant

Until the situation changes:

- **We will** keep the fork running for personal, internal, and
  company use — which is unambiguously inside the original licence
  grant.
- **We will** keep cross-linking back to upstream PRs and issues on
  every contribution that has an upstream predecessor, so attribution
  and intent stay visible to the original maintainers if they return.
- **We will** preserve [`LICENSE.md`](./LICENSE.md) as-is, including
  the `Copyright Hedron Vision Incorporated` line and every reference
  to the original repository.
- **We will not** charge for the tool, charge for fork-specific paid
  support, or otherwise monetize the work in ways that would conflict
  with the no-commercial-distribution clause.
- **We will not** unilaterally relicense the existing code. Where this
  fork adds new code, that code is contributed under the same licence
  terms as everything else in the repository.
- **We will not** assert any trademark or naming rights over
  "Hedron's Compile Commands Extractor" or related marks.

---

## What happens when Hedron reasserts stewardship

If [Hedron Vision Inc.][hedron-co], anyone authorised to act on its
behalf, or anyone reasonably claiming successor-in-interest contacts us
to:

- **resume upstream maintenance** — we will switch this fork into a
  "syncing back" mode and route contributions to upstream;
- **relicense the project** — we will adopt the new licence terms
  (subject to giving existing users reasonable notice);
- **request that the fork be wound down** — we will archive the
  repository, redirect users to the upstream, and stop accepting new
  contributions;
- **request transfer of ownership** — we will hand the repository
  over;
- **anything else** — we will engage in good faith and comply with
  any reasonable direction.

The general-purpose contact route for Hedron Vision Inc. is
`contactus@hedronvision.com`, with founder Christopher Sauer reachable
via [@cpsauer on GitHub][cpsauer-gh] or LinkedIn.

---

## Outreach

### Prior contact (April 2025)

On **2025-04-18**, helly25 (Marcus Boerger) emailed Christopher Sauer
at `christophersauer@pacbell.net` asking whether the long-pending
header-only fix ([upstream #219][upstream-pr-219]) could be merged,
and floating alternatives including ownership transfer, adding a
co-maintainer, or a permissive relicence. A second mail on the same
day pointed at the rebased [upstream #209][upstream-pr-209].

Christopher replied on **2025-04-24** ("Hey, Marcus!") saying the
Google-side approvals were close and the team "should be able to
transfer into google and merge in super soon", apologising for the
slowness. helly25 acknowledged the same day.

In the thirteen months since, no transfer, merge, or relicence has
happened publicly. The upstream repository continued to receive only
pre-commit autoupdates. The open-PR backlog kept growing. Bazel 9
(April 2026) removed the native `py_binary` / `cc_binary` rules,
breaking the tool out of the box for stock Bazel 9 users
([upstream issue #279][upstream-issue-279]).

### Follow-up (May 2026)

On **2026-05-17 at 14:35 BST**, a follow-up email was sent recapping the
situation and outlining options for a permanent resolution (resumed upstream
maintenance, relicensing, or explicit direction).

On **2026-05-17 at 23:58 BST**, Christopher Sauer responded,
confirming active receipt and expressing full support for the work being done
here to keep the tool working for the community. He noted that personal
circumstances will keep him away from active maintenance for quite some time,
but confirmed his intent to work together to make the integration official when
he returns.

### Reassessment

A constructive dialogue is now actively underway. For the moment, this fork will
remain active to support the community, but under restricted maintenance. Due to
current compliance constraints, this repository has limited ability to take on
external contributions until a permanent upstream resolution is finalized.

### Outcomes

(no responses logged yet)

---

## Sources

The factual claims in this document are based on public records and
public statements available at the time of writing
([FORK.md timeline](./FORK.md#timeline) for project-side dates):

- [Hedron Vision Incorporated — bizprofile.net (CA SoS filing summary)][hedron-co]
- [Hedron Vision — Crunchbase company profile][hedron-cb]
- [Hedron Vision — PitchBook profile][hedron-pb]
- [Christopher Sauer — Crunchbase person profile][cpsauer-cb]
- [Christopher Sauer — GitHub profile bio][cpsauer-gh]
- [Hedron Vision — GitHub organization][hedron-gh]
- [hedronvision.com — company website][hedron-web]
- [Hedron Vision LinkedIn post — "joined Google DeepMind"][hedron-linkedin]

[upstream]: https://github.com/hedronvision/bazel-compile-commands-extractor
[hedron-co]: https://www.bizprofile.net/ca/portola-valley/hedron-vision-incorporated
[hedron-cb]: https://www.crunchbase.com/organization/hedron-vision
[hedron-pb]: https://pitchbook.com/profiles/company/266637-07
[hedron-web]: https://hedronvision.com
[hedron-gh]: https://github.com/hedronvision
[hedron-linkedin]: https://www.linkedin.com/posts/hedronvision_hedron-vision-has-joined-google-deepmind-activity-7275631303255842818-yQw7
[cpsauer-cb]: https://www.crunchbase.com/person/chris-sauer-0a97
[cpsauer-gh]: https://github.com/cpsauer
[gdm-gh]: https://github.com/google-deepmind

[upstream-pr-209]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/209
[upstream-pr-219]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/219
[upstream-issue-279]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/279
