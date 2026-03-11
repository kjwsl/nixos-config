{...}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    programs.helix = {
      enable = true;
      package = pkgs.evil-helix;
      settings = {
        editor = {
          evil = true; # evil-helix option
          line-number = "relative";
          lsp = {
            display-messages = true;
            display-progress-messages = true;
            display-inlay-hints = true;
          };
          auto-pairs = false;
          indent-guides.render = true;
          whitespace.render = "all";
        };
        keys.normal = {
          space.W = ":w";
          space.Q = ":q";
          z.x = "normal_mode"; # `zx` to escape
          # space.f.f = "file_picker";
          # space.c.a = "code_action";
          # space.f.b = "buffer_picker";
          # space.f.s = "symbol_picker";
          # space.f.c = "changed_file_picker";
          # space.f.d = "diagnostics_picker";
          # space.f."." = "last_picker";
          # space.w.w = ":w";
          # space.w.q = ":wq";
          # space.q.q = ":q";
        };
      };
    };
  };
}
