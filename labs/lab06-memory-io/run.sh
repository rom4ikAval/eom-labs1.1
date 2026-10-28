#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
ulimit -c 0
python3 -u run_experiments.py 2>&1 | tee lab06-results.txt
