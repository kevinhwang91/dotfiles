nunmap <buffer> d
nunmap <buffer> D
nunmap <buffer> o
nunmap <buffer> O
nnoremap <buffer><silent><nowait> s <Cmd>call b:__gitmessenger_popup.opts.mappings['d'][0]()<CR>
nnoremap <buffer><silent><nowait> S <Cmd>call b:__gitmessenger_popup.opts.mappings['D'][0]()<CR>
nnoremap <buffer><silent><nowait> < <Cmd>call b:__gitmessenger_popup.opts.mappings['o'][0]()<CR>
nnoremap <buffer><silent><nowait> > <Cmd>call b:__gitmessenger_popup.opts.mappings['O'][0]()<CR>

function s:get_commit() abort
    let commit = ''
    for l in nvim_buf_get_lines(0, 0, -1, v:false)
        let match_group = matchlist(l, '\m^\s\+Commit:\s\+\(\w\+\)')
        if !empty(match_group)
            let commit = match_group[1]
            break
        endif
    endfor
    return commit[:6]
endfunction

nnoremap <buffer><silent> y<C-g> <Cmd>call setreg(v:register, <SID>get_commit())<CR>
nnoremap <buffer> <Leader>gb :GBrowse <C-r>=<SID>get_commit()<CR><CR>
nnoremap <buffer> <Leader>gl :Flog -- <C-r>=<SID>get_commit()<CR><CR>
