#!/bin/bash
# Template test suite (stdlib only — no pytest dependency).
cd "$(dirname "$0")"
python3 -m unittest discover -s tests -v
