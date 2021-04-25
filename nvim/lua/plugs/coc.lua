local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local map = require('remap').map

local function setup()
    -- https://github.com/neoclide/coc.nvim/issues/2853
    fn['coc#config']('snippets', {ultisnips = {enable = true}})
    fn['CocActionAsync']('deactivateExtension', 'coc-snippets')

    fn['coc#config']('languageserver.lua.settings.Lua.workspace',
        {library = {[vim.env.VIMRUNTIME .. '/lua'] = true}})

    api.nvim_exec([[
    aug Coc
        au!
        au User CocLocationsChange ++nested lua require('plugs.coc').jump2loc()
        au CursorHold * sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)
        au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        au VimLeavePre * if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif
        au InsertCharPre * lua require('plugs.coc').enable_ultisnips()
        au FileType vim xmap if <Plug>(coc-funcobj-i) | omap if <Plug>(coc-funcobj-i)
        au FileType vim xmap af <Plug>(coc-funcobj-a) | omap af <Plug>(coc-funcobj-a)
    aug END]], false)

    local cxx_ft = {'c', 'cpp', 'objc', 'objcpp', 'cc', 'cuda'}
    local cur_ft = vim.bo.ft
    if vim.tbl_contains(cxx_ft, cur_ft) then
        cmd('pa vim-lsp-cxx-highlight')
        vim.bo.ft = cur_ft
    else
        cmd(string.format([[au Coc FileType %s ++once pa vim-lsp-cxx-highlight]],
            table.concat(cxx_ft, ',')))
    end

    cmd('hi link CocHighlightText CurrentWord')

    map('i', '<C-space>', 'coc#refresh()', {noremap = true, expr = true})
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

    map('x', '<Leader>sr',
        [[<Cmd>lua require('plugs.coc').enable_ultisnips()<CR><Plug>(coc-snippets-select)]], {})
    map('x', '<Leader>sx', '<Plug>(coc-convert-snippet)', {})

    cmd([[com! -nargs=0 OR call CocAction('runcom', 'editor.action.organizeImport')]])
    map('n', '<Leader>qi', '<Cmd>OR<CR>')
    map('n', '<M-q>', [[<Cmd>echo CocAction('getCurrentFunctionSymbol')<CR>]])
    map('n', '<Leader>qd', [[<Cmd>lua require('plugs.coc').diagnostic()<CR>]])

    cmd([[com! -nargs=0 ClangdSH call CocAction('runcom', 'clangd.switchSourceHeader')]])
    map('n', '<Leader>sh', '<Cmd>ClangdSH<CR>')
end

function M.enable_ultisnips()
    fn.CocAction('activeExtension', 'coc-snippets')
    map('x', '<Leader>sr', '<Plug>(coc-snippets-select)', {})
    cmd('au! Coc InsertCharPre *')
    M.enable_ultisnips = nil
end

function M.go2def()
    local cur_bufnr = api.nvim_get_current_buf()
    if api.nvim_exec([[echo CocAction('jumpDefinition')]], true) == 'v:true' then
        vim.w.gtd = 'coc'
    else
        local cword = fn.expand('<cword>')
        if not pcall(function()
            local wv = fn.winsaveview()
            cmd('ltag ' .. cword)
            local def_size = fn.getloclist(0, {size = 0}).size
            vim.w.gtd = 'tag'
            if def_size > 1 then
                api.nvim_set_current_buf(cur_bufnr)
                fn.winrestview(wv)
                cmd('abo lw')
            elseif def_size == 1 then
                cmd('lcl')
                fn.search(cword, 'c')
            end
        end) then
            vim.w.gtd = 'search'
            fn.searchdecl(cword)
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        cmd('norm! zz')
    end
end

function M.show_documentation()
    if vim.b.filetype == 'vim' or vim.b.filetype == 'help' then
        cmd(string.format('h %s', fn.expand('<cword>')))
    elseif api.nvim_exec([[echo CocAction('hasProvider', 'hover')]], true) == 'v:true' then
        fn['CocActionAsync']('doHover')
    else
        cmd('norm! K')
    end
end

function M.diagnostic()
    local diagnostics = fn['CocAction']('diagnosticList')
    local items, loc_ranges = {}, {}
    for _, d in ipairs(diagnostics) do
        local text = string.format('[%s%s] %s', (d.source == '' and 'coc.nvim' or d.source),
            (d.code == vim.NIL and '' or ' ' .. d.code), d.message:match('[^\n]+\n*'))
        local item = {filename = d.file, lnum = d.lnum, col = d.col, text = text, type = d.severity}
        table.insert(loc_ranges, d.location.range)
        table.insert(items, item)
    end
    fn.setqflist({}, ' ', {
        title = 'CocDiagnosticList',
        items = items,
        context = {bqf = {lsp_ranges_hl = loc_ranges}}
    })
    cmd('bo cope')
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

-- CocHasProvider('documentHighlight') has probability of RPC failure
-- Write the hardcode of filetype for fallback highlight
local fb_bl_ft = {
    'qf', 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java', 'lua', 'typescript',
    'javascript', 'css', 'html', 'xml'
}

local function get_cur_word()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    local word = fn.matchstr(line:sub(1, col + 1), '\\k*$') ..
                     fn.matchstr(line:sub(col + 1, -1), '^\\k*'):sub(2, -1)
    return string.format([[\<%s\>]], word:gsub('[\\/]', '\\%1'))
end

function M.hl_fallback()
    if vim.bo.buftype == 'terminal' and api.nvim_get_mode() == 't' or
        vim.tbl_contains(fb_bl_ft, vim.bo.filetype) then
        return
    end

    if vim.w.coc_matchids_fb then
        pcall(fn.matchdelete, vim.w.coc_matchids_fb)
    end

    vim.w.coc_matchids_fb = fn.matchadd('CocHighlightText', get_cur_word(), -1)
end

setup()

return M
