local M = {}
local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

local function setup()
    vim.g.nremap = {
        ['d?'] = 's?',
        dv = 'sv',
        dp = 'sp',
        ds = 'sh',
        dh = 'sh',
        dq = '',
        d2o = 's2o',
        d3o = 's3o',
        dd = 'ss',
        s = '<C-s>',
        u = '<C-u>',
        O = 'T',
        ['*'] = '',
        ['#'] = '',
        ['<C-W>gf'] = 'gF',
        ['[m'] = '[f',
        [']m'] = ']f'
    }
    vim.g.xremap = {s = 'S', u = '<C-u>'}
    cmd([[
        aug FugitiveCustom
            au!
            au User FugitiveIndex nmap <silent><buffer> st :Gtabedit <Plug><cfile><Bar>Gdiffsplit!<CR>
        aug end
    ]])
end

function M.index()
    local bufname = api.nvim_buf_get_name(0)
    if fn.winnr('$') == 1 and bufname == '' then
        cmd('Git')
    else
        cmd('tab Git')
    end
    if bufname == '' then
        cmd('sil! noa bw #')
    end
end

-- placeholder for Git difftool --name-only :)
function M.diff_hist()
    local info = fn.getqflist({idx = 0, context = 0})
    local idx, ctx = info.idx, info.context
    if idx and ctx and type(ctx.items) == 'table' then
        local diff = ctx.items[idx].diff or {}
        if #diff == 1 then
            cmd('abo vert diffs ' .. diff[1].filename)
            cmd('winc p')
        end
    end
end

setup()

return M
