Plug 'pseewald/vim-anyfold', {'on': 'AnyFoldActivate'}
let g:anyfold_fold_display = 0
let g:anyfold_identify_comments = 0
let g:anyfold_motion = 0

augroup FoldLazyLoad
    autocmd!
    autocmd FileType vim,sh,zsh,python,yaml,xml,html,json,make,sql,tmux call <SID>load_anyfold()
    autocmd FileType javascript,typescript,css call <SID>load_lspfold()
    if has('nvim-0.5')
        autocmd FileType c,cpp,go,rust,java,lua call <SID>load_treesitter()
    endif
augroup END

function s:set_fold_opt() abort
    setlocal foldenable foldlevel=99
    setlocal foldtext=FoldText()
endfunction

function s:load_treesitter() abort
    let b:lazy_load_fold = str2nr(expand('<abuf>'))
    augroup FoldLazyLoad
        autocmd! BufEnter <buffer=abuf>
        autocmd BufEnter <buffer=abuf> call timer_start(2000, function('s:lazy_load_treesitter'))
    augroup END
endfunction

function s:lazy_load_treesitter(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        call s:set_fold_opt()
        setlocal foldmethod=expr
        setlocal foldexpr=nvim_treesitter#foldexpr()
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

function s:load_anyfold() abort
    let fsize = getfsize(expand('<afile>'))
    if fsize < 524288 && fsize > 0
        let b:lazy_load_fold = str2nr(expand('<abuf>'))
        augroup FoldLazyLoad
            autocmd! BufEnter <buffer=abuf>
            autocmd BufEnter <buffer=abuf> call timer_start(2000, function('s:lazy_load_anyfold'))
        augroup END
    endif
endfunction

function s:lazy_load_anyfold(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        call s:set_fold_opt()
        execute 'AnyFoldActivate'
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

function s:load_lspfold() abort
    let b:lazy_load_fold = str2nr(expand('<abuf>'))
    augroup FoldLazyLoad
        autocmd! BufEnter <buffer=abuf>
        autocmd BufEnter <buffer=abuf> call timer_start(2000,
                    \ function('s:lazy_load_lsp'), {'repeat': 10})
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

function s:lazy_load_lsp(timer) abort
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
command! -nargs=0 TreesitterFold call <SID>set_fold_opt() |
            \ setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()
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
