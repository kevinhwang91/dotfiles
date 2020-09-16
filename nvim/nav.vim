Plug 'kevinhwang91/rnvimr'
let g:rnvimr_enable_ex = 1
let g:rnvimr_enable_bw = 1
let g:rnvimr_hide_gitignore = 1
let g:rnvimr_border_attr = {'fg': 3}
let g:rnvimr_ranger_cmd = 'ranger --cmd="set column_ratios 1,1"'
highlight default link RnvimrNormal CursorLine
tnoremap <silent> <M-i> <C-\><C-n>:RnvimrResize<CR>
nnoremap <silent> <M-o> :RnvimrToggle<CR>
tnoremap <silent> <M-o> <C-\><C-n>:RnvimrToggle<CR>

if executable('fzf')
    Plug 'junegunn/fzf.vim'
    nnoremap <silent> <leader>ft :BTags<CR>
    nnoremap <silent> <leader>fo :Tags<CR>
    nnoremap <silent> <leader>fc :BCommits<CR>
    nnoremap <silent> <leader>f/ :History/<CR>
    nnoremap <silent> <leader>f; :History:<CR>
    nnoremap <silent> <leader>fr :History<CR>
    nnoremap <silent> <leader>fg :GFiles<CR>
    nnoremap <silent> <leader>fm :Marks<CR>
    nnoremap <silent> <leader>ff :FZF<CR>
    nnoremap <silent> <leader>fb :Buffers<CR>

    let $FZF_DEFAULT_OPTS .= ' --reverse --info=inline'
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
endif

Plug 't9md/vim-choosewin', {'on': 'ChooseWin'}
nnoremap <M-0> :ChooseWin<CR>
let g:choosewin_blink_on_land = 0
let g:choosewin_color_label = { 'gui': ['#98c379', '#202326', 'bold'] }
let g:choosewin_color_label_current = { 'gui': ['#528bff', '#202326', 'bold'] }
let g:choosewin_color_other = { 'gui': ['#2c323c'] }

Plug 'dyng/ctrlsf.vim'
let g:ctrlsf_ackprg = 'rg'
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
            \ 'loclist': '',
            \ 'chgmode': 'M',
            \ 'stop': '<C-c>',
            \ }
highlight default link ctrlsfFilename Underlined

nmap <leader>rg <Plug>CtrlSFCCwordExec
xmap <leader>rg <Plug>CtrlSFVwordExec
cabbrev rg CtrlSF
cabbrev rgt CtrlSF -T
cabbrev rgr CtrlSF -R

function! CtrlSFAfterMainWindowInit()
    setlocal wrap
    autocmd BufWinEnter <buffer> call s:ctrlsf_enter()
    autocmd BufWinLeave <buffer> call s:ctrlsf_leave()
    doautocmd BufWinEnter <buffer>

    let b:visual_multi_map = {'n': 'VM-Find-Next', 'N': 'VM-Find-Prev',
                \'q': 'VM-Skip-Region', 'Q': 'VM-Remove-Region',
                \']': 'VM-Goto-Next', '[': 'VM-Goto-Prev'}
    nnoremap <buffer><expr><silent> <leader>1
                \ execute('let g:ctrlsf_auto_preview = !g:ctrlsf_auto_preview')
    nnoremap <buffer><silent> <C-n> :call <SID>vm_match_pat()<CR>

    nnoremap <buffer><silent> [f :call <SID>nav_file(0)<CR>
    nnoremap <buffer><silent> ]f :call <SID>nav_file(1)<CR>
endfunction

function! Wrap_VM_Start() abort
    let b:vm_set_statusline = get(g:, 'VM_set_statusline', 2)
    let g:VM_set_statusline = 0
    for [key, val] in items(b:visual_multi_map)
        execute 'nmap <buffer><nowait><silent> '. key .
                    \' :call <SID>wrap_vm_map("'. val . '")<CR>'
    endfor
    nmap <buffer><nowait><silent> <C-n> n
endfunction

function! Wrap_VM_Exit() abort
    let g:VM_set_statusline = b:vm_set_statusline
    for key in keys(b:visual_multi_map)
        execute 'nunmap <buffer> ' . key
    endfor
    nnoremap <buffer><silent> <C-n> :call <SID>vm_match_pat()<CR>
endfunction

function s:nav_file(forward) abort
    call search('^\%(\([0-9]\+\)\|\.\.\.\.\)\@!.\+\ze:$', a:forward ? 'W' : 'bW')
endfunction

function s:ctrlsf_enter() abort
    if get(g:, 'loaded_lightline', 0)
        " autocmd! lightline BufEnter
        autocmd! lightline WinEnter
    endif
    augroup CtrlSFWithVisualMulti
        autocmd!
        autocmd User visual_multi_start call Wrap_VM_Start()
        autocmd User visual_multi_exit call Wrap_VM_Exit()
    augroup END
endfunction

function s:ctrlsf_leave() abort
    if get(g:, 'loaded_lightline', 0)
        " autocmd lightline BufEnter * call lightline#update()
        autocmd lightline WinEnter * call lightline#update()
    endif
    autocmd! CtrlSFWithVisualMulti
endfunction

function s:vm_match_pat()
    for m in getmatches()
        if m.group ==# 'ctrlsfMatch'
            let ctrlsf_pat = m.pattern
            break
        endif
    endfor
    if !exists('ctrlsf_pat')
        return
    endif
    noautocmd normal! gE
    execute 'VMSearch ' . ctrlsf_pat
    execute "normal \<Plug>(VM-Show-Infoline)"
endfunction

function s:wrap_vm_map(action) abort
    let preview = get(g:, 'ctrlsf_auto_preview', 0)
    if preview
        let b:VM_skip_reset_once_on_bufleave = 1
    endif
    execute "normal \<Plug>(" . a:action . ')'
    if preview
        call ctrlsf#JumpTo('preview')
    endif
    execute "normal \<Plug>(VM-Show-Infoline)"
endfunction

Plug 'andymass/vim-matchup'
let loaded_matchit = 1
let loaded_matchparen = 1

let g:matchup_matchparen_timeout = 100
let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_deferred_show_delay = 150
let g:matchup_matchparen_deferred_hide_delay = 700
let g:matchup_matchparen_hi_surround_always = 1
let g:matchup_motion_override_Npercent = 0
let g:matchup_motion_cursor_end = 0
let g:matchup_mappings_enabled = 0

nmap % <Plug>(matchup-%)
omap % <Plug>(matchup-%)
xmap % <Plug>(matchup-%)
nmap g5 <Plug>(matchup-g%)
omap g5 <Plug>(matchup-g%)
xmap g5 <Plug>(matchup-g%)
nmap [5 <Plug>(matchup-[%)
omap [5 <Plug>(matchup-[%)
xmap [5 <Plug>(matchup-[%)
nmap ]5 <Plug>(matchup-]%)
omap ]5 <Plug>(matchup-]%)
xmap ]5 <Plug>(matchup-]%)
nmap z5 <Plug>(matchup-z%)
omap z5 <Plug>(matchup-z%)
xmap z5 <Plug>(matchup-z%)
omap a5 <Plug>(matchup-a%)
xmap a5 <Plug>(matchup-a%)
omap i5 <Plug>(matchup-i%)
xmap i5 <Plug>(matchup-i%)
