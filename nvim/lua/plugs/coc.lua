local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local map = require('remap').map
local utils = require('kutils')
local diag_qfid
local sign_icons

function M.go2def()
    local cur_bufnr = api.nvim_get_current_buf()
    local by
    if vim.bo.ft == 'help' then
        api.nvim_feedkeys(utils.termcodes['<C-]>'], 'n', false)
        by = 'tag'
    else
        local err, res = M.a2sync('jumpDefinition', {'drop'})
        if not err then
            by = 'coc'
        elseif res == 'timeout' then
            vim.notify('Go to reference Timeout', vim.log.levels.WARN)
        else
            local cword = fn.expand('<cword>')
            if not pcall(function()
                local wv = fn.winsaveview()
                cmd('ltag ' .. cword)
                local def_size = fn.getloclist(0, {size = 0}).size
                by = 'ltag'
                if def_size > 1 then
                    api.nvim_set_current_buf(cur_bufnr)
                    fn.winrestview(wv)
                    cmd('abo lw')
                elseif def_size == 1 then
                    cmd('lcl')
                    fn.search(cword, 'cs')
                end
            end) then
                fn.searchdecl(cword)
                by = 'search'
            end
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        cmd('norm! zz')
    end

    if by then
        utils.cool_echo('go2def: ' .. by, 'Special')
    end
end

function M.show_documentation()
    local ft = vim.bo.ft
    if ft == 'help' then
        cmd(('sil! h %s'):format(fn.expand('<cword>')))
    else
        local err, res = M.a2sync('definitionHover')
        if err then
            if res == 'timeout' then
                vim.notify('Show documentation Timeout', vim.log.levels.WARN)
            end
            cmd('norm! K')
        end
    end
end

function M.diagnostic_change()
    if vim.v.exiting == vim.NIL then
        local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
        if info.id == diag_qfid and info.winid ~= 0 then
            M.diagnostic(info.winid, info.nr, true)
        end
    end
end

function M.diagnostic(winid, nr, keep)
    fn.CocActionAsync('diagnosticList', '', function(err, res)
        if err == vim.NIL then
            local items = {}
            for _, d in ipairs(res) do
                local text = ('[%s%s] %s'):format((d.source == '' and 'coc.nvim' or d.source),
                    (d.code == vim.NIL and '' or ' ' .. d.code), d.message:match('([^\n]+)\n*'))
                local item = {
                    filename = d.file,
                    lnum = d.lnum,
                    end_lnum = d.end_lnum,
                    col = d.col,
                    end_col = d.end_col,
                    text = text,
                    type = d.severity
                }
                table.insert(items, item)
            end
            local id
            if winid and nr then
                id = diag_qfid
            else
                local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
                id, winid, nr = info.id, info.winid, info.nr
            end
            local action = id == 0 and ' ' or 'r'
            fn.setqflist({}, action,
                {id = id ~= 0 and id or nil, title = 'CocDiagnosticList', items = items})

            if id == 0 then
                local info = fn.getqflist({id = id, nr = 0})
                diag_qfid, nr = info.id, info.nr
            end

            if not keep then
                if winid == 0 then
                    cmd('bo cope')
                else
                    api.nvim_set_current_win(winid)
                end
                cmd(('sil %dchi'):format(nr))
            end
        end
    end)
end

function M.jump2loc(locs, skip)
    locs = locs or vim.g.coc_jump_locations
    fn.setloclist(0, {}, ' ', {title = 'CocLocationList', items = locs})
    if not skip then
        local winid = fn.getloclist(0, {winid = 0}).winid
        if winid == 0 then
            cmd('abo lw')
        else
            api.nvim_set_current_win(winid)
        end
    end
end

M.hl_fallback = (function()
    local fb_bl_ft = {
        'qf', 'fzf', 'vim', 'sh', 'python', 'go', 'c', 'cpp', 'rust', 'java', 'lua', 'typescript',
        'javascript', 'css', 'html', 'xml'
    }
    local hl_fb_tbl = {}
    local re_s, re_e = vim.regex([[\k*$]]), vim.regex([[^\k*]])
    local function cur_word_pat()
        local lnum, col = unpack(api.nvim_win_get_cursor(0))
        local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]:match('%C*')
        local _, e_off = re_e:match_str(line:sub(col + 1, -1))
        local pat = ''
        if e_off ~= 0 then
            local s, e = re_s:match_str(line:sub(1, col + 1))
            local word = line:sub(s + 1, e + e_off - 1)
            pat = ([[\<%s\>]]):format(word:gsub('[\\/~]', [[\%1]]))
        end
        return pat
    end

    return function()
        local ft = vim.bo.ft
        if vim.tbl_contains(fb_bl_ft, ft) or api.nvim_get_mode().mode == 't' then
            return
        end

        local m_id, winid = unpack(hl_fb_tbl)
        pcall(fn.matchdelete, m_id, winid)

        winid = api.nvim_get_current_win()
        m_id = fn.matchadd('CocHighlightText', cur_word_pat(), -1, -1, {window = winid})
        hl_fb_tbl = {m_id, winid}
    end
end)()

