nunmap <buffer> d
nunmap <buffer> D
nunmap <buffer> o
nunmap <buffer> O
nmap <buffer><silent><nowait> s <Cmd>call b:__gitmessenger_popup.opts.mappings['d'][0]()<CR>
nmap <buffer><silent><nowait> S <Cmd>call b:__gitmessenger_popup.opts.mappings['D'][0]()<CR>
nmap <buffer><silent><nowait> < <Cmd>call b:__gitmessenger_popup.opts.mappings['o'][0]()<CR>
nmap <buffer><silent><nowait> > <Cmd>call b:__gitmessenger_popup.opts.mappings['O'][0]()<CR>
