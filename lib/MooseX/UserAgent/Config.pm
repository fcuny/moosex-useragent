package MooseX::UserAgent::Config;

use Moose::Role;

has 'agent' => (
    isa     => 'Object',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ua   = LWP::UserAgent->new;

        my $conf = $self->useragent_conf;
        $ua->agent( $conf->{name} ) if $conf->{name};
        $ua->from( $conf->{mail} )  if $conf->{mail};
        $ua->max_size( $conf->{max_size} || 3000000 );
        $ua->timeout( $conf->{timeout}   || 30 );
        $ua;
    }
);

1;

__END__

=head1 NAME

RTGI::Role::UserAgent::Config

=head1 DESCRIPTION

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck@lumberjaph.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
