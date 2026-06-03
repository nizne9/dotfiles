-- Format Lua with stylua on save.
-- lua_ls intentionally omits formatting; stylua fills that role.

local has_stylua = vim.fn.executable('stylua') == 1

vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('format_lua_stylua', { clear = true }),
  pattern = '*.lua',
  callback = function(args)
    if not has_stylua then return end
    local view = vim.fn.winsaveview()
    vim.cmd('silent !stylua ' .. vim.fn.shellescape(args.file))
    vim.cmd('edit!')
    vim.fn.winrestview(view)
  end,
  desc = 'Format Lua with stylua on save',
})
