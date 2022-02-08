local M = {}
local api = vim.api
local fn = vim.fn

local utils = require('kutils')
local remap = require('remap')

local RegFloatWin = setmetatable({bufnr = nil, winid = nil, ns = nil, bremap = nil, reg = nil}, {
    __call = function(self, o)
        self.last_winid = o.last_winid
        self.op_cnt = o.op_cnt
        self.mode = o.mode
        self.rlines = o.rlines
        return self
    end
})

local function read_reg(reg)
    local lines = {}
    for _, e in ipairs(reg) do
        for _, rname in ipairs(e.name) do
            local raw_contexts = fn.getreg(rname, 1)
            if #vim.trim(raw_contexts) > 0 then
                local regtype = fn.getregtype(rname)
                local contents = raw_contexts:gsub('[\r\n]', '\\n')
                local line = (' %s  %s'):format(rname, contents)
                table.insert(lines, {
                    regname = rname,
                    line = line,
                    regtype = regtype,
                    hl_group = e.hl_group
                })
            end
        end
    end
    return lines
end

function RegFloatWin:close()
    local winid = self.winid
    if winid and api.nvim_win_is_valid(winid) then
        api.nvim_win_close(winid, true)
        self.winid = nil
    end
end

function RegFloatWin:open()
    local rlines = read_reg(self.reg)
    local opts = {
        style = 'minimal',
        relative = 'cursor',
        width = 100,
        height = #rlines,
        row = 1,
        col = 1,
        noautocmd = true,
        border = 'rounded'
    }
    local bufnr, winid = self.bufnr, self.winid
    if winid and bufnr then
        bufnr = self.bufnr
        opts.noautocmd = nil
        api.nvim_win_set_config(self.winid, opts)
    else
        bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = 'wipe'
        vim.bo[bufnr].ft = 'reg'

        winid = api.nvim_open_win(bufnr, true, opts)

        vim.wo[winid].wrap = false
        vim.wo[winid].list = true
        vim.wo[winid].winhighlight = 'NormalFloat:Normal'
        vim.wo[winid].winbl = 8
    end
    vim.wo[winid].cursorline = true
    return bufnr, winid, rlines
end

local function go2lastwin(last_winid)
    if last_winid and api.nvim_win_is_valid(last_winid) then
        api.nvim_set_current_win(last_winid)
    end
end

function M.cancel()
    local self = RegFloatWin
    self:close()
    go2lastwin(self.last_winid)
end

function M.handle(rname)
    local self = RegFloatWin
    if not rname then
        local lnum = api.nvim_win_get_cursor(self.winid)[1]
        local register_line = self.rlines[lnum]
        rname = register_line.regname
    end
    self:close()
    go2lastwin(self.last_winid)

    local mode = self.mode
    if mode:match('[is]') then
        api.nvim_paste(fn.getreg(rname), true, -1)
    else
        local keys
        if mode == 'n' then
            if self.op_cnt > 0 then
                keys = self.op_cnt .. '"' .. rname
            else
                keys = '"' .. rname
            end
        elseif mode:match('[vV\x16]') then
            keys = 'gv"' .. rname
        end
        api.nvim_feedkeys(keys, 'n', false)
    end
end

function RegFloatWin:mappings()
    local actions = {['<CR>'] = 'handle()', ['<Esc>'] = 'cancel()'}

    for _, e in ipairs(self.reg) do
        for _, rname in ipairs(e.name) do
            actions[rname] = ('handle(%q)'):format(rname)
            if rname:match('^[a-z]$') then
                local u_rname = rname:upper()
                actions[u_rname] = ('handle(%q)'):format(u_rname)
            end
        end
    end

    local bufnr = self.bufnr
    local opts = {nowait = true, noremap = true, silent = true}
    local fmt = [[<Cmd>lua require('reg').%s<CR>]]
    local bmap = remap.bmap
    for lhs, func in pairs(actions) do
        local rhs = fmt:format(func)
        bmap(bufnr, 'n', lhs, rhs, opts)
        bmap(bufnr, 'i', lhs, rhs, opts)
    end

    bmap(bufnr, 'n', '<C-k>', '<Up>', opts)
    bmap(bufnr, 'i', '<C-k>', '<Up>', opts)
    bmap(bufnr, 'n', '<C-j>', '<Down>', opts)
    bmap(bufnr, 'i', '<C-j>', '<Down>', opts)

    bmap(bufnr, 'n', '<C-p>', '<Up>', opts)
    bmap(bufnr, 'i', '<C-p>', '<Up>', opts)
    bmap(bufnr, 'n', '<C-n>', '<Down>', opts)
    bmap(bufnr, 'i', '<C-n>', '<Down>', opts)

    opts.noremap = false
    for m, t in pairs(self.bremap) do
        for lhs, rhs in pairs(t) do
            bmap(bufnr, m, lhs, rhs, opts)
        end
    end
