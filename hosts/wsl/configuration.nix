{
  username,
  pkgs,
  ...
}:

{
  imports = [
    ../linux/configuration.nix
  ];

  wsl.defaultUser = username;
  wsl.enable = true;
  environment.systemPackages = [ pkgs.xclip ]; # needed for CLI clipboard support
  environment.variables.BROWSER = "explorer.exe";
}
