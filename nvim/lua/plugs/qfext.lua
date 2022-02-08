local M = {}
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local coc = require('plugs.coc')

function M.outline()
    local kinds = {'Function', 'Method', 'Interface', 'Struct', 'Class'}
    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].bt == 'quickfix' then
        bufnr = fn.bufnr('#')
    end
    coc.run_command('kvs.symbol.docSymbols', {bufnr, kinds}, function(e, r)
        if e ~= vim.NIL or type(r) ~= 'table' or #r == 0 then
            return
        end

        local items = {}
        local text_fmt = '%-32s│%5d:%-3d│%10s%s%s'
        for _, s in ipairs(r) do
            local range = s.selectionRange
            local rs, re = range.start, range['end']
            local lnum, col = rs.line + 1, rs.character + 1
            table.insert(items, {
                bufnr = bufnr,
                lnum = lnum,
                col = col,
                end_lnum = re.line + 1,
                end_col = re.character + 1,
                text = text_fmt:format(s.kind, lnum, col, ' ', ('| '):rep(s.level), s.text)
            })
        end
        local bufname = api.nvim_buf_get_name(bufnr)
        fn.setloclist(0, {}, ' ', {
            title = ('Outline Bufnr: %d'):format(bufnr),
            context = {bqf = {fzf_action_for = {esc = 'closeall', ['ctrl-c'] = ''}}},
            items = items,
            quickfixtextfunc = function(qinfo)
                cmd(('noa lcd %s'):format(fn.fnamemodify(bufname, ':h')))
                local ret = {}
                local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                for i = qinfo.start_idx, qinfo.end_idx do
                    local ele = _items[i]
                    table.insert(ret, ele.text)
                end
                return ret
            end
        })

        local winid = fn.getloclist(0, {winid = 0}).winid
        if winid == 0 then
            cmd('abo lw')
        else
            api.nvim_set_current_win(winid)
        end

        if vim.b.bqf_enabled then
            api.nvim_feedkeys('zf', 'm', false)
        end
    end)
end

return M
