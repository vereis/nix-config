{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.jira = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.jira.enable {
    home.packages = with pkgs; [ jira-cli-go ];
  };
}
