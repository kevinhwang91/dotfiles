Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
" Plug 'neoclide/coc.nvim'

Plug 'rafcamlet/coc-nvim-lua'

let g:coc_global_extensions = [
            \ 'coc-go',
            \ 'coc-html',
            \ 'coc-json',
            \ 'coc-pyright',
            \ 'coc-java',
            \ 'coc-rust-analyzer',
            \ 'coc-lua',
            \ 'coc-tsserver',
            \ 'coc-vimlsp',
            \ 'coc-xml',
            \ 'coc-yaml',
            \ 'coc-css',
            \ 'coc-diagnostic',
            \ 'coc-dictionary',
            \ 'coc-markdownlint',
            \ 'coc-snippets',
            \ 'coc-word',
            \ 'coc-postfix'
            \ ]

inoremap <silent><expr> <C-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Cmd>call <SID>go_to_definition()<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

function! s:go_to_definition()
    let bufnr = bufnr()
    silent let ret = CocAction('jumpDefinition')
    if ret
        let w:gtd = 'coc'
        if bufnr() != bufnr
            normal zz
        endif
    else
        let cword = expand('<cword>')
        try
            execute('ltag ' . cword)
            let def_size = getloclist(0, {'size': 0}).size
            let w:gtd = 'tag'
            if def_size > 1
                execute("normal! \<C-o>")
                execute('lopen ' . def_size)
            elseif def_size == 1
                lclose
                call search(cword, 'c')
                if bufnr() != bufnr
                    normal zz
                endif
            endif
        catch /.*/
            let w:gtd = 'search'
            call searchdecl(cword)
        endtry
    endif
endfunction

" Use K for show documentation in preview window
nnoremap <silent> K <Cmd>call <SID>show_documentation()<CR>

function s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute('h '. expand('<cword>'))
    else
        call CocAction('doHover')
    endif
endfunction

let g:coc_enable_locationlist = 0
augroup Coc
    autocmd!
    autocmd User CocLocationsChange ++nested call <SID>jump_to_loc(g:coc_jump_locations)
    autocmd CursorHold * silent call CocActionAsync('highlight',
                \ '', function('s:highlight_fallback'))
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    autocmd VimLeavePre * if get(g:, 'coc_process_pid', 0) |
                \ call system('kill -9 ' . g:coc_process_pid) | endif
augroup END

function s:jump_to_loc(locs) abort
    let loc_range = map(deepcopy(a:locs), 'v:val.range')
    let loc = setloclist(0, [], ' ', {'title': 'CocLocationList', 'items': a:locs,
                \ 'context': {'bqf': {'lsp_range_hl': loc_range}}})
    let winid = getloclist(0, {'winid': 0}).winid
    if winid == 0
        aboveleft lwindow
    else
        call win_gotoid(winid)
    endif
endfunction

" CocHasProvider('documentHighlight') has probability of RPC failure
" Write the hardcode of filetype for fallback highlight
let s:fb_ft_black_list = [
            \ 'qf', 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java',
            \ 'typescript', 'javascript', 'css', 'html', 'xml'
            \ ]

highlight default link CocHighlightText CurrentWord

function s:get_cur_word()
    let line = getline('.')
    let col = col('.')
    let left = strpart(line, 0, col)
    let right = strpart(line, col - 1, col('$'))
    let word = matchstr(left, '\k*$') . matchstr(right, '^\k*')[1:]
    return '\<' . escape(word, '/\') . '\>'
endf

function s:highlight_fallback(err, res)
    if &buftype == 'terminal' || index(s:fb_ft_black_list, &filetype) > -1
        return
    endif

    if exists('w:coc_matchids_fb')
        silent! call matchdelete(w:coc_matchids_fb)
    endif

    let w:coc_matchids_fb = matchadd('CocHighlightText', s:get_cur_word(), -1)
endfunction

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
" Remap for rename current word
nmap <silent> <leader>rn <Plug>(coc-refactor)
" Remap keys for applying codeAction to the current buffer.
nmap <silent> <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <silent> <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ik <Plug>(coc-classobj-i)
omap ik <Plug>(coc-classobj-i)
xmap ak <Plug>(coc-classobj-a)
omap ak <Plug>(coc-classobj-a)

" TODO
map [f vafo<Esc>
map ]f vaf<Esc>

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR <Cmd>call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <silent> <leader>qi <Cmd>OR<CR>

nnoremap <silent> <M-q> <Cmd>echo CocAction('getCurrentFunctionSymbol')<CR>
