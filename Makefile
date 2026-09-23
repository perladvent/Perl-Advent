.PHONY: help init hooks new-article uat uat-serve uat-serve-tailnet archives site e2e e2e-build preview preview-build preview-tailnet

# Running `make` with no target prints this help. Each target's one-line
# summary is the `## ...` text on its rule line below, so the list stays in
# sync with the targets automatically.
.DEFAULT_GOAL := help

help: ## Show this help
	@printf 'Perl Advent Calendar — make targets\n\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## /{printf "  make %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf '\nOverridable variables (make <target> VAR=value):\n'
	@printf '  %-24s %s\n' 'DAY=$(DAY)' 'day the 2026 UAT preview simulates'
	@printf '  %-24s %s\n' 'PORT=$(PORT)' 'port for uat-serve / uat-serve-tailnet'
	@printf '  %-24s %s\n' 'BIND=$(BIND)' 'address uat-serve binds to (0.0.0.0 = all interfaces)'
	@printf '  %-24s %s\n' 'SINGLE_YEAR=YYYY' 'limit `make site` to one year'
	@printf '  %-24s %s\n' 'TODAY=YYYY-MM-DD' 'simulate a date for `make site`'
	@printf '  %-24s %s\n' 'E2E_PORT=$(E2E_PORT)' 'port for the Playwright e2e run'
	@printf '  %-24s %s\n' 'ARTICLE=path.pod' 'article for `make preview` (required)'
	@printf '  %-24s %s\n' 'PREVIEW_PORT=$(PREVIEW_PORT)' 'port for `make preview`'
	@printf '  %-24s %s\n' 'PREVIEW_HOST=IP' 'bind `make preview` beyond loopback (e.g. tailnet IP)'

# Initialize and update git submodules.
# Handy for linked worktrees, which don't get submodules populated automatically.
init: ## Fetch/update git submodules (run once in a fresh worktree)
	git submodule update --init --recursive

# Opt-in: install the precious lint pre-commit hook. Not needed to write or
# submit an article — only useful if you run `precious` locally and want it to
# check staged files before each commit. Requires `precious` on your PATH.
hooks: ## Install the precious lint pre-commit hook (optional; needs precious)
	./scripts/pre-commit --init

# --- Authoring --------------------------------------------------------------
# Scaffold a new article stub under YEAR/incoming/. Prompts for anything you
# don't pass; all fields are overridable:
#   make new-article                                 # fully interactive
#   make new-article YEAR=2026 TITLE='Foo::Bar' TOPIC='Foo::Bar'
new-article: init ## Create a new article stub in incoming/ (override YEAR=/TITLE=/TOPIC=/AUTHOR=)
	perl script/new_article \
	  $(if $(YEAR),--year '$(YEAR)') \
	  $(if $(TITLE),--title '$(TITLE)') \
	  $(if $(TOPIC),--topic '$(TOPIC)') \
	  $(if $(AUTHOR),--author '$(AUTHOR)')

# --- 2026 UAT preview -------------------------------------------------------
# Two steps: build the fixture site, then serve it. Override DAY/PORT/BIND:
#   make uat                    # build out/2026 (simulated 2026-12-06)
#   make uat DAY=2026-12-02     # build simulating a different day
#   make uat-serve              # serve out/ on 127.0.0.1:8026 (Ctrl-C to stop)
#   make uat-serve PORT=8080    # serve on a different port
#   make uat-serve BIND=0.0.0.0 # serve on every interface (e.g. LAN access)
#   make uat-serve-tailnet      # serve bound to this host's Tailscale IP only
# Then open http://127.0.0.1:$(PORT)/2026/ . Rebuild with `make uat` while the
# server keeps running and just refresh the browser.
DAY  ?= 2026-12-06
PORT ?= 8026
BIND ?= 127.0.0.1

uat: ## Build the 2026 UAT fixture site into out/2026 (override DAY=)
	./script/uat-preview.sh $(DAY)

uat-serve: ## Serve out/ over HTTP (override PORT= / BIND=)
	cd out && python3 -m http.server $(PORT) --bind $(BIND)

# Serve on the tailnet only: bind to this machine's own Tailscale IP so the
# site is reachable from other tailnet devices (by IP or MagicDNS name) but
# not from the wider LAN. Requires Tailscale to be installed and `up`.
uat-serve-tailnet: ## Serve out/ bound to this host's Tailscale IP (tailnet only)
	@ip=$$(tailscale ip -4 2>/dev/null | head -n1); \
	test -n "$$ip" || { echo "No Tailscale IPv4 address found — is 'tailscale up' running?" >&2; exit 1; }; \
	echo "Serving out/ on http://$$ip:$(PORT)/ (reachable on your tailnet)"; \
	cd out && python3 -m http.server $(PORT) --bind "$$ip"

# --- Archives-only rebuild (fast UAT loop) ----------------------------------
# Regenerate just the four archives pages (archives.html / archives-AZ.html /
# archives-Yd.html / archives-author.html) from archives.yaml, without the full
# per-year advcal build. mkarchives runs on plain host Perl, so this is quick —
# ideal while iterating on archives.yaml or mkarchives during UAT. Writes into
# an existing out/ (created if missing); the year pages under out/ are left
# untouched. Reload the page in the browser afterwards.
archives: ## Rebuild only the archives pages into out/ (fast UAT loop)
	@mkdir -p out
	perl mkarchives out
	@echo "Regenerated out/archives*.html — reload http://127.0.0.1:$(PORT)/archives-author.html"

