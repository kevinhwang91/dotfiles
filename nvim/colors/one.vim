if v:vim_did_enter
    hi clear
    syntax reset
endif
let g:colors_name = 'one'

hi Normal guifg=#abb2bf ctermfg=249 guibg=#202326 ctermbg=16
hi Bold gui=bold cterm=bold
hi ColorColumn guibg=#282c34 ctermbg=236
hi Conceal guifg=#4b5263 ctermfg=239 guibg=NONE ctermbg=NONE
hi Cursor guibg=#528bff ctermbg=69
hi CursorColumn guibg=#282c34 ctermbg=236
hi CursorLine guibg=#282c34 ctermbg=236 gui=none cterm=none
hi Directory guifg=#61afef ctermfg=75
hi ErrorMsg guifg=#e06c75 ctermfg=168 guibg=NONE ctermbg=NONE gui=none cterm=none
hi VertSplit guifg=#3e4452 ctermfg=238 gui=none cterm=none
hi Folded guifg=#202326 ctermfg=16 guibg=#5c6370 ctermbg=241 gui=none cterm=none
hi FoldColumn guifg=#4b5263 ctermfg=239 guibg=#202326 ctermbg=16
hi IncSearch guifg=#d19a66 ctermfg=173
hi LineNr guifg=#4b5263 ctermfg=239
hi CursorLineNr guifg=#abb2bf ctermfg=249 guibg=#282c34 ctermbg=236 gui=none cterm=none
hi MatchParen guifg=#e06c75 ctermfg=168 guibg=NONE ctermbg=NONE gui=underline,bold cterm=underline,bold
hi Italic gui=italic cterm=italic
hi ModeMsg guifg=#abb2bf ctermfg=249
hi MoreMsg guifg=#abb2bf ctermfg=249
hi NonText guifg=#5c6370 ctermfg=241 gui=none cterm=none
hi PMenu guibg=#333841 ctermbg=237
hi PMenuSel guibg=#4b5263 ctermbg=239
hi PMenuSbar guibg=#202326 ctermbg=16
hi PMenuThumb guibg=#abb2bf ctermbg=249
hi Question guifg=#61afef ctermfg=75
hi QuickFixLine guibg=#31435e ctermbg=238 gui=bold cterm=bold
hi Search guifg=#202326 ctermfg=16 guibg=#e5c07b ctermbg=180
hi SpecialKey guifg=#3e4452 ctermfg=238 gui=none cterm=none
hi StatusLine guifg=#abb2bf ctermfg=249 guibg=#30353f ctermbg=236 gui=none cterm=none
hi StatusLineNC guifg=#202326 ctermfg=16 guibg=#5c6370 ctermbg=241 gui=none cterm=none
hi TabLine guifg=#abb2bf ctermfg=249 guibg=#3e4452 ctermbg=238 gui=none cterm=none
hi TabLineFill guifg=#5c6370 ctermfg=241 guibg=#202326 ctermbg=16 gui=none cterm=none
hi TabLineSel guifg=#202326 ctermfg=16 guibg=#528bff ctermbg=69 gui=bold cterm=bold
hi Title guifg=#abb2bf ctermfg=249 gui=bold cterm=bold
hi Visual guibg=#3e4452 ctermbg=238
hi WarningMsg guifg=#e06c75 ctermfg=168
hi WildMenu guifg=#abb2bf ctermfg=249 guibg=#5c6370 ctermbg=241
hi SignColumn guibg=#202326 ctermbg=16
hi Special guifg=#61afef ctermfg=75
hi Comment guifg=#5c6370 ctermfg=241 gui=italic cterm=italic
hi Constant guifg=#98c379 ctermfg=114
hi Number guifg=#d19a66 ctermfg=173
hi Identifier guifg=#e06c75 ctermfg=168 gui=none cterm=none
hi Statement guifg=#c678dd ctermfg=176 gui=none cterm=none
hi Operator guifg=#528bff ctermfg=69 gui=none cterm=none
hi PreProc guifg=#e5c07b ctermfg=180
hi Type guifg=#e5c07b ctermfg=180 gui=none cterm=none
hi Special guifg=#61afef ctermfg=75
hi SpecialChar guifg=#56b6c2 ctermfg=73
hi Underlined guifg=NONE ctermfg=NONE guibg=NONE ctermbg=NONE gui=underline cterm=underline
hi Error guifg=#e06c75 ctermfg=168 guibg=NONE ctermbg=NONE gui=bold cterm=bold
hi Todo guifg=#c678dd ctermfg=176 guibg=NONE ctermbg=NONE gui=italic cterm=italic
hi StatusLineNormal guifg=#30353f ctermfg=236 guibg=#98c379 ctermbg=114 gui=bold cterm=bold
hi StatusLineInsert guifg=#30353f ctermfg=236 guibg=#61afef ctermbg=75 gui=bold cterm=bold
hi StatusLineReplace guifg=#30353f ctermfg=236 guibg=#e06c75 ctermbg=168 gui=bold cterm=bold
hi StatusLineVisual guifg=#30353f ctermfg=236 guibg=#c678dd ctermbg=176 gui=bold cterm=bold
hi StatusLineCommand guifg=#30353f ctermfg=236 guibg=#56b6c2 ctermbg=73 gui=bold cterm=bold
hi StatusLineBranch guifg=#56b6c2 ctermfg=73 guibg=#30353f ctermbg=236
hi StatusLineHunkAdd guifg=#98c379 ctermfg=114 guibg=#30353f ctermbg=236
hi StatusLineHunkChange guifg=#d19a66 ctermfg=173 guibg=#30353f ctermbg=236
hi StatusLineHunkRemove guifg=#e06c75 ctermfg=168 guibg=#30353f ctermbg=236
hi StatusLineFileName guifg=#abb2bf ctermfg=249 guibg=#30353f ctermbg=236
hi StatusLineFileModified guifg=#c678dd ctermfg=176 guibg=#30353f ctermbg=236
hi StatusLineFormat guifg=#528bff ctermfg=69 guibg=#30353f ctermbg=236 gui=bold cterm=bold
hi StatusLineError guifg=#be5046 ctermfg=130 guibg=#30353f ctermbg=236
hi StatusLineWarning guifg=#e5c07b ctermfg=180 guibg=#30353f ctermbg=236
hi Parameter guifg=#50a14f ctermfg=71
hi CurrentWord guibg=#31435e ctermbg=238 gui=bold cterm=bold
hi DiffAdd guifg=NONE ctermfg=NONE guibg=#0b4820 ctermbg=22 gui=none cterm=none
hi DiffChange guifg=NONE ctermfg=NONE guibg=#30353f ctermbg=236 gui=none cterm=none
hi DiffDelete guifg=NONE ctermfg=NONE guibg=#450a15 ctermbg=52 gui=none cterm=none
hi DiffText guifg=NONE ctermfg=NONE guibg=#263F78 ctermbg=237 gui=bold cterm=bold
hi htmlH1 guifg=#56b6c2 ctermfg=73 gui=bold cterm=bold
hi markdownBold guifg=#d19a66 ctermfg=173 gui=bold cterm=bold
hi markdownItalic guifg=#d19a66 ctermfg=173 gui=bold cterm=bold

