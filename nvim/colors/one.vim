if v:vim_did_enter
    highlight clear
    syntax reset
endif
let g:colors_name = 'one'

function! <SID>X(group, fg, bg, attr)
    let cmd = 'hi ' . a:group
    if !empty(a:fg)
        let cmd = cmd . ' guifg=' . a:fg[0] . ' ctermfg=' . a:fg[1]
    endif
    if !empty(a:bg)
        let cmd = cmd . ' guibg=' .  a:bg[0] . ' ctermbg=' . a:bg[1]
    endif
    if a:attr != ''
        let cmd = cmd . ' gui=' .   a:attr . ' cterm=' . a:attr
    endif
    execute cmd
endfun

" color definition
let s:none = ['NONE', 'NONE']
let s:black_1 = ['#202326', '16']
let s:black_2 = ['#282c34', '236']
let s:red_1 = ['#e06c75', '168']
let s:red_2 = ['#be5046', '130']
let s:green_1 = ['#98c379', '114']
let s:green_2 = ['#50a14f', '71']
let s:yellow_1 = ['#d19a66', '173']
let s:yellow_2 = ['#e5c07b', '180']
let s:blue_1 = ['#61afef', '75']
let s:blue_2 = ['#528bff', '69']
let s:purple_1 = ['#c678dd', '176']
let s:cyan_1 = ['#56b6c2', '73']
let s:white_1 = ['#abb2bf', '249']

let s:mono_1 = ['#5c6370', '241']
let s:mono_2 = ['#4b5263', '239']
let s:mono_3 = ['#3e4452', '238']
let s:mono_4 = ['#333841', '237']
let s:mono_5 = ['#314365', '238']
let s:mono_6 = ['#30353f', '236']

" editor color
call <sid>X('Normal', s:white_1, s:black_1, '')
call <sid>X('Bold', '', '', 'bold')
call <sid>X('ColorColumn', '', s:black_2, '')
call <sid>X('Conceal', s:mono_2, s:none, '')
call <sid>X('Cursor', '', s:blue_2, '')
call <sid>X('CursorColumn', '', s:black_2, '')
call <sid>X('CursorLine', '', s:black_2, 'none')
call <sid>X('Directory', s:blue_1, '', '')
call <sid>X('ErrorMsg', s:red_1, s:none, 'none')
call <sid>X('VertSplit', s:mono_3, '', 'none')
call <sid>X('Folded', s:black_1, s:mono_1, 'none')
call <sid>X('FoldColumn', s:mono_2, s:black_1, '')
call <sid>X('IncSearch', s:yellow_1, '', '')
call <sid>X('LineNr', s:mono_2, '', '')
call <sid>X('CursorLineNr', s:white_1, s:black_2, 'none')
call <sid>X('MatchParen', s:red_1, s:none, 'underline,bold')
call <sid>X('Italic', '', '', 'italic')
call <sid>X('ModeMsg', s:white_1, '', '')
call <sid>X('MoreMsg', s:white_1, '', '')
call <sid>X('NonText', s:mono_1, '', 'none')
call <sid>X('PMenu', '', s:mono_4, '')
call <sid>X('PMenuSel', '', s:mono_2, '')
call <sid>X('PMenuSbar', '', s:black_1, '')
call <sid>X('PMenuThumb', '', s:white_1, '')
call <sid>X('Question', s:blue_1, '', '')
call <sid>X('QuickFixLine', '', s:mono_5, 'bold')
call <sid>X('Search', s:black_1, s:yellow_2, '')
call <sid>X('SpecialKey', s:mono_3, '', 'none')
call <sid>X('StatusLine', s:white_1, s:mono_6, 'none')
call <sid>X('StatusLineNC', s:black_1, s:mono_1, 'none')
call <sid>X('TabLine', s:white_1, s:mono_2, 'none')
call <sid>X('TabLineFill', s:mono_1, s:black_1, 'none')
call <sid>X('TabLineSel', s:black_1, s:blue_2, 'bold')
call <sid>X('Title', s:white_1, '', 'bold')
call <sid>X('Visual', '', s:mono_3, '')
call <sid>X('WarningMsg', s:red_1, '', '')
call <sid>X('WildMenu', s:white_1, s:mono_1, '')
call <sid>X('SignColumn', '', s:black_1, '')
call <sid>X('Special', s:blue_1, '', '')
highlight link Whitespace SpecialKey

" syntax
call <sid>X('Comment', s:mono_1, '', 'italic')
call <sid>X('Constant', s:green_1, '', '')
call <sid>X('Number', s:yellow_1, '', '')
call <sid>X('Identifier', s:red_1, '', 'none')
call <sid>X('Statement', s:purple_1, '', 'none')
call <sid>X('Operator', s:blue_2, '', 'none')
call <sid>X('PreProc', s:yellow_2, '', '')
call <sid>X('Type', s:yellow_2, '', 'none')
call <sid>X('Special', s:blue_1, '', '')
call <sid>X('SpecialChar', s:cyan_1, '', '')
call <sid>X('Underlined', s:none, s:none, 'underline')
call <sid>X('Error', s:red_1, s:none, 'bold')
call <sid>X('Todo', s:purple_1, s:none, 'italic')
highlight link Define Statement
highlight link Macro Statement
highlight link Include Special
highlight link Function Special
highlight link Delimiter NONE
highlight link Boolean Number
highlight link Float Number
highlight link Label Identifier

