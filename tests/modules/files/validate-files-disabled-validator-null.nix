{
  home.file."test-file".text = "test content";

  nmt.script = ''
    assertFileNotRegex activate 'Running validate hook for.*test-file'
  '';
}
