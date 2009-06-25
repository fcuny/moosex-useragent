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
        $ua->max_size( $conf->{max_size} ) if $conf->{max_size};
        $ua->timeout( $conf->{timeout}   || 180 );
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
AnyEvent::HTTP string. See L<LWP::UserAgent> or L<AnyEvent::HTTP>.

=item B<mail>

Mail string used by the HTTP client (only for LWP). Default is to use the
LWP string. See L<LWP::UserAgent>

=item B<max_size>

size limit for response content. The default is 3 000 000 octets. See
L<LWP::UserAgent>.

=item B<timeout>

Timeout value in seconds. The default timeout() value is 180 seconds

=item B<cache>

=over 2

=item B<use_cache>

Set to true to activate caching. Defaults is false.

=item B<root>

The location in the filesystem that will hold the root of the cache.

=item B<default_expires_in>

The default expiration time for objects place in the cache. Defaults to $EXPIRES_NEVER if not explicitly set.

=item B<namespace>

The namespace associated with this cache. Defaults to "Default" if not
explicitly set.

=back

=back

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
