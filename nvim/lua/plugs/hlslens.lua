local M = {}
local hlslens = require('hlslens')
local hlslens_started = false
local line_lens_bak

local override_line_lens = function(pos_list, nearest, idx, r_idx, hls_ns)
    local _ = r_idx
    local lnum = pos_list[idx][1]
    local count = #pos_list

    local text, chunks
    if nearest then
        text = string.format('[%d/%d]', idx, count)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLensCur'}}
    else
        text = string.format('[%d]', idx)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLens'}}
    end
    vim.api.nvim_buf_set_extmark(0, hls_ns, lnum - 1, -1, {
        virt_text = chunks,
        virt_text_pos = 'overlay',
        virt_text_hide = true
    })
end

function M.vmlens_start()
    vim.api.nvim_buf_set_keymap(0, 'n', 'n', '<C-n>', {silent = true})
    if not hlslens then
        return
    end
    local config = hlslens.get_config()
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
    local config = hlslens.get_config()
    config.override_line_lens = line_lens_bak
    hlslens.disable()
    if hlslens_started then
        hlslens.start()
    end
end

return M
