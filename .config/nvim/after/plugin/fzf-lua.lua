local config_path = vim.fn.stdpath('config')

-- # Config
vim.keymap.set('', '<leader>hfc', '<cmd>FzfLua files cwd=' .. config_path .. '<cr>', { silent = true, desc = 'Find Config Directory' })
vim.keymap.set('', '<leader>hgc', '<cmd>FzfLua live_grep cwd=' .. config_path .. '<cr>', { silent = true, desc = 'Grep Config' })

-- # Basic
vim.keymap.set('', '<leader>ff', '<cmd>FzfLua files<cr>', { silent = true, desc = 'Find Files' })
vim.keymap.set('', '<leader>fo', '<cmd>FzfLua oldfiles<cr>', { silent = true, desc = 'Find Old Files' })
vim.keymap.set('', '<leader>fq', '<cmd>FzfLua quickfix<cr>', { silent = true, desc = 'Quickfix List' })
vim.keymap.set('', '<leader>fb', '<cmd>FzfLua buffers<cr>', { silent = true, desc = 'Find Buffers' })
vim.keymap.set('', '<leader>gg', '<cmd>FzfLua live_grep<cr>', { silent = true, desc = 'Grep Current Directory' })
vim.keymap.set('', '<leader>gb', '<cmd>FzfLua lgrep_curbuf<cr>', { silent = true, desc = 'Grep Inside Current Buffer' })
vim.keymap.set('', '<leader>f:', '<cmd>FzfLua commands<cr>', { silent = true, desc = 'Find Commands' })
vim.keymap.set('', '<leader>fj', '<cmd>FzfLua jumps<cr>', { silent = true, desc = 'Find Jumps' })
vim.keymap.set('', '<leader>fxm', '<cmd>FzfLua marks<cr>', { silent = true, desc = 'Find Marks' })

-- # LSP
vim.keymap.set('', 'gH', '<cmd>FzfLua lsp_document_diagnostics<cr>', { silent = true, desc = 'Find Diagnostics' })
vim.keymap.set('', '<leader>f*', '<cmd>FzfLua lsp_finder<cr>', { silent = true, desc = 'Grep Symbols (LSP)' })
vim.keymap.set('', '<leader>ft', '<cmd>FzfLua lsp_typedefs<cr>', { silent = true, desc = 'Find Typedefs' })
vim.keymap.set('', '<leader>fsd', '<cmd>FzfLua lsp_document_symbols<cr>', { silent = true, desc = 'Find Document Symbols' })
vim.keymap.set('', '<leader>fsw', '<cmd>FzfLua lsp_workspace_symbols<cr>', { silent = true, desc = 'Find Workspace Symbols' })
vim.keymap.set('', '<leader>fd', '<cmd>FzfLua lsp_definitions<cr>', { silent = true, desc = 'Find Definitions' })
vim.keymap.set('', '<leader>fD', '<cmd>FzfLua lsp_declarations<cr>', { silent = true, desc = 'Find Declarations' })
vim.keymap.set('', '<leader>ca', '<cmd>FzfLua lsp_code_actions<cr>', { silent = true, desc = 'Code Actions' })
vim.keymap.set('', '<leader>fxic', '<cmd>FzfLua lsp_incoming_calls<cr>', { silent = true, desc = 'Find Incoming Calls' })
vim.keymap.set('', '<leader>fxoc', '<cmd>FzfLua lsp_outgoing_calls<cr>', { silent = true, desc = 'Find Outgoing Calls' })

-- Misc.
vim.keymap.set('', '<leader>fgc', '<cmd>FzfLua git_commits<cr>', { silent = true, desc = 'Find Git Commits' })
vim.keymap.set('', '<leader>fgf', '<cmd>FzfLua git_files<cr>', { silent = true, desc = 'Find Git Files' })
vim.keymap.set('', '<leader>fh', '<cmd>FzfLua helptags<cr>', { silent = true, desc = 'Find Helptags' })
vim.keymap.set('', '<leader>fk', '<cmd>FzfLua keymaps<cr>', { silent = true, desc = 'Find Keymaps' })
vim.keymap.set('', '<leader>fm', '<cmd>FzfLua manpages<cr>', { silent = true, desc = 'Find Manpages' })
vim.keymap.set('', '<leader>fr', '<cmd>FzfLua resume<cr>', { silent = true, desc = 'Resume Search' })
vim.keymap.set('', '<leader>fxa', '<cmd>FzfLua autocmds<cr>', { silent = true, desc = 'Find Manpages' })
vim.keymap.set('', '<leader>fxc', '<cmd>FzfLua changes<cr>', { silent = true, desc = 'Find Changes' })
vim.keymap.set('', '<leader>fxr', '<cmd>FzfLua registers<cr>', { silent = true, desc = 'Find Registers' })
vim.keymap.set('', '<leader>fxt', '<cmd>FzfLua colorschemes<cr>', { silent = true, desc = 'Find Themes' })

-- # Grep
vim.keymap.set('', '<leader>gC', '<cmd>FzfLua grep_cWORD<cr>', { silent = true, desc = 'Grep Cursor (Case Sensitive)' })
vim.keymap.set('', '<leader>gc', '<cmd>FzfLua grep_cword<cr>', { silent = true, desc = 'Grep Cursor (Case Insensitive)' })
vim.keymap.set('', '<leader>gv', '<cmd>FzfLua grep_visual<cr>', { silent = true, desc = 'Grep Selection' })
