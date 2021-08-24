local M = {}
local cmd = vim.cmd

local g = vim.g

local map = require('remap').map

function M.bqf()
    if g.colors_name == 'one' then
        cmd('hi! link BqfPreviewBorder Parameter')
    end

    require('bqf').setup({
        auto_enable = true,
        auto_resize_height = true,
        preview = {auto_preview = true},
        func_map = {split = '<C-s>'},
        filter = {fzf = {action_for = {['ctrl-s'] = 'split'}}}
    })
end

function M.hlslens()
    require('hlslens').setup({
        auto_enable = true,
        enable_incsearch = true,
        calm_down = false,
        nearest_only = false,
        nearest_float_when = 'auto',
        float_shadow_blend = 50,
        virt_priority = 100
    })

    cmd([[com! HlSearchLensToggle lua require('hlslens').toggle()]])

    map('n', 'n',
        [[<Cmd>execute('norm! ' . v:count1 . 'nzv')<CR><Cmd>lua require('hlslens').start()<CR>]])
    map('n', 'N',
        [[<Cmd>execute('norm! ' . v:count1 . 'Nzv')<CR><Cmd>lua require('hlslens').start()<CR>]])
    map('', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})
end

function M.surround()
    map('n', 'sd', '<Plug>Dsurround', {})
    map('n', 'cs', '<Plug>Csurround', {})
    map('n', 'cS', '<Plug>CSurround', {})
    map('n', 'ys', '<Plug>Ysurround', {})
    map('n', 'yS', '<Plug>YSurround', {})
    map('n', 'yss', '<Plug>Yssurround', {})
    map('n', 'ygs', '<Plug>YSsurround', {})
    map('x', 'S', '<Plug>VSurround', {})
    map('x', 'gS', '<Plug>VgSurround', {})
end

function M.visualmulti()
    g.VM_theme = 'codedark'
    g.VM_highlight_matches = ''
    g.VM_show_warnings = 0
    g.VM_silent_exit = 1
    g.VM_default_mappings = 1
    g.VM_maps = {
        Delete = 's',
        Undo = '<C-u>',
        Redo = '<C-r>',
        ['Select Operator'] = 'v',
        ['Select Cursor Up'] = '<M-C-k>',
        ['Select Cursor Down'] = '<M-C-j>',
        ['Move Left'] = '<M-C-h>',
        ['Move Right'] = '<M-C-l>'
    }
    map('n', '<C-n>', '<Plug>(VM-Find-Under)', {})
    map('x', '<C-n>', '<Plug>(VM-Find-Subword-Under)', {})
    map('n', [[<Leader>\]], '<Plug>(VM-Add-Cursor-At-Pos)', {})
    map('n', '<Leader>/', '<Plug>(VM-Start-Regex-Search)', {})
    map('n', '<Leader>A', '<Plug>(VM-Select-All)', {})
    map('x', '<Leader>A', '<Plug>(VM-Visual-All)', {})
    map('n', '<Leader>gs', '<Plug>(VM-Reselect-Last)', {})
    map('n', '<M-C-k>', '<Plug>(VM-Select-Cursor-Up)', {})
    map('n', '<M-C-j>', '<Plug>(VM-Select-Cursor-Down)', {})
    map('n', 'g/', '<Cmd>VMSearch<CR>')

    cmd([[
        aug VisualMulti
            au!
            au User visual_multi_start lua require('plugs.vm').start()
            au User visual_multi_exit lua require('plugs.vm').exit()
            au User visual_multi_mappings lua require('plugs.vm').mappings()
        aug END
    ]])
end

function M.cleverf()
    g.clever_f_across_no_line = 1
    g.clever_f_timeout_ms = 1
    map('', ';', '<Plug>(clever-f-repeat-forward)', {})
    map('', ',', '<Plug>(clever-f-repeat-back)', {})
end

function M.choosewin()
    g.choosewin_blink_on_land = 0
    g.choosewin_color_label = {gui = {'#98c379', '#202326', 'bold'}}
    g.choosewin_color_label_current = {gui = {'#528bff', '#202326', 'bold'}}
    g.choosewin_color_other = {gui = {'#2c323c'}}
    map('n', '<M-0>', '<Cmd>ChooseWin<CR>')
end

