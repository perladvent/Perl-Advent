// End-to-end coverage for the 2026 progressive-enhancement script,
// 2026/share/static/advent.js. The system under test is a real
// `script/uat-preview.sh 2026-12-25` build served from out/2026/ (see
// playwright.config.js). Fixtures open doors 1-6; articles 02-05 carry code
// listings; article 01 has a dead "previous" pager and 06 a dead "next".
//
// Locators prefer role/accessible-name so the specs double as a regression
// check on the buttons' aria-labels.
const { test, expect } = require("@playwright/test");

const THEME_KEY = "pac-theme";
const VISIT_KEY = "pac-visited";

/* ---- Theme toggle -------------------------------------------------------- */
test.describe("theme toggle", () => {
  test("cycles auto -> light -> dark and persists across reload", async ({ page }) => {
    await page.goto("index.html");
    const html = page.locator("html");
    const toggle = page.getByRole("button", { name: "Switch colour theme" });

    // Starts in auto: no data-theme attribute, label shows Auto.
    await expect(toggle).toHaveText(/Auto/);
    expect(await html.getAttribute("data-theme")).toBeNull();

    await toggle.click();
    await expect(html).toHaveAttribute("data-theme", "light");
    await expect(toggle).toHaveText(/Light/);
    expect(await page.evaluate((k) => localStorage.getItem(k), THEME_KEY)).toBe("light");

    await toggle.click();
    await expect(html).toHaveAttribute("data-theme", "dark");
    await expect(toggle).toHaveText(/Dark/);
    expect(await page.evaluate((k) => localStorage.getItem(k), THEME_KEY)).toBe("dark");

    await toggle.click();
    await expect(toggle).toHaveText(/Auto/);
    expect(await html.getAttribute("data-theme")).toBeNull();

    // Persisted choice re-applies on reload.
    await toggle.click(); // back to light
    await page.reload();
    await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
    await expect(page.getByRole("button", { name: "Switch colour theme" })).toHaveText(/Light/);
  });

  test("does not throw when localStorage is blocked", async ({ page }) => {
    // Simulate a browser/profile where storage access throws (private mode with
    // cookies blocked, etc). advent.js wraps every access in try/catch.
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

    await page.goto("index.html");
    const html = page.locator("html");
    const toggle = page.getByRole("button", { name: "Switch colour theme" });

    // Toggle still works visually even though nothing can be persisted.
    await toggle.click();
    await expect(html).toHaveAttribute("data-theme", "light");
    await toggle.click();
    await expect(html).toHaveAttribute("data-theme", "dark");

    expect(errors, `unexpected page errors: ${errors.map(String).join(", ")}`).toHaveLength(0);
  });
});

/* ---- Visited doors ------------------------------------------------------- */
// A visited door's ✓ is appended inside its link, so the link's accessible name
// becomes e.g. "1✓" — role/name locators assert the user-visible outcome and
// catch duplicate ticks (a second ✓ would make the name "1✓✓").
test.describe("visited doors", () => {
  test("renders a single tick on a visited door", async ({ page }) => {
    await page.addInitScript(
      (args) => localStorage.setItem(args.key, JSON.stringify(["2026-12-01"])),
      { key: VISIT_KEY },
    );
    await page.goto("index.html");

    // Exactly one door is ticked, and it is door 1. (The accessible name joins
    // the digit and tick spans with a space, so match "1 ✓" tolerantly.)
    await expect(page.getByRole("link", { name: /✓/ })).toHaveCount(1);
    await expect(page.getByRole("link", { name: /^1\s*✓$/ })).toHaveCount(1);
    // Unvisited neighbour has no tick.
    await expect(page.getByRole("link", { name: "2", exact: true })).toBeVisible();

    // Re-running markCalendar (reload) must not add a second tick.
    await page.reload();
    await expect(page.getByRole("link", { name: /✓/ })).toHaveCount(1);
    await expect(page.getByRole("link", { name: /^1\s*✓$/ })).toHaveCount(1);
  });

  test("clicking a door records it (markCalendar path)", async ({ page }) => {
    // Swallow the anchor's default navigation in a capture-phase listener so the
    // page stays put; advent.js's own (bubbling) click handler still fires and
    // records the day. This isolates markCalendar from markCurrentArticle.
    await page.addInitScript(() => {
      document.addEventListener(
        "click",
        (e) => {
          if (e.target.closest && e.target.closest("a.article")) e.preventDefault();
        },
        true,
      );
    });
    await page.goto("index.html");

    await page.getByRole("link", { name: "2", exact: true }).click();

    await expect
      .poll(() => page.evaluate((k) => localStorage.getItem(k), VISIT_KEY))
      .toBe(JSON.stringify(["2026-12-02"]));
  });

  test("visiting an article page records the day (markCurrentArticle path)", async ({ page }) => {
    await page.goto("2026-12-04.html");
    await expect
      .poll(() => page.evaluate((k) => localStorage.getItem(k), VISIT_KEY))
      .toBe(JSON.stringify(["2026-12-04"]));

    // The recorded day then shows a tick back on the calendar, without dupes.
    await page.goto("index.html");
    await expect(page.getByRole("link", { name: /✓/ })).toHaveCount(1);
    await expect(page.getByRole("link", { name: /^4\s*✓$/ })).toHaveCount(1);
  });
});

