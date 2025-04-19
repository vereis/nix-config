{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/awesome.nix
    ../../../modules/home/firefox.nix
    ../../../modules/home/git.nix
    ../../../modules/home/jira.nix
    ../../../modules/home/kitty.nix
    ../../../modules/home/ncmpcpp.nix
    ../../../modules/home/neovim.nix
    ../../../modules/home/ranger.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/zsh.nix
    ../../../modules/services/winget.nix
  ];

  modules.git.enable = true;
  modules.jira.enable = true;
  modules.kitty.enable = true;
  modules.kitty.fontSize = 13;
  modules.ncmpcpp.enable = true;
  modules.neovim.enable = true;
  modules.ranger.enable = true;
  modules.tmux.enable = true;
  modules.zsh.enable = true;
  modules.winget.enable = true;
  modules.winget.packages = [
    "AutoHotkey.AutoHotkey"
    "Mozilla.Firefox"
    "Microsoft.Office"
    "Microsoft.OneDrive"
    "Microsoft.Edge"
    "Valve.Steam"
    "Microsoft.VCRedist.2015+.x64"
    "Microsoft.VCRedist.2015+.x86"
    "AltDrag.AltDrag"
    "Discord.Discord"
    "Spotify.Spotify"
    "qutebrowser.qutebrowser"
    "SlackTechnologies.Slack"
    "Microsoft.Teams"
    "Microsoft.AppInstaller"
    "Microsoft.UI.Xaml.2.8"
    "Microsoft.VCLibs.Desktop.14"
    "Microsoft.WindowsTerminal"
    "Microsoft.WSL"
    "7zip.7zip"
  ];
}
