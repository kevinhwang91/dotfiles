Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
noremap <M-C-l> <Cmd>Neoformat<CR>
let g:neoformat_only_msg_on_error = 1
let g:neoformat_basic_format_align = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_basic_format_trim = 1

" python
let g:neoformat_enabled_python = ['autopep8']
let g:neoformat_python_autopep8 = {'exe': 'autopep8', 'args': ['--max-line-length=100']}

" lua
let g:neoformat_enabled_lua = ['luaformat']
let g:neoformat_lua_luaformat = {'exe': 'lua-format', 'args': [
            \ '--column-limit=100', '--no-keep-simple-control-block-one-line',
            \ '--no-keep-simple-function-one-line', '--no-align-args', '--no-align-parameter',
            \ '--no-align-table-field', '--double-quote-to-single-quote']}

" javascript
let g:neoformat_enabled_javascript = ['prettier']

" typescript
let g:neoformat_enabled_typescript = ['prettier']

" json
let g:neoformat_enabled_json = ['prettier']

" yaml
let g:neoformat_enabled_yaml = ['prettier']
let g:neoformat_yaml_prettier = {'exe': 'prettier',
            \ 'args': ['--stdin-filepath', '"%:p"', '--tab-width=2'], 'stdin': 1}

" editorconfig
Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
let g:EditorConfig_preserve_formatoptions = 1

augroup GoFormat
    autocmd!
    autocmd FileType go setlocal noexpandtab
augroup end

augroup PrettierFormat
    autocmd!
    autocmd FileType javascript,typescript,json setlocal noexpandtab
    autocmd FileType yaml setlocal tabstop=2 shiftwidth=2
augroup end
