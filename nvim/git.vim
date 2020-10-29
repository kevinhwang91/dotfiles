Plug 'tpope/vim-fugitive'
let g:nremap = {'d?': 's?', 'dv': 'sv', 'dp': 'sp', 'ds': 'sh', 'dh': 'sh',
            \ 'dd': 'ss', 'dq': 'qd', 's': 'S', 'u': '<C-u>', 'O': 'T',
            \ '[m': '[f', ']m': ']f'}
let g:xremap = {'s': 'S', 'u': '<C-u>'}

nnoremap <silent> <leader>gg <Cmd>tab Git<CR>
nnoremap <leader>gc :Git commit<Space>
nnoremap <leader>gC :Git commit --amend<Space>
nnoremap <leader>ge <Cmd>Gedit<CR>
nnoremap <silent> <leader>gb <Cmd>Git blame -w <bar> setlocal nocursorline nocursorbind <bar>
            \ wincmd p<CR>
nnoremap <leader>gw <Cmd>execute 'FollowSymlink' <bar> Gwrite<CR>
nnoremap <leader>gr <Cmd>execute 'FollowSymlink' <bar> keepalt Gread <bar> w!<CR>
nnoremap <silent> <leader>gd <Cmd>Gdiffsplit<CR>
nnoremap <silent> <leader>gD <Cmd>Gdiffsplit HEAD<CR>
nnoremap <silent> qd <Cmd>call fugitive#DiffClose()<CR>

Plug 'ruanyl/vim-gh-line', {'on': ['<Plug>(gh-repo)', '<Plug>(gh-line)']}
map <leader>gO <Plug>(gh-repo)
map <leader>gL <Plug>(gh-line)

Plug 'airblade/vim-gitgutter'
let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_signs = 0
let g:gitgutter_max_signs = 9999
highlight default link GitGutterAddLineNr GitGutterAdd
highlight default link GitGutterChangeLineNr GitGutterChange
highlight default link GitGutterDeleteLineNr GitGutterDelete
highlight default link GitGutterChangeDeleteLineNr GitGutterChangeDeleteLine
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
let g:flog_default_arguments = {'max_count': 1000}
nnoremap <silent> <leader>gl <Cmd>Flog<CR>

function s:vim_flog_map() abort
    nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
    vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
    nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
    vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
    nmap <buffer> U <Plug>(FlogUpdate)
    nmap <buffer> o <Plug>(FlogVSplitCommitRight)
    nnoremap <buffer><silent> <CR> <Cmd>belowright Flogsplitcommit<CR>
    nnoremap <buffer><silent> <C-n> <Cmd>call flog#next_commit() <bar> belowright Flogsplitcommit<CR>
    nnoremap <buffer><silent> <C-p> <Cmd>call flog#previous_commit() <bar> belowright Flogsplitcommit<CR>
    nmap <buffer> ]R <Plug>(FlogVNextRefRight)
    nmap <buffer> [R <Plug>(FlogVPrevRefRight)
    nnoremap <buffer><silent> ]r <Cmd>call flog#next_ref() <bar> belowright Flogsplitcommit<CR>
    nnoremap <buffer><silent> [r <Cmd>call flog#previous_ref() <bar> belowright Flogsplitcommit<CR>
    nnoremap <buffer> rl :Floggit reset <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
    nnoremap <buffer> rh :Floggit reset --hard <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
endfunction

augroup VimFlog
    autocmd!
    autocmd FileType floggraph call <SID>vim_flog_map()
augroup END

Plug 'rhysd/git-messenger.vim', {'on': 'GitMessenger'}
let g:git_messenger_no_default_mappings = 0
let g:git_messenger_always_into_popup = 1
nnoremap <silent> <Leader>gm <Cmd>GitMessenger<CR>

function s:git_messenger_map() abort
    nunmap <buffer> d
    nunmap <buffer> D
    nmap <buffer><silent><nowait> s <Cmd>call b:__gitmessenger_popup.opts.mappings['d'][0]()<CR>
    nmap <buffer><silent><nowait> S <Cmd>call b:__gitmessenger_popup.opts.mappings['D'][0]()<CR>
endfunction

augroup GitMessenger
    autocmd!
    autocmd FileType gitmessengerpopup call <SID>git_messenger_map()
augroup END
