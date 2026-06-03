-- tokyonight must load at startup so other plugins see the correct colorscheme.

return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = false,
      })
      vim.cmd.colorscheme('tokyonight')
    end,
  },
}
