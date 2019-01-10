Plug 'tpope/vim-fugitive'
let g:nremap = {'d?': 's?', 'dv': 'sv', 'dp': 'sp', 'ds': 'sh', 'dh': 'sh',
            \ 'dd': 'ss', 'dq': 'sq', 's': 'S', 'u': '<C-u>', 'O': 'T',
            \ '[m': '[f', ']m': ']f'}
let g:xremap = {'s': 'S', 'u': '<C-u>'}

nnoremap <silent> <leader>gg :tab Git<CR>
nnoremap <leader>gc :Git commit<Space>
nnoremap <leader>ge :Gedit<CR>
nnoremap <silent> <leader>gb :Git blame -w <bar> setlocal nocursorline nocursorbind <bar>
            \ wincmd p<CR>
nnoremap <leader>gw :execute 'FollowSymlink' <bar> Gwrite<CR>
nnoremap <leader>gr :execute 'FollowSymlink' <bar> Gread <bar> w!<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gD :Gdiffsplit HEAD<CR>

Plug 'tpope/vim-rhubarb'

Plug 'airblade/vim-gitgutter'
let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_signs = 0
let g:gitgutter_max_signs = 9999
highlight default link GitGutterAddLineNr SignifySignAdd
highlight default link GitGutterChangeLineNr SignifySignChange
highlight default link GitGutterDeleteLineNr SignifySignDelete
highlight default link GitGutterChangeDeleteLineNr SignifySignDelete
let g:gitgutter_map_keys = 0
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

Plug 'rbong/vim-flog', {'on': ['Flog', 'Flogsplit']}
let g:flog_default_arguments = {'max_count': 100}
nnoremap <silent> <leader>gl :Flog<CR>

augroup VimFlog
    autocmd!
    autocmd FileType floggraph nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
    autocmd FileType floggraph vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
    autocmd FileType floggraph nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
    autocmd FileType floggraph vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
    autocmd FileType floggraph nmap <buffer> U <Plug>(FlogUpdate)
augroup END

Plug 'rhysd/git-messenger.vim', {'on': 'GitMessenger'}
let g:git_messenger_no_default_mappings = 0
let g:git_messenger_always_into_popup = 1
nnoremap <silent> <Leader>gm :GitMessenger<CR>

function s:map_git_messenger_popup() abort
    nunmap <buffer> d
    nunmap <buffer> D
    nmap <buffer><silent><nowait> s :<C-u>call b:__gitmessenger_popup.opts.mappings['d'][0]()<CR>
    nmap <buffer><silent><nowait> S :<C-u>call b:__gitmessenger_popup.opts.mappings['D'][0]()<CR>
endfunction

augroup GitMessenger
    autocmd!
    autocmd FileType gitmessengerpopup call <SID>map_git_messenger_popup()
augroup END
