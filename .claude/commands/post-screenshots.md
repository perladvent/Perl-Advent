---
description: Take screenshots of incoming articles and post them to the current PR
---

# Post Screenshots to PR

Generate preview screenshots of incoming articles and post them as a comment on the current pull request.

## Workflow

### Step 1: Verify PR Context

1. Get the current branch and PR number:
   ```bash
   git branch --show-current
   gh pr view --json number,headRefName,files
   ```
2. Confirm we're on a PR branch with incoming articles
3. Extract PR number and changed article files

### Step 2: Clean Previous Artifacts

Clean up any previous test runs:
```bash
docker compose down 2>/dev/null || true
rm -rf screenshots out out-host incoming-mappings.json 2>/dev/null || true
```

### Step 3: Build Docker Image

Ensure Docker image is up to date:
```bash
docker compose build
```

### Step 4: Detect Changed Articles

Find changed POD files in the PR:
```bash
gh pr diff {PR_NUMBER} --name-only | grep -E "202[0-9]/(incoming|articles)/.*\.pod$"
```

### Step 5: Build Site with Incoming Articles

Run the build process:
```bash
YEAR=$(date +%Y)
docker compose run --rm perl-advent bash -c "perl script/render-incoming.pl && bash script/build-site.sh --single-year $YEAR --today ${YEAR}-12-25"
```

### Step 6: Copy Build Output to Host

Extract build artifacts from Docker:
```bash
docker compose run --rm perl-advent cp -r /app/out /app/out-host
docker compose run --rm perl-advent cp /app/incoming-mappings.json /app/incoming-mappings-host.json || true
mv out-host out
mv incoming-mappings-host.json incoming-mappings.json 2>/dev/null || true
```

### Step 7: Start Web Server

Start the Docker web server:
```bash
docker compose up -d --no-deps perl-advent-server
```

Wait for server to be ready:
```bash
sleep 3
for i in $(seq 1 10); do
  if curl -s "http://localhost:7007/$YEAR/" > /dev/null; then
    echo "Server ready"
    break
  fi
  sleep 2
done
```

### Step 8: Install Playwright (if needed)

Ensure Playwright is installed:
```bash
if [ ! -d "node_modules/playwright" ]; then
  npm install playwright
fi
npx playwright install chromium --with-deps
```

### Step 9: Take Screenshots

Set environment variables and run screenshot script:
```bash
export CHANGED_FILES="{comma or newline separated list of changed article files}"
export YEAR="{current year}"
export SERVER_PORT=7007
mkdir -p screenshots
node script/ci/take-screenshots.js
```

### Step 10: Upload Screenshots to GitHub

Use GitHub CLI to upload screenshots as PR comment attachments. Since we can't directly embed images in PR comments without uploading them somewhere, we'll:

1. Create a gist with the screenshots
2. Post a PR comment with links to the gist images

Alternative approach: Base64 encode small versions for inline preview.

**Better approach**: Use the GitHub Releases API or create a temporary branch with the images.

**Best approach for this use case**: Upload screenshots as artifacts to a temporary location and reference them in the comment, OR embed them as base64 data URLs if they're reasonably sized.

Let's use the simplest approach: **Create a GitHub Gist with the screenshots and link to them in the PR comment.**

Steps:
```bash
# For each screenshot, upload to a gist
gh gist create screenshots/*.png --public

# Get the gist URL
GIST_URL=$(gh gist list --limit 1 | awk '{print $1}')

# Post PR comment with screenshot info and gist link
gh pr comment {PR_NUMBER} --body "$(cat <<EOF
## 📸 Article Preview Screenshots

Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

{For each article in screenshots/info.json}
### {article name}

**Rendered as:** \`{htmlFile}\`

| View | Resolution | Screenshot |
|------|------------|------------|
| 🖥️ Desktop | 1920x1080 | [View]({gist_url}/desktop.png) |
| 📱 Mobile | 375x667 | [View]({gist_url}/mobile.png) |

---

EOF
)"
```

### Step 11: Cleanup

Stop the Docker server:
```bash
docker compose down
```

### Step 12: Display Summary

Show summary of what was posted:
- Number of articles processed
- Screenshot files generated
- PR comment link
- Gist URL with screenshots

## Important Notes

- **Run from PR branch**: This command must be run from a branch associated with a PR
- **Docker required**: The build process uses Docker Compose
- **Playwright needed**: Node.js and Playwright are required for screenshots
- **GitHub CLI authentication**: Must be authenticated with `gh auth login`
- **Gist creation**: Screenshots will be uploaded to a public gist for embedding in PR

## Error Handling

If any step fails:
1. Show clear error message
2. Stop Docker containers
3. Explain what went wrong and how to fix it
4. Clean up temporary files

## Example Output

```
✅ Found PR #123: Add new article about Module::Name
📸 Taking screenshots of 1 article...
✅ Generated 2 screenshots
📤 Uploaded screenshots to gist: https://gist.github.com/user/abc123
💬 Posted comment to PR #123
🎉 Done! View the PR: https://github.com/owner/repo/pull/123
```

---

Begin the workflow now.
