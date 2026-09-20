.PHONY: init uat uat-serve e2e e2e-build

# Initialize and update git submodules.
# Handy for linked worktrees, which don't get submodules populated automatically.
init:
	git submodule update --init --recursive

# --- 2026 UAT preview -------------------------------------------------------
# Two steps: build the fixture site, then serve it. Override DAY/PORT as needed:
#   make uat                    # build out/2026 (simulated 2026-12-06)
#   make uat DAY=2026-12-02     # build simulating a different day
#   make uat-serve              # serve out/ on :8026 (Ctrl-C to stop)
#   make uat-serve PORT=8080    # serve on a different port
# Then open http://127.0.0.1:$(PORT)/2026/ . Rebuild with `make uat` while the
# server keeps running and just refresh the browser.
DAY  ?= 2026-12-06
PORT ?= 8026

uat:
	./script/uat-preview.sh $(DAY)

uat-serve:
	cd out && python3 -m http.server $(PORT)

# --- 2026 e2e (Playwright) --------------------------------------------------
# Run the advent.js browser tests. They need the fixture site (out/2026) built
# at 2026-12-25 so every door is open; Playwright starts its own server to serve
# it, so no separate `uat-serve` is required. Override the port with E2E_PORT.
#   make e2e-build              # build out/2026 the suite runs against
#   make e2e                    # run the tests (build first with e2e-build)
#   make e2e E2E_PORT=8080      # run on a different port
E2E_PORT ?= 8126

e2e-build:
	./script/uat-preview.sh 2026-12-25

e2e:
	npm ci
	npx playwright install chromium
	PORT=$(E2E_PORT) npx playwright test
