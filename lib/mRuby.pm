package mRuby;
use strict;
use warnings;
use 5.008008;
our $VERSION = '0.04';

use XSLoader;

XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=encoding utf8

=head1 NAME

mRuby - mruby binding for perl5.

=head1 SYNOPSIS

    use mRuby;

    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $n = $mrb->generate_code($st);
    $st->pool_close();
    my $ret = $mrb->run($mrb->proc_new($n), undef);

=head1 DESCRIPTION

mRuby is mruby binding for perl5.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

L<mRuby>

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
