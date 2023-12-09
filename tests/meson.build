test_cases = [
  'agent-name-test'
]


foreach case : test_cases
  test_file = case + '.vala'
  test (case, executable (case, [test_file] + paper_clip_sources,
  vala_args: [
    meson.project_source_root() + '/vapi/Config.vapi',
    '--vapidir', meson.project_source_root() / 'vapi',
  ],
        dependencies: paper_clip_deps), env: ['G_TEST_SRCDIR='+meson.current_source_dir ()])
endforeach