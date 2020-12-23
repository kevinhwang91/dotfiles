Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile', 'on': []}
" Plug 'neoclide/coc.nvim', {'on': []}
autocmd VimEnter * ++once call timer_start(100, {-> call('plug#load', ['coc.nvim'])})

let g:coc_global_extensions = [
            \ 'coc-go',
            \ 'coc-html',
            \ 'coc-json',
            \ 'coc-pyright',
            \ 'coc-java',
            \ 'coc-rust-analyzer',
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

let g:coc_enable_locationlist = 0
autocmd User CocNvimInit ++once call <SID>coc_lazy_init()

function s:coc_lazy_init() abort
    augroup Coc
        autocmd!
        autocmd User CocLocationsChange ++nested call coc_ext#jump_to_loc(g:coc_jump_locations)
        autocmd CursorHold * silent! call CocActionAsync('highlight',
                    \ '', function('coc_ext#highlight_fallback'))
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        autocmd VimLeavePre * if get(g:, 'coc_process_pid', 0) |
                    \ call system('kill -9 ' . g:coc_process_pid) | endif
    augroup END
endfunction

inoremap <silent><expr> <C-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Cmd>call coc_ext#go_to_definition()<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K <Cmd>call coc_ext#show_documentation()<CR>

highlight default link CocHighlightText CurrentWord

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

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR <Cmd>call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <silent> <leader>qi <Cmd>OR<CR>

nnoremap <silent> <M-q> <Cmd>echo CocAction('getCurrentFunctionSymbol')<CR>

nnoremap <silent> <leader>qd <Cmd>call coc_ext#qf_diagnostic()<CR>
