package MooseX::UserAgent;

use Moose::Role;

our $VERSION = '0.2.0';

use Encode;
use HTTP::Response;
use LWPx::ParanoidAgent;
use HTML::Encoding 'encoding_from_http_message';
use Compress::Zlib;

has 'agent' => (
    isa     => 'Object',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ua   = LWPx::ParanoidAgent->new;

        my $conf = $self->useragent_conf;
        $ua->agent( $conf->{name} ) if $conf->{name};
        $ua->from( $conf->{mail} )  if $conf->{mail};
        $ua->max_size( $conf->{max_size} || 3000000 );
        $ua->timeout( $conf->{timeout}   || 30 );
        $ua;
    }
);

sub fetch {
    my ( $self, $url ) = @_;

    my $req = HTTP::Request->new( GET => URI->new( $url ) );

    $req->header('Accept-Encoding', 'gzip');

    if ( $self->context->{ useragent }->{ use_cache } ) {
        my $ref = $self->cache->get( $url );
        if ( defined $ref && $ref->{ LastModified } ne '' ) {
            $req->header( 'If-Modified-Since' => $ref->{ LastModified } );
        }
    }

    my $res = $self->agent->request( $req );

    if ( $self->context->{ useragent }->{ use_cache } ) {
        $self->cache->set(
            $url,
            {   ETag         => $res->header( 'Etag' )          || '',
                LastModified => $res->header( 'Last-Modified' ) || ''
            }
        );
    }

    $res;
}

sub get_content {
    my ( $self, $res ) = @_;

    my $enc = encoding_from_http_message($res);

    my $content = $res->content;
    if ( $res->content_encoding && $res->content_encoding eq 'gzip' ) {
        $content = Compress::Zlib::memGunzip($content);
    }

    if ( $enc && $enc !~ /utf-8/i ) {
        $content = $res->decoded_content( raise_error => 1 );
        if ($@) {
            $content = Encode::decode( $enc, $content );
        }
    }
    $content;
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

    --- kwalify schema
    "use_cache":
      name: use_cache
      desc: use cache
      required: true
      type: int
    "name":
      name: name
      desc: useragent string
      required: true
      type: str
    "mail":
      name: mail
      desc: mail for the useragent
      required: true
      type: str
    "timeout":
      name: timeout
      desc: timeout
      required: true
      type: int
    "max_size":
      name: max_size
      desc: max size
      required: true
      type: int

=head1 DESCRIPTION

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

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
