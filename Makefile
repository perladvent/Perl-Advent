.PHONY: init uat uat-serve

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
