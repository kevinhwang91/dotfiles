Plug 'kevinhwang91/vim-one'
let g:one_termcolors = 0
let g:one_allow_italics = 1

augroup ColorTheme
    autocmd!
    autocmd ColorScheme * call s:color_scheme()
augroup end

function s:color_scheme() abort
    highlight! link TermCursor Cursor
    if g:colors_name ==# 'one'
        highlight CurrentWord cterm=bold ctermbg=238 gui=bold guibg=#314365
    endif
endfunction
