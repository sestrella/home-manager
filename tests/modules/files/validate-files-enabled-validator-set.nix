{
  home.file."test-file" = {
    text = "test content";
    validate = {
      enabled = true;
      validator = { source }: "echo 'validated ${source}'";
    };
  };

  nmt.script = ''
    assertFileRegex activate 'Running validate hook for test-file'
    assertFileRegex activate 'validated /nix/store/.*-hm_testfile'
  '';
}
