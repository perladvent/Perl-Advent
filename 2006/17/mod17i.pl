sub log
{
    my ($self, $message) = @_;

    # logging stuff here.

    if ( ( -s $self->filename ) > 100_000_000) {
        Logfile::Rotate->new(
            File => $self->file_name,
            Gzip => 'lib',
            Dir => '/digi_dev/logs/old',
        )->rotate;
    }
}
