-- :lua dofile('/home/sasha/.config/nvim/lua/user/myplug/lua/init.lua').setup()
local api = vim.api
local fn = vim.fn
local M = {}

function M.tmux_split_window(shell)
    if not (type(shell) == "string") then shell = "$SHELL" end
    return function(command)
        return "tmux split-window -p 30 " .. shell .. " -c -- \"" .. command ..
                   "; " .. shell .. ";\""
    end
end

function M.docker_compose_exec(service)
    return function(command)
        return "docker compose exec " .. service .. " " .. command
    end
end

-- function M.dlv(service)
--     return function(command)
--         local dap = require "dap"
--
--         goLaunchAdapter = {
--             type = "executable",
--             command = "node",
--             args = {"/opt/vscode-go/dist/debugAdapter.js"}
--         }
--
--         goLaunchConfig = {
--             type = "go",
--             request = "attach",
--             mode = "remote",
--             name = "Remote Attached Debugger",
--             dlvToolPath = os.getenv('HOME') .. "/go/bin/dlv", -- Or wherever your local delve lives.
--             remotePath = {
-- "/opt/app"
--             },
--             port = {your_exposed_container_port},
--             pathMappings = {["/opt/app"] = "${workspaceFolder}"}
--             cwd = vim.fn.getcwd()
--         }
--         local session = dap.launch(goLaunchAdapter, goLaunchConfig);
--         if session == nil then
--            io.write("Error launching adapter");
--         end
--         dap.repl.open()
--         
--         return "go version"
--     end
-- end

local is_go_test_file = function(file) return string.find(file, "_test.go$") end

local is_go_func_line = function(line) return line:find("^func") end

local detect_go_test = function(file, line)
    local _, _, testName = line:find(" Test([a-zA-Z0-9]+)%(")
    if not testName then testName = "Test" .. testName end
    return testName
end

local notify = astronvim.notify

local configs = {
    {
        file_filter = is_go_test_file,
        line_filter = is_go_func_line,
        builder = {
            detect_go_test,
            function(testName)
                return "go test -v ./... -testify.m " .. testName
            end, M.docker_compose_exec("debug"), function(command)
                return
            end, M.tmux_split_window()
        }
    }
}

local function run_test_on_cursor()
    local filename = fn.bufname()
    local start_line, start_col = unpack(api.nvim_win_get_cursor(0))
    local line = fn.getline(start_line)
    -- 
    --
    -- local command = ""
    -- for k, conf in pairs(configs) do 
    --   if not conf.file_filter(filename) then
    --     goto continue
    --   end
    --
    --   if not conf.line_filter(line) then
    --     goto continue
    --   end
    --
    --   command = table.remove(conf.builder, 1)()
    --   for k, step in pairs(conf.builder) do
    --     command = step(command)
    --   end
    --
    --   break
    --
    --   ::continue::
    -- end
    --
    -- if not command then
    --   notify("wrong")
    -- else
    --   io.popen(command)
    -- end

    if not is_go_test_file(filename) then
        notify("not go test file")
        return
    end

    if not is_go_func_line(line) then
        notify("no func")
        return
    end

    testName = detect_go_test(filename, line)

    if not testName then
        notify("no test name")
        return
    end

    command = "go test -v ./... -testify.m " .. testName
    command = M.docker_compose_exec("debug")(command)
    command = command .. " | /home/sasha/GolandProjects/gotest/gotest"
    command = M.tmux_split_window()(command)
    io.popen(command)
end

local function setup_commands()
    local cmd = api.nvim_create_user_command
    cmd("MyTestRun", function(opts) run_test_on_cursor() end, {})
end

function M.setup(user_config) setup_commands() end

return M
