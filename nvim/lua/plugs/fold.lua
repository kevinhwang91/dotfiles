local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

-- local parsers = require('nvim-treesitter.parsers')
local utils = require('kutils')

local bl_ft
local anyfold_prefer_ft

local function setup()
    vim.g.anyfold_fold_display = 0
    vim.g.anyfold_identify_comments = 0
    vim.g.anyfold_motion = 0

    bl_ft = {'', 'man', 'markdown', 'git'}
    anyfold_prefer_ft = {'python'}
    cmd([[
        aug FoldLoad
            au!
            au FileType * lua require('plugs.fold').defer_load()
        aug END
    ]])

    cmd([[com! -nargs=0 Fold lua require('plugs.fold').do_fold()]])
    _G.foldtext = M.foldtext
    M.defer_load()
end

local function find_win_except_float(bufnr)
    local winid = fn.bufwinid(bufnr)
    if fn.win_gettype(winid) == 'popup' then
        local f_winid = winid
        winid = 0
        for _, wid in ipairs(api.nvim_list_wins()) do
            if f_winid ~= wid and api.nvim_win_get_buf(wid) == bufnr then
                winid = wid
                break
            end
        end
    end
    return winid
end

function M.do_fold()
    local ret = false
    local fsize
    local filename = api.nvim_buf_get_name(0)
    if vim.tbl_contains(anyfold_prefer_ft, vim.bo.ft) then
        fsize = fn.getfsize(filename)
        if 0 < fsize and fsize < 524288 then
            cmd('AnyFoldActivate')
            ret = true
        end
    end
    if not ret then
        -- nvim_treesitter#foldexpr() format may block
        -- if parsers.has_parser() then
        --     vim.wo.foldmethod = 'expr'
        --     vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        -- elseif not fsize then
        if not fsize then
            fsize = fn.getfsize(filename)
            if 0 < fsize and fsize < 524288 then
                cmd('AnyFoldActivate')
            end
        end
    end
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldtext = 'v:lua.foldtext()'
    vim.b.loaded_fold = true
end

function M.defer_load()
    if vim.b.loaded_fold or vim.wo.foldmethod == 'diff' or vim.bo.bt ~= '' or
        vim.tbl_contains(bl_ft, vim.bo.ft) then
        return
    end
    vim.wo.foldmethod = 'manual'
    local bufnr = tonumber(fn.expand('<abuf>')) or api.nvim_get_current_buf()
    local winid = find_win_except_float(bufnr)
    if winid ~= 0 then
        vim.defer_fn(function()
            if api.nvim_win_is_valid(winid) and api.nvim_buf_is_loaded(bufnr) and
                vim.wo[winid].foldmethod == 'manual' then
                local ok = pcall(function()
                    return api.nvim_buf_get_var(bufnr, 'loaded_fold')
                end)
                if not ok then
                    local cur_bufnr = api.nvim_get_current_buf()
                    if cur_bufnr == bufnr then
                        M.do_fold()
                    else
                        cmd(('au FoldLoad BufEnter <buffer=%d> ++once %s'):format(bufnr,
                            [[lua require('plugs.fold').do_fold()]]))
                    end
                end
            end
        end, 1500)
    end
end

function M.foldtext()
    local fs, fe = vim.v.foldstart, vim.v.foldend
    local fs_lines = api.nvim_buf_get_lines(0, fs - 1, fe - 1, false)
    local fs_line = fs_lines[1]
    for _, line in ipairs(fs_lines) do
        if line:match('%w') then
            fs_line = line
            break
        end
    end
    local pad = ' '
    fs_line = utils.expandtab(fs_line)
    local gutter_size = fn.screenpos(0, api.nvim_win_get_cursor(0)[1], 1).curscol -
                            fn.win_screenpos(0)[2]
    local width = api.nvim_win_get_width(0) - gutter_size
    local fold_info = (' %d lines %s'):format(1 + fe - fs, (' + '):rep(vim.v.foldlevel))
    local spaces = pad:rep(width - #fold_info - api.nvim_strwidth(fs_line))
    return fs_line .. spaces .. fold_info
end

setup()

return M
