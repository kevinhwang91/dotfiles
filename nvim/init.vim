syntax on
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set softtabstop=-1
set expandtab
set autoindent
set smartindent
set clipboard=unnamedplus
set timeout
set timeoutlen=500
set ignorecase
set smartcase
set updatetime=200
set hidden
set cursorline
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
set noshowmode
set cedit=<C-x>
set list
set listchars=tab:\│\ ,trail:•
set showbreak=╰─➤
set nofoldenable
set foldcolumn=1
set title
set titlestring=%(%m%)%(%{expand(\"%:~\")}%)
set history=10000
set lazyredraw
set inccommand=nosplit
set shortmess+=aIc
set signcolumn=yes:1
set shada=!,'300,<50,s10,h
set synmaxcol=300

" undo
set undofile
set undolevels=1000

" no backup
set nobackup
set noswapfile

" true color
if (has('termguicolors'))
    set termguicolors
    set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20
endif

" harcode for reducing startup time
let g:python3_host_prog = '/usr/bin/python3'
if exists('$DISPLAY') && executable('xsel')
    let g:clipboard = {
                \ 'name': 'xsel',
                \ 'copy': {
                \   '+': ['xsel', '--nodetach', '-i', '-b'],
                \   '*': ['xsel', '--nodetach', '-i', '-b'],
                \ },
                \ 'paste': {
                \   '+': ['xsel', '-o', '-b'],
                \   '*': ['xsel', '-o', '-b'],
                \ },
                \ 'cache_enabled': 1
                \ }
elseif exists('$TMUX')
    let g:clipboard = {
                \ 'name': 'tmux',
                \ 'copy': {
                \   '+': ['tmux', 'load-buffer', '-'],
                \   '*': ['tmux', 'load-buffer', '-'],
                \  },
                \ 'paste': {
                \   '+': ['tmux', 'save-buffer', '-'],
                \   '*': ['tmux', 'save-buffer', '-'],
                \ },
                \ 'cache_enabled': 1,
                \ }
    " load-buffer support -w in 3.3 version
    if str2float(matchstr(system('tmux -V')[0:-2], '\d\+\.\d\+')) >= 3.3
        let g:clipboard['copy']['+'] = ['tmux', 'load-buffer', '-w', '-']
        let g:clipboard['copy']['*'] = ['tmux', 'load-buffer', '-w', '-']
    endif
endif

" source config file function
let s:conf_dir = expand("<sfile>:p:h")
function s:source(config) abort
    let path = s:conf_dir . '/' . a:config
    if !empty(glob(path))
        execute 'source' path
    endif
endfunction

call s:source('script.vim')

" map
let mapleader = ' '
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
nnoremap q <Nop>
nnoremap Q <Nop>
nnoremap - "_
xnoremap - "_
nnoremap <silent> qq :confirm q<CR>
nnoremap <silent> qa :confirm qa<CR>
nnoremap <silent> qt :tabc<CR>
nnoremap <silent> qc :ccl<CR>
nnoremap <silent> qs :lcl<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <C-g> 1<C-g>
nnoremap <silent> <leader>3 :buffer #<CR>
nnoremap <silent> <leader>l :nohlsearch<CR>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-d> <Del>
cnoremap <C-k> <C-\>egetcmdline()[:getcmdpos() - 2]<CR>
cnoremap <M-b> <C-Left>
cnoremap <M-f> <C-Right>
if has('nvim-0.5')
    cnoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
endif
tnoremap <M-\> <C-\><C-n>

nnoremap s d
xnoremap s d
onoremap s d
nnoremap d <C-d>
xnoremap d <C-d>
nnoremap u <C-u>
xnoremap u <C-u>
nnoremap <C-u> u
nnoremap <expr> k (v:count > 1 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 1 ? "m'" . v:count : '') . 'j'

nnoremap ' `
xnoremap ' `
onoremap ' `
nnoremap ` '
xnoremap ` '
onoremap ` '
nnoremap g' g`
xnoremap g' g`
onoremap g' g`
nnoremap g` g'
xnoremap g` g'
onoremap g` g'
nnoremap m' m`
xnoremap m' m`
nnoremap m` m'
xnoremap m` m'
nnoremap <silent> '0 :normal! `0<CR>:silent! CleanEmptyBuf<CR>
xnoremap <silent> '0 :normal! `0<CR>:silent! CleanEmptyBuf<CR>
nnoremap <silent><leader>i :silent! normal! `^<CR>

xnoremap <silent> <M-j> :move '>+1<CR>gv=gv
xnoremap <silent> <M-k> :move '<-2<CR>gv=gv
nnoremap <silent> yd :call setreg(v:register, expand('%:p:h'))<CR>:echo expand('%:p:h')<CR>
nnoremap <silent> yn :call setreg(v:register, expand('%:t'))<CR>:echo expand('%:t')<CR>
nnoremap <silent> yp :call setreg(v:register, expand('%:p'))<CR>:echo expand('%:p')<CR>
nnoremap Y y$

function s:prefix_timeout(prefix)
    let char = getchar(0)
    if type(char) == 0
        let char = nr2char(char)
    endif
    if empty(char)
        return '\<Nul>'
    else
        return a:prefix . char
    endif
endfunction

nnoremap <expr> [ <SID>prefix_timeout('[')
xnoremap <expr> [ <SID>prefix_timeout('[')
nnoremap <expr> ] <SID>prefix_timeout(']')
xnoremap <expr> ] <SID>prefix_timeout(']')
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap [s :lprevious<CR>
nnoremap ]s :lnext<CR>
nnoremap [S :lfirst<CR>
nnoremap ]S :llast<CR>
nnoremap [z [z_
xnoremap [z [z_
nnoremap ]z ]z_
xnoremap ]z ]z_
nnoremap <expr> z <SID>prefix_timeout('z')
xnoremap <expr> z <SID>prefix_timeout('z')
nnoremap zj zj_
xnoremap zj zj_
nnoremap zk zk_
xnoremap zk zk_

function s:nav_fold(forward, count)
    let view = winsaveview()
    normal! m'
    let cnt = a:count
    while cnt > 0
        if a:forward
            execute 'keepjumps normal! ]z'
        else
            execute 'keepjumps normal! zk'
        endif
        let cur_pos = getpos('.')
        if a:forward
            execute 'keepjumps normal! zj_'
        else
            execute 'keepjumps normal! [z_'
        endif
        let cnt -= 1
    endwhile
    if cur_pos == getpos('.')
        call winrestview(view)
    else
        normal! m'
    endif
endfunction

nnoremap <silent> z[ :<C-u>call <SID>nav_fold(0, v:count1)<CR>
nnoremap <silent> z] :<C-u>call <SID>nav_fold(1, v:count1)<CR>

if empty($XDG_CONFIG_HOME)
    call plug#begin('~/.config/nvim/plugged')
else
    call plug#begin(expand("$XDG_CONFIG_HOME/nvim/plugged"))
endif

" navigation
call s:source('nav.vim')

" edit
call s:source('edit.vim')

" theme
call s:source('theme.vim')

" statusline
call s:source('stl.vim')

" git
call s:source('git.vim')

" highlight syntax
call s:source('hl.vim')

" format
call s:source('format.vim')

" fold
call s:source('fold.vim')

" tmux
call s:source('tmux.vim')

" markdown
call s:source('mdk.vim')

" language server client
call s:source('coc.vim')

" debug
call s:source('debug.vim')

" rarely used
call s:source('misc.vim')

" snippet
Plug 'honza/vim-snippets'

" man
augroup ManInitPost
    autocmd!
    autocmd FileType man call timer_start(0, {-> execute('unmap <buffer> q')})
augroup END

" document
Plug 'kkoomen/vim-doge', {'on': ['DogeGenerate', 'DogeCreateDocStandard']}
let g:doge_enable_mappings = 0
nnoremap <leader>dg :DogeGenerate<CR>
let g:doge_mapping_comment_jump_forward = '<C-j>'
let g:doge_mapping_comment_jump_backward = '<C-k>'

" comment
Plug 'preservim/nerdcommenter', {'on': ['<Plug>NERDCommenterToggle']}
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDToggleCheckAllLines = 1
let g:NERDTrimTrailingWhitespace = 1
map <C-_> <Plug>NERDCommenterToggle

call plug#end()

" color scheme
try
    colorscheme one
catch
endtry
