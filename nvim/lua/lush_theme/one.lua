-- lua require('lush').ify()
local lush = require('lush')
-- local hsl = lush.hsl

local black1 = '#202326'
local black2 = '#282c34'
local red1 = '#e06c75'
local red2 = '#be5046'
local red3 = '#442d30'
local green1 = '#98c379'
local green2 = '#50a14f'
local green3 = '#2a3c33'
local yellow1 = '#d19a66'
local yellow2 = '#e5c07b'
local blue1 = '#61afef'
local blue2 = '#528bff'
local blue3 = '#213352'
local blue4 = '#31435e'
local purple1 = '#c678dd'
local purple2 = '#8075f1'
local cyan1 = '#56b6c2'
local white1 = '#abb2bf'
local mono1 = '#5c6370'
local mono2 = '#4b5263'
local mono3 = '#3e4452'
local mono4 = '#333841'
local mono5 = '#30353f'

---@diagnostic disable
local theme = lush(function()
    return {
        Comment {fg = mono1, gui = 'italic'}, --
        ColorColumn {bg = black2}, --
        Conceal {fg = mono2}, --
        Cursor {fg = black1, bg = blue2}, --
        -- lCursor {}, --
        -- CursorIM {}, --
        CursorColumn {bg = black2}, --
        CursorLine {bg = black2}, --
        Directory {fg = blue1}, --
        DiffAdd {bg = green3}, --
        DiffChange {bg = mono4}, --
        DiffDelete {bg = red3}, --
        DiffText {bg = blue3}, --
        -- EndOfBuffer {}, --
        TermCursor {fg = black1, bg = blue2}, --
        -- TermCursorNC {}, --
        ErrorMsg {fg = red2}, --
        VertSplit {fg = mono3}, --
        Folded {fg = white1, bg = mono3}, --
        FoldColumn {fg = mono2, bg = black1}, --
        SignColumn {bg = black1}, --
        IncSearch {fg = black1, bg = yellow1}, --
        -- Substitute {}, --
        LineNr {fg = mono2}, --
        CursorLineNr {fg = white1, bg = black2}, --
        MatchParen {fg = purple2, gui = 'bold,underline'}, --
        ModeMsg {fg = white1}, --
        -- MsgArea {}, --
        -- MsgSeparator {}, --
        MoreMsg {fg = white1}, --
        NonText {fg = mono1}, --
        Normal {fg = white1, bg = black1}, --
        -- NormalFloat {}, --
        -- NormalNC {}, --
        Pmenu {fg = white1, bg = mono4}, --
        PmenuSel {fg = white1, bg = blue4}, --
        PmenuSbar {bg = black1}, --
        PmenuThumb {bg = mono1}, --
        Question {fg = blue1}, --
        QuickFixLine {bg = blue3, gui = 'bold'}, --
        Search {fg = black1, bg = yellow2}, --
        SpecialKey {fg = mono3}, --
        -- SpellBad {}, --
        -- SpellCap {}, --
        -- SpellLocal {}, --
        -- SpellRare {}, --
        StatusLine {fg = white1, bg = mono5}, --
        StatusLineNC {fg = black1, bg = mono1}, --
        TabLine {fg = white1, bg = mono3}, --
        TabLineFill {fg = mono1, bg = black1}, --
        TabLineSel {fg = black1, bg = blue2, gui = 'bold'}, --
        Title {fg = white1, gui = 'bold'}, --
        Visual {bg = mono3}, --
        -- VisualNOS {}, --
        WarningMsg {fg = yellow2}, --
        Whitespace {SpecialKey}, --
        WildMenu {fg = white1, bg = mono1}, --
        --
        Constant {fg = green1}, --
        -- String {}, --
        -- Character {}, --
        Number {fg = yellow1}, --
        Boolean {Number}, --
        Float {Number}, --
        Special {fg = cyan1}, --
        -- SpecialChar {}, --
        -- Tag {}, --
        Delimiter {}, --
        -- SpecialComment {}, --
        -- Debug {}, --
        Identifier {fg = red1}, --
        Function {fg = blue1}, --
        Statement {fg = purple1}, --
        -- Conditional {}, --
        -- Repeat {}, --
        Label {Identifier}, --
        Operator {fg = blue2}, --
        -- Keyword {}, --
        -- Exception {}, --
        PreProc {fg = yellow2}, --
        Include {Function}, --
        Define {Statement}, --
        Macro {Statement}, --
        -- PreCondit {}, --
        Type {fg = yellow2}, --
        -- StorageClass {}, --
        -- Structure {}, --
        -- Typedef {}, --
        Underlined {gui = 'underline'}, --
        -- Bold {gui = 'bold'}, --
        -- Italic {gui = 'italic'}, --
        Error {fg = red1, gui = 'bold'}, --
        Todo {fg = purple1, gui = 'italic'}, --
        -- extra
        Parameter {fg = green2}, --
        CurrentWord {bg = blue4, gui = 'bold'}, --
        -- statusline
        StatusLineNormal {fg = mono5, bg = green1, gui = 'bold'}, --
        StatusLineInsert {fg = mono5, bg = blue1, gui = 'bold'}, --
        StatusLineReplace {fg = mono5, bg = red1, gui = 'bold'}, --
        StatusLineVisual {fg = mono5, bg = purple1, gui = 'bold'}, --
        StatusLineCommand {fg = mono5, bg = cyan1, gui = 'bold'}, --
        StatusLineBranch {fg = cyan1, bg = mono5}, --
        StatusLineHunkAdd {fg = green1, bg = mono5}, --
        StatusLineHunkChange {fg = yellow1, bg = mono5}, --
        StatusLineHunkRemove {fg = red1, bg = mono5}, --
        StatusLineFileName {fg = white1, bg = mono5}, --
        StatusLineFileModified {fg = purple2, bg = mono5}, --
        StatusLineFormat {fg = blue2, bg = mono5}, --
        StatusLineError {fg = red2, bg = mono5}, --
        StatusLineWarning {fg = yellow2, bg = mono5}, --
        -- diff
        DiffFile {DiffText}, --
        DiffOldFile {DiffDelete}, --
        DiffNewFile {DiffAdd}, --
        DiffRemoved {DiffDelete}, --
        DiffAdded {DiffAdd}, --
        DiffLine {DiffText}, --
        -- help
        helpCommand {Type}, --
        helpExample {Type}, --
        helpHeader {Title}, --
        helpSectionDelim {NonText}, --
        -- asciidoc
        asciidocListingBlock {NonText}, --
        -- html
        htmlH1 {fg = cyan1, gui = 'bold'}, --
        -- markdown
        markdownBold {fg = yellow1, gui = 'bold'}, --
        markdownItalic {fg = yellow1, gui = 'bold'}, --
        markdownUrl {NonText}, --
        markdownCode {Constant}, --
        markdownCodeBlock {Identifier}, --
        markdownListMarker {Identifier}, --
        markdownHeadingDelimiter {Special}, --
        -- vim
        vimCommentTitle {NonText}, --
        vimHighlight {Function}, --
        vimFunction {Function}, --
        vimUserFunc {Function}, --
        vimNotation {Special}, --
        vimFuncSID {Special}, --
        -- xml
        xmlTag {Identifier}, --
        xmlTagName {Identifier}, --
        -- zsh
        zshCommands {Statement}, --
        zshDeref {Identifier}, --
        zshShortDeref {Identifier}, --
        zshFunction {Function}, --
        zshSubst {Identifier}, --
        zshSubstDelim {NonText}, --
        zshVariableDef {Number}, --
        -- man
        manTitle {Special}, --
        manFooter {NonText} --
    }
end)
---@diagnostic enable

return theme
