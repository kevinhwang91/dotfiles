local M = {}
local cmd = vim.cmd
local api = vim.api

local g = vim.g

local gittool = require('gittool')

function M.find_git()
    local root = gittool.root()
    if root ~= '' then
        cmd('au! FindGitForPlugs BufRead | aug! FindGitForPlugs')
        M.find_git = nil
        M.git_relation()
    end
end

function M.git_relation()
    local config = require('plugs.config')
    vim.defer_fn(function()
        g.gitgutter_highlight_linenrs = 1
        g.gitgutter_signs = 0
        g.gitgutter_map_keys = 0
        g.gitgutter_close_preview_on_escape = 1
        cmd('pa vim-gitgutter')
        config.gitgutter()
        cmd('doautoall gitgutter BufEnter')
    end, 300)

    local init_fugitive = function()
        local fugitive = _G.packer_plugins['vim-fugitive']
        if not fugitive.loaded then
            fugitive.loaded = true
            require('plugs.fugitive')
            for _, del_cmd in ipairs(fugitive.commands) do
                cmd('delc ' .. del_cmd)
            end
            cmd('pa vim-fugitive')
            cmd('doautoall fugitive BufReadCmd')
            cmd('doautoall fugitive BufRead')
        end
    end

    if api.nvim_buf_get_name(0):find('/.git/index$') then
        init_fugitive()
    else
        vim.defer_fn(init_fugitive, 1000)
    end

    -- .editorconfig is almost in git repositories
    vim.defer_fn(function()
        g.EditorConfig_exclude_patterns = {'fugitive://.*'}
        g.EditorConfig_preserve_formatoptions = 1
        cmd('pa editorconfig-vim')
        cmd('EditorConfigReload')
    end, 1200)
end

local function init()
    cmd([[
        aug FindGitForPlugs
            au!
            au BufRead * sil! lua require('plugs.manual').find_git()
        aug END
    ]])
end

init()

return M
