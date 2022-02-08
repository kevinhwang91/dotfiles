local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if not vim.loop.fs_stat(install_path) then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end
vim.cmd('pa packer.nvim')

local packer = require('packer')
packer.on_compile_done = function()
    local fp = assert(io.open(packer.config.compile_path, 'rw+'))
    local wbuf = {}
    local key_state = 0
    for line in fp:lines() do
        if key_state == 0 then
            table.insert(wbuf, line)
            if line:find('Keymap lazy%-loads') then
                key_state = 1
                table.insert(wbuf, [[vim.defer_fn(function()]])
            end
        elseif key_state == 1 then
            if line == '' then
                key_state = 2
                table.insert(wbuf, ('end, %d)'):format(15))
            end
            local _, e1 = line:find('vim%.cmd')
            if line:find('vim%.cmd') then
                local s2, e2 = line:find('%S+%s', e1 + 1)
                local map_mode = line:sub(s2, e2)
                line = ('pcall(vim.cmd, %s<unique>%s)'):format(map_mode, line:sub(e2 + 1))
            end
            table.insert(wbuf, line)
        else
            table.insert(wbuf, line)
        end
    end

    if key_state == 2 then
        fp:seek('set')
        fp:write(table.concat(wbuf, '\n'))
    end

    fp:close()
end

return packer.startup({
    config = {
        opt_default = true,
        display = {open_cmd = 'tabedit', keybindings = {prompt_revert = 'R', diff = 'D'}}
    },
    ---@diagnostic disable-next-line: unused-local
    function(use, use_rocks)
        local function conf(name)
            if name:match('^plugs%.') then
                return ([[require('%s')]]):format(name)
            else
                return ([[require('plugs.config').%s()]]):format(name)
            end
        end

        use {
            'wbthomason/packer.nvim',
            setup = function()
                if vim.g['loaded_nerd_comments'] ~= nil then
                    vim.g['loaded_nerd_comments'] = nil
                end
                if vim.g.loaded_visual_multi == 1 then
                    vim.schedule(function()
                        vim.fn['vm#plugs#permanent']()
                    end)
                end
            end
        }

        use {'kevinhwang91/rnvimr', opt = false}

        use {'kevinhwang91/nvim-hclipboard'}

        use {'kevinhwang91/nvim-bqf', ft = 'qf', config = conf('bqf'), branch = 'dev'}

        use {
            'kevinhwang91/nvim-hlslens',
            branch = 'dev',
            keys = {
                {'n', 'n'}, {'x', 'n'}, {'o', 'n'}, {'n', 'N'}, {'x', 'N'}, {'o', 'N'}, {'n', '/'},
                {'n', '?'}, {'n', '*'}, {'x', '*'}, {'n', '#'}, {'x', '#'}, {'n', 'g*'},
                {'x', 'g*'}, {'n', 'g#'}, {'x', 'g#'}
            },
            config = conf('hlslens'),
            requires = 'haya14busa/vim-asterisk'
        }

        use {'Raimondi/delimitMate', event = 'InsertEnter'}

        use {
            'tpope/vim-surround',
            setup = [[vim.g.surround_no_mappings = 1]],
            keys = {
                {'n', 'sd'}, {'n', 'cs'}, {'n', 'cS'}, {'n', 'ys'}, {'n', 'yS'}, {'n', 'yss'},
                {'n', 'ygs'}, {'x', 'S'}, {'x', 'gS'}
            },
            config = conf('surround')
        }

        use {
            'mg979/vim-visual-multi',
            setup = [[vim.g.VM_leader = '<Space>']],
            keys = {
                {'n', '<C-n>'}, {'x', '<C-n>'}, {'n', [[<Leader>\]]}, {'n', '<Leader>A'},
                {'x', '<Leader>A'}, {'n', '<M-C-k>'}, {'n', '<M-C-j>'}, {'n', 'g/'}
            },
            cmd = {'VMSearch'},
            config = conf('visualmulti'),
            wants = {'nvim-hlslens', 'delimitMate', 'vim-surround'}
        }

        use {
            'rhysd/clever-f.vim',
            keys = {
                {'n', 'f'}, {'x', 'f'}, {'o', 'f'}, {'n', 'F'}, {'x', 'F'}, {'o', 'F'}, {'n', 't'},
                {'x', 't'}, {'o', 't'}, {'n', 'T'}, {'x', 'T'}, {'o', 'T'}
            },
            config = conf('cleverf')
        }

        use {'antoinemadec/FixCursorHold.nvim', opt = false}

        use {'junegunn/fzf.vim', requires = {{'junegunn/fzf', run = './install --bin'}}}

        use {'t9md/vim-choosewin', keys = {{'n', '<M-0>'}}, config = conf('choosewin')}

        use {
            'kevinhwang91/vim-grepper',
            cmd = 'Grepper',
            keys = {{'n', 'gs'}, {'x', 'gs'}, {'n', '<Leader>rg'}},
            config = conf('grepper')
        }

        use {'Yggdroot/indentLine', cmd = 'IndentLinesEnable', config = conf('indentline')}

        use {'tpope/vim-repeat', opt = false}
        use {
            'michaeljsmith/vim-indent-object',
            keys = {{'o', 'ai'}, {'o', 'ii'}, {'x', 'ai'}, {'x', 'ii'}}
        }

        use {'wellle/targets.vim', fn = 'targets#e'}

        use {
            'tommcdo/vim-exchange',
            keys = {{'x', 'X'}, {'n', 'cx'}, {'n', 'cx;'}, {'n', 'cxx'}},
            setup = [[vim.g.exchange_no_mappings = 1]],
            config = conf('exchange')
        }

        use {
            'bootleq/vim-cycle',
            keys = {{'n', '<C-a>'}, {'v', '<C-a>'}, {'n', '<C-x>'}, {'v', '<C-x>'}},
            setup = [[vim.g.cycle_no_mappings = 1]],
            config = conf('plugs.cycle')
        }

        use {'mbbill/undotree'}

        use {
            'tpope/vim-fugitive',
            fn = 'fugitive#*',
            cmd = {'Git', 'Gedit', 'Gread', 'Gwrite', 'Gdiffsplit', 'Gvdiffsplit'},
            event = 'BufReadPre */.git/index',
            config = conf('plugs.fugitive')
        }

        use {'tpope/vim-rhubarb'}

        use {
            'rbong/vim-flog',
            cmd = {'Flog', 'Flogsplit'},
            requires = {{'tpope/vim-fugitive'}},
            config = conf('plugs.flog')
        }

        use {
            'lewis6991/gitsigns.nvim',
            requires = {'nvim-lua/plenary.nvim'},
            config = conf('plugs.gitsigns')
        }

        use {
            'ruanyl/vim-gh-line',
            keys = {{'n', '<Leader>gO'}, {'n', '<Leader>gL'}, {'x', '<Leader>gL'}},
            setup = [[vim.g.gh_line_blame_map_default = 0]],
            config = conf('ghline')
        }

        use {'rhysd/git-messenger.vim', cmd = {'GitMessenger'}}

        use {'rrethy/vim-hexokinase', run = 'make hexokinase'}

        use {'sbdchd/neoformat', cmd = 'Neoformat', config = conf('plugs.format')}

        use {'editorconfig/editorconfig-vim', config = conf('plugs.editorconf')}

        use {'pseewald/vim-anyfold', cmd = 'AnyFoldActivate'}

        use {
            'jpalardy/vim-slime',
            keys = {{'n', '<C-c><C-c>'}, {'x', '<C-c><C-c>'}, {'n', '<C-c>v'}, {'n', '<C-c>l'}},
            setup = [[vim.g.slime_no_mappings = 1]],
            config = conf('slime')
        }

        use {'plasticboy/vim-markdown', ft = 'markdown'}

        use {
            'iamcco/markdown-preview.nvim',
            run = 'cd app && yarn install',
            ft = {'markdown', 'html'},
            setup = [[vim.g.mkdp_auto_close = 0]]
        }

        use {'sakhnik/nvim-gdb', cmd = {'GdbStart', 'GdbStartPDB'}, config = conf('plugs.nvimgdb')}

        use {'kevinhwang91/vim-ibus-sw', event = 'InsertEnter'}

        use {'othree/eregex.vim', cmd = 'E2v', setup = [[vim.g.eregex_default_enable = 0]]}

        use {
            'KabbAmine/vCoolor.vim',
            keys = {{'n', '<Leader>pc'}, {'n', '<Leader>yb'}, {'n', '<Leader>yr'}},
            setup = [[vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1]],
            config = conf('vcoolor')
        }

        use {'kevinhwang91/suda.vim', keys = {{'n', '<Leader>W'}}, config = conf('suda')}

        use {'neoclide/coc.nvim', branch = 'master', run = 'yarn install --frozen-lockfile'}

        use {'kevinhwang91/coc-kvs', run = 'yarn install --frozen-lockfile'}

        use {
            'danymat/neogen',
            config = conf('neogen'),
            keys = {{'n', '<Leader>dg'}},
            requires = 'nvim-treesitter/nvim-treesitter'
        }

        use {'preservim/nerdcommenter', keys = '<Plug>NERDCommenterToggle'}

        use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}

        use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

        use {'nvim-treesitter/nvim-treesitter-textobjects'}

        use {
            'nvim-treesitter/playground',
            cmd = {'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor'}
        }

        use {'rktjmp/lush.nvim'}

        use {'MTDL9/vim-log-highlighting', event = 'BufNewFile,BufRead *.log'}

        use {'nanotee/luv-vimdocs', opt = false}

        use {'mizlan/iswap.nvim', requires = 'nvim-treesitter/nvim-treesitter'}

        use {'rcarriga/nvim-notify', config = conf('notify')}

        -- use_rocks {'lrexlib-PCRE2'}
        -- use_rocks {'base64'}
        -- use_rocks {'luautf8'}

    end
})