function M.grepper()
    g.grepper = {
        tools = {'rg', 'grep'},
        dir = 'repo,file',
        open = 0,
        switch = 1,
        jump = 0,
        simple_prompt = 1,
        quickfix = 1,
        searchreg = 1,
        highlight = 0,
        stop = 10000,
        rg = {
            grepprg = 'rg -H --no-heading --vimgrep --smart-case',
            grepformat = '%f:%l:%c:%m,%f:%l:%m'
        }
    }
    map('n', 'gs', [[<Cmd>lua require('yank').set_wv()<CR><Plug>(GrepperOperator)]], {})
    map('x', 'gs', '<Plug>(GrepperOperator)', {})
    map('n', '<Leader>rg', [[<Cmd>Grepper -tool rg<CR>]])
    cmd(([[
        aug Grepper
            au!
            au User Grepper ++nested %s | %s
        aug END
    ]]):format(
        [[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]],
        'bo cope'))

    -- if fn.executable('rg') then
    --     vim.o.grepprg = [[rg --vimgrep --no-heading --smart-case]]
    --     vim.o.grepformat = [[%f:%l:%c:%m,%f:%l:%m]]
    -- end
end

function M.exchange()
    map('n', 'cx', '<Plug>(Exchange)', {})
    map('x', 'X', '<Plug>(Exchange)', {})
    map('n', 'cx;', '<Plug>(ExchangeClear)', {})
    map('n', 'cxx', '<Plug>(ExchangeLine)', {})
end

function M.matchup()
    g.matchup_surround_enabled = 1
    g.matchup_matchparen_timeout = 100
    g.matchup_matchparen_deferred = 1
    g.matchup_matchparen_deferred_show_delay = 50
    g.matchup_matchparen_deferred_hide_delay = 300
    g.matchup_matchparen_hi_surround_always = 1
    g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'CurrentWord'}
    g.matchup_delim_start_plaintext = 1
    g.matchup_motion_override_Npercent = 0
    g.matchup_motion_cursor_end = 0
    g.matchup_mappings_enabled = 0

    cmd('hi! link MatchWord Underlined')

    map('n', '%', '<Plug>(matchup-%)', {})
    map('x', '%', '<Plug>(matchup-%)', {})
    map('o', '%', '<Plug>(matchup-%)', {})
    map('n', '[5', '<Plug>(matchup-[%)', {})
    map('x', '[5', '<Plug>(matchup-[%)', {})
    map('o', '[5', '<Plug>(matchup-[%)', {})
    map('n', ']5', '<Plug>(matchup-]%)', {})
    map('x', ']5', '<Plug>(matchup-]%)', {})
    map('o', ']5', '<Plug>(matchup-]%)', {})
    map('n', '<Leader>5', '<Plug>(matchup-z%)', {})
    map('x', '<Leader>5', '<Plug>(matchup-z%)', {})
    map('o', '<Leader>5', '<Plug>(matchup-z%)', {})
    map('x', 'a5', '<Plug>(matchup-a%)', {})
    map('o', 'a5', '<Plug>(matchup-a%)', {})
    map('x', 'i5', '<Plug>(matchup-i%)', {})
    map('o', 'i5', '<Plug>(matchup-i%)', {})
    map('n', 'cs5', '<plug>(matchup-cs%)', {})
    map('n', 'sd5', '<plug>(matchup-ds%)', {})

    cmd([[
        aug Mathup
            au!
            autocmd TermOpen * let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
            autocmd FileType qf let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
        aug END
    ]])
end

