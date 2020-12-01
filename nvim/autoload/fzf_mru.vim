let s:cache_file = $HOME . '/.mru_files'
let s:max = 10000

function s:list_mru()
    let mru_list = []
    if filereadable(s:cache_file)
        let mru_list = readfile(s:cache_file)
    endif
    if len(mru_list) > s:max
        call remove(mru_list, s:max - 1, -1)
    endif
    cal filter(mru_list, '!empty(glob(fnameescape(v:val)))')
    retu mru_list
endfunction

function s:mru_source()
    let mru_list = s:list_mru()
    if !empty(mru_list) && mru_list[0] == expand('%:p')
        call remove(mru_list, 0)
    endif
    return map(mru_list, 'fnamemodify(v:val, ":~:.")')
endfunction

function s:p(...)
    let preview_args = get(g:, 'fzf_preview_window', ['right', 'ctrl-/'])
    if empty(preview_args)
        return {'options': ['--preview-window', 'hidden'] }
    endif
    return call('fzf#vim#with_preview', extend(copy(a:000), preview_args))
endfunction

function! fzf_mru#update_mru(bufnr)
    let bufnr = str2nr(a:bufnr)
    let bufname = bufname(bufnr)
    let filename = fnamemodify(bufname, ':p')
    if empty(bufname) || !empty(getbufvar(bufnr, '&buftype')) || !filereadable(filename)
        return
    endif
    let mru_list = s:list_mru()
    let idx = index(mru_list, filename)
    if idx == 0
        return
    elseif idx > 0
        call remove(mru_list, idx)
    endif
    call insert(mru_list, filename)
    silent call writefile(mru_list, s:cache_file)
endfunction

function! fzf_mru#mru() abort
    let opt_dict = s:p()
    call extend(opt_dict.options, ['--prompt', 'MRU> '])
    call extend(opt_dict, {'source': s:mru_source()})
    call fzf#run(fzf#wrap('mru-files', opt_dict, 0))
endfunction
