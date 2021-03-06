local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local disk_file = vim.env.HOME .. '/.mru_file'
local tmp_file = '/tmp/' .. vim.env.USER .. '_mru_file'
local max = 1000
local count = 0

local function init()
    if fn.filereadable(tmp_file) == 0 then
        M.write2ram()
    end
    M.update(0)

    api.nvim_exec([[
    augroup Mru
        autocmd!
        autocmd BufEnter,BufAdd * lua require('mru').update(vim.fn.expand('<abuf>', 1))
        autocmd VimLeavePre,VimSuspend * lua require('mru').write2disk()
        autocmd FocusLost * lua require('mru').write2disk()
    augroup END')
    ]], false)

    -- https://github.com/neovim/neovim/pull/7670
    -- TODO Neovim + Tmux will fire FocusGained on startup
    if vim.env.TMUX then
        cmd(string.format('autocmd Mru FocusGained * ++once %s',
            [[execute("autocmd Mru FocusGained * lua require('mru').write2ram()")]]))
    else
        cmd([[autocmd Mru FocusGained * lua require('mru').write2ram()]])
    end
end

local function list(file)
    local mru_list = {}
    local fd = io.open(file, 'r')
    if fd then
        for line in fd:lines() do
            local f_existed = io.open(line, 'r')
            if f_existed then
                f_existed:close()
                table.insert(mru_list, line)
            end
        end
        fd:close()
    end
    while #mru_list > max do
        table.remove(mru_list)
    end
    return mru_list
end

local function write_file(file_path, lines)
    local file_path_ = file_path .. '_'
    local fd_ = io.open(file_path_, 'w')
    if fd_ then
        for _, line in ipairs(lines) do
            fd_:write(line .. '\n')
        end
        fd_:close()
        os.rename(file_path_, file_path)
    end
end

function M.list()
    return list(tmp_file)
end

function M.write2disk(mru_list)
    mru_list = not mru_list and list(tmp_file)
    if #mru_list > 0 then
        write_file(disk_file, mru_list)
    end
end

function M.write2ram()
    local mru_list = list(disk_file)
    write_file(tmp_file, mru_list)
end

function M.update(bufnr)
    bufnr = bufnr == 0 and api.nvim_get_current_buf() or tonumber(bufnr)
    local bufname = fn.bufname(bufnr)
    local filename = fn.fnamemodify(bufname, ':p')
    if bufname == '' or vim.bo[bufnr].buftype ~= '' or fn.filereadable(filename) == 0 then
        return
    end

    local mru_list = list(tmp_file)
    local idx = -1
    for i, fname in ipairs(mru_list) do
        if fname == filename then
            idx = i
            break
        end
    end
    if idx == 1 then
        return
    elseif idx > 1 then
        table.remove(mru_list, idx)
    end
    table.insert(mru_list, 1, filename)

    count = (count + 1) % 10
    if count == 0 then
        M.write2disk()
    else
        write_file(tmp_file, mru_list)
    end
end

init()

return M
