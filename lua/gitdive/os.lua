local config = require("gitdive.config")

local M = {}

---@param cmd string[]
---@return string?
function M.system(cmd)
    local cwd = vim.fn.fnamemodify(config.config.get_absolute_file(), ":h")
    local out = vim.system(cmd, { cwd }):wait()
    if out.code == 0 then
        return vim.trim(out.stdout or "")
    end
end

return M
