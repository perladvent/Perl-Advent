# Run the server, unless this code is being loaded as a module
Xmas::NMS::Server->run() unless caller();

package Xmas::NMS::Server;
use base qw(Net::Server::PreFork);
use Carp;
use Scalar::Util qw(blessed);
use File::Basename qw(dirname);
use File::Spec::Functions qw(catdir);

# Net::Server can take options from the command line, a
# config file, or as parameters to new() or run(). Using
# this method, you can override and add options that
# Net::Server will then recognize from any of those places
sub options {
    my ( $self, $template ) = @_;  # template is a hashref
    my $props = $self->{server};   # server properties

    # load the base class' options into the template
    $self->SUPER::options( $template );

    # create a property entry for the new option
    $props->{nms_authkey} ||= undef;

    # put a reference to that entry into the template
    $template->{nms_authkey} = \$props->{nms_authkey};

    # when the options are processed by Net::Server,
    # their values will be stored in the referenced
    # server property entries

    # use an arrayref for multi-valued options
    $props->{nms_regions} ||= [];
    $template->{nms_regions} = $props->{nms_regions};

    # you can do each type in one line, if you like...
    $template->{"nms_$_"} = \$props->{"nms_$_"}
        for ( qw( data_dir client_timeout) );

    $template->{nms_data_types} = $props->{nms_data_types} ||= [];
}

# If you want to set some defaults differently or in
# addition to those already used by Net::Server, put
# them in a hash returned by this method.
sub default_values {
    return {
        port => 8765,
        nms_client_timeout => 30,

        # types of data collected by the agency
        nms_data_types => [qw(observations hearsay gift_lists)],

        # where to look for the data files
        nms_data_dir => catdir( dirname( $0 ), 'data' ),
    };
}

# use this method to validate the values of your options
sub post_configure_hook {
    my ( $self ) = @_;
    my $props = $self->{server};

    @{ $props->{nms_regions} }
        || croak "Please specify one or more values for nms_regions";

    $props->{nms_authkey}
        || croak "Please specify a value for nms_authkey";
}

# if you want to use authorization more involved than
# checking the client's IP address, use this hook
sub allow_deny_hook {
    my ( $self ) = @_;
    my $props = $self->{server};

    # prompt
    $self->sendtext( "auth: " );

    my $line = $self->getline_timeout || return;

    # authorized? return truth
    return 1 if $line eq $props->{nms_authkey};

    # not authorized? return false
    my $client_ip = $props->{peeraddr} || 'unknown';
    $self->sendlines( 
        "AUTHORIZATION FAILED FROM IP [$client_ip]",
        "YOU ARE NOW ON THE NAUGHTY LIST",
    );

    return;
}

# continuation of authorized connections
sub process_request {
    my ( $self ) = @_;

    my $props     = $self->{server};
    my $client_fh = $props->{client};

    $self->sendlines(
        "",
        "Welcome to the NMS server for the following regions:",
        ( map {"\t$_"} @{ $props->{nms_regions} } ),
        "",
        "Enter the name of a snot-nosed brat or QUIT to logout.",
        "NOTE: children actually named 'QUIT' have a tough life",
        "already and automatically get a pony EVERY YEAR",
        "",
    );

    while ( $self->sendtext( "name: " )
        and defined( my $name = $self->getline_timeout ) )
    {
        return if $name eq 'QUIT';
        $self->sendlines( "\t$name is a rotten little kid", "" );
    }

}

# this isn't a Net::Server hook, it's just a helper
# to get a line from the client within a timeout
sub getline_timeout {
    my ( $self, $client_fh, $timeout ) = @_;

    $client_fh ||= $self->{server}{client};
    $timeout   ||= $self->{server}{nms_client_timeout};

    # attempt to get a line from the client within the timeout
    my $line = eval {

        # set an alarm to throw an exception...
        local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
        my $previous_alarm = alarm( $timeout );

        my $line = $client_fh->getline;

        # restore the old alarm value
        alarm( $previous_alarm );

        # return the line from the eval
        $line;
    };

    # if the alarm went off, catch the exception
    if ( $@ =~ /timed out/i ) {
        $self->sendlines(
            $client_fh,
            "Timed Out - You were too slow-ho-ho!"
        );
        return;
    }

    # getline can return undef...
    return unless defined $line;

    # strip out any end-of-line chars
    $line =~ s/\r?\n$//;
    return $line;
}


# another helper method to make decorate text with newlines
sub sendlines {
    my $self = shift;
    my ($client_fh, @lines) = $self->_client_fh_from_args( @_ );
    $self->sendtext( $client_fh, map { "$_\r\n" } @lines );
}

# concatenate text and send to client undecorated
sub sendtext {
    my ( $self ) = shift;

    my ($client_fh, @lines) = $self->_client_fh_from_args( @_ );

    $client_fh->print( map { defined( $_ ) ? $_ : "" } @lines )
        or croak "Error sending data to the client!";
}

# find out if the first argument is a filehandle. if so, use that.
# if not, use the client filehandle.
sub _client_fh_from_args {
    my $self = shift;
    my $client_fh
        = ( blessed( $_[0] ) && $_[0]->can( 'print' ) ) ?
            shift : $self->{server}{client};
    return ( $client_fh, @_ );
}

1;
