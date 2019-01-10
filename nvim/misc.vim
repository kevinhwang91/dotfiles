" switch ibus input
Plug 'kevinhwang91/vim-ibus-sw'

" PCRE regex
Plug 'othree/eregex.vim', {'on': 'E2v'}
let g:eregex_default_enable = 0

" color picker
Plug 'KabbAmine/vCoolor.vim', {'on': ['VCoolor', 'VCoolIns']}
let g:vcoolor_disable_mappings = 1
let g:vcoolor_lowercase = 1
nnoremap <silent> <leader>pc :VCoolor<CR>

" suda, fix neovim ':w !sudo tee %' bug
Plug 'kevinhwang91/suda.vim'
nnoremap <leader>:w :w suda://%<CR>

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
nnoremap <silent> <leader>tm :SignatureToggleSigns<CR>

" wip
Plug 'puremourning/vimspector'
let g:vimspector_install_gadgets = ['vscode-cpptools', 'debugpy', 'vscode-go',
            \ 'vscode-bash-debug', 'debugger-for-chrome', 'CodeLLDB']
nmap <F1> <Plug>VimspectorRestart
nmap <F2> <Plug>VimspectorContinue
nmap <F3> <Plug>VimspectorPause
nmap <F4> <Plug>VimspectorStop
nmap <F5> <Plug>VimspectorToggleConditionalBreakpoint
nmap <F6> <Plug>VimspectorStepOut
nmap <F7> <Plug>VimspectorStepInto
nmap <F8> <Plug>VimspectorStepOver
nmap <F9> <Plug>VimspectorAddFunctionBreakpoint
nmap <F10> <Plug>VimspectorToggleBreakpoint
" alacritty has remaped Control-([1-9]|[0;']) to Control-[F1-F12] (F25-F36)
nmap <F25> <Plug>VimspectorRestart
nmap <F26> <Plug>VimspectorContinue
nmap <F27> <Plug>VimspectorPause
nmap <F28> <Plug>VimspectorStop
nmap <F29> <Plug>VimspectorToggleConditionalBreakpoint
nmap <F30> <Plug>VimspectorStepOut
nmap <F31> <Plug>VimspectorStepInto
nmap <F32> <Plug>VimspectorStepOver
nmap <F33> <Plug>VimspectorAddFunctionBreakpoint
nmap <F34> <Plug>VimspectorToggleBreakpoint
