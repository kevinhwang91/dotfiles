local M = {}
local api = vim.api

local function get_defaults(mode)
    return {noremap = true, silent = mode ~= 'c'}
end

function M.map(mode, lhs, rhs, opts)
    opts = opts or get_defaults(mode)
    api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function M.bmap(bufnr, mode, lhs, rhs, opts)
    opts = opts or get_defaults(mode)
    api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

return M
