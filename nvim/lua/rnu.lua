local M = {}
local api = vim.api
local cmd = vim.cmd

local delay = 50
local focus_lock = 1

local function set_win_rnu(val)
    if api.nvim_win_get_config(0).relative ~= '' then
        return
    end

    local cur_winid = api.nvim_get_current_win()
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if cur_winid == winid and vim.wo[cur_winid].nu then
            if vim.bo.bt ~= 'quickfix' then
                vim.wo[cur_winid].rnu = val
            end
        elseif api.nvim_win_get_config(0).relative == '' and vim.wo[winid].nu then
            vim.wo[winid].rnu = false
        end
    end
end

local function set_rnu()
    set_win_rnu(true)
    cmd('hi! link FoldColumn NONE')
end

local function unset_rnu()
    set_win_rnu(false)
    cmd('hi! link FoldColumn Ignore')
end

function M.focus(gained)
    focus_lock = focus_lock - 1
    vim.defer_fn(function()
        if focus_lock >= 0 then
            if gained then
                set_rnu()
            else
                unset_rnu()
            end
        end
        focus_lock = focus_lock + 1
    end, delay)
end

function M.win_enter()
    set_rnu()
end

function M.scmd_enter()
    set_win_rnu(false)
    cmd('redraws')
end

function M.scmd_leave()
    set_win_rnu(true)
end

return M
