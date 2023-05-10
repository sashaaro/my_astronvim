return {
    "mfussenegger/nvim-dap",
    config = function() 
    local dapGoPort = os.getenv("GO_DAP_PORT")

    if not dapGoPort then dapGoPort = 9005 end

local dap = require "dap"
  dap.adapters.go = {
      type = "server",
      -- host = "127.0.0.1",
      port = dapGoPort
    }
  dap.configurations.go = {
      {
        type = "go",
        name = "delve container debug",
        request = "attach",
        mode = "remote",
        substitutepath = {{from = "${workspaceFolder}", to = "/opt/app"}}
      }
    }


-- dap.adapters.delve = {
--   type = 'server',
--   port = '${port}',
--   executable = {command = 'dlv', args = {'dap', '-l', '127.0.0.1:${port}'}}
-- }

-- dap.adapters.php = {
--   type = "executable",
--   command = "node",
--   args = {"/opt/vscode-php-debug/out/phpDebug.js"}
-- }

-- dap.configurations.php = {
--   {
--     type = "php",
--     request = "launch",
--     name = "Listen for Xdebug",
--     port = 9003,
--     pathMappings = {["/opt/app"] = "${workspaceFolder}"}
--   }
-- }
       return dap
    end
}
