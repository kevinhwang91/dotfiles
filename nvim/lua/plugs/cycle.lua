local M = {}
local fn = vim.fn

local g = vim.g
local map = require('remap').map

local function init()
    g.cycle_default_groups = {
        {{'true', 'false'}}, {{'enable', 'disable'}}, {{'yes', 'no'}}, {{'on', 'off'}},
        {{'and', 'or'}}, {{'up', 'down'}}, {{'above', 'below'}}, {{'left', 'right'}},
        {{'in', 'out'}}, {{'top', 'bottom'}}, {{'before', 'after'}}, {{'forward', 'backward'}},
        {{'width', 'height'}}, {{'push', 'pull'}}, {{'max', 'min'}}, {{'new', 'old'}},
        {{'dark', 'light'}}, {{'good', 'bad'}}, {{'floor', 'ceil'}}, {{'read', 'write'}},
        {{'get', 'set'}}, {{'upper', 'lower'}}, {{'open', 'close'}}, {{'&&', '||'}}, {{'==', '!='}},
        {{'>=', '<='}}, {{'<<', '>>'}}, {{'++', '--'}},
        {{'trace', 'debug', 'info', 'warn', 'error', 'fatal'}}, {{',', '，'}}, {{'.', '。'}},
        {{':', '：'}}, {{'?', '？'}}, {{'是', '否'}}, {{'(:)', '（:）'}, 'sub_pairs'}, {
            {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'},
            'hard_case', {name = 'Days'}
        }, {
            {
                'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
                'September', 'October', 'November', 'December'
            }, 'hard_case', {name = 'Months'}
        }, {'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'}
    }
    g.cycle_default_groups_for_python = {{{'elif', 'if'}}}
    g.cycle_default_groups_for_sh = {{{'elif', 'if'}}}
    g.cycle_default_groups_for_zsh = {{{'elif', 'if'}}, {{'((:))', '[[:]]'}, 'sub_pairs'}}
    g.cycle_default_groups_for_vim = {{{'elseif', 'if'}}}
    g.cycle_default_groups_for_lua = {{{'elseif', 'if'}}, {{'==', '~='}}, {{'pairs', 'ipairs'}}}
    g.cycle_default_groups_for_go = {
        {{'==', '!='}}, {{':=', '='}}, {{'interface', 'struct'}},
        {{'int', 'int8', 'int16', 'int32', 'int64'}},
        {{'uint', 'uint8', 'uint16', 'uint32', 'uint64'}}, {{'float32', 'float64'}},
        {{'complex64', 'complex128'}}
    }
    local javascript_group = {{{'===', '!=='}}, {{'let', 'const', 'var'}}}
    g.cycle_default_groups_for_javascript = javascript_group
    g.cycle_default_groups_for_typescript = vim.list_extend({{{'public', 'private', 'protected'}}},
        javascript_group)
    map('n', '<Plug>CycleFallbackNext', '<C-a>')
    map('n', '<Plug>CycleFallbackPrev', '<C-x>')
    map('n', '<C-a>', '<Plug>CycleNext', {})
    map('x', '<C-a>', '<Plug>CycleNext', {})
    map('s', '<C-a>', '<C-g>o<Esc><Plug>CycleNext', {})
    map('n', '<C-x>', '<Plug>CyclePrev', {})
    map('x', '<C-x>', '<Plug>CyclePrev', {})
    map('s', '<C-x>', '<C-g>o<Esc><Plug>CycleNext', {})

    fn['cycle#reset_ft_groups']()
end

init()

return M
