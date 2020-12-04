" switch ibus input
Plug 'kevinhwang91/vim-ibus-sw'

" PCRE regex
Plug 'othree/eregex.vim', {'on': 'E2v'}
let g:eregex_default_enable = 0

" color picker
Plug 'KabbAmine/vCoolor.vim', {'on': ['VCoolor', 'VCoolIns']}
let g:vcoolor_disable_mappings = 1
let g:vcoolor_lowercase = 1
nnoremap <silent> <leader>pc <Cmd>VCoolor<CR>

" suda, fix neovim ':w !sudo tee %' bug
Plug 'kevinhwang91/suda.vim', {'on': 'SudaWrite'}
nnoremap <leader>:w <Cmd>SudaWrite<CR>
