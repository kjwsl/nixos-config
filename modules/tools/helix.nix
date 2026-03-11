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
            enable = true;
            display-messages = true;
            display-progress-messages = true;
            display-inlay-hints = true;
          };
          auto-pairs = false;
          indent-guides.render = true;
          end-of-line-diagnostics = "hint";
          inline-diagnostics = {
            cursor-line = "warning";
          };
        };
        keys.normal = {
          # space.f.f = "file_picker";
          # space.c.a = "code_action";
          # space.f.b = "buffer_picker";
          # space.f.s = "symbol_picker";
          # space.f.c = "changed_file_picker";
          # space.f.d = "diagnostics_picker";
          # space.f."." = "last_picker";
          space.w.w = ":w";
          space.w.q = ":wq";
          space.q.q = ":q";
          V = [
            "select_mode"
            "extend_line_below"
          ];
        };
        keys.insert = {
          z.x = [
            "normal_mode"
            "collapse_selection"
          ]; # `zx` to escape
        };
        keys.select = {
          z.x = [
            "normal_mode"
            "collapse_selection"
          ]; # `zx` to escape
        };
      };
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "${pkgs.alejandra}";
            };
          }
        ];
      };
    };
  };
}
