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
