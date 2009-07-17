package MooseX::UserAgent::Paranoid;

use Moose::Role;
with qw/
    MooseX::UserAgent::Config 
    MooseX::UserAgent::Content
    MooseX::UserAgent::Cache
    MooseX::UserAgent::Generic
    /;

has _LWPLIB => ( isa => 'Str', is => 'ro', default => 'LWPx::ParanoidAgent' );

1;

__END__

=head1 NAME

RTGI::Role::UserAgent::Paranoid - Fetch an url using LWPx::ParanoidAgent

=head1 SYNOPSIS

    package Foo;

    use Moose;
    with qw/MooseX::UserAgent::Paranoid/;

    has useragent_conf => (
        isa     => 'HashRef',
        default => sub {
            { name => 'myownbot', };
        }
    );

    my $res = $self->fetch($url, $cache);
    ...
    my $content = $self->get_content($res);

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item B<fetch>

This method will fetch a given URL. This method handle only the http
protocol.

If there is a cache configuration, the url will be checked in the cache,
and if there is a match, a 304 HTTP code will be returned.

Return a HTTP::Response object. 

=back

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
L<http://rtgi.fr/>

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
