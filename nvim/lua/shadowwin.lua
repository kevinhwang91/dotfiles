local M = {}
local api = vim.api

local shadow_winblend = 70
local shadow_winid = -1

local function is_existed()
    local ret = shadow_winid > 0 and api.nvim_win_is_valid(shadow_winid)
    if ret and not vim.tbl_contains(api.nvim_tabpage_list_wins(0), shadow_winid) then
        api.nvim_win_close(shadow_winid, false)
        ret = false
    end
    return ret
end

function M.create()
    local ret = false
    if not is_existed() then
        local bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = 'wipe'
        shadow_winid = api.nvim_open_win(bufnr, false, {
            relative = 'editor',
            focusable = 0,
            width = vim.o.columns,
            height = vim.o.lines,
            row = 0,
            col = 0,
            style = 'minimal',
            zindex = 1
        })
        vim.wo[shadow_winid].winhl = 'Normal:Normal'
        vim.wo[shadow_winid].winbl = shadow_winblend
        ret = true
    end
    return ret
end

function M.close()
    local ret = false
    if is_existed() then
        api.nvim_win_close(shadow_winid, false)
        ret = true
    end
    return ret
end

function M.resize()
    if is_existed() then
        api.nvim_win_set_config(shadow_winid, {width = vim.o.columns, height = vim.o.lines})
    end
end

return M
