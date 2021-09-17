local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

function M.write_file(path, data, sync)
    local path_ = path .. '_'
    if sync then
        local fd = assert(uv.fs_open(path_, 'w', 438))
        assert(uv.fs_write(fd, data))
        assert(uv.fs_close(fd))
        uv.fs_rename(path_, path)
    else
        uv.fs_open(path_, 'w', 438, function(err_open, fd)
            assert(not err_open, err_open)
            uv.fs_write(fd, data, -1, function(err_write)
                assert(not err_write, err_write)
                uv.fs_close(fd, function(err_close, succ)
                    assert(not err_close, err_close)
                    if succ then
                        -- may rename by other syn write
                        uv.fs_rename(path_, path, function()
                        end)
                    end
                end)
            end)
        end)
    end
end

function M.follow_symlink(fname)
    fname = fname and fn.fnamemodify(fname, ':p') or api.nvim_buf_get_name(0)
    local linked_path = uv.fs_readlink(fname)
    if linked_path then
        cmd(('keepalt file %s'):format(linked_path))
    end
end

function M.clean_empty_bufs()
    local bufnrs = {}
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if not vim.bo[bufnr].modified and api.nvim_buf_get_name(bufnr) == '' then
            table.insert(bufnrs, bufnr)
        end
    end
    if #bufnrs > 0 then
        cmd('bw ' .. table.concat(bufnrs, ' '))
    end
end

function M.close_diff()
    local winids = vim.tbl_filter(function(winid)
        return vim.wo[winid].diff
    end, api.nvim_tabpage_list_wins(0))

    if #winids > 1 then
        for _, winid in ipairs(winids) do
            local ok, msg = pcall(api.nvim_win_close, winid, false)
            if not ok and msg:match('^Vim:E444:') then
                if api.nvim_buf_get_name(0):match('^fugitive://') then
                    cmd('Gedit')
                end
            end
        end
    end
end

-- My eyes can't get along with 2 spaces indent!
function M.kill2spaces()
    cmd('sil! GitGutterBufferDisable')
    vim.bo.ts = 4
    vim.bo.sw = 4
    local pos = api.nvim_win_get_cursor(0)
    cmd('%!unexpand -t2 --first-only')
    vim.bo.modified = false
    api.nvim_win_set_cursor(0, pos)
end

function M.killable_defer(timer, func, delay)
    vim.validate({
        timer = {timer, 'userdata', true},
        func = {func, 'function'},
        delay = {delay, 'number'}
    })
    local stop = function()
        timer:stop()
        if not timer:is_closing() then
            timer:close()
        end
    end
    if timer and timer:has_ref() then
        stop()
    end
    timer = uv.new_timer()
    timer:start(delay, 0, function()
        vim.schedule(function()
            if timer:has_ref() then
                stop()
                func()
            end
        end)
    end)
    return timer
end

M.cool_echo = (function()
    local timer
    return function(msg, hl, history, delay)
        -- TODO without schedule wrapper may echo prefix spaces
        local lastmsg
        vim.schedule(function()
            api.nvim_echo({{msg, hl}}, history, {})
            lastmsg = api.nvim_exec('5message', true)
        end)
        timer = M.killable_defer(timer, function()
            if lastmsg == api.nvim_exec('5message', true) then
                api.nvim_echo({{'', ''}}, false, {})
            end
        end, delay or 2500)
    end
end)()

function M.expandtab(str, bufnr)
    bufnr = bufnr or 0
    local ts = vim.bo[bufnr].ts
    local new = ''
    local pad = ' '
    local ti = 0
    local i = 1
    while true do
        i = str:find('\t', i)
        if not i then
            new = new .. str:sub(ti + 1)
            break
        end
        new = new .. str:sub(ti + 1, i - 1)
        new = new .. pad:rep(ts - #new % ts)
        ti = i
        i = i + 1
    end
    return new
end

M.highlight = (function()
    local ns = api.nvim_create_namespace('k-highlight')
    return function(bufnr, higroup, start, finish, delay)
        vim.highlight.range(bufnr, ns, higroup, start, finish)
        vim.defer_fn(function()
            pcall(api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)
        end, delay or 200)
    end
end)()

return M
