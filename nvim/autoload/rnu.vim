let s:delay = 50

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

function s:set_rnu() abort
    call s:set_win_rnu(v:true)
    highlight! link FoldColumn NONE
endfunction

function s:unset_rnu() abort
    call s:set_win_rnu(v:false)
    highlight! link FoldColumn Ignore
endfunction

let s:focus_lock = 1
function s:rnu_lost(timer) abort
    if s:focus_lock >= 0
        call s:unset_rnu()
    endif
    let s:focus_lock += 1
endfunction

function s:rnu_gained(timer) abort
    if s:focus_lock >= 0
        call s:set_rnu()
    endif
    let s:focus_lock += 1
endfunction

function! rnu#focuslost() abort
    let s:focus_lock -= 1
    call timer_start(s:delay, function('s:rnu_lost'))
endfunction

function! rnu#focusgained() abort
    let s:focus_lock -= 1
    call timer_start(s:delay, function('s:rnu_gained'))
endfunction

function! rnu#winenter() abort
    call s:set_rnu()
endfunction
