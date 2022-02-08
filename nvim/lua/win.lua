local M = {}

local api = vim.api
local fn = vim.fn

local mru_list

function M.record()
    local cur_winid = api.nvim_get_current_win()
    local new_list = {}
    local win_set = {}

    local add2new = function(winid)
        if not win_set[winid] and api.nvim_win_is_valid(winid) then
            table.insert(new_list, winid)
            win_set[winid] = true
        end
    end

    add2new(cur_winid)

    for _, winid in ipairs(mru_list) do
        add2new(winid)
    end

    mru_list = new_list
end

function M.go2recent()
    local cur_winid = api.nvim_get_current_win()
    for _, winid in ipairs(mru_list) do
        if cur_winid ~= winid and api.nvim_win_is_valid(winid) then
            local win_type = fn.win_gettype(winid)
            if win_type ~= 'popup' then
                fn.win_gotoid(winid)
                break
            end
        end
    end
end

local function init()
    mru_list = {}
end

init()

return M
