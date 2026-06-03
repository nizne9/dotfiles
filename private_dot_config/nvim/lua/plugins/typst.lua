-- Lightweight typst support: delegate everything to tinymist (LSP) and
-- typst itself (compiler/formatter). No wrapper plugins, no tree-sitter
-- grammar, no preview. See docs/superpowers/specs/2026-06-03-typst-nvim-design.md
-- for the rationale.
--
-- tinymist is installed/managed by mason-lspconfig (see lua/plugins/lsp.lua).

-- NOTE on plugin specs in this file:
--   The 4th spec uses `dir = vim.fn.stdpath('config')` so lazy.nvim
--   treats it as a local plugin (avoids the "missing plugin" clone
--   attempt). The `name` is just a label. It uses `init` rather than
--   `config` because the spec has no event/cmd/keys/ft trigger — with
--   `config` lazy would never call it, and the augroup would never
--   register. The real work is the FileType autocmd registered in
--   spec #4. The 1st and 3rd specs (nvim-treesitter and typst.nvim)
--   are deliberately disabled, kept as future hooks.

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- INTENTIONALLY NOT LISTED: the plugin is archived. We rely on
    -- tinymist's LSP semantic tokens for highlighting instead.
    enabled = false,
  },
  {
    -- Empty spec entry for tinymist itself: lsp.lua already triggers
    -- automatic_enable = true, but we register a spec so lazy can track
    -- it. The real work happens in lsp.lua; this file only owns per-buffer
    -- options.
    'Myriad-Dreamin/tinymist',
    lazy = true,
    config = function()
      -- No-op: tinymist is configured by lspconfig elsewhere. This spec
      -- exists so lazy.nvim tracks the plugin in the lockfile.
    end,
  },
  {
    'nvim-typst/typst.nvim',
    -- Future hook for community wrappers (e.g. completion sources). Not
    -- enabled today; kept as a placeholder comment so the next iteration
    -- has an obvious location.
    enabled = false,
  },
  {
    -- Per-filetype settings for *.typ buffers. This block is what gives
    -- typst its editor feel. (See file header for why `dir`/`init` are used.)
    dir = vim.fn.stdpath('config'),
    name = 'typst-local-settings',
    init = function()
      -- Enable tinymist once at module load. The nvim 0.12 recommended
      -- pattern is config(); enable() at load time, then lsp.start() per
      -- buffer in a FileType autocmd.
      pcall(vim.lsp.enable, 'tinymist', true)

      local group = vim.api.nvim_create_augroup('typst_local_settings', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'typst',
        callback = function(args)
          local bufnr = args.buf

          -- 2-space indent matches the typst community template default.
          vim.bo[bufnr].tabstop = 2
          vim.bo[bufnr].shiftwidth = 2
          vim.bo[bufnr].softtabstop = 2
          vim.bo[bufnr].expandtab = true

          -- 80-col guide. textwidth is buffer-scoped. colorcolumn is
          -- window-scoped (vim.wo is indexed by window-id, not bufnr —
          -- translate via bufwinid; 0 means buffer has no window yet).
          vim.bo[bufnr].textwidth = 80
          local winid = vim.fn.bufwinid(bufnr)
          if winid ~= 0 then
            vim.wo[winid].colorcolumn = '80'
          end

          -- The LSP start is handled by vim.lsp.enable (called in init
          -- above) plus mason-lspconfig's automatic_enable; both register
          -- a global FileType autocmd that starts tinymist for typst
          -- buffers. No per-buffer start is needed here.
        end,
        desc = 'Apply per-buffer options and attach tinymist to typst files',
      })
    end,
  },
}
