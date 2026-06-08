#!/usr/bin/env bash
# Verifies that a generated compile_commands.json lists the expected source and
# header files. The compile commands (arguments) themselves are intentionally
# not checked -- we only assert the files are present.
#
# Usage: verify_compile_commands.sh [path-to-compile_commands.json]
#   Default path: ./compile_commands.json -- where `bazel run :refresh` writes
#   it (the module root).
#
# Kept bash 3.2+ compatible so it runs on stock macOS bash.
set -euo pipefail

cdb="${1:-compile_commands.json}"

# The test depends on jq; fail loudly (rather than silently passing) if absent.
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required by this test but was not found on PATH." >&2
  exit 1
fi

if [[ ! -s "${cdb}" ]]; then
  echo "ERROR: '${cdb}' is missing or empty. Did 'bazel run :refresh' run first?" >&2
  exit 1
fi

# Files we expect the extractor to have emitted entries for: the binary source,
# the library source, the test source, and the library header (pulled in via the
# extractor's header support).
expected=(greeter.cc greeter_main.cc greeter_test.cc greeter.h)

status=0
for want in "${expected[@]}"; do
  # Match on basename so we don't depend on absolute/relative path layout.
  if jq -e --arg f "${want}" 'any(.[]; (.file | split("/") | last) == $f)' "${cdb}" >/dev/null; then
    echo "OK: ${want} present"
  else
    echo "MISSING: ${want} not found in ${cdb}" >&2
    status=1
  fi
done

if [[ "${status}" -ne 0 ]]; then
  echo "---- 'file' entries present in ${cdb} ----" >&2
  jq -r '.[].file' "${cdb}" | sort -u | sed 's/^/  /' >&2
fi

exit "${status}"
