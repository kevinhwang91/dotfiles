local M = {}

function M.reload_module(m_name)
    for p in pairs(package.loaded) do
        if p:find('^' .. m_name) then
            package.loaded[p] = nil
        end
    end
end

return M
