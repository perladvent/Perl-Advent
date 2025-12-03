#!/usr/bin/env node
/**
 * Take screenshots of article previews
 *
 * Usage: CHANGED_FILES="file1.pod\nfile2.pod" YEAR=2025 node script/ci/take-screenshots.js
 *
 * Environment variables:
 *   CHANGED_FILES - Newline-separated list of changed POD files
 *   YEAR - The year to look for articles in (defaults to current year)
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function takeScreenshots() {
  const changedFilesEnv = process.env.CHANGED_FILES;
  if (!changedFilesEnv) {
    console.log('No CHANGED_FILES environment variable set');
    return [];
  }
  const changedFiles = changedFilesEnv.trim().split('\n').filter(f => f);
  const year = process.env.YEAR || new Date().getFullYear().toString();
  const browser = await chromium.launch();
  const screenshotInfo = [];

  // Load incoming article mappings
  let mappings = {};
  const hasIncomingFiles = changedFiles.some(f => f.includes('incoming'));

  if (hasIncomingFiles) {
    try {
      const mappingData = JSON.parse(fs.readFileSync('incoming-mappings.json', 'utf8'));
      // Convert array to lookup object keyed by incoming file path
      mappings = Object.fromEntries(
        mappingData.map(m => [m.incoming, m.html])
      );
      console.log('Loaded article mappings:', mappings);
    } catch (e) {
      console.error('ERROR: incoming-mappings.json not found but incoming articles detected');
      console.error('This should have been created by render-incoming.pl');
      throw e;
    }
  }

  for (const file of changedFiles) {
    console.log(`Processing: ${file}`);

    let htmlFile;
    const basename = path.basename(file, '.pod');

    if (file.includes('incoming')) {
      // Use the mapping file to find which HTML file this incoming article was rendered to
      if (mappings[file]) {
        htmlFile = mappings[file];
        console.log(`Found HTML file from mapping: ${htmlFile}`);
      } else {
        console.error(`No mapping found for ${file}`);
        console.error('This should not happen - render-incoming.pl should have created the mapping');
      }
    } else if (file.includes('articles')) {
      // For articles, the filename directly maps to HTML
      htmlFile = basename + '.html';
    }

    if (!htmlFile) {
      console.log(`Could not determine HTML file for ${file}, skipping`);
      continue;
    }

    const port = process.env.SERVER_PORT || '8000';
    const url = `http://localhost:${port}/${year}/${htmlFile}`;
    console.log(`Taking screenshots of: ${url}`);

    // Use the basename directly - for date-formatted names like 2025-12-01, keep the date
    // For other names like 'my-article', use as is
    const safeArticleName = (basename || 'article').replace(/[^a-zA-Z0-9-_]/g, '-');

    // Desktop screenshot
    let desktopPath = null;
    const desktopPage = await browser.newPage();
    try {
      await desktopPage.setViewportSize({ width: 1920, height: 1080 });
      await desktopPage.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      await desktopPage.waitForTimeout(1000); // Wait for syntax highlighting
      desktopPath = `screenshots/${safeArticleName}-desktop.png`;
      await desktopPage.screenshot({ path: desktopPath, fullPage: true });
      console.log(`Saved: ${desktopPath}`);
    } catch (err) {
      console.error(`Failed to screenshot desktop view of ${file}: ${err.message}`);
      desktopPath = null;
    } finally {
      await desktopPage.close();
    }

    // Mobile screenshot
    let mobilePath = null;
    const mobilePage = await browser.newPage();
    try {
      await mobilePage.setViewportSize({ width: 375, height: 667 });
      await mobilePage.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      await mobilePage.waitForTimeout(1000); // Wait for syntax highlighting
      mobilePath = `screenshots/${safeArticleName}-mobile.png`;
      await mobilePage.screenshot({ path: mobilePath, fullPage: true });
      console.log(`Saved: ${mobilePath}`);
    } catch (err) {
      console.error(`Failed to screenshot mobile view of ${file}: ${err.message}`);
      mobilePath = null;
    } finally {
      await mobilePage.close();
    }

    // Only add to screenshot info if at least one screenshot succeeded
    if (desktopPath || mobilePath) {
      screenshotInfo.push({
        article: file,
        htmlFile: htmlFile,
        desktop: desktopPath,
        mobile: mobilePath
      });
    }
  }

  await browser.close();

  // Write screenshot info for later steps
  fs.writeFileSync('screenshots/info.json', JSON.stringify(screenshotInfo, null, 2));
  console.log('Screenshot info saved to screenshots/info.json');

  return screenshotInfo;
}

takeScreenshots().catch(err => {
  console.error(err);
  process.exit(1);
});
