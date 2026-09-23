#!/bin/bash
#
# Approve an article proposal issue: label it accepted and post a getting-started
# comment so the author knows the tools at their disposal.
#
# Usage:
#   ./script/approve-article-proposal.sh <issue-number>
# Override the calendar year with the YEAR env var (default 2026); the label
# must already exist.

set -eu -o pipefail

issue=$1
YEAR="${YEAR:-2026}"

gh issue edit "$issue" --add-label "$YEAR,Proposal Accepted"

gh issue comment "$issue" --body "$(cat <<EOF
🎉 Your proposal has been accepted — welcome aboard!

Here's how to get your article written:

1. Fork the repo, then create your article stub (writes to
   \`$YEAR/incoming/your-slug.pod\`):
   \`\`\`
   make new-article
   \`\`\`
2. Write it in POD, and test it as you go:
   \`\`\`
   perl t/article_pod.t $YEAR/incoming/your-slug.pod
   \`\`\`
3. Preview it rendered with the real calendar styling, then open the URL it
   prints (run \`make init\` once first to fetch the build submodules):
   \`\`\`
   make preview ARTICLE=$YEAR/incoming/your-slug.pod
   \`\`\`
4. Open a pull request. Keep pushing to your fork — the PR updates
   automatically.

See the "Authors" section of the README and EDITING.md for more. Questions?
Just ask right here.
EOF
)"
