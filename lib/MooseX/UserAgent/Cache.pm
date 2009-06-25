package MooseX::UserAgent::Cache;

use Moose::Role;
use Cache::FileCache;

has 'ua_cache' => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Cache::FileCache->new(
            {
                cache_root => $self->useragent_conf->{cache}->{root},
                default_expires_in =>
                    $self->useragent_conf->{cache}->{expires},
                namespace => $self->useragent_conf->{cache}->{namespace}
            }
        );
    }
);

sub get_ua_cache {
    my ( $self, $url ) = @_;
    if ( $self->useragent_conf->{cache}->{use_cache} ) {
        my $ref = $self->ua_cache->get($url);
        if ( defined $ref && $ref->{LastModified} ne '' ) {
            return $ref->{LastModified};
        }
    }
}

sub store_ua_cache {
    my ( $self, $url, $res ) = @_;
    if ( $self->useragent_conf->{ cache }->{ use_cache } ) {
        $self->ua_cache->set(
            $url,
            {   ETag         => $res->header( 'Etag' )          || '',
                LastModified => $res->header( 'Last-Modified' ) || ''
            }
        );
    }
}

1;

__END__

=head1 NAME

RTGI::Role::UserAgent::Cache

=head1 DESCRIPTION

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck@lumberjaph.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
