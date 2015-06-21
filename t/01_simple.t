use strict;
use warnings;
use utf8;
use Test::More;
use mRuby;

subtest 'simple' => sub {
    my $mrb = mRuby::State->new();
    isa_ok($mrb, 'mRuby::State');
    my $st = $mrb->parse_string('9');
    isa_ok($st, 'mRuby::ParserState');
    my $proc = $mrb->generate_code($st);
    isa_ok($proc, 'mRuby::RProc');
    my $ret = $mrb->run($proc, undef);
    is($ret, 9);
};

subtest 'return string' => sub {
    my $mrb = mRuby::State->new();
    isa_ok($mrb, 'mRuby::State');
    my $st = $mrb->parse_string('"OK" + "JOHN"');
    isa_ok($st, 'mRuby::ParserState');
    my $proc = $mrb->generate_code($st);
    isa_ok($proc, 'mRuby::RProc');
    my $ret = $mrb->run($proc, undef);
    is($ret, 'OKJOHN');
};

done_testing;

