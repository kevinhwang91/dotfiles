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
    Plug 'nvim-treesitter/nvim-treesitter', {'on': ['TSBufEnable', 'TSEnableAll',
                \ 'TSInstall', 'TSInstallInfo', 'TSInstallSync', 'TSModuleInfo', 'TSUpdate']}
    highlight default link TSPunctBracket NONE
    highlight default link TSVariable NONE
    highlight default link TSConstant NONE
    highlight default link TSKeyword Statement
    highlight default link TSInclude Statement
    highlight default link TSConstBuiltin cSpecial
    highlight default link TSParameter Parameter

    " lazy load for file type
    let s:ts_ft_set = ['go', 'java', 'rust', 'javascript', 'typescript']

    function LazyLoadTreeSitter(timer) abort
        if !get(g:, 'loaded_nvim_treesitter', 0)
            call plug#load('nvim-treesitter')
        endif

        augroup TSHighlight
            autocmd!
            autocmd CursorHold,CursorHoldI * call <SID>refresh_ts()
            execute 'autocmd FileType ' . join(s:ts_ft_set, ',') .
                        \ ' execute("TSBufEnable highlight")'
        augroup END

        for buf_nr in filter(range(1, bufnr('$')), 'bufexists(v:val) && bufloaded(v:val)')
            let ft = getbufvar(buf_nr, '&filetype')
            if index(s:ts_ft_set, ft) > -1
                execute 'TSBufEnable highlight'
            endif
        endfor
    endfunction

    function s:refresh_ts() abort
        if exists('b:ts_last_changedtick') &&
                    \ (b:ts_last_changedtick < 0 || b:ts_last_changedtick == b:changedtick)
            return
        endif
        let ft = &filetype
        if index(s:ts_ft_set, ft) >= 0
            execute 'silent! TSBufDisable highlight'
            execute 'TSBufEnable highlight'
        else
            let b:ts_last_changedtick = -1
            return
        endif
        let b:ts_last_changedtick = b:changedtick
    endfunction

    augroup TSHighlight
        autocmd!
        execute 'autocmd FileType ' . join(s:ts_ft_set, ',') .
                    \ ' call timer_start(0, "LazyLoadTreeSitter")'
    augroup END
endif

" lazy load for python file type
Plug 'numirias/semshi', {'do': ':UpdateAllRemotePlugins', 'on': []}
function LazyLoadSemshi(timer) abort
    let g:semshi#mark_selected_nodes = 0
    let g:semshi#error_sign = 0
    highlight default link semshiSelf cSpecial
    highlight default link semshiBuiltin Structure
    highlight default link semshiAttribute Keyword
    highlight default link semshiGlobal Bold
    highlight default link semshiUnresolved Underlined
    highlight default link semshiFree NONE
    highlight default link semshiParameter Parameter
    highlight semshiParameterUnused cterm=underline ctermfg=71 gui=underline guifg=#50a14f
    highlight semshiImported cterm=italic ctermfg=173 gui=italic guifg=#d19a66
    highlight semshiFree cterm=italic gui=italic

    autocmd FileType python syntax match pythonOperator '\V=\|-\|+\|*\|@\|/\|%\|&\||\|^\|~\|<\|>\|!=' |
                \ syntax match pythonFunctionCall
                \ '\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\ze\%(\s*(\)'
    highlight default link pythonFunctionCall Function

    call plug#load('semshi')
    for buf_nr in filter(range(1, bufnr('$')), 'bufexists(v:val) && bufloaded(v:val)')
        if getbufvar(buf_nr, '&filetype') == 'python'
            execute 'Semshi enable'
        endif
    endfor
endfunction
autocmd FileType python ++once call timer_start(0, 'LazyLoadSemshi')

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
            \ 'checkinterval': 200,
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
