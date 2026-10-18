# shellcheck shell=bash
# Source (don't execute) to build with the inc/ forks instead of any installed
# advcal, SynHi or PPI::HTML; the site's templates and code listings need them.
_repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for _fork in WWW-AdventCalendar Pod-Elemental-Transformer-SynHi PPI-HTML; do
    if [[ ! -d "$_repo/inc/$_fork/lib" ]]; then
        echo "Missing inc/$_fork — run 'make init' to fetch submodules." >&2
        return 1
    fi
    PERL5LIB="$_repo/inc/$_fork/lib${PERL5LIB:+:$PERL5LIB}"
done
export PERL5LIB
export PATH="$_repo/script/bin:$PATH"
unset _repo _fork
