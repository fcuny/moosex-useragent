use inc::Module::Install;
name 'MooseX-UserAgent';
all_from 'lib/MooseX/UserAgent.pm';

# requires '';
requires 'Moose';
requires 'Test::Class';
requires 'Test::Exception';
requires 'URI';
requires 'HTTP::Request';
requires 'HTTP::Response';
requires 'LWP::UserAgent';
requires 'LWPx::ParanoidAgent';
requires 'Cache::FileCache';
requires 'Cache::MemoryCache;'
requires 'AnyEvent::HTTP';
requires 'Compress::Zlib';
requires 'HTML::Encoding';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
repository 'http://github.com/franckcuny/MooseX--UserAgent/tree/master';
WriteAll;
