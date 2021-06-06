local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

function M.file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

function M.write_file(file_path, lines)
    local file_path_ = file_path .. '_'
    local fd_ = io.open(file_path_, 'w')
    if fd_ then
        for _, line in ipairs(lines) do
            fd_:write(line, '\n')
        end
        fd_:close()
        os.rename(file_path_, file_path)
    end
end

function M.follow_symlink(fname)
    fname = fname and fn.fnamemodify(fname, ':p') or api.nvim_buf_get_name(0)
    if fn.getftype(fname) ~= 'link' then
        return
    end
    cmd(('keepalt file %s'):format(fn.fnameescape(fn.resolve(fname))))
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

function M.nav_fold(forward, cnt)
    local wv = fn.winsaveview()
    cmd([[norm! m`]])
    local cur_l, cur_c
    while cnt > 0 do
        if forward then
            cmd('keepj norm! ]z')
        else
            cmd('keepj norm! zk')
        end
        cur_l, cur_c = unpack(api.nvim_win_get_cursor(0))
        if forward then
            cmd('keepj norm! zj_')
        else
            cmd('keepj norm! [z_')
        end
        cnt = cnt - 1
    end

    local cur_l1, cur_c1 = unpack(api.nvim_win_get_cursor(0))
    if cur_l == cur_l1 and cur_c == cur_c1 then
        fn.winrestview(wv)
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
        vim.schedule(function()
            api.nvim_echo({{msg, hl}}, history, {})
        end)
        timer = M.killable_defer(timer, function()
            api.nvim_echo({{'', ''}}, false, {})
        end, delay or 2500)
    end
end)()

return M
