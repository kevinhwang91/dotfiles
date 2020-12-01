Plug 'kevinhwang91/rnvimr'
let g:rnvimr_enable_ex = 1
let g:rnvimr_enable_bw = 1
let g:rnvimr_hide_gitignore = 1
let g:rnvimr_border_attr = {'fg': 3}
let g:rnvimr_ranger_cmd = 'ranger'
highlight default link RnvimrNormal CursorLine
tnoremap <silent> <M-i> <C-\><C-n><Cmd>RnvimrResize<CR>
nnoremap <silent> <M-o> <Cmd>RnvimrToggle<CR>
tnoremap <silent> <M-o> <C-\><C-n><Cmd>RnvimrToggle<CR>
let g:rnvimr_ranger_views = [
            \ {'minwidth': 90, 'ratio': []},
            \ {'minwidth': 50, 'maxwidth': 89, 'ratio': [1,1]},
            \ {'maxwidth': 49, 'ratio': [1]}
            \ ]

" WIP need neovim 0.5
Plug 'kevinhwang91/nvim-bqf'
let g:bqf_auto_enable = 1

" WIP
Plug 'kevinhwang91/nvim-hlslens'
let g:hlslens_auto_enable = 1
noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>call hlslens#start()<CR>
noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>call hlslens#start()<CR>

augroup VMlens
    autocmd!
    autocmd User visual_multi_start call VMlensStart()
    autocmd User visual_multi_exit call VMlensExit()
augroup END

function! VMlensStart() abort
    if v:hlsearch && get(g:, 'hlslens_enabled', 0)
        let b:hlslens_existed = 1
    endif
    execute 'autocmd HlSearchLens CursorMoved * call hlslens#draw_lens(1)'
    call timer_start(0, {-> call('hlslens#draw_lens', [1])})
endfunction

function! VMlensExit() abort
    call hlslens#reset()
    if exists('b:hlslens_existed')
        unlet b:hlslens_existed
        call hlslens#start()
    endif
endfunction

if executable('fzf')
    Plug 'junegunn/fzf.vim'
    nnoremap <silent> <leader>ft <Cmd>BTags<CR>
    nnoremap <silent> <leader>fo <Cmd>Tags<CR>
    nnoremap <silent> <leader>fc <Cmd>BCommits<CR>
    nnoremap <silent> <leader>f/ <Cmd>History/<CR>
    nnoremap <silent> <leader>f; <Cmd>History:<CR>
    nnoremap <silent> <leader>fg <Cmd>GFiles<CR>
    nnoremap <silent> <leader>fm <Cmd>Marks<CR>
    nnoremap <silent> <leader>ff <Cmd>FZF<CR>
    nnoremap <silent> <leader>fb <Cmd>Buffers<CR>

    let $FZF_DEFAULT_OPTS .= ' --reverse --info=inline --border'
    let $BAT_STYLE='numbers'

    let g:fzf_layout = {'window': {'width': 0.7, 'height': 0.7}}

    augroup Fzf
        autocmd VimResized * call <SID>resize_fzf_preview()
    augroup END

    function s:resize_fzf_preview() abort
        try
            let layout = g:fzf_layout.window
            if &columns * layout.width - 2 > 100
                let g:fzf_preview_window = ['right:50%']
            else
                if &lines * layout.height - 2 > 25
                    let g:fzf_preview_window = ['down:50%']
                else
                    let g:fzf_preview_window = []
                endif
            endif
        catch /^Vim\%((\a\+)\)\=:E/
        endtry
    endfunction

    call s:resize_fzf_preview()

    " TODO how to lazyload fzf mru?
    call fzf_mru#enable()
    nnoremap <silent> <leader>fr <Cmd>call fzf_mru#mru()<CR>
endif

Plug 't9md/vim-choosewin', {'on': 'ChooseWin'}
nnoremap <M-0> <Cmd>ChooseWin<CR>
let g:choosewin_blink_on_land = 0
let g:choosewin_color_label = {'gui': ['#98c379', '#202326', 'bold']}
let g:choosewin_color_label_current = {'gui': ['#528bff', '#202326', 'bold']}
let g:choosewin_color_other = {'gui': ['#2c323c']}

