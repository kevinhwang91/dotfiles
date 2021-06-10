local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local map = require('remap').map
local utils = require('kutils')
local diag_qfid

local function setup()
    diag_qfid = -1

    -- https://github.com/neoclide/coc.nvim/issues/2853
    fn['coc#config']('snippets', {ultisnips = {enable = true}})
    fn['CocActionAsync']('deactivateExtension', 'coc-snippets')

    fn['coc#config']('languageserver.lua.settings.Lua.workspace',
        {library = {[vim.env.VIMRUNTIME .. '/lua'] = true}})

    cmd([[
        aug Coc
            au!
            au User CocLocationsChange ++nested lua require('plugs.coc').jump2loc()
            au User CocDiagnosticChange ++nested lua require('plugs.coc').diagnostic_change()
            au CursorHold * sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)
            au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
            au VimLeavePre * if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif
            au InsertCharPre * lua require('plugs.coc').enable_ultisnips()
        aug END
    ]])

    cmd('hi! link CocHighlightText CurrentWord')
    if vim.g.colors_name == 'one' then
        cmd('hi! CocErrorSign guifg=#be5046')
        cmd('hi! CocWarningSign guifg=#e5c07b')
    end

    map('i', '<C-space>', 'coc#refresh()', {noremap = true, expr = true, silent = true})
    map('n', '<C-f>', [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]],
        {noremap = true, expr = true})
    map('n', '<C-b>', [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]],
        {noremap = true, expr = true})
    map('v', '<C-f>', [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]],
        {noremap = true, expr = true})
    map('v', '<C-b>', [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]],
        {noremap = true, expr = true})
    map('i', '<C-f>', [[coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]],
        {noremap = true, expr = true})
    map('i', '<C-b>', [[coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]],
        {noremap = true, expr = true})

    map('n', '[d', '<Plug>(coc-diagnostic-prev)', {})
    map('n', ']d', '<Plug>(coc-diagnostic-next)', {})

    map('n', 'gd', [[<Cmd>lua require('plugs.coc').go2def()<CR>]])
    map('n', 'gy', '<Plug>(coc-type-definition)', {})
    map('n', 'gi', '<Plug>(coc-implementation)', {})
    map('n', 'gr', '<Plug>(coc-references)', {})

    map('n', 'K', [[<Cmd>lua require('plugs.coc').show_documentation()<CR>]])

    map('n', '<Leader>rn', '<Plug>(coc-refactor)', {})
    map('n', '<Leader>ac', '<Plug>(coc-codeaction)', {})
    map('n', '<M-CR>', '<Plug>(coc-codeaction-line)', {})
    map('x', '<M-CR>', '<Plug>(coc-codeaction-selected)', {})
    map('n', '<Leader>qf', '<Plug>(coc-fix-current)', {})

    map('x', 'if', [[:<C-u>lua require('plugs.coc').textobj('func', true, true)<CR>]])
    map('x', 'af', [[:<C-u>lua require('plugs.coc').textobj('func', false, true)<CR>]])
    map('o', 'if', [[:<C-u>lua require('plugs.coc').textobj('func', true)<CR>]])
    map('o', 'af', [[:<C-u>lua require('plugs.coc').textobj('func', false)<CR>]])

    map('x', 'ik', [[:<C-u>lua require('plugs.coc').textobj('class', true, true)<CR>]])
    map('x', 'ak', [[:<C-u>lua require('plugs.coc').textobj('class', false, true)<CR>]])
    map('o', 'ik', [[:<C-u>lua require('plugs.coc').textobj('class', true)<CR>]])
    map('o', 'ak', [[:<C-u>lua require('plugs.coc').textobj('class', false)<CR>]])

    map('x', '<Leader>sr',
        [[<Cmd>lua require('plugs.coc').enable_ultisnips()<CR><Plug>(coc-snippets-select)]], {})
    map('x', '<Leader>sx', '<Plug>(coc-convert-snippet)', {})

    cmd([[com! -nargs=0 OR call CocAction('runcom', 'editor.action.organizeImport')]])
    map('n', '<Leader>qi', '<Cmd>OR<CR>')
    map('n', '<M-q>', [[<Cmd>echo CocAction('getCurrentFunctionSymbol')<CR>]])
    map('n', '<Leader>qd', [[<Cmd>lua require('plugs.coc').diagnostic()<CR>]])

    cmd([[com! -nargs=0 DiagnosticToggleBuffer call CocAction('diagnosticToggleBuffer')]])
    cmd([[com! -nargs=0 CocOutput CocCommand workspace.showOutput]])
    map('n', '<Leader>sh', '<Cmd>CocCommand clangd.switchSourceHeader<CR>')
end

function M.enable_ultisnips()
    fn.CocAction('activeExtension', 'coc-snippets')
    map('x', '<Leader>sr', '<Plug>(coc-snippets-select)', {})
    cmd('au! Coc InsertCharPre *')
    M.enable_ultisnips = nil
end

