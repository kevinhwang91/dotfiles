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

    let cur_winid = nvim_get_current_win()
    for winid in nvim_tabpage_list_wins(0)
        if cur_winid == winid && nvim_win_get_option(cur_winid, 'number')
            if &buftype == 'quickfix'
                continue
            endif
            call nvim_win_set_option(cur_winid, 'relativenumber', a:val)
        elseif empty(nvim_win_get_config(winid)['relative']) &&
                    \ nvim_win_get_option(winid, 'number')
            call nvim_win_set_option(winid, 'relativenumber', v:false)
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
nnoremap <silent> qe <Cmd>CleanEmptyBuf<CR>

function s:v_set_search(cmdtype)
    let temp = @s
    norm! gv"sy
    let @/ = substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
endfunction

xnoremap * :call <SID>v_set_search('/')<CR>/<C-r>=@/<CR><CR>
xnoremap # :call <SID>v_set_search('?')<CR>?<C-r>=@/<CR><CR>

" augroup ShadowWindow
"     autocmd!
"     autocmd WinEnter * call timer_start(50, {-> call(function('s:toggle_shadow'), [])})
" augroup END

function s:shadow_existed() abort
    return exists('s:shadow_winid') && nvim_win_is_valid(s:shadow_winid)
endfunction

function s:create_shadow() abort
    if s:shadow_existed()
        return
    endif

    let opts = {
                \ 'relative': 'editor',
                \ 'focusable': 0,
                \ 'width': &columns,
                \ 'height': &lines,
                \ 'row': 0,
                \ 'col': 0,
                \ 'style': 'minimal',
                \ }

    let shadow_bufnr = nvim_create_buf(0, 1)
    call nvim_buf_set_option(shadow_bufnr, 'bufhidden', 'wipe')
    let s:shadow_winid = nvim_open_win(shadow_bufnr, 0, opts)
    call nvim_win_set_option(s:shadow_winid, 'winhighlight', 'Normal:Normal')
    call nvim_win_set_option(s:shadow_winid, 'winblend', 70)
    autocmd ShadowWindow VimResized * call <SID>reszie_shadow()
endfunction

function s:close_shadow() abort
    if !s:shadow_existed()
        return
    endif
    autocmd! ShadowWindow VimResized
    call nvim_win_close(s:shadow_winid, 0)
endfunction

function s:reszie_shadow() abort
    if !s:shadow_existed()
        return
    endif
    call nvim_win_set_config(s:shadow_winid, {'width': &columns, 'height': &lines})
endfunction

function! s:toggle_shadow() abort
    if s:shadow_existed() && s:shadow_winid == win_getid()
        close
        return
    endif
    if empty(nvim_win_get_config(0)['relative'])
        call s:close_shadow()
    else
        call s:create_shadow()
    endif
endfunction
