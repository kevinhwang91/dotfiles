" man
let g:no_man_maps = 1
augroup ManInit
    autocmd!
    autocmd FileType man nmap <buffer> gO :call man#show_toc()<CR>
augroup END

" wrap UpdateRemotePlugins command to update the lazyload plugins
function s:update_remote_plugs() abort
    let save_rtp = &rtp
    let r_list = []
    for info in values(g:plugs)
        call add(r_list, info['dir'])
    endfor
    execute 'set rtp=' . join(r_list, ',')
    call remote#host#UpdateRemotePlugins()
    execute 'set rtp=' . save_rtp
endfunction
command! -nargs=0 UpdateRemotePlugins call <SID>update_remote_plugs()

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
    execute 'file ' . fnameescape(resolve(fname))
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
    if line('.') == line('$')
        keepjumps execute 'normal! ' . line('.') . 'zb'
        return
    endif
    normal! zz
    normal! L
    if line('.') == line('$')
        keepjumps execute 'normal! ' . line('.') . 'zb'
    endif
    keepjumps normal! ``
endfunction

nnoremap zZ <Cmd>call <SID>zz()<CR>
xnoremap zZ <Cmd>call <SID>zz()<CR>

augroup ShadowWindow
    autocmd!
    autocmd WinEnter * call shadowwin#enable()
augroup END
