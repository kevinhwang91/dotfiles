local M = {}
local fn = vim.fn
local api = vim.api

local function init()
    _G.statusline = M.statusline
    vim.o.statusline = '%!v:lua.statusline()'

    _G.tabline = M.tabline
    vim.o.tabline = '%!v:lua.tabline()'
end

local mode_map = setmetatable({
    n = {'N', '%#StatusLineNormal#'},
    i = {'I', '%#StatusLineInsert#'},
    R = {'R', '%#StatusLineReplace#'},
    v = {'V', '%#StatusLineVisual#'},
    V = {'VL', '%#StatusLineVisual#'},
    [''] = {'VB', '%#StatusLineVisual#'},
    s = {'S', '%#StatusLineVisual#'},
    S = {'SL', '%#StatusLineVisual#'},
    [''] = {'SB', '%#StatusLineVisual#'},
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
    if vim.bo[bufnr].readonly then
        return fn.filereadable(fn.bufname(bufnr or '%')) == 1 and '' or ''
    end
    return nil
end

local function quickfix()
    local qf_type = fn.getwininfo(api.nvim_get_current_win())[1].loclist == 1 and 'loc' or 'qf'
    local what = {nr = 0, size = 0}
    local info = qf_type == 'loc' and fn.getloclist(0, what) or fn.getqflist(what)
    what = {nr = '$'}
    local nr = (qf_type == 'loc' and fn.getloclist(0, what) or fn.getqflist(what)).nr
    local prefix = qf_type == 'loc' and 'Location' or 'Quickfix'
    return string.format('%s (%d/%d) [%d]', prefix, info.nr, nr, info.size)
end

local function filename()
    local bufname = fn.bufname('%')
    if not vim.b.fugitive_fname then
        if bufname:match('^fugitive:') and fn.exists('*FugitiveReal') == 1 then
            vim.b.fugitive_fname = fn.fnamemodify(fn['FugitiveReal'](bufname), ':t') .. ' '
        else
            vim.b.fugitive_fname = ''
        end
    end

    local fname
    if vim.b.fugitive_fname ~= '' then
        fname = vim.b.fugitive_fname
    elseif bufname == '' and vim.bo.buftype == '' then
        fname = '[No Name]'
    elseif vim.bo.buftype == 'quickfix' then
        fname = quickfix()
    else
        fname = fn.expand('%:t')
        if fn.expand('%:e') == '' and vim.bo.filetype ~= '' then
            fname = string.format('%s (%s)', fname, vim.bo.filetype)
        end
    end
    return '%#StatusLine' .. (vim.bo.modified and 'FileModified#' or 'FileName#') .. fname ..
               ' %m%#StatusLine#'
end

local fugitive = (function()
    local tick = 0
    local threshold = 1
    local last_branch = {nil, nil}

    return function()
        local bufname = fn.expand('%')
        if bufname == '' or fn.exists('*FugitiveExtractGitDir') == 0 then
            return nil
        end

        local branch
        if bufname ~= last_branch[1] or os.clock() - tick > threshold then
            if not vim.b.git_dir or vim.b.git_dir == '' then
                return nil
            end
            branch = fn['FugitiveHead']()
            local info = fn['FugitiveParse']()[1]
            if info ~= '' then
                local commit = vim.split(info, ':')[1]
                branch = string.format('%s(%s)', branch, commit:sub(0, 6))
            end
            last_branch = {bufname, branch}
            tick = os.clock()
        else
            branch = last_branch[2]
        end
        return '%#StatusLineBranch# ' .. branch .. '%#StatusLine#'
    end
end)()

local function gitgutter()
    if fn.exists('*GitGutterGetHunkSummary') == 0 or vim.bo.readonly or not vim.bo.modifiable then
        return nil
    else
        local cnt = fn['GitGutterGetHunkSummary']()
        if cnt[1] == 0 and cnt[2] == 0 and cnt[3] == 0 then
            return nil
        else
            local list = {}
            local symbol = {
                '%#StatusLineHunkAdd#+', '%#StatusLineHunkChange#~', '%#StatusLineHunkRemove#-'
            }
            for i = 1, 3 do
                table.insert(list, symbol[i] .. cnt[i])
            end
            return table.concat(list, ' ') .. '%#StatusLine#'
        end
    end
end

local function coc_status()
    return vim.trim(vim.g.coc_status or '')
end

local coc_diagnostic = (function()
    local coc_signs = setmetatable({}, {
        __index = function(t, k)
            local sign = fn['coc#util#get_config']('diagnostic')[k .. 'Sign']
            t[k] = '%#StatusLine' .. k:upper():sub(1, 1) .. k:sub(2) .. '#' .. sign
            return t[k]
        end
    })

    return function()
        local info = vim.b.coc_diagnostic_info
        if not info or (info.warning == 0 and info.error == 0) then
            return nil
        end
        local signs = {}
        if info.warning > 0 then
            table.insert(signs, coc_signs['warning'] .. ' ' .. info.warning)
        end
        if info.error > 0 then
            table.insert(signs, coc_signs['error'] .. ' ' .. info.error)
        end
        return table.concat(signs, ' ') .. '%#StatusLine#'
    end
end)()

local fileformat = (function()
    local is_mac = fn.has('macunix') == 1
    return function(bufnr)
        local icon
        if vim.bo[bufnr].fileformat == 'unix' then
            icon = is_mac and '' or 'ﱦ'
        else
            icon = ''
        end
        if bufnr == 0 then
            return '%#StatusLineFormat#' .. icon .. '%#StatusLine#'
        end
        return icon
    end
end)()

function M.statusline()
    local stl = {}
    if api.nvim_get_current_win() == vim.g.statusline_winid then
        local m_name, m_hl = unpack(mode_map[api.nvim_get_mode().mode])
        local width = api.nvim_win_get_width(vim.g.statusline_winid)
        table.insert(stl, m_hl .. ' ' .. m_name .. ' %#StatusLine#')
        table.insert(stl, filename())
        table.insert(stl, readonly(0))

        table.insert(stl, '%<%=')

        table.insert(stl, coc_status())
        table.insert(stl, coc_diagnostic())
        if width > 75 then
            table.insert(stl, gitgutter())
        end
        if width > 85 then
            table.insert(stl, fugitive())
        end
        table.insert(stl, fileformat(0))
        table.insert(stl, m_hl)
        table.insert(stl, ' %3l/%-3L %3v ')
    else
        local bufnr = fn.winbufnr(vim.g.statusline_winid)
        table.insert(stl, '    %t')
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
        local bufnr = fn.winbufnr(api.nvim_tabpage_get_win(tp))
        if vim.bo[bufnr].modifiable then
            name = fn.fnamemodify(fn.bufname(bufnr), ':t')
        end
        if name and name ~= '' then
            table.insert(tl, name .. ' ')
        else
            table.insert(tl, '[No Name] ')
        end
    end
    table.insert(tl, '%#TabLineFill#%T')
    return table.concat(tl)
end

init()

return M
