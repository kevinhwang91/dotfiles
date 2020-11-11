if has('nvim-0.5')
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost *
                    \ lua if not vim.b.visual_multi then
                    \ vim.highlight.on_yank({higroup='IncSearch', timeout=800})
                    \ end
    augroup END
endif

" experiment
if has('nvim-0.5')
    Plug 'nvim-treesitter/nvim-treesitter'
    highlight default link TSPunctBracket NONE
    highlight default link TSVariable NONE
    highlight default link TSConstant NONE
    highlight default link TSKeyword Statement
    highlight default link TSInclude Statement
    highlight default link TSConstBuiltin cSpecial
    highlight default link TSParameter Parameter
    highlight default link TSVariableBuiltin cSpecial

    let g:ts_ft_set = ['go', 'java', 'rust', 'javascript', 'typescript', 'lua']

    autocmd VimEnter * ++once call <SID>enable_ts_hl()

    function s:enable_ts_hl() abort
        lua require'nvim-treesitter.configs'.setup {
                    \   ensure_installed = vim.g.ts_ft_set,
                    \   highlight = {
                    \       enable = true,
                    \       disable = {'c'},
                    \   },
                    \ }
    endfunction
endif

Plug 'numirias/semshi', {'do': 'UpdateRemotePlugins'}
let g:semshi#mark_selected_nodes = 0
let g:semshi#error_sign = 0

highlight default link semshiFree Italic
highlight default link semshiSelf cSpecial
highlight default link semshiBuiltin Structure
highlight default link semshiAttribute Keyword
highlight default link semshiGlobal Bold
highlight default link semshiUnresolved Underlined
highlight default link semshiParameter Parameter

highlight default link pythonFunctionCall Function
autocmd FileType python syntax match pythonOperator '\V=\|-\|+\|*\|@\|/\|%\|&\||\|^\|~\|<\|>\|!='
autocmd FileType python syntax match pythonFunctionCall
            \ '\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\ze\%(\s*(\)'

augroup SemshiHighlight
    autocmd!
    autocmd BufWritePost *.py execute('Semshi highlight')
augroup END

Plug 'rrethy/vim-hexokinase', {'do': 'make hexokinase'}
let s:all_hexokinase_pat = ['full_hex', 'triple_hex', 'rgb', 'rgba', 'hsl', 'hsla', 'colour_names']
let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_refreshEvents = ['BufWrite', 'BufRead', 'TextChanged', 'TextChangedI']
let g:Hexokinase_ftOptOutPatterns = {
            \ 'ctrlsf': s:all_hexokinase_pat,
            \ 'css': s:all_hexokinase_pat,
            \ 'scss': s:all_hexokinase_pat
            \ }
let g:Hexokinase_termDisabled = 1

Plug 'jackguo380/vim-lsp-cxx-highlight', {'for': ['c', 'cpp']}
autocmd FileType c,cpp syntax match cOperator "\(<<\|>>\|[-+*/%&^|<>!=]\)=" |
            \ syntax match cOperator "<<\|>>\|&&\|||\|++\|--\|->" |
            \ syntax match cOperator "[!~*&%<>^|=+-]" |
            \ syntax match cOperator "&&\|||"
highlight default link LspCxxHlSymParameter Parameter
highlight default link LspCxxHlGroupMemberVariable Keyword
highlight default link LspCxxHlSymUnknown NONE
highlight default link LspCxxHlSymVariable NONE
