local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local shadow_winblend = 70
local shadow_winid = -1

local function existed()
    local ret = shadow_winid > 0 and api.nvim_win_is_valid(shadow_winid)
    if ret and not vim.tbl_contains(api.nvim_tabpage_list_wins(0), shadow_winid) then
        api.nvim_win_close(shadow_winid, false)
        ret = false
    end
    return ret
end

local function create()
    if existed() then
        return false
    end

    local bufnr = api.nvim_create_buf(false, true)
    vim.bo[bufnr].bufhidden = 'wipe'
    shadow_winid = api.nvim_open_win(bufnr, false, {
        relative = 'editor',
        focusable = 0,
        width = vim.o.columns,
        height = vim.o.lines,
        row = 0,
        col = 0,
        style = 'minimal'
    })
    vim.wo[shadow_winid].winhl = 'Normal:Normal'
    vim.wo[shadow_winid].winbl = shadow_winblend
    return true
end

local function close()
    if not existed() then
        return false
    end
    api.nvim_win_close(shadow_winid, false)
    return true
end

local function detect_other_wins(cur_winid)
    cur_winid = cur_winid or api.nvim_get_current_win()
    local bufnr = api.nvim_win_get_buf(cur_winid)
    if vim.bo[bufnr].buftype == 'nofile' then
        return true
    end

    for _, winid in ipairs(api.nvim_list_wins()) do
        bufnr = api.nvim_win_get_buf(winid)
        local buftype = vim.bo[bufnr].buftype
        if winid ~= cur_winid and api.nvim_win_get_config(winid).relative ~= '' and buftype ~=
            'nofile' or buftype == 'quickfix' then
            return true
        end
    end
    return false
end

function M.resize()
    if not existed() then
        return
    end
    api.nvim_win_set_config(shadow_winid, {width = vim.o.columns, height = vim.o.lines})
end

function M.toggle()
    local cur_winid = api.nvim_get_current_win()
    if existed() and shadow_winid == cur_winid then
        api.nvim_win_close(cur_winid, true)
        return
    end
    if api.nvim_win_get_config(cur_winid).relative == '' then
        if close() then
            cmd([[
                aug ShadowWindow
                    au!
                    au WinEnter * lua require('shadowwin').toggle()
                aug END
            ]])
        end
    elseif not detect_other_wins(cur_winid) then
        if create() then
            cmd([[
                aug ShadowWindow
                    au!
                    au VimResized * lua require('shadowwin').resize()
                    au WinEnter * lua vim.defer_fn(function() require('shadowwin').toggle() end, 50)
                aug END
            ]])
        end
    end
end

return M
