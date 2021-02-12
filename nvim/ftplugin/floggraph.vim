nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> U <Plug>(FlogUpdate)
nmap <buffer> o <Plug>(FlogVSplitCommitRight)
nmap <buffer> ]R <Plug>(FlogVNextRefRight)
nmap <buffer> [R <Plug>(FlogVPrevRefRight)
nnoremap <buffer><silent> <CR> <Cmd>belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-n> <Cmd>call flog#next_commit() <bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> <C-p> <Cmd>call flog#previous_commit() <bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> ]r <Cmd>call flog#next_ref() <bar> belowright Flogsplitcommit<CR>
nnoremap <buffer><silent> [r <Cmd>call flog#previous_ref() <bar> belowright Flogsplitcommit<CR>
nnoremap <buffer> rl :Floggit reset <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> rh :Floggit reset --hard <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
