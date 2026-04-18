#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

mkdir -p output/bin

cobc -x -free -I copybooks -o output/bin/FINRECON src/FINRECON.cbl
./output/bin/FINRECON

echo "Ejecución finalizada."
echo "Revisa:"
echo "  output/RESULTS.DAT"
echo "  output/ERRORS.DAT"
echo "  output/REPORT.TXT"
