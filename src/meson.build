hidden_scribe_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'Document.vala',
  'DocumentView.vala',
  'DateRow.vala',
  'KeywordRow.vala',
  'DetailsWindow.vala',
  'DetailRow.vala',
  'StringArrayRow.vala',

  # Services
  'Services/DocManager.vala',
]

hidden_scribe_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1'),
  dependency('poppler-glib'),
  dependency('libportal-gtk4'),
]

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Paper Clip')
conf.set_quoted('G_LOG_DOMAIN', 'Paper Clip')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

hidden_scribe_sources += gnome.compile_resources('pdf_metadata_editor-resources',
  'pdf-metadata-editor.gresource.xml',
  c_name: 'hidden_scribe'
)

executable('pdf-metadata-editor', hidden_scribe_sources,
  vala_args: [
    meson.project_source_root() + '/vapi/Config.vapi',
    '--vapidir', meson.project_source_root() / 'vapi',
  ],
  dependencies: hidden_scribe_deps,
       install: true,
)
