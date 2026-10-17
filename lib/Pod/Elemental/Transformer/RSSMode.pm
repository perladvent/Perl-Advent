package Pod::Elemental::Transformer::RSSMode;

use Moose;
with 'Pod::Elemental::Transformer';

use namespace::autoclean;

has web_mode => (
    is      => 'ro',
    default => 0,
);

has _to_be_removed_regex => (
    is       => 'ro',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_to_be_removed_regex',
);

sub _build_to_be_removed_regex {
    my ($self) = @_;
    return qr/\Arss_only/ if $self->web_mode;
    return qr/\Aweb_only/;
}

sub transform_node {
    my ($self, $node) = @_;

    # Remove mode-specific =for directives that do not apply.
    $self->_remove_nodes($node);

    # Convert remaining mode directives into regular html directives.
    $self->_rename_nodes($node);
}

sub _rename_nodes {
    my ($self, $node) = @_;

    for my $child (@{ $node->children }) {
        next unless $child->can('command') && $child->command eq 'for';

        my $content = $child->content;
        $content =~ s/\Aweb_only/html/;
        $content =~ s/\Arss_only/html/;
        $child->content($content);
    }
}

sub _remove_nodes {
    my ($self, $node) = @_;

    $node->children([
        grep {
            !(
                $_->can('command')
                && $_->command eq 'for'
                && $_->content =~ $self->_to_be_removed_regex
            )
        } @{ $node->children }
    ]);
}

__PACKAGE__->meta->make_immutable;
1;
