# Declares top-level options shared across all configurations.
# Other modules read config.username and config.email instead of using specialArgs.
{lib, ...}: {
  options = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "ray";
      description = "Primary username across all configurations.";
    };

    email = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "kjwdev01@gmail.com";
      description = "Primary email address used in user-facing config (git, jujutsu, etc.).";
    };

    github_username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "larpios";
      description = "Primary GitHub username across all configurations.";
    };
  };
}
