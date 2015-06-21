[![Build Status](https://travis-ci.org/tokuhirom/mRuby.pm.svg?branch=master)](https://travis-ci.org/tokuhirom/mRuby.pm)
# NAME

mRuby - mruby binding for perl5.

# SYNOPSIS

    use mRuby;

    my $mrb = mRuby::State->new();
    my $st = $mrb->parse_string('9');
    my $proc = $mrb->generate_code($st);
    my $ret = $mrb->run($proc, undef);

# DESCRIPTION

mRuby is mruby binding for perl5.

# AUTHOR

Tokuhiro Matsuno <tokuhirom AAJKLFJEF@ GMAIL COM>

# SEE ALSO

[mRuby](https://metacpan.org/pod/mRuby)

# LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
