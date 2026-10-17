package Perl::Advent::RSSModePatch;

use strict;
use warnings;

use Encode ();
use Pod::Elemental;
use Pod::Elemental::Transformer::Codebox;
use Pod::Elemental::Transformer::List;
use Pod::Elemental::Transformer::PPIHTML;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::RSSMode;
use Pod::Elemental::Transformer::SynMux;
use Pod::Elemental::Transformer::VimHTML;
use Pod::Simple::XHTML 3.13;
use WWW::AdventCalendar::Article ();

our $VERSION = '0.001';

my $orig_body_html = WWW::AdventCalendar::Article->can('body_html');

no warnings 'redefine';

*WWW::AdventCalendar::Article::_body_renderable_pod_with_core_transforms = sub {
    my ($self) = @_;

    my $body = $self->body;
    $body = Encode::encode('utf-8', $body);

    $body = "\n=encoding utf-8\n\n$body" unless $body =~ /^=encoding/s;

    my $document = Pod::Elemental->read_string($body);

    Pod::Elemental::Transformer::Pod5->new->transform_node($document);
    Pod::Elemental::Transformer::List->new->transform_node($document);

    my $mux = Pod::Elemental::Transformer::SynMux->new({
        transformers => [
            Pod::Elemental::Transformer::Codebox->new,
            Pod::Elemental::Transformer::PPIHTML->new,
            Pod::Elemental::Transformer::VimHTML->new,
        ],
    });

    $mux->transform_node($document);

    return $document->as_pod_string;
};

*WWW::AdventCalendar::Article::_render_string_to_html = sub {
    my ($self, $string) = @_;

    my $parser = Pod::Simple::XHTML->new;
    $parser->perldoc_url_prefix('https://metacpan.org/module/');
    $parser->output_string(\my $html);
    $parser->html_h_level(2);
    $parser->html_header('');
    $parser->html_footer('');

    $parser->parse_string_document(Encode::encode('utf-8', $string));

    $html = "<div class='pod'>$html</div>";

    $html =~ s{
      \s*(<pre>)\s*
      (<table\sclass='code-listing'>.+?
      \s*</table>)\s*(?:<!--\shack\s-->)?\s*(</pre>)\s*
    }{my $str = $2; $str =~ s/\G^\s\s[^\$]*$//gm; $str}gesmx;

    return $html;
};

*WWW::AdventCalendar::Article::_build_body_html = sub {
    my ($self) = @_;

    my $pod = Pod::Elemental->read_string($self->_body_renderable_pod_with_core_transforms);
    Pod::Elemental::Transformer::RSSMode->new({ web_mode => 1 })->transform_node($pod);

    return $self->_render_string_to_html($pod->as_pod_string);
};

*WWW::AdventCalendar::Article::body_html_for_rss = sub {
    my ($self) = @_;

    my $pod = Pod::Elemental->read_string($self->_body_renderable_pod_with_core_transforms);
    Pod::Elemental::Transformer::RSSMode->new->transform_node($pod);

    return $self->_render_string_to_html($pod->as_pod_string);
};

# Feed summaries call body_html from WWW::AdventCalendar::build; route those calls
# to RSS rendering while keeping page rendering on the normal accessor path.
*WWW::AdventCalendar::Article::body_html = sub {
    my ($self, @rest) = @_;

    my ($caller_pkg) = caller;
    if ($caller_pkg && $caller_pkg eq 'WWW::AdventCalendar') {
        return $self->body_html_for_rss;
    }

    return $orig_body_html->($self, @rest);
};

1;
