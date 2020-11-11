Plug 'kevinhwang91/vim-one'
let g:one_termcolors = 0
let g:one_allow_italics = 1

augroup ColorTheme
    autocmd!
    autocmd ColorScheme * call s:color_scheme()
augroup end

function s:color_scheme() abort
    highlight! link TermCursor Cursor
    highlight MatchWord cterm=underline gui=underline
    if g:colors_name ==# 'one'
        highlight BqfPreviewBorder guifg=#50a14f ctermfg=71
        highlight semshiParameterUnused cterm=underline ctermfg=71 gui=underline guifg=#50a14f
        highlight semshiImported cterm=italic ctermfg=173 gui=italic guifg=#d19a66
        highlight CurrentWord cterm=bold ctermbg=238 gui=bold guibg=#314365
    endif
endfunction
