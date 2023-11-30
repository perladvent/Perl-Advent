#!/usr/bin/env bash

# If this is December or January, replace the placeholder screen
if [[ $(date +%m) -eq 12 ]] || [[ $(date +%m) -eq 1 ]]; then
  cp in-season.html index.html
fi
