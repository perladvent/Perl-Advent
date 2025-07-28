#!/bin/bash

set -eux -o pipefail

gh issue edit $1 --add-label "2025,Proposal Accepted"
