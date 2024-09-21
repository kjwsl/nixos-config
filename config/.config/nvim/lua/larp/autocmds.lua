vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', {}),
  desc = 'Hightlight selection on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach', {}),
  desc = 'Attach LSP',
  pattern = '*',
  callback = function()
    vim.keymap.set('n', 'gh', function()
      vim.diagnostic.open_float({
        source = true,
        format = function(diagnostic)
          return string.format('%s [%s]', diagnostic.message, diagnostic.source)
        end,
        border = 'rounded',
        severity_sort = true,
        focus_id = 'diagnostic',
      })
    end, { desc = 'Get diagnostics' })
  end,
})