" statusline
call <sid>X('StatusLineNormal', s:mono_6, s:green_1, 'bold')
call <sid>X('StatusLineInsert', s:mono_6, s:blue_1, 'bold')
call <sid>X('StatusLineReplace', s:mono_6, s:red_1, 'bold')
call <sid>X('StatusLineVisual', s:mono_6, s:purple_1, 'bold')
call <sid>X('StatusLineCommand', s:mono_6, s:cyan_1, 'bold')
call <sid>X('StatusLineBranch', s:cyan_1, s:mono_6, '')
call <sid>X('StatusLineHunkAdd', s:green_1, s:mono_6, '')
call <sid>X('StatusLineHunkChange', s:yellow_1, s:mono_6, '')
call <sid>X('StatusLineHunkRemove', s:red_1, s:mono_6, '')
call <sid>X('StatusLineFileName', s:white_1, s:mono_6, '')
call <sid>X('StatusLineFileModified', s:purple_1, s:mono_6, '')
call <sid>X('StatusLineFormat', s:blue_2, s:mono_6, 'bold')
call <sid>X('StatusLineError', s:red_2, s:mono_6, '')
call <sid>X('StatusLineWarning', s:yellow_2, s:mono_6, '')

call <sid>X('Parameter', s:green_2, '', '')
call <sid>X('CurrentWord', '', s:mono_5, 'bold')

" diff
call <sid>X('DiffAdd', s:green_1, s:mono_3, 'none')
call <sid>X('DiffChange', s:yellow_1, s:mono_3, 'none')
call <sid>X('DiffDelete', s:red_1, s:mono_3, 'none')
call <sid>X('DiffText', s:blue_1, s:mono_3, '')

" help
highlight link helpCommand Type
highlight link helpExample Type
highlight link helpHeader Title
highlight link helpSectionDelim NonText

" asciidoc
highlight link asciidocListingBlock NonText

" git related plugins
highlight link DiffAdded DiffAdd
highlight link DiffNewFile DiffAdd
highlight link DiffFile DiffDelete
highlight link DiffRemoved DiffDelete
highlight link DiffLine DiffText
highlight link GitGutterAdd Constant
highlight link GitGutterChange Type
highlight link GitGutterDelete Identifier
call <sid>X('GitGutterChangeDeleteLine', s:red_2, '', '')
highlight link GitGutterAddLineNr GitGutterAdd
highlight link GitGutterChangeLineNr GitGutterChange
highlight link GitGutterDeleteLineNr GitGutterDelete
highlight link GitGutterChangeDeleteLineNr GitGutterChangeDeleteLine

" html
call <sid>X('htmlH1', s:cyan_1, '', 'bold')

" markdown
call <sid>X('markdownBold', s:yellow_1, '', 'bold')
call <sid>X('markdownItalic', s:yellow_1, '', 'bold')
highlight link markdownUrl NonText
highlight link markdownCode Constant
highlight link markdownCodeDelimiter Constant
highlight link markdownCodeBlock Identifier
highlight link markdownHeadingDelimiter SpecialChar
highlight link markdownListMarker Identifier

" vim
highlight link vimCommentTitle NonText
highlight link vimHighlight Function
highlight link vimFunction Function
highlight link vimFuncName Keyword
highlight link vimHighlight Function
highlight link vimUserFunc Function
highlight link vimNotation SpecialChar
highlight link vimFuncSID SpecialChar

" xml
highlight link xmlTag Identifier
highlight link xmlTagName Identifier

" zsh
highlight link zshCommands Keyword
highlight link zshDeref Identifier
highlight link zshShortDeref Identifier
highlight link zshFunction Function
highlight link zshSubst Identifier
highlight link zshSubstDelim NonText
highlight link zshVariableDef Number

" man
highlight link manTitle SpecialChar
highlight link manFooter NonText

" treesitter
highlight link TSPunctBracket Delimiter
highlight link TSVariable NONE
highlight link TSConstant NONE
highlight link TSKeyword Keyword
highlight link TSInclude Keyword
highlight link TSConstBuiltin SpecialChar
highlight link TSParameter Parameter
highlight link TSVariableBuiltin SpecialChar

" bqf
call <sid>X('BqfPreviewBorder', s:green_2, '', '')

" coc
call <sid>X('CocErrorSign', s:red_2, '', '')
call <sid>X('CocWarningSign', s:yellow_2, '', '')

set background=dark
