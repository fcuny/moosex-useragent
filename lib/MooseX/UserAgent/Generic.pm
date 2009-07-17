package MooseX::UserAgent::Generic;

our $VERSION = '0.2.0';

use URI;
use HTTP::Request;

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
