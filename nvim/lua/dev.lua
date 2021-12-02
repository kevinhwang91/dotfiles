local M = {}

local function inspect(v)
    local s
    local t = type(v)
    if t == 'nil' then
        s = 'nil'
    elseif t ~= 'string' then
        s = vim.inspect(v)
    else
        s = tostring(v)
    end
    return s
end

local kprint = function(...)
    local argc = select('#', ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, inspect(arg))
    end
    print(table.concat(msg_tbl, ' '))
end

function M.reload_module(m_name)
    m_name = vim.trim(m_name)
    for p in pairs(package.loaded) do
        if p:sub(1, #m_name) == m_name then
            package.loaded[p] = nil
        end
    end
end

local function init()
    _G.p = kprint
    local log = require('log')
    _G.info = log.info
    _G.ktime = vim.loop.hrtime
end

init()

return M
