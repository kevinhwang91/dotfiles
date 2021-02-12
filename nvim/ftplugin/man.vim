if !exists('g:no_man_maps')
    let g:no_man_maps = 1
endif
nmap <silent><buffer> gO :call man#show_toc()<CR>
