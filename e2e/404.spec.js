// End-to-end coverage for the root 404.html (copied to out/ by
// script/uat-preview.sh). GitHub Pages serves it at the missing path, so it is
// loaded root-absolute here rather than relative to the 2026/ baseURL.
const { test, expect } = require("@playwright/test");

const PAGE = "/404.html";

test.describe("404 page", () => {
  // Dates are local time because the page reads the local month; the cases
  // sit on either side of the December rollover and the New Year.
  for (const [now, year] of [
    ["2026-11-30T23:59:00", 2025],
    ["2026-12-01T00:01:00", 2026],
    ["2026-12-31T23:59:00", 2026],
    ["2027-01-01T00:01:00", 2026],
  ]) {
    test(`points the primary link at the ${year} calendar on ${now}`, async ({ page }) => {
      await page.clock.setFixedTime(new Date(now));
      await page.goto(PAGE);
      const latest = page.locator("#latest");
      await expect(latest).toHaveAttribute("href", `/${year}/`);
      await expect(latest).toHaveText(`The ${year} calendar`);
    });
  }

  // The background is the theme's --paper, so it also proves /2026/style.css
  // loaded: without it the body stays transparent.
  for (const [theme, paper] of [
    ["light", "rgb(251, 247, 239)"],
    ["dark", "rgb(11, 24, 38)"],
  ]) {
    test(`applies a stored ${theme} theme`, async ({ page }) => {
      await page.addInitScript((t) => localStorage.setItem("pac-theme", t), theme);
      await page.goto(PAGE);
      await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
      await expect(page.locator("body")).toHaveCSS("background-color", paper);
    });
  }

  test("follows the system dark preference with no stored theme", async ({ page }) => {
    await page.emulateMedia({ colorScheme: "dark" });
    await page.goto(PAGE);
    expect(await page.locator("html").getAttribute("data-theme")).toBeNull();
    await expect(page.locator("body")).toHaveCSS("background-color", "rgb(11, 24, 38)");
  });

  test("ignores an unknown stored theme", async ({ page }) => {
    await page.addInitScript(() => localStorage.setItem("pac-theme", "auto"));
    await page.goto(PAGE);
    expect(await page.locator("html").getAttribute("data-theme")).toBeNull();
  });

  test("does not throw when localStorage is blocked", async ({ page }) => {
    await page.addInitScript(() => {
      Object.defineProperty(window, "localStorage", {
        configurable: true,
        get() {
          throw new Error("storage blocked");
        },
      });
    });
    const errors = [];
    page.on("pageerror", (e) => errors.push(e));

    await page.goto(PAGE);
    expect(errors).toEqual([]);
    expect(await page.locator("html").getAttribute("data-theme")).toBeNull();
    await expect(page.locator("#latest")).toHaveAttribute("href", /^\/\d{4}\/$/);
  });

  test.describe("without JavaScript", () => {
    test.use({ javaScriptEnabled: false });

    test("keeps the archives fallback for the primary link", async ({ page }) => {
      await page.goto(PAGE);
      const latest = page.locator("#latest");
      await expect(latest).toHaveAttribute("href", "/archives.html");
      await expect(latest).toHaveText("Latest calendar");
    });
  });
});
