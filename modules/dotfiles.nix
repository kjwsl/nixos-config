{ config, pkgs, lib, ... }:

{
  # Handle remaining dotfiles that need to be managed as raw files
  # These are configurations that don't have good HM modules or are too complex to nixify
  
  home.file = {
    # Shell configurations that need raw access
    ".aliasrc".source = ../dotfiles/dot_aliasrc;
    ".bash_local".source = ../dotfiles/dot_bash_local;
    ".bashrc".source = ../dotfiles/dot_bashrc;
    ".profile".source = ../dotfiles/dot_profile;
    ".zshrc".source = ../dotfiles/dot_zshrc;
    ".zshenv".source = ../dotfiles/dot_zshenv;
    ".p10k.zsh".source = ../dotfiles/dot_p10k.zsh;
    
    # Development configurations
    ".clang-format".source = ../dotfiles/dot_clang-format;
    ".clang-tidy".source = ../dotfiles/dot_clang-tidy;
    ".envrc".source = ../dotfiles/dot_envrc;
    ".justfile".source = ../dotfiles/dot_justfile;
    
    # Directories that need raw file management
    ".cargo/config.toml".source = ../dotfiles/dot_cargo/config.toml;
    ".local/bin/start-screenpipe.ps1".source = ../dotfiles/dot_local/bin/executable_start-screenpipe.ps1;
    ".fonts".source = ../dotfiles/dot_fonts;
    ".vim".source = ../dotfiles/dot_vim;
    ".gemini".source = ../dotfiles/dot_gemini;
    
    # Global gitignore and other git files not handled by git module
    ".gitignore".source = ../dotfiles/dot_gitignore;
    ".gitmodules".source = ../dotfiles/dot_gitmodules;
    
    # IDE configurations
    ".config/ideavim".source = ../dotfiles/ideavim;
    ".config/zed".source = ../dotfiles/zed;
    
    # Doom Emacs (too complex to nixify)
    ".config/doom".source = ../dotfiles/doom;
  };
  
  # Note: The following are handled by chezmoi external repositories and should NOT be nixified:
  # - ~/.config/nvim (external git repo: https://github.com/kjwsl/nvim-config)
  # - ~/.oh-my-bash (external git repo: https://github.com/ohmybash/oh-my-bash)
  # 
  # These external dependencies are managed by chezmoi's .chezmoiexternal.toml
}