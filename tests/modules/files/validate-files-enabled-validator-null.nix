{
  home.file."test-file" = {
    text = "test content";
    validate.enabled = true;
  };

  nmt.script = ''
    assertFileNotRegex activate 'Running validate hook for.*test-file'
  '';
}
