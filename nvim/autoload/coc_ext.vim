function! coc_ext#go_to_definition()
    let bufnr = bufnr()
    silent let ret = CocAction('jumpDefinition')
    if ret
        let w:gtd = 'coc'
        if bufnr() != bufnr
            normal zz
        endif
    else
        let cword = expand('<cword>')
        try
            execute('ltag ' . cword)
            let def_size = getloclist(0, {'size': 0}).size
            let w:gtd = 'tag'
            if def_size > 1
                execute("normal! \<C-o>")
                execute('aboveleft lwindow ' . def_size)
            elseif def_size == 1
                lclose
                call search(cword, 'c')
                if bufnr() != bufnr
                    normal zz
                endif
            endif
        catch /.*/
            let w:gtd = 'search'
            call searchdecl(cword)
        endtry
    endif
endfunction

function! coc_ext#show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . ' ' . expand('<cword>')
    endif
endfunction

function! coc_ext#qf_diagnostic() abort
    let diagnostic_list = CocAction('diagnosticList')
    let items = []
    let loc_ranges = []
    for d in diagnostic_list
        let type = d.severity[0]
        let text = printf('[%s%s] %s [%s]', (empty(d.source) ? 'coc.nvim' : d.source),
                    \ (d.code ? ' ' . d.code : ''), split(d.message, '\n')[0], type)
        let item = {'filename': d.file, 'lnum': d.lnum, 'col': d.col, 'text': text, 'type': type}
        call add(loc_ranges, d.location.range)
        call add(items, item)
    endfor
    call setqflist([], ' ', {'title': 'CocDiagnosticList', 'items': items,
                \ 'context': {'bqf': {'lsp_range_hl': loc_ranges}}})
    botright copen
endfunction

function! coc_ext#jump2loc(locs) abort
    let loc_ranges = map(deepcopy(a:locs), 'v:val.range')
    call setloclist(0, [], ' ', {'title': 'CocLocationList', 'items': a:locs,
                \ 'context': {'bqf': {'lsp_range_hl': loc_ranges}}})
    let winid = getloclist(0, {'winid': 0}).winid
    if winid == 0
        aboveleft lwindow
    else
        call win_gotoid(winid)
    endif
endfunction

" CocHasProvider('documentHighlight') has probability of RPC failure
" Write the hardcode of filetype for fallback highlight
let s:fb_ft_black_list = [
            \ 'qf', 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java', 'lua',
            \ 'typescript', 'javascript', 'css', 'html', 'xml'
            \ ]

function s:get_cur_word()
    let line = getline('.')
    let col = col('.')
    let left = strpart(line, 0, col)
    let right = strpart(line, col - 1, col('$'))
    let word = matchstr(left, '\k*$') . matchstr(right, '^\k*')[1:]
    return '\<' . escape(word, '/\') . '\>'
endf

function! coc_ext#highlight_fallback(err, res)
    if &buftype == 'terminal' || index(s:fb_ft_black_list, &filetype) > -1
        return
    endif

    if exists('w:coc_matchids_fb')
        silent! call matchdelete(w:coc_matchids_fb)
    endif

    let w:coc_matchids_fb = matchadd('CocHighlightText', s:get_cur_word(), -1)
endfunction
