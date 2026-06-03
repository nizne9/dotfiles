-- Lightweight typst support: delegate to tinymist (LSP) via
-- mason-lspconfig. No tree-sitter grammar (upstream is archived;
-- remaining forks are stale relative to typst 0.12+), no preview, no
-- wrapper plugin.

return {
  {
    'Myriad-Dreamin/tinymist',
    ft = 'typst',
    -- mason-lspconfig's automatic_enable flips vim.lsp.enable for every
    -- server in `servers` that is currently installed. In a headless /
    -- short-lived nvim session the install can lag the enable call, so
    -- we also enable here, on first typst buffer. pcall swallows the
    -- case where tinymist is not yet registered in vim.lsp.config.
    config = function()
      pcall(vim.lsp.enable, 'tinymist', true)
    end,
  },
}
