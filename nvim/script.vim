" man
let g:no_man_maps = 1
augroup ManInit
    autocmd!
    autocmd FileType man nmap <buffer> gO :call man#show_toc()<CR>
augroup END

" remove ansi color
command! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g

augroup RnuColumn
    autocmd!
    autocmd FocusLost * call rnu#focuslost()
    autocmd FocusGained * call rnu#focusgained()
    autocmd WinEnter * call rnu#winenter()
augroup END

function s:follow_symlink(...) abort
    let fname = a:0 ? a:1 : expand('%')
    if getftype(fname) != 'link'
        return
    endif
    execute 'keepalt file ' . fnameescape(resolve(fname))
endfunction

command! -nargs=? -complete=buffer FollowSymlink call <SID>follow_symlink(<f-args>)

function s:clean_empty_buf()
    let bufnr_list = []
    for buf in getbufinfo({'buflisted': 1})
        if !buf.changed && empty(buf.name)
            call add(bufnr_list, buf.bufnr)
        endif
    endfor
    if !empty(bufnr_list)
        execute 'bwipeout ' . join(bufnr_list)
    endif
endfunction

command! -nargs=0 CleanEmptyBuf call <SID>clean_empty_buf()
nnoremap <silent> qe <Cmd>CleanEmptyBuf<CR>

function s:zz() abort
    let l1 = line('.')
    let l_count = line('$')
    if l1 == l_count
        keepjumps execute 'normal! ' . l1 . 'zb'
        return
    endif
    normal! zvzz
    let l1 = line('.')
    normal! L
    let l2 = line('.')
    if l2 + &scrolloff >= l_count
        keepjumps execute 'normal! ' . l2 . 'zb'
    endif
    if l1 != l2
        keepjumps normal! ``
    endif
endfunction

nnoremap zZ <Cmd>call <SID>zz()<CR>
xnoremap zZ <Cmd>call <SID>zz()<CR>

augroup ShadowWindow
    autocmd!
    autocmd WinEnter * call shadowwin#enable()
augroup END

command! Jumps call jumplist#to_qf()
nnoremap <silent> <leader>jj <Cmd>Jumps<CR>
