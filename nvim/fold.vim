Plug 'pseewald/vim-anyfold', {'on': 'AnyFoldActivate'}
let g:anyfold_fold_display = 0
let g:anyfold_identify_comments = 0
let g:anyfold_motion = 0

augroup FoldLazyLoad
    autocmd!
    " autocmd FileType vim,sh,zsh,python,c,cpp,css,yaml,java,xml,html,go,json,lua,make,sql,tmux,
    " \javascript,typescript
    " \ call <SID>load_anyfold(expand('<afile>'), expand('<abuf>'))

    autocmd FileType vim,sh,zsh,python,c,cpp,yaml,xml,html,json,lua,make,sql,tmux,rust
                \ call <SID>load_anyfold(expand('<afile>'), str2nr(expand('<abuf>')))
    autocmd FileType go,rust,java,javascript,typescript,css
                \ call <SID>load_lspfold(str2nr(expand('<abuf>')))
augroup END

function s:set_fold_opt() abort
    setlocal foldenable
    setlocal foldtext=FoldText()
endfunction

function s:load_anyfold(afile, bufnr) abort
    let fsize = getfsize(a:afile)
    if fsize < 524288 && fsize > 0
        let b:lazy_load_fold = a:bufnr
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . a:bufnr . '>'
            execute 'autocmd BufEnter <buffer=' . a:bufnr .
                        \ '> call timer_start(2000, "LazyLoadAnyFold")'
        augroup END
        call s:set_fold_opt()
    endif
endfunction

function LazyLoadAnyFold(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        execute 'AnyFoldActivate'
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

function s:load_lspfold(bufnr) abort
    let b:lazy_load_fold = a:bufnr
    augroup FoldLazyLoad
        execute 'autocmd! BufEnter <buffer=' . a:bufnr . '>'
        execute 'autocmd BufEnter <buffer=' . a:bufnr .
                    \ '> call timer_start(2000, "LazyLoadLspFold", {"repeat": 10})'
    augroup END
endfunction

function s:handle_callback(err, res) abort
    if a:res
        call s:set_fold_opt()
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

function LazyLoadLspFold(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        silent! let has_folding_range = CocHasProvider('foldingRange')
        if exists('has_folding_range') && has_folding_range
            call CocActionAsync('fold', '', function('s:handle_callback'))
        endif
    else
        call timer_stop(a:timer)
    endif
endfunction

command! -nargs=0 AnyFold call <SID>set_fold_opt() | AnyFoldActivate
command! -nargs=0 LspFold execute 'setlocal foldmethod=manual | normal! zE' |
            \ call CocActionAsync('fold', '', function('s:handle_callback'))

function! FoldText() abort
    let fs = v:foldstart
    while getline(fs) !~ '\w'
        let fs = nextnonblank(fs + 1)
    endwhile

    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif

    if &number
        let num_wid = 2 + float2nr(log10(line('$')))
        if num_wid < &numberwidth
            let num_wid = &numberwidth
        endif
    else
        if &relativenumber
            let num_wid = &numberwidth
        else
            let num_wid = 0
        endif
    endif

    " TODO how to calculate the signcolumn width? (per width with 2 chars)
    let width = winwidth(0) - &foldcolumn - num_wid  - 2 * 1
    let fold_size_str = ' ' .string(1 + v:foldend - v:foldstart) . ' lines '
    let fold_level_str = repeat(' + ', v:foldlevel)
    let spaces = repeat(' ', width - strwidth(fold_size_str . line . fold_level_str))
    return line . spaces . fold_size_str . fold_level_str
endfunction
