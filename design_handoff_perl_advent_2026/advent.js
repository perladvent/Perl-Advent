/* ============================================================================
   Perl Advent Calendar 2026 — optional progressive enhancement
   Adds two things the CSS-only theme can't do on its own:
     1. A manual light/dark toggle (auto → light → dark), remembered per visitor.
     2. A "visited" tick on advent doors you've already opened.
   Date-locking of future days is NOT here — the generator already handles that
   server-side (future cells ship with no <a>, and the calendar rebuilds daily).

   Install: copy this file next to style.css and add ONE line before </body>
   in share/templates/page.mhtml:
       <script src="advent.js" defer></script>
   Pure vanilla JS, no dependencies. Safe to omit — everything degrades cleanly.
   ============================================================================ */
(function () {
  "use strict";
  var root = document.documentElement;
  var THEME_KEY = "pac-theme";      // "auto" | "light" | "dark"
  var VISIT_KEY = "pac-visited";    // JSON array of "YYYY-MM-DD" ids

  /* ---- Theme ------------------------------------------------------------- */
  var order = ["auto", "light", "dark"];
  var label = { auto: "◑ Auto", light: "☀ Light", dark: "☽ Dark" };

  function readTheme() {
    try { return localStorage.getItem(THEME_KEY) || "auto"; } catch (e) { return "auto"; }
  }
  function applyTheme(t) {
    if (t === "auto") root.removeAttribute("data-theme");
    else root.setAttribute("data-theme", t);
  }
  function saveTheme(t) { try { localStorage.setItem(THEME_KEY, t); } catch (e) {} }

  var current = readTheme();
  applyTheme(current);

  function buildToggle() {
    var btn = document.createElement("button");
    btn.id = "pac-theme-toggle";
    btn.type = "button";
    btn.setAttribute("aria-label", "Switch colour theme");
    btn.textContent = label[current];
    btn.addEventListener("click", function () {
      current = order[(order.indexOf(current) + 1) % order.length];
      applyTheme(current);
      saveTheme(current);
      btn.textContent = label[current];
    });
    document.body.appendChild(btn);
  }

  /* ---- Visited doors ----------------------------------------------------- */
  function readVisited() {
    try { return JSON.parse(localStorage.getItem(VISIT_KEY) || "[]"); } catch (e) { return []; }
  }
  function writeVisited(list) {
    try { localStorage.setItem(VISIT_KEY, JSON.stringify(list)); } catch (e) {}
  }
  // "2026-12-17.html" -> "2026-12-17"
  function dateFromHref(href) {
    var m = /(\d{4}-\d{2}-\d{2})\.html$/.exec(href || "");
    return m ? m[1] : null;
  }

  function markCalendar() {
    var visited = readVisited();
    var links = document.querySelectorAll(".calendar td.day.advent a.article");
    Array.prototype.forEach.call(links, function (a) {
      var d = dateFromHref(a.getAttribute("href"));
      if (d && visited.indexOf(d) !== -1) {
        a.parentNode.classList.add("visited");
        if (!a.querySelector(".tick")) {
          var t = document.createElement("span");
          t.className = "tick";
          t.textContent = "✓";
          a.appendChild(t);
        }
      }
      a.addEventListener("click", function () {
        var day = dateFromHref(a.getAttribute("href"));
        if (!day) return;
        var v = readVisited();
        if (v.indexOf(day) === -1) { v.push(day); writeVisited(v); }
      });
    });
  }

  // On an article page, record this day as visited.
  function markCurrentArticle() {
    var d = dateFromHref(location.pathname);
    if (!d) return;
    var v = readVisited();
    if (v.indexOf(d) === -1) { v.push(d); writeVisited(v); }
  }

  /* ---- Copy buttons on code listings ------------------------------------ */
  // The listing's real newlines are <br> inside <code>; textContent drops them,
  // so clone, turn each <br> into "\n", then read the text.
  function codeText(table) {
    var code = table.querySelector("td.code code") || table.querySelector("code");
    if (!code) return "";
    var clone = code.cloneNode(true);
    Array.prototype.forEach.call(clone.querySelectorAll("br"), function (br) {
      br.parentNode.replaceChild(document.createTextNode("\n"), br);
    });
    return clone.textContent.replace(/\s+$/, "");
  }
  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      try {
        var ta = document.createElement("textarea");
        ta.value = text; ta.style.position = "fixed"; ta.style.opacity = "0";
        document.body.appendChild(ta); ta.select();
        var ok = document.execCommand("copy");
        document.body.removeChild(ta);
        ok ? resolve() : reject();
      } catch (e) { reject(e); }
    });
  }
  // The generator brackets each cell's <code> with a leading <br> and a
  // trailing <br>&nbsp;, which render as a blank line above and below. The CSS
  // hides those <br>s, but the stray trailing &nbsp; then collapses onto the
  // last line — in the right-aligned number column it shoves the final number
  // left. Strip the direct-child <br>s and whitespace-only text nodes for good;
  // the real line breaks live INSIDE <code> and are untouched.
  function trimCells(table) {
    Array.prototype.forEach.call(table.querySelectorAll("td"), function (td) {
      Array.prototype.slice.call(td.childNodes).forEach(function (n) {
        if (n.nodeType === 1 && n.tagName === "BR") td.removeChild(n);
        else if (n.nodeType === 3 && !n.nodeValue.replace(/[\s ]/g, "")) {
          td.removeChild(n);
        }
      });
    });
  }
  function addCopyButtons() {
    var tables = document.querySelectorAll("table.code-listing");
    Array.prototype.forEach.call(tables, function (table) {
      if (table.parentNode && table.parentNode.classList.contains("code-block")) return;
      trimCells(table);
      var wrap = document.createElement("div");
      wrap.className = "code-block";
      table.parentNode.insertBefore(wrap, table);
      wrap.appendChild(table);

      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "code-copy";
      btn.setAttribute("aria-label", "Copy code to clipboard");
      btn.textContent = "Copy";
      var reset;
      btn.addEventListener("click", function () {
        copyText(codeText(table)).then(function () {
          btn.textContent = "Copied ✓";
          btn.classList.add("copied");
          clearTimeout(reset);
          reset = setTimeout(function () {
            btn.textContent = "Copy";
            btn.classList.remove("copied");
          }, 1600);
        }, function () {
          btn.textContent = "Press Ctrl+C";
          clearTimeout(reset);
          reset = setTimeout(function () { btn.textContent = "Copy"; }, 1600);
        });
      });
      wrap.appendChild(btn);
    });
  }

  /* ---- Back-to-calendar link (article pages only) ----------------------- */
  function buildBackLink() {
    var home = document.querySelector("#header h1 a");
    var a = document.createElement("a");
    a.id = "pac-back";
    a.href = home ? home.getAttribute("href") : "index.html";
    a.textContent = "← Calendar";
    a.setAttribute("aria-label", "Back to the calendar");
    document.body.appendChild(a);
  }

  // On the first/last article the generator emits the dead direction as bare
  // text (<li class="previous">Previous</li> with no <a>) that links nowhere.
  // A CSS :not(:has(a)) rule is the intent, but its cascade is unreliable next
  // to the positioned .previous/.next rules, so remove the linkless item here.
  function pruneDeadPager() {
    var items = document.querySelectorAll("#pager li");
    Array.prototype.forEach.call(items, function (li) {
      if (!li.querySelector("a")) li.parentNode.removeChild(li);
    });
  }

  function init() {
    buildToggle();
    if (document.querySelector(".calendar")) { markCalendar(); centerDayNumbers(); }
    else { markCurrentArticle(); addCopyButtons(); buildBackLink(); pruneDeadPager(); }
  }

  /* ---- Optical centering -------------------------------------------------- */
  /* CSS centers a digit's advance box, but Bebas Neue's ink isn't centred in
     that box (its "1", "4", "7" sit right of centre). Measure each number's ink
     and nudge it so the visible glyph is centred on the door/sticker. */
  function centerOne(host) {
    if (!host) return;
    var span = host.querySelector(".num");
    if (!span) {
      // Wrap only the digit's text nodes, preserving element children such as
      // the ".tick" visited badge (markCalendar runs before this).
      var digit = "";
      for (var n = host.firstChild; n; ) {
        var next = n.nextSibling;
        if (n.nodeType === 3) { digit += n.nodeValue; host.removeChild(n); }
        n = next;
      }
      digit = digit.trim();
      if (!digit) return;
      span = document.createElement("span");
      span.className = "num";
      span.style.display = "inline-block";
      span.textContent = digit;
      host.insertBefore(span, host.firstChild);
    }
    var text = span.textContent;
    if (!text) return;
    var cs = getComputedStyle(host);
    var ctx = (centerOne._c || (centerOne._c = document.createElement("canvas").getContext("2d")));
    ctx.font = cs.fontWeight + " " + cs.fontSize + " " + cs.fontFamily;
    var m = ctx.measureText(text);
    if (m.actualBoundingBoxLeft == null) return;
    var inkCenter = (-m.actualBoundingBoxLeft + m.actualBoundingBoxRight) / 2;
    var nudge = m.width / 2 - inkCenter;
    if (text === "1") nudge -= 0.05 * parseFloat(cs.fontSize); // lone "1": weight the stem, not the flag
    span.style.transform = "translateX(" + nudge.toFixed(2) + "px)";
  }
  function centerDayNumbers() {
    var run = function () {
      var cells = document.querySelectorAll(".calendar td.day");
      Array.prototype.forEach.call(cells, function (td) {
        centerOne(td.querySelector("a.article") || td);
      });
    };
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(run);
    setTimeout(run, 350);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
