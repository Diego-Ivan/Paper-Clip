hidden_scribe_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'Document.vala',
  'PropertyRow.vala',
  'EntryRow.vala',
  'DocumentView.vala',

  # Services
  'Services/DocManager.vala',
]

hidden_scribe_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1'),
  dependency('poppler-glib'),
]

hidden_scribe_sources += gnome.compile_resources('hidden-scribe-resources',
  'hidden-scribe.gresource.xml',
  c_name: 'hidden_scribe'
)

executable('hidden-scribe', hidden_scribe_sources,
  dependencies: hidden_scribe_deps,
       install: true,
)
