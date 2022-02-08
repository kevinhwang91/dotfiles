local M = {}
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local utils = require('kutils')
local debounce = require('debounce')

local db
local last_hist
local max
local hist_bufs
local hist_bufs_size

local function list(file, limit)
    local hist_list = {}
    local hist_set = {}
    limit = tonumber(limit) or max

    local add_list = function(line)
        line = vim.trim(line)
        if line ~= '' then
            if #hist_list < limit then
                if not hist_set[line] then
                    table.insert(hist_list, line)
                    hist_set[line] = #hist_list
                end
            else
                return false
            end
        end
        return true
    end

    local i = #hist_bufs
    while i > 0 do
        local hist = hist_bufs[i]
        if not add_list(hist) then
            break
        end
        i = i - 1
    end

    local fd = io.open(file, 'r')
    if fd then
        for line in fd:lines() do
            if not add_list(line) then
                break
            end
        end
        fd:close()
    end
    return #hist_list == 0 and {''} or hist_list
end

function M.reload()
    local hist_list = list(db, hist_bufs_size)
    for i = #hist_list, 1, -1 do
        fn.histadd(':', hist_list[i])
    end
    last_hist = hist_list[1]
end

M.enable_reload = (function()
    local debounced
    return function()
        if api.nvim_get_mode().mode == 'c' then
            if not debounced then
                debounced = debounce(M.reload, 50)
            end
            debounced()
        elseif fn.exists('#CmdHist#CmdlineEnter#:') == 0 then
            cmd([[au CmdHist CmdlineEnter : ++once lua vim.schedule(require('cmdhist').reload)]])
        end
    end
end)()

function M.list()
    local hist_list = list(db)
    for i = math.min(#hist_list, hist_bufs_size), 1, -1 do
        fn.histadd(':', hist_list[i])
    end
    last_hist = hist_list[1]
    return hist_list
end

M.flush = (function()
    local debounced
    return function(force)
        if #hist_bufs == 0 then
            return
        end
        if force then
            utils.write_file(db, table.concat(list(db), '\n'), true)
        else
            if not debounced then
                debounced = debounce(function()
                    if #hist_bufs > 0 then
                        utils.write_file(db, table.concat(list(db), '\n'))
                        hist_bufs = {}
                    end
                end, 50)
            end
            debounced()
        end
    end
end)()

M.store = (function()
    local count = 0
    return function()
        local hist = fn.histget(':')
        if hist ~= last_hist then
            table.insert(hist_bufs, hist)
            last_hist = hist
            count = (count + 1) % 10
            if count == 0 then
                M.flush()
            end
        end
    end
end)()

function M.fire_leave()
    vim.schedule(M.store)
end

local function init()
    local data_dir = fn.stdpath('data')
    fn.mkdir(data_dir, 'p')
    db = data_dir .. '/cmdhist'
    max = 100000
    hist_bufs = {}
    hist_bufs_size = 50
    M.reload()

    cmd([[
        aug CmdHist
            au!
            au CmdlineLeave : lua require('cmdhist').fire_leave()
            au VimLeavePre,VimSuspend * lua require('cmdhist').flush(true)
            au FocusLost * lua require('cmdhist').flush()
            au FocusGained * lua require('cmdhist').enable_reload()
        aug END
    ]])
end

init()

return M
