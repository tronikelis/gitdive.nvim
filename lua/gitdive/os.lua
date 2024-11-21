local M = {}

---@param url string
function M.open_default(url)
    local bin
    if vim.fn.has("macunix") == 1 then
        bin = "open"
    elseif vim.fn.has("unix") == 1 then
        bin = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
        bin = "start"
    else
        error("unknown os")
        return
    end

    if not M.system({ bin, url }) then
        error("can't open " .. url)
    end
end

---@param cmd string[]
---@return string?
function M.system(cmd)
    local cwd = vim.fn.expand("%:p:h") or vim.fn.getcwd()
    local out = vim.system(cmd, { cwd }):wait()
    if out.code == 0 then
        return out.stdout or ""
    end
end

return M
