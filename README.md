# Bazel Compile Commands Extractor

> **This is the [helly25](https://github.com/helly25/bazel-compile-commands-extractor) fork.**
> The original [hedronvision/bazel-compile-commands-extractor](https://github.com/hedronvision/bazel-compile-commands-extractor)
> repository has had no non-CI commit since 2024-06-28
> (the founding team [joined Google DeepMind][gdm] in December 2024), and
> tooling on current Bazel (9.x) stopped working out of the box. This
> fork is the actively maintained version while upstream remains
> inactive.
>
> * [`FORK.md`](./FORK.md) — timeline, triage / decision log of the first sweep, list of backported upstream PRs and issues
> * [`LEGAL.md`](./LEGAL.md) — licensing context, status of Hedron Vision Inc., and the explicit commitment we make about handing the project back if Hedron reasserts stewardship
> * [`LICENSE.md`](./LICENSE.md) — original license (unchanged; controls)
>
> [gdm]: https://www.linkedin.com/posts/hedronvision_hedron-vision-has-joined-google-deepmind-activity-7275631303255842818-yQw7

## What this is

A Bazel-aware extractor that produces a standard
[`compile_commands.json`](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
describing every C-language-family compile action in your workspace. With
that file in place, build-system-agnostic tooling — `clangd`,
`clang-tidy`, IDE plugins — works the same as it would on a CMake or
Make project.

Concretely, you get:

- Cross-platform autocomplete, jump-to-definition, smart rename, and
  live diagnostics for C, C++, Objective-C, Objective-C++, and CUDA via
  `clangd`.
- `clang-tidy` runs that reflect your real Bazel build commands.
- Anything else that consumes the `compile_commands.json` spec.

The commands are *de-Bazelized*: they can be run directly from the
workspace root without any Bazel-specific environment or wrappers, which
is what makes tools like `clangd` understand them.

## Usage visuals

![Usage Animation](https://user-images.githubusercontent.com/7157583/142501309-862e89e2-02b4-4b61-950c-8b7e1bfd7eb7.gif)

▲ Extracts `compile_commands.json`, enabling [`clangd` autocomplete](https://github.com/clangd/vscode-clangd) in your editor ▼

![clangd help example](https://user-images.githubusercontent.com/7157583/142502357-af9ba056-f9e0-47ce-b69d-57e85dcca458.png)

## Requirements

- **Bazel 6.0+**, with **Bazel 9 supported** (see [`FORK.md`](./FORK.md) for the Bazel 9 backport).
- **Python 3.8+** on the host that runs the refresh.
- **`clangd`** (latest recommended) for editor integration.
- **OS:** Linux, macOS, and Windows are all in active use.

## Status

Actively maintained as a fork. We use this tool ourselves daily and run
it across Linux, macOS, and Windows. See [`FORK.md`](./FORK.md) for the
backstory and the list of upstream PRs we landed in the first sweep,
and [`LEGAL.md`](./LEGAL.md) for the licensing context.

## Quick start

If you have a small-to-medium Bazel project and just want autocomplete
in your editor:

1. Add the dependency — one block in `MODULE.bazel` *or* `WORKSPACE`
   (full snippets below).
2. From your workspace root: `bazel run @hedron_compile_commands//:refresh_all`.
3. Open your editor; `clangd` will pick up `compile_commands.json`
   automatically.

Re-run step 2 whenever you change `BUILD`/`BUILD.bazel`/`*.bzl` files.

For larger or more configured projects, see [Run the extractor](#run-the-extractor) below.

---

## Setup

> Basic setup time: ~10 minutes including the editor configuration.

### Add this tool to your Bazel setup

#### bzlmod (`MODULE.bazel`) — recommended

```Starlark
# Bazel Compile Commands Extractor (helly25 fork; see FORK.md for context)
# https://github.com/helly25/bazel-compile-commands-extractor
bazel_dep(name = "hedron_compile_commands", dev_dependency = True)  # Bazel module name kept for backwards compat with existing consumers.
git_override(
    module_name = "hedron_compile_commands",
    remote = "https://github.com/helly25/bazel-compile-commands-extractor.git",
    commit = "0e990032f3c5a866e72615cf67e5ce22186dcb97",
    # Replace the commit hash with the latest from
    # https://github.com/helly25/bazel-compile-commands-extractor/commits/main
    # (or set up Renovate; see below).
)
```

#### Traditional `WORKSPACE`

Put this near the top of your `WORKSPACE` to prevent other tools from
clobbering its dependencies with older versions:

```Starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


# Bazel 9 removed the native `py_binary` and `cc_binary` rules, so WORKSPACE
# users must bring in `rules_python` and `rules_cc` explicitly. If you
# already depend on these via other rules, you can omit this block.
# bzlmod (MODULE.bazel) users do not need this; the deps are declared in
# `bazel_dep()` calls inside this module.
http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/2.0.1/rules_python-2.0.1.tar.gz",
    # sha256 = "...",  # First run will print the canonical sha256 to use here.
)
http_archive(
    name = "rules_cc",
    url = "https://github.com/bazelbuild/rules_cc/releases/download/0.2.18/rules_cc-0.2.18.tar.gz",
    # sha256 = "...",
)


# Bazel Compile Commands Extractor (helly25 fork; see FORK.md for context)
# https://github.com/helly25/bazel-compile-commands-extractor
http_archive(
    name = "hedron_compile_commands",  # external repo name kept for backwards compat
    url = "https://github.com/helly25/bazel-compile-commands-extractor/archive/0e990032f3c5a866e72615cf67e5ce22186dcb97.tar.gz",
    strip_prefix = "bazel-compile-commands-extractor-0e990032f3c5a866e72615cf67e5ce22186dcb97",
    # Replace the commit hash with the latest from
    # https://github.com/helly25/bazel-compile-commands-extractor/commits/main
    # (or set up Renovate; see below).
    # The first run prints a canonical sha256 to fill in here.
)
load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")
hedron_compile_commands_setup()
load("@hedron_compile_commands//:workspace_setup_transitive.bzl", "hedron_compile_commands_setup_transitive")
hedron_compile_commands_setup_transitive()
load("@hedron_compile_commands//:workspace_setup_transitive_transitive.bzl", "hedron_compile_commands_setup_transitive_transitive")
hedron_compile_commands_setup_transitive_transitive()
load("@hedron_compile_commands//:workspace_setup_transitive_transitive_transitive.bzl", "hedron_compile_commands_setup_transitive_transitive_transitive")
hedron_compile_commands_setup_transitive_transitive_transitive()
```

#### Stay up-to-date with Renovate

We live at head — the latest `main` commit is the one you want. We
recommend [Renovate](https://github.com/renovatebot/renovate) (or
similar) to bump the pinned commit automatically. See Renovate's docs
for setup; the bazel `git_override` / `http_archive` shapes above are
both standard, supported patterns.

### Run the extractor

The extractor produces `compile_commands.json` in your workspace root.
Re-run it whenever you change `BUILD`/`BUILD.bazel`/`*.bzl` files;
`clangd` will pick up the new commands automatically.

> You must use `bazel run`, not `bazel build`; the tool executes a
> Python script that shells out to `bazel aquery`.

Pick the path that matches your project:

#### Path 1 — Simple codebase, no extra flags

```shell
bazel run @hedron_compile_commands//:refresh_all
```

#### Path 2 — Your everyday builds need extra flags

If you typically build with `--config=…` or `--compilation_mode=…`, the
extractor needs the same flags so it can see the build accurately.
Append them after `--`:

```shell
bazel run @hedron_compile_commands//:refresh_all -- --config=my_flags --compilation_mode=dbg
```

The `--` separator is required; it routes the flags to the extractor's
`bazel aquery`, not to the outer `bazel run`.

#### Path 3 — Specific targets, or per-target flags

Useful when some targets can't be built standalone (e.g. an
`android_library` configured by an `android_binary`), or when different
targets need different flags. Add this to a `BUILD` file in your
workspace (we recommend `//BUILD`):

```Starlark
load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")

refresh_compile_commands(
    name = "refresh_compile_commands",

    # Targets you actively work on. Flags already in `.bazelrc` are
    # picked up automatically.
    targets = {
        "//:my_output_1": "--important_flag1 --important_flag2=true",
        "//:my_output_2": "",
    },
    # A list of targets is fine if you don't need per-target flags.
    # A single string is fine for one target. Wildcards (`//...`) work,
    # as do `+` / `-` set expressions (see `bazel query`).
    # For a header-only library, pass a test or binary that compiles it.
)
```

Then:

```shell
bazel run :refresh_compile_commands
```

For all `refresh_compile_commands` options, see the macro docs at the
top of [`refresh_compile_commands.bzl`](./refresh_compile_commands.bzl).

#### Path 4 — `ccls` or other consumers that don't want headers

Same as Path 3, but set `exclude_headers = "all"` on the macro target.

### Large projects: speeding things up

If `compile_commands.json` generation gets slow, the following macro
parameters trade completeness for speed:

- `exclude_external_sources = True` — skip compile entries for external
  workspaces entirely.
- `exclude_headers = "external"` — keep main-workspace headers, drop
  external/system headers.

Get the basic setup working first, then tune. Details in
[`refresh_compile_commands.bzl`](./refresh_compile_commands.bzl).

### Runtime flags (`--bcce-*`)

Pass any of these after `--` on `bazel run`. They override the
corresponding macro parameter for a single run. Precedence:
**runtime flag > macro param > default**.

| Flag | Effect |
|---|---|
| `--bcce-color=auto\|yes\|no` (or `--nobcce-color`) | Colored output. `auto` consults TTY + `NO_COLOR` / `TERM`. |
| `--bcce-compiler=<path>` | Override the detected compiler. |
| `--bcce-copt=<flag>` | Append an extra option to every compile command (repeatable). |
| `--bcce-threads=<N>` | Worker-pool size for one run. |
| `--bcce-output-dir=<dir>` | Write `compile_commands.json` into a different directory. |
| `--bcce-exclude-headers=all\|external\|none` | Override `exclude_headers`. `none` (or empty) restores the macro default. |

Notes:

- **`--bcce-compiler`** and **`--bcce-copt`** can also be configured on
  the `clangd` side via [compileflags](https://clangd.llvm.org/config#compileflags).
  Use whichever fits your workflow.
- **`--bcce-color`** is helpful where the consuming terminal doesn't
  handle ANSI (the VSCode OUTPUT panel, for example).

Example — suppress colored output:

```shell
bazel run @hedron_compile_commands//:refresh_all -- --bcce-color=no
```

<details>
<summary>Why isn't there a <code>--bcce-bazel</code> runtime flag?</summary>

The `bazel_command` macro parameter (added by
[#12](https://github.com/helly25/bazel-compile-commands-extractor/pull/12),
which backports
[hedronvision#215](https://github.com/hedronvision/bazel-compile-commands-extractor/pull/215))
is intentionally **macro-only**, with no `--bcce-bazel` runtime
equivalent:

- Bazel version selection is already handled by
  [bazelisk](https://github.com/bazelbuild/bazelisk) + `.bazelversion`;
  an extractor-level override would only muddy that contract.
- The script is invoked via `bazel run`, so the outer Bazel is already
  fixed at invocation time. A runtime flag that controls which `bazel`
  the extractor's *inner* subprocesses (`bazel version`, `bazel aquery`,
  `bazel dump --action_cache`) shell out to invites confusion about
  which binary actually ran.
- The macro param already covers the legitimate cases (wrapper scripts,
  alternative binary names in CI sandboxes).

If you hit a use case that needs a runtime override here, please open
an issue. Reversing this decision is small and additive: in
`refresh.template.py`, change `_bazel()` to consult
`_get_last_arg('bcce-bazel')` first (mirroring `_threads()` /
`_output_dir()` / `_exclude_headers()`); document the flag in the table
above; no `.bzl` changes needed. The deliberate omission is also
recorded as a comment next to `bazel_command` in
[`refresh_compile_commands.bzl`](./refresh_compile_commands.bzl).

</details>

---

## Editor setup

### VSCode

Install the `clangd` extension and make sure Microsoft's C++ extension
isn't interfering:

```shell
code --install-extension llvm-vs-code-extensions.vscode-clangd
code --uninstall-extension ms-vscode.cpptools
```

Open VSCode **user** settings, search for `clangd`, and add these three
entries to `clangd.arguments`:

```text
--header-insertion=never
--compile-commands-dir=${workspaceFolder}/
--query-driver=**
```

What they do:

- `--header-insertion=never` turns off (often-overzealous) auto header
  inserts.
- `--compile-commands-dir=${workspaceFolder}/` keeps `clangd` finding
  the commands even when you're browsing system headers outside the
  source tree.
- `--query-driver=**` lets `clangd` interrogate Bazel's compiler
  wrappers to discover their default include paths.

If your `WORKSPACE` is in a subdirectory of the VSCode project, override
`--compile-commands-dir` in your **workspace** settings to point at
that subdirectory. (Workspace settings replace user settings here, so
re-specify all three flags when you override.)

Enable **Clangd: Check Updates** and prefer the latest `clangd`. We
remove workarounds as `clangd` upstream fixes the underlying issues, so
running an old `clangd` (including the Apple Xcode build) will
gradually drift out of compatibility.

If `clangd` doesn't prompt you to download the server binary, run
`Cmd/Ctrl+Shift+P → Download language server`. You may need to reload
the window once it finishes.

#### Share settings with your team

Add the same settings to your VSCode **workspace** settings and check
`.vscode/settings.json` into source control.

#### Auto-refresh `compile_commands.json` on save

The [Run on Save](https://github.com/emeraldwalk/vscode-runonsave)
extension can re-run the extractor whenever a Bazel file changes:

```json
{
    "emeraldwalk.runonsave": {
        "commands": [
            {
                "match": "(WORKSPACE|BUILD|.*[.]bzl|.*[.]bazel)$",
                "isAsync": true,
                "cmd": "bazel run @hedron_compile_commands//:refresh_all"
            }
        ]
    }
}
```

You only need to refresh on Bazel-file changes — `clangd` re-reads
`compile_commands.json` automatically.

### Other editors

The general recipe is the same: install
[a recent `clangd`](https://clangd.llvm.org/installation.html#editor-plugins)
for your editor and pass it the three flags above
(`--header-insertion=never`, `--compile-commands-dir=…`,
`--query-driver=**`). Folks have reported successful setups with Emacs,
Vim/Neovim with YouCompleteMe or coc, and JetBrains IDEs. PRs
documenting the exact configuration for another editor are welcome.

---

## What works well

- Cross-platform development out of the box: in our daily use we get
  Android completion in Android source, macOS in macOS, iOS in iOS,
  etc. Linux and Windows users have similar reports.
- All the usual `clangd` features: navigation (`Cmd/Ctrl`-click or
  `option`-click), smart rename, autocomplete, diagnostics, highlights.
- Generated files work too, **provided** the file actually exists on
  disk. With a remote-cache / remote-execution setup you'll likely need
  `--remote_download_regex` (and/or `--remote_download_outputs`) to
  pull headers and source files locally — "build without the bytes" is
  Bazel's default now and clangd needs the bytes.
- `.d` dependency files speed up header discovery significantly when
  they're cached locally. On non-Windows, double-check that they're
  being downloaded; passing `--noexperimental_inmemory_dotd_files` will
  force them to disk if you need to.

If you make these patterns work for a setup we haven't documented, a
short PR or issue update is very welcome.

## Known limitations

The biggest known rough edges are tracked in the
[issue tracker](https://github.com/helly25/bazel-compile-commands-extractor/issues).
Please add to it when you find new ones, and let us know if you need
help or an additional feature.

If you've set things up and it's working well, we'd also love to hear
about it (a quick issue, a star, or a PR documenting your editor
configuration all help future users find the tool).

---

## Contributing

Development setup is straightforward — see
[`ImplementationReadme.md`](./ImplementationReadme.md). The codebase is
small and friendly; jumping in is an efficient way to get whatever
improvement you need landed.

If you spot a fix that should also live upstream
(hedronvision/bazel-compile-commands-extractor), please cross-link your
PR there as well; we keep the lineage visible (see
[`FORK.md`](./FORK.md#how-we-did-the-sweep)).
