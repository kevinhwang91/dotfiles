if exists("*<SID>X")
    delf <SID>X
endif

hi clear
syntax reset
if exists('g:colors_name')
    unlet g:colors_name
endif
let g:colors_name = 'one'

if has('gui_running') || has('termguicolors') || &t_Co == 88 || &t_Co == 256
    " Highlight function
    " the original one is borrowed from mhartington/oceanic-next
    function! <SID>X(group, fg, bg, attr, ...)
        let l:attrsp = get(a:, 1, "")
        " fg, bg, attr, attrsp
        if !empty(a:fg)
            exec "hi " . a:group . " guifg=" .  a:fg[0]
            exec "hi " . a:group . " ctermfg=" . a:fg[1]
        endif
        if !empty(a:bg)
            exec "hi " . a:group . " guibg=" .  a:bg[0]
            exec "hi " . a:group . " ctermbg=" . a:bg[1]
        endif
        if a:attr != ""
            exec "hi " . a:group . " gui=" .   a:attr
            exec "hi " . a:group . " cterm=" . a:attr
        endif
        if !empty(l:attrsp)
            exec "hi " . a:group . " guisp=" . l:attrsp[0]
        endif
    endfun

    " }}}


    " Color definition --------------------------------------------------------{{{
    let s:dark = 0

    let s:none = ['NONE', 'NONE']
    let s:dark = 1
    let s:mono_1 = ['#abb2bf', '249']
    let s:mono_2 = ['#828997', '102']
    let s:mono_3 = ['#5c6370', '241']
    let s:mono_4 = ['#4b5263', '239']

    let s:hue_1   = ['#56b6c2', '73'] " cyan
    let s:hue_2   = ['#61afef', '75'] " blue
    let s:hue_3   = ['#c678dd', '176'] " purple
    let s:hue_4   = ['#98c379', '114'] " green 1
    let s:hue_4_2 = ['#50a14f', '71'] " green 2

    let s:hue_5   = ['#e06c75', '168'] " red 1
    let s:hue_5_2 = ['#be5046', '130'] " red 2

    let s:hue_6   = ['#d19a66', '173'] " orange 1
    let s:hue_6_2 = ['#e5c07b', '180'] " orange 2

    let s:syntax_bg     = ['#202326', '16']
    let s:syntax_gutter = ['#636d83', '242']
    let s:syntax_cursor = ['#282c34', '236']

    let s:syntax_accent = ['#528bff', '69']

    let s:vertsplit    = ['#4b5263', '239']
    let s:special_grey = ['#3b4048', '238']
    let s:visual_grey  = ['#3e4452', '238']
    let s:pmenu        = ['#333841', '237']

    let s:syntax_fg = s:mono_1
    let s:syntax_fold_bg = s:mono_3

    " }}}

    " Vim editor color --------------------------------------------------------{{{
    call <sid>X('Normal',       s:syntax_fg,     s:syntax_bg,      '')
    call <sid>X('Bold',         '',              '',               'bold')
    call <sid>X('ColorColumn',  '',              s:syntax_cursor,  '')
    call <sid>X('Conceal',      s:mono_4,        s:none,           '')
    call <sid>X('Cursor',       '',              s:syntax_accent,  '')
    call <sid>X('CursorIM',     '',              '',               '')
    call <sid>X('CursorColumn', '',              s:syntax_cursor,  '')
    call <sid>X('CursorLine',   '',              s:syntax_cursor,  'none')
    call <sid>X('Directory',    s:hue_2,         '',               '')
    call <sid>X('ErrorMsg',     s:hue_5,         s:none,           'none')
    call <sid>X('VertSplit',    s:vertsplit,     '',               'none')
    call <sid>X('Folded',       s:syntax_bg,     s:syntax_fold_bg, 'none')
    call <sid>X('FoldColumn',   s:mono_4,        s:syntax_bg,  '')
    call <sid>X('IncSearch',    s:hue_6,         '',               '')
    call <sid>X('LineNr',       s:mono_4,        '',               '')
    call <sid>X('CursorLineNr', s:syntax_fg,     s:syntax_cursor,  'none')
    call <sid>X('MatchParen',   s:hue_5,         s:syntax_cursor,  'underline,bold')
    call <sid>X('Italic',       '',              '',               'italic')
    call <sid>X('ModeMsg',      s:syntax_fg,     '',               '')
    call <sid>X('MoreMsg',      s:syntax_fg,     '',               '')
    call <sid>X('NonText',      s:mono_3,        '',               'none')
    call <sid>X('PMenu',        '',              s:pmenu,          '')
    call <sid>X('PMenuSel',     '',              s:mono_4,         '')
    call <sid>X('PMenuSbar',    '',              s:syntax_bg,      '')
    call <sid>X('PMenuThumb',   '',              s:mono_1,         '')
    call <sid>X('Question',     s:hue_2,         '',               '')
    call <sid>X('Search',       s:syntax_bg,     s:hue_6_2,        '')
    call <sid>X('SpecialKey',   s:special_grey,  '',               'none')
    call <sid>X('Whitespace',   s:special_grey,  '',               'none')
    call <sid>X('StatusLine',   s:syntax_fg,     s:syntax_cursor,  'none')
    call <sid>X('StatusLineNC', s:mono_3,        '',               '')
    call <sid>X('TabLine',      s:mono_1,        s:none,           '')
    call <sid>X('TabLineFill',  s:mono_3,        s:visual_grey,    'none')
    call <sid>X('TabLineSel',   s:syntax_bg,     s:hue_2,          '')
    call <sid>X('Title',        s:syntax_fg,     '',               'bold')
    call <sid>X('Visual',       '',              s:visual_grey,    '')
    call <sid>X('VisualNOS',    '',              s:visual_grey,    '')
    call <sid>X('WarningMsg',   s:hue_5,         '',               '')
    call <sid>X('TooLong',      s:hue_5,         '',               '')
    call <sid>X('WildMenu',     s:syntax_fg,     s:mono_3,         '')
    call <sid>X('SignColumn',   '',              s:syntax_bg,      '')
    call <sid>X('Special',      s:hue_2,         '',               '')
    " }}}

    " Vim Help highlighting ---------------------------------------------------{{{
    call <sid>X('helpCommand',      s:hue_6_2, '', '')
    call <sid>X('helpExample',      s:hue_6_2, '', '')
    call <sid>X('helpHeader',       s:mono_1,  '', 'bold')
    call <sid>X('helpSectionDelim', s:mono_3,  '', '')
    " }}}

    " Standard syntax highlighting --------------------------------------------{{{
    call <sid>X('Comment',        s:mono_3,        '',          'italic')
    call <sid>X('Constant',       s:hue_4,         '',          '')
    call <sid>X('Parameter',      s:hue_4_2,       '',          '')
    call <sid>X('String',         s:hue_4,         '',          '')
    call <sid>X('Character',      s:hue_4,         '',          '')
    call <sid>X('Number',         s:hue_6,         '',          '')
    call <sid>X('Boolean',        s:hue_6,         '',          '')
    call <sid>X('Float',          s:hue_6,         '',          '')
    call <sid>X('Identifier',     s:hue_5,         '',          'none')
    call <sid>X('Function',       s:hue_2,         '',          '')
    call <sid>X('Statement',      s:hue_3,         '',          'none')
    call <sid>X('Conditional',    s:hue_3,         '',          '')
    call <sid>X('Repeat',         s:hue_3,         '',          '')
    call <sid>X('Label',          s:hue_3,         '',          '')
    call <sid>X('Operator',       s:syntax_accent, '',          'none')
    call <sid>X('Keyword',        s:hue_5,         '',          '')
    call <sid>X('Exception',      s:hue_3,         '',          '')
    call <sid>X('PreProc',        s:hue_6_2,       '',          '')
    call <sid>X('Include',        s:hue_2,         '',          '')
    call <sid>X('Define',         s:hue_3,         '',          'none')
    call <sid>X('Macro',          s:hue_3,         '',          '')
    call <sid>X('PreCondit',      s:hue_6_2,       '',          '')
    call <sid>X('Type',           s:hue_6_2,       '',          'none')
    call <sid>X('StorageClass',   s:hue_6_2,       '',          '')
    call <sid>X('Structure',      s:hue_6_2,       '',          '')
    call <sid>X('Typedef',        s:hue_6_2,       '',          '')
    call <sid>X('Special',        s:hue_2,         '',          '')
    call <sid>X('SpecialChar',    s:hue_1,         '',          '')
    call <sid>X('Tag',            '',              '',          '')
    call <sid>X('Delimiter',      '',              s:none,          '')
    call <sid>X('SpecialComment', '',              '',          '')
    call <sid>X('Debug',          '',              '',          '')
    call <sid>X('Underlined',     '',              '',          'underline')
    call <sid>X('Ignore',         '',              '',          '')
    call <sid>X('Error',          s:hue_5,         s:none,      'bold')
    call <sid>X('Todo',           s:hue_3,         s:none,      'italic')
    " }}}

    " Diff highlighting -------------------------------------------------------{{{
    call <sid>X('DiffAdd',     s:hue_4, s:visual_grey, '')
    call <sid>X('DiffChange',  s:hue_6, s:visual_grey, '')
    call <sid>X('DiffDelete',  s:hue_5, s:visual_grey, '')
    call <sid>X('DiffText',    s:hue_2, s:visual_grey, '')
    call <sid>X('DiffAdded',   s:hue_4, s:visual_grey, '')
    call <sid>X('DiffFile',    s:hue_5, s:visual_grey, '')
    call <sid>X('DiffNewFile', s:hue_4, s:visual_grey, '')
    call <sid>X('DiffLine',    s:hue_2, s:visual_grey, '')
    call <sid>X('DiffRemoved', s:hue_5, s:visual_grey, '')
    " }}}

    " Asciidoc highlighting ---------------------------------------------------{{{
    call <sid>X('asciidocListingBlock',   s:mono_2,  '', '')
    " }}}

    " Git and git related plugins highlighting --------------------------------{{{
    call <sid>X('GitGutterAdd',    s:hue_4,   '', '')
    call <sid>X('GitGutterChange', s:hue_6_2, '', '')
    call <sid>X('GitGutterDelete', s:hue_5,   '', '')
    call <sid>X('GitGutterChangeDeleteLine', s:hue_5_2, '', '')
    " }}}

    " Markdown highlighting ---------------------------------------------------{{{
    call <sid>X('markdownUrl',              s:mono_3,  '', '')
    call <sid>X('markdownBold',             s:hue_6,   '', 'bold')
    call <sid>X('markdownItalic',           s:hue_6,   '', 'bold')
    call <sid>X('markdownCode',             s:hue_4,   '', '')
    call <sid>X('markdownCodeBlock',        s:hue_5,   '', '')
    call <sid>X('markdownCodeDelimiter',    s:hue_4,   '', '')
    call <sid>X('markdownHeadingDelimiter', s:hue_5_2, '', '')
    call <sid>X('markdownH1',               s:hue_5,   '', '')
    call <sid>X('markdownH2',               s:hue_5,   '', '')
    call <sid>X('markdownH3',               s:hue_5,   '', '')
    call <sid>X('markdownH3',               s:hue_5,   '', '')
    call <sid>X('markdownH4',               s:hue_5,   '', '')
    call <sid>X('markdownH5',               s:hue_5,   '', '')
    call <sid>X('markdownH6',               s:hue_5,   '', '')
    call <sid>X('markdownListMarker',       s:hue_5,   '', '')
    " }}}

    " Spelling highlighting ---------------------------------------------------{{{
    call <sid>X('SpellBad',     '', s:syntax_bg, 'undercurl')
    call <sid>X('SpellLocal',   '', s:syntax_bg, 'undercurl')
    call <sid>X('SpellCap',     '', s:syntax_bg, 'undercurl')
    call <sid>X('SpellRare',    '', s:syntax_bg, 'undercurl')
    " }}}

    " Vim highlighting --------------------------------------------------------{{{
    call <sid>X('vimCommand',      s:hue_3,  '', '')
    call <sid>X('vimCommentTitle', s:mono_3, '', 'bold')
    call <sid>X('vimFunction',     s:hue_2,  '', '')
    call <sid>X('vimFuncName',     s:hue_3,  '', '')
    call <sid>X('vimHighlight',    s:hue_2,  '', '')
    call <sid>X('vimLineComment',  s:mono_3, '', 'italic')
    call <sid>X('vimParenSep',     s:mono_2, '', '')
    call <sid>X('vimSep',          s:mono_2, '', '')
    call <sid>X('vimUserFunc',     s:hue_2,  '', '')
    call <sid>X('vimNotation',     s:hue_1,  '', '')
    call <sid>X('vimFuncSID',      s:hue_1,  '', '')
    call <sid>X('vimVar',          s:hue_5,  '', '')
    " }}}

    " XML highlighting --------------------------------------------------------{{{
    call <sid>X('xmlAttrib',  s:hue_6_2, '', '')
    call <sid>X('xmlEndTag',  s:hue_5,   '', '')
    call <sid>X('xmlTag',     s:hue_5,   '', '')
    call <sid>X('xmlTagName', s:hue_5,   '', '')
    " }}}

    " ZSH highlighting --------------------------------------------------------{{{
    call <sid>X('zshCommands',     s:hue_3, '', '')
    call <sid>X('zshDeref',        s:hue_5,     '', '')
    call <sid>X('zshShortDeref',   s:hue_5,     '', '')
    call <sid>X('zshFunction',     s:hue_2,     '', '')
    call <sid>X('zshKeyword',      s:hue_3,     '', '')
    call <sid>X('zshSubst',        s:hue_5,     '', '')
    call <sid>X('zshSubstDelim',   s:mono_3,    '', '')
    call <sid>X('zshTypes',        s:hue_3,     '', '')
    call <sid>X('zshVariableDef',  s:hue_6,     '', '')
    " }}}

    " man highlighting --------------------------------------------------------{{{
    hi link manTitle String
    call <sid>X('manFooter', s:mono_3, '', '')
    " }}}
endif
"}}}

set background=dark
