" airline is slow, lightline is hard to extend third plugin, I hate this
" bull-shit code of lightline configuration, help!!!!

" Plug 'vim-airline/vim-airline'
" Plug 'ryanoasis/vim-devicons'

Plug 'itchyny/lightline.vim', {'on': []}
Plug 'ryanoasis/vim-devicons', {'on': []}
autocmd VimEnter * ++once call timer_start(0, function('s:lazy_load_stl'))
augroup LightlineExtend
    autocmd!
    autocmd User CocDiagnosticChange call lightline#update()
    autocmd CursorHold,BufWritePost * call s:whitespace_refresh()
augroup END

function s:lazy_load_stl(timer) abort
    let g:webdevicons_enable_nerdtree = 0
    call plug#load('vim-devicons')
    call plug#load('lightline.vim')
    call lightline#init()
    call lightline#colorscheme()
    let hl_normal = lightline#palette().normal
    let hl_normal_l0 = hl_normal.left[0]
    let hl_normal_m = hl_normal.middle[0]
    let hl_visual_l0 = lightline#palette().visual.left[0]
    execute printf('highlight LightlineModified_1 guifg=%s guibg=%s ctermfg=%s ctermbg=%s',
                \ hl_visual_l0[1], hl_normal_m[1], hl_visual_l0[3], hl_normal_m[3])
    execute printf('highlight LightlineModified_2 guifg=%s guibg=%s ctermfg=%s ctermbg=%s',
                \ hl_normal_m[0], hl_normal_m[1], hl_normal_m[2], hl_normal_m[3])
    execute printf('highlight LightlineReadOnly guifg=%s guibg=%s ctermfg=%s ctermbg=%s',
                \ hl_normal_l0[1], hl_normal_m[1], hl_normal_l0[3], hl_normal_m[3])
    highlight clear StatusLineNC
    call lightline#update()
endfunction

let g:lightline = {
            \   'colorscheme': 'one',
            \   'separator': {'left': '', 'right': ''},
            \   'subseparator': {'left': '', 'right': ''},
            \   'active': {
            \       'left': [
            \           ['mode', 'paste'], ['branch', 'hunk', 'quickfix'], ['filename', 'readonly'],
            \           ['cocstatus'],
            \       ],
            \       'right': [
            \           ['whitespace', 'error', 'warning', 'lineinfo'],
            \           ['fileencoding', 'fileformat'], ['filetype'],
            \       ],
            \   },
            \   'inactive': {
            \       'left': [ ['quickfix', 'ifilename', 'ireadonly'] ],
            \       'right':[ ['lineinfo'], ['fileencoding', 'fileformat'], ['filetype'] ]
            \   },
            \   'tabline': {'left': [ ['tabs'] ], 'right':[]},
            \   'component': {
            \       'empty': ' ',
            \       'filename': '%#LightlineModified#%{LightlineFileName()}%m' .
            \           '%#LightlineLeft_active_2#',
            \       'ifilename': '%{LightlineInactiveFileName()}',
            \       'readonly': '%#LightlineReadonly#%{LightlineReadOnly()}' .
            \           '%#LightlineLeft_active_2#%<',
            \       'ireadonly': '%{LightlineReadOnly()}%<',
            \       'lineinfo': '☰ %3l/%-3L %3v'
            \   },
            \   'component_expand': {
            \       'error': 'LightlineCocErrors',
            \       'warning': 'LightlineCocWarnings',
            \       'whitespace': 'LightlineWhiteSpace',
            \   },
            \   'component_type': {
            \       'branch': 'raw',
            \       'hunk': 'raw',
            \       'quickfix': 'raw',
            \       'readonly': 'raw',
            \       'fileencoding': 'raw',
            \       'fileformat': 'raw',
            \       'error': 'error',
            \       'warning': 'warning',
            \       'whitespace': 'warning',
            \   },
            \   'component_function': {
            \       'filetype': 'LightlineFiletype',
            \       'fileencoding': 'LightlineFileencoding',
            \       'fileformat': 'LightlineFileformat',
            \       'branch': 'LightlineFugitive',
            \       'hunk': 'LightlineGitGutter',
            \       'quickfix': 'LightlineQuickfix',
            \       'cocstatus': 'LightlineCocStatus'
            \   },
            \   'mode_map': {'n' : 'N', 'i' : 'I','R' : 'R', 'v' : 'V', 'V' : 'VL', "\<C-v>": 'VB',
            \               'c' : 'C', 's' : 'S','S' : 'SL', "\<C-s>": 'SB', 't': 'T'},
            \ }

