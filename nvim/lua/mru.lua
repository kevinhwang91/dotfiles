local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local db
local max
local bufs
local tmp_prefix

local function setup()
    db = vim.env.HOME .. '/.mru_file'
    max = 1000
    bufs = {}
    tmp_prefix = fn.tempname()

    M.store_buf(0)
    cmd([[
        aug Mru
            au!
            au BufEnter,BufAdd,FocusGained * lua require('mru').store_buf(vim.fn.expand('<abuf>', 1))
            au VimLeavePre,VimSuspend * lua require('mru').flush()
            au FocusLost * lua require('mru').flush()
        aug END
    ]])
end

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

local function write_file(file_path, lines)
    local file_path_ = file_path .. '_'
    local fd_ = io.open(file_path_, 'w')
    if fd_ then
        for _, line in ipairs(lines) do
            fd_:write(line .. '\n')
        end
        fd_:close()
        os.rename(file_path_, file_path)
    end
end

local function list(file)
    local mru_list = {}
    local fname_set = {[''] = true}

    local add_list = function(name)
        if not fname_set[name] then
            fname_set[name] = true
            if file_exists(name) then
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
        if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == '' then
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
    write_file(db, mru_list)
    return mru_list
end

function M.flush()
    write_file(db, list(db))
end

M.store_buf = (function()
    local count = 0
    return function(bufnr)
        bufnr = bufnr and tonumber(bufnr) or api.nvim_get_current_buf()
        table.insert(bufs, bufnr)
        count = (count + 1) % 10
        if count == 0 then
            local mru_list = list(db)
            write_file(db, mru_list)
        end
    end
end)()

setup()

return M
