local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local g = vim.g
local o, wo, bo = vim.o, vim.wo, vim.bo
local map = require('remap').map

cmd('syntax enable')
wo.number = true
wo.relativenumber = true
wo.cursorline = true
wo.signcolumn = 'yes:1'
wo.foldcolumn = '1'
wo.foldenable = true
wo.list = true
bo.tabstop = 4
o.tabstop = bo.tabstop
bo.shiftwidth = 4
o.shiftwidth = bo.shiftwidth
bo.softtabstop = -1
o.softtabstop = bo.softtabstop
bo.expandtab = true
o.expandtab = bo.expandtab
bo.autoindent = true
o.autoindent = bo.autoindent
bo.smartindent = true
o.smartindent = bo.smartindent
o.synmaxcol = 300
bo.synmaxcol = o.synmaxcol
o.textwidth = 100
bo.textwidth = o.textwidth
o.clipboard = 'unnamedplus'
o.timeout = true
o.timeoutlen = 500
o.ignorecase = true
o.smartcase = true
o.updatetime = 200
o.hidden = true
o.fileencodings = 'utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1'
o.showmode = false
o.cedit = '<C-x>'
o.listchars = 'tab:▏ ,trail:•'
o.showbreak = '╰─➤'
o.foldlevelstart = 99
o.title = true
o.titlestring = '%(%m%)%(%{expand(\"%:~\")}%)'
o.history = 3000
o.lazyredraw = true
o.inccommand = 'nosplit'
o.shortmess = o.shortmess .. 'aIc'
o.diffopt = o.diffopt .. ',vertical'
o.shada = [[!,'20,<50,s10,/100,@1000,h]]

-- undo
bo.undofile = true
o.undofile = bo.undofile
o.undolevels = 1000

-- no backup
o.backup = false
bo.swapfile = false
o.swapfile = bo.swapfile

if fn.has('termguicolors') == 1 then
    o.termguicolors = true
end

g.loaded_netrwPlugin = 1
g.loaded_matchparen = 1
g.loaded_matchit = 1

if vim.env.DISPLAY and fn.executable('xsel') then
    g.clipboard = {
        name = 'xsel',
        copy = {['+'] = 'xsel --nodetach -i -b', ['*'] = 'xsel --nodetach -i -b'},
        paste = {['+'] = 'xsel -o -b', ['*'] = 'xsel -o -b'},
        cache_enabled = true
    }
elseif vim.env.TMUX then
    g.clipboard = {
        name = 'tmux',
        copy = {['+'] = 'tmux load-buffer -w -', ['*'] = 'tmux load-buffer -w -'},
        paste = {['+'] = 'tmux save-buffer -', ['*'] = 'tmux save-buffer -'},
        cache_enabled = true
    }
elseif fn.executable('osc52send') then
    g.clipboard = {
        name = 'osc52send',
        copy = {['+'] = 'osc52send', ['*'] = 'osc52send'},
        paste = {['+'] = '', ['*'] = ''},
        cache_enabled = true
    }
end

-- map
g.mapleader = ' '
map('n', '<Space>', '')
map('x', '<Space>', '')
map('n', 'q', '')
map('n', 'Q', '')
map('n', '-', '"_')
map('x', '-', '"_')
map('n', '<leader>2;', '@:')
map('x', '<leader>2;', '@:')
map('n', 'qq', '<Cmd>confirm q<CR>')
map('n', 'qa', '<Cmd>confirm qa<CR>')
map('n', 'qt', '<Cmd>tabc<CR>')
map('n', 'qc', '<Cmd>ccl<CR>')
map('n', 'qs', '<Cmd>lcl<CR>')
map('n', '<leader>w', '<Cmd>up<CR>')
map('n', '<leader>wq', '<Cmd>wq<CR>')
map('n', '<C-g>', '1<C-g>')
map('n', '<leader>3', '<Cmd>buffer #<CR>')
map('n', '<leader>l', ':nohlsearch<CR>')
map('c', '<C-b>', '<Left>')
map('c', '<C-f>', '<Right>')
map('c', '<C-a>', '<Home>')
map('c', '<C-d>', '<Del>')
map('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]])
map('c', '<M-b>', '<C-Left>')
map('c', '<M-f>', '<C-Right>')
map('c', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})
map('t', [[<M-\>]], [[<C-\><C-n>]])
map('n', '<C-w>O', '<Cmd>tabonly<CR>')
map('i', '<M-;>', '<END>')

map('n', 's', 'd')
map('x', 's', 'd')
map('o', 's', 'd')
map('n', 'd', '<C-d>')
map('x', 'd', '<C-d>')
map('n', 'u', '<C-u>')
map('x', 'u', '<C-u>')
map('n', '<C-u>', 'u')
map('n', 'k', [[(v:count > 1 ? "m'" . v:count : '') . 'k']], {noremap = true, expr = true})
map('n', 'j', [[(v:count > 1 ? "m'" . v:count : '') . 'j']], {noremap = true, expr = true})

map('n', [[']], [[`]])
map('x', [[']], [[`]])
map('o', [[']], [[`]])
map('n', [[`]], [[']])
map('x', [[`]], [[']])
map('o', [[`]], [[']])
map('n', [[g']], [[g`]])
map('x', [[g']], [[g`]])
map('o', [[g']], [[g`]])
map('n', [[g`]], [[g']])
map('x', [[g`]], [[g']])
map('n', [[m']], [[m`]])
map('x', [[m']], [[m`]])

map('n', [['0]], [[<Cmd>normal! `0<CR><Cmd>silent! CleanEmptyBuf<CR>]])
map('n', '<leader>i', '<Cmd>silent! normal! `^<CR>')

map('x', '<M-j>', [[:move '>+1<CR>gv=gv]])
map('x', '<M-k>', [[:move '<-2<CR>gv=gv]])
map('n', 'yd', [[<Cmd>call setreg(v:register, expand('%:p:h'))<CR>:echo expand('%:p:h')<CR>]])
map('n', 'yn', [[<Cmd>call setreg(v:register, expand('%:t'))<CR>:echo expand('%:t')<CR>]])
map('n', 'yp', [[<Cmd>call setreg(v:register, expand('%:p'))<CR>:echo expand('%:p')<CR>]])
map('n', 'Y', 'y$')

map('n', '[', [[v:lua._G.prefix_timeout('[')]], {noremap = true, expr = true})
map('x', '[', [[v:lua._G.prefix_timeout('[')]], {noremap = true, expr = true})
map('n', ']', [[v:lua._G.prefix_timeout(']')]], {noremap = true, expr = true})
map('x', ']', [[v:lua._G.prefix_timeout(']')]], {noremap = true, expr = true})
map('n', '[b', '<Cmd>bprevious<CR>')
map('n', ']b', '<Cmd>bnext<CR>')
map('n', '[q', [[<Cmd>execute(v:count1 . 'cprevious')<CR>]])
map('n', ']q', [[<Cmd>execute(v:count1 . 'cnext')<CR>]])
map('n', '[Q', '<Cmd>cfirst<CR>')
map('n', ']Q', '<Cmd>clast<CR>')
map('n', '[s', [[<Cmd>execute(v:count1 . 'lprevious')<CR>]])
map('n', ']s', [[<Cmd>execute(v:count1 . 'lnext')<CR>]])
map('n', '[S', '<Cmd>lfirst<CR>')
map('n', ']S', '<Cmd>llast<CR>')
map('n', '[z', '[z_')
map('x', '[z', '[z_')
map('n', ']z', ']z_')
map('x', ']z', ']z_')
map('n', 'zj', 'zj_')
map('x', 'zj', 'zj_')
map('n', 'zk', 'zk_')
map('x', 'zk', 'zk_')
map('n', 'z', [[v:lua._G.prefix_timeout('z')]], {noremap = true, expr = true})
map('x', 'z', [[v:lua._G.prefix_timeout('z')]], {noremap = true, expr = true})

map('n', 'zZ', [[<Cmd>lua require('kutils').zz()<CR>]])
map('x', 'zZ', [[<Cmd>lua require('kutils').zz()<CR>]])

map('n', 'z[', [[<Cmd>lua require('kutils').nav_fold(false, vim.v.count1)<CR>]])
map('n', 'z]', [[<Cmd>lua require('kutils').nav_fold(true, vim.v.count1)<CR>]])

map('x', 'iz', [[:<C-U>normal [zv]zg_<CR>]])
map('o', 'iz', [[:normal viz<CR>]])

-- https://github.com/neovim/neovim/issues/13862
function _G.prefix_timeout(prefix)
    local char = fn.getchar(0)
    if type(char) == 'number' then
        char = fn.nr2char(char)
    end
    return char == '' and [[\<Nul>]] or prefix .. char
end

require('mru')
require('stl')
require('plugs.fold')

g.loaded_remote_plugins = fn.stdpath('data') .. '/rplugin.vim'
cmd([[command! -bar UpdateRemotePlugins call remote#host#UpdateRemotePlugins()]])

-- sakhnik/nvim-gdb
api.nvim_exec([[
    function! GdbInit(...)
        call v:lua.require('plugs.nvimgdb').manual_init(a:000)
    endfunction
]], false)

-- junegunn/fzf.vim
vim.g.loaded_fzf = true
map('n', '<leader>ft', '<Cmd>BTags<CR>')
map('n', '<leader>fo', '<Cmd>Tags<CR>')
map('n', '<leader>fc', '<Cmd>BCommits<CR>')
map('n', '<leader>f/', '<Cmd>History/<CR>')
map('n', '<leader>f;', '<Cmd>History:<CR>')
map('n', '<leader>fg', '<Cmd>GFiles<CR>')
map('n', '<leader>fm', '<Cmd>Marks<CR>')
map('n', '<leader>ff', '<Cmd>FZF<CR>')
map('n', '<leader>fb', '<Cmd>Buffers<CR>')
map('n', '<leader>fr', [[<Cmd>lua require('plugs.fzf').mru()<CR>]])
api.nvim_exec([[
    augroup Fzf
        autocmd!
        autocmd FuncUndefined fzf#* lua require('plugs.fzf')
        autocmd CmdUndefined FZF,BTags,BCommits,History,GFiles,Marks,Buffers,Maps lua require('plugs.fzf')
    augroup END
]], false)

if fn.empty(fn.glob(fn.stdpath('config') .. '/plugin/packer_compiled.vim')) == 1 then
    require('plugs.packer').compile()
else
    cmd([[command! PackerInstall lua require('plugs.packer').install()]])
    cmd([[command! PackerUpdate lua require('plugs.packer').update()]])
    cmd([[command! PackerSync lua require('plugs.packer').sync()]])
    cmd([[command! PackerClean lua require('plugs.packer').clean()]])
    cmd([[command! PackerCompile lua require('plugs.packer').compile()]])
end

vim.api.nvim_exec([[
    augroup Packer
        autocmd!
        autocmd BufWritePost */plugs/packer.lua call execute(['luafile ' . expand('<afile>'), 'PackerCompile'])
    augroup END
]], false)

pcall(cmd, 'colorscheme one')

-- kevinhwang91/nvim-hlslens
map('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
map('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])

api.nvim_exec([[
    augroup VMlens
        autocmd!
        autocmd User visual_multi_start lua require('plugs.hlslens').vmlens_start()
        autocmd User visual_multi_exit lua require('plugs.hlslens').vmlens_exit()
    augroup END
]], false)

-- kevinhwang91/rnvimr
g.rnvimr_enable_ex = 1
g.rnvimr_enable_bw = 1
g.rnvimr_hide_gitignore = 1
g.rnvimr_border_attr = {fg = 3}
g.rnvimr_ranger_cmd = 'ranger'
g.rnvimr_ranger_views = {
    {minwidth = 90, ratio = {}}, {minwidth = 50, maxwidth = 89, ratio = {1, 1}},
    {maxwidth = 49, ratio = {1}}
}
cmd('highlight link RnvimrNormal CursorLine')
map('t', '<M-i>', [[<C-\><C-n><Cmd>RnvimrResize<CR>]])
map('t', '<M-o>', [[<C-\><C-n><Cmd>RnvimrToggle<CR>]])
map('n', '<M-o>', '<Cmd>RnvimrToggle<CR>')

-- t9md/vim-choosewin
g.choosewin_blink_on_land = 0
g.choosewin_color_label = {gui = {'#98c379', '#202326', 'bold'}}
g.choosewin_color_label_current = {gui = {'#528bff', '#202326', 'bold'}}
g.choosewin_color_other = {gui = {'#2c323c'}}
map('n', '<M-0>', '<Cmd>ChooseWin<CR>')

-- mhinz/vim-grepper
g.grepper = {
    tools = {'rg', 'grep'},
    dir = 'repo,file',
    open = 0,
    switch = 1,
    jump = 0,
    simple_prompt = 1,
    quickfix = 1,
    searchreg = 1,
    highlight = 0,
    rg = {
        grepprg = 'rg -H --no-heading --vimgrep --smart-case',
        grepformat = '%f:%l:%c:%m,%f:%l:%m'
    }
}
-- if fn.executable('rg') then
--     vim.bo.grepprg = [[rg\ --vimgrep\ --no-heading\ --smart-case]]
--     vim.o.grepprg = vim.bo.grepprg
--     vim.o.grepformat = [[%f:%l:%c:%m,%f:%l:%m]]
-- end
map('n', '<leader>rg', [[<Cmd>Grepper -tool rg<CR>]])
map('n', 'gs', '<Plug>(GrepperOperator)', {})
map('x', 'gs', '<Plug>(GrepperOperator)', {})
api.nvim_exec([[
    augroup Grepper
        autocmd!
        autocmd User Grepper call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': histget('/')}}}) | botright copen
    augroup END
]], false)

-- andymass/vim-matchup
g.matchup_matchparen_timeout = 100
g.matchup_matchparen_deferred = 1
g.matchup_matchparen_deferred_show_delay = 150
g.matchup_matchparen_deferred_hide_delay = 700
g.matchup_matchparen_hi_surround_always = 1
g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'CurrentWord'}
g.matchup_delim_start_plaintext = 0
g.matchup_motion_override_Npercent = 0
g.matchup_motion_cursor_end = 0
g.matchup_mappings_enabled = 0

cmd('highlight link MatchWord Underlined')
api.nvim_exec([[
    augroup MatchupMatch
        autocmd!
        autocmd TermEnter * call clearmatches()
        autocmd TermOpen * let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
    augroup END
]], false)

map('n', '%', '<Plug>(matchup-%)', {})
map('x', '%', '<Plug>(matchup-%)', {})
map('o', '%', '<Plug>(matchup-%)', {})
map('n', '[5', '<Plug>(matchup-[%)', {})
map('x', '[5', '<Plug>(matchup-[%)', {})
map('o', '[5', '<Plug>(matchup-[%)', {})
map('n', ']5', '<Plug>(matchup-]%)', {})
map('x', ']5', '<Plug>(matchup-]%)', {})
map('o', ']5', '<Plug>(matchup-]%)', {})
map('n', [[z']], '<Plug>(matchup-z%)', {})
map('x', [[z']], '<Plug>(matchup-z%)', {})
map('o', [[z']], '<Plug>(matchup-z%)', {})
map('x', 'a5', '<Plug>(matchup-a%)', {})
map('o', 'a5', '<Plug>(matchup-a%)', {})
map('x', 'i5', '<Plug>(matchup-i%)', {})
map('o', 'i5', '<Plug>(matchup-i%)', {})

-- haya14busa/vim-asterisk
g['asterisk#keeppos'] = 0
map('', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {})
map('', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {})
map('', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
map('', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})

g.surround_no_mappings = 1
map('n', 'sd', '<Plug>Dsurround', {})
map('n', 'cs', '<Plug>Csurround', {})
map('n', 'cS', '<Plug>CSurround', {})
map('n', 'ys', '<Plug>Ysurround', {})
map('n', 'yS', '<Plug>YSurround', {})
map('n', 'yss', '<Plug>Yssurround', {})
map('n', 'ygs', '<Plug>YSsurround', {})
map('x', 'S', '<Plug>VSurround', {})
map('x', 'gS', '<Plug>VgSurround', {})
map('n', '<C-S>', '<Plug>Isurround', {})

map('n', 'U', '<Plug>(RepeatUndo)', {})

-- wellle/targets.vim
g.targets_aiAI = 'aIAi'
g.targets_seekRanges =
    'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
g.targets_jumpRanges = g.targets_seekRanges
g.targets_nl = 'nl'

-- tommcdo/vim-exchange
g.exchange_no_mappings = 1
map('n', 'cx', '<Plug>(Exchange)', {})
map('x', 'X', '<Plug>(Exchange)', {})
map('n', 'cx;', '<Plug>(ExchangeClear)', {})
map('n', 'cxx', '<Plug>(ExchangeLine)', {})

-- mg979/vim-visual-multi
g.VM_leader = '<Space>'
g.VM_theme = 'codedark'
g.VM_highlight_matches = ''
g.VM_show_warnings = 0
g.VM_silent_exit = 1
g.VM_default_mappings = 1
g.VM_maps = {
    Delete = 's',
    Undo = '<C-u>',
    Redo = '<C-r>',
    ['Select Cursor Up'] = '<M-C-k>',
    ['Select Cursor Down'] = '<M-C-j>',
    ['Move Left'] = '<M-C-h>',
    ['Move Right'] = '<M-C-l>'
}
map('n', '<C-n>', '<Plug>(VM-Find-Under)', {})
map('x', '<C-n>', '<Plug>(VM-Find-Subword-Under)', {})
map('n', [[<leader>\]], '<Plug>(VM-Add-Cursor-At-Pos)', {})
map('n', '<leader>/', '<Plug>(VM-Start-Regex-Search)', {})
map('n', '<leader>A', '<Plug>(VM-Select-All)', {})
map('x', '<leader>A', '<Plug>(VM-Visual-All)', {})
map('x', '<leader>c', '<Plug>(VM-Visual-Cursors)', {})
map('n', '<M-C-k>', '<Plug>(VM-Select-Cursor-Up)', {})
map('n', '<M-C-j>', '<Plug>(VM-Select-Cursor-Down)', {})
map('n', '<leader>g/', '<Cmd>VMSearch<CR>')

-- highlight syntax
api.nvim_exec([[
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * lua if not vim.b.visual_multi then vim.highlight.on_yank({higroup='IncSearch', timeout=800}) end
    augroup END
]], false)


-- bootleq/vim-cycle
g.cycle_no_mappings = 1
g.cycle_default_groups = {
    {{'true', 'false'}}, {{'enable', 'disable'}}, {{'yes', 'no'}}, {{'on', 'off'}}, {{'and', 'or'}},
    {{'up', 'down'}}, {{'left', 'right'}}, {{'top', 'bottom'}}, {{'before', 'after'}},
    {{'width', 'height'}}, {{'push', 'pull'}}, {{'&&', '||'}}, {{'++', '--'}}, {{',', '，'}},
    {{'.', '。'}}, {{'?', '？'}}, {{'是', '否'}}, {{'(:)', '（:）'}, 'sub_pairs'}, {
        {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}, 'hard_case',
        {name = 'Days'}
    }, {
        {
            'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
            'October', 'November', 'December'
        }, 'hard_case', {name = 'Months'}
    }
}
g.cycle_default_groups_for_python = {{{'elif', 'else'}}}
g.cycle_default_groups_for_sh = {{{'elif', 'else'}}}
g.cycle_default_groups_for_zsh = g.cycle_default_groups_for_sh
g.cycle_default_groups_for_vim = {{{'elseif', 'else'}}}
g.cycle_default_groups_for_lua = {{{'elseif', 'else'}}}

map('n', '<Plug>CycleFallbackNext', '<C-a>')
map('n', '<Plug>CycleFallbackPrev', '<C-x>')
map('n', '<C-a>', '<Plug>CycleNext', {})
map('v', '<C-a>', '<Plug>CycleNext', {})
map('n', '<C-x>', '<Plug>CyclePrev', {})
map('v', '<C-x>', '<Plug>CyclePrev', {})

-- mbbill/undotree
map('n', '<M-u>', '<Cmd>UndotreeToggle<CR>')
cmd([[command! -nargs=0 UndotreeToggle lua require('plugs.undotree').toggle()]])

-- tpope/vim-fugitive
g.nremap = {
    ['d?'] = 's?',
    dv = 'sv',
    dp = 'sp',
    ds = 'sh',
    dh = 'sh',
    dq = 'qd',
    d2o = 's2o',
    d3o = 's3o',
    dd = 'ss',
    s = 'S',
    u = '<C-u>',
    O = 'T',
    ['[m'] = '[f',
    [']m'] = ']f'
}
g.xremap = {s = 'S', u = '<C-u>'}
map('n', '<leader>gg', '<Cmd>tab Git<CR>')
map('n', '<leader>gc', ':Git commit<Space>')
map('n', '<leader>gC', ':Git commit --amend<Space>')
map('n', '<leader>ge', '<Cmd>Gedit<CR>')
map('n', '<leader>gb', '<Cmd>Git blame -w <bar>wincmd p<CR>')
map('n', '<leader>gw', [[<Cmd>lua require('kutils').follow_symlink()<CR><Cmd>Gwrite<CR>]])
map('n', '<leader>gr',
    [[<Cmd>lua require('kutils').follow_symlink()<CR><Cmd>keepalt Gread <bar> up!<CR>]])
map('n', '<leader>gd', '<Cmd>Gdiffsplit<CR>')
map('n', '<leader>gD', '<Cmd>Gdiffsplit HEAD<CR>')
map('n', 'qd', '<Cmd>call fugitive#DiffClose()<CR>')

-- ruanyl/vim-gh-line
g.gh_line_blame_map_default = 0
map('n', '<leader>gO', '<Plug>(gh-repo)', {})
map('n', '<leader>gL', '<Plug>(gh-line)', {})
map('x', '<leader>gL', '<Plug>(gh-line)', {})

-- airblade/vim-gitgutter
g.gitgutter_highlight_linenrs = 1
g.gitgutter_signs = 0
g.gitgutter_max_signs = 9999
g.gitgutter_map_keys = 0
map('n', '<leader>hp', '<Plug>(GitGutterPreviewHunk)', {})
map('n', '<leader>hs', '<Plug>(GitGutterStageHunk)', {})
map('n', '<leader>hu', '<Plug>(GitGutterUndoHunk)', {})
map('n', '[c', '<Plug>(GitGutterPrevHunk)', {})
map('n', ']c', '<Plug>(GitGutterNextHunk)', {})
map('o', 'ih', '<Plug>(GitGutterTextObjectInnerPending)', {})
map('o', 'ah', '<Plug>(GitGutterTextObjectOuterPending)', {})
map('x', 'ih', '<Plug>(GitGutterTextObjectInnerVisual)', {})
map('x', 'ah', '<Plug>(GitGutterTextObjectOuterVisual)', {})

-- rbong/vim-flog
g.flog_default_arguments = {max_count = 1000}
map('n', '<leader>gl', '<Cmd>Flog<CR>')
map('n', '<leader>gf', '<Cmd>Flog -path=%<CR>')

-- rhysd/git-messenger.vim
g.git_messenger_no_default_mappings = 0
g.git_messenger_always_into_popup = 1
map('n', '<leader>gm', '<Cmd>GitMessenger<CR>')

-- rrethy/vim-hexokinase
local all_hexokinase_pat = {'full_hex', 'triple_hex', 'rgb', 'rgba', 'hsl', 'hsla', 'colour_names'}
g.Hexokinase_highlighters = {'backgroundfull'}
g.Hexokinase_refreshEvents = {'BufRead', 'TextChanged', 'InsertLeave'}
g.Hexokinase_ftOptOutPatterns = {css = all_hexokinase_pat, scss = all_hexokinase_pat}
g.Hexokinase_termDisabled = 1

-- sbdchd/neoformat
g.neoformat_only_msg_on_error = 1
g.neoformat_basic_format_align = 1
g.neoformat_basic_format_retab = 1
g.neoformat_basic_format_trim = 1
map('n', '<M-C-l>', '<Cmd>Neoformat<CR>')

-- python
g.neoformat_enabled_python = {'autopep8'}
g.neoformat_python_autopep8 = {exe = 'autopep8', args = {'--max-line-length=100'}}

-- lua
g.neoformat_enabled_lua = {'luaformat'}
g.neoformat_lua_luaformat = {exe = 'lua-format'}

-- javascript
g.neoformat_enabled_javascript = {'prettier'}

-- typescript
g.neoformat_enabled_typescript = {'prettier'}

-- json
g.neoformat_enabled_json = {'prettier'}

-- yaml
g.neoformat_enabled_yaml = {'prettier'}
g.neoformat_yaml_prettier = {
    exe = 'prettier',
    args = {'--stdin-filepath', '"%:p"', '--tab-width=2'},
    stdin = 1
}

api.nvim_exec([[
    augroup GoFormat
        autocmd!
        autocmd FileType go setlocal noexpandtab
    augroup end

    augroup MakeFileFormat
        autocmd!
        autocmd FileType make setlocal noexpandtab
    augroup end

    augroup PrettierFormat
        autocmd!
        autocmd FileType javascript,typescript,json setlocal noexpandtab
        autocmd FileType yaml setlocal tabstop=2 shiftwidth=2
    augroup end
]], false)

-- editorconfig/editorconfig-vim
g.EditorConfig_exclude_patterns = {'fugitive://.*'}
g.EditorConfig_preserve_formatoptions = 1

-- pseewald/vim-anyfold
g.anyfold_fold_display = 0
g.anyfold_identify_comments = 0
g.anyfold_motion = 0

-- jpalardy/vim-slime
g.slime_target = 'tmux'
g.slime_default_config = {socket_name = vim.split(vim.env.TMUX or '', ',')[1], target_pane = ':.'}
g.slime_no_mappings = 1
g.slime_python_ipython = 1
map('x', '<C-c><C-c>', '<Plug>SlimeRegionSend', {})
map('n', '<C-c><C-c>', '<Plug>SlimeParagraphSend', {})
map('n', '<C-c>v', '<Plug>SlimeConfig', {})
map('n', '<C-c>l', '<Plug>SlimeLineSend', {})

-- plasticboy/vim-markdown
g.vim_markdown_toc_autofit = 1
g.vim_markdown_no_default_key_mappings = 1
g.vim_markdown_emphasis_multiline = 0
g.vim_markdown_edit_url_in = 'current'

-- iamcco/markdown-preview.nvim
g.mkdp_auto_close = 0

-- neoclide/coc.nvim
g.coc_global_extensions = {
    'coc-go', 'coc-html', 'coc-json', 'coc-pyright', 'coc-java', 'coc-rust-analyzer',
    'coc-tsserver', 'coc-vimlsp', 'coc-xml', 'coc-yaml', 'coc-css', 'coc-diagnostic',
    'coc-dictionary', 'coc-markdownlint', 'coc-snippets', 'coc-word'
}
g.coc_enable_locationlist = 0
cmd([[autocmd User CocNvimInit ++once lua require('plugs.coc')]])

-- kkoomen/vim-doge
g.doge_enable_mappings = 0
g.doge_mapping_comment_jump_forward = '<C-j>'
g.doge_mapping_comment_jump_backward = '<C-k>'
map('n', '<leader>dg', '<Cmd>DogeGenerate<CR>')

-- preservim/nerdcommenter
g.NERDCreateDefaultMappings = 0
g.NERDSpaceDelims = 1
g.NERDCompactSexyComs = 1
g.NERDDefaultAlign = 'left'
g.NERDToggleCheckAllLines = 1
g.NERDTrimTrailingWhitespace = 1
g.NERDCustomDelimiters = {lua = {left = '--', leftAlt = '', rightAlt = ''}}
map('n', '<C-_>', '<Plug>NERDCommenterToggle', {})
map('x', '<C-_>', '<Plug>NERDCommenterToggle', {})

-- othree/eregex.vim
g.eregex_default_enable = 0

-- KabbAmine/vCoolor.vim
g.vcoolor_disable_mappings = 1
g.vcoolor_lowercase = 1
map('n', '<leader>pc', '<Cmd>VCoolor<CR>')

-- kevinhwang91/suda.vim
map('n', '<leader>:w', '<Cmd>SudaWrite<CR>')

-- remove ansi color
cmd([[command! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]])

cmd(
    [[command! -nargs=? -complete=buffer FollowSymlink lua require('kutils').follow_symlink(<f-args>)]])

cmd([[command! -nargs=0 CleanEmptyBuf lua require('kutils').clean_empty_buf()]])

api.nvim_exec([[
    augroup RnuColumn
        autocmd!
        autocmd FocusLost * lua require('rnu').focus(false)
        autocmd FocusGained * lua require('rnu').focus(true)
        autocmd WinEnter * lua require('rnu').win_enter()
    augroup END
]], false)

api.nvim_exec([[
    augroup ShadowWindow
        autocmd!
        autocmd WinEnter * lua require('shadowwin').toggle()
    augroup END
]], false)

cmd([[command! Jumps lua require('jumplist').jumps2qf()]])

map('n', '<leader>jj', '<Cmd>Jumps<CR>')

vim.schedule(function()
    vim.defer_fn(function()
        require('plugs.treesitter')
    end, 50)
    vim.defer_fn(function()
        cmd('packadd vim-matchup')
        fn['matchup#loader#init_buffer']()
    end, 200)
    vim.defer_fn(function()
        cmd('packadd vim-gitgutter')
    end, 300)
    vim.defer_fn(function()
        cmd('packadd coc.nvim')
        cmd('packadd tmux-complete.vim')
        cmd('packadd vim-lsp-cxx-highlight')
    end, 500)
end)