function M.a2sync(action, args, time)
    local done = false
    local err = false
    local res = ''
    args = args or {}
    table.insert(args, function(e, r)
        if e ~= vim.NIL then
            err = true
        end
        if r ~= vim.NIL then
            res = r
        end
        done = true
    end)
    fn.CocActionAsync(action, unpack(args))
    local wait_ret = vim.wait(time or 1000, function()
        return done
    end)
    err = err or not wait_ret
    if not wait_ret then
        res = 'timeout'
    end
    return err, res
end

function M.run_command(name, args, cb)
    local action_fn
    args = args or {}
    if type(cb) == 'function' then
        action_fn = fn.CocActionAsync
        table.insert(args, cb)
    else
        action_fn = fn.CocAction
    end
    return action_fn('runCommand', name, unpack(args))
end

function M.code_action(mode, only)
    if type(mode) == 'string' then
        mode = {mode}
    end
    local no_actions = true
    for _, m in ipairs(mode) do
        local err, ret = M.a2sync('codeActions', {m, only}, 1000)
        if err then
            if ret == 'timeout' then
                vim.notify('codeAction timeout', vim.log.levels.WARN)
                break
            end
        else
            if type(ret) == 'table' and #ret > 0 then
                fn.CocActionAsync('codeAction', m, only)
                no_actions = false
                break
            end
        end
    end
    if no_actions then
        vim.notify('No code Action available', vim.log.levels.WARN)
    end
end

function M.organize_import()
    local err, ret = M.a2sync('organizeImport', {}, 1000)
    if err then
        if ret == 'timeout' then
            vim.notify('organizeImport timeout', vim.log.levels.WARN)
        else
            vim.notify('No action for organizeImport', vim.log.levels.WARN)
        end
    end
end

function M.accept_complete()
    local mode = api.nvim_get_mode().mode
    if mode == 'i' then
        return utils.termcodes['<C-l>']
    elseif mode == 'ic' then
        local ei_bak = vim.o.ei
        vim.o.ei = 'CompleteDone'
        vim.schedule(function()
            vim.o.ei = ei_bak
            fn.CocActionAsync('stopCompletion')
        end)
        return utils.termcodes['<C-y>']
    else
        return utils.termcodes['<Ignore>']
    end
end

function M.rename()
    vim.g.coc_jump_locations = nil
    fn.CocActionAsync('rename', '', function(err, res)
        if err == vim.NIL and res then
            local loc = vim.g.coc_jump_locations
            if loc then
                local uri = vim.uri_from_bufnr(0)
                local dont_open = true
                for _, lo in ipairs(loc) do
                    if lo.uri ~= uri then
                        dont_open = false
                        break
                    end
                end
                M.jump2loc(loc, dont_open)
            end
        end
    end)
end

function M.post_open_float()
    local winid = vim.g.coc_last_float_win
    if winid and api.nvim_win_is_valid(winid) then
        local bufnr = api.nvim_win_get_buf(winid)
        api.nvim_buf_call(bufnr, function()
            vim.wo[winid].showbreak = 'NONE'
        end)
    end
end

function M.skip_snippet()
    fn.CocActionAsync('snippetNext')
    return utils.termcodes['<BS>']
end

function M.scroll(down)
    if #fn['coc#float#get_float_win_list']() > 0 then
        return fn['coc#float#scroll'](down)
    else
        return down and utils.termcodes['<C-f>'] or utils.termcodes['<C-b>']
    end
end

function M.scroll_insert(right)
    if #fn['coc#float#get_float_win_list']() > 0 and fn.pumvisible() == 0 and
        api.nvim_get_current_win() ~= vim.g.coc_last_float_win then
        return fn['coc#float#scroll'](right)
    else
        return right and utils.termcodes['<Right>'] or utils.termcodes['<Left>']
    end
end

function M.sign_icon(level)
    return sign_icons[level]
end

