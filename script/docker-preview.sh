#!/bin/bash
#
# Container side of `make preview-docker`: build/render, then hand out/ back to
# HOST_UID_GID even when that fails, since the container runs as root and
# root-owned output would break a later host `make site`.
#
# Usage (env: ARTICLE, HOST_UID_GID, PREVIEW_PORT):
#   script/docker-preview.sh --serve   # build the site, render, then serve
#   script/docker-preview.sh           # re-render only (Compose Watch)

set -euo pipefail
cd "$(dirname "$0")/.."

serve=""
[[ "${1:-}" == --serve ]] && serve=1

rc=0
[[ -z "$serve" ]] || bash script/build-site.sh || rc=$?
[[ $rc -ne 0 ]] || bash script/preview-article.sh "$ARTICLE" || rc=$?
if [[ -n "${HOST_UID_GID:-}" ]]; then
    chown -R -- "$HOST_UID_GID" out || echo "warning: could not chown out/" >&2
fi
[[ $rc -eq 0 && -n "$serve" ]] || exit "$rc"
exec http_this out --host 0.0.0.0 --port "$PREVIEW_PORT" --autoindex
