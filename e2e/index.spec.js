// End-to-end coverage for the root welcome page, index.html (copied to out/ by
// script/uat-preview.sh). It is the site root, so it is loaded root-absolute
// here rather than relative to the 2026/ baseURL.
const { test, expect } = require("@playwright/test");

const PAGE = "/index.html";
const LIGHT_PAPER = "rgb(251, 247, 239)";
const DARK_PAPER = "rgb(11, 24, 38)";

// The page reads the browser's local date. Pin the browser to a zone with a
// DST change and write every instant with that zone's offset, so the dates
// mean the same thing on any runner (EDT is -04:00 until November 1, 2026).
test.use({ timezoneId: "America/New_York" });

const at = (page, iso) => page.clock.setFixedTime(new Date(iso));

test.describe("welcome page", () => {
  for (const [now, days, digits, year] of [
    ["2026-02-01T12:00:00-05:00", 303, ["3", "0", "3"], 2026],
    ["2026-10-08T00:01:00-04:00", 54, ["5", "4"], 2026],
    // The last hour of EDT: counting milliseconds instead of calendar dates
    // would come out a day short here.
    ["2026-10-31T23:59:00-04:00", 31, ["3", "1"], 2026],
    ["2026-11-30T23:59:00-05:00", 1, ["1"], 2026],
    // A later year, so nothing year-dependent can pass by matching the HTML.
    ["2027-02-01T12:00:00-05:00", 303, ["3", "0", "3"], 2027],
  ]) {
    const label = days === 1 ? "1 day" : `${days} days`;
    test(`counts ${label} to December 1 on ${now}`, async ({ page }) => {
      await at(page, now);
      await page.goto(PAGE);
      await expect(page.locator("#doors .door")).toHaveText(digits);
      await expect(page.locator("#countdown")).toHaveText(
        `${label} until the first door opens`
      );
      const latest = page.locator("#latest");
      await expect(latest).toHaveAttribute("href", `/${year - 1}/`);
      await expect(latest).toHaveText(`The ${year - 1} calendar`);
      await expect(page.locator("#feed")).toHaveAttribute("href", `/${year}/atom.xml`);
      await expect(page.locator("#feed-alt")).toHaveAttribute("href", `/${year}/atom.xml`);
      await expect(page.locator(".lede")).toHaveText(
        `Year ${year - 1999} of The Perl Advent Calendar opens on December 1st.`
      );
    });
  }

  for (const [now, year] of [
    ["2026-12-01T00:01:00-05:00", 2026],
    ["2026-12-31T23:59:00-05:00", 2026],
    // January still belongs to the calendar that ran in December.
    ["2027-01-01T00:01:00-05:00", 2026],
    ["2027-01-31T23:59:00-05:00", 2026],
  ]) {
    test(`redirects to the ${year} calendar on ${now}`, async ({ page }) => {
      await at(page, now);
      await page.goto(PAGE);
      await expect(page).toHaveURL(new RegExp(`/${year}/(index\\.html)?$`));
    });
  }

  // The background is the theme's --paper, so it also proves /2026/style.css
  // loaded: the inline fallback only matches the light paper.
  for (const [theme, paper] of [
    ["light", LIGHT_PAPER],
    ["dark", DARK_PAPER],
  ]) {
    test(`applies a stored ${theme} theme`, async ({ page }) => {
      await at(page, "2026-10-08T12:00:00-04:00");
      await page.addInitScript((t) => localStorage.setItem("pac-theme", t), theme);
      await page.goto(PAGE);
      await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
      await expect(page.locator("body")).toHaveCSS("background-color", paper);
    });
  }

  test("a stored light theme beats a dark system setting", async ({ page }) => {
    await at(page, "2026-10-08T12:00:00-04:00");
    await page.emulateMedia({ colorScheme: "dark" });
    await page.addInitScript(() => localStorage.setItem("pac-theme", "light"));
    await page.goto(PAGE);
    await expect(page.locator("body")).toHaveCSS("background-color", LIGHT_PAPER);
  });

  test("ignores an unknown stored theme", async ({ page }) => {
    await at(page, "2026-10-08T12:00:00-04:00");
    await page.emulateMedia({ colorScheme: "dark" });
    await page.addInitScript(() => localStorage.setItem("pac-theme", "sepia"));
    await page.goto(PAGE);
    await expect(page.locator("html")).not.toHaveAttribute("data-theme");
    await expect(page.locator("body")).toHaveCSS("background-color", DARK_PAPER);
  });

  test("does not throw when localStorage is blocked", async ({ page }) => {
    await at(page, "2026-10-08T12:00:00-04:00");
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
    await expect(page.locator("html")).not.toHaveAttribute("data-theme");
    await expect(page.locator("#countdown")).toHaveText("54 days until the first door opens");
  });

  test("fits three doors on a 375px screen", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await at(page, "2026-02-01T12:00:00-05:00");
    await page.goto(PAGE);
    await expect(page.locator("#doors .door")).toHaveCount(3);
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - document.documentElement.clientWidth
    );
    expect(overflow).toBeLessThanOrEqual(0);
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
      await expect(page.locator("#feed")).toHaveAttribute("href", "/2026/atom.xml");
      await expect(page.locator(".lede")).toHaveText(
        "The next year of The Perl Advent Calendar opens on December 1st."
      );
    });
  });
});
