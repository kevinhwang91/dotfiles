let s:cyan   = ['#56b6c2', 73]
let s:blue1  = [ '#61afef', 75 ]
let s:blue2  = [ '#528bff', 69 ]
let s:green  = [ '#98c379', 76 ]
let s:purple = [ '#c678dd', 176 ]
let s:red1   = [ '#e06c75', 168 ]
let s:red2   = [ '#be5046', 168 ]
let s:yellow1 = ['#d19a66', 173]
let s:yellow2 = [ '#e5c07b', 180 ]
let s:fg    = [ '#abb2bf', 249 ]
let s:bg    = [ '#202326', 235 ]
let s:gray1 = [ '#5c6370', 241 ]
let s:gray2 = [ '#282c34', 236 ]
let s:gray3 = [ '#3b4048', 238 ]
let s:gray4 = [ '#333841', 237]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {},
            \ 'command': {}, 'tabline': {}}

let s:p.inactive.left   = [ [ s:gray1,  s:gray4, 'bold' ] ]
let s:p.inactive.middle = [ [ s:gray1, s:gray4 ] ]
let s:p.inactive.right  = [ [ s:gray1, s:gray4 ] ]

" Common
let s:p.normal.left    = [ [ s:bg, s:green, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.normal.middle  = [ [ s:fg, s:gray2 ] ]
let s:p.normal.right   = [ [ s:bg, s:green, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.normal.error   = [ [ s:bg, s:red2, 'bold' ] ]
let s:p.normal.warning = [ [ s:bg, s:yellow2, 'bold'] ]
let s:p.insert.right   = [ [ s:bg, s:blue1, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.insert.left    = [ [ s:bg, s:blue1, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.replace.right  = [ [ s:bg, s:red1, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.replace.left   = [ [ s:bg, s:red1, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.visual.right   = [ [ s:bg, s:purple, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.visual.left    = [ [ s:bg, s:purple, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.command.right   = [ [ s:bg, s:cyan, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.command.left    = [ [ s:bg, s:cyan, 'bold' ], [ s:fg, s:gray3 ] ]
let s:p.tabline.left   = [ [ s:fg, s:gray3 ] ]
let s:p.tabline.tabsel = [ [ s:bg, s:blue2, 'bold' ] ]
let s:p.tabline.middle = [ [ s:gray3, s:bg ] ]
let s:p.tabline.right  = copy(s:p.normal.right)

let g:lightline#colorscheme#one#palette = lightline#colorscheme#flatten(s:p)
