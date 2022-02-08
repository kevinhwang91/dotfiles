local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

local debounce = require('debounce')

M.termcodes = setmetatable({}, {
    __index = function(tbl, k)
        local k_upper = k:upper()
        local v_upper = rawget(tbl, k_upper)
        local c = v_upper or api.nvim_replace_termcodes(k, true, false, true)
        rawset(tbl, k, c)
        if not v_upper then
            rawset(tbl, k_upper, c)
        end
        return c
    end
})

M.ansi = setmetatable({}, {
    __index = function(t, k)
        local v = M.render_str('%s', k)
        rawset(t, k, v)
        return v
    end
})

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

M.render_str = (function()
    local ansi = {
        black = 30,
        red = 31,
        green = 32,
        yellow = 33,
        blue = 34,
        magenta = 35,
        cyan = 36,
        white = 37
    }
    local gui = vim.o.termguicolors

    local function color2csi24b(color_num, fg)
        local r = math.floor(color_num / 2 ^ 16)
        local g = math.floor(math.floor(color_num / 2 ^ 8) % 2 ^ 8)
        local b = math.floor(color_num % 2 ^ 8)
        return ('%d;2;%d;%d;%d'):format(fg and 38 or 48, r, g, b)
    end

    local function color2csi8b(color_num, fg)
        return ('%d;5;%d'):format(fg and 38 or 48, color_num)
    end

    local color2csi = gui and color2csi24b or color2csi8b

    return function(str, group_name, def_fg, def_bg)
        vim.validate({
            str = {str, 'string'},
            group_name = {group_name, 'string'},
            def_fg = {def_fg, 'string', true},
            def_bg = {def_bg, 'string', true}
        })
        local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, gui)
        if not ok or
            not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or
                hl.underline) then
            return str
        end
        local fg, bg
        if hl.reverse then
            fg = hl.background ~= nil and hl.background or nil
            bg = hl.foreground ~= nil and hl.foreground or nil
        else
            fg = hl.foreground
            bg = hl.background
        end
        local escape_prefix = ('\x1b[%s%s%s'):format(hl.bold and ';1' or '',
            hl.italic and ';3' or '', hl.underline and ';4' or '')

        local escape_fg, escape_bg = '', ''
        if fg and type(fg) == 'number' then
            escape_fg = ';' .. color2csi(fg, true)
        elseif def_fg and ansi[def_fg] then
            escape_fg = ansi[def_fg]
        end
        if bg and type(bg) == 'number' then
            escape_fg = ';' .. color2csi(bg, false)
        elseif def_bg and ansi[def_bg] then
            escape_fg = ansi[def_bg]
        end

        return ('%s%s%sm%s\x1b[m'):format(escape_prefix, escape_fg, escape_bg, str)
    end
end)()

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

M.cool_echo = (function()
    local lastmsg
    local debounced
    return function(msg, hl, history, wait)
        -- TODO without schedule wrapper may echo prefix spaces
        vim.schedule(function()
            api.nvim_echo({{msg, hl}}, history, {})
            lastmsg = api.nvim_exec('5message', true)
        end)
        if not debounced then
            debounced = debounce(function()
                if lastmsg == api.nvim_exec('5message', true) then
                    api.nvim_echo({{'', ''}}, false, {})
                end
            end, wait or 2500)
        end
        debounced()
    end
end)()

function M.expandtab(str, ts, start)
    start = start or 1
    local new = str:sub(1, start - 1)
    -- without check type to improve performance
    -- if str and type(str) == 'string' then
    local pad = ' '
    local ti = start - 1
    local i = start
    while true do
        i = str:find('\t', i, true)
        if not i then
            if ti == 0 then
                new = str
            else
                new = new .. str:sub(ti + 1)
            end
            break
        end
        if ti + 1 == i then
            new = new .. pad:rep(ts)
        else
            local append = str:sub(ti + 1, i - 1)
            new = new .. append .. pad:rep(ts - api.nvim_strwidth(append) % ts)
        end
        ti = i
        i = i + 1
    end
    -- end
    return new
end

M.highlight = (function()
    local ns = api.nvim_create_namespace('k-highlight')

    local function do_unpack(pos)
        vim.validate({
            pos = {
                pos, function(p)
                    local t = type(p)
                    return t == 'table' or t == 'number'
                end, 'must be table or number type'
            }
        })
        local row, col
        if type(pos) == 'table' then
            row, col = unpack(pos)
        else
            row = pos
        end
        col = col or 0
        return row, col
    end

    return function(bufnr, hl_goup, start, finish, opt, delay)
        local row, col = do_unpack(start)
        local end_row, end_col = do_unpack(finish)
        if end_col then
            end_col = math.min(math.max(fn.col({end_row + 1, '$'}) - 1, 0), end_col)
        end
        local o = {hl_group = hl_goup, end_row = end_row, end_col = end_col}
        o = opt and vim.tbl_deep_extend('keep', o, opt) or o
        local id = api.nvim_buf_set_extmark(bufnr, ns, row, col, o)
        vim.defer_fn(function()
            pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
        end, delay or 300)
    end
end)()

return M
