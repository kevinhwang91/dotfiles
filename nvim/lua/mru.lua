local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

local utils = require('kutils')

local db
local max
local bufs
local tmp_prefix

local function list(file)
    local mru_list = {}
    local fname_set = {[''] = true}

    local add_list = function(name)
        if not fname_set[name] then
            fname_set[name] = true
            if uv.fs_stat(name) then
                if #mru_list < max then
                    table.insert(mru_list, name)
                else
                    return false
                end
            end
        end
        return true
    end

    while #bufs > 0 do
        local bufnr = table.remove(bufs)
        if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].bt == '' then
            local fname = api.nvim_buf_get_name(bufnr)
            if not fname:match(tmp_prefix) then
                if not add_list(fname) then
                    break
                end
            end
        end
    end

    local fd = io.open(file, 'r')
    if fd then
        for fname in fd:lines() do
            if not add_list(fname) then
                break
            end
        end
        fd:close()
    end
    return mru_list
end

function M.list()
    local mru_list = list(db)
    utils.write_file(db, table.concat(mru_list, '\n'))
    return mru_list
end

M.flush = function()
    return function(sync)
        local timer
        return function()
            utils.killable_defer(timer, function()
                utils.write_file(db, table.concat(list(db), '\n'), sync)
            end, 50)
        end
    end
end

M.store_buf = (function()
    local count = 0
    return function()
        local bufnr = fn.expand('<abuf>', 1)
        bufnr = bufnr and tonumber(bufnr) or api.nvim_get_current_buf()
        table.insert(bufs, bufnr)
        count = (count + 1) % 10
        if count == 0 then
            M.list()
        end
    end
end)()

local function init()
    db = vim.env.HOME .. '/.mru_file'
    max = 1000
    bufs = {}
    tmp_prefix = uv.os_tmpdir()

    M.store_buf()
    cmd([[
        aug Mru
            au!
            au BufEnter,BufAdd,FocusGained * lua require('mru').store_buf()
            au VimLeavePre * lua require('mru').flush(true)
            au VimSuspend * lua require('mru').flush()
            au FocusLost * lua require('mru').flush()
        aug END
    ]])
end

init()

return M
