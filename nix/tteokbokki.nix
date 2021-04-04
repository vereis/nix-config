{ pkgs, ... }:

{
  home.packages = [
    pkgs.bash
    pkgs.openssh
    pkgs.tree
    pkgs.direnv
    pkgs.zsh
    pkgs.fzf
    pkgs.ripgrep
    pkgs.xclip
    pkgs.dbeaver
    pkgs.neofetch
    pkgs.firefox
    # docker must be installed manually on host system
    pkgs.docker-compose
    pkgs.httpie
  ];

  programs.home-manager.enable = true;

  home.username = "chris";
  home.homeDirectory = "/home/chris";
  home.stateVersion = "21.05";

  pam.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file.".dotfiles" = {
    source = builtins.fetchGit {
      url = "https://github.com/vereis/dotfiles";
      ref = "master";
      rev = "779c7a4c1aec7e9099b33a890d7c229f4564c79a";
    };
  };

  programs.neovim = {
    enable = true;
        
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython = true;
    withPython3 = true;

    plugins = [ pkgs.fzf pkgs.ripgrep ];

    extraConfig = ''
      let g:config_dir='~/.dotfiles/nvim'
      let g:plugin_dir='~/.nvim_plugins'
      execute "exe 'source' '" . g:config_dir . "/init.vim'"
    '';
  };
  
  programs.zsh.enable = true;

  programs.zsh.enableCompletion = true;
  programs.zsh.enableAutosuggestions = true;

  programs.zsh.autocd = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.plugins = [ "git" "sudo" ];
  programs.zsh.oh-my-zsh.theme = "afowler";
  programs.zsh.loginExtra = ''
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi
    
    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/.local/bin" ] ; then
        PATH="$HOME/.local/bin:$PATH"
    fi
    
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi
    cd ~
  '';

  # WSL2 requires this for X Server integration
  programs.zsh.initExtra = ''
    WSL_HOST=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    export WSL_HOST=$WSL_HOST
    export DISPLAY=$WSL_HOST:0.0
    export LIBGL_ALWAYS_INDIRECT=1

    # This is neccessary because the default `fzf` command fails on busybox distros
    export FZF_DEFAULT_COMMAND="sort -u <( rg --files ) <( git ls-files )"
  '';

  # home-manager's zsh doesn't support the syntax highlighting plugin, so fetch it ourselves...
  programs.zsh.plugins = [
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-syntax-highlighting";
        rev = "0.7.1";
        sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
      };
    }
  ];

  programs.keychain.enable = true;
  programs.keychain.enableBashIntegration = true;
  programs.keychain.enableZshIntegration = true;

  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;
  programs.fzf.enableZshIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.direnv.enableZshIntegration = true;

  services.lorri.enable = true;
}
