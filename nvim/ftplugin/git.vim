setlocal foldmethod=expr
setlocal foldexpr=DiffFold()
setlocal foldcolumn=2
setlocal signcolumn=no

function! DiffFold()
    let line = getline(v:lnum)
    if line =~# '^\(diff\|index\)' " file
        return '>1'
    elseif line =~# '^--- .*$'
        return '>1'
    elseif line =~# '^==== .*$'
        return '>1'
    elseif line =~# '^@@' " hunk
        return '>2'
    elseif line =~# '^\*\*\* \d\+,\d\+ \*\*\*\*$' " context: file1
        return '>2'
    elseif line =~# '^--- \d\+,\d\+ ----$' " context: file2
        return '>2'
    else
        return '='
    endif
endfunction
