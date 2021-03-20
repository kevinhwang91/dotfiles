local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local function init()
    vim.g.undotree_SplitWidth = 45
    vim.g.undotree_SetFocusWhenToggle = 1
    api.nvim_exec([[
        function! Undotree_CustomMap()
            nmap <buffer> <C-u> <Plug>UndotreeUndo
            nunmap <buffer> u
        endfunc
    ]], false)
    cmd('pa undotree')
end

function M.toggle()
    fn['undotree#UndotreeToggle']()
    require('plugs.undotree').clean_undo()
end

-- TODO: always clean filename with '%'
function M.clean_undo()
    local u_dir = vim.o.undodir
    local pre_len = u_dir:len(vim.o.undodir) + 2
    for file in vim.gsplit(fn.globpath(u_dir, '*'), '\n') do
        local fp_per = file:sub(pre_len, -1)
        local fp = fp_per:gsub('%%', '/')
        if fn.empty(fn.glob(fp)) == 1 then
            os.remove(fp)
        end
    end
end

init()

return M
