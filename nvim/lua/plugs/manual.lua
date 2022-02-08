local M = {}
local cmd = vim.cmd

function M.find_git()
    local root = require('gittool').root()
    if root ~= '' then
        cmd('au! FindGit4Plugs BufRead | aug! FindGit4Plugs')
        M.find_git = nil
        M.git_relation()
    end
end

function M.git_relation()
    vim.defer_fn(function()
        cmd('PackerLoad gitsigns.nvim')
    end, 300)

    -- .editorconfig is almost in git repositories
    vim.defer_fn(function()
        cmd('PackerLoad editorconfig-vim')
    end, 1200)
end

local function init()
    cmd([[
        aug FindGit4Plugs
            au!
            au BufRead * lua require('plugs.manual').find_git()
        aug END
    ]])
end

init()

return M
