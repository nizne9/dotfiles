# Typst in this nvim config

Lightweight setup. No preview, no PDF embed, no wrapper plugin.

## What you get

- LSP (tinymist) on `*.typ` buffers: completion, hover, go-to-definition,
  references, rename, code actions, document symbols
- Diagnostics from the typst compiler
- Format-on-demand via `<leader>fm` (delegates to `typst fmt` via LSP)
- 2-space indent, 80-col guide

## How it works

- `lua/plugins/lsp.lua` lists `tinymist` in `servers`; mason installs it
  on first nvim launch (the binary lands in `~/.local/share/nvim/mason/bin/`).
- `lua/plugins/typst.lua` declares per-filetype options and enables
  tinymist at module load via `vim.lsp.enable('tinymist', true)`. A
  `FileType` autocmd applies buffer-local options when a `.typ` file
  opens. The LSP attach is then driven by mason-lspconfig's
  `automatic_enable` (also set in `lsp.lua`); the autocmd itself does
  not start the client.
- Highlighting comes from tinymist's LSP semantic tokens, not from a
  tree-sitter grammar. Math mode and inline code blocks look plain.

## Why so minimal?

- `nvim-treesitter` is archived; remaining typst grammar forks are
  stale (last commits 2023–2025; typst is on 0.14.2). Loading a stale
  grammar would give wrong highlights, not better ones.
- Browser preview / PDF embed would each add ≥1 plugin and break
  "lightweight" without adding editing capability.

## If tinymist isn't responding

```sh
:Mason              # check tinymist install status
:LspInfo            # confirm tinymist is attached
:Lazy sync          # re-resolve plugin specs
```

If `Mason` shows tinymist is missing, install manually:

```sh
:MasonInstall tinymist
```

## If you want more (NOT installed by default)

- **Browser preview**: `typst-preview.nvim`
- **Snippets**: `L3MON4D3/LuaSnip` with a typst snippet collection
- **Better highlighting**: evaluate `syntastica-typst` (active fork of
  the tree-sitter approach) — trade-off: heavier startup, more correct
  math mode / inline code coloring
- **PDF embed**: `nvim-pdf-tools` or `img-pane.nvim`
