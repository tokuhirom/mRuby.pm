use strict;
use warnings;
use utf8;

use Test::More tests => 6;
use Test::Requires qw/Test::LeakTrace/;
use mRuby;

no_leaks_ok { mRuby::State->new() } 'mRuby::State->new';
no_leaks_ok { mRuby::State->new()->parse_string('9') } '#parse_string';
no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $proc = $mrb->generate_code($st);
    $st->pool_close();
} '#generate_code+pool_close';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $proc = $mrb->generate_code($st);
    $st->pool_close();
    $mrb->run($proc, undef);
} '#run';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('[1, [2, [3]]]');
    my $proc = $mrb->generate_code($st);
    $st->pool_close();
    my $v = $mrb->run($proc, undef);
    note explain $v;
} '#run returns arrayref';

no_leaks_ok {
    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('{1 => { 2 => [3] }}');
    my $proc = $mrb->generate_code($st);
    $st->pool_close();
    my $v = $mrb->run($proc, undef);
    note explain $v;
} '#run returns hashref';

