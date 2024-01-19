return {
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text', config = true },
  },
  config = function()
    local dap = require 'dap'
    require('dap').adapters["pwa-node"] = {
      type = 'server',
      host = 'localhost',
      port = '5000',
      executable = {
        command = 'js-debug-adapter', -- As I'm using mason, this will be in the path
        args = { '5000' },
      }
    }

    for _, language in ipairs { 'typescript', "javascript" } do
      require('dap').configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          runtimeArgs ='ts-node-dev',
          program = 'src/app.ts',
          cwd = '/Users/sw02/soon/blitz/workspace/blitz-admin-api',
        },
      }
    end
  end,
}
