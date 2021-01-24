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
let g:Hexokinase_refreshEvents = ['BufRead', 'TextChanged', 'InsertLeave']
let g:Hexokinase_ftOptOutPatterns = {
            \ 'css': s:all_hexokinase_pat,
            \ 'scss': s:all_hexokinase_pat
            \ }
let g:Hexokinase_termDisabled = 1

" coc has loaded lazily
Plug 'jackguo380/vim-lsp-cxx-highlight', {'on': []}

function s:lazy_load_cxx_highlight(timer) abort
    highlight default link LspCxxHlSymParameter Parameter
    highlight default link LspCxxHlGroupMemberVariable Keyword
    highlight default link LspCxxHlSymUnknown NONE
    highlight default link LspCxxHlSymVariable NONE
    call plug#load('coc.nvim')
    call plug#load('vim-lsp-cxx-highlight')
    silent! augroup! CxxHighlightLazyLoad
endfunction

augroup CxxHighlightLazyLoad
    autocmd!
    autocmd FileType c,cpp,objc,objcpp,cc,cuda
                \ call timer_start(100, function('s:lazy_load_cxx_highlight'))
augroup end
