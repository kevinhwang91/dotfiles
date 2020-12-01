let s:shadow_winblend = 70

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
    call nvim_win_set_option(s:shadow_winid, 'winblend', s:shadow_winblend)
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

function s:detect_other_floatwins(cur_winid) abort
    if getwinvar(a:cur_winid, '&buftype') == 'nofile'
        return 1
    endif
    for winid in nvim_list_wins()
        if winid == a:cur_winid
            continue
        endif
        if !empty(nvim_win_get_config(winid).relative) && getwinvar(winid, '&buftype') != 'nofile'
            return 1
        endif
    endfor
    return 0
endfunction

function s:toggle_shadow(timer) abort
    let cur_winid = win_getid()
    if s:shadow_existed() && s:shadow_winid == cur_winid
        close
        return
    endif
    if empty(nvim_win_get_config(0).relative)
        call s:close_shadow()
    elseif !s:detect_other_floatwins(cur_winid)
        call s:create_shadow()
    endif
endfunction

function! shadowwin#disable() abort
    augroup ShadowWindow
        autocmd!
    augroup END
endfunction

function! shadowwin#enable() abort
    augroup ShadowWindow
        autocmd!
        autocmd WinEnter * call timer_start(50, function('s:toggle_shadow'))
    augroup END
    call s:toggle_shadow(0)
endfunction
