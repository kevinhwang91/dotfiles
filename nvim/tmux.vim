Plug 'jpalardy/vim-slime', {'on': ['<Plug>SlimeRegionSend',
            \ '<Plug>SlimeParagraphSend', '<Plug>SlimeConfig']}
let g:slime_target = 'tmux'
let g:slime_default_config = {
            \ 'socket_name': get(split($TMUX, ','), 0),
            \ 'target_pane': ':.'
            \ }
let g:slime_no_mappings = 1
let g:slime_python_ipython = 1
xmap <C-c><C-c> <Plug>SlimeRegionSend
nmap <C-c><C-c> <Plug>SlimeParagraphSend
nmap <C-c>v <Plug>SlimeConfig

Plug 'wellle/tmux-complete.vim'
