use strict;
use warnings;
use utf8;
use Test::More;
use mRuby;

subtest 'simple' => sub {
    my @tests = (
        q{9} => 9,
        q{"JOHN"} => 'JOHN',
        q{[1,2,3]} => [1,2,3],
        q!{'KE' => 'NT'}! => {KE => 'NT'},
    );

    while (my ($src, $expected) = splice @tests, 0, 2) {
        my $mrb = mRuby::State->new();
        isa_ok($mrb, 'mRuby::State');
        my $st = $mrb->parse_string($src);
        isa_ok($st, 'mRuby::ParserState');
        my $n = $mrb->generate_code($st);
        is($n, 142);
        $st->pool_close();
        my $ret = $mrb->run($mrb->proc_new($n), undef);
        is_deeply($ret, $expected);
    }
};

done_testing;

