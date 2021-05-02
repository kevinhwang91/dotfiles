local M = {}
local p_debug = vim.fn.getenv('DEBUG_PLENARY')
if p_debug == vim.NIL then
    p_debug = false
end

local levels = {debug = 1, info = 2, warn = 3, error = 4}

function M.log(config)
    local default_config = {plugin = 'plenary', level = p_debug and 'debug' or 'info'}

    config = vim.tbl_deep_extend('force', default_config, config)

    local outfile = ('%s/%s.log'):format(vim.api.nvim_call_function('stdpath', {'cache'}), 'kevin')

    local obj = config

    local make_string = function(...)
        local t = {}
        for i = 1, select('#', ...) do
            local x = select(i, ...)
            t[#t + 1] = type(x) == 'table' and vim.inspect(x) or tostring(x)
        end
        return table.concat(t, ' ')
    end

    local log_at_level = function(level, level_config, message_maker, ...)
        if level < levels[config.level] then
            return
        end
        local nameupper = level_config.name:upper()

        local msg = message_maker(...)
        local info = debug.getinfo(1, 'Sl')
        local lineinfo = info.short_src .. ':' .. info.currentline

        local fp = assert(io.open(outfile, 'a'))
        local str = string.format('[%-6s%s] %s: %s\n', nameupper, os.date(), lineinfo, msg)
        fp:write(str)
        fp:close()
    end

    for i, x in ipairs(config.modes) do
        obj[x.name] = function(...)
            return log_at_level(i, x, make_string, ...)
        end

        obj[('fmt_%s'):format(x.name)] = function(...)
            return log_at_level(i, x, function(...)
                local passed = {...}
                local fmt = table.remove(passed, 1)
                local inspected = {}
                for _, v in ipairs(passed) do
                    table.insert(inspected, vim.inspect(v))
                end
                return string.format(fmt, unpack(inspected))
            end, ...)
        end
    end

    return obj
end

return M
