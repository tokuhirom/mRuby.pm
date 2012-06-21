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
            $self->SUPER::process_PL_files();

            require Cwd::Guard;

            my @libs = <vendor/mruby/lib/*>;
            if (@libs <= 0) {
                my $guard = Cwd::Guard::cwd_guard('vendor/mruby/');
                system(q{make CFLAGS="-g -fPIC"}) == 0
                    or die;
            }
            $self->SUPER::ACTION_code(@_);
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
        'Devel::PPPort' => 0,
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
$build->create_build_script();
