local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local indentLine_loaded

function M.hook(config)
    if tonumber(config.indent_size) == 2 then
        local bufnr = api.nvim_get_current_buf()
        vim.defer_fn(function()
            local bt = vim.bo[bufnr].bt
            if bt == '' then
                if not indentLine_loaded then
                    cmd('PackerLoad indentLine')
                    indentLine_loaded = true
                end
                api.nvim_buf_call(bufnr, function()
                    cmd('IndentLinesEnable')
                end)
            end
        end, 100)
    end
end

local function init()
    indentLine_loaded = false
    vim.g.EditorConfig_exclude_patterns = {'fugitive://.*'}
    vim.g.EditorConfig_max_line_indicator = 'none'
    vim.g.EditorConfig_preserve_formatoptions = 1
    fn['editorconfig#AddNewHook'](M.hook)
    cmd('EditorConfigReload')
end

init()

return M
