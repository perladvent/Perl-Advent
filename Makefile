.PHONY: init

# Initialize and update git submodules.
# Handy for linked worktrees, which don't get submodules populated automatically.
init:
	git submodule update --init --recursive
