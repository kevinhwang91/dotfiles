local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local gittool = require('gittool')
local coc = require('plugs.coc')

local function save_doc(bufnr)
    vim.schedule(function()
        api.nvim_buf_call(bufnr, function()
            cmd('sil! up')
        end)
    end)
end

function M.format_doc()
    gittool.root_exe(function()
        if vim.g.coc_service_initialized == 1 then
            local bufnr = api.nvim_get_current_buf()
            local err = coc.a2sync('hasProvider', {'format'}, 2000)
            if not err then
                fn.CocActionAsync('format', '', function(e, _)
                    if e ~= vim.NIL then
                        api.nvim_buf_call(bufnr, function()
                            cmd('Neoformat')
                            cmd('sil! up')
                        end)
                    else
                        save_doc(bufnr)
                    end
                end)
            end
        else
            cmd('Neoformat')
            cmd('sil! up')
        end
    end)
end

function M.format_selected(mode)
    if vim.g.coc_service_initialized == 0 then
        vim.notify([[coc.nvim hasn't initialized]], vim.log.levels.WARN)
        return
    end

    gittool.root_exe(function()
        local err = coc.a2sync('hasProvider', {mode and 'formatRange' or 'format'}, 2000)
        if not err then
            local bufnr = api.nvim_get_current_buf()
            fn.CocActionAsync(mode and 'formatSelected' or 'format', mode, function(e, _)
                if e ~= vim.NIL then
                    vim.notify(e, vim.log.levels.WARN)
                else
                    save_doc(bufnr)
                end
            end)
        end
    end)
end

local function init()
    local g = vim.g
    g.neoformat_only_msg_on_error = 1
    g.neoformat_basic_format_align = 1
    g.neoformat_basic_format_retab = 1
    g.neoformat_basic_format_trim = 1

    -- c
    g.neoformat_enabled_c = {'clangformat'}

    -- python
    g.neoformat_enabled_python = {'autopep8'}

    -- lua
    g.neoformat_enabled_lua = {'luaformat'}

    -- json
    g.neoformat_enabled_json = {'jq'}
    g.neoformat_json_jq = {exe = 'jq', args = {'--indent', '4', '--tab'}, stdin = 1}

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

init()

return M
