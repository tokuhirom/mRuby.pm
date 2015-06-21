use strict;
use warnings;
use utf8;
use Test::More;
use mRuby;
use mRuby::Symbol qw/mrb_sym/;
use mRuby::Bool qw/mrb_true mrb_false/;

sub run {
    my @tests = @_;
    while (my ($src, $expected) = splice @tests, 0, 2) {
        subtest "src: $src" => sub {
            my $mrb = mRuby::State->new();
            isa_ok($mrb, 'mRuby::State');
            my $st = $mrb->parse_string($src);
            isa_ok($st, 'mRuby::ParserState');
            my $proc = $mrb->generate_code($st);
            isa_ok($proc, 'mRuby::RProc');
            my $ret = $mrb->run($proc, undef);
            is_deeply($ret, $expected, 'run') or diag explain $ret;
        };
    }
}

subtest 'simple' => sub {
    run(
        q{9} => 9,
        q{1.5} => 1.5,
        q{true} => mrb_true(),
        q{false} => mrb_false(),
        q{nil} => undef,
        q{:foo} => mrb_sym('foo'),
        q{"JOHN"} => 'JOHN',
        q{[]} => [],
        q{{}} => {},
        q{[1,2,3]} => [1,2,3],
        q{{"KE"=>"NT"}} => {KE=>'NT'},
    );
};

subtest 'nested' => sub {
    run(
        q{[1,[2,[3,"4",:sym,nil]]]}                          => [1,[2,[3,"4",mrb_sym("sym"),undef]]],
        q!{'k'=>'v',:symk=>:symv,1.5=>2.5,3=>4,:undef=>nil}! => {k=>'v',symk=>mrb_sym('symv'),'1.5'=>2.5,3=>4,undef=>undef},
        q{{:k=>[:v,nil],:undef=>nil}}                        => {k=>['v',undef],undef=>undef},
        q{[{:k=>[:v,nil],:undef=>nil}]}                      => [{k=>['v',undef],undef=>undef}],
    );
};

done_testing;

