#!/usr/bin/env bash
# Verifies that a generated compile_commands.json lists the expected source and
# header files. The compile commands (arguments) themselves are intentionally
# not checked -- we only assert the files are present.
#
# Usage: verify_compile_commands.sh [--deduped] [path-to-compile_commands.json]
#   Default path: ./compile_commands.json -- where `bazel run :refresh` writes
#   it (the module root).
#   --deduped: the compile DB was generated with --bcce-prefer-target-config, so
#   additionally require that no file is described more than once.
#
# Kept bash 3.2+ compatible so it runs on stock macOS bash.
set -euo pipefail

mode="default"
if [[ "${1:-}" == "--deduped" ]]; then
  mode="deduped"
  shift
fi

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
expected=(
  greeter.cc greeter_main.cc greeter_test.cc greeter.h
  # Compiled in both configurations (target via greeter_lib/uses_generated,
  # exec via the generator tool).
  shared.cc shared.h
  generated.cc
  # Compiled ONLY in the exec configuration, via the generator tool. Present in
  # both modes: --bcce-prefer-target-config keeps exec-only files.
  toolonly.cc toolonly.h
  uses_generated.cc
)

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

# Counts entries for a basename whose command does/doesn't come from the exec
# configuration. Exec-configuration outputs live under bazel-out/<...>-exec<...>/.
count_entries() { # <basename> <exec|target>
  local select='test("bazel-out/[^ ]*-exec")'
  [[ "${2}" == "target" ]] && select="(${select} | not)"
  jq -r --arg f "${1}" \
    "[.[] | select((.file | split(\"/\") | last) == \$f) | select((.arguments | join(\" \")) | ${select})] | length" \
    "${cdb}"
}

# The contract of --bcce-prefer-target-config: a file compiled in BOTH
# configurations keeps only its target-configuration command, while a file
# compiled ONLY in the exec configuration keeps that command. Note this is
# deliberately not "every file appears once" -- the extractor emits one entry per
# analyzed target root, so shared.cc legitimately still has several
# target-configuration entries here.
shared_exec="$(count_entries shared.cc exec)"
shared_target="$(count_entries shared.cc target)"
toolonly_exec="$(count_entries toolonly.cc exec)"
generated_exec="$(count_entries generated.cc exec)"
generated_target="$(count_entries generated.cc target)"

if [[ "${mode}" == "deduped" ]]; then
  if [[ "${shared_exec}" -ne 0 ]]; then
    echo "ERROR: shared.cc still has ${shared_exec} exec-configuration entries; --bcce-prefer-target-config should have dropped them." >&2
    status=1
  else
    echo "OK: shared.cc has no exec-configuration entries (${shared_target} target ones remain)"
  fi
  if [[ "${toolonly_exec}" -lt 1 ]]; then
    echo "ERROR: toolonly.cc lost its exec-configuration entry; exec-ONLY files must be kept." >&2
    status=1
  else
    echo "OK: toolonly.cc kept its exec-configuration entry (exec-only files are preserved)"
  fi
  if [[ "${generated_exec}" -ne 0 || "${generated_target}" -lt 1 ]]; then
    echo "ERROR: expected generated.cc only in the target configuration; got ${generated_target} target / ${generated_exec} exec." >&2
    status=1
  else
    echo "OK: generated.cc keeps only its target-configuration entry"
  fi
else
  # Guard the inverse, so a silent change to the default -- or a fixture that
  # stopped producing exec-configuration actions, which would make the --deduped
  # run vacuous -- cannot pass unnoticed.
  if [[ "${shared_exec}" -lt 1 || "${shared_target}" -lt 1 ]]; then
    echo "ERROR: expected shared.cc in BOTH configurations by default; got ${shared_target} target / ${shared_exec} exec." >&2
    echo "       Without that the --deduped check proves nothing." >&2
    status=1
  else
    echo "OK: shared.cc present in both configurations (${shared_target} target / ${shared_exec} exec)"
  fi
fi

exit "${status}"