" let s:dump = []
" function! <SID>X(group, fg, bg, attr)
"     let cmd = 'hi ' . a:group
"     if !empty(a:fg)
"         let cmd = cmd . ' guifg=' . a:fg[0] . ' ctermfg=' . a:fg[1]
"     endif
"     if !empty(a:bg)
"         let cmd = cmd . ' guibg=' .  a:bg[0] . ' ctermbg=' . a:bg[1]
"     endif
"     if a:attr != ''
"         let cmd = cmd . ' gui=' .   a:attr . ' cterm=' . a:attr
"     endif
"     call add(s:dump, cmd)
"     execute cmd
" endfun

" " color definition
" let s:none = ['NONE', 'NONE']
" let s:black_1 = ['#202326', '16']
" let s:black_2 = ['#282c34', '236']
" let s:red_1 = ['#e06c75', '168']
" let s:red_2 = ['#be5046', '130']
" let s:red_3 = ['#450a15', '52']
" let s:green_1 = ['#98c379', '114']
" let s:green_2 = ['#50a14f', '71']
" let s:green_3 = ['#0b4820', '22']
" let s:yellow_1 = ['#d19a66', '173']
" let s:yellow_2 = ['#e5c07b', '180']
" let s:blue_1 = ['#61afef', '75']
" let s:blue_2 = ['#528bff', '69']
" let s:blue_3 = ['#263F78', '237']
" let s:purple_1 = ['#c678dd', '176']
" let s:cyan_1 = ['#56b6c2', '73']
" let s:white_1 = ['#abb2bf', '249']

