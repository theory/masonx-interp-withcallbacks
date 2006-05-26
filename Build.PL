use Module::Build;

my $build_pkg = eval { require Apache::TestMB }
  ? 'Apache::TestMB' : 'Module::Build';

$build_pkg->new(
    module_name        => 'MasonX::Interp::WithCallbacks',
    license            => 'perl',
    requires           => {
        'HTML::Mason'             => '1.23',
        'Test::Simple'            => '0.17',
        'Class::Container'        => '0.09',
        'Params::CallbackRequest' => '1.15',
    },
    build_requires     => {
        'Test::Simple' => '0.17'
    },
    recommends         => {
        'Apache::TestMB' => 0
    },
    create_makefile_pl => 'passthrough',
    add_to_cleanup     => ['t/mason'],
)->create_build_script;
