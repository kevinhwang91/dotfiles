local M = {}
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local mru = require('mru')
local cmdhist = require('cmdhist')
local utils = require('kutils')

local coc = require('plugs.coc')

local default_preview_window, default_action

local function build_opt(opts)
    local preview_args = vim.g.fzf_preview_window or default_preview_window
    return fn['fzf#vim#with_preview'](opts, unpack(preview_args))
end

local function do_action(expect, path, bufnr, lnum, col)
    local action = vim.g.fzf_action or {}
    action = vim.tbl_extend('keep', action, default_action)
    local jump_cmd = action[expect] or 'edit'
    local bi
    if jump_cmd == 'drop' then
        if not bufnr then
            bufnr = fn.bufadd(path)
            vim.bo[bufnr].buflisted = true
        end
        bi = fn.getbufinfo(bufnr)
        if #bi == 1 and #bi[1].windows == 0 then
            api.nvim_set_current_buf(bufnr)
            return
        end
    end

    local function jump_path(p)
        cmd(('%s %s'):format(jump_cmd, fn.fnameescape(p)))
    end

    if path == '' then
        if bufnr and bufnr > 0 and api.nvim_buf_is_valid(bufnr) then
            local tmpfile = fn.tempname()
            local tmp_bufnr = fn.bufadd(tmpfile)
            if jump_cmd:match('drop') then
                bi = bi or fn.getbufinfo(bufnr)
                if #bi == 1 then
                    local winids = bi[1].windows
                    if #winids > 0 then
                        fn.win_gotoid(winids[1])
                        cmd(('keepalt b %d'):format(tmp_bufnr))
                    else
                        jump_path(tmpfile)
                    end
                end
            else
                jump_path(tmpfile)
            end
            cmd(('keepalt b %d'):format(bufnr))
            cmd(('noa bw %d'):format(tmp_bufnr))
        end
    else
        jump_path(path)
    end

    if lnum then
        col = col or 1
        api.nvim_win_set_cursor(0, {lnum, col - 1})
    end
end

local function format_files(b_list, m_list)
    local max_bufnr = 0
    local b_names = {}
    for _, b in ipairs(b_list) do
        b_names[b.name] = true
        if max_bufnr < b.bufnr then
            max_bufnr = b.bufnr
        end
    end
    local max_digit = math.floor(math.log10(max_bufnr)) + 1
    local cur_bufnr, alt_bufnr = api.nvim_get_current_buf(), fn.bufnr('#')
    local fmt = '%s:%d\t%d\t%s[%s]\t%s'
    local out = {}
    for _, b in ipairs(b_list) do
        local bufnr = b.bufnr
        local bt = vim.bo[bufnr].bt
        if bt ~= 'help' and bt ~= 'quickfix' and bt ~= 'terminal' and bt ~= 'prompt' then
            local name = b.name
            local lnum = b.lnum
            local readonly = vim.bo[bufnr].readonly
            local modified = b.changed == 1
            local flag = ''
            if modified then
                flag = utils.ansi.Statement:format('+ ')
            elseif readonly then
                flag = utils.ansi.Special:format('- ')
            end

            local sname = name == '' and '[No name]' or fn.fnamemodify(name, ':~:.')
            if bufnr == cur_bufnr then
                sname = utils.ansi.Directory:format(sname)
            elseif bufnr == alt_bufnr then
                sname = utils.ansi.Constant:format(sname)
            end

            sname = flag .. sname
            local bufnr_str = utils.ansi.Number:format(tostring(bufnr))
            local digit = math.floor(math.log10(bufnr)) + 1
            local padding = (' '):rep(max_digit - digit)
            local o_str = fmt:format(name, lnum, lnum, padding, bufnr_str, sname)

            table.insert(out, o_str)
        end
    end

    fmt = '%s:1\t1\t' .. (' '):rep(max_digit + 2) .. '\t%s'
    for _, m in ipairs(m_list) do
        if not b_names[m] then
            local sname = fn.fnamemodify(m, ':~:.')
            local o_str = fmt:format(m, sname)
            table.insert(out, o_str)
        end
    end
    return out
end

function M.files()
    local cur_bufnr = api.nvim_get_current_buf()

    local expr = [[{"bufnr": v:val.bufnr, "name": v:val.name, "lnum": v:val.lnum, ]] ..
                     [["lastused": v:val.lastused, "changed": v:val.changed}]]
    local b_list = api.nvim_eval(([[map(getbufinfo({'buflisted':1}), %q)]]):format(expr))
    table.sort(b_list, function(a, b)
        return a.lastused > b.lastused
    end)
    local m_list = mru.list()
    local header = #b_list > 0 and b_list[1].bufnr == cur_bufnr and '1' or '0'
    local opts = {
        options = {
            '+m', '--prompt', 'Files> ', '--tiebreak', 'index', '--header-lines', header, '--ansi',
            '-d', '\t', '--tabstop', '1', '--with-nth', '3..', '--preview-window', '+{2}/2'
        }
    }
    opts = build_opt(opts)
    opts.name = 'files'
    opts.source = format_files(b_list, m_list)
    opts['sink*'] = function(lines)
        if #lines ~= 2 then
            return
        end
        local expect = lines[1]
        local g1, _, g3 = unpack(vim.split(lines[2], '\t'))
        local path = g1:match('^(.*):%d+$')
        local bufnr = tonumber(g3:match('%[(%d+)%]$'))
        do_action(expect, path, bufnr)
    end
    fn.FzfWrapper(opts)
