return {
  'echasnovski/mini.icons',
  lazy = true,
  init = function()
    local icons = require('mini.icons')
    icons.setup()

    package.preload['nvim-web-devicons'] = function()
      icons.mock_nvim_web_devicons()
      return package.loaded['nvim-web-devicons']
    end
  end,
}
