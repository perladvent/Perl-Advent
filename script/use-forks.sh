# shellcheck shell=bash
# Source (don't execute) to build with the inc/ forks instead of any installed
# advcal, SynHi or PPI::HTML; the site's templates and code listings need them.
_repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_lib=""
for _fork in WWW-AdventCalendar Pod-Elemental-Transformer-SynHi PPI-HTML; do
    if [[ ! -d "$_repo/inc/$_fork/lib" ]]; then
        echo "Missing inc/$_fork — run 'make init' to fetch submodules." >&2
        unset _repo _fork _lib
        return 1
    fi
    _lib="${_lib:+$_lib:}$_repo/inc/$_fork/lib"
done
# Changed only once every fork is present, so a failed source leaves them as-is.
export PERL5LIB="$_lib${PERL5LIB:+:$PERL5LIB}"
export PATH="$_repo/script/bin:$PATH"
unset _repo _fork _lib
