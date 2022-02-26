local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

-- WIP
function M.batch_sub(is_loc, pat_rep)
    local matches = fn.matchlist(pat_rep, [[\v(([^|"\\a-zA-Z0-9]).*\2.*\2=)([cgeiI]*)\s*$]])
    if vim.tbl_isempty(matches) then
        return
    end

    local pr_str = matches[2]
    local delm = matches[3]
    local flag = matches[4]
    local pr_tbl = vim.split(pr_str, delm)
    local pat, rep = pr_tbl[2], pr_tbl[3]
    if pat == '' then
        pat = fn.getreg('/')
    end
    if vim.o.gdefault then
        flag:gsub('g', '')
        flag = flag .. 'g'
    end

    local old = is_loc and fn.getloclist(0) or fn.getqflist()
    if #old == 0 then
        return
    end

    local function gt(e1, e2)
        local ret = false
        if e1[1] > e2[1] then
            ret = true
        elseif e1[1] == e2[1] then
            if e1[2] < e2[2] then
                ret = true
            end
        end

        return ret
    end

    -- Bucket sort + Insertion sort
    local buf_list = {}
    local bp_list = {}
    for i = 1, #old do
        local e = old[i]
        local bufnr = e.bufnr
        if not bp_list[bufnr] then
            buf_list[#buf_list + 1] = bufnr
            bp_list[bufnr] = {}
        end
        local plist = bp_list[bufnr]
        local j = #plist
        plist[j + 1] = {e.lnum, e.col}
        while j > 0 and gt(plist[j], plist[j + 1]) do
            plist[j], plist[j + 1] = plist[j + 1], plist[j]
            j = j - 1
        end
    end

    local new = {}
    for _, bufnr in ipairs(buf_list) do
        local plist = bp_list[bufnr]
        for _, pos in ipairs(plist) do
            new[#new + 1] = {bufnr = bufnr, lnum = pos[1], col = pos[2]}
        end
    end

    local set_cmd = is_loc and function(...)
        return fn.setloclist(0, ...)
    end or fn.setqflist

    local function silent_setqf(items)
        local ei = vim.go.ei
        vim.go.ei = 'all'
        pcall(set_cmd, {}, 'r', {items = items, quickfixtextfunc = ''})
        vim.go.ei = ei
    end

    silent_setqf(new)

    local ok, res = pcall(function()
        local concat = ([[%s\%%#%s%s%s%s%s]]):format(delm, pat, delm, rep, delm, flag)
        local do_cmd = is_loc and 'ldo' or 'cdo'
        cmd(([[%s s%s]]):format(do_cmd, concat))
    end)
    fn.histdel('/', -1)
    fn.histadd('/', pat)
    fn.setreg('/', pat)

    silent_setqf(old)

    if not ok then
        vim.notify(res, vim.log.levels.ERROR)
    end
end

function M.qftf(qinfo)
    local items
    local ret = {}
    require('gittool').cd_root(fn.bufname('#'), true)
    if qinfo.quickfix == 1 then
        items = fn.getqflist({id = qinfo.id, items = 0}).items
    else
        items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
    end
    local limit = 31
    local fname_fmt1, fname_fmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'
    local valid_fmt = '%s │%5d:%-3d│%s %s'
    for i = qinfo.start_idx, qinfo.end_idx do
        local e = items[i]
        local fname = ''
        local str
        if e.valid == 1 then
            if e.bufnr > 0 then
                fname = fn.bufname(e.bufnr)
                if fname == '' then
                    fname = '[No Name]'
                else
                    fname = fname:gsub('^' .. vim.env.HOME, '~')
                end
                -- char in fname may occur more than 1 width, ignore this issue in order to keep
                -- performance
                if #fname <= limit then
                    fname = fname_fmt1:format(fname)
                else
                    fname = fname_fmt2:format(fname:sub(1 - limit))
                end
            end
            local lnum = e.lnum > 99999 and -1 or e.lnum
            local col = e.col > 999 and -1 or e.col
            local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()
            str = valid_fmt:format(fname, lnum, col, qtype, e.text)
        else
            str = e.text
        end
        table.insert(ret, str)
    end
    return ret
end

function M.close()
    local loc_winid = fn.getloclist(0, {winid = 0}).winid
    if loc_winid == 0 then
        cmd('ccl')
    else
        local qf_winid = fn.getqflist({winid = 0}).winid
        if qf_winid == 0 then
            cmd('lcl')
        else
            local prompt = ' [q]uickfix, [l]ocation ? '
            local bufnr = api.nvim_create_buf(false, true)
            local winid = api.nvim_open_win(bufnr, false, {
                relative = 'cursor',
                width = #prompt,
                height = 1,
                row = 1,
                col = 1,
                style = 'minimal',
                border = 'rounded',
                noautocmd = true
            })
            vim.wo[winid].winhl = 'Normal:Normal'
            vim.wo[winid].winbl = 8
            api.nvim_buf_set_lines(bufnr, 0, 1, false, {prompt})
            -- (?<=\[)[^\[\]](?=\]) to \%(\[\)\@<=[^[\]]\%(\]\)\@=]== with E2v
            -- I know \zs and \ze also work, but I prefer PCRE than vim regex
            fn.matchadd('MatchParen', [==[\%(\[\)\@<=[^[\]]\%(\]\)\@=]==], 10, -1, {window = winid})
            vim.schedule(function()
                local char = fn.getchar()
                if type(char) == 'number' then
                    char = fn.nr2char(char)
                    if char == 'q' then
                        cmd('ccl')
                    elseif char == 'l' then
                        cmd('lcl')
                    end
                end
                cmd(('noa bw %d'):format(bufnr))
            end)
        end
    end
end

function M.syntax()
    if vim.b.current_syntax then
        return
    end

    local title = vim.w.quickfix_title
    if title:match('^%**[Oo]utline') then
        require('plugs.qfext').outline_syntax()
    else
        cmd([[
            syn match qfFileName /^[^│]*/ nextgroup=qfSeparatorLeft
            syn match qfSeparatorLeft /│/ contained nextgroup=qfLineNr
            syn match qfLineNr /[^│]*/ contained nextgroup=qfSeparatorRight
            syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote
            syn match qfError / E .*$/ contained
            syn match qfWarning / W .*$/ contained
            syn match qfInfo / I .*$/ contained
            syn match qfNote / [NH] .*$/ contained

            hi def link qfFileName Directory
            hi def link qfSeparatorLeft Delimiter
            hi def link qfSeparatorRight Delimiter
            hi def link qfLineNr LineNr
            hi def link qfError CocErrorSign
            hi def link qfWarning CocWarningSign
            hi def link qfInfo CocInfoSign
            hi def link qfNote CocHintSign
        ]])
        end
    vim.b.current_syntax = 'qf'
end

local function init()
    vim.g.qf_disable_statusline = true
    vim.o.qftf = [[{info -> v:lua.require('qf').qftf(info)}]]
    cmd([[
        com! -nargs=1 Cdos lua require('qf').batch_sub(false, <q-args>)
        com! -nargs=1 Ldos lua require('qf').batch_sub(true, <q-args>)

        cabbrev cdos <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Cdos' : 'cdos')<CR>
        cabbrev ldos <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Ldos' : 'ldos')<CR>
    ]])
end

init()

return M
