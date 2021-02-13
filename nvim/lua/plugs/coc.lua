local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local map = require('remap').map

local function init()
    -- https://github.com/neoclide/coc.nvim/issues/2853
    fn['coc#config']('snippets', {ultisnips = {enable = true}})
    fn['CocActionAsync']('deactivateExtension', 'coc-snippets')

    fn['coc#config']('languageserver.lua.settings.Lua.workspace',
        {library = {[vim.env.VIMRUNTIME .. '/lua'] = true}})

    api.nvim_exec([[
    augroup Coc
        autocmd!
        autocmd User CocLocationsChange ++nested lua require('plugs.coc').jump2loc()
        autocmd CursorHold * silent! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        autocmd VimLeavePre * if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif
        autocmd InsertCharPre * ++once call CocAction('activeExtension', 'coc-snippets')
    augroup END]], false)

    cmd('highlight link CocHighlightText CurrentWord')

    local map_opt = {noremap = true, silent = true, expr = true}
    map('i', '<C-space>', 'coc#refresh()', map_opt)
    map('i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"]], map_opt)

    map('n', '<C-f>', [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]], map_opt)
    map('n', '<C-b>', [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]], map_opt)
    map('v', '<C-f>', [[coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"]], map_opt)
    map('v', '<C-b>', [[coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"]], map_opt)
    map('i', '<C-f>', [[coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]],
        map_opt)
    map('i', '<C-b>', [[coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]],
        map_opt)

    map('n', '[d', '<Plug>(coc-diagnostic-prev)', {})
    map('n', ']d', '<Plug>(coc-diagnostic-next)', {})

    map('n', 'gd', [[<Cmd>lua require('plugs.coc').go2def()<CR>]])
    map('n', 'gy', '<Plug>(coc-type-definition)', {})
    map('n', 'gi', '<Plug>(coc-implementation)', {})
    map('n', 'gr', '<Plug>(coc-references)', {})

    map('n', 'K', [[<Cmd>lua require('plugs.coc').show_documentation()<CR>]])

    map('n', '<leader>rn', '<Plug>(coc-refactor)', {})
    map('n', '<leader>ac', '<Plug>(coc-codeaction)', {})
    map('n', '<leader>qf', '<Plug>(coc-fix-current)', {})

    map('x', '<leader>x', '<Plug>(coc-convert-snippet)', {})

    cmd([[command! -nargs=0 OR call CocAction('runCommand', 'editor.action.organizeImport')]])
    map('n', '<leader>qi', '<Cmd>OR<CR>')
    map('n', '<M-q>', [[<Cmd>echo CocAction('getCurrentFunctionSymbol')<CR>]])
    map('n', '<leader>qd', [[<Cmd>lua require('plugs.coc').diagnostic()<CR>]])

    cmd([[command! -nargs=0 ClangdSH call CocAction('runCommand', 'clangd.switchSourceHeader')]])
    map('n', '<leader>sh', '<Cmd>ClangdSH<CR>')
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
                cmd('aboveleft lwindow')
            elseif def_size == 1 then
                cmd('lclose')
                fn.search(cword, 'c')
            end
        end) then
            vim.w.gtd = 'search'
            fn.searchdecl(cword)
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        cmd('normal! zz')
    end
end

function M.show_documentation()
    if vim.b.filetype == 'vim' or vim.b.filetype == 'help' then
        cmd(string.format('h %s', fn.expand('<cword>')))
    elseif api.nvim_exec([[echo CocAction('hasProvider', 'hover')]], true) == 'v:true' then
        fn['CocActionAsync']('doHover')
    else
        cmd('normal! K')
    end
end

function M.diagnostic()
    local diagnostics = fn['CocAction']('diagnosticList')
    local items, loc_ranges = {}, {}
    for _, d in ipairs(diagnostics) do
        local text = string.format('[%s%s] %s', (d.source == '' and 'coc.nvim' or d.source),
            (d.code and ' ' .. d.code or ''), d.message:match('[^\n]+\n*'))
        local item = {filename = d.file, lnum = d.lnum, col = d.col, text = text, type = d.severity}
        table.insert(loc_ranges, d.location.range)
        table.insert(items, item)
    end
    fn.setqflist({}, ' ', {
        title = 'CocDiagnosticList',
        items = items,
        context = {bqf = {lsp_ranges_hl = loc_ranges}}
    })
    cmd('botright copen')
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
        cmd('aboveleft lwindow')
    else
        api.nvim_set_current_win(winid)
    end
end

-- CocHasProvider('documentHighlight') has probability of RPC failure
-- Write the hardcode of filetype for fallback highlight
local fb_ft_black_list = {
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
    if vim.bo.buftype == 'terminal' or vim.tbl_contains(fb_ft_black_list, vim.bo.filetype) then
        return
    end

    if vim.w.coc_matchids_fb then
        pcall(fn.matchdelete, vim.w.coc_matchids_fb)
    end

    vim.w.coc_matchids_fb = fn.matchadd('CocHighlightText', get_cur_word(), -1)
end

init()

return M
