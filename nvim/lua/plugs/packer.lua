local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end
vim.cmd('packadd packer.nvim')

return require('packer').startup({
    function(use)
        use {'wbthomason/packer.nvim', opt = true}

        use {'kevinhwang91/rnvimr'}

        use {'kevinhwang91/nvim-bqf'}

        use {'kevinhwang91/nvim-hlslens'}

        use {'junegunn/fzf.vim', opt = true}

        use {'t9md/vim-choosewin', cmd = 'ChooseWin'}

        use {'mhinz/vim-grepper', cmd = 'Grepper', keys = '<Plug>(GrepperOperator)'}

        use {'andymass/vim-matchup', opt = true}

        use {'haya14busa/vim-asterisk'}

        use {'tpope/vim-surround'}

        use {'tpope/vim-repeat'}

        use {
            'michaeljsmith/vim-indent-object',
            keys = {
                {'o', 'ai'}, {'o', 'ii'}, {'v', 'ai'}, {'v', 'ii'}, {'o', 'aI'}, {'o', 'iI'},
                {'v', 'aI'}, {'v', 'iI'}
            }
        }
        use {'wellle/targets.vim'}

        use {
            'tommcdo/vim-exchange',
            keys = {'<Plug>(Exchange)', '<Plug>(ExchangeClear)', '<Plug>(ExchangeLine)'}
        }

        use {
            'Krasjet/auto-pairs',
            event = 'InsertEnter *',
            config = [[vim.fn['AutoPairsTryInit']()]]
        }

        use {
            'mg979/vim-visual-multi',
            cmd = {'VMSearch'},
            keys = {
                '<Plug>(VM-Find-Under)', '<Plug>(VM-Visual-Cursors)',
                '<Plug>(VM-Add-Cursor-At-Pos)', '<Plug>(VM-Select-All)', '<Plug>(VM-Visual-All)',
                '<Plug>(VM-Select-Cursor-Up)', '<Plug>(VM-Select-Cursor-Down)',
                '<Plug>(VM-Start-Regex-Search)', '<Plug>(VM-Find-Subword-Under)'
            }
        }

        use {'bootleq/vim-cycle', keys = {'<Plug>CyclePrev', '<Plug>CycleNext'}}

        use {'mbbill/undotree', opt = true}

        use {'tpope/vim-fugitive'}

        use {'ruanyl/vim-gh-line', keys = {'<Plug>(gh-repo)', '<Plug>(gh-line)'}}

        use {'airblade/vim-gitgutter', opt = true}

        use {'rbong/vim-flog', cmd = {'Flog', 'Flogsplit'}}

        use {'rhysd/git-messenger.vim', cmd = {'GitMessenger'}}

        use {
            'rrethy/vim-hexokinase',
            run = 'make hexokinase',
            cmd = {'HexokinaseToggle', 'HexokinaseTurnOn'},
            event = 'BufReadPost *'
        }

        use {'sbdchd/neoformat', cmd = 'Neoformat'}

        use {'editorconfig/editorconfig-vim'}

        use {'honza/vim-snippets'}

        use {'pseewald/vim-anyfold', cmd = 'AnyFoldActivate'}

        use {
            'jpalardy/vim-slime',
            keys = {
                '<Plug>SlimeRegionSend', '<Plug>SlimeLineSend', '<Plug>SlimeParagraphSend',
                '<Plug>SlimeConfig'
            }
        }

        use {'plasticboy/vim-markdown', ft = 'markdown'}

        use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', ft = 'markdown'}

        use {'sakhnik/nvim-gdb', run = ':UpdateRemotePlugins'}

        use {'kevinhwang91/vim-ibus-sw'}

        use {'othree/eregex.vim', cmd = 'E2v'}

        use {'KabbAmine/vCoolor.vim', cmd = {'VCoolor', 'VCoolIns'}}

        use {'kevinhwang91/suda.vim', cmd = 'SudaWrite'}

        use {
            'neoclide/coc.nvim',
            opt = true,
            branch = 'master',
            run = 'yarn install --frozen-lockfile'
        }

        use {'kevinhwang91/vim-lsp-cxx-highlight', opt = true}

        use {'wellle/tmux-complete.vim', opt = true}

        use {
            'kkoomen/vim-doge',
            run = function()
                vim.fn['doge#install']()
            end,
            cmd = {'DogeGenerate', 'DogeCreateDocStandard'}
        }

        use {'preservim/nerdcommenter', keys = '<Plug>NERDCommenterToggle'}

        use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}

        use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', opt = true}

        use {'nvim-treesitter/nvim-treesitter-textobjects', opt = true}
    end,
    config = {display = {open_cmd = 'tabedit', keybindings = {prompt_revert = 'R', diff = 'D'}}}
})
