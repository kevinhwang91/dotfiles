local M = {}
local api = vim.api

local hlslens
local config
local lens_backup

local override_lens = function(render, plist, nearest, idx, r_idx)
    local _ = r_idx
    local lnum, col = unpack(plist[idx])

    local text, chunks
    if nearest then
        text = ('[%d/%d]'):format(idx, #plist)
        chunks = {{' ', 'Ignore'}, {text, 'VM_Extend'}}
    else
        text = ('[%d]'):format(idx)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLens'}}
    end
    render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
    if hlslens then
        config = require('hlslens.config')
        lens_backup = config.override_lens
        config.override_lens = override_lens
        hlslens.start(true)
    end
end

function M.exit()
    if hlslens then
        config.override_lens = lens_backup
        hlslens.start(true)
    end
end

function M.mappings()
    api.nvim_buf_set_keymap(0, 'n', 'n', '<C-n>', {silent = true})
    api.nvim_buf_set_keymap(0, 'i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<Plug>(VM-I-Return)"]],
        {expr = true})
end

local function init()
    local ok, res = pcall(require, 'hlslens')
    if ok then
        hlslens = res
    end
end

init()

return M
