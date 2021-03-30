local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end
vim.cmd('pa packer.nvim')

return require('packer').startup({
    config = {
        opt_default = true,
        display = {open_cmd = 'tabedit', keybindings = {prompt_revert = 'R', diff = 'D'}}
    },
    function(use)
        use {
            'wbthomason/packer.nvim',
            setup = function()
                for _, flag in ipairs({
                    'loaded_grepper', 'loaded_eregex', 'loaded_git_messenger', 'loaded_slime',
                    'loaded_nerd_comments', 'loaded_suda', 'vcoolor_loaded', 'loaded_choosewin',
                    'loaded_cycle', 'loaded_doge', 'loaded_gh_line', 'loaded_hexokinase'
                }) do
                    if vim.g[flag] ~= nil then
                        vim.g[flag] = nil
                    end
                end
            end
        }

        use {'kevinhwang91/rnvimr', opt = false}

        use {'kevinhwang91/nvim-bqf', opt = false}

        use {'kevinhwang91/nvim-hlslens', opt = false}

        use {'rhysd/clever-f.vim', opt = false}

        use {'antoinemadec/FixCursorHold.nvim', opt = false}

        use {'junegunn/fzf.vim', requires = {{'junegunn/fzf', run = './install --bin'}}}

        use {'t9md/vim-choosewin', cmd = 'ChooseWin'}

        use {'mhinz/vim-grepper', cmd = 'Grepper', keys = '<Plug>(GrepperOperator)'}

        use {'andymass/vim-matchup'}

        use {'haya14busa/vim-asterisk', opt = false}

        use {'tpope/vim-surround', opt = false}

        use {'tpope/vim-repeat', opt = false}

        use {
            'michaeljsmith/vim-indent-object',
            keys = {
                {'o', 'ai'}, {'o', 'ii'}, {'v', 'ai'}, {'v', 'ii'}, {'o', 'aI'}, {'o', 'iI'},
                {'v', 'aI'}, {'v', 'iI'}
            }
        }
        use {'wellle/targets.vim', opt = false}

        use {
            'tommcdo/vim-exchange',
            keys = {'<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)'}
        }

        use {'Krasjet/auto-pairs', opt = false}

        use {'mg979/vim-visual-multi'}

        use {'bootleq/vim-cycle', keys = {'<Plug>CyclePrev', '<Plug>CycleNext'}}

        use {'mbbill/undotree'}

        use {'tpope/vim-fugitive', opt = false}

        use {'ruanyl/vim-gh-line', keys = {'<Plug>(gh-repo)', '<Plug>(gh-line)'}}

        use {'airblade/vim-gitgutter'}

        use {'rbong/vim-flog', cmd = {'Flog', 'Flogsplit'}}

        use {'rhysd/git-messenger.vim', cmd = {'GitMessenger'}}

        use {'rrethy/vim-hexokinase', run = 'make hexokinase'}

        use {'sbdchd/neoformat', cmd = 'Neoformat'}

        use {'editorconfig/editorconfig-vim', opt = false}

        use {'honza/vim-snippets', opt = false}

        use {'pseewald/vim-anyfold', cmd = 'AnyFoldActivate'}

        use {
            'jpalardy/vim-slime',
            keys = {
                '<Plug>SlimeRegionSend', '<Plug>SlimeLineSend', '<Plug>SlimeParagraphSend',
                '<Plug>SlimeConfig'
            }
        }

        use {'plasticboy/vim-markdown', ft = 'markdown'}

        use {
            'iamcco/markdown-preview.nvim',
            run = 'cd app && yarn install',
            ft = {'markdown', 'html'}
        }

        use {'sakhnik/nvim-gdb', run = ':UpdateRemotePlugins', opt = false}

        use {'kevinhwang91/vim-ibus-sw', opt = false}

        use {'othree/eregex.vim', cmd = 'E2v'}

        use {'KabbAmine/vCoolor.vim', cmd = {'VCoolor', 'VCoolIns'}}

        use {'kevinhwang91/suda.vim', cmd = 'SudaWrite'}

        use {'neoclide/coc.nvim', branch = 'master', run = 'yarn install --frozen-lockfile'}

        use {'kevinhwang91/vim-lsp-cxx-highlight'}

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
    end
})
