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
        preview = {auto_preview = true, delay_syntax = 50},
        func_map = {split = '<C-s>', drop = 'o', openc = 'O', tabdrop = '<C-t>'},
        filter = {
            fzf = {
                action_for = {
                    ['enter'] = 'drop',
                    ['ctrl-s'] = 'split',
                    ['ctrl-t'] = 'tab drop',
                    ['ctrl-x'] = ''
                },
                extra_opts = {'-d', '│'}
            }
        }
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
    map('n', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('n', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('n', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('n', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})

    map('x', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('x', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('x', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map('x', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})

    g['asterisk#keeppos'] = 1
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
        dir = 'repo,file',
        simple_prompt = 1,
        searchreg = 1,
        stop = 50000,
        rg = {
            grepprg = 'rg -H --no-heading --max-columns=200 --vimgrep --smart-case',
            grepformat = '%f:%l:%c:%m,%f:%l:%m'
        }
    }
    map('n', 'gs', '<Plug>(GrepperOperator)', {})
    map('x', 'gs', '<Plug>(GrepperOperator)', {})
    map('n', '<Leader>rg', [[<Cmd>Grepper<CR>]])
    cmd(([[
        aug Grepper
            au!
            au User Grepper ++nested %s
        aug END
    ]]):format(
        [[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]))

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

    cmd([[
        aug Mathup
            au!
            autocmd TermOpen * let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
            autocmd FileType qf let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
        aug END
    ]])
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

function M.indentline()
    g.indentLine_enabled = 0
    g.indentLine_char = '▏'
    g.indentLine_setColors = 1
    g.indentLine_defaultGroup = 'Whitespace'
    g.indentLine_faster = 1
end

function M.notify()
    require('notify').setup({
        stages = 'slide',
        timeout = 2000,
        minimum_width = 30,
        render = 'minimal',
        icons = {ERROR = ' ', WARN = ' ', INFO = ' ', DEBUG = ' ', TRACE = ' '}
    })
end

function M.neogen()
    local neogen = require('neogen')
    neogen.setup({enabled = true, input_after_comment = true})
    map('i', '<C-j>', [[<Cmd>lua require('neogen').jump_next()<CR>]])
    map('i', '<C-k>', [[<Cmd>lua require('neogen').jump_prev()<CR>]])
    map('n', '<Leader>dg', [[:Neogen<Space>]], {noremap = true, silent = false})
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
