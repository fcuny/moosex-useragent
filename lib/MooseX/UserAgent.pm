package MooseX::UserAgent;

our $VERSION = '0.2.0';

use Moose::Role;
with qw/MooseX::UserAgent::Config MooseX::UserAgent::Content
    MooseX::UserAgent::Cache/;

use URI;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

sub fetch {
    my ( $self, $url ) = @_;

    my $req = HTTP::Request->new( GET => URI->new( $url ) );

    $req->header( 'Accept-Encoding', 'gzip' );
    my $last_modified = $self->get_ua_cache($url);
    $req->header( 'If-Modified-Since' => $last_modified )
        if $last_modified;

    my $res = $self->agent->request( $req );
    $self->store_ua_cache($url, $res);
    $res;
}

1;

__END__

=head1 NAME

RTGI::Role::UserAgent - Fetch an url using LWP as the HTTP library

=head1 SYNOPSIS

    package Foo;

    use Moose;
    with qw/MooseX::UserAgent/;

    has useragent_conf => (
        isa     => 'HashRef',
        default => sub {
            { name => 'myownbot', };
        }
    );

    my $res = $self->fetch($url, $cache);
    ...
    my $content = $self->get_content($res);

    --- yaml configuration
    name: 'Mozilla/5.0 (compatible; RTGI; http://rtgi.fr/)'
    mail: 'bot@rtgi.fr'
    max_size: 3000000
    timeout: 30
    cache:
      use_cache: 1
      root: /tmp
      default_expires_in: 5 days
      namespace: my::useragent

=head1 DESCRIPTION

This is a role which provides a useragent to a Moose Class. 

The role will do the caching for you if you need it, using Cache::*Cache
modules. By default it uses Cache::FileCache, but you can use any Cache
modules you want.

=head2 METHODS

=over 4

=item B<agent>

The default useragent is a LWPx::ParanoidAgent object. In the
configuration, the name, mail of the useragent have to be defined. The
default size of a page manipulated can't excess 3 000 000 octets and the
timeout is set to 30 seconds.

=item B<fetch>

This method will fetch a given URL. This method handle only the http
protocol.

If there is a cache configuration, the url will be checked in the cache,
and if there is a match, the content will be returned.

In the case of scraping search engines, a delay may be given, so we will
not hammer the server.

=item B<get_content>

This method will return a content in utf8.

=back

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck@lumberjaph.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
