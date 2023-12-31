package MooseX::UserAgent::Content;

use Encode;
use Moose::Role;
use Compress::Zlib;
use HTML::Encoding 'encoding_from_http_message';

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
        $content = Encode::encode("utf-8", $content);
    }
    $content;
}

1;

__END__

=head1 NAME

RTGI::Role::UserAgent::Content

=head1 DESCRIPTION

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

franck cuny  C<< <franck.cuny@rtgi.fr> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, RTGI
All rights reserved.
L<http://rtgi.fr>

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
