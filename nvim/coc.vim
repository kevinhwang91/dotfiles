Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

let g:coc_global_extensions = [
            \ 'coc-go',
            \ 'coc-html',
            \ 'coc-json',
            \ 'coc-jedi',
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
nmap <silent> gd :call <SID>go_to_definition()<CR>
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
            let line = line('.')
            execute('tjump ' . cword)
            if line == line('.')
                return
            endif
            let w:gtd = 'tag'
            call search(cword, 'c')
            if bufnr() != bufnr
                normal zz
            endif
        catch /.*/
            let w:gtd = 'search'
            call searchdecl(cword)
        endtry
    endif
endfunction

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute('h '. expand('<cword>'))
    else
        call CocAction('doHover')
    endif
endfunction

augroup Coc
    autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight',
                \ '', function('s:highlight_fallback'))
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
highlight default link CocHighlightText CurrentWord

 " CocHasProvider('documentHighlight') has probability of RPC failure
 " Write the hardcode of filetype for fallback highlight
let s:fb_ft_black_list = [
            \ 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java',
            \ 'typescript', 'javascript', 'css', 'html', 'xml'
            \ ]

function s:get_cur_word()
    let line = getline('.')
    let col = col('.')
    let left = strpart(line, 0, col)
    let right = strpart(line, col - 1, col('$'))
    let word = matchstr(left, '\k*$') . matchstr(right, '^\k*')[1:]
    return '\<' . escape(word, '/\') . '\>'
endf

function s:highlight_fallback(err, res)
    if index(s:fb_ft_black_list, &filetype) > -1
        return
    endif

    if exists('w:coc_matchids_fb')
        silent! call matchdelete(w:coc_matchids_fb)
    endif

    let w:coc_matchids_fb = matchadd('CocHighlightText', s:get_cur_word(), -1)
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-refactor)

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

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

nnoremap <silent> <M-q> :echo CocAction('getCurrentFunctionSymbol')<CR>
