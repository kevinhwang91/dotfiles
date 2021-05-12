local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

function M.root(path)
    if path then
        path = fn.fnamemodify(path, ':p')
    else
        local ok, msg = pcall(api.nvim_buf_get_var, 0, 'git_dir')
        if ok then
            return fn.fnamemodify(msg, ':h')
        else
            path = api.nvim_buf_get_name(0)
        end
    end
    local prev = ''
    local ret = ''
    while path ~= prev do
        prev = path
        path = fn.fnamemodify(path, ':h')
        local t = path .. '/.git'
        if fn.isdirectory(t) == 1 then
            ret = path
            break
        end
    end
    return ret
end

function M.cd_root(path, window)
    local cd = window and 'lcd' or 'cd'
    local r = M.root(path)
    if r ~= '' then
        cmd(('%s %s'):format(cd, r))
    end
    return r
end

function M.root_exe(exec)
    local cur_winid
    local old_cwd = fn.getcwd()

    local r = M.cd_root(nil, true)
    if r ~= '' then
        cur_winid = api.nvim_get_current_win()
    end
    if type(exec) == 'string' then
        pcall(cmd, exec)
    elseif type(exec) == 'function' then
        pcall(exec)
    end

    if r ~= '' then
        fn.win_execute(cur_winid, 'lcd ' .. old_cwd)
    end
end

return M
