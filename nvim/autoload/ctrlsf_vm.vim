function! ctrlsf_vm#init() abort
    setlocal wrap
    augroup CtrlSFMainWindow
        autocmd!
        autocmd BufWinEnter <buffer> call s:ctrlsf_enter()
        autocmd BufWinLeave <buffer> call s:ctrlsf_leave()
        doautocmd BufWinEnter <buffer>
    augroup end

    let b:visual_multi_map = {'n': 'VM-Find-Under', 'N': 'VM-Find-Prev',
                \'q': 'VM-Skip-Region', 'Q': 'VM-Remove-Region',
                \']': 'VM-Goto-Next', '[': 'VM-Goto-Prev'}
    nnoremap <buffer><expr><silent> <leader>1
                \ execute('let g:ctrlsf_auto_preview = !g:ctrlsf_auto_preview')
    nnoremap <buffer><silent> <C-n> <Cmd>call <SID>vm_match_pat()<CR>

    nnoremap <buffer><silent> [f <Cmd>call <SID>nav_file(0)<CR>
    nnoremap <buffer><silent> ]f <Cmd>call <SID>nav_file(1)<CR>
endfunction

function! Wrap_VM_Start() abort
    let b:vm_set_statusline = get(g:, 'VM_set_statusline', 2)
    let g:VM_set_statusline = 0
    for [key, val] in items(b:visual_multi_map)
        execute 'nmap <buffer><nowait><silent> '. key .
                    \' <Cmd>call <SID>wrap_vm_map("'. val . '")<CR>'
    endfor
    nmap <buffer><nowait><silent> <C-n> n
endfunction

function! Wrap_VM_Exit() abort
    let g:VM_set_statusline = b:vm_set_statusline
    for key in keys(b:visual_multi_map)
        execute 'nunmap <buffer> ' . key
    endfor
    nnoremap <buffer><silent> <C-n> <Cmd>call <SID>vm_match_pat()<CR>
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
    execute 'VMSearch! ' . ctrlsf_pat
endfunction

function s:wrap_vm_map(action) abort
    let preview = get(g:, 'ctrlsf_auto_preview', 0)
    if preview
        let b:VM_skip_reset_once_on_bufleave = 1
    endif
    execute 'normal ' . v:count1 . "\<Plug>(" . a:action . ')'
    if preview
        call ctrlsf#JumpTo('preview')
    endif
endfunction
