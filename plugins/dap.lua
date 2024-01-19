return {
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text', config = true },
    { 'mxsdev/nvim-dap-vscode-js' },
  },
  config = function()
    local dap = require 'dap'
    require('dap-vscode-js').setup({
    debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter',
    debugger_cmd = { 'js-debug-adapter' },
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
})
    dap.adapters["pwa-node"] = {
      type = 'server',
      host = 'localhost',
      port = '5000',
      executable = {
        command = 'js-debug-adapter',
        args = { '5000' },
      }
    }
    for _, language in ipairs { 'typescript', "javascript" } do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = 'src/app.ts',
        },
      }
    end
  end,
}
