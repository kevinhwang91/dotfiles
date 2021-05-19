setl so=1

" fix last window is floating with hl and blend
if &winhl != ''
    call nvim_win_set_option(0, 'winhl', '')
endif

if &winbl
    call nvim_win_set_option(0, 'winbl', 0)
endif

noremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>
