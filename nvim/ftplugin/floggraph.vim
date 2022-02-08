setl lcs-=trail:•
set ve=all
augroup Flog
    au! * <buffer>
    au BufEnter <buffer> set ve=all
    au BufLeave <buffer> set ve=
augroup END

nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> U <Plug>(FlogUpdate)
nmap <buffer> o <Plug>(FlogVSplitCommitRight)
nmap <buffer> ]R <Plug>(FlogVNextRefRight)
nmap <buffer> [R <Plug>(FlogVPrevRefRight)
nnoremap <buffer><silent> <CR> <Cmd>bel Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-n> <Cmd>call flog#next_commit()<Bar>belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-p> <Cmd>call flog#previous_commit()<Bar>belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> ]r <Cmd>call flog#next_ref()<Bar>belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> [r <Cmd>call flog#previous_ref()<Bar>belowright Flogsplitcommit<CR>
nnoremap <buffer> rl :Floggit reset <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> rh :Floggit reset --hard <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> <Leader>gt :Floggit difftool -y <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
xnoremap <buffer> <Leader>gt :Floggit difftool -y<Space>
nnoremap <buffer> <Leader>gs :Flogsetargs -- <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> <Leader>gp :Flogsetargs -raw-args=--first-parent --
            \ <C-r>=flog#get_commit_at_line().short_commit_hash<CR><CR>
nnoremap <buffer> <Leader>gr :Flogsetargs -raw-args=
nnoremap <buffer> <Leader>gj :Flogjump<Space>
nnoremap <buffer> <Leader>gb :GBrowse <C-r>=flog#get_commit_at_line().short_commit_hash<CR><CR>
nmap <buffer> qd <Plug>(FlogCloseTmpWin)
nmap <buffer> sc <Plug>(FlogVDiffSplitLastCommitRight)

function s:scroll(direction) abort
    let winnr = winnr('$')
    if winnr < 2
        if a:direction
            exe "norm! \<C-f>"
        else
            exe "norm! \<C-b>"
        endif
        return
    endif
    noa winc p
    if a:direction
        exe "norm! \<C-d>"
    else
        exe "norm! \<C-u>"
    endif
    noa winc p
endfunction

nnoremap <buffer><silent> <C-f> <Cmd>call <SID>scroll(1)<CR>
nnoremap <buffer><silent> <C-b> <Cmd>call <SID>scroll(0)<CR>
