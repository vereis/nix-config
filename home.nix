{ config, pkgs, ... }:

{
  programs.home-manager = {
    enable = true;
  };

  home.packages = with pkgs; [
    pkgs.compton
    pkgs.zsh
    pkgs.fzf
    pkgs.kitty
    pkgs.ctags
    pkgs.neofetch

    # The neovim section in `programs` implicit adds this...
    # pkgs.neovim
  ];
  
  programs = {
    git = {
      enable = true;
      userName = "Chris Bailey";
      userEmail = "me@cbailey.co.uk";
    };

    zsh = {
      enable = true;
      shellAliases = {
        vim = "nvim";
      };

      # automatically cd without actual cd command
      autocd = true;

      enableCompletion = true;
      enableAutosuggestions = true;

      oh-my-zsh = {
        enable = true;
	plugins = [ "git" "sudo" ];
	theme = "flazz";
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    kitty = {
      enable = true;
      settings = {
        font_family = "Fira Code Regular";
        bold_font = "Fira Code Bold";
        italic_font = "Fira Code Italic";
	font_size = 11;
        window_padding_width = 24;
	copy_on_select = "clipboard";

	# monokai soda
        background = "#191919";
        foreground = "#c4c4b5";
        cursor = "#f6f6ec";
        selection_background = "#343434";
        color0 = "#191919";
        color8 = "#615e4b";
        color1 = "#f3005f";
        color9 = "#f3005f";
        color2 = "#97e023";
        color10 = "#97e023";
        color3 = "#fa8419";
	color11 = "#dfd561";
	color4 = "#9c64fe";
        color12 = "#9c64fe";
        color5 = "#f3005f";
        color13 = "#f3005f";
        color6 = "#57d1ea";
        color14 = "#57d1ea";
        color7 = "#c4c4b5";
        color15 = "#f6f6ee";
        selection_foreground = "#191919";
      };
    };

   neovim = {
     enable = true;

     viAlias = true;
     vimAlias = true;
     vimdiffAlias = true;

     withNodeJs = true;
     withPython = true;
     withPython3 = true;

     configure = {
       # I don't want to port my vim rc to NixOS so I just
       # expect the config file to be in the usual directory...
       customRC = ''
         exe 'source' '~/.config/nvim/init.vim'
       '';
     };
   };
  };

  services = {
    # compton renamed to picom
    picom = {
      enable = true;
    };
  };
}
