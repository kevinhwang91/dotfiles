local M = {}

local api = vim.api

-- WIP
-- http://rrthomas.github.io/lrexlib/manual.html
local rex = require('rex_pcre2')

function M.search_all(pattern, bufnr)
    bufnr = bufnr and bufnr or api.nvim_get_current_buf()
    local pos = {}
    local start = vim.loop.hrtime()
    local re = rex.new(pattern)
    -- local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local len = api.nvim_buf_line_count(bufnr)
    local j = 1
    while j <= len do
        local i = 1
        local line = api.nvim_buf_get_lines(bufnr, j - 1, j, false)[1]
        while i <= #line do
            local s, e = re:find(line, i)
            if s then
                table.insert(pos, {s, e})
                i = e + 1
            else
                break
            end
        end
        j = j + 1
    end
    ldebug('find')
    -- local text = table.concat(lines, '\n')
    -- rex.gsub(text, pattern, '', function(s, e, _)
    --     table.insert(pos, {s, e})
    --     return false, false
    -- end)
    -- ldebug('gsub')
    ldebug(vim.loop.hrtime() - start)
    return pos
end

return M
