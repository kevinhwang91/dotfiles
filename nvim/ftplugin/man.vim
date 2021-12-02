" copy from runtime/autoload/man.vim
" add abo mod for lopen
function s:show_toc() abort
    let bufname = bufname('%')
    let info = getloclist(0, {'winid': 1})
    if !empty(info) && getwinvar(info.winid, 'qf_toc') ==# bufname
        abo lopen
        return
    endif

    let toc = []
    let lnum = 2
    let last_line = line('$') - 1
    while lnum && lnum < last_line
        let text = getline(lnum)
        if text =~# '^\%( \{3\}\)\=\S.*$'
            call add(toc, {'bufnr': bufnr('%'), 'lnum': lnum, 'text': text})
        endif
        let lnum = nextnonblank(lnum + 1)
    endwhile

    call setloclist(0, toc, ' ')
    call setloclist(0, [], 'a', {'title': 'Man TOC'})
    abo lopen
    let w:qf_toc = bufname
endfunction

setlocal signcolumn=no

nnoremap <silent><buffer> gO <Cmd>call <SID>show_toc()<CR>
nnoremap <silent><buffer> gd <C-]>

call timer_start(0, {-> execute('sil! nunmap <buffer> q')})
