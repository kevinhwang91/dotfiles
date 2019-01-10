Plug 'tpope/vim-surround'
let g:surround_no_mappings = 1
nmap sd <Plug>Dsurround
nmap cs <Plug>Csurround
nmap cS <Plug>CSurround
nmap ys <Plug>Ysurround
nmap yS <Plug>YSurround
nmap yss <Plug>Yssurround
nmap ygs <Plug>YSsurround
xmap S <Plug>VSurround
xmap gS <Plug>VgSurround
imap <C-S> <Plug>Isurround

Plug 'tpope/vim-repeat'
nmap U <Plug>(RepeatUndo)

Plug 'michaeljsmith/vim-indent-object'

Plug 'wellle/targets.vim'
let g:targets_aiAI = 'aIAi'
let g:targets_seekRanges = 'cc cr cb cB lc ac Ac lr lb ar ab lB' .
            \ 'Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
let g:targets_jumpRanges = g:targets_seekRanges
let g:targets_nl = 'nl'

Plug 'Krasjet/auto-pairs'

Plug 'mg979/vim-visual-multi', {'on': ['VMFromSearch', '<Plug>(VM-Find-Under)',
            \'<Plug>(VM-Visual-Cursors)','<Plug>(VM-Add-Cursor-At-Pos)',
            \'<Plug>(VM-Select-All)', '<Plug>(VM-Visual-All)',
            \'<Plug>(VM-Select-Cursor-Up)','<Plug>(VM-Select-Cursor-Down)',
            \'<Plug>(VM-Start-Regex-Search)', '<Plug>(VM-Find-Subword-Under)']}
let g:VM_leader = '<Space>'
let g:VM_theme = 'codedark'
let g:VM_highlight_matches = ''
let g:VM_show_warnings = 0
let g:VM_silent_exit = 1
let g:VM_maps = {}
let g:VM_default_mappings = 1
let g:VM_maps['Delete'] = 's'
let g:VM_maps['Select Operator'] = 'gx'
let g:VM_maps['Undo'] = '<C-u>'
let g:VM_maps['Redo'] = '<C-r>'
let g:VM_maps['Select Cursor Up'] = '<M-C-k>'
let g:VM_maps['Select Cursor Down'] = '<M-C-j>'
let g:VM_maps['Move Left'] = '<M-C-h>'
let g:VM_maps['Move Right'] = '<M-C-l>'
nmap <C-n> <Plug>(VM-Find-Under)
xmap <C-n> <Plug>(VM-Find-Subword-Under)
nmap <leader>\ <Plug>(VM-Add-Cursor-At-Pos)
nmap <leader>/ <Plug>(VM-Start-Regex-Search)
nmap <leader>A <Plug>(VM-Select-All)
xmap <leader>A <Plug>(VM-Visual-All)
xmap <leader>c <Plug>(VM-Visual-Cursors)
nmap <M-C-k> <Plug>(VM-Select-Cursor-Up)
nmap <M-C-j> <Plug>(VM-Select-Cursor-Down)
nmap <silent> <leader>g/ :VMFromSearch<CR>

Plug 'bootleq/vim-cycle'
let g:cycle_no_mappings = 1
noremap <silent> <Plug>CycleFallbackNext <C-a>
noremap <silent> <Plug>CycleFallbackPrev <C-x>
nmap <silent> <C-a> <Plug>CycleNext
vmap <silent> <C-a> <Plug>CycleNext
nmap <silent> <C-x> <Plug>CyclePrev
vmap <silent> <C-x> <Plug>CyclePrev

let g:cycle_default_groups = [
            \ [['true', 'false']],
            \ [['enable', 'disable']],
            \ [['yes', 'no']],
            \ [['on', 'off']],
            \ [['and', 'or']],
            \ [['up', 'down']],
            \ [['left', 'right']],
            \ [['top', 'bottom']],
            \ [['before', 'after']],
            \ [['push', 'pull']],
            \ [['&&', '||']],
            \ [['++', '--']],
            \ [[',', '，']],
            \ [['.', '。']],
            \ [['?', '？']],
            \ [['是', '否']],
            \ [['(:)', '（:）'], 'sub_pairs'],
            \ [['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
            \   'Friday', 'Saturday'], 'hard_case', {'name': 'Days'}],
            \ [['January', 'February', 'March', 'April', 'May', 'June',
            \   'July', 'August', 'September', 'October', 'November',
            \   'December'], 'hard_case', {'name': 'Months'}],
            \ ]
let g:cycle_default_groups_for_python = [
            \   [['elif', 'else']]
            \ ]
let g:cycle_default_groups_for_sh = [
            \   [['elif', 'else']]
            \ ]
let g:cycle_default_groups_for_zsh = g:cycle_default_groups_for_sh
let g:cycle_default_groups_for_vim = [
            \   [['elseif', 'else']]
            \ ]

Plug 'mbbill/undotree', {'on': []}
let g:undotree_SplitWidth = 45
let g:undotree_SetFocusWhenToggle = 1

function Undotree_CustomMap()
    nmap <buffer> <C-u> <Plug>UndotreeUndo
    nunmap <buffer> u
endfunc

nnoremap <silent> <M-u> :UndotreeToggle<CR>

command! -nargs=0 UndotreeToggle call s:undo_toggle()
function s:undo_toggle()
    call plug#load('undotree')
    call undotree#UndotreeToggle()
    call s:clean_undo_file()
endfunction

" TODO: always clean filename with '%'
function s:clean_undo_file()
    for undo_file in split(globpath(&undodir, '*'), '\n')
        let file_with_per = substitute(undo_file, &undodir . '/', '', '')
        let file = substitute(file_with_per, '%', '/', 'g')
        if empty(glob(file))
            call delete(undo_file)
        end
    endfor
endfunction

function s:v_set_search(cmdtype)
    let temp = @s
    norm! gv"sy
    let @/ = substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
endfunction

xnoremap * :<C-u>call <SID>v_set_search('/')<CR>/<C-r>=@/<CR><CR>
xnoremap # :<C-u>call <SID>v_set_search('?')<CR>?<C-r>=@/<CR><CR>
