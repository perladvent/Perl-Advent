#!/usr/bin/env perl
use v5.26;
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Path qw(make_path);
use File::Temp qw(tempdir);
use Test::More;

my $repo_root = abs_path('.');
my $script_in_repo = "$repo_root/script/build-site.sh";

ok(-f $script_in_repo, 'build-site.sh exists in repo');

sub write_file {
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "open($path): $!";
    print {$fh} $content;
    close $fh or die "close($path): $!";
}

sub setup_fixture {
    my ($supports_https) = @_;

    my $tmp = tempdir(CLEANUP => 1);

    make_path("$tmp/script", "$tmp/bin", "$tmp/images", "$tmp/2025/share/static");

    open my $in, '<', $script_in_repo or die "open($script_in_repo): $!";
    my $script = do { local $/; <$in> };
    close $in;
    write_file("$tmp/script/build-site.sh", $script);
    chmod 0755, "$tmp/script/build-site.sh";

    write_file("$tmp/mkarchives", <<'MKARCH');
#!/usr/bin/env perl
use strict;
use warnings;
my $out = shift @ARGV // die "missing out dir";
mkdir $out unless -d $out;
MKARCH
    chmod 0755, "$tmp/mkarchives";

    write_file("$tmp/bin/advcal", <<'ADVCAL');
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--help" ]]; then
  if [[ "${SUPPORTS_HTTPS:-0}" == "1" ]]; then
    echo "  --https"
  fi
  exit 0
fi
echo "$*" >> "$ADVCAL_LOG"
out_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      out_dir="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
mkdir -p "$out_dir"
ADVCAL
    chmod 0755, "$tmp/bin/advcal";

    write_file("$tmp/bin/Markdown.pl", <<'MARKDOWN');
#!/usr/bin/env perl
use strict;
use warnings;
my $file = shift @ARGV;
print "<p>$file</p>\n";
MARKDOWN
    chmod 0755, "$tmp/bin/Markdown.pl";

    write_file("$tmp/2025/advent.ini", "[adventcal]\n");
    write_file("$tmp/index.html", "<html></html>\n");
    write_file("$tmp/RSS.xml", "<rss></rss>\n");
    write_file("$tmp/favicon.ico", "ico\n");
    write_file("$tmp/contact.mkdn", "contact\n");
    write_file("$tmp/FAQ.mkdn", "faq\n");
    write_file("$tmp/FAQ-submit.mkdn", "submit\n");

    my $log = "$tmp/advcal.log";

    local %ENV = %ENV;
    $ENV{PATH} = "$tmp/bin:$ENV{PATH}";
    $ENV{ADVCAL_BIN} = 'advcal';
    $ENV{ADVCAL_LOG} = $log;
    $ENV{SUPPORTS_HTTPS} = $supports_https ? 1 : 0;

    my $cmd = "cd '$tmp' && ./script/build-site.sh --single-year 2025";
    my $rc = system('bash', '-c', $cmd);
    is($rc, 0, "build-site.sh succeeds (supports_https=$supports_https)");

    open my $log_fh, '<', $log or die "open($log): $!";
    my @lines = <$log_fh>;
    close $log_fh;

    return join '', @lines;
}

my $args_with_https = setup_fixture(1);
like($args_with_https, qr/\s--https(?:\s|$)/, 'passes --https when advcal supports it');

my $args_without_https = setup_fixture(0);
unlike($args_without_https, qr/\s--https(?:\s|$)/, 'omits --https when advcal does not support it');

done_testing;
