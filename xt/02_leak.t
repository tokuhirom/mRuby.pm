use strict;
use warnings;
use utf8;

use Test::More tests => 8;
use Test::Requires qw/Test::LeakTrace/;
use mRuby;

no_leaks_ok { mRuby::State->new() } 'mRuby::State->new';
no_leaks_ok { mRuby::State->new()->parse_string('9') } '#parse_string';
no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $proc = $mrb->generate_code($st);
} '#generate_code';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $proc = $mrb->generate_code($st);
    $mrb->run($proc, undef);
} '#run';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('[1, [2, [3]]]');
    my $proc = $mrb->generate_code($st);
    my $v = $mrb->run($proc, undef);
} '#run returns arrayref';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('{1 => { 2 => [3] }}');
    my $proc = $mrb->generate_code($st);
    my $v = $mrb->run($proc, undef);
} '#run returns hashref';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('[nil]');
    my $proc = $mrb->generate_code($st);
    my $v = $mrb->run($proc, undef);
} '#run returns nil in arrayref';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('{:undef => nil}');
    my $proc = $mrb->generate_code($st);
    my $v = $mrb->run($proc, undef);
} '#run returns nil in hashref';

