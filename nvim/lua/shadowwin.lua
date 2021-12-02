local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

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

local function create()
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

local function close()
    local ret = false
    if is_existed() then
        api.nvim_win_close(shadow_winid, false)
        ret = true
    end
    return ret
end

local function should_toggle(cur_winid)
    local ret = true
    cur_winid = cur_winid or api.nvim_get_current_win()
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        local bt = vim.bo[api.nvim_win_get_buf(winid)].bt
        if bt == '' and winid ~= cur_winid and fn.win_gettype(winid) == 'popup' or bt == 'quickfix' then
            ret = false
            break
        end
    end
    return ret
end

function M.resize()
    if is_existed() then
        api.nvim_win_set_config(shadow_winid, {width = vim.o.columns, height = vim.o.lines})
    end
end

function M.toggle()
    local cur_winid = api.nvim_get_current_win()
    if is_existed() and shadow_winid == cur_winid then
        api.nvim_win_close(cur_winid, true)
    else
        if fn.win_gettype(cur_winid) ~= 'popup' then
            if close() then
                cmd([[
                    aug ShadowWindow
                        au!
                        au WinEnter * lua require('shadowwin').toggle()
                    aug END
                ]])
            end
        elseif should_toggle(cur_winid) then
            if create() then
                cmd([[
                    aug ShadowWindow
                        au!
                        au VimResized * lua require('shadowwin').resize()
                        au WinEnter * lua vim.defer_fn(require('shadowwin').toggle, 50)
                    aug END
                ]])
            end
        end
    end
end

return M
