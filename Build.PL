use strict;
use warnings;
use Module::Build;
use File::Spec;

die "Please run 'git submodule init; git submodule update'" unless -d 'vendor/mruby/';

my $class = Module::Build->subclass(
    class => 'My::Builder',
    code => <<'...'
        sub ACTION_code {
            my $self = shift;

            require Devel::PPPort;
            Devel::PPPort::WriteFile('ppport.h');

            require Cwd::Guard;

            my @libs = <vendor/mruby/lib/*>;
            if (@libs <= 0) {
                my $guard = Cwd::Guard::cwd_guard('vendor/mruby/');
                system(q{make CFLAGS="-g -fPIC"}) == 0
                    or die;
            }
            $self->SUPER::ACTION_code(@_);
        }

    sub c99_available {
        my($self) = @_;

        return 0 if not $self->have_c_compiler();
    
        require File::Temp;
        require File::Basename;
        require Config;
    
        my $tmpfile = File::Temp->new(SUFFIX => '.c');
    
        $tmpfile->print(<<'C99');
// include a C99 header
#include <stdbool.h>
inline // a C99 keyword with C99 style comments
int test_c99() {
    int i = 0;
    i++;
    int j = i - 1; // another C99 feature: declaration after statement
    return j;
}
C99
    
        $tmpfile->close();
    
        system("$Config::Config{cc} -c " . $tmpfile->filename);
    
        (my $objname = File::Basename::basename($tmpfile->filename)) =~ s/\Q.c\E$/$Config::Config{_o}/;
        unlink $objname or warn "Cannot unlink $objname (ignored): $!";
    
        return $? == 0;
    }

    sub requires_c99 {
        my($self) = @_;
        if(!$self->c99_available) {
            $self->log_warn("This distribution requires a C99 compiler, but $Config{cc} seems not to support C99, stopped.\n");
            exit;
        }
        return;
    }
...
);

my $build = My::Builder->new(
    license              => 'perl',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More' => '0.98',
        'Test::Requires' => 0,
        'Cwd::Guard' => 0,
        'Devel::PPPort' => 3.20,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        # 'Exporter'                      => '0',
        'parent'                        => '0',
        # 'Plack'                         => '0.9949',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'mRuby',
    module_name => 'mRuby',

    extra_linker_flags => ['-L' . File::Spec->rel2abs('vendor/mruby/lib/'), '-lmruby'],
    extra_compiler_flags => ['-fPIC', '-I' . File::Spec->rel2abs('vendor/mruby/include/')],

    # script_files => [''],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    create_readme  => 1,
    create_license => 1,
);
$build->requires_c99();
$build->create_build_script();
