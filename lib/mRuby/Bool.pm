package mRuby::Bool;
use strict;
use warnings;

use Exporter 5.57 qw/import/;
our @EXPORT_OK = qw/mrb_true mrb_false mrb_bool/;

use overload
    bool     => sub { ${+shift} },
    fallback => 1;

sub _new_bool {
    my $p = shift;
    my $class = $p ? 'mRuby::Bool::True' : 'mRuby::Bool::False';
    my $bool = bless \$p, $class;
    Internals::SvREADONLY($bool, 1);
    return $bool;
}

my $true  = _new_bool(1);
my $false = _new_bool(undef);

sub mrb_true () { ## no critic
    return $true;
}

sub mrb_false () { ## no critic
    return $false;
}

sub mrb_bool ($) { ## no critic
    my $v = shift;
    return $v ? $true : $false;
}

package # hide from PAUSE
    mRuby::Bool::True;
our @INC = qw/mRuby::Bool/;

package # hide from PAUSE
    mRuby::Bool::False;
our @INC = qw/mRuby::Bool/;

1;
__END__

=pod

=encoding utf-8

=head1 NAME

mRuby::Symbol - TODO

=head1 SYNOPSIS

    use mRuby::Symbol qw/mrb_sym/;

    mrb_sym('foo'); ## :foo in mruby context.

=head1 DESCRIPTION

TODO

=head1 SEE ALSO

L<perl>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut



1;
__END__

=pod

=encoding utf-8

=head1 NAME

mRuby::Bool - TODO

=head1 SYNOPSIS

    use mRuby::Bool;

=head1 DESCRIPTION

TODO

=head1 SEE ALSO

L<perl>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut
