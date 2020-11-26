if has('nvim-0.5')
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost *
                    \ lua if not vim.b.visual_multi then
                    \ vim.highlight.on_yank({higroup='IncSearch', timeout=800})
                    \ end
    augroup END
endif

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
highlight default link LspCxxHlSymParameter Parameter
highlight default link LspCxxHlGroupMemberVariable Keyword
highlight default link LspCxxHlSymUnknown NONE
highlight default link LspCxxHlSymVariable NONE
