{
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        diagnostic = {
          "<leader>j" = "goto_next";
          "<leader>k" = "goto_prev";
        };
	lspBuf = {
	  K = "hover";
          gD = "references";
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
	};
	extra = [
         {
           action = "<CMD>LspStop<Enter>";
           key = "<leader>lx";
         }
         {
           action = "<CMD>LspStart<Enter>";
           key = "<leader>ls";
         }
         {
           action = "<CMD>LspRestart<Enter>";
           key = "<leader>lr";
         }
         {
           action = {
             __raw = "require('telescope.builtin').lsp_definitions()";
           };
           key = "gd";
         }
         {
           action = "<CMD>Lspsaga hover_doc<Enter>";
           key = "K";
         }
        ];
      };
    };


    lsp-lines.enable = true;
    lsp-status.enable = true;
    coq-nvim.enable = true;
    dap.enable = true;

    nvim-bqf.enable = true;
    
    # Diagnostics
    treesitter.enable = true;
    treesitter-context.enable = true;
    
    # AI Stuff
    wtf.enable = true;
    copilot-lua.enable = true;
    copilot-cmp.enable = true;
    copilot-chat.enable = true;

    #autocomplete
    cmp-vim-lsp.enable = true;
    cmp-treesitter.enable = true;
    cmp_luasnip.enable = true;
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
    };
  };
}
