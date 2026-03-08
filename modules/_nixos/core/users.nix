# System user accounts.
{config, ...}: {
  users.users.ray = {
    isNormalUser = true;
    description = "ray";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
}
