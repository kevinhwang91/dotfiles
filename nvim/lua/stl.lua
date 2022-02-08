local M = {}
local fn = vim.fn
local api = vim.api
local uv = vim.loop

local mode_map = setmetatable({
    n = {'N', '%#StatusLineNormal#'},
    i = {'I', '%#StatusLineInsert#'},
    R = {'R', '%#StatusLineReplace#'},
    v = {'V', '%#StatusLineVisual#'},
    V = {'VL', '%#StatusLineVisual#'},
    ['\x16'] = {'VB', '%#StatusLineVisual#'}, -- ^V
    s = {'S', '%#StatusLineVisual#'},
    S = {'SL', '%#StatusLineVisual#'},
    ['\x13'] = {'SB', '%#StatusLineVisual#'}, -- ^S
    c = {'C', '%#StatusLineCommand#'},
    ['!'] = {'!', '%#StatusLineCommand#'},
    r = {'P', '%#StatusLineCommand#'},
    t = {'T', '%#StatusLineInsert#'}
}, {
    __index = function(t, k)
        return t[k:sub(1, 1)] or t['n']
    end
})

local function readonly(bufnr)

    -- local tick = 0
    -- local threshold = 1000000000
    -- local last
    -- local loaded = false
    local ret
    if vim.bo[bufnr].readonly then
        ret = uv.fs_stat(api.nvim_buf_get_name(bufnr or 0)) and '' or ''
    end
    return ret
end

local function quickfix(winid)
    winid = winid or api.nvim_get_current_win()
    local qf_type = fn.getwininfo(winid)[1].loclist == 1 and 'loc' or 'qf'
    local what = {nr = 0, size = 0}
    local info = qf_type == 'loc' and fn.getloclist(0, what) or fn.getqflist(what)
    what = {nr = '$'}
    local nr = (qf_type == 'loc' and fn.getloclist(0, what) or fn.getqflist(what)).nr
    local prefix = qf_type == 'loc' and 'Location' or 'Quickfix'
    local title = vim.w[winid].quickfix_title or ''
    return ('%s (%d/%d) [%d] %s'):format(prefix, info.nr, nr, info.size, title)
end

local function filename(width)
    local bufname = api.nvim_buf_get_name(0)
    local fugitive_name = vim.b.fugitive_fname
    if not fugitive_name then
        if bufname:match('^fugitive:') and fn.exists('*FugitiveReal') == 1 then
            fugitive_name = fn.fnamemodify(fn.FugitiveReal(bufname), ':t') .. ' '
            vim.b.fugitive_fname = fugitive_name
        end
    end

    local fname
    local bt = vim.bo.bt
    if fugitive_name then
        fname = fugitive_name
    elseif bufname == '' and bt == '' then
        fname = '[No Name]'
    elseif bt == 'quickfix' then
        fname = quickfix():sub(1, width * 2 / 3)
    else
        fname = fn.expand('%:t')
        local ft = vim.bo.ft
        if fn.expand('%:e') == '' or ft == '' then
            fname = ('%s (%s)'):format(fname, ft)
        end
    end
    if bt == '' then
        fname = fname .. ' %m'
    end
    return '%#StatusLine' .. (vim.bo.modified and 'FileModified#' or 'FileName#') .. fname ..
               '%#StatusLine#'
end

local function gitsigns()
    local ret
    local ginfo = vim.b.gitsigns_status_dict
    if ginfo then
        local branch = ginfo.head
        local list = {'%#StatusLineBranch# ' .. branch}
        local added = ginfo.added
        local changed = ginfo.changed
        local removed = ginfo.removed
        if added and added > 0 then
            table.insert(list, '%#StatusLineHunkAdd#+' .. added)
        end
        if changed and changed > 0 then
            table.insert(list, '%#StatusLineHunkChange#~' .. changed)
        end
        if removed and removed > 0 then
            table.insert(list, '%#StatusLineHunkRemove#-' .. removed)
        end
        ret = table.concat(list, ' ') .. '%#StatusLine#'
    end
    return ret
