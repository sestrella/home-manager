{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;

  cfg = config.programs.herdr;

  tomlFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = [ lib.maintainers.amadejkastelic ];

  options.programs.herdr = {
    enable = lib.mkEnableOption "Herdr";

    package = lib.mkPackageOption pkgs "herdr" { nullable = true; };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = {
        onboarding = false;
        terminal = {
          default_shell = "nu";
          shell_mode = "auto";
          new_cwd = "follow";
        };
        theme = {
          name = "catppuccin";
          auto_switch = true;
          light_name = "catppuccin-latte";
          dark_name = "catppuccin";
        };
        ui = {
          sidebar_width = 32;
          agent_panel_sort = "priority";
          toast.delivery = "herdr";
          sound.enabled = true;
        };
        keys.prefix = "ctrl+b";
        keys.command = [
          {
            key = "prefix+l";
            type = "plugin_action";
            command = "example.layout.apply";
            description = "apply layout";
          }
        ];
      };
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/herdr/config.toml`.
        See <https://herdr.dev/docs/configuration/> for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    home.activation.validateHerdrConfig = mkIf (cfg.settings != { }) (
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] (
        let
          configPath = config.xdg.configFile."herdr/config.toml".source;
          herdr = if cfg.package == null then "herdr" else "${lib.getExe cfg.package}";
          jq = lib.getExe pkgs.jq;
        in
        ''
          echo "HERDR_CONFIG_PATH: ${configPath}\n"
          output=$(HERDR_CONFIG_PATH="${configPath}" ${herdr} server reload-config)

          echo "$output" | ${jq} -e '.result.status == "applied"' >/dev/null || {
            echo "$output" | ${jq} -r '.result.diagnostics[] | gsub("\n"; " ") | gsub(" ; keeping current.*$"; "")' >&2
            exit 1
          }
        ''
      )
    );

    xdg.configFile."herdr/config.toml" = mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "herdr-config.toml" cfg.settings;
    };
  };
}