function M.cycle()
    g.cycle_default_groups = {
        {{'true', 'false'}}, {{'enable', 'disable'}}, {{'yes', 'no'}}, {{'on', 'off'}},
        {{'and', 'or'}}, {{'up', 'down'}}, {{'left', 'right'}}, {{'top', 'bottom'}},
        {{'before', 'after'}}, {{'width', 'height'}}, {{'push', 'pull'}}, {{'max', 'min'}},
        {{'&&', '||'}}, {{'++', '--'}}, {{',', '，'}}, {{'.', '。'}}, {{'?', '？'}},
        {{'是', '否'}}, {{'(:)', '（:）'}, 'sub_pairs'}, {
            {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'},
            'hard_case', {name = 'Days'}
        }, {
            {
                'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
                'September', 'October', 'November', 'December'
            }, 'hard_case', {name = 'Months'}
        }
    }
    g.cycle_default_groups_for_python = {{{'elif', 'else'}}}
    g.cycle_default_groups_for_sh = {{{'elif', 'else'}}}
    g.cycle_default_groups_for_zsh = g.cycle_default_groups_for_sh
    g.cycle_default_groups_for_vim = {{{'elseif', 'else'}}}
    g.cycle_default_groups_for_lua = {{{'elseif', 'else'}}}
    map('n', '<Plug>CycleFallbackNext', '<C-a>')
    map('n', '<Plug>CycleFallbackPrev', '<C-x>')
    map('n', '<C-a>', '<Plug>CycleNext', {})
    map('v', '<C-a>', '<Plug>CycleNext', {})
    map('n', '<C-x>', '<Plug>CyclePrev', {})
    map('v', '<C-x>', '<Plug>CyclePrev', {})
end

function M.gitgutter()
    cmd([[
        hi! link GitGutterAdd Constant
        hi! link GitGutterChange Type
        hi! link GitGutterDelete Identifier
        hi! link GitGutterAddLineNr GitGutterAdd
        hi! link GitGutterChangeLineNr GitGutterChange
        hi! link GitGutterDeleteLineNr GitGutterDelete
        hi! link GitGutterChangeDeleteLineNr GitGutterChangeDeleteLine
        hi! link GitGutterAddIntraLine DiffText
        hi! link GitGutterDeleteIntraLine DiffText
    ]])
    if g.colors_name == 'one' then
        cmd('hi! GitGutterChangeDeleteLine guifg=#be5046')
    end
    map('n', '<Leader>hp', '<Plug>(GitGutterPreviewHunk)', {})
    map('n', '<Leader>hs', '<Plug>(GitGutterStageHunk)', {})
    map('n', '<Leader>hu', '<Plug>(GitGutterUndoHunk)', {})
    map('n', '[c', '<Plug>(GitGutterPrevHunk)', {})
    map('n', ']c', '<Plug>(GitGutterNextHunk)', {})
    map('o', 'ih', '<Plug>(GitGutterTextObjectInnerPending)', {})
    map('o', 'ah', '<Plug>(GitGutterTextObjectOuterPending)', {})
    map('x', 'ih', '<Plug>(GitGutterTextObjectInnerVisual)', {})
    map('x', 'ah', '<Plug>(GitGutterTextObjectOuterVisual)', {})
end

function M.ghline()
    map('', '<Leader>gO', '<Plug>(gh-repo)', {})
    map('', '<Leader>gL', '<Plug>(gh-line)', {})
end

function M.neoformat()
    g.neoformat_only_msg_on_error = 1
    g.neoformat_basic_format_align = 1
    g.neoformat_basic_format_retab = 1
    g.neoformat_basic_format_trim = 1

    -- python
    g.neoformat_enabled_python = {'autopep8'}
    g.neoformat_python_autopep8 = {exe = 'autopep8', args = {'--max-line-length=100'}}

    -- lua
    g.neoformat_enabled_lua = {'luaformat'}
    g.neoformat_lua_luaformat = {exe = 'lua-format'}

    -- javascript
    g.neoformat_enabled_javascript = {'prettier'}

    -- typescript
    g.neoformat_enabled_typescript = {'prettier'}

    -- json
    g.neoformat_enabled_json = {'prettier'}

    -- yaml
    g.neoformat_enabled_yaml = {'prettier'}
    g.neoformat_yaml_prettier = {
        exe = 'prettier',
        args = {'--stdin-filepath', '"%:p"', '--tab-width=2'},
        stdin = 1
    }

    -- sql
    g.neoformat_enabled_sql = {'sqlformatter'}
    g.neoformat_sql_sqlformatter = {exe = 'sql-formatter', args = {'--indent', '4'}, stdin = 1}
end

function M.slime()
    g.slime_python_ipython = 1
    g.slime_target = 'tmux'
    g.slime_default_config = {
        socket_name = vim.split(vim.env.TMUX or '', ',')[1],
        target_pane = ':.'
    }
    map('x', '<C-c><C-c>', '<Plug>SlimeRegionSend', {})
    map('n', '<C-c><C-c>', '<Plug>SlimeParagraphSend', {})
    map('n', '<C-c>v', '<Plug>SlimeConfig', {})
    map('n', '<C-c>l', '<Plug>SlimeLineSend', {})
end

function M.vcoolor()
    map('n', '<Leader>pc', '<Cmd>VCoolor<CR>')
    map('n', '<Leader>yb', '<Cmd>VCoolIns b<CR>')
    map('n', '<Leader>yr', '<Cmd>VCoolIns r<CR>')
end

function M.suda()
    map('n', '<Leader>W', '<Cmd>SudaWrite<CR>')
end

return M
