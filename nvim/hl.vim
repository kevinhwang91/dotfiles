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

    augroup TSHighlight
        autocmd!
        autocmd CursorHold,CursorHoldI * call <SID>refresh_ts()
        autocmd VimEnter * call <SID>enable_ts_hl()
    augroup END

    function s:refresh_ts() abort
        if exists('b:ts_last_changedtick') &&
                    \ (b:ts_last_changedtick < 0 || b:ts_last_changedtick == b:changedtick)
            return
        endif
        let ft = &filetype
        if index(g:ts_ft_set, ft) >= 0
            execute 'silent! TSBufDisable highlight'
            execute 'TSBufEnable highlight'
        else
            let b:ts_last_changedtick = -1
            return
        endif
        let b:ts_last_changedtick = b:changedtick
    endfunction

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

Plug 'TaDaa/vimade', {'on': 'VimadeEnable'}
let g:vimade = {
            \ 'enablesigns': 1,
            \ 'fadelevel': 0.6,
            \ 'fadepriority': 0,
            \ 'checkinterval': 220,
            \ 'basegroups': ['Folded', 'Search', 'SignColumn', 'LineNr',
            \       'CursorLineNr', 'DiffAdd', 'DiffChange', 'DiffDelete',
            \       'DiffText', 'FoldColumn', 'Whitespace']
            \ }

augroup FadeExceptFloating
    autocmd!
    autocmd WinEnter,BufWinEnter * call <SID>fade_except_floating()
augroup END

function s:toggle_vimade(enable) abort
    let cur_win = nvim_get_current_win()
    noautocmd wincmd p
    let last_win = nvim_get_current_win()
    noautocmd wincmd p
    if a:enable
        execute 'VimadeEnable'
    else
        execute 'VimadeDisable'
    endif
    noautocmd call nvim_set_current_win(last_win)
    noautocmd call nvim_set_current_win(cur_win)
endfunction

function s:fade_except_floating() abort
    if empty(nvim_win_get_config(0)['relative'])
        if exists('g:vimade_running') && g:vimade_running != 0
            call s:toggle_vimade(0)
        endif
    else
        if !exists('g:vimade_running') || g:vimade_running == 0
            call s:toggle_vimade(1)
        endif
    endif
endfunction