" let s:mono_1 = ['#5c6370', '241']
" let s:mono_2 = ['#4b5263', '239']
" let s:mono_3 = ['#3e4452', '238']
" let s:mono_4 = ['#333841', '237']
" let s:mono_5 = ['#31435e', '238']
" let s:mono_6 = ['#30353f', '236']

" editor color
" call <sid>X('Normal', s:white_1, s:black_1, '')
" call <sid>X('Bold', '', '', 'bold')
" call <sid>X('ColorColumn', '', s:black_2, '')
" call <sid>X('Conceal', s:mono_2, s:none, '')
" call <sid>X('Cursor', '', s:blue_2, '')
" call <sid>X('CursorColumn', '', s:black_2, '')
" call <sid>X('CursorLine', '', s:black_2, 'none')
" call <sid>X('Directory', s:blue_1, '', '')
" call <sid>X('ErrorMsg', s:red_1, s:none, 'none')
" call <sid>X('VertSplit', s:mono_3, '', 'none')
" call <sid>X('Folded', s:black_1, s:mono_1, 'none')
" call <sid>X('FoldColumn', s:mono_2, s:black_1, '')
" call <sid>X('IncSearch', s:yellow_1, '', '')
" call <sid>X('LineNr', s:mono_2, '', '')
" call <sid>X('CursorLineNr', s:white_1, s:black_2, 'none')
" call <sid>X('MatchParen', s:red_1, s:none, 'underline,bold')
" call <sid>X('Italic', '', '', 'italic')
" call <sid>X('ModeMsg', s:white_1, '', '')
" call <sid>X('MoreMsg', s:white_1, '', '')
" call <sid>X('NonText', s:mono_1, '', 'none')
" call <sid>X('PMenu', '', s:mono_4, '')
" call <sid>X('PMenuSel', '', s:mono_2, '')
" call <sid>X('PMenuSbar', '', s:black_1, '')
" call <sid>X('PMenuThumb', '', s:white_1, '')
" call <sid>X('Question', s:blue_1, '', '')
" call <sid>X('QuickFixLine', '', s:mono_5, 'bold')
" call <sid>X('Search', s:black_1, s:yellow_2, '')
" call <sid>X('SpecialKey', s:mono_3, '', 'none')
" call <sid>X('StatusLine', s:white_1, s:mono_6, 'none')
" call <sid>X('StatusLineNC', s:black_1, s:mono_1, 'none')
" call <sid>X('TabLine', s:white_1, s:mono_3, 'none')
" call <sid>X('TabLineFill', s:mono_1, s:black_1, 'none')
" call <sid>X('TabLineSel', s:black_1, s:blue_2, 'bold')
" call <sid>X('Title', s:white_1, '', 'bold')
" call <sid>X('Visual', '', s:mono_3, '')
" call <sid>X('WarningMsg', s:red_1, '', '')
" call <sid>X('WildMenu', s:white_1, s:mono_1, '')
" call <sid>X('SignColumn', '', s:black_1, '')
" call <sid>X('Special', s:blue_1, '', '')
hi link Whitespace SpecialKey

