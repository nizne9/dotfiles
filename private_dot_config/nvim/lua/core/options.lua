-- ============================================================================
--  基础选项
-- ============================================================================

-- Leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 编辑
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.signcolumn = 'yes'
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 缩进
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 视觉
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400

-- 搜索
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- 补全（0.11+ 内置 LSP 补全）
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Treesitter 折叠（0.11+ 内置）
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
