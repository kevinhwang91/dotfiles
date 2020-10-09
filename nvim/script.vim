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
autocmd VimEnter * ++once command! -nargs=0 UpdateRemotePlugins call <SID>update_remote_plugs()

" remove ansi color
command! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g

function s:set_win_rnu(val) abort
    if !empty(nvim_win_get_config(0)['relative'])
        return
    endif

    for win_hd in nvim_tabpage_list_wins(0)
        if nvim_get_current_win() == win_hd && nvim_win_get_option(win_hd, 'number')
            call nvim_win_set_option(win_hd, 'relativenumber', a:val)
        elseif empty(nvim_win_get_config(win_hd)['relative']) &&
                    \ nvim_win_get_option(win_hd, 'number')
            call nvim_win_set_option(win_hd, 'relativenumber', v:false)
        endif
    endfor
endfunction

augroup ToggleSigncolumn
    autocmd!
    autocmd FocusLost * call s:set_win_rnu(v:false) |
                \ highlight! link FoldColumn Ignore
    autocmd WinEnter,FocusGained * call s:set_win_rnu(v:true) |
                \ highlight! link FoldColumn NONE
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
    execute 'bw ' . join(bufnr_list)
endfunction

command! -nargs=0 CleanEmptyBuf call <SID>clean_empty_buf()
nnoremap <silent> qe :CleanEmptyBuf<CR>

function s:v_set_search(cmdtype)
    let temp = @s
    norm! gv"sy
    let @/ = substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
endfunction

xnoremap * :<C-u>call <SID>v_set_search('/')<CR>/<C-r>=@/<CR><CR>
xnoremap # :<C-u>call <SID>v_set_search('?')<CR>?<C-r>=@/<CR><CR>

" function WIP() abort
    " if v:hlsearch
        " set nolazyredraw
        " normal! n
        " set lazyredraw
        " return
    " endif
    " let hl_groups = ['CocHighlightText', 'CocHighlightRead', 'CocHighlightWrite']
    " let pos = []
    " let groups = getmatches()
    " for group in filter(groups, 'index(hl_groups, v:val.group) > -1')
        " for [key, val] in items(group)
            " if key =~ '^pos' && index(pos, val) < 0
                " call add(pos, val)
            " endif
        " endfor
    " endfor
    " call sort(pos, {p1, p2 -> p1[0] == p2[0] ? p1[1] - p2[1] : p1[0] - p2[0]})
    " let [_, p1, p2, _] = getpos('.')
    " let i = 0
    " let len = len(pos)
    " while i < len
        " let p = pos[i]
        " if p1 == p[0] && p2 >= p[1] && p2 < p[1] + p[2]
            " if i + 1 == len
                " let i = -1
            " endif
            " echo pos[i+1][0] pos[i+1][1]
            " call cursor(pos[i+1][0], pos[i+1][1])
            " return
        " endif
        " let i += 1
    " endwhile
" endfunction
