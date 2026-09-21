.PHONY: help init uat uat-serve uat-serve-tailnet site e2e e2e-build

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

# Initialize and update git submodules.
# Handy for linked worktrees, which don't get submodules populated automatically.
init: ## Fetch/update git submodules (run once in a fresh worktree)
	git submodule update --init --recursive

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
