let s:disk_file = $HOME . '/.mru_files'
let s:tmp_dir = '/tmp/fzf_mru'
let s:tmp_file = s:tmp_dir . '/mru_files'
let s:max = 300
let s:count = 0

function s:list_mru(file) abort
    let mru_list = []
    if filereadable(a:file)
        let mru_list = readfile(a:file)
    endif
    if len(mru_list) > s:max
        call remove(mru_list, s:max, -1)
    endif
    cal filter(mru_list, '!empty(glob(fnameescape(v:val)))')
    return mru_list
endfunction

function s:mru_source(file) abort
    let mru_list = s:list_mru(a:file)
    if !empty(mru_list) && mru_list[0] == expand('%:p')
        call remove(mru_list, 0)
    endif
    return map(mru_list, 'fnamemodify(v:val, ":~:.")')
endfunction

function s:write2disk(...) abort
    if a:0 == 1 && type(a:1) == v:t_list
        let mru_list = a:1
    else
        let mru_list = s:list_mru(s:tmp_file)
    endif
    if !empty(mru_list)
        " race condition between processes
        let d_mru_list = s:list_mru(s:disk_file)
        if len(d_mru_list) - 10 > len(mru_list)
            call system(printf("cp %s %s", s:tmp_file, '/tmp/mru_ram'))
            call system(printf("cp %s %s", s:disk_file, '/tmp/mru_disk'))
            return
        endif
        call writefile(mru_list, s:disk_file)
    endif
endfunction

function s:write2ram() abort
    let mru_list = s:list_mru(s:disk_file)
    call writefile(mru_list, s:tmp_file)
endfunction

function s:p(...) abort
    let preview_args = get(g:, 'fzf_preview_window', ['right', 'ctrl-/'])
    if empty(preview_args)
        return {'options': ['--preview-window', 'hidden'] }
    endif
    return call('fzf#vim#with_preview', extend(copy(a:000), preview_args))
endfunction

function! fzf_mru#update_mru(bufnr) abort
    if empty(a:bufnr) || type(a:bufnr) == v:t_number && a:bufnr == 0
        let bufnr = bufnr()
    else
        let bufnr = str2nr(a:bufnr)
    endif
    let bufname = bufname(bufnr)
    let filename = fnamemodify(bufname, ':p')
    if empty(bufname) || !empty(getbufvar(bufnr, '&buftype')) || !filereadable(filename)
        return
    endif

    let mru_list = s:list_mru(s:tmp_file)
    let idx = index(mru_list, filename)
    if idx == 0
        return
    elseif idx > 0
        call remove(mru_list, idx)
    endif
    call insert(mru_list, filename)

    let s:count = (s:count + 1) % 10
    if s:count == 0
        call s:write2disk()
    endif
    call writefile(mru_list, s:tmp_file)
endfunction

function! fzf_mru#mru() abort
    let opt_dict = s:p()
    call extend(opt_dict.options, ['--prompt', 'MRU> ', '--tiebreak', 'index'])
    call extend(opt_dict, {'source': s:mru_source(s:tmp_file)})
    call fzf#run(fzf#wrap('mru-files', opt_dict, 0))
endfunction

function! fzf_mru#enable() abort
    if !filereadable(s:tmp_file)
        silent! call mkdir(s:tmp_dir, 'p')
        call s:write2ram()
    endif
    call fzf_mru#update_mru(0)
    augroup FzfMru
        autocmd!
        autocmd BufEnter,BufAdd * call fzf_mru#update_mru(expand('<abuf>', 1))
        autocmd VimLeavePre,VimSuspend * call <SID>write2disk()
        autocmd FocusLost * call <SID>write2disk()
        " https://github.com/neovim/neovim/pull/7670
        " TODO Neovim + Tmux will fire FocusGained on startup
        if exists('$TMUX')
            autocmd FocusGained * ++once execute('autocmd FocusGained * call <SID>write2ram()')
        else
            autocmd FocusGained * call <SID>write2ram()
        endif
    augroup END
endfunction