/* ---- Copy buttons on code listings -------------------------------------- */
test.describe("copy button", () => {
  test("copies listing text with newlines and trimmed trailing whitespace", async ({ page }) => {
    // Record what gets written so we can assert the text transformation,
    // independent of clipboard read permissions.
    await page.addInitScript(() => {
      window.__copied = null;
      Object.defineProperty(navigator, "clipboard", {
        configurable: true,
        value: {
          writeText: (t) => {
            window.__copied = t;
            return Promise.resolve();
          },
        },
      });
    });
    await page.goto("2026-12-02.html");

    const copy = page.getByRole("button", { name: "Copy code to clipboard" }).first();
    await expect(copy).toHaveText("Copy");
    await copy.click();

    await expect(copy).toHaveText(/Copied/);
    await expect(copy).toHaveClass(/copied/);

    const copied = await page.evaluate(() => window.__copied);
    expect(copied).not.toBeNull();
    expect(copied).toContain("#!/usr/bin/env perl");
    // <br> became real newlines...
    expect(copied.split("\n").length).toBeGreaterThan(1);
    // ...and trailing whitespace was stripped.
    expect(copied).toBe(copied.replace(/\s+$/, ""));

    // Label reverts after the timeout.
    await expect(copy).toHaveText("Copy", { timeout: 3000 });
    await expect(copy).not.toHaveClass(/copied/);
  });

  test("uses the execCommand fallback when the Clipboard API is unavailable", async ({ page }) => {
    // Force the fallback branch (copyText) by removing navigator.clipboard;
    // Chromium otherwise grants clipboard perms and only the primary path runs.
    await page.addInitScript(() => {
      Object.defineProperty(navigator, "clipboard", {
        configurable: true,
        value: undefined,
      });
    });
    await page.goto("2026-12-02.html");

    const copy = page.getByRole("button", { name: "Copy code to clipboard" }).first();
    await copy.click();

    // execCommand('copy') succeeds against the focused textarea, so the label
    // still flips to the success state.
    await expect(copy).toHaveText(/Copied/);
    await expect(copy).toHaveClass(/copied/);
  });
});

