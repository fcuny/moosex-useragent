package Test::MooseX::UserAgent;

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;
use Cache::MemoryCache;
use RTGI::Storage::Client;
{

    package Test::UserAgent;
    use Moose;
    with qw/MooseX::UserAgent/;
    has useragent_conf => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            return {
                name =>
                    'Mozilla/5.0 (compatible; LWP; RTGI; http://rtgi.fr/)',
                mail     => 'bot@rtgi.fr',
                timeout  => 30,
                cache    => { use_cache => 0, },
                max_size => 3000000,
            };
        }
    );
    1;
}
{

    package Test::UserAgent::Async;
    use Moose;
    with qw/MooseX::UserAgent::Async/;
    has useragent_conf => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            return {
                name =>
                    'Mozilla/5.0 (compatible; Async; RTGI; http://rtgi.fr/)',
                mail    => 'bot@rtgi.fr',
                timeout => 30,
                cache   => { use_cache => 0, },
            };
        }
    );
    1;
}
{

    package Test::UserAgent::Paranoid;
    use Moose;
    with qw/MooseX::UserAgent::Paranoid/;
    has useragent_conf => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            return {
                name =>
                    'Mozilla/5.0 (compatible; Paranoid; RTGI; http://rtgi.fr/)',
                mail    => 'bot@rtgi.fr',
                timeout => 30,
                cache   => { use_cache => 0, },
            };
        }
    );
    1;
}

sub cache {
    my $cache = new Cache::MemoryCache(
        {
            'namespace'          => 'testua',
            'default_expires_in' => 600
        }
    );
    return $cache;
}

my @ua_roles = (qw/Test::UserAgent Test::UserAgent::Async
    Test::UserAgent::Paranoid/);

sub fetch : Tests(21) {
    my $test = shift;

    my $url = 'http://lumberjaph.net/blog';

    foreach my $ua (@ua_roles) {
        can_ok $ua, 'fetch';
        ok my $obj = $ua->new(), '... object is created';
        ok my $res = $obj->fetch($url), '... fetch url';
        is $res->code,      "200",          "... fetch is a success";
        like $res->content, qr/lumberjaph/, "... and content is good";

        # test with cache
        $obj = $ua->new(
            useragent_conf => {
                name =>
                    'Mozilla/5.0 (compatible; Async; RTGI; http://rtgi.fr/)',
                cache => {
                    use_cache => 1,
                    namespace => 'testua',
                }
            },
            ua_cache => $test->cache,
        );
        $res = $obj->fetch($url);
        is $res->code, "200", "... fetch is a success";

        my $ref = $obj->ua_cache->get($url);
        ok defined $ref, "... url is now in cache";
    }
}

sub get_content : Tests(12) {
    my $test = shift;

    my $url = 'http://lumberjaph.net';
    foreach my $ua (@ua_roles) {
        can_ok $ua, 'get_content';
        ok my $obj = $ua->new(), ' ... object is created';
        my $res = $obj->fetch($url);
        cmp_ok $res->code, "<", 300, "... fetch is a success";
        my $content = $obj->get_content($res);
        like $content, qr/lumberjaph/, "... and content is good";
    }
}

sub test_cache : Tests(6) {
    my $test = shift;
    my $url = 'http://en.wikipedia.org';

    my $obj = Test::UserAgent->new(
        useragent_conf => { cache => { use_cache => 1 } },
        ua_cache       => $test->cache
        ),
        ' ... object is created';
    can_ok $obj, 'get_content';
    my $res = $obj->fetch($url);
    cmp_ok $res->code, "<", 300, "... fetch is a success";

    $obj = Test::UserAgent::Async->new(
        useragent_conf => { cache => { use_cache => 1 } },
        ua_cache       => $test->cache
        ),
        ' ... object is created';
    can_ok $obj, 'get_content';
    $res = $obj->fetch($url);
    is $res->code, 304, '... already in cache';

    $obj = Test::UserAgent::Paranoid->new(
        useragent_conf => { cache => { use_cache => 1 } },
        ua_cache       => $test->cache
        ),
        ' ... object is created';
    can_ok $obj, 'get_content';
    $res = $obj->fetch($url);
    is $res->code, 304, '... already in cache';
}

sub test_lwplib : Tests(2) {
    my $test   = shift;
    my $ua_lwp = Test::UserAgent->new();
    is $ua_lwp->_LWPLIB, 'LWP::UserAgent', '... use LWP::UserAgent';
    my $ua_paranoid = Test::UserAgent::Paranoid->new();
    is $ua_paranoid->_LWPLIB, 'LWPx::ParanoidAgent',
        '... use LWPx::ParanoidAgent';
}

1;
