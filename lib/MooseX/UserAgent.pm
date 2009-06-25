package MooseX::UserAgent;

our $VERSION = '0.2.0';

use URI;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

use Moose::Role;
with qw/
    MooseX::UserAgent::Config
    MooseX::UserAgent::Content
    MooseX::UserAgent::Cache
    /;

sub fetch {
    my ( $self, $url ) = @_;

    my $req = HTTP::Request->new( GET => URI->new($url) );

    $req->header( 'Accept-Encoding', 'gzip' );
    my $last_modified = $self->get_ua_cache($url);
    $req->header( 'If-Modified-Since' => $last_modified )
        if $last_modified;

    my $res = $self->agent->request($req);
    $self->store_ua_cache( $url, $res );
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
modules you want:

    my $cache = new Cache::MemoryCache(
        {
            'namespace'          => 'mymemorycacheforbot',
            'default_expires_in' => 600
        }
    );

    my $class = $MyClassUsingUA->new(
        useragent_conf => {
            cache => {
                use_cache => 1,
                namespace => 'testua',
            }
        },
        ua_cache => $cache,
    );

=head2 METHODS

=head3 useragent_conf

This is an attribut you need to add to your Class. It's a HashRef that
contains all the required configuration for the useragent.

=over 4

=item B<agent>

The default useragent is a LWP::UserAgent object. In the configuration,
the name and mail of the useragent have to be defined. The default size of
a page manipulated can't excess 3 000 000 octets and the timeout is set to
30 seconds.

=item B<fetch>

This method will fetch a given URL. This method handle only the http
protocol.

If there is a cache configuration, the url will be checked in the cache,
and if there is a match, a 304 HTTP code will be returned.

=item B<get_content>

This method will return a content in utf8.

=back

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
