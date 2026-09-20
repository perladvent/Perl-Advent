// @ts-check
const { defineConfig, devices } = require("@playwright/test");

// The suite drives a real `script/uat-preview.sh` build (out/2026/) served over
// HTTP — advent.js and the relative asset links assume a server root at the year
// directory, so file:// will not do. Build first with `npm run e2e:build`.
const PORT = Number(process.env.PORT || 8126);

module.exports = defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [["github"], ["list"]] : "list",
  use: {
    baseURL: `http://127.0.0.1:${PORT}/2026/`,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
  // Serve the pre-built out/ tree. The build (which needs Perl + advcal) is a
  // separate step so the browser run stays dependency-light.
  webServer: {
    command: `python3 -m http.server ${PORT} --directory out`,
    url: `http://127.0.0.1:${PORT}/2026/index.html`,
    reuseExistingServer: !process.env.CI,
    timeout: 30 * 1000,
  },
});
