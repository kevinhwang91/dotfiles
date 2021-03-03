local M = {}
local hlslens = require('hlslens')
local hlslens_started = false
local line_lens_bak

local override_line_lens = function(lnum, loc, idx, r_idx, count, hls_ns)
    local _ = r_idx
    local text, chunks
    if loc ~= 'c' then
        text = string.format('[%d]', idx)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLens'}}
    else
        text = string.format('[%d/%d]', idx, count)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLensCur'}}
    end
    vim.api.nvim_buf_clear_namespace(0, -1, lnum - 1, lnum)
    vim.api.nvim_buf_set_extmark(0, hls_ns, lnum - 1, -1, {virt_text = chunks})
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
