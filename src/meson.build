hidden_scribe_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'Document.vala',
  'DocumentView.vala',
  'DateRow.vala',
  'DropOverlay.vala',
  'KeywordRow.vala',
  'DetailsList.vala',
  'SaveChangesDialog.vala',
  'StringArrayRow.vala',
  'DocumentThumbnail.vala',
  'KeywordList.vala',
  'PasswordDialog.vala',

  'ThreadManager.vala',

  # Models
  'Models/AsyncTask.vala',

  # Services
  'Services/DocumentManager.vala',
  'Services/Thumbnailer.vala',
]

exempi_dep = dependency('exempi-2.0')

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

hidden_scribe_deps = [
  dependency('gtk4', version:'>=4.10'),
  dependency('libadwaita-1'),
  dependency('poppler-glib'),
  exempi_dep,
  m_dep,
]

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Paper Clip')
conf.set_quoted('G_LOG_DOMAIN', 'Paper Clip')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('EXEMPI_VERSION', exempi_dep.version () + ' (Compile Time)')
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
