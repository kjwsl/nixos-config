{ config, pkgs, lib, ... }:

{
  # Handle remaining dotfiles that need to be managed as raw files
  # These are configurations that don't have good HM modules or are too complex to nixify
  
  home.file = {
    # Shell configurations that need raw access
    ".aliasrc".source = ~/.local/share/chezmoi/dot_aliasrc;
    ".bash_local".source = ~/.local/share/chezmoi/dot_bash_local;
    ".bashrc".source = ~/.local/share/chezmoi/dot_bashrc;
    ".profile".source = ~/.local/share/chezmoi/dot_profile;
    ".zshrc".source = ~/.local/share/chezmoi/dot_zshrc;
    ".zshenv".source = ~/.local/share/chezmoi/dot_zshenv;
    ".p10k.zsh".source = ~/.local/share/chezmoi/dot_p10k.zsh;
    
    # Development configurations
    ".clang-format".source = ~/.local/share/chezmoi/dot_clang-format;
    ".clang-tidy".source = ~/.local/share/chezmoi/dot_clang-tidy;
    ".envrc".source = ~/.local/share/chezmoi/dot_envrc;
    ".justfile".source = ~/.local/share/chezmoi/dot_justfile;
    
    # Directories that need raw file management
    ".cargo".source = ~/.local/share/chezmoi/dot_cargo;
    ".local".source = ~/.local/share/chezmoi/dot_local;
    ".fonts".source = ~/.local/share/chezmoi/dot_fonts;
    ".vim".source = ~/.local/share/chezmoi/dot_vim;
    ".gemini".source = ~/.local/share/chezmoi/dot_gemini;
    
    # Global gitignore and other git files not handled by git module
    ".gitignore".source = ~/.local/share/chezmoi/dot_gitignore;
    ".gitmodules".source = ~/.local/share/chezmoi/dot_gitmodules;
    
    # IDE configurations
    ".config/ideavim".source = ~/.local/share/chezmoi/dot_config/ideavim;
    ".config/zed".source = ~/.local/share/chezmoi/dot_config/zed;
    
    # Doom Emacs (too complex to nixify)
    ".config/doom".source = ~/.local/share/chezmoi/dot_config/doom;
  };
  
  # Note: The following are handled by chezmoi external repositories and should NOT be nixified:
  # - ~/.config/nvim (external git repo: https://github.com/kjwsl/nvim-config)
  # - ~/.oh-my-bash (external git repo: https://github.com/ohmybash/oh-my-bash)
  # 
  # These external dependencies are managed by chezmoi's .chezmoiexternal.toml
}