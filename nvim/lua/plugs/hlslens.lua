local M = {}
local hlslens = require('hlslens')
local hlslens_started = false
local line_lens_bak

local override_line_lens = function(render, pos_list, nearest, idx, r_idx)
    local _ = r_idx
    local lnum, col = unpack(pos_list[idx])

    local text, chunks
    if nearest then
        text = string.format('[%d/%d]', idx, #pos_list)
        chunks = {{'  ', 'Normal'}, {text, 'HlSearchLensCur'}}
        render.set_virt_or_float(0, lnum - 1, col - 1, chunks)
    else
        text = string.format('[%d]', idx)
        chunks = {{'  ', 'Normal'}, {text, 'HlSearchLens'}}
        render.set_virt(0, lnum - 1, -1, chunks)
    end
end

function M.vmlens_start()
    vim.api.nvim_buf_set_keymap(0, 'n', 'n', '<C-n>', {silent = true})
    if not hlslens then
        return
    end
    local config = hlslens.config()
    line_lens_bak = config.override_line_lens
    config.override_line_lens = override_line_lens
    hlslens_started = config.started
    if hlslens_started then
        hlslens.disable()
    end
    hlslens.start()
end

function M.vmlens_exit()
    vim.api.nvim_buf_del_keymap(0, 'n', 'n')
    if not hlslens then
        return
    end
    local config = hlslens.config()
    config.override_line_lens = line_lens_bak
    hlslens.disable()
    if hlslens_started then
        hlslens.start()
    end
end

return M
