local cmd = vim.cmd
local fn = vim.fn
local uv = vim.loop

local env, g, o = vim.env, vim.g, vim.o

o.nu = true
o.rnu = true
o.cul = true
o.culopt = 'number,screenline'
o.scl = 'yes:1'
o.foldcolumn = '1'
o.foldenable = true
o.list = true
o.ts = 4
o.sw = 4
o.et = true
o.softtabstop = -1
-- o.autoindent = true
o.smartindent = true
o.synmaxcol = 300
o.textwidth = 100
o.clipboard = 'unnamedplus'
-- o.timeout = true
o.timeoutlen = 500
o.ignorecase = true
o.smartcase = true
o.updatetime = 200
-- o.hidden = true
-- o.inccommand = 'nosplit'
o.fileencodings = 'utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1'
o.showmode = false
o.cedit = '<C-x>'
o.listchars = 'tab:▏ ,trail:•,precedes:<,extends:>'
o.sidescrolloff = 5
o.showbreak = '╰─➤ '
o.foldlevelstart = 99
o.title = true
o.titlestring = '%(%m%)%(%{expand(\"%:~\")}%)'
o.lazyredraw = true
o.shortmess = o.shortmess .. 'acsIS'
o.confirm = true
o.jumpoptions = 'stack'
o.diffopt = o.diffopt .. ',vertical,internal,algorithm:patience'
o.shada = [['20,<50,s10,/20,@20,:0,h]]
o.termguicolors = true
o.fillchars = 'eob: '
o.wildoptions = 'pum'
o.winminwidth = 10
o.nrformats = 'octal,hex,bin,unsigned'

-- undo
o.undofile = true
o.undolevels = 1000

-- no backup
o.backup = false
o.swapfile = false

g.loaded_netrwPlugin = 1
-- g.loaded_matchparen = 1
-- g.loaded_matchit = 1
g.loaded_2html_plugin = 1

-- I haven't any remote plugins
g.loaded_remote_plugins = 1

local clipboard
if env.DISPLAY and fn.executable('xsel') == 1 then
    clipboard = {
        name = 'xsel',
        copy = {
            ['+'] = {'xsel', '--nodetach', '-i', '-b'},
            ['*'] = {'xsel', '--nodetach', '-i', '-p'}
        },
        paste = {['+'] = {'xsel', '-o', '-b'}, ['*'] = {'xsel', '-o', '-p'}},
        cache_enabled = true
    }
elseif env.TMUX then
    clipboard = {
        name = 'tmux',
        copy = {['+'] = {'tmux', 'load-buffer', '-w', '-'}},
        paste = {['+'] = {'tmux', 'save-buffer', '-'}},
        cache_enabled = true
    }
    clipboard.copy['*'] = clipboard.copy['+']
    clipboard.paste['*'] = clipboard.paste['+']
elseif fn.executable('osc52send') == 1 then
    clipboard = {
        name = 'osc52send',
        copy = {['+'] = {'osc52send'}},
        paste = {
            ['+'] = function()
                return {fn.getreg('0', 1, true), fn.getregtype('0')}
            end
        },
        cache_enabled = false
    }
    clipboard.copy['*'] = clipboard.copy['+']
    clipboard.paste['*'] = clipboard.paste['+']
end

g.clipboard = clipboard

-- map
-- push parameters to list and defer mapping
local paras_tbl = {}
local function map(mode, lhs, rhs, opts)
    table.insert(paras_tbl, {mode, lhs, rhs, opts})
end

g.mapleader = ' '
map('n', '<Space>', '')
map('x', '<Space>', '')
map('n', 'q', '')
map('x', 'q', '')
map('n', 'Q', '')
map('n', '-', '"_')
map('x', '-', '"_')
map('n', 'qq', [[<Cmd>lua require('builtin').fix_quit()<CR>]])
map('n', 'qa', '<Cmd>qa<CR>')
map('n', 'qt', '<Cmd>tabc<CR>')
map('n', 'qc', [[<Cmd>lua require('qf').close()<CR>]])
map('n', 'qd', [[<Cmd>lua require('kutils').close_diff()<CR>]])
map('n', 'qD', [[<Cmd>tabdo lua require('kutils').close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]])

map('n', 's', 'd')
map('x', 's', 'd')
map('o', 's', 'd')
map('n', 'd', '<C-d>')
map('x', 'd', '<C-d>')
map('n', 'u', '<C-u>')
map('x', 'u', '<C-u>')
map('n', '<C-u>', 'u')

map('n', 'y', [[v:lua.require'yank'.wrap()]], {noremap = true, expr = true})
map('n', 'yw', [[v:lua.require'yank'.wrap('iw')]], {noremap = true, expr = true})
map('n', 'yW', [[v:lua.require'yank'.wrap('iW')]], {noremap = true, expr = true})
map('n', 'Y', 'y$')
map('n', 'v', 'm`v')
map('n', 'V', 'm`V')
map('n', '<C-v>', 'm`<C-v>')
map('x', 'p', [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])
map('x', 'P', [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])
map('n', '<Leader>v', [['`[' . strpart(getregtype(), 0, 1) . '`]']], {noremap = true, expr = true})
map('n', '<Leader>2;', '@:')
map('x', '<Leader>2;', '@:')
map('n', '<Leader>3', [[<Cmd>lua require('builtin').switch_lastbuf()<CR>]])
map('n', '<Leader>w', '<Cmd>up<CR>')
map('n', '<Leader>;w', '<Cmd>wq<CR>')
map('n', '<C-g>', '2<C-g>')
map('n', '<Leader>l', ':noh<CR>')
map('n', '<C-l>', '<C-l>')
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
map('n', '<C-w>s', [[<Cmd>lua require('builtin').split_lastbuf()<CR>]])
map('n', '<C-w>v', [[<Cmd>lua require('builtin').split_lastbuf(true)<CR>]])
map('n', '<C-w>O', '<Cmd>tabo<CR>')
map('n', '<C-w>;', [[<Cmd>lua require('win').go2recent()<CR>]])

map('n', '<M-a>', 'VggoG')
map('i', '<M-;>', '<END>')

map('n', 'k', [[(v:count > 1 ? 'm`' . v:count : '') . 'k']], {noremap = true, expr = true})
map('n', 'j', [[(v:count > 1 ? 'm`' . v:count : '') . 'j']], {noremap = true, expr = true})

map('n', 'U', [[<Cmd>execute('earlier ' . v:count1 . 'f')<CR>]], {noremap = true, silent = false})
map('n', '<M-r>', [[<Cmd>execute('later ' . v:count1 . 'f')<CR>]], {noremap = true, silent = false})

map('n', [[']], [[`]])
map('x', [[']], [[`]])
map('o', [[']], [[`]])
map('n', [[`]], [[']])
map('x', [[`]], [[']])
map('o', [[`]], [[']])

map('n', '<Leader>i', '<Cmd>sil! norm! `^<CR>')

map('n', '<M-j>', '<Cmd>m +1<CR>')
map('n', '<M-k>', '<Cmd>m -2<CR>')
map('i', '<M-j>', '<C-o><Cmd>m +1<CR>')
map('i', '<M-k>', '<C-o><Cmd>m -2<CR>')
map('x', '<M-j>', [[:m '>+1<CR>gv=gv]])
map('x', '<M-k>', [[:m '<-2<CR>gv=gv]])

map('n', 'cc', [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], {noremap = true, expr = true})
map('n', '0', [[v:lua.require'builtin'.jump0()]], {noremap = true, expr = true})
map('x', '0', [[v:lua.require'builtin'.jump0()]], {noremap = true, expr = true})
map('o', '0', [[v:lua.require'builtin'.jump0()]], {noremap = true, expr = true})

map('n', 'yd', [[<Cmd>lua require('yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>]])
map('n', 'yn', [[<Cmd>lua require('yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>]])
map('n', 'yp', [[<Cmd>lua require('yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>]])

map('n', '[', [[v:lua.require'builtin'.prefix_timeout('[')]], {noremap = true, expr = true})
map('x', '[', [[v:lua.require'builtin'.prefix_timeout('[')]], {noremap = true, expr = true})
map('n', ']', [[v:lua.require'builtin'.prefix_timeout(']')]], {noremap = true, expr = true})
map('x', ']', [[v:lua.require'builtin'.prefix_timeout(']')]], {noremap = true, expr = true})
map('n', '[b', [[<Cmd>execute(v:count1 . 'bp')<CR>]])
map('n', ']b', [[<Cmd>execute(v:count1 . 'bn')<CR>]])
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
map('n', 'z', [[v:lua.require'builtin'.prefix_timeout('z')]], {noremap = true, expr = true})
map('x', 'z', [[v:lua.require'builtin'.prefix_timeout('z')]], {noremap = true, expr = true})

map('n', 'za', [[<Cmd>lua require('plugs.fold').with_highlight('a')<CR>]])
map('n', 'zA', [[<Cmd>lua require('plugs.fold').with_highlight('A')<CR>]])
map('n', 'zo', [[<Cmd>lua require('plugs.fold').with_highlight('o')<CR>]])
map('n', 'zO', [[<Cmd>lua require('plugs.fold').with_highlight('O')<CR>]])
map('n', 'zv', [[<Cmd>lua require('plugs.fold').with_highlight('v')<CR>]])

map('n', 'z[', [[<Cmd>lua require('plugs.fold').nav_fold(false)<CR>]])
map('n', 'z]', [[<Cmd>lua require('plugs.fold').nav_fold(true)<CR>]])

map('x', 'iz', [[:<C-u>keepj norm [zv]zg_<CR>]])
map('o', 'iz', [[:norm viz<CR>]])

map('x', 'if', [[:<C-u>lua require('plugs.textobj').select('func', true, true)<CR>]])
map('x', 'af', [[:<C-u>lua require('plugs.textobj').select('func', false, true)<CR>]])
map('o', 'if', [[<Cmd>lua require('plugs.textobj').select('func', true)<CR>]])
map('o', 'af', [[<Cmd>lua require('plugs.textobj').select('func', false)<CR>]])

map('x', 'ik', [[:<C-u>lua require('plugs.textobj').select('class', true, true)<CR>]])
map('x', 'ak', [[:<C-u>lua require('plugs.textobj').select('class', false, true)<CR>]])
map('o', 'ik', [[<Cmd>lua require('plugs.textobj').select('class', true)<CR>]])
map('o', 'ak', [[<Cmd>lua require('plugs.textobj').select('class', false)<CR>]])

map('n', '<M-C-l>', [[<Cmd>lua require('plugs.format').format_doc()<CR>]])
map('x', '<M-C-l>', [[:lua require('plugs.format').format_selected(vim.fn.visualmode())<CR>]])

require('dev')
require('reg')
require('mru')
require('stl')
require('qf')

local conf_dir = fn.stdpath('config')
if uv.fs_stat(conf_dir .. '/plugin/packer_compiled.lua') then
    local packer_loader_complete = [[customlist,v:lua.require'packer'.loader_complete]]
    cmd(([[
        com! PackerInstall lua require('plugs.packer').install()
        com! PackerUpdate lua require('plugs.packer').update()
        com! PackerSync lua require('plugs.packer').sync()
        com! PackerClean lua require('plugs.packer').clean()
        com! PackerStatus lua require('plugs.packer').status()
        com! -nargs=? PackerCompile lua require('plugs.packer').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugs.packer').loader(<f-args>)
    ]]):format(packer_loader_complete))
else
    require('plugs.packer').compile()
end

local theme = 'one'
if not pcall(cmd, ('color %s'):format(theme)) then
    require('plugs.lush').dump(theme)
end

-- junegunn/fzf.vim
-- `pacman -S fzf` will force nvim load plugin in /usr/share/vim/vimfiles/plugin/fzf.vim
g.loaded_fzf = true
local fzf_opts = env.FZF_DEFAULT_OPTS
if fzf_opts then
    env.FZF_DEFAULT_OPTS = fzf_opts .. ' --reverse --info=inline --border'
end
env.BAT_STYLE = 'numbers'
map('n', '<Leader>f', '')
map('n', '<Leader>fz', '<Cmd>FZF<CR>')
map('n', '<Leader>fm', '<Cmd>Marks<CR>')
map('n', '<Leader>fo', '<Cmd>Tags<CR>')
map('n', '<Leader>f/', '<Cmd>History/<CR>')
map('n', '<Leader>fc', [[<Cmd>lua require('gittool').root_exe('BCommits')<CR>]])
map('n', '<Leader>fg', [[<Cmd>lua require('gittool').root_exe('GFiles')<CR>]])
map('n', '<Leader>ff', [[<Cmd>lua require('gittool').root_exe(require('plugs.fzf').files)<CR>]])
map('n', '<Leader>f,', [[<Cmd>lua require('gittool').root_exe('Rg')<CR>]])
map('n', '<Leader>f;', [[<Cmd>lua require('plugs.fzf').cmdhist()<CR>]])

cmd([[
    aug Fzf
        au!
        au FuncUndefined fzf#* lua require('plugs.fzf')
        au CmdUndefined FZF,BCommits,History,GFiles,Marks,Buffers,Rg lua require('plugs.fzf')
    aug END

    com! -nargs=* -bar -bang Maps call fzf#vim#maps(<q-args>, <bang>0)
    com! -bar -bang Helptags call fzf#vim#helptags(<bang>0)
]])

-- qf extension
map('n', '<Leader>ft', [[<Cmd>lua require('plugs.qfext').outline()<CR>]])

-- Man
g.no_man_maps = 1
cmd([[cabbrev man <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Man' : 'man')<CR>]])

-- kevinhwang91/rnvimr
g.rnvimr_enable_ex = 1
-- g.rnvimr_enable_picker = 1
g.rnvimr_enable_bw = 1
g.rnvimr_hide_gitignore = 1
g.rnvimr_border_attr = {fg = 3}
g.rnvimr_ranger_cmd = 'ranger'
g.rnvimr_shadow_winblend = 70
g.rnvimr_edit_cmd = 'drop'
g.rnvimr_action = {
    ['<C-t>'] = 'NvimEdit tab drop',
    ['<C-s>'] = 'NvimEdit split true',
    ['<C-v>'] = 'NvimEdit vsplit true',
    ['<C-o>'] = 'NvimEdit drop true',
    gw = 'JumpNvimCwd',
    yw = 'EmitRangerCwd'
}
g.rnvimr_ranger_views = {
    {minwidth = 90, ratio = {}}, {minwidth = 50, maxwidth = 89, ratio = {1, 1}},
    {maxwidth = 49, ratio = {1}}
}

cmd('hi! link RnvimrNormal CursorLine')
cmd([[
    aug RnvimrKeyMap
        au!
        au FileType rnvimr tnoremap <silent><buffer> <M-i> <Cmd>RnvimrResize<CR>
        au FileType rnvimr tnoremap <silent><buffer> <M-o> <Cmd>RnvimrToggle<CR>
    aug END
]])
map('n', '<M-o>', '<Cmd>RnvimrToggle<CR>')

-- tpope/vim-repeat
map('n', '<Plug>DummyRepeatUndo', '<Plug>(RepeatUndo)', {})
map('n', '<Plug>DummyRepeatRedo', '<Plug>(RepeatRedo)', {})

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
map('n', '<Leader>gd', ':tab Gdiffsplit<Space>', {silent = false})
map('n', '<Leader>gt', ':Git difftool -y<Space>', {silent = false})

-- rbong/vim-flog
map('n', '<Leader>gl', '<Cmd>Flog<CR>')
map('n', '<Leader>gf', [[<Cmd>lua require('plugs.flog').cur_file()<CR>]])

-- rhysd/git-messenger.vim
g.git_messenger_no_default_mappings = 0
g.git_messenger_always_into_popup = 1
g.git_messenger_date_format = '%Y-%m-%d %H:%M:%S'
map('n', '<Leader>gm', '<Cmd>GitMessenger<CR>')

-- plasticboy/vim-markdown
g.vim_markdown_toc_autofit = 1
g.vim_markdown_no_default_key_mappings = 1
g.vim_markdown_folding_disabled = 1
g.vim_markdown_emphasis_multiline = 0
g.vim_markdown_edit_url_in = 'current'

-- sakhnik/nvim-gdb
g.nvimgdb_disable_start_keymaps = 1
map('n', '<Leader>dd', ':GdbStart gdb -q<Space>', {silent = false})
map('n', '<Leader>dp', ':GdbStartPDB python -m pdb<Space>', {silent = false})

-- preservim/nerdcommenter
g.NERDCreateDefaultMappings = 0
g.NERDSpaceDelims = 1
g.NERDCompactSexyComs = 1
g.NERDDefaultAlign = 'left'
g.NERDToggleCheckAllLines = 1
g.NERDTrimTrailingWhitespace = 1
g.NERDCustomDelimiters = {lua = {left = '--', leftAlt = '', rightAlt = ''}}
g.NERDAltDelims_c = 1
g.NERDAltDelims_cpp = 1

map('', '<C-_>', '<Plug>NERDCommenterToggle', {})

map('n', '<Leader>jj', '<Cmd>Jumps<CR>')

-- notify
vim.notify = function(...)
    cmd('PackerLoad nvim-notify')
    vim.notify = require('notify')
    vim.notify(...)
end

cmd([[
    com! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g
    com! -nargs=? -complete=buffer FollowSymlink lua require('kutils').follow_symlink(<f-args>)
    com! -nargs=0 CleanEmptyBuf lua require('kutils').clean_empty_bufs()
    com! -nargs=0 Jumps lua require('builtin').jumps2qf()

    aug RnuColumn
        au!
        au FocusLost * lua require('rnu').focus(false)
        au FocusGained * lua require('rnu').focus(true)
        au WinEnter * lua require('rnu').win_enter()
        au CmdlineEnter /,\? lua require('rnu').scmd_enter()
        au CmdlineLeave /,\? lua require('rnu').scmd_leave()
    aug END

    aug TermFix
        au!
        au TermEnter * lua vim.schedule(function() vim.cmd('noh') vim.fn.clearmatches() end)
    aug END

    aug GoFormat
        au!
        au FileType go setl noexpandtab
    aug END

    aug MakeFileFormat
        au!
        au FileType make setl noexpandtab
    aug END

    aug PrettierFormat
        au!
        au FileType javascript,typescript,json,jsonc setl noexpandtab
        au FileType yaml setl tabstop=2 shiftwidth=2
    aug END

    aug FirstBuf
        au!
        au BufHidden <buffer> ++once lua require('builtin').wipe_empty_buf()
    aug END

    aug MruWin
        au!
        au WinLeave * lua require('win').record()
    aug END
]])

require('plugs.manual')

cmd([[
    filetype off
    let g:did_load_filetypes = 0
]])

-- defer loading
g.loaded_clipboard_provider = 1

vim.schedule(function()
    vim.defer_fn(function()
        local m = require('remap').map
        for _, paras in ipairs(paras_tbl) do
            m(unpack(paras))
        end
    end, 10)

    vim.defer_fn(function()
        require('plugs.treesitter')

        cmd([[
            unlet g:did_load_filetypes
            runtime! filetype.vim
            au! syntaxset
            au syntaxset FileType * lua require('plugs.treesitter').hijack_synset()
            filetype on
            doautoall filetypedetect BufRead
        ]])
    end, 20)

    vim.defer_fn(function()
        g.loaded_clipboard_provider = nil
        cmd('runtime autoload/provider/clipboard.vim')

        if fn.exists('##ModeChanged') == 1 then
            cmd([[
                aug SelectModeNoYank
                    au!
                    au ModeChanged *:s set clipboard=
                    au ModeChanged s:* set clipboard=unnamedplus
                aug END
            ]])
        else
            cmd('pa nvim-hclipboard')
            require('hclipboard').start()
        end

        cmd([[
            aug Packer
                au!
                au BufWritePost */plugs/packer.lua so <afile> | PackerCompile
            aug END

            aug LushTheme
                au!
                au BufWritePost */lua/lush_theme/*.lua lua require('plugs.lush').write_post()
            aug END

            aug CmdHist
                au!
                au CmdlineEnter : lua require('cmdhist')
            aug END

            aug CmdHijack
                au!
                au CmdlineEnter : lua require('cmdhijack')
            aug END
        ]])

        -- highlight syntax
        if fn.exists('##SearchWrapped') == 1 then
            cmd([[
                aug SearchWrappedHighlight
                    au!
                    au SearchWrapped * lua require('builtin').search_wrap()
                aug END
            ]])
        end

        cmd(([[
            aug LuaHighlight
                au!
                au TextYankPost * lua if not vim.b.visual_multi then %s end
            aug END
        ]]):format([[pcall(vim.highlight.on_yank, {higroup='IncSearch', timeout=400})]]))

        local all_hexokinase_pat = {
            'full_hex', 'triple_hex', 'rgb', 'rgba', 'hsl', 'hsla', 'colour_names'
        }
        g.Hexokinase_highlighters = {'backgroundfull'}
        g.Hexokinase_refreshEvents = {'BufRead', 'TextChanged', 'InsertLeave'}
        g.Hexokinase_ftOptOutPatterns = {css = all_hexokinase_pat, scss = all_hexokinase_pat}
        g.Hexokinase_termDisabled = 1
        cmd('pa vim-hexokinase')
        cmd('doautoall hexokinase_autocmds BufRead')
    end, 200)

    vim.defer_fn(function()
        g.coc_global_extensions = {
            'coc-clangd', --
            'coc-css', --
            'coc-dictionary', --
            'coc-eslint', --
            'coc-go', --
            'coc-html', --
            'coc-java', --
            'coc-json', --
            'coc-markdownlint', --
            'coc-pyright', --
            'coc-rust-analyzer', --
            'coc-snippets', --
            'coc-sql', --
            'coc-tsserver', --
            'coc-vimlsp', --
            'coc-word', --
            'coc-xml', --
            'coc-yaml' --
        }
        g.coc_enable_locationlist = 0
        g.coc_selectmode_mapping = 0
        cmd([[
            au User CocNvimInit ++once lua require('plugs.coc').initialize()
            hi! link CocSemDefaultLibrary Special
            hi! link CocSemDocumentation Number
            hi! CocSemStatic gui=bold
        ]])
        cmd('pa coc-kvs')
        cmd('pa coc.nvim')
    end, 300)

    vim.defer_fn(function()
        require('plugs.fold')
    end, 800)
end)
