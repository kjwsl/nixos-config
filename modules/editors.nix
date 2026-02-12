{ config, pkgs, ... }:

{
  # Neovim configuration
  programs.neovim = {
    enable = true;

    # Set as default editor
    defaultEditor = true;

    # Enable vi/vim aliases
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Extra packages available to neovim
    extraPackages = with pkgs; [
      # Language servers and tools can be added here if needed
    ];

    # Configuration
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set termguicolors

      " Use system clipboard
      set clipboard=unnamedplus

      " Better split defaults
      set splitbelow
      set splitright
    '';
  };
}
