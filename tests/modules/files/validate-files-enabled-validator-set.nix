{ config, pkgs, ... }:

{
  home.file."test-file" = {
    text = "test content";
    validate = {
      enabled = true;
      validator = { source }: "echo 'validated ${source}'";
      # validator = { source }: "echo 'validated ${source}'";
    };
  };

  nmt.script =
    let
      activationScript = pkgs.writeScript "activation" config.home.activation.validateFiles.data;
    in
    ''
      substitute ${activationScript} $TMPDIR/activate --subst-var TMPDIR
      chmod +x $TMPDIR/activate
      $TMPDIR/activate
    '';
}
