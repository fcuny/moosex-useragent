package MooseX::UserAgent::Async;

use Moose::Role;
with qw/MooseX::UserAgent::Config MooseX::UserAgent::Content
    MooseX::UserAgent::Cache/;

use AnyEvent::HTTP;
use HTTP::Response;

sub fetch {
    my ( $self, $url ) = @_;
    my $status = AnyEvent->condvar;

    my $last_modified = $self->get_ua_cache($url);

    my $request_headers = { 'Accept-Encoding' => 'gzip', };
    $request_headers->{'If-Modified-Since'} = $last_modified
        if $last_modified;

    http_request GET => $url, headers => $request_headers, sub {
        my ( $data, $headers ) = @_;
        my $response = HTTP::Response->new;
        $response->content($data);
        $response->code(delete $headers->{Status});
        foreach my $header ( keys %$headers ) {
            $response->header( $header => $headers->{$header} );
        }
        $self->store_ua_cache($url, $response);
        $status->send($response);
    };
    return $status->recv;
}

1;

__END__

=head1 NAME

RTGI::Role::UserAgent::Async - Fetch an url using AnyEvent::HTTP 

=head1 SYNOPSIS

    package Foo;

    use Moose;
    with qw/MooseX::UserAgent::Async/;

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

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck@lumberjaph.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
