{
  home.file."test-file" = {
    text = "test content";
    validate = {
      enabled = false;
      validator = { source }: "echo 'should not run'";
    };
  };

  nmt.script = ''
    assertFileNotRegex activate 'Running validate hook for.*test-file'
  '';
}
