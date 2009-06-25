package MooseX::UserAgent::Config;

use Moose::Role;

has 'agent' => (
    isa     => 'Object',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ua   = LWP::UserAgent->new;

        if (!$self->can('useragent_conf')) {
        }
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

=head1 SYNOPSIS

    has useragent_conf => (
        isa     => 'HashRef',
        default => sub {
            {
                name     => 'myownbot',
                mail     => 'mail\@bot.com',
                timeout  => 60,
                max_size => 50000,
                cache    => {
                    use_cache => 1,
                    namespace => 'mybotua',
                    root      => '/tmp',
                }
            };
        }
    );

=head1 DESCRIPTION

=over 4

=item B<name>

UserAgent string used by the HTTP client. Default is to use the LWP or
AnyEvent::HTTP string.

=item B<mail>

Mail string used by the HTTP client (only for LWP). Default is to use the
LWP string.

=item B<max_size>

Max size that will be fetched by the useragent, in octets (only for LWP).
Default is set to 3 000 000.

=item B<timeout>

Time out. Default is set to 30.

=item B<cache>

=over 2

=item B<use_cache>

If you need caching, set to 1. Default is no cache.

=item B<root>

Where to store the cache.

=item B<default_expires_in>

=item B<namespace>

=back

=back

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
