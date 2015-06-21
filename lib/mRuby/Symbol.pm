package mRuby::Symbol;
use strict;
use warnings;

use Exporter 5.57 qw/import/;
our @EXPORT_OK = qw/mrb_sym/;

use overload
    q{""} => sub { ${+shift} },
    fallback => 1;

sub mrb_sym ($) { ## no critic
    my $v = shift;
    return bless \$v, __PACKAGE__;
}

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