end

function RegFloatWin:write_buf()
    local lines = vim.tbl_map(function(e)
        return e.line
    end, self.rlines)
    local bufnr = self.bufnr
    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    for i, e in ipairs(self.rlines) do
        api.nvim_buf_set_extmark(bufnr, self.ns, i - 1, 1, {hl_group = e.hl_group, end_col = 2})
    end
    vim.bo[bufnr].modifiable = false
end

function RegFloatWin:run()
    self.bufnr, self.winid, self.rlines = self:open()
    self:mappings()
    self:write_buf()
    api.nvim_win_set_cursor(self.winid, {1, 1})
end

function M.peek(prefix)
    local char
    local wait = vim.wait(400, function()
        char = fn.getcharstr(0)
        return char ~= ''
    end)
    local mode = api.nvim_get_mode().mode
    local ret
    if wait or mode == 'c' then
        char = RegFloatWin.bremap[mode][char] or char
        if mode:match('[is]') then
            ret = utils.termcodes['<C-g>'] .. 'u' .. utils.termcodes['<C-r>'] ..
                      utils.termcodes['<C-o>'] .. char
            if mode == 's' then
                ret = utils.termcodes['<C-g>'] .. '"_c' .. ret
            end
        else
            ret = prefix .. char
        end
    else
        RegFloatWin({mode = mode, op_cnt = vim.v.count, last_winid = api.nvim_get_current_win()})
        vim.schedule(function()
            RegFloatWin:run()
        end)
        if mode == 'i' then
            ret = utils.termcodes['<Ignore>']
        elseif mode == 's' then
            ret = utils.termcodes['<C-g>'] .. '"_c'
        else
            ret = utils.termcodes['<Esc>']
        end
    end
    return ret
end

local function init()
    RegFloatWin.ns = api.nvim_create_namespace('k-reg')
    local bremap = setmetatable({n = {['\''] = '"', [';'] = '+'}, i = {['\''] = '"', [';'] = '+'}},
        {
            __index = function(t)
                return t.n
            end
        })
    bremap.v = bremap.n
    bremap.c = bremap.i
    RegFloatWin.bremap = bremap

    RegFloatWin.reg = {
        {type = 'unnamed', name = {'"'}, hl_group = 'Normal'},
        {type = 'selection', name = {'+', '*'}, hl_group = 'Operator'},
        {type = 'last search pattern', name = {'/'}, hl_group = 'Special'},
        {type = 'read-only', name = {':', '.', '%'}, hl_group = 'Todo'},
        {
            type = 'numbered',
            name = {'0', '1', '2', '3', '4', '5', '7', '8', '9'},
            hl_group = 'Number'
        }, {
            type = 'named',
            name = {
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q',
                'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
            },
            hl_group = 'Character'
        }, {type = 'alternate buffer', name = {'#'}, hl_group = 'Directory'},
        {type = 'expression', name = {'='}, hl_group = 'Directory'},
        {type = 'delete', name = {'-'}, hl_group = 'Identifier'}
    }

    local map = remap.map

    map('n', '"', [[v:lua.require'reg'.peek('"')]], {noremap = true, expr = true})
    map('x', '"', [[v:lua.require'reg'.peek('"')]], {noremap = true, expr = true})
    map('!', '<C-r>', [[v:lua.require'reg'.peek('<C-r>')]], {noremap = true, expr = true})
    map('s', '<C-r>', [[v:lua.require'reg'.peek('<C-r>')]], {noremap = true, expr = true})
end

init()

return M
