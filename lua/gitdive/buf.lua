local config = require("gitdive.config")

local M = {}

---@return string?
function M.get_relative_file()
    local git_dir = vim.fs.root(0, ".git")
    if not git_dir then
        return
    end

    local file = config.config.get_absolute_file()
    file = file:sub(#git_dir + 2)

    return file
end

---@param filepath string
function M.edit_relative_file(filepath)
    local git_dir = vim.fs.root(0, ".git")
    if not git_dir then
        return
    end

    local file = vim.fs.joinpath(git_dir, filepath)

    if not vim.uv.fs_statfs(file) then
        error("can't edit non existent file")
    end

    vim.cmd.e(file)
end

---@return gitdive.Range?
function M.get_range()
    if string.lower(vim.api.nvim_get_mode().mode) ~= "v" then
        return
    end

    return {
        from = vim.fn.line("v"),
        to = vim.fn.line("."),
    }
end

return M
