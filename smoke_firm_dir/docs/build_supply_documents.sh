#!/usr/bin/env bash
# Rebuild both editable supply notes; retain existing PDFs if compilation fails.
set -euo pipefail
cd "$(dirname "$0")"
supply_build_dir=$(mktemp -d "${TMPDIR:-/tmp}/supply-docs.XXXXXX")
trap 'rm -rf "$supply_build_dir"' EXIT
for supply_doc in ec_supply_conference_model ec_supply_solution_appendix; do
  for supply_pass in 1 2; do
    xelatex -interaction=nonstopmode -halt-on-error \
      -output-directory="$supply_build_dir" "$supply_doc.tex" \
      > "$supply_build_dir/$supply_doc-build.log" 2>&1 || {
        cat "$supply_build_dir/$supply_doc-build.log"
        exit 1
      }
  done
done
for supply_doc in ec_supply_conference_model ec_supply_solution_appendix; do
  cp "$supply_build_dir/$supply_doc.pdf" "$supply_doc.pdf"
  printf 'Built %s.pdf\n' "$supply_doc"
done
