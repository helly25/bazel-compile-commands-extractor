#!/usr/bin/env bash
# System test: run the cc_binary through Bazel runfiles and assert it prints the
# expected greeting. The binary's runfiles path is passed as $1, expanded from
# $(rlocationpath :greeter) in the BUILD file.
set -o pipefail

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  { echo >&2 "ERROR: cannot find runfiles library."; exit 1; }
f=
set -e
# --- end runfiles.bash initialization v3 ---

binary="$(rlocation "$1")"
if [[ -z "${binary}" || ! -x "${binary}" ]]; then
  echo "ERROR: could not locate test binary via runfiles: $1" >&2
  exit 1
fi

output="$("${binary}")"
expected="Hello from the integration test binary!"
if [[ "${output}" != *"${expected}"* ]]; then
  echo "FAIL: binary output did not contain the expected string." >&2
  echo "  expected substring: ${expected}" >&2
  echo "  actual output:      ${output}" >&2
  exit 1
fi

echo "OK: binary printed the expected greeting."