/* ---- Line-number gutter (#687) -------------------------------------------- */
test.describe("line-number gutter", () => {
  // All listing pages, so 02/04's single-line blocks cover the 1-line case.
  test("each pre listing gets one aria-hidden gutter numbered 1..N", async ({ page }) => {
    let singleLine = 0;
    for (const day of ["02", "03", "04", "05"]) {
      await page.goto(`2026-12-${day}.html`);
      const listings = await page.evaluate(() =>
        Array.prototype.map.call(document.querySelectorAll("pre > code.code-listing"), (code) => {
          const pre = code.parentNode;
          const gutters = pre.querySelectorAll(".code-gutter");
          return {
            brs: code.querySelectorAll("br").length,
            count: gutters.length,
            text: gutters[0] && gutters[0].textContent,
            hidden: gutters[0] && gutters[0].getAttribute("aria-hidden"),
            select: gutters[0] && getComputedStyle(gutters[0]).userSelect,
            // Same line box for both columns, so equal heights mean aligned rows.
            sameHeight: gutters[0] && Math.abs(gutters[0].offsetHeight - code.offsetHeight) < 2,
          };
        })
      );
      expect(listings.length, `no listings on 2026-12-${day}.html`).toBeGreaterThan(0);
      for (const l of listings) {
        const expected = Array.from({ length: l.brs + 1 }, (_, i) => String(i + 1)).join("\n");
        expect(l, `2026-12-${day}.html`).toEqual({
          brs: l.brs, count: 1, text: expected, hidden: "true", select: "none", sameHeight: true,
        });
        if (l.brs === 0 && l.text === "1") singleLine++;
      }
    }
    expect(singleLine, "no single-line listing in fixtures").toBeGreaterThan(0);
  });

  test("inner code does not compound the panel font-size", async ({ page }) => {
    await page.goto("2026-12-03.html");
    const sizes = await page.evaluate(() => {
      const code = document.querySelector("pre > code.code-listing");
      return [getComputedStyle(code.parentNode).fontSize, getComputedStyle(code).fontSize];
    });
    expect(sizes[1]).toBe(sizes[0]);
  });

  test("gutter stays pinned while a long line scrolls", async ({ page }) => {
    await page.setViewportSize({ width: 400, height: 800 });
    await page.goto("2026-12-03.html");
    const pos = await page.evaluate(() => {
      const pre = Array.prototype.find.call(
        document.querySelectorAll("pre.numbered"),
        (p) => p.scrollWidth > p.clientWidth
      );
      if (!pre) return null;
      pre.scrollLeft = 100;
      return [pre.getBoundingClientRect().left, pre.querySelector(".code-gutter").getBoundingClientRect().left];
    });
    expect(pos, "no horizontally overflowing pre.numbered on 2026-12-03.html at 400px").not.toBeNull();
    expect(Math.abs(pos[1] - pos[0])).toBeLessThan(2);
    // Only the <pre> scrolls; the page itself must not.
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  });

  test("copy copies only the code, not the line numbers", async ({ page }) => {
    await page.addInitScript(() => {
      window.__copied = null;
      Object.defineProperty(navigator, "clipboard", {
        configurable: true,
        value: { writeText: (t) => { window.__copied = t; return Promise.resolve(); } },
      });
    });
    await page.goto("2026-12-03.html");
    await page.getByRole("button", { name: "Copy code to clipboard" }).first().click();
    const copied = await page.evaluate(() => window.__copied);
    const lines = await page.locator("pre .code-gutter").first().textContent();
    expect(copied.split("\n").length).toBe(lines.split("\n").length);
    expect(copied.startsWith("1")).toBe(false);
    expect(copied).toContain("package");
  });
});

/* ---- Dead pager pruning -------------------------------------------------- */
// The dead direction ships as bare, linkless text ("Previous"/"Next"); pruning
// removes the whole item, so a pruned direction leaves neither a link nor its
// text behind. Assertions are scoped to the pager's <nav> landmark.
test.describe("dead pager pruning", () => {
  const pager = (page) => page.getByRole("navigation", { name: "Article navigation" });

  test("first article drops the dead previous item, keeps a working next", async ({ page }) => {
    await page.goto("2026-12-01.html");
    const nav = pager(page);
    await expect(nav.getByText("Previous")).toHaveCount(0);
    await expect(nav.getByRole("link", { name: "Next" })).toHaveCount(1);
  });

  test("last article drops the dead next item, keeps a working previous", async ({ page }) => {
    await page.goto("2026-12-06.html");
    const nav = pager(page);
    await expect(nav.getByText("Next")).toHaveCount(0);
    await expect(nav.getByRole("link", { name: "Previous" })).toHaveCount(1);
  });

  test("middle article keeps both working pager links", async ({ page }) => {
    await page.goto("2026-12-03.html");
    const nav = pager(page);
    await expect(nav.getByRole("link", { name: "Previous" })).toHaveCount(1);
    await expect(nav.getByRole("link", { name: "Next" })).toHaveCount(1);
  });
});

/* ---- Back-to-calendar link ----------------------------------------------- */
test.describe("back-to-calendar link", () => {
  test("article pages get a link back to the calendar", async ({ page }) => {
    await page.goto("2026-12-03.html");
    const back = page.getByRole("link", { name: "Back to the calendar" });
    await expect(back).toBeVisible();
    await expect(back).toHaveAttribute("href", "index.html");
  });

  test("the calendar page does not get a back link", async ({ page }) => {
    await page.goto("index.html");
    await expect(page.getByRole("link", { name: "Back to the calendar" })).toHaveCount(0);
  });
});

/* ---- Optical centering --------------------------------------------------- */
test.describe("optical centering", () => {
  test("day numbers get a translateX transform after fonts load", async ({ page }) => {
    await page.goto("index.html");
    await page.evaluate(() => document.fonts.ready);

    const num = page.locator(".calendar td.day .num").first();
    await expect(num).toHaveCount(1);
    // A non-empty translateX is applied (exact px is font-metric dependent).
    await expect
      .poll(() => num.evaluate((el) => el.style.transform))
      .toMatch(/translateX\(/);
  });
});