" syntax
" call <sid>X('Comment', s:mono_1, '', 'italic')
" call <sid>X('Constant', s:green_1, '', '')
" call <sid>X('Number', s:yellow_1, '', '')
" call <sid>X('Identifier', s:red_1, '', 'none')
" call <sid>X('Statement', s:purple_1, '', 'none')
" call <sid>X('Operator', s:blue_2, '', 'none')
" call <sid>X('PreProc', s:yellow_2, '', '')
" call <sid>X('Type', s:yellow_2, '', 'none')
" call <sid>X('Special', s:blue_1, '', '')
" call <sid>X('SpecialChar', s:cyan_1, '', '')
" call <sid>X('Underlined', s:none, s:none, 'underline')
" call <sid>X('Error', s:red_1, s:none, 'bold')
" call <sid>X('Todo', s:purple_1, s:none, 'italic')
hi link Define Statement
hi link Macro Statement
hi link Include Special
hi link Function Special
hi link Delimiter NONE
hi link Boolean Number
hi link Float Number
hi link Label Identifier

" statusline
" call <sid>X('StatusLineNormal', s:mono_6, s:green_1, 'bold')
" call <sid>X('StatusLineInsert', s:mono_6, s:blue_1, 'bold')
" call <sid>X('StatusLineReplace', s:mono_6, s:red_1, 'bold')
" call <sid>X('StatusLineVisual', s:mono_6, s:purple_1, 'bold')
" call <sid>X('StatusLineCommand', s:mono_6, s:cyan_1, 'bold')
" call <sid>X('StatusLineBranch', s:cyan_1, s:mono_6, '')
" call <sid>X('StatusLineHunkAdd', s:green_1, s:mono_6, '')
" call <sid>X('StatusLineHunkChange', s:yellow_1, s:mono_6, '')
" call <sid>X('StatusLineHunkRemove', s:red_1, s:mono_6, '')
" call <sid>X('StatusLineFileName', s:white_1, s:mono_6, '')
" call <sid>X('StatusLineFileModified', s:purple_1, s:mono_6, '')
" call <sid>X('StatusLineFormat', s:blue_2, s:mono_6, 'bold')
" call <sid>X('StatusLineError', s:red_2, s:mono_6, '')
" call <sid>X('StatusLineWarning', s:yellow_2, s:mono_6, '')

" call <sid>X('Parameter', s:green_2, '', '')
" call <sid>X('CurrentWord', '', s:mono_5, 'bold')

" diff
" call <sid>X('DiffAdd', s:none, s:green_3, 'none')
" call <sid>X('DiffChange', s:none, s:mono_6, 'none')
" call <sid>X('DiffDelete', s:none, s:red_3, 'none')
" call <sid>X('DiffText', s:none, s:blue_3, 'bold')

" help
hi link helpCommand Type
hi link helpExample Type
hi link helpHeader Title
hi link helpSectionDelim NonText

" asciidoc
hi link asciidocListingBlock NonText

" git related plugins
hi link DiffAdded DiffAdd
hi link DiffNewFile DiffAdd
hi link DiffFile DiffDelete
hi link DiffRemoved DiffDelete
hi link DiffLine DiffText

" html
" call <sid>X('htmlH1', s:cyan_1, '', 'bold')

" markdown
" call <sid>X('markdownBold', s:yellow_1, '', 'bold')
" call <sid>X('markdownItalic', s:yellow_1, '', 'bold')
hi link markdownUrl NonText
hi link markdownCode Constant
hi link markdownCodeDelimiter Constant
hi link markdownCodeBlock Identifier
hi link markdownHeadingDelimiter SpecialChar
hi link markdownListMarker Identifier

" vim
hi link vimCommentTitle NonText
hi link vimHighlight Function
hi link vimFunction Function
hi link vimFuncName Keyword
hi link vimHighlight Function
hi link vimUserFunc Function
hi link vimNotation SpecialChar
hi link vimFuncSID SpecialChar

" xml
hi link xmlTag Identifier
hi link xmlTagName Identifier

" zsh
hi link zshCommands Keyword
hi link zshDeref Identifier
hi link zshShortDeref Identifier
hi link zshFunction Function
hi link zshSubst Identifier
hi link zshSubstDelim NonText
hi link zshVariableDef Number

" man
hi link manTitle SpecialChar
hi link manFooter NonText

" call writefile(s:dump, '/tmp/dump_nvim_color.vim')
set background=dark
