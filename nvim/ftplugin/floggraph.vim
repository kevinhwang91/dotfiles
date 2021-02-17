nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> U <Plug>(FlogUpdate)
nmap <buffer> o <Plug>(FlogVSplitCommitRight)
nmap <buffer> ]R <Plug>(FlogVNextRefRight)
nmap <buffer> [R <Plug>(FlogVPrevRefRight)
nnoremap <buffer><silent> <CR> <Cmd>belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-n> <Cmd>call flog#next_commit() <Bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-p> <Cmd>call flog#previous_commit() <Bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> ]r <Cmd>call flog#next_ref() <Bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> [r <Cmd>call flog#previous_ref() <Bar> belowright Flogsplitcommit<CR>
nnoremap <buffer> rl :Floggit reset <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> rh :Floggit reset --hard <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> gt :Floggit difftool -y <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
xnoremap <buffer> gt :Floggit difftool -y<Space>

function s:scroll(direction) abort
    let winnr = winnr('$')
    if winnr < 2
        if a:direction
            execute "normal! \<C-f>"
        else
            execute "normal! \<C-b>"
        endif
        return
    endif
    noautocmd wincmd p
    if a:direction
        execute "normal! \<C-d>"
    else
        execute "normal! \<C-u>"
    endif
    noautocmd wincmd p
endfunction

nnoremap <buffer><silent> <C-f> <Cmd>call <SID>scroll(1)<CR>
nnoremap <buffer><silent> <C-b> <Cmd>call <SID>scroll(0)<CR>
