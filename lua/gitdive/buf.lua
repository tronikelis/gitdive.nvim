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

    vim.cmd.e(vim.fs.joinpath(git_dir, filepath))
end

---@return gitdive.Range?
function M.get_range()
    if vim.api.nvim_get_mode().mode ~= "v" then
        return
    end

    return {
        from = vim.api.nvim_buf_get_mark(0, "<")[1],
        to = vim.api.nvim_buf_get_mark(0, ">")[1],
    }
end

return M
