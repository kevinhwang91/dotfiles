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
Plug 'kevinhwang91/suda.vim'
nnoremap <leader>:w <Cmd>w suda://%<CR>

" marks display
" hide at startup https://github.com/neovim/neovim/issues/4295
Plug 'kshenoy/vim-signature'
let g:SignatureEnabledAtStartup = 0
let g:SignatureMarkTextHL = 'Special'
let g:SignatureMarkerTextHL = 'Statement'
let g:SignatureMap = {
            \ 'Leader'             :  "m",
            \ 'PlaceNextMark'      :  "m,",
            \ 'ToggleMarkAtLine'   :  "m;",
            \ 'PurgeMarksAtLine'   :  "m-",
            \ 'DeleteMark'         :  "sm",
            \ 'PurgeMarks'         :  "m<Space>",
            \ 'PurgeMarkers'       :  "m<BS>",
            \ 'GotoNextLineByPos'  :  "]'",
            \ 'GotoPrevLineByPos'  :  "['",
            \ 'GotoNextSpotByPos'  :  "]`",
            \ 'GotoPrevSpotByPos'  :  "[`",
            \ 'GotoNextMarker'     :  "]-",
            \ 'GotoPrevMarker'     :  "[-",
            \ 'GotoNextMarkerAny'  :  "]=",
            \ 'GotoPrevMarkerAny'  :  "[=",
            \ 'ListBufferMarks'    :  "m/",
            \ 'ListBufferMarkers'  :  "m?"
            \ }
nnoremap <silent> <leader>tm <Cmd>SignatureToggleSigns<CR>
