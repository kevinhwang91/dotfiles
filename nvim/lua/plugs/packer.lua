local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.glob(install_path) == '' then
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
                table.insert(wbuf, [[vim.schedule(function() vim.defer_fn(function()]])
            end
        elseif key_state == 1 then
            if line == '' then
                key_state = 2
                table.insert(wbuf, ('end, %d) end)'):format(100))
            end
            local _, e1 = line:find('vim%.cmd')
            if line:find('vim%.cmd') then
                local s2, e2 = line:find('%S+%s', e1 + 1)
                line = ('pcall(vim.cmd, %s<unique>%s)'):format(line:sub(s2, e2), line:sub(e2 + 1))
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
    function(use, use_rocks)
        local function conf(name)
            return ([[require('plugs.config').%s()]]):format(name)
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
            setup = [[vim.g.loaded_nvim_hlslens = 1]],
            keys = {'n', 'N', '/', '?', '*', '#', 'g*', 'g#'},
            config = conf('hlslens'),
            requires = {{'haya14busa/vim-asterisk'}}
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
                {'', '<C-n>'}, {'n', [[<Leader>\]]}, {'', '<Leader>A'}, {'n', '<M-C-k>'},
                {'n', '<M-C-j>'}, {'n', 'g/'}
            },
            cmd = {'VMSearch'},
            config = conf('visualmulti'),
            wants = {'nvim-hlslens', 'delimitMate', 'vim-surround'}
        }

        use {'rhysd/clever-f.vim', keys = {'f', 'F', 't', 'T'}, config = conf('cleverf')}

        use {'antoinemadec/FixCursorHold.nvim', opt = false}

        use {'junegunn/fzf.vim', requires = {{'junegunn/fzf', run = './install --bin'}}}

        use {'t9md/vim-choosewin', keys = '<M-0>', config = conf('choosewin')}

        use {
            'mhinz/vim-grepper',
            cmd = 'Grepper',
            keys = {{'n', 'gs'}, {'x', 'gs'}, {'n', '<Leader>rg'}},
            config = conf('grepper')
        }

        use {'andymass/vim-matchup'}

        use {'tpope/vim-repeat', opt = false}

        use {
            'michaeljsmith/vim-indent-object',
            keys = {
                {'o', 'ai'}, {'o', 'ii'}, {'v', 'ai'}, {'v', 'ii'}, {'o', 'aI'}, {'o', 'iI'},
                {'v', 'aI'}, {'v', 'iI'}
            }
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
            keys = {'<C-a>', '<C-x>'},
            setup = [[vim.g.cycle_no_mappings = 1]],
            config = conf('cycle')
        }

        use {'mbbill/undotree'}

        use {
            'tpope/vim-fugitive',
            fn = 'fugitive#*',
            cmd = {'Git', 'Gedit', 'Gread', 'Gwrite', 'Gdiffsplit', 'Gvdiffsplit'},
            config = [[require('plugs.fugitive')]]
        }

        use {'tpope/vim-rhubarb'}

        use {'rbong/vim-flog', cmd = {'Flog', 'Flogsplit'}, requires = {{'tpope/vim-fugitive'}}}

        use {'airblade/vim-gitgutter'}

        use {
            'ruanyl/vim-gh-line',
            keys = {'<Leader>gO', '<Leader>gL'},
            setup = [[vim.g.gh_line_blame_map_default = 0]],
            config = conf('ghline')
        }

        use {'rhysd/git-messenger.vim', cmd = {'GitMessenger'}}

        use {'rrethy/vim-hexokinase', run = 'make hexokinase'}

        use {'sbdchd/neoformat', cmd = 'Neoformat', config = conf('neoformat')}

        use {'editorconfig/editorconfig-vim'}

        use {'pseewald/vim-anyfold', cmd = 'AnyFoldActivate'}

        use {
            'jpalardy/vim-slime',
            keys = {{'', '<C-c><C-c>'}, {'n', '<C-c>v'}, {'n', '<C-c>l'}},
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

        use {
            'sakhnik/nvim-gdb',
            cmd = {'GdbStart', 'GdbStartPDB'},
            config = [[require('plugs.nvimgdb')]]
        }

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

        use {'wellle/tmux-complete.vim'}

        use {
            'kkoomen/vim-doge',
            run = function()
                vim.fn['doge#install']()
            end,
            cmd = {'DogeGenerate', 'DogeCreateDocStandard'}
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

        use {'mizlan/iswap.nvim'}

        -- keep learning :)
        use {'nvim-lua/plenary.nvim'}

        use_rocks {'lrexlib-PCRE2'}
    end
})
