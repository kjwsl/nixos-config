return {
  {

    'lambdalisue/vim-suda',
    config = function()
      vim.keymap.set('n', '<leader><leader>w', ':SudaWrite<CR>', { noremap = true })
      vim.keymap.set('n', '<leader><leader>r', ':SudaRead<CR>', { noremap = true })
    end,
  },
  {
    'ziontee113/color-picker.nvim',
    event = 'BufEnter',
    keys = {
      { '<leader>uc' },
      { '<c-e>uc', mode = 'i' },
    },
    config = function()
      local get_opts = function(tbl)
        local new_opts = { noremap = true, silent = true }
        for k, v in pairs(tbl) do
          new_opts[k] = v
        end
        return new_opts
      end
      vim.keymap.set('n', '<leader>uc', '<cmd>PickColor<cr>', get_opts({ desc = 'Open Color Picker' }))
      vim.keymap.set('i', '<c-e>uc', '<cmd>PickColor<cr>', get_opts({ desc = 'Open Color Picker' }))
    end,
  },
  {
    'LintaoAmons/bookmarks.nvim',
    -- tag = "v0.5.4", -- optional, pin the plugin at specific version for stability
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
      { 'stevearc/dressing.nvim' }, -- optional: to have the same UI shown in the GIF
    },

    config = function()
      vim.keymap.set({ 'n', 'v' }, 'mm', '<cmd>BookmarksMark<cr>', { desc = 'Mark current line into active BookmarkList.' })
      vim.keymap.set({ 'n', 'v' }, 'mo', '<cmd>BookmarksGoto<cr>', { desc = 'Go to bookmark at current active BookmarkList' })
      vim.keymap.set({ 'n', 'v' }, 'ma', '<cmd>BookmarksCommands<cr>', { desc = 'Find and trigger a bookmark command.' })
      vim.keymap.set({ 'n', 'v' }, 'mg', '<cmd>BookmarksGotoRecent<cr>', { desc = 'Go to latest visited/created Bookmark' })
    end,
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      { 'junegunn/fzf', build = './install --bin' },
    },
    config = function()
      local fzf = require('fzf-lua')
      -- calling `setup` is optional for customization
      fzf.setup({
        'fzf-native',
        hls = {
          Rg = {
            cmd = 'rg --vimgrep --no-heading --smart-case',
            previewer = 'bat',
          },
        },
      })

      vim.keymap.set({ 'i' }, '<C-x><C-f>', function()
        fzf.complete_file({
          cmd = 'rg --files',
          winopts = { preview = { hidden = 'nohidden' } },
        })
      end, { silent = true, desc = 'Fuzzy complete file' })
    end,
  },
  {
    'mfussenegger/nvim-dap',
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'BurntSushi/ripgrep',
      'sharkdp/fd',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      telescope.setup({
        defaults = {
          path_display = { 'truncate ' }, -- Example configuration
          mappings = {
            i = {
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
      })
    end,
  },
  {
    -- # Provides various useful modules
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      -- mini.align is a module that aligns text in visual mode
      require('mini.align').setup({})

      -- mini.ai is a module that provides more text objects, especially for ones that start with `a(round)`, and `i(nside)`
      -- Check out the documentation for more information (https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md)
      require('mini.ai').setup({})
    end,
  },
  {
    -- 1. Highlights TODO, FIXME, etc. in your code
    -- 2. Provides a list of all the highlights in your project
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {

      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      require('todo-comments').setup({})
      vim.keymap.set('n', ']t', function()
        require('todo-comments').jump_next()
      end, { desc = 'Next todo comment' })

      vim.keymap.set('n', '[t', function()
        require('todo-comments').jump_prev()
      end, { desc = 'Previous todo comment' })

      -- You can also specify a list of valid jump keywords

      vim.keymap.set('n', ']t', function()
        require('todo-comments').jump_next({ keywords = { 'ERROR', 'WARNING' } })
      end, { desc = 'Next error/warning todo comment' })
    end,
  },
  {
    'gelguy/wilder.nvim',
    config = true,
  },
}
