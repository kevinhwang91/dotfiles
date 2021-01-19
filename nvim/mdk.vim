Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_emphasis_multiline = 0
let g:vim_markdown_edit_url_in = 'current'

augroup VimMarkdown
    autocmd!
    autocmd FileType markdown setlocal foldenable foldlevel=99 foldlevelstart=99
    autocmd FileType markdown nnoremap <silent><buffer> gO <Cmd>Toc<CR>
    autocmd FileType markdown vnoremap <silent><buffer> gO <Cmd>Toc<CR>
    autocmd FileType markdown nnoremap <silent><buffer> <leader>to <Cmd>InsertToc<CR>
    autocmd FileType markdown nmap <buffer> ]] <Plug>Markdown_MoveToNextHeader
    autocmd FileType markdown vmap <buffer> ]] <Plug>Markdown_MoveToNextHeader
    autocmd FileType markdown nmap <buffer> [[ <Plug>Markdown_MoveToPreviousHeader
    autocmd FileType markdown vmap <buffer> [[ <Plug>Markdown_MoveToPreviousHeader
    autocmd FileType markdown nmap <silent><buffer> gx <Plug>Markdown_OpenUrlUnderCursor
    autocmd FileType markdown vmap <silent><buffer> gx <Plug>Markdown_OpenUrlUnderCursor
    autocmd FileType markdown nmap <silent><buffer> ge <Plug>Markdown_EditUrlUnderCursor
    autocmd FileType markdown vmap <silent><buffer> ge <Plug>Markdown_EditUrlUnderCursor
augroup END

Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app && yarn install', 'for': 'markdown'}
let g:mkdp_auto_close = 0
