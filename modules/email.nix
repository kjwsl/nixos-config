{ config, pkgs, ... }:

{
  programs.himalaya = {
    enable = true;
    # settings = {}; # Global settings if needed
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
        # extensions = [ ... ];
      };
    };
  };

  accounts.email = {
    accounts = {
      personal = {
        primary = true;
        address = "kjwdev01@gmail.com";
        realName = "Kwak Jungwoo";
        flavor = "gmail.com";
        passwordCommand = "cat /run/secrets/gmail_password"; # Placeholder for sops-nix
        himalaya.enable = true;
        thunderbird.enable = true;
      };

      work = {
        address = "kjwsl@fatherslab.com";
        realName = "Kwak Jungwoo";
        userName = "kjwsl@fatherslab.com";
        flavor = "outlook.office365.com";
        passwordCommand = "cat /run/secrets/work_password"; # Placeholder for sops-nix
        himalaya.enable = true;
        thunderbird.enable = true;
      };
    };
  };
}
