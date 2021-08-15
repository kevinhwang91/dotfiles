setl so=2

" fix last window is floating with hl and blend
if &winhl != ''
    setlocal winhl=
endif

if &winbl
    setlocal winbl=0
endif

noremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>
