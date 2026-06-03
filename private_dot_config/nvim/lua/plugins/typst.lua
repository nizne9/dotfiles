-- Lightweight typst support: delegate to tinymist (LSP) via mason-lspconfig.
-- No tree-sitter grammar, no preview, no wrapper plugin. See TYPST.md
-- for the full rationale.

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
