local M = {}

local parser_available = {}

local function lang_for_buf(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == '' then
    return nil
  end
  return vim.treesitter.language.get_lang(filetype)
end

local function normal_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ''
end

function M.has_parser(lang)
  if not lang then
    return false
  end
  if parser_available[lang] then
    return true
  end

  local ok, loaded = pcall(vim.treesitter.language.add, lang)
  if ok and loaded == true then
    parser_available[lang] = true
    return true
  end
  return false
end

function M.has_query(lang, name)
  if not M.has_parser(lang) then
    return false
  end

  local ok, query = pcall(vim.treesitter.query.get, lang, name)
  return ok and query ~= nil
end

function M.has_buf_query(bufnr, name)
  local lang = lang_for_buf(bufnr)
  return M.has_query(lang, name)
end

local function has_lsp_folds(bufnr)
  return next(vim.lsp.get_clients({
    bufnr = bufnr,
    method = 'textDocument/foldingRange',
  })) ~= nil
end

local function set_window_folds(win, method, expr)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  vim.wo[win][0].foldmethod = method
  vim.wo[win][0].foldexpr = expr or '0'
end

function M.configure_folds(bufnr, win)
  if not normal_buffer(bufnr) then
    return
  end

  if M.has_buf_query(bufnr, 'folds') then
    set_window_folds(win, 'expr', 'v:lua.vim.treesitter.foldexpr()')
  elseif has_lsp_folds(bufnr) then
    set_window_folds(win, 'expr', 'v:lua.vim.lsp.foldexpr()')
  else
    set_window_folds(win, 'manual')
  end
end

function M.start_highlight(bufnr)
  if not normal_buffer(bufnr) then
    return
  end

  local lang = lang_for_buf(bufnr)
  if M.has_query(lang, 'highlights') then
    pcall(vim.treesitter.start, bufnr, lang)
  end
end

function M.configure_buffer(bufnr)
  if not normal_buffer(bufnr) then
    return
  end

  M.start_highlight(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    M.configure_folds(bufnr, win)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true })

  vim.treesitter.language.register('bash', { 'sh', 'bash' })
  vim.treesitter.language.register('json', { 'jsonc' })

  vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
    group = group,
    callback = function(ev)
      M.configure_buffer(ev.buf)
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(ev)
      M.configure_buffer(ev.buf)
    end,
  })
end

return M