end

local function format_outline(symbols)
    local fmt = '%s:%d\t%d\t%d\t%s\t    %s%s'
    local out = {}
    local name = api.nvim_buf_get_name(0)
    local hl_map = {
        Function = 'Function',
        Method = 'Function',
        Interface = 'Structure',
        Struct = 'Structure',
        Class = 'Structure'
    }
    for _, s in ipairs(symbols) do
        local k = s.kind
        local lnum = s.lnum
        local col = s.col
        local kind = utils.ansi[hl_map[k]]:format(('%-10s'):format(k))
        local text = s.text
        local level = s.level > 0 and utils.ansi.NonText:format(('| '):rep(s.level)) or ''
        local o_str = fmt:format(name, lnum, lnum, col, kind, level, text)
        table.insert(out, o_str)
    end
    return out
end

function M.outline()
    local syms = coc.run_command('kvs.symbol.docSymbols',
        {'', {'Function', 'Method', 'Interface', 'Struct', 'Class'}})
    local opts = {
        options = {
            '+m', '--prompt', 'Outline> ', '--tiebreak', 'index', '--ansi', '-d', '\t', '--tabstop',
            '1', '--with-nth', '4..', '--preview-window', '+{2}/2'
        }
    }
    opts = build_opt(opts)
    opts.name = 'outline'
    opts.source = format_outline(syms)
    opts['sink*'] = function(lines)
        if #lines ~= 2 then
            return
        end
        local expect = lines[1]
        local g1, g2, g3 = unpack(vim.split(lines[2], '\t'))
        local path = g1:match('^(.*):%d+$')
        local lnum, col = tonumber(g2), tonumber(g3)
        do_action(expect, path, nil, lnum, col)
    end
    fn.FzfWrapper(opts)
end

function M.cmdhist()
    local opts = {
        name = 'history-command',
        source = cmdhist.list(),
        ['sink*'] = function(ret)
            local key, cmdl = unpack(ret)
            if key == 'ctrl-y' then
                fn.setreg(vim.v.register, cmdl)
            else
                fn.histadd(':', cmdl)
                cmdhist.store()
                if key == 'ctrl-e' then
                    cmd('redraw')
                    api.nvim_feedkeys(':' .. utils.termcodes['<Up>'], 'n', false)
                else
                    api.nvim_feedkeys((':' .. cmdl .. utils.termcodes['<CR>']), '', false)
                end
            end
        end,
        options = {'+m', '--prompt', 'Hist: ', '--tiebreak', 'index', '--expect', 'ctrl-e,ctrl-y'}
    }
    fn.FzfWrapper(opts)
end

function M.resize_preview_layout()
    local layout = vim.g.fzf_layout.window
    if vim.o.columns * layout.width - 2 > 100 then
        vim.g.fzf_preview_window = {'right:50%,border-left'}
    else
        if vim.o.lines * layout.height - 2 > 25 then
            vim.g.fzf_preview_window = {'down:50%,border-top'}
        else
            vim.g.fzf_preview_window = {'down:50%,border-top,hidden'}
        end
    end
end

function M.prepare_ft()
    -- TODO there's a bug for neovim's floating window for cursorline when split window, keep
    -- cursorline option of fzf's window on as a workaround
    vim.wo.cul = true
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        local bt = vim.bo[api.nvim_win_get_buf(winid)].bt
        if bt == 'quickfix' then
            return
        end
    end

    require('shadowwin').create()
    cmd([[
        aug Fzf
            au BufWipeout <buffer> lua require('shadowwin').close()
            au VimResized <buffer> lua require('shadowwin').resize()
        aug END
    ]])

end

local function init()
    vim.g.fzf_action = {
        ['ctrl-t'] = 'tab drop',
        ['ctrl-s'] = 'split',
        ['ctrl-v'] = 'vsplit',
        ['enter'] = 'drop'
    }
    vim.g.fzf_layout = {window = {width = 0.7, height = 0.7}}

    vim.g.loaded_fzf = nil
    cmd('pa fzf')
    cmd('pa fzf.vim')
    cmd([[
        function! FzfWrapper(opts) abort
            let opts = a:opts
            let options = ''
            if has_key(opts, 'options')
                let options = type(opts.options) == v:t_list ? join(opts.options) : opts.options
            endif
            if options !~ '--expect' && has_key(opts, 'sink*')
                let Sink = remove(opts, 'sink*')
                let wrapped = fzf#wrap(opts)
                let wrapped['sink*'] = Sink
            else
                let wrapped = fzf#wrap(opts)
            endif
            call fzf#run(wrapped)
        endfunction

        aug Fzf
            au!
            au FileType fzf lua require('plugs.fzf').prepare_ft()
            au VimResized * lua pcall(require('plugs.fzf').resize_preview_layout)
        aug END

        sil! au! fzf_buffers *
        sil! aug! fzf_buffers
    ]])

    default_preview_window = {'right:50%,border-left', 'ctrl-/'}
    default_action = {['ctrl-t'] = 'tab split', ['ctrl-x'] = 'split', ['ctrl-v'] = 'vsplit'}
    M.resize_preview_layout()
end

init()

return M
