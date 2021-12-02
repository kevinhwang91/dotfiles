local M = {}
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

function M.cur_file()
    local has_forest = fn.executable('git-forest') == 1
    if has_forest then
        g.flog_build_log_command_fn = nil
    end
    cmd('Flog -raw-args=--follow -path=%')
    if has_forest then
        g.flog_build_log_command_fn = 'flog#build_git_forest_log_command'
    end
end

local function init()
    g.flog_default_arguments = {max_count = 1000}
    local has_forest = fn.executable('git-forest') == 1
    if has_forest then
        g.flog_build_log_command_fn = 'flog#build_git_forest_log_command'
    end
end

init()

return M