function! LightlineReadOnly() abort
    if &readonly
        return filereadable(expand('%')) ? '' : ''
    endif
    return ''
endfunction

function! LightlineFileName() abort
    if &modified
        highlight link LightlineModified LightlineModified_1
    else
        highlight link LightlineModified LightlineModified_2
    endif
    if !exists('b:lightline_fugitive_name')
        let b:lightline_fugitive_name = ''
        if bufname('%') =~? '^fugitive:' && exists('*FugitiveReal')
            let b:lightline_fugitive_name = FugitiveReal(bufname('%'))
        endif
    endif

    if !empty(b:lightline_fugitive_name)
        let filename  = fnamemodify(b:lightline_fugitive_name, ':t') . '  '
    elseif empty(expand('%')) && empty(&buftype)
        let filename = '[No Name]'
    elseif &buftype == 'quickfix'
        let filename = get(w:, 'quickfix_title')
    elseif bufname('%') == '__CtrlSF__'
        let filename = pathshorten(ctrlsf#utils#SectionC())
    elseif bufname('%') == '__CtrlSFPreview__'
        let filename = ctrlsf#utils#PreviewSectionC()
    else
        let filename = expand('%:t')
    endif

    return filename
endfunction

function! LightlineInactiveFileName() abort
    if &buftype == 'quickfix'
        let filename = get(w:, 'quickfix_title')
    elseif bufname('%') == '__CtrlSF__'
        let filename = ctrlsf#utils#SectionC()
    elseif bufname('%') == '__CtrlSFPreview__'
        let filename = ctrlsf#utils#PreviewSectionC()
    else
        let filename = pathshorten(expand("%:~"))
    endif

    return filename
endfunction

function! LightlineFugitive() abort
    if empty(expand('%')) || !exists('*FugitiveHead') || !exists('*FugitiveExtractGitDir')
                \ || !exists('*FugitiveParse') || winwidth(0) < 90
                \ || bufname('%') == '__CtrlSF__' || bufname('%') == '__CtrlSFPreview__'
        return ''
    endif

    if !exists('b:lightline_git_tick') || reltimefloat(reltime(b:lightline_git_tick)) > 0.5
        if empty(get(b:, 'git_dir', ''))
            let b:git_dir=FugitiveExtractGitDir(resolve(expand('%')))
        endif
        let branch = FugitiveHead()
        let info = FugitiveParse()[0]
        if !empty(info)
            let commit = split(info, ':')[0]
            let branch .= '(' .  strpart(commit, 0, 6) . ')'
        endif
        let b:last_git_branch = branch
        let b:lightline_git_tick = reltime()
    else
        let branch = exists('b:last_git_branch') ? b:last_git_branch : ''
    endif
    return empty(branch) ? '' : printf('  %s ', branch)
endfunction

function! LightlineGitGutter() abort
    if !exists('*GitGutterGetHunkSummary') || &readonly || ! &modifiable || winwidth(0) < 80
                \ || bufname('%') == '__CtrlSF__' || bufname('%') == '__CtrlSFPreview__'
        return ''
    else
        let symbols_hl =  ['+', '~', '-']
        let cnt = GitGutterGetHunkSummary()
        if cnt == [0, 0, 0]
            return ''
        else
            let list = []
            for i in [0, 1, 2]
                call add(list, symbols_hl[i] . cnt[i])
            endfor
            return printf(' %s ', join(list))
        endif
    endif
endfunction

function! LightlineQuickfix() abort
    if &buftype != 'quickfix'
        return ''
    endif
    let type = getwininfo(win_getid())[0].loclist ? 'loc' : 'qf'
    let what = {'nr': 0, 'size': 0}
    let info = type == 'loc' ? getloclist(0, what) : getqflist(what)
    let nr = type == 'loc' ? getloclist(0, {'nr': '$'}).nr : getqflist({'nr': '$'}).nr
    let prefix = type == 'loc' ? 'Location' : ' Quickfix'
    return printf(' %s (%d/%d) [%d] ', prefix, info.nr, nr, info.size)
endfunction

function! LightlineCocStatus() abort
    return trim(get(g:, 'coc_status', ''))
endfunction

function! s:coc_diagnostic(kind, sign) abort
    let info = get(b:, 'coc_diagnostic_info', 0)
    if empty(info) || get(info, a:kind, 0) == 0
        return ''
    endif
    return printf('%s%d', a:sign, info[a:kind])
endfunction

function! LightlineCocErrors() abort
    return s:coc_diagnostic('error', 'E')
endfunction

function! LightlineCocWarnings() abort
    return s:coc_diagnostic('warning', 'W')
endfunction

function! LightlineFiletype()
    if bufname('%') == '__CtrlSF__'
        return ctrlsf#utils#SectionX()
    endif

    if !exists('*WebDevIconsGetFileTypeSymbol')
        return &filetype
    else
        let ft_symbol = WebDevIconsGetFileTypeSymbol()
        if winwidth(0) < 70
            return ft_symbol
        endif
        return printf(' %s %s ', &filetype, ft_symbol)
    endif
endfunction

function! LightlineFileencoding() abort
    if winwidth(0) < 60 || bufname('%') == '__CtrlSF__' || bufname('%') == '__CtrlSFPreview__'
        return ''
    endif
    return printf(' %s ', &fenc !=# '' ? &fenc : &enc)
endfunction

function! LightlineFileformat() abort
    if bufname('%') == '__CtrlSF__' || bufname('%') == '__CtrlSFPreview__'
        return ''
    endif

    if !exists('*WebDevIconsGetFileFormatSymbol')
        return printf(' %s ', &fileformat)
    else
        return printf(' %s  ', WebDevIconsGetFileFormatSymbol())
    endif
endfunction

function! LightlineWhiteSpace() abort
    if &readonly || !&modifiable || line('$') > 20000 || bufname('%') == '__CtrlSF__'
        return ''
    endif

    let list = []

    let trailing = search('\s$', 'nw')
    if trailing != 0
        call add(list, printf('%sT', trailing))
    endif

    let mixed = search('\v(^\t+ +)|(^ +\t+)', 'nw')
    if mixed != 0
        call add(list, printf('%sM', mixed))
    endif

    let inconsistent = s:check_inconsistent_indentation()
    if !empty(inconsistent)
        call add(list, printf('[%s]I', inconsistent))
    endif

    return join(list)
endfunction

function s:check_inconsistent_indentation()
    let indent_tabs = search('\v(^\t+)', 'nw')
    let indent_spc  = search('\v(^ +)', 'nw')
    if indent_tabs > 0 && indent_spc > 0
        if indent_spc < indent_tabs
            return printf("%d:%d", indent_spc, indent_tabs)
        else
            return printf("%d:%d", indent_tabs, indent_spc)
        endif
    else
        return ''
    endif
endfunction

function s:whitespace_refresh()
    if get(b:, 'whitespace_changedtick', 0) == b:changedtick
        return
    endif
    unlet! b:whitespace_changedtick
    call lightline#update()
    let b:whitespace_changedtick = b:changedtick
endfunction
