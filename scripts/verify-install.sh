#!/usr/bin/env bash
set -euo pipefail

test -f skill/SKILL.md
test -d skill/references
test -d skill/assets
test -d skill/scripts

echo "install layout: OK"
