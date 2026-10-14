// End-to-end coverage for the root welcome page, index.html (copied to out/ by
// script/uat-preview.sh). It is the site root, so it is loaded root-absolute
// here rather than relative to the 2026/ baseURL.
const { test, expect } = require("@playwright/test");

const PAGE = "/index.html";

// Dates are local time because the page reads the local date.
test.describe("welcome page", () => {
  for (const [now, days, digits] of [
    ["2026-02-01T12:00:00", 303, ["3", "0", "3"]],
    ["2026-10-08T00:01:00", 54, ["5", "4"]],
    // Crosses the November DST change in zones that have one.
    ["2026-10-31T23:59:00", 31, ["3", "1"]],
    ["2026-11-30T23:59:00", 1, ["1"]],
  ]) {
    const label = days === 1 ? "1 day" : `${days} days`;
    test(`counts ${label} to December 1 on ${now}`, async ({ page }) => {
      await page.clock.setFixedTime(new Date(now));
      await page.goto(PAGE);
      await expect(page.locator("#doors .door")).toHaveText(digits);
      await expect(page.locator("#countdown")).toHaveText(
        `${label} until the first door opens`
      );
      await expect(page.locator("#latest")).toHaveAttribute("href", "/2025/");
      await expect(page.locator("#latest")).toHaveText("The 2025 calendar");
      await expect(page.locator("#feed")).toHaveAttribute("href", "/2026/atom.xml");
      await expect(page.locator("#feed-alt")).toHaveAttribute("href", "/2026/atom.xml");
      await expect(page.locator(".lede")).toHaveText(
        "Year 27 of The Perl Advent Calendar opens on December 1st."
      );
    });
  }

  for (const [now, year] of [
    ["2026-12-01T00:01:00", 2026],
    ["2027-01-31T23:59:00", 2026],
  ]) {
    test(`redirects to the ${year} calendar on ${now}`, async ({ page }) => {
      await page.clock.setFixedTime(new Date(now));
      await page.goto(PAGE);
      await expect(page).toHaveURL(new RegExp(`/${year}/(index\\.html)?$`));
    });
  }

  // The background is the theme's --paper, so it also proves /2026/style.css
  // loaded: without it the body stays transparent.
  for (const [theme, paper] of [
    ["light", "rgb(251, 247, 239)"],
    ["dark", "rgb(11, 24, 38)"],
  ]) {
    test(`applies a stored ${theme} theme`, async ({ page }) => {
      await page.clock.setFixedTime(new Date("2026-10-08T12:00:00"));
      await page.addInitScript((t) => localStorage.setItem("pac-theme", t), theme);
      await page.goto(PAGE);
      await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
      await expect(page.locator("body")).toHaveCSS("background-color", paper);
    });
  }

  test("does not throw when localStorage is blocked", async ({ page }) => {
    await page.clock.setFixedTime(new Date("2026-10-08T12:00:00"));
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
    await expect(page.locator("#countdown")).toBeVisible();
  });

  test.describe("without JavaScript", () => {
    test.use({ javaScriptEnabled: false });

    test("shows blank locked doors and the archives fallback", async ({ page }) => {
      await page.goto(PAGE);
      await expect(page.locator("#doors .door")).toHaveText(["", ""]);
      await expect(page.locator("#countdown")).toBeHidden();
      const latest = page.locator("#latest");
      await expect(latest).toHaveAttribute("href", "/archives.html");
      await expect(latest).toHaveText("Latest calendar");
      await expect(page.locator(".lede")).toHaveText(
        "The next year of The Perl Advent Calendar opens on December 1st."
      );
    });
  });
});
