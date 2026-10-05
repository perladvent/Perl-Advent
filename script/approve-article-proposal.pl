#!/usr/bin/env perl
#
# Approve an article proposal issue: label it accepted and post a getting-started
# comment so the author knows the tools at their disposal.
#
# Usage:
#   perl script/approve-article-proposal.pl <issue-number>
# Override the calendar year with the YEAR env var (default 2026); the label
# must already exist.

use v5.36;

my $issue = shift or die "usage: $0 <issue-number>\n";
my $year  = $ENV{YEAR} // 2026;

sub gh (@args) {
    system('gh', @args) == 0 or die "gh @args failed\n";
}

gh 'issue', 'edit', $issue, '--add-label', "$year,Proposal Accepted";

# Don't hard-wrap: GitHub comments render every newline as a line break.
my $body = <<"END";
🎉 Welcome to the Perl Advent Calendar v$year! Many of us look forward to this time of year and we can't wait to read what you're about to write.

Here's how to get your article written:

1. Fork the repo, then create your article stub (writes to `$year/incoming/your-slug.pod`):

   ```
   make new-article
   ```

2. Write it in POD, and test it as you go:

   ```
   perl t/article_pod.t $year/incoming/your-slug.pod
   ```

3. Preview it rendered with the real calendar styling, then open the URL it prints. Serving the preview needs `http_this`, which is a one-time install:

   ```
   cpm install -g App::HTTPThis
   make preview ARTICLE=$year/incoming/your-slug.pod
   ```

4. Open a pull request. Keep pushing to your fork and the PR will update automatically.

We like our articles to reflect the author's own unique voice. If you'd like to lean on an LLM to help with things like generating an image, whipping up some sample code, proofreading your article, etc, please do so, but please write the prose yourself. We want to hear your voice. Let your gift be something you put your heart into, rather than your tokens.

See the "Authors" section of the README and EDITING.md for more. If you have questions, you can ask them right here in this ticket.
END

gh 'issue', 'comment', $issue, '--body', $body;
