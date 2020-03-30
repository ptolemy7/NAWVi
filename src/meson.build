executable (
    meson.project_name(),
    'main.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('webkit2gtk-4.0'),
        dependency('gee-0.8')
    ],
    install: true
)

install_data (
    'nawvi_helper_script',
    install_dir: join_paths( get_option('prefix'),'bin')

)