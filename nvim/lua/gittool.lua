local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

function M.root(path)
    if path then
        path = fn.fnamemodify(path, ':p')
    else
        local git_dir = vim.b.git_dir
        if git_dir then
            return fn.fnamemodify(git_dir, ':h')
        else
            path = api.nvim_buf_get_name(0)
        end
    end
    local prev = ''
    local ret = ''
    while path ~= prev do
        prev = path
        path = fn.fnamemodify(path, ':h')
        local st = uv.fs_stat(path .. '/.git')
        local stt = st and st.type
        if stt and stt == 'directory' or stt == 'file' then
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
        cmd(('noa %s %s'):format(cd, r))
    end
    return r
end

function M.root_exe(exec, path)
    local cur_winid
    local old_cwd = uv.cwd()

    local r = M.cd_root(path, true)
    if r ~= '' then
        cur_winid = api.nvim_get_current_win()
    end
    local ok, res
    if type(exec) == 'string' then
        ok, res = pcall(cmd, exec)
    elseif type(exec) == 'function' then
        ok, res = pcall(exec)
    end
    if not ok then
        vim.notify(res, vim.log.levels.ERROR)
    end

    if r ~= '' then
        fn.win_execute(cur_winid, 'noa lcd ' .. old_cwd)
    end

    return ok and res or nil
end

return M
