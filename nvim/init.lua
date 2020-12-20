-- WIP
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local kmap = vim.api.nvim_set_keymap
local kbmap = vim.api.nvim_buf_set_keymap
local kumap = vim.api.nvim_del_keymap
local kbumap = vim.api.nvim_buf_del_keymap

cmd('syntax enable')
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.cursorline = true
vim.wo.signcolumn = 'yes:1'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = -1
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.clipboard = 'unnamedplus'
vim.o.timeout = true
vim.o.timeoutlen = 500
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 200
vim.o.hidden = true
vim.o.fileencodings = 'utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1'
vim.o.showmode = false
vim.o.cedit = '<C-x>'
vim.o.list = true
vim.o.listchars = 'tab:│ ,trail:•'
vim.o.showbreak = '╰─➤'
vim.o.foldenable = true
vim.o.foldcolumn = '1'
vim.o.foldlevelstart = 99
vim.o.title = true
vim.o.titlestring = '%(%m%)%(%{expand(\"%:~\")}%)'
vim.o.history = 10000
vim.o.lazyredraw = true
vim.o.inccommand = 'nosplit'
vim.o.shortmess = vim.o.shortmess .. 'aIc'
vim.o.shada = [[!,'20,<50,s10,h]]
vim.o.synmaxcol = 300
vim.o.textwidth = 100

-- undo
vim.o.undofile = true
vim.o.undolevels = 1000

-- no backup
vim.o.backup = false
vim.o.swapfile = false

if fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
    vim.o.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20'
end

-- harcode for reducing startup time
vim.g.python3_host_prog = '/usr/bin/python3'
if os.getenv('DISPLAY') and fn.executable('xsel') then
    vim.g.clipboard = {
        name = 'xsel',
        copy = {['+'] = 'xsel --nodetach -i -b', ['*'] = 'xsel --nodetach -i -b'},
        paste = {['+'] = 'xsel -o -b', ['*'] = 'xsel -o -b'},
        cache_enabled = true
    }
elseif os.getenv('TMUX') then
    vim.g.clipboard = {
        name = 'tmux',
        copy = {['+'] = 'tmux load-buffer -', ['*'] = 'tmux load-buffer -'},
        paste = {['+'] = 'tmux save-buffer -', ['*'] = 'tmux save-buffer -'},
        cache_enabled = true
    }
elseif fn.executable('osc52send') then
    vim.g.clipboard = {
        name = 'osc52send',
        copy = {['+'] = 'osc52send', ['*'] = 'osc52send'},
        paste = {['+'] = '', ['*'] = ''},
        cache_enabled = true
    }
end

-- map
vim.g.mapleader = ' '

kmap('n', '<Space>', '', {noremap = true})
kmap('x', '<Space>', '', {noremap = true})
kmap('n', 'q', '', {noremap = true})
kmap('n', 'Q', '', {noremap = true})
kmap('n', '-', '"_', {noremap = true})
kmap('x', '-', '"_', {noremap = true})
kmap('n', 'qq', '<Cmd>confirm q<CR>', {noremap = true, silent = true})
kmap('n', 'qa', '<Cmd>confirm qa<CR>', {noremap = true, silent = true})
kmap('n', 'qt', '<Cmd>tabc<CR>', {noremap = true, silent = true})
kmap('n', 'qc', '<Cmd>ccl<CR>', {noremap = true, silent = true})
kmap('n', 'qs', '<Cmd>lcl<CR>', {noremap = true, silent = true})
kmap('n', '<leader>w', '<Cmd>w<CR>', {noremap = true})
kmap('n', '<leader>wq', '<Cmd>wq<CR>', {noremap = true})
kmap('n', '<C-g>', '1<C-g>', {noremap = true})
kmap('n', '<leader>3', '<Cmd>buffer #<CR>', {noremap = true, silent = true})
kmap('n', '<leader>l', ':nohlsearch<CR>', {noremap = true, silent = true})
kmap('c', '<C-b>', '<Left>', {noremap = true})
kmap('c', '<C-f>', '<Right>', {noremap = true})
kmap('c', '<C-a>', '<Home>', {noremap = true})
kmap('c', '<C-d>', '<Del>', {noremap = true})
kmap('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]], {noremap = true})
kmap('c', '<M-b>', '<C-Left>', {noremap = true})
kmap('c', '<M-f>', '<C-Right>', {noremap = true})
kmap('c', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})
kmap('t', [[<M-\>]], [[<C-\><C-n>]], {noremap = true})
kmap('n', '<C-w>O', '<Cmd>tabonly', {noremap = true, silent = true})
kmap('i', '<M-;>', '<END>', {noremap = true})

kmap('n', 's', 'd', {noremap = true})
kmap('x', 's', 'd', {noremap = true})
kmap('o', 's', 'd', {noremap = true})
kmap('n', 'd', '<C-d>', {noremap = true})
kmap('x', 'd', '<C-d>', {noremap = true})
kmap('n', 'u', '<C-u>', {noremap = true})
kmap('x', 'u', '<C-u>', {noremap = true})
kmap('n', '<C-u>', 'u', {noremap = true})
kmap('n', 'k', [[(v:count > 1 ? "m'" . v:count : '') . 'k']], {noremap = true, expr = true})
kmap('n', 'j', [[(v:count > 1 ? "m'" . v:count : '') . 'j']], {noremap = true, expr = true})

kmap('n', [[']], [[`]], {noremap = true})
kmap('x', [[']], [[`]], {noremap = true})
kmap('o', [[']], [[`]], {noremap = true})
kmap('n', [[`]], [[']], {noremap = true})
kmap('x', [[`]], [[']], {noremap = true})
kmap('o', [[`]], [[']], {noremap = true})
kmap('n', [[g']], [[g`]], {noremap = true})
kmap('x', [[g']], [[g`]], {noremap = true})
kmap('o', [[g']], [[g`]], {noremap = true})
kmap('n', [[g`]], [[g']], {noremap = true})
kmap('x', [[g`]], [[g']], {noremap = true})
kmap('n', [[m']], [[m`]], {noremap = true})
kmap('x', [[m']], [[m`]], {noremap = true})

kmap('n', [['0]], [[<Cmd>normal! `0<CR><Cmd>silent! CleanEmptyBuf<CR>]],
    {noremap = true, silent = true})
kmap('n', '<leader>i', '<Cmd>silent! normal! `^<CR>', {noremap = true, silent = true})

kmap('x', '<M-j>', [[:move '>+1<CR>gv=gv]], {noremap = true, silent = true})
kmap('x', '<M-k>', [[:move '<-2<CR>gv=gv]], {noremap = true, silent = true})
kmap('n', 'yd', [[<Cmd>call setreg(v:register, expand('%:p:h'))<CR>:echo expand('%:p:h')<CR>]],
    {noremap = true, silent = true})
kmap('n', 'yn', [[<Cmd>call setreg(v:register, expand('%:t'))<CR>:echo expand('%:t')<CR>]],
    {noremap = true, silent = true})
kmap('n', 'yp', [[<Cmd>call setreg(v:register, expand('%:p'))<CR>:echo expand('%:p')<CR>]],
    {noremap = true, silent = true})
kmap('n', 'Y', 'Y$', {noremap = true})

function prefix_timeout(prefix)
    local char = fn.getchar(0)
    if type(char) == 'number' then
        char = fn.nr2char(char)
    end
    return char == '' and [[\<Nul>]] or prefix .. char
end

kmap('n', '[', [[v:lua.prefix_timeout('[')]], {noremap = true, expr = true})
kmap('x', '[', [[v:lua.prefix_timeout('[')]], {noremap = true, expr = true})
kmap('n', ']', [[v:lua.prefix_timeout(']')]], {noremap = true, expr = true})
kmap('x', ']', [[v:lua.prefix_timeout(']')]], {noremap = true, expr = true})
kmap('x', '[b', '<Cmd>bprevious<CR>', {noremap = true, silent = true})
kmap('x', ']b', '<Cmd>bnext<CR>', {noremap = true, silent = true})
kmap('x', '[q', [[<Cmd>execute(v:count1 . 'cprevious')<CR>]], {noremap = true, silent = true})
kmap('x', ']q', [[<Cmd>execute(v:count1 . 'cnext')<CR>]], {noremap = true, silent = true})
kmap('x', '[Q', '<Cmd>cfirst<CR>', {noremap = true, silent = true})
kmap('x', ']Q', '<Cmd>clast<CR>', {noremap = true, silent = true})
kmap('x', '[s', [[<Cmd>execute(v:count1 . 'lprevious')<CR>]], {noremap = true, silent = true})
kmap('x', ']s', [[<Cmd>execute(v:count1 . 'lnext')<CR>]], {noremap = true, silent = true})
kmap('x', '[S', '<Cmd>lfirst<CR>', {noremap = true, silent = true})
kmap('x', ']S', '<Cmd>llast<CR>', {noremap = true, silent = true})
kmap('n', '[z', '[z_', {noremap = true})
kmap('x', '[z', '[z_', {noremap = true})
kmap('n', ']z', ']z_', {noremap = true})
kmap('x', ']z', ']z_', {noremap = true})
kmap('n', 'zj', 'zj_', {noremap = true})
kmap('x', 'zj', 'zj_', {noremap = true})
kmap('n', 'zk', 'zk_', {noremap = true})
kmap('x', 'zk', 'zk_', {noremap = true})
kmap('n', 'z', [[v:lua.prefix_timeout('z')]], {noremap = true, expr = true})
kmap('x', 'z', [[v:lua.prefix_timeout('z')]], {noremap = true, expr = true})

pcall(cmd, 'colorscheme one')