function M.did_init(silent)
    if vim.g.coc_service_initialized == 0 then
        if silent then
            vim.notify([[coc.nvim hasn't initialized]], vim.log.levels.WARN)
        end
        return false
    end
    return true
end

function M.initialize()
    diag_qfid = -1

    fn['coc#config']('languageserver.lua.settings.Lua.workspace',
        {library = {[vim.env.VIMRUNTIME .. '/lua'] = true}})

    fn['coc#config']('snippets', {textmateSnippetsRoots = {fn.stdpath('config') .. '/snippets'}})
    fn.CocActionAsync('reloadExtension', 'coc-snippets')

    local diag_config = fn['coc#util#get_config']('diagnostic')
    sign_icons = {
        hint = diag_config.hintSign,
        info = diag_config.infoSign,
        warning = diag_config.warningSign,
        error = diag_config.errorSign
    }

    cmd([[
        aug Coc
            au!
            au User CocLocationsChange ++nested lua require('plugs.coc').jump2loc()
            au User CocDiagnosticChange ++nested lua require('plugs.coc').diagnostic_change()
            au CursorHold * sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)
            au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
            au VimLeavePre * if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif
            au FileType list lua vim.cmd('pa nvim-bqf') require('bqf.magicwin.handler').attach()
            au User CocOpenFloat lua require('plugs.coc').post_open_float()
        aug END

        hi link CocSemVariable TSVariable
        hi link CocSemNamespace Namespace
        hi link CocSemClass Type
        hi link CocSemEnum Number
        hi link CocSemEnumMember Enum
    ]])

    cmd('hi! link CocHighlightText CurrentWord')
    if vim.g.colors_name == 'one' then
        cmd('hi! CocFadeOut guifg=#928374')
        cmd('hi! CocErrorSign guifg=#be5046')
        cmd('hi! CocWarningSign guifg=#e5c07b')
        cmd('hi! CocWarningHighlight gui=undercurl guisp=#e5c07b')
        cmd('hi! CocErrorHighlight gui=undercurl guisp=#be5046')
        cmd('hi! CocCodeLens gui=italic guifg=#5e5e5e')
    end

    map('i', '<C-space>', 'coc#refresh()', {noremap = true, expr = true, silent = true})
    map('n', '<C-f>', [[v:lua.require'plugs.coc'.scroll(v:true)]],
        {noremap = true, expr = true, silent = true})
    map('n', '<C-b>', [[v:lua.require'plugs.coc'.scroll(v:false)]],
        {noremap = true, expr = true, silent = true})
    map('s', '<C-f>', [[v:lua.require'plugs.coc'.scroll(v:true)]],
        {noremap = true, expr = true, silent = true})
    map('s', '<C-b>', [[v:lua.require'plugs.coc'.scroll(v:false)]],
        {noremap = true, expr = true, silent = true})
    map('i', '<C-f>', [[v:lua.require'plugs.coc'.scroll_insert(v:true)]],
        {noremap = true, expr = true, silent = true})
    map('i', '<C-b>', [[v:lua.require'plugs.coc'.scroll_insert(v:false)]],
        {noremap = true, expr = true, silent = true})

    map('i', '<C-]>', [[!get(b:, 'coc_snippet_active') ? "\<C-]>" : "\<C-j>"]], {expr = true})
    map('s', '<C-]>', [[v:lua.require'plugs.coc'.skip_snippet()]], {noremap = true, expr = true})
    map('s', '<Bs>', '<C-g>"_c')
    map('s', '<Del>', '<C-g>"_c')
    map('s', '<C-h>', '<C-g>"_c')
    map('s', '<C-w>', '<Esc>a')
    map('s', '<C-o>', '<Nop>')
    map('s', '<C-o>o', '<Esc>a<C-o>o')

    map('n', '[d', '<Plug>(coc-diagnostic-prev)', {})
    map('n', ']d', '<Plug>(coc-diagnostic-next)', {})

    map('n', 'gd', [[<Cmd>lua require('plugs.coc').go2def()<CR>]])
    map('n', 'gy', [[<Cmd>call CocActionAsync('jumpTypeDefinition', 'drop')<CR>]])
    map('n', 'gi', [[<Cmd>call CocActionAsync('jumpImplementation', 'drop')<CR>]])
    map('n', 'gr', [[<Cmd>call CocActionAsync('jumpUsed', 'drop')<CR>]])

    map('n', 'K', [[<Cmd>lua require('plugs.coc').show_documentation()<CR>]])

    map('n', '<Leader>rn', [[<Cmd>lua require('plugs.coc').rename()<CR>]])

    map('n', '<Leader>ac', [[<Cmd>lua require('plugs.coc').code_action('')<CR>]])
    map('n', '<M-CR>', [[<Cmd>lua require('plugs.coc').code_action({'cursor', 'line'})<CR>]])
    map('x', '<M-CR>', [[:<C-u>lua require('plugs.coc').code_action(vim.fn.visualmode())<CR>]])

    map('n', '<Leader>al', '<Plug>(coc-codelens-action)', {silent = true})

    map('x', '<Leader>s', '<Plug>(coc-snippets-select)', {})
    map('n', '<Leader>so', '<Cmd>CocCommand snippets.openSnippetFiles<CR>')

    map('n', '<Leader>qi', [[<Cmd>lua require('plugs.coc').organize_import()<CR>]])
    map('n', '<M-q>', [[<Cmd>lua vim.notify(vim.fn.CocAction('getCurrentFunctionSymbol'))<CR>]])
    map('n', '<Leader>qd', [[<Cmd>lua require('plugs.coc').diagnostic()<CR>]])

    map('i', '<C-l>', [[v:lua.require'plugs.coc'.accept_complete()]], {noremap = true, expr = true})

    cmd([[com! -nargs=0 DiagnosticToggleBuffer call CocAction('diagnosticToggleBuffer')]])
    cmd([[com! -nargs=0 CocOutput CocCommand workspace.showOutput]])
    map('n', '<Leader>sf', [[<Cmd>CocCommand clangd.switchSourceHeader<CR>]])

    map('n', '<Leader>st', [[<Cmd>CocCommand go.test.toggle<CR>]])
    map('n', '<Leader>tf', [[<Cmd>CocCommand go.test.generate.function<CR>]])
    map('x', '<Leader>tf', [[:CocCommand go.test.generate.function<CR>]])
end

return M
