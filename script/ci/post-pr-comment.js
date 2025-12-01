#!/usr/bin/env node
/**
 * Post or update a PR comment with screenshot information
 *
 * Usage: node script/ci/post-pr-comment.js
 *
 * This script is designed to be called from actions/github-script@v7
 * It expects the following to be available in scope:
 *   - github: GitHub API client
 *   - context: GitHub Action context
 *
 * For standalone testing, set these environment variables:
 *   - GITHUB_TOKEN: GitHub API token
 *   - GITHUB_REPOSITORY: owner/repo
 *   - PR_NUMBER: Pull request number
 *   - RUN_ID: Workflow run ID
 */

const fs = require('fs');
const path = require('path');

async function postPRComment(github, context) {
  // Read screenshot info
  let screenshotInfo = [];
  try {
    screenshotInfo = JSON.parse(fs.readFileSync('screenshots/info.json', 'utf8'));
  } catch (e) {
    console.log('No screenshot info found');
    return;
  }

  if (screenshotInfo.length === 0) {
    console.log('No screenshots were generated');
    return;
  }

  // Get workflow run info for artifact link
  const runId = context.runId;
  const repo = context.repo;
  const artifactUrl = `https://github.com/${repo.owner}/${repo.repo}/actions/runs/${runId}`;

  // Build comment body
  let body = `## 📸 Article Preview Screenshots\n\n`;
  body += `Generated at: ${new Date().toISOString()}\n\n`;

  for (const info of screenshotInfo) {
    body += `### ${info.article}\n\n`;
    body += `**Rendered as:** \`${info.htmlFile}\`\n\n`;
    body += `| View | Resolution | File |\n`;
    body += `|------|------------|------|\n`;
    body += `| 🖥️ Desktop | 1920x1080 | \`${path.basename(info.desktop)}\` |\n`;
    body += `| 📱 Mobile | 375x667 | \`${path.basename(info.mobile)}\` |\n\n`;
    body += `---\n\n`;
  }

  body += `📥 [Download full-resolution screenshots from workflow artifacts](${artifactUrl})\n`;

  // Find and update existing comment or create new one
  const { data: comments } = await github.rest.issues.listComments({
    owner: repo.owner,
    repo: repo.repo,
    issue_number: context.payload.pull_request.number
  });

  const botComment = comments.find(comment =>
    comment.user.type === 'Bot' &&
    comment.body.includes('Article Preview Screenshots')
  );

  if (botComment) {
    await github.rest.issues.updateComment({
      owner: repo.owner,
      repo: repo.repo,
      comment_id: botComment.id,
      body: body
    });
    console.log('Updated existing comment');
  } else {
    await github.rest.issues.createComment({
      owner: repo.owner,
      repo: repo.repo,
      issue_number: context.payload.pull_request.number,
      body: body
    });
    console.log('Created new comment');
  }
}

// Export for use in GitHub Actions
module.exports = postPRComment;