# --- Full site build (all years) — UAT the archives pages -------------------
# Builds the ENTIRE site into out/ via script/build-site.sh, which runs
# mkarchives (regenerating archives.html / archives-AZ.html / archives-Yd.html /
# archives-author.html) and then advcal for every year. The host's stock
# `advcal` lacks the fork's --https flag, so this target puts the inc/ fork
# (bin + lib) in front of the build — the same fork `make uat` uses. Requires
# submodules (run `make init` first in a fresh worktree).
#   make site                     # build every year into out/
#   make site TODAY=2025-12-25     # simulate a date (opens that year's doors)
#   make site SINGLE_YEAR=2025     # limit the per-year render to one year
# Then serve with `make uat-serve` (or `make uat-serve-tailnet`) and open
#   http://127.0.0.1:$(PORT)/archives-author.html
FORK := inc/WWW-AdventCalendar

site: ## Build the whole site into out/ (override SINGLE_YEAR= / TODAY=)
	@test -f $(FORK)/bin/advcal || { echo "Missing $(FORK) — run 'make init' to fetch submodules." >&2; exit 1; }
	@bin=$$(mktemp -d); \
	printf '#!/bin/sh\nexec perl "%s/$(FORK)/bin/advcal" "$$@"\n' "$(CURDIR)" > "$$bin/advcal"; \
	chmod +x "$$bin/advcal"; \
	PERL5LIB="$(CURDIR)/$(FORK)/lib$${PERL5LIB:+:$$PERL5LIB}" PATH="$$bin:$$PATH" \
	  ./script/build-site.sh \
	    $(if $(SINGLE_YEAR),--single-year $(SINGLE_YEAR)) \
	    $(if $(TODAY),--today $(TODAY)); \
	rc=$$?; rm -rf "$$bin"; \
	if [ $$rc -eq 0 ]; then \
	  echo "Built out/. Serve with 'make uat-serve' then open http://127.0.0.1:$(PORT)/archives-author.html"; \
	fi; \
	exit $$rc

# --- 2026 e2e (Playwright) --------------------------------------------------
# Run the advent.js browser tests. They need the fixture site (out/2026) built
# at 2026-12-25 so every door is open; Playwright starts its own server to serve
# it, so no separate `uat-serve` is required. Override the port with E2E_PORT.
#   make e2e-build              # build out/2026 the suite runs against
#   make e2e                    # run the tests (build first with e2e-build)
#   make e2e E2E_PORT=8080      # run on a different port
E2E_PORT ?= 8126

e2e-build: ## Build out/2026 at 2026-12-25 for the e2e suite
	./script/uat-preview.sh 2026-12-25

e2e: ## Run the Playwright e2e tests (override E2E_PORT=)
	npm ci
	npx playwright install chromium
	PORT=$(E2E_PORT) npx playwright test

# --- Single-article preview -------------------------------------------------
# Render ONE .pod as door 1 (2026-12-01.html) with the 2026 re-skin, then serve
# it. ARTICLE is required. Override the port with PREVIEW_PORT; set PREVIEW_HOST
# (e.g. a tailnet IP) to expose it beyond loopback.
#   make preview ARTICLE=2026/incoming/foo.pod        # build then serve on :8026
#   make preview ARTICLE=... PREVIEW_PORT=9000         # serve on a different port
#   make preview-build ARTICLE=...                     # build only (server already up)
# Then open http://127.0.0.1:$(PREVIEW_PORT)/2026/2026-12-01.html .
PREVIEW_PORT ?= 8026

preview: ## Render one .pod as door 1 and serve it (ARTICLE= required; PREVIEW_HOST= for tailnet)
	@test -n "$(ARTICLE)" || { echo "usage: make preview ARTICLE=2026/incoming/foo.pod" >&2; exit 1; }
	PREVIEW_PORT=$(PREVIEW_PORT) ./script/preview-article.sh $(ARTICLE)
	http_this out --port $(PREVIEW_PORT) $(if $(PREVIEW_HOST),--host $(PREVIEW_HOST),) --autoindex

preview-build: ## Render one .pod as door 1 without serving (ARTICLE= required)
	@test -n "$(ARTICLE)" || { echo "usage: make preview-build ARTICLE=2026/incoming/foo.pod" >&2; exit 1; }
	PREVIEW_PORT=$(PREVIEW_PORT) ./script/preview-article.sh $(ARTICLE)

# Same as `make preview`, but auto-binds to this host's Tailscale IP so the
# preview is reachable across your tailnet without looking the IP up yourself.
# Requires Tailscale installed and `up`.
preview-tailnet: ## Render one .pod as door 1 and serve it on this host's Tailscale IP (ARTICLE= required)
	@test -n "$(ARTICLE)" || { echo "usage: make preview-tailnet ARTICLE=2026/incoming/foo.pod" >&2; exit 1; }
	@ip=$$(tailscale ip -4 2>/dev/null | head -n1); \
	test -n "$$ip" || { echo "No Tailscale IPv4 address found — is 'tailscale up' running?" >&2; exit 1; }; \
	PREVIEW_PORT=$(PREVIEW_PORT) ./script/preview-article.sh $(ARTICLE); \
	echo "Serving on http://$$ip:$(PREVIEW_PORT)/2026/2026-12-01.html (reachable on your tailnet)"; \
	http_this out --port $(PREVIEW_PORT) --host "$$ip" --autoindex
