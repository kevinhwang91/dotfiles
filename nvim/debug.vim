" alacritty has remaped Control-([1-9]|[0]) to Control-[F1-F10] (F25-F34)

Plug 'sakhnik/nvim-gdb', {'do': ':UpdateRemotePlugins'}
let g:nvimgdb_disable_start_keymaps = 1

function! GdbKeymaps()
    nnoremap <silent><buffer> <F25> :GdbRun<CR>
    nnoremap <silent><buffer> <F26> :GdbContinue<CR>
    nnoremap <silent><buffer> <F27>
                \ :echo substitute(GdbCustomCommand('info locals'), '\r\n', ' \| ', 'g')<CR>
    nnoremap <silent><buffer> <F28> :GdbDebugStop<CR>
    nnoremap <silent><buffer> <F29> :GdbEvalWord<CR>
    xnoremap <silent><buffer> <F29> :GdbEvalRange<CR>
    nnoremap <silent><buffer> <F30> :GdbFinish<CR>
    nnoremap <silent><buffer> <F31> :GdbStep<CR>
    nnoremap <silent><buffer> <F32> :GdbNext<CR>
    nnoremap <silent><buffer> <F33> :GdbUntil<CR>
    nnoremap <silent><buffer> <F34> :GdbBreakpointToggle<CR>
    nnoremap <silent><buffer> <C-P> :GdbFrameUp<CR>
    nnoremap <silent><buffer> <C-N> :GdbFrameDown<CR>
    nnoremap <silent><buffer> <leader>wl :GdbCreateWatch info locals<CR>
endfunction

augroup NvimGdb
    autocmd User NvimGdbStart call <SID>nvim_gdb_init()
augroup end

function s:nvim_gdb_init() abort
    call sign_undefine('GdbCurrentLine')
    call sign_define('GdbCurrentLine', {'numhl': 'Operator'})
    for i in range(1, 9)
        call sign_define('GdbBreakpoint' . i, {'texthl': 'WarningMsg'})
    endfor
    setlocal foldcolumn=0 signcolumn=no nonumber norelativenumber
    let b:matchup_matchparen_enabled = 0
endfunction

function! GdbTKeymaps()
    tnoremap <silent><buffer> <C-t> <C-\><C-n>:wincmd p<CR>
endfunction

let g:nvimgdb_config_override = {
            \ 'set_keymaps': 'GdbKeymaps',
            \ 'set_tkeymaps': 'GdbTKeymaps',
            \ }
nnoremap <leader>dd :GdbStart gdb -q<Space>

" wip, preserve it for reviewing the latest message
Plug 'mfussenegger/nvim-dap', {'on': []}
Plug 'puremourning/vimspector', {'on': []}
let g:vimspector_install_gadgets = ['vscode-cpptools', 'debugpy', 'vscode-go',
            \ 'vscode-bash-debug', 'debugger-for-chrome', 'CodeLLDB']
" nmap <F25> <Plug>VimspectorRestart
" nmap <F26> <Plug>VimspectorContinue
" nmap <F27> <Plug>VimspectorPause
" nmap <F28> <Plug>VimspectorStop
" nmap <F29> <Plug>VimspectorToggleConditionalBreakpoint
" nmap <F30> <Plug>VimspectorStepOut
" nmap <F31> <Plug>VimspectorStepInto
" nmap <F32> <Plug>VimspectorStepOver
" nmap <F33> <Plug>VimspectorAddFunctionBreakpoint
" nmap <F34> <Plug>VimspectorToggleBreakpoint