" if executable('rg')
"     set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
"     set grepformat=%f:%l:%c:%m,%f:%l:%m
" endif

Plug 'mhinz/vim-grepper', {'on': ['Grepper', '<Plug>(GrepperOperator)']}
nnoremap <leader>rg <Cmd>Grepper -tool rg<CR>

augroup Grepper
    autocmd User Grepper belowright copen
augroup END

nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)

let g:grepper = {
            \ 'tools': ['rg', 'git'],
            \ 'dir': 'repo,file',
            \ 'open': 0,
            \ 'switch': 1,
            \ 'jump': 0,
            \ 'simple_prompt': 1,
            \ 'quickfix': 1,
            \ 'highlight': 1,
            \ 'rg': {
            \   'grepprg': 'rg -H --no-heading --vimgrep --smart-case',
            \   'grepformat': '%f:%l:%c:%m,%f:%l:%m',
            \   }
            \ }

Plug 'dyng/ctrlsf.vim'
let g:ctrlsf_ackprg = 'rg'
let g:ctrlsf_populate_qflist = 1
let g:ctrlsf_auto_focus = {'at': 'start'}
let g:ctrlsf_auto_preview = 1
let g:ctrlsf_default_root = 'project'
let g:ctrlsf_follow_symlinks = 1
let g:ctrlsf_mapping = {
            \ 'open': ['<CR>', 'o'],
            \ 'openb': 'O',
            \ 'split': '<C-x>',
            \ 'vsplit': '<C-v>',
            \ 'tab': 't',
            \ 'tabb': 'T',
            \ 'popen': 'p',
            \ 'popenf': 'P',
            \ 'quit': 'qq',
            \ 'next': '<C-j>',
            \ 'prev': '<C-k>',
            \ 'pquit': 'qq',
            \ 'loclist': '<C-s>',
            \ 'chgmode': 'M',
            \ 'stop': '<C-c>',
            \ }
highlight default link ctrlsfFilename Underlined
nmap <leader>ct <Plug>CtrlSFCCwordExec
xmap <leader>ct <Plug>CtrlSFVwordExec

function! CtrlSFAfterMainWindowInit()
    call ctrlsf_vm#init()
endfunction

Plug 'andymass/vim-matchup', {'on': []}

autocmd VimEnter * ++once call timer_start(100, {-> call('plug#load', ['vim-matchup'])})

let g:matchup_matchparen_timeout = 100
let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_deferred_show_delay = 150
let g:matchup_matchparen_deferred_hide_delay = 700
let g:matchup_matchparen_hi_surround_always = 1

let g:matchup_matchparen_offscreen = {'method': 'popup'}
let g:matchup_delim_start_plaintext = 0
let g:matchup_motion_override_Npercent = 0
let g:matchup_motion_cursor_end = 0
let g:matchup_mappings_enabled = 0

augroup MatchupMatch
    autocmd!
    autocmd TermEnter * call clearmatches()
    autocmd TermOpen * let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
augroup END

nmap % <Plug>(matchup-%)
omap % <Plug>(matchup-%)
xmap % <Plug>(matchup-%)
nmap [5 <Plug>(matchup-[%)
omap [5 <Plug>(matchup-[%)
xmap [5 <Plug>(matchup-[%)
nmap ]5 <Plug>(matchup-]%)
omap ]5 <Plug>(matchup-]%)
xmap ]5 <Plug>(matchup-]%)
nmap z' <Plug>(matchup-z%)
omap z' <Plug>(matchup-z%)
xmap z' <Plug>(matchup-z%)
omap a5 <Plug>(matchup-a%)
xmap a5 <Plug>(matchup-a%)
omap i5 <Plug>(matchup-i%)
xmap i5 <Plug>(matchup-i%)

Plug 'haya14busa/vim-asterisk'
let g:asterisk#keeppos = 0

map *  <Plug>(asterisk-z*)<Cmd>call hlslens#start()<CR>
map #  <Plug>(asterisk-z#)<Cmd>call hlslens#start()<CR>
map g* <Plug>(asterisk-gz*)<Cmd>call hlslens#start()<CR>
map g# <Plug>(asterisk-gz#)<Cmd>call hlslens#start()<CR>
