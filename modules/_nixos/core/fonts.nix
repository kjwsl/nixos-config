# System-wide font configuration.
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font"];
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
    };
  };
}
