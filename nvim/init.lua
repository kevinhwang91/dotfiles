local cmd = vim.cmd
local fn = vim.fn

local g, o, wo, bo = vim.g, vim.o, vim.wo, vim.bo
local map = require('remap').map

-- source filetype.vim later
g.did_load_filetypes = 1
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
o.shortmess = o.shortmess .. 'acIS'
o.confirm = true
o.jumpoptions = 'stack'
o.diffopt = o.diffopt .. ',vertical,internal,algorithm:patience'
o.shada = [[!,'10,<50,s10,/100,@1000,h]]
o.termguicolors = true

-- undo
bo.undofile = true
o.undofile = bo.undofile
o.undolevels = 1000

-- no backup
o.backup = false
bo.swapfile = false
o.swapfile = bo.swapfile

g.loaded_netrwPlugin = 1
g.loaded_matchparen = 1
g.loaded_matchit = 1
g.loaded_2html_plugin = 1

-- I haven't any remote plugins
g.loaded_remote_plugins = 1

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
        cache_enabled = false
    }
elseif fn.executable('osc52send') then
    g.clipboard = {
        name = 'osc52send',
        copy = {['+'] = 'osc52send', ['*'] = 'osc52send'},
        paste = {['+'] = '', ['*'] = ''},
        cache_enabled = false
    }
    cmd([[
        let g:clipboard.paste['+'] = {-> [getreg('"', 1, 1), getregtype('"')]}
        let g:clipboard.paste['*'] = g:clipboard.paste['+']
    ]])
end

-- map
g.mapleader = ' '
map('n', '<Space>', '')
map('x', '<Space>', '')
map('n', 'q', '')
map('x', 'q', '')
map('n', 'Q', '')
map('n', '-', '"_')
map('x', '-', '"_')
map('n', 'y', [[v:lua._G.yank()]], {noremap = true, expr = true})
map('n', 'Y', 'y$')
map('n', 'v', 'm`v')
map('n', 'V', 'm`V')
map('n', '<Leader>2;', '@:')
map('x', '<Leader>2;', '@:')
map('n', 'qq', '<Cmd>q<CR>')
map('n', 'qa', '<Cmd>qa<CR>')
map('n', 'qt', '<Cmd>tabc<CR>')
map('n', 'qc', '<Cmd>ccl<CR>')
map('n', 'qs', '<Cmd>lcl<CR>')
map('n', 'qd', [[<Cmd>lua require('kutils').close_diff()<CR>]])
map('n', 'qD', [[<Cmd>tabdo lua require('kutils').close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]])
map('n', '<Leader>w', '<Cmd>up<CR>')
map('n', '<Leader>;w', '<Cmd>wq<CR>')
map('n', '<C-g>', '1<C-g>')
map('n', '<Leader>l', ':noh<CR>')
map('c', '<C-b>', '<Left>')
map('c', '<C-f>', '<Right>')
map('c', '<C-a>', '<Home>')
map('c', '<C-d>', '<Del>')
map('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]])
map('c', '<M-b>', '<C-Left>')
map('c', '<M-f>', '<C-Right>')
map('c', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})
map('t', [[<M-\>]], [[<C-\><C-n>]])

map('n', '<C-w><C-t>', '<Cmd>tab sp<CR>')
map('n', '<Leader>3', '<Cmd>b #<CR>')
map('n', '<C-w>s', [[<Cmd>lua require('bultin').split_lastbuf()<CR>]])
map('n', '<C-w>v', [[<Cmd>lua require('bultin').split_lastbuf(true)<CR>]])
map('n', '<C-w>O', '<Cmd>tabo<CR>')

map('n', '<M-a>', 'VggoG')
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
map('n', [[m`]], [[m']])
map('x', [[m`]], [[m']])

map('n', [['0]], [[<Cmd>norm! `0<CR><Cmd>sil! CleanEmptyBuf<CR>]])
map('n', '<Leader>i', '<Cmd>sil! norm! `^<CR>')

map('n', '<M-j>', '<Cmd>m +1<CR>')
map('n', '<M-k>', '<Cmd>m -2<CR>')
map('i', '<M-j>', '<C-o><Cmd>m +1<CR>')
map('i', '<M-k>', '<C-o><Cmd>m -2<CR>')
map('x', '<M-j>', [[:m '>+1<CR>gv=gv]])
map('x', '<M-k>', [[:m '<-2<CR>gv=gv]])
map('n', 'yd', [[<Cmd>call setreg(v:register, expand('%:p:h'))<CR>:echo expand('%:p:h')<CR>]])
map('n', 'yn', [[<Cmd>call setreg(v:register, expand('%:t'))<CR>:echo expand('%:t')<CR>]])
map('n', 'yp', [[<Cmd>call setreg(v:register, expand('%:p'))<CR>:echo expand('%:p')<CR>]])
map('n', 'Y', 'y$')

map('n', '[', [[v:lua._G.prefix_timeout('[')]], {noremap = true, expr = true})
map('x', '[', [[v:lua._G.prefix_timeout('[')]], {noremap = true, expr = true})
map('n', ']', [[v:lua._G.prefix_timeout(']')]], {noremap = true, expr = true})
map('x', ']', [[v:lua._G.prefix_timeout(']')]], {noremap = true, expr = true})
map('n', '[b', '<Cmd>bp<CR>')
map('n', ']b', '<Cmd>bn<CR>')
map('n', '[q', [[<Cmd>execute(v:count1 . 'cp')<CR>]])
map('n', ']q', [[<Cmd>execute(v:count1 . 'cn')<CR>]])
map('n', '[Q', '<Cmd>cfir<CR>')
map('n', ']Q', '<Cmd>cla<CR>')
map('n', '[s', [[<Cmd>execute(v:count1 . 'lp')<CR>]])
map('n', ']s', [[<Cmd>execute(v:count1 . 'lne')<CR>]])
map('n', '[S', '<Cmd>lfir<CR>')
map('n', ']S', '<Cmd>lla<CR>')
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

map('n', 'z[', [[<Cmd>lua require('kutils').nav_fold(false, vim.v.count1)<CR>]])
map('n', 'z]', [[<Cmd>lua require('kutils').nav_fold(true, vim.v.count1)<CR>]])

map('x', 'iz', [[:<C-U>keepj norm [zv]zg_<CR>]])
map('o', 'iz', [[:norm viz<CR>]])

-- https://github.com/neovim/neovim/issues/13862
function _G.yank()
    return require('yank').wrap()
end

function _G.prefix_timeout(prefix)
    local char = fn.getchar(0)
    if type(char) == 'number' then
        char = fn.nr2char(char)
    end
    return char == '' and [[\<Ignore>]] or prefix .. char
end

require('mru')
require('stl')

if fn.glob(fn.stdpath('config') .. '/plugin/packer_compiled.vim') == '' then
    require('plugs.packer').compile()
else
    cmd([[
        com! PackerInstall lua require('plugs.packer').install()
        com! PackerUpdate lua require('plugs.packer').update()
        com! PackerSync lua require('plugs.packer').sync()
        com! PackerClean lua require('plugs.packer').clean()
        com! PackerCompile lua require('plugs.packer').compile()
        com! PackerStatus lua require('plugs.packer').status()
    ]])
end

cmd([[
    aug Packer
        au!
        au BufWritePost */plugs/packer.lua call execute(['luafile ' . expand('<afile>'), 'PackerCompile'])
    aug END
]])

pcall(cmd, 'color one')

-- junegunn/fzf.vim
-- `pacman -S fzf` will force nvim load plugin in /usr/share/vim/vimfiles/plugin/fzf.vim
vim.g.loaded_fzf = true
vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. ' --reverse --info=inline --border'
vim.env.BAT_STYLE = 'numbers'
map('n', '<Leader>f', '')
map('n', '<Leader>ft', '<Cmd>BTags<CR>')
map('n', '<Leader>fo', '<Cmd>Tags<CR>')
map('n', '<Leader>fc', '<Cmd>BCommits<CR>')
map('n', '<Leader>f/', '<Cmd>History/<CR>')
map('n', '<Leader>f;', '<Cmd>History:<CR>')
map('n', '<Leader>fg', '<Cmd>GFiles<CR>')
map('n', '<Leader>fm', '<Cmd>Marks<CR>')
map('n', '<Leader>ff', '<Cmd>FZF<CR>')
map('n', '<Leader>fb', '<Cmd>Buffers<CR>')
map('n', '<Leader>fr', [[<Cmd>lua require('plugs.fzf').mru()<CR>]])

cmd([[
    aug Fzf
        au!
        au FuncUndefined fzf#* lua require('plugs.fzf')
        au CmdUndefined FZF,BTags,BCommits,History,GFiles,Marks,Buffers,Rg lua require('plugs.fzf')
    aug END

    com! -nargs=* -bar -bang Maps call fzf#vim#maps(<q-args>, <bang>0)
    com! -bar -bang Helptags call fzf#vim#helptags(<bang>0)
]])


-- kevinhwang91/rnvimr
g.rnvimr_enable_ex = 1
g.rnvimr_enable_bw = 1
g.rnvimr_hide_gitignore = 1
g.rnvimr_border_attr = {fg = 3}
g.rnvimr_ranger_cmd = 'ranger'
g.rnvimr_action = {
    ['<C-t>'] = 'NvimEdit tabedit',
    ['<C-s>'] = 'NvimEdit split',
    ['<C-v>'] = 'NvimEdit vsplit',
    ['<C-o>'] = 'NvimEdit drop true',
    gw = 'JumpNvimCwd',
    yw = 'EmitRangerCwd'
}
g.rnvimr_ranger_views = {
    {minwidth = 90, ratio = {}}, {minwidth = 50, maxwidth = 89, ratio = {1, 1}},
    {maxwidth = 49, ratio = {1}}
}

cmd('hi link RnvimrNormal CursorLine')
map('t', '<M-i>', [[<C-\><C-n><Cmd>RnvimrResize<CR>]])
map('t', '<M-o>', [[<C-\><C-n><Cmd>RnvimrToggle<CR>]])
map('n', '<M-o>', '<Cmd>RnvimrToggle<CR>')

-- tpope/vim-repeat
map('n', 'U', '<Plug>(RepeatUndo)', {})

-- wellle/targets.vim
g.targets_aiAI = 'aIAi'
g.targets_seekRanges =
    'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
g.targets_jumpRanges = g.targets_seekRanges
g.targets_nl = 'nm'
map('o', 'I', [[targets#e('o', 'i', 'I')]], {expr = true})
map('x', 'I', [[targets#e('o', 'i', 'I')]], {expr = true})
map('o', 'a', [[targets#e('o', 'a', 'a')]], {expr = true})
map('x', 'a', [[targets#e('o', 'a', 'a')]], {expr = true})
map('o', 'i', [[targets#e('o', 'I', 'i')]], {expr = true})
map('x', 'i', [[targets#e('o', 'I', 'i')]], {expr = true})
map('o', 'A', [[targets#e('o', 'A', 'A')]], {expr = true})
map('x', 'A', [[targets#e('o', 'A', 'A')]], {expr = true})

-- highlight syntax
cmd([[
    aug LuaHighlight
        au!
        au TextYankPost * lua if not vim.b.visual_multi then vim.highlight.on_yank({higroup='IncSearch', timeout=800}) end
    aug END
]])

-- mbbill/undotree
g.undotree_WindowLayout = 3
map('n', '<M-u>', '<Cmd>UndotreeToggle<CR>')
cmd([[com! -nargs=0 UndotreeToggle lua require('plugs.undotree').toggle()]])

-- tpope/vim-fugitive
map('n', '<Leader>gg', [[<Cmd>lua require('plugs.fugitive').index()<CR>]])
map('n', '<Leader>gc', ':Git commit<Space>', {silent = false})
map('n', '<Leader>gC', ':Git commit --amend<Space>', {silent = false})
map('n', '<Leader>ge', '<Cmd>Gedit<CR>')
map('n', '<Leader>gb', '<Cmd>Git blame -w<Bar>winc p<CR>')
map('n', '<Leader>gw', [[<Cmd>lua require('kutils').follow_symlink()<CR><Cmd>Gwrite<CR>]])
map('n', '<Leader>gr',
    [[<Cmd>lua require('kutils').follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>]])
map('n', '<Leader>gd', ':Gdiffsplit!<Space>', {silent = false})
map('n', '<Leader>gt', ':Git difftool -y<Space>', {silent = false})

-- rbong/vim-flog
g.flog_default_arguments = {max_count = 1000}
map('n', '<Leader>gl', '<Cmd>Flog<CR>')
map('n', '<Leader>gf', '<Cmd>Flog -path=%<CR>')

-- rhysd/git-messenger.vim
g.git_messenger_no_default_mappings = 0
g.git_messenger_always_into_popup = 1
map('n', '<Leader>gm', '<Cmd>GitMessenger<CR>')

-- sbdchd/neoformat
map('n', '<M-C-l>', '<Cmd>Neoformat<CR>')

-- plasticboy/vim-markdown
g.vim_markdown_toc_autofit = 1
g.vim_markdown_no_default_key_mappings = 1
g.vim_markdown_folding_disabled = 1
g.vim_markdown_emphasis_multiline = 0
g.vim_markdown_edit_url_in = 'current'

-- sakhnik/nvim-gdb
map('n', '<Leader>dd', ':GdbStart gdb -q<Space>', {silent = false})
map('n', '<Leader>dp', ':GdbStartPDB python -m pdb<Space>', {silent = false})

-- neoclide/coc.nvim
g.coc_global_extensions = {
    'coc-clangd', 'coc-go', 'coc-html', 'coc-json', 'coc-pyright', 'coc-java', 'coc-rust-analyzer',
    'coc-tsserver', 'coc-vimlsp', 'coc-xml', 'coc-yaml', 'coc-css', 'coc-diagnostic',
    'coc-dictionary', 'coc-markdownlint', 'coc-snippets', 'coc-word'
}
g.coc_enable_locationlist = 0
map('i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"]], {noremap = true, expr = true})
cmd([[au User CocNvimInit ++once lua require('plugs.coc')]])

-- kkoomen/vim-doge
g.doge_enable_mappings = 0
g.doge_mapping_comment_jump_forward = '<C-j>'
g.doge_mapping_comment_jump_backward = '<C-k>'
map('n', '<Leader>dg', '<Cmd>DogeGenerate<CR>')

-- preservim/nerdcommenter
g.NERDCreateDefaultMappings = 0
g.NERDSpaceDelims = 1
g.NERDCompactSexyComs = 1
g.NERDDefaultAlign = 'left'
g.NERDToggleCheckAllLines = 1
g.NERDTrimTrailingWhitespace = 1
g.NERDCustomDelimiters = {lua = {left = '--', leftAlt = '', rightAlt = ''}}
map('', '<C-_>', '<Plug>NERDCommenterToggle', {})

cmd([[
    com! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g
    com! -nargs=? -complete=buffer FollowSymlink lua require('kutils').follow_symlink(<f-args>)
    com! -nargs=0 CleanEmptyBuf lua require('kutils').clean_empty_bufs()
    com! -nargs=0 Kill2Spaces lua require('kutils').kill2spaces()
    com! -nargs=0 Jumps lua require('bultin').jumps2qf()
]])
map('n', '<Leader>2p', '<Cmd>Kill2Spaces<CR>')

cmd([[
    aug RnuColumn
        au!
        au FocusLost * lua require('rnu').focus(false)
        au FocusGained * lua require('rnu').focus(true)
        au WinEnter * lua require('rnu').win_enter()
        au CmdlineEnter [/\?] lua require('rnu').scmd_enter()
        au CmdlineLeave [/\?] lua require('rnu').scmd_leave()
    aug END

    aug ShadowWindow
        au!
        au WinEnter * lua require('shadowwin').toggle()
    aug END

    aug TermFix
        au!
        au TermEnter * call clearmatches()
    aug END
]])

map('n', '<Leader>jj', '<Cmd>Jumps<CR>')

require('plugs.manual')

vim.schedule(function()
    vim.defer_fn(function()
        g.did_load_filetypes = nil
        cmd('filetype on')
        cmd('doautoall filetypedetect BufRead')
    end, 30)

    vim.defer_fn(function()
        require('plugs.treesitter')
        require('plugs.fold')
    end, 50)

    vim.defer_fn(function()
        require('plugs.config').matchup()
        cmd('pa vim-matchup')
        fn['matchup#loader#init_buffer']()
        fn['matchup#loader#bufwinenter']()

        local all_hexokinase_pat = {
            'full_hex', 'triple_hex', 'rgb', 'rgba', 'hsl', 'hsla', 'colour_names'
        }
        g.Hexokinase_highlighters = {'backgroundfull'}
        g.Hexokinase_refreshEvents = {'BufRead', 'TextChanged', 'InsertLeave'}
        g.Hexokinase_ftOptOutPatterns = {css = all_hexokinase_pat, scss = all_hexokinase_pat}
        g.Hexokinase_termDisabled = 1
        cmd('pa vim-hexokinase')
        cmd('HexokinaseTurnOn')
    end, 200)

    vim.defer_fn(function()
        cmd('pa tmux-complete.vim')
        cmd('pa coc.nvim')
    end, 500)
end)
