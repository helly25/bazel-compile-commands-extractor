# Fork status — helly25/bazel-compile-commands-extractor

This document explains why this repository exists as a separately-maintained
fork of [hedronvision/bazel-compile-commands-extractor][upstream], how the
move happened, what shipped in the first sweep, and how we keep the lineage
visible.

The short version: upstream has been functionally dormant since the
founding team [joined Google DeepMind][hedron-linkedin] in December 2024.
A backlog of useful patches accumulated, and current Bazel versions
stopped working out of the box. In May 2026 we did a coordinated
viability sweep — triaged the open upstream PRs, picked one base when
several PRs solved the same problem, landed everything as PRs in this
fork, and posted cross-reference comments back upstream so credit stays
with the original authors.

This fork is the active version while upstream remains inactive. We
continue to track upstream and will fold in anything new that lands
there.

See [`LEGAL.md`](./LEGAL.md) for the licensing context, the research we
did on Hedron Vision Inc.'s current status, and the explicit commitment
we make about handing the project back if Hedron reasserts stewardship.

---

## Timeline

### Upstream activity

The hedronvision repository has not had a non-CI commit in ~2 years. The
last few touches were pre-commit autoupdates only. See
[`LEGAL.md`](./LEGAL.md#status-of-hedron-vision-inc) for what we found
out about Hedron Vision Inc. itself and the December 2024 Google DeepMind
move.

| Date         | Upstream event                                                    |
|--------------|-------------------------------------------------------------------|
| 2024-06-28   | [Restore python 3.8 support][upstream-1e08f8e] — last meaningful commit |
| 2024-10-08   | Merge of pre-commit-CI autoupdate ([#225][upstream-pr-225]) — CI-only |
| 2024-12      | Hedron Vision [announces it has "joined Google DeepMind"][hedron-linkedin] (acqui-hire). The corporate shell remains active in California Secretary of State records; the founder moves to Google DeepMind. |
| 2025-08-11   | Merge of pre-commit-CI autoupdate ([#256][upstream-pr-256]) — CI-only |
| 2025–2026    | ~30 open PRs accumulated with no maintainer review                |
| 2026-04      | Bazel 9 lands, removing native `py_binary`/`cc_binary`; the tool stops loading on stock Bazel 9 ([upstream issue #279][upstream-issue-279]) |

### Fork sweep

| Date         | Fork event                                                        |
|--------------|-------------------------------------------------------------------|
| 2023-05-22   | helly25 opens [upstream #122][upstream-pr-122] (custom control args). Sits unreviewed. |
| 2024-08-18   | helly25 opens [upstream #209][upstream-pr-209] (pre-processed header support). Sits unreviewed. |
| 2026-05-17   | Coordinated sweep: 14 PRs opened and merged in [helly25/bazel-compile-commands-extractor][fork], spanning Bazel 9 support, eight bug-fix backports, four feature backports, and the rebased helly25-authored branches |
| 2026-05-17   | Cross-reference comments posted on the corresponding upstream PRs and issues |

After this date, **this fork is the actively-maintained version while
upstream remains inactive**. The upstream remote is still tracked here
as `upstream` and we will fold in any future work that lands there. If
Hedron Vision Inc. reasserts active stewardship at any point, we will
comply with their direction — see the
[goal statement in `LEGAL.md`](./LEGAL.md#goal).

---

## How we did the sweep

1. **Triage.** Enumerated upstream open PRs and issues; sorted them into:
   _critical for viability_ (Bazel 9 loading), _high-value bug fixes_,
   _useful features_, and _too-large / out-of-scope_.

2. **Pick a base when patches compete.** Several upstream PRs addressed
   the same problem. For each, we read the diffs side-by-side and picked
   the cleanest base. Rationale is captured in each backport PR's description:

   - **Bazel 9 loading:** chose [#278][upstream-pr-278] (minimal scope,
     stable `defs.bzl` load paths, ships README docs for WORKSPACE users)
     over [#272][upstream-pr-272] (bundled unrelated header changes; no PR
     description) and [#281][upstream-pr-281] (drive-by reformatting; uses
     newer split load paths that require recent rules releases). The
     header-extension half of #272 was instead routed through the
     pre-processed-header backport.
   - **Header / source-extension expansion:** chose
     [helly25's own #209][upstream-pr-209] (most polished version of the
     same idea) over [#205][upstream-pr-205], [#219][upstream-pr-219],
     [#257][upstream-pr-257], and the header half of #272.
   - **Bazel binary / threads configurability:** chose [#215][upstream-pr-215]
     (superset; also adds `max_threads`) over [#191][upstream-pr-191]
     (just the binary). Reworked slightly so `bazel_command` is a macro
     parameter rather than a `--define BAZEL_COMMAND=...` build var.
   - **Sourceless compile actions:** landed **both** [#274][upstream-pr-274]
     (disables the `parse_headers` feature at the aquery layer; root-cause
     fix) and [#262][upstream-pr-262] (handles a sourceless action
     gracefully if one slips through), as defense in depth.
   - **AttributeError on `_is_relative_to`:** [#237][upstream-pr-237] and
     [#253][upstream-pr-253] were independently submitted identical
     one-line fixes; cross-linked both upstream.

3. **Rebase the helly25-authored branches.** Two long-standing fork branches
   ([`feat/pre_processed_header_support_20240818`][fork-branch-209] and
   [`custom-control-args`][fork-branch-122]) had drifted from upstream
   (one by a year, the other by ~3 years). The latter, viewed naïvely,
   looked like it deleted files (`nvcc_clang_diff.py`, `print_args.cpp`,
   `renovate.json5`, `workspace_setup_transitive*.bzl`) — but those were
   branch-drift artefacts, not intent. We rebased preserving only the
   feature commits.

4. **Extend with new runtime overrides.** The custom-control-args branch
   originally added three `--bcce-*` flags. Once `max_threads`,
   `output_dir`, and `exclude_headers` landed as macro parameters via the
   feature backports, we extended the same pattern to add three more
   runtime flags (`--bcce-threads`, `--bcce-output-dir`,
   `--bcce-exclude-headers`) before merging that PR.

5. **Cross-link.** For every upstream PR we picked up, we posted a comment
   on the original linking to the helly25 backport PR. Same for issues
   that were fixed. Original authorship is preserved in every commit
   message via `Backport of hedronvision/bazel-compile-commands-extractor#N (author)`.

6. **Document the decisions.** For deliberate omissions
   (e.g. no `--bcce-bazel` runtime flag — see the README), we wrote down
   both the reasoning and what reversing the decision would entail, so
   future maintainers don't have to rediscover the trade-off.

---

## What landed in the sweep

All 14 PRs were merged into `main` on 2026-05-17. Each commit message
credits the original author and links the upstream PR.

| helly25 PR | Title | Upstream source |
|---|---|---|
| [#1][pr-1]  | Bazel 9 support: load py_binary/cc_binary from rules_python/rules_cc | [hedronvision#278][upstream-pr-278] (xFile3160); also addresses [#272][upstream-pr-272], [#281][upstream-pr-281], [#235][upstream-pr-235]; fixes upstream issue [#279][upstream-issue-279] |
| [#2][pr-2]  | Pre-processed header support (`.processed` outputs + header source files) | [hedronvision#209][upstream-pr-209] (helly25); supersedes [#205][upstream-pr-205], [#219][upstream-pr-219], [#257][upstream-pr-257], header half of [#272][upstream-pr-272] |
| [#3][pr-3]  | Fix `AttributeError` in `_file_is_in_main_workspace_and_not_external` | [hedronvision#237][upstream-pr-237] (tomboehling) / [#253][upstream-pr-253] (lordadamson) |
| [#4][pr-4]  | Fix `exclude_headers="external"` not filtering cached headers | [hedronvision#277][upstream-pr-277] (chrapkowski-sg) |
| [#5][pr-5]  | Remove `compile_commands.json` before writing (handles symlink case) | [hedronvision#193][upstream-pr-193] (keith); fixes upstream issue [#105][upstream-issue-105] |
| [#6][pr-6]  | Handle aquery env entries with no `value` field | [hedronvision#254][upstream-pr-254] (evanpurcell); fixes upstream issue [#252][upstream-issue-252] |
| [#7][pr-7]  | Skip MASM `.S` compiles on Windows (`ml.exe`/`ml64.exe`) | [hedronvision#261][upstream-pr-261] (zaucy) |
| [#8][pr-8]  | Disable `parse_headers` feature during aquery | [hedronvision#274][upstream-pr-274] (keith) |
| [#9][pr-9]  | Handle sourceless compile actions gracefully | [hedronvision#262][upstream-pr-262] (izashchelkin); fixes upstream issue [#258][upstream-issue-258] |
| [#10][pr-10] | Strip `-c` in `-M` header-dep cmd + `tags=["manual"]` on generated `py_binary` | [hedronvision#276][upstream-pr-276] (srikantharun); fixes upstream issues [#273][upstream-issue-273] and [#255][upstream-issue-255] |
| [#11][pr-11] | Use `ProcessPoolExecutor` instead of `ThreadPoolExecutor` | [hedronvision#250][upstream-pr-250] (ManishPatelKodiak) |
| [#12][pr-12] | Make `bazel` command and worker-thread count configurable | [hedronvision#215][upstream-pr-215] (sthornington); supersedes [#191][upstream-pr-191] |
| [#13][pr-13] | Add `output_dir` parameter to `refresh_compile_commands` | [hedronvision#210][upstream-pr-210] (ilev4ik) |
| [#14][pr-14] | Add `--bcce-color`, `--bcce-compiler`, `--bcce-copt`, `--bcce-threads`, `--bcce-output-dir`, `--bcce-exclude-headers` runtime flags | [hedronvision#122][upstream-pr-122] (helly25), extended with overrides for the macro params landed via #12 and #13 |

The full set of upstream cross-reference comments (one per PR / issue
above, plus comments on the parallel-attempt PRs) is visible on the
upstream repository and accessible via the links in the table.

---

## Future direction

* **Open community contributions.** PRs welcome. The
  [issue tracker](https://github.com/helly25/bazel-compile-commands-extractor/issues)
  is open.
* **Continue cross-linking upstream.** If a fix or feature lands here that
  matches an existing upstream PR or issue, we'll keep posting a comment
  there pointing at our PR, so the lineage stays visible.
* **Re-evaluate upstream activity periodically.** If upstream becomes
  active again, we'll re-sync or hand the work back per the
  [goal statement in `LEGAL.md`](./LEGAL.md#goal); the `upstream` git
  remote is configured for that. Outreach to Hedron Vision Inc. and to
  the founder is tracked in [`LEGAL.md`](./LEGAL.md#outreach).
* **Track open upstream PRs we deferred.** The first sweep deliberately
  skipped a handful of larger or higher-risk changes — Swift support
  ([#96][upstream-pr-96]), file-based filter ([#99][upstream-pr-99]),
  custom output configurations ([#202][upstream-pr-202]), enhanced source
  file detection ([#263][upstream-pr-263]), hermetic Python
  ([#267][upstream-pr-267] / [#268][upstream-pr-268]), startup-flags
  ([#222][upstream-pr-222]), `cc_wrapper` unwrap ([#248][upstream-pr-248]),
  Win32 drive-lowercasing ([#236][upstream-pr-236]), symlink-prefix
  ([#259][upstream-pr-259]), custom JSON output path
  ([#260][upstream-pr-260]). These remain candidates for future sweeps; if
  one is blocking you, please open an issue here.

---

## Stale fork branches

The two long-standing helly25 branches in this repository
(`feat/pre_processed_header_support_20240818` and `custom-control-args`)
were the source material for [PR #2][pr-2] and [PR #14][pr-14]. They are
preserved as-is for historical reference but are no longer the canonical
home of those features — `main` is.

---

[upstream]: https://github.com/hedronvision/bazel-compile-commands-extractor
[fork]: https://github.com/helly25/bazel-compile-commands-extractor
[hedron-linkedin]: https://www.linkedin.com/posts/hedronvision_hedron-vision-has-joined-google-deepmind-activity-7275631303255842818-yQw7

[upstream-1e08f8e]: https://github.com/hedronvision/bazel-compile-commands-extractor/commit/1e08f8e
[upstream-pr-96]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/96
[upstream-pr-99]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/99
[upstream-pr-122]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/122
[upstream-pr-191]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/191
[upstream-pr-193]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/193
[upstream-pr-202]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/202
[upstream-pr-205]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/205
[upstream-pr-209]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/209
[upstream-pr-210]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/210
[upstream-pr-215]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/215
[upstream-pr-219]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/219
[upstream-pr-222]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/222
[upstream-pr-225]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/225
[upstream-pr-235]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/235
[upstream-pr-236]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/236
[upstream-pr-237]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/237
[upstream-pr-248]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/248
[upstream-pr-250]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/250
[upstream-pr-253]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/253
[upstream-pr-254]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/254
[upstream-pr-256]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/256
[upstream-pr-257]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/257
[upstream-pr-259]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/259
[upstream-pr-260]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/260
[upstream-pr-261]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/261
[upstream-pr-262]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/262
[upstream-pr-263]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/263
[upstream-pr-267]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/267
[upstream-pr-268]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/268
[upstream-pr-272]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/272
[upstream-pr-274]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/274
[upstream-pr-276]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/276
[upstream-pr-277]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/277
[upstream-pr-278]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/278
[upstream-pr-281]: https://github.com/hedronvision/bazel-compile-commands-extractor/pull/281

[upstream-issue-105]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/105
[upstream-issue-252]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/252
[upstream-issue-255]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/255
[upstream-issue-258]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/258
[upstream-issue-273]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/273
[upstream-issue-279]: https://github.com/hedronvision/bazel-compile-commands-extractor/issues/279

[fork-branch-209]: https://github.com/helly25/bazel-compile-commands-extractor/tree/feat/pre_processed_header_support_20240818
[fork-branch-122]: https://github.com/helly25/bazel-compile-commands-extractor/tree/custom-control-args

[pr-1]: https://github.com/helly25/bazel-compile-commands-extractor/pull/1
[pr-2]: https://github.com/helly25/bazel-compile-commands-extractor/pull/2
[pr-3]: https://github.com/helly25/bazel-compile-commands-extractor/pull/3
[pr-4]: https://github.com/helly25/bazel-compile-commands-extractor/pull/4
[pr-5]: https://github.com/helly25/bazel-compile-commands-extractor/pull/5
[pr-6]: https://github.com/helly25/bazel-compile-commands-extractor/pull/6
[pr-7]: https://github.com/helly25/bazel-compile-commands-extractor/pull/7
[pr-8]: https://github.com/helly25/bazel-compile-commands-extractor/pull/8
[pr-9]: https://github.com/helly25/bazel-compile-commands-extractor/pull/9
[pr-10]: https://github.com/helly25/bazel-compile-commands-extractor/pull/10
[pr-11]: https://github.com/helly25/bazel-compile-commands-extractor/pull/11
[pr-12]: https://github.com/helly25/bazel-compile-commands-extractor/pull/12
[pr-13]: https://github.com/helly25/bazel-compile-commands-extractor/pull/13
[pr-14]: https://github.com/helly25/bazel-compile-commands-extractor/pull/14
