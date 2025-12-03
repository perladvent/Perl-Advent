---
description: Review and edit an article from a pull request
arguments:
  - name: pr_number
    description: Pull request number to review
    required: true
---

# Article Review Workflow

You are helping to review and edit a Perl Advent Calendar article. Follow this workflow step-by-step:

## Step 1: Setup Worktree and Checkout PR

1. Extract the PR number from the command arguments
2. Create a worktree in `.worktrees/review-pr-{NUMBER}`:
   ```bash
   git worktree add .worktrees/review-pr-{NUMBER}
   ```
3. Change to the worktree directory
4. Checkout the PR (this automatically sets up remote tracking to author's fork):
   ```bash
   gh pr checkout {NUMBER}
   ```
5. Verify remote tracking is set correctly:
   ```bash
   git status
   git remote -v
   ```
   Display the current branch name and remote it's tracking so the user knows where pushes will go

## Step 2: Identify the Article

1. Use `gh pr diff {NUMBER}` to find which article file(s) were added or modified
2. Identify the main article file (usually in `YYYY/incoming/*.pod` or `YYYY/articles/*.pod`)
3. Read the article file
4. Display a brief summary:
   - Article title
   - Author
   - Topic/Module
   - File location
   - Word count

## Step 3: Analyze the Article

Perform a comprehensive review checking for:

### Grammar and Style
- Spelling errors
- Grammar issues
- Punctuation problems
- Sentence clarity
- Consistency in terminology

### POD Formatting
- Required headers present (Author, Title, Topic)
- Proper POD syntax
- **Code blocks have syntax highlighting**: Check if code blocks use syntax highlighting. Options include:
  - `=begin perl` / `=end perl` for Perl code blocks
  - Inline vim highlighting with `#!vim <language>` (e.g., `#!vim bash`, `#!vim perl`)
  - Code blocks using vim highlighting must have a 2-space indent
  - Plain indented code without highlighting should be flagged for author review
- Links formatted correctly: Both `L<Module::Name>` and `L<text|url>` (POD) are acceptable
- Headings use correct levels (`=head2`, `=head3`)

### Technical Content
- Code examples are complete and make sense
- Module names are accurate
- Links to documentation are correct
- Christmas theme (if present) is appropriate

### Images
- If images are referenced, check they exist in the correct location
- Image paths are correct
- Alt text is present

## Step 4: Present Issues Interactively

For each issue found:

1. **Show the issue** with context:
   ```
   Issue #N: [Category: Grammar/POD/Style/Technical]

   Current text (line X):
   "original text with problem highlighted"

   Proposed fix:
   "corrected text"

   Reason: Brief explanation of why this change is suggested
   ```

2. **Ask for approval** with options:
   - **Accept** - Apply this fix
   - **Reject** - Skip this fix
   - **Modify** - Let me suggest a different fix
   - **Skip remaining** - Stop reviewing and show summary

3. **Keep track** of accepted/rejected changes

## Step 5: Apply Approved Changes

For each accepted change:
1. Use the Edit tool to apply the fix to the article file
2. Confirm the change was applied successfully

## Step 6: Summary and Next Steps

After reviewing all issues:

1. Show summary:
   - Total issues found: X
   - Changes applied: Y
   - Changes rejected: Z

2. Test the article:
   ```bash
   perl t/article_pod.t {article_file}
   ```

3. If there are changes, show the diff:
   ```bash
   git diff
   ```

4. Offer to commit and push:
   - **Commit and push to author's branch** - Commits changes and pushes directly to the PR author's branch (no new PR needed)
   - **Commit only** - Commits but doesn't push (user can push later)
   - **Show diff again** - Review changes once more
   - **Continue editing** - Make additional manual changes
   - **Discard changes** - Don't commit anything

5. If user chooses to commit and push:
   a. Stage and commit changes with descriptive message following repo conventions:
      ```bash
      git add {article_file}
      git commit -m "Editorial review: fix grammar and POD formatting

      - Fixed spelling/grammar issues
      - Corrected POD formatting
      - [Other specific changes]
      "
      ```
   b. Check if the PR is from a fork by examining the author:
      ```bash
      gh pr view {NUMBER} --json author,headRefName --jq '{author: .author.login, branch: .headRefName}'
      ```
   c. If the PR is from a fork (author is different from repo owner):
      - Add the author's fork as a remote using SSH:
        ```bash
        git remote add {author} git@github.com:{author}/Perl-Advent.git
        ```
      - Push to the author's fork:
        ```bash
        git push {author} {current_branch}:{head_branch}
        ```
      - Example: `git push fleetfootmike fleetfootmike/main:main`
   d. If the PR is from the same repo (not a fork):
      - Push directly:
        ```bash
        git push
        ```
   e. Confirm the PR has been updated with the commit

## Step 7: Cleanup (if requested)

After successful commit/push (or if user wants to clean up):

1. Ask if user wants to remove the worktree
2. If yes:
   ```bash
   cd /Users/olaf/Documents/github/perladvent/Perl-Advent
   git worktree remove .worktrees/review-pr-{NUMBER}
   ```
3. Confirm cleanup is complete

## Important Guidelines

- **Preserve author's voice**: Only fix clear errors, don't rewrite their style
- **Light touch editing**: Per EDITING.md, maintain individuality of articles
- **Respect non-native speakers**: Fix grammar but preserve their unique voice
- **Christmas themes optional**: Don't add or remove festive elements
- **Be interactive**: Always ask before applying changes
- **Test after changes**: Always run the POD test to ensure validity

## Editorial Philosophy

Remember from EDITING.md:
- Light touch to maintain individuality
- Respect for non-native English speakers
- Encourage creativity and festive elements
- Technical accuracy is critical
- Use GitHub PR suggestions for explaining complex edits

Begin the workflow now with PR #{pr_number}.
