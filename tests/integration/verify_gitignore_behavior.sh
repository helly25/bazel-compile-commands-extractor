#!/usr/bin/env bash
# Verifies how `bazel run :refresh` treats git's ignore state.
#
# Covers, in order:
#   1. --nobcce-update-gitignore writes nothing into .git at all
#   2. `update_gitignore = False` on the macro does the same (the .bzl plumbing)
#   3. the default adds anchored entries for the output we generate
#   4. re-running adds nothing (idempotent)
#   5. patterns git already ignores are not re-added
#   6. an unwritable .git warns but still produces compile_commands.json
#
# Regression coverage for
# https://github.com/helly25/bazel-compile-commands-extractor/issues/25, where
# (6) used to be an unhandled PermissionError that killed the whole run.
#
# Runs against a throwaway git repository created inside this module, so the
# checkout's own .git is never touched. Removed again on exit.
#
# Kept bash 3.2+ compatible so it runs on stock macOS bash.
set -euo pipefail

readonly EXCLUDE=".git/info/exclude"
readonly HEADER="### Automatically added by Hedron's Bazel Compile Commands Extractor"

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# A nested .git makes this directory its own repository, so `git rev-parse
# --git-common-dir` inside the extractor resolves here rather than to the
# checkout that contains us. That keeps the checkout's ignore state (and any
# ignore rules it sets for tests/integration/) out of the assertions below.
setup_repo() {
  rm -rf .git
  git init -q .
  git config user.email "test@example.com"
  git config user.name "test"
  # Whoever runs this may have a core.excludesFile that already covers
  # `bazel-*` or `.cache/` (a very reasonable thing for a Bazel developer to
  # have). It applies to this throwaway repository too, and the tool correctly
  # skips anything git already ignores, so leaving it in place would make the
  # assertions below depend on the machine. Point it at nothing instead.
  git config core.excludesFile /dev/null
  # `git init` writes a default .git/info/exclude, so "left alone" has to mean
  # "unchanged", not "absent".
  baseline_exclude="$(cat "${EXCLUDE}" 2>/dev/null || true)"
}

assert_exclude_unchanged() {
  local context="$1"
  local current
  current="$(cat "${EXCLUDE}" 2>/dev/null || true)"
  if [[ "${current}" != "${baseline_exclude}" ]]; then
    fail "${context}: modified ${EXCLUDE}, expected it left exactly as git created it."
  fi
}

cleanup() {
  chmod +w "${EXCLUDE}" 2>/dev/null || true
  rm -rf .git .gitignore refresh_output.txt
}
trap cleanup EXIT

refresh() {
  rm -f compile_commands.json
  bazel run "$@"
}

assert_no_bcce_section() {
  local context="$1"
  if [[ -e "${EXCLUDE}" ]] && grep -qF "${HEADER}" "${EXCLUDE}"; then
    fail "${context}: wrote entries into ${EXCLUDE}, expected none."
  fi
}

assert_cdb_produced() {
  local context="$1"
  if [[ ! -s compile_commands.json ]]; then
    fail "${context}: no compile_commands.json produced."
  fi
}

echo "=== 1. --nobcce-update-gitignore leaves git alone ==="
setup_repo
refresh //:refresh -- --nobcce-update-gitignore
assert_no_bcce_section "--nobcce-update-gitignore"
assert_exclude_unchanged "--nobcce-update-gitignore"
assert_cdb_produced "--nobcce-update-gitignore"

echo "=== 2. update_gitignore = False on the macro leaves git alone ==="
setup_repo
refresh //:refresh_no_gitignore
assert_no_bcce_section "update_gitignore = False"
assert_exclude_unchanged "update_gitignore = False"
assert_cdb_produced "update_gitignore = False"

echo "=== 3. the default adds anchored entries ==="
setup_repo
refresh //:refresh
assert_cdb_produced "default"
if [[ ! -e "${EXCLUDE}" ]]; then
  fail "default: ${EXCLUDE} was not created."
else
  for pattern in '/external' '/bazel-*' '/compile_commands.json' '/.cache/'; do
    if ! grep -qxF "${pattern}" "${EXCLUDE}"; then
      fail "default: expected pattern '${pattern}' in ${EXCLUDE}."
    fi
  done
  # The clangd cache entry used to be written unanchored, which ignored every
  # directory of that name anywhere in the repository rather than just ours.
  if grep -qxF '.cache/' "${EXCLUDE}"; then
    fail "default: wrote the unanchored '.cache/' pattern; it should be anchored."
  fi
fi

echo "=== 4. re-running is idempotent ==="
before="$(cat "${EXCLUDE}")"
refresh //:refresh
if [[ "$(cat "${EXCLUDE}")" != "${before}" ]]; then
  fail "second run changed ${EXCLUDE}; expected it to be left as is."
fi

echo "=== 5. patterns git already ignores are not re-added ==="
setup_repo
printf '/external\n/bazel-*\n/compile_commands.json\n/.cache/\n' > .gitignore
refresh //:refresh
assert_no_bcce_section "already ignored via .gitignore"
assert_exclude_unchanged "already ignored via .gitignore"
rm -f .gitignore

echo "=== 6. an unwritable .git warns but does not fail the run ==="
setup_repo
# The file, not the directory: `git init` already created .git/info/exclude, and
# appending to a file that exists needs write permission on the file itself.
touch "${EXCLUDE}"
chmod -w "${EXCLUDE}"
# root ignores the write bits, so the failure this asserts on can't be staged there.
if [[ -w "${EXCLUDE}" ]]; then
  echo "SKIP: ${EXCLUDE} still writable (running as root?); cannot test the unwritable case."
else
  rm -f compile_commands.json
  if ! bazel run //:refresh > refresh_output.txt 2>&1; then
    cat refresh_output.txt >&2
    fail "unwritable .git: the run failed; it should warn and carry on."
  elif ! grep -qF "Skipping the .gitignore update" refresh_output.txt; then
    cat refresh_output.txt >&2
    fail "unwritable .git: expected a warning about skipping the .gitignore update."
  fi
  assert_cdb_produced "unwritable .git"
  rm -f refresh_output.txt
fi
chmod +w "${EXCLUDE}"

if [[ "${failures}" -ne 0 ]]; then
  echo "${failures} check(s) failed." >&2
  exit 1
fi
echo "All gitignore-behavior checks passed."