function M.go2def()
    local cur_bufnr = api.nvim_get_current_buf()
    local by
    if vim.bo.ft == 'help' then
        api.nvim_feedkeys(api.nvim_replace_termcodes('<C-]>', true, false, true), 'n', false)
        by = 'tag'
    elseif api.nvim_exec([[echo CocAction('jumpDefinition')]], true):match('v:true$') then
        by = 'coc'
    else
        local cword = fn.expand('<cword>')
        if not pcall(function()
            local wv = fn.winsaveview()
            cmd('ltag ' .. cword)
            local def_size = fn.getloclist(0, {size = 0}).size
            by = 'ltag'
            if def_size > 1 then
                api.nvim_set_current_buf(cur_bufnr)
                fn.winrestview(wv)
                cmd('abo lw')
            elseif def_size == 1 then
                cmd('lcl')
                fn.search(cword, 'cs')
            end
        end) then
            fn.searchdecl(cword)
            by = 'search'
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        cmd('norm! zz')
    end

    if by then
        utils.cool_echo('go2def: ' .. by, 'Special')
    end
end

function M.show_documentation()
    local ft = vim.bo.ft
    if ft == 'vim' or ft == 'help' then
        cmd(('sil! h %s'):format(fn.expand('<cword>')))
    elseif api.nvim_eval([[CocAction('hasProvider', 'hover')]]) then
        fn['CocActionAsync']('doHover')
    else
        cmd('norm! K')
    end
end

function M.diagnostic_change()
    if vim.v.exiting == vim.NIL then
        local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
        if info.winid ~= 0 then
            M.diagnostic(info.winid, info.nr, true)
        end
    end
end

function M.diagnostic(winid, nr, keep)
    fn['CocActionAsync']('diagnosticList', '', function(err, res)
        if err == vim.NIL then
            local items, loc_ranges = {}, {}
            for _, d in ipairs(res) do
                local text = ('[%s%s] %s'):format((d.source == '' and 'coc.nvim' or d.source),
                    (d.code == vim.NIL and '' or ' ' .. d.code), d.message:match('([^\n]+)\n*'))
                local item = {
                    filename = d.file,
                    lnum = d.lnum,
                    col = d.col,
                    text = text,
                    type = d.severity
                }
                table.insert(loc_ranges, d.location.range)
                table.insert(items, item)
            end
            local id
            if winid and nr then
                id = diag_qfid
            else
                local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
                id, winid, nr = info.id, info.winid, info.nr
            end
            local action = id == 0 and ' ' or 'r'
            fn.setqflist({}, action, {
                id = id ~= 0 and id or nil,
                title = 'CocDiagnosticList',
                items = items,
                context = {bqf = {lsp_ranges_hl = loc_ranges}}
            })

            if id == 0 then
                local info = fn.getqflist({id = id, nr = 0})
                diag_qfid, nr = info.id, info.nr
            end

            if not keep then
                if winid == 0 then
                    cmd('bo cope')
                else
                    api.nvim_set_current_win(winid)
                end
                cmd(('sil %dchi'):format(nr))
            end
        end
    end)
end

function M.jump2loc(locs)
    locs = locs or vim.g.coc_jump_locations
    local loc_ranges = vim.tbl_map(function(val)
        return val.range
    end, locs)
    fn.setloclist(0, {}, ' ', {
        title = 'CocLocationList',
        items = locs,
        context = {bqf = {lsp_ranges_hl = loc_ranges}}
    })
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        cmd('abo lw')
    else
        api.nvim_set_current_win(winid)
    end
end

local function get_cur_word()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]:match('%C*')
    local word = fn.matchstr(line:sub(1, col + 1), [[\k*$]]) ..
                     fn.matchstr(line:sub(col + 1, -1), [[^\k*]]):sub(2, -1)
    return ([[\<%s\>]]):format(word:gsub('[\\/~]', [[\%1]]))
end

-- CocHasProvider('documentHighlight') has probability of RPC failure
-- Write the hardcode of filetype for fallback highlight
local fb_bl_ft = {
    'qf', 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java', 'lua', 'typescript',
    'javascript', 'css', 'html', 'xml'
}

local hl_fb_tbl = {}

function M.hl_fallback()
    if vim.tbl_contains(fb_bl_ft, vim.bo.ft) or api.nvim_get_mode().mode == 't' and vim.bo.bt ==
        'terminal' then
        return
    end

    local m_id, winid = unpack(hl_fb_tbl)
    pcall(fn.matchdelete, m_id, winid)

    winid = api.nvim_get_current_win()
    m_id = fn.matchadd('CocHighlightText', get_cur_word(), -1, -1, {window = winid})
    hl_fb_tbl = {m_id, winid}
end

function M.textobj(obj, inner, visual)
    local symbols = {func = {'Method', 'Function'}, class = {'Interface', 'Struct', 'Class'}}
    local done = false
    local err
    fn['CocActionAsync']('selectSymbolRange', inner, visual and fn.visualmode() or '', symbols[obj],
        function(e)
            if e ~= vim.NIL then
                err = true
            end
            done = true
        end)
    if not vim.wait(3200, function()
        return done
    end) or err then
        if obj == 'func' then
            obj = 'function'
        end
        require('nvim-treesitter.textobjects.select').select_textobject(
            ('@%s.%s'):format(obj, inner and 'inner' or 'outer'), visual and 'x' or 'o')
    end
end

setup()

return M