end

local function coc_status()
    return vim.trim(vim.g.coc_status or '')
end

local coc_diagnostic = (function()
    local coc_signs = setmetatable({}, {
        __index = function(tbl, k)
            local icon = require('plugs.coc').sign_icon(k)
            local v = '%#StatusLine' .. k:sub(1, 1):upper() .. k:sub(2) .. '#' .. icon
            rawset(tbl, k, v)
            return v
        end
    })

    return function()
        local ret
        local info = vim.b.coc_diagnostic_info
        if info and (info.warning > 0 or info.error > 0) then
            local signs = {}
            if info.warning > 0 then
                table.insert(signs, coc_signs['warning'] .. ' ' .. info.warning)
            end
            if info.error > 0 then
                table.insert(signs, coc_signs['error'] .. ' ' .. info.error)
            end
            ret = table.concat(signs, ' ') .. '%#StatusLine#'
        end
        return ret
    end
end)()

local function fileformat(bufnr)
    local icon
    if vim.bo[bufnr].fileformat == 'unix' then
        icon = jit.os == 'OSX' and '' or 'ﱦ'
    else
        icon = ''
    end
    return bufnr == 0 and '%#StatusLineFormat#' .. icon .. '%#StatusLine#' or icon
end

function M.statusline()
    local stl = {}
    if api.nvim_get_current_win() == vim.g.statusline_winid then
        local m_name, m_hl = unpack(mode_map[api.nvim_get_mode().mode])
        local width = api.nvim_win_get_width(vim.g.statusline_winid)
        table.insert(stl, m_hl .. ' ' .. m_name .. ' %#StatusLine#')
        table.insert(stl, filename(width))
        table.insert(stl, readonly(0))

        table.insert(stl, '%<%=')

        local c_st = coc_status()
        if #c_st > width / 2 then
            c_st = c_st:sub(1, width / 2)
        end
        table.insert(stl, c_st)
        table.insert(stl, coc_diagnostic())
        if width > 75 then
            table.insert(stl, gitsigns())
        end
        table.insert(stl, fileformat(0))
        table.insert(stl, m_hl)
        table.insert(stl, ' %3l/%-3L %3v ')
    else
        local winid = vim.g.statusline_winid
        local bufnr = api.nvim_win_get_buf(winid)
        table.insert(stl, '   ')
        table.insert(stl, vim.bo[bufnr].bt == 'quickfix' and quickfix(winid) or '%t %m')
        table.insert(stl, readonly(bufnr))

        table.insert(stl, '%<%=')

        table.insert(stl, fileformat(bufnr))
        table.insert(stl, '  %3l/%-3L %3v ')
    end

    return table.concat(stl, ' ')
end

function M.tabline()
    local tl = {}
    for i, tp in ipairs(api.nvim_list_tabpages()) do
        if tp == api.nvim_get_current_tabpage() then
            table.insert(tl, '%#TabLineSel#')
        else
            table.insert(tl, '%#TabLine#')
        end
        table.insert(tl, ' ' .. i .. ' ')
        local name
        local winid = api.nvim_tabpage_get_win(tp)
        local bufnr = api.nvim_win_get_buf(winid)
        name = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ':t')
        if not name or name == '' then
            local win_type = fn.win_gettype(winid)
            if win_type == 'loclist' then
                name = '[Location]'
            elseif win_type == 'quickfix' then
                name = '[Quickfix]'
            else
                name = '[No Name]'
            end
        end
        table.insert(tl, name .. ' ')
    end
    table.insert(tl, '%#TabLineFill#%T')
    return table.concat(tl)
end

local function init()
    vim.o.statusline = [[%!v:lua.require'stl'.statusline()]]
    vim.o.tabline = [[%!v:lua.require'stl'.tabline()]]
end

init()

return M
