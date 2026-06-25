local M = {}

---@class gitdive.Range
---@field from number
---@field to number

---@class gitdive.ParsedUrl
---@field revision string
---@field filepath string
---@field range gitdive.Range?

---@param range gitdive.Range?
---@param abbrev_ref boolean
function M.browse(range, abbrev_ref)
    local g_buf = require("gitdive.buf")
    local g_git = require("gitdive.git")
    local config = require("gitdive.config")

    local remote_url = g_git.get_remote_browser_base_url()
    if not remote_url then
        error("can't get remote url")
    end

    local host = config.config.get_host(remote_url)
    if not host then
        error("unknown git host")
    end

    range = range or g_buf.get_range()

    local filepath = g_buf.get_relative_file()
    if not filepath then
        error("can't get relative file path")
    end

    local revision = g_git.get_revision(abbrev_ref)
    if not revision then
        error("can't get revision")
    end

    local pathname = config.config.host_to_pathname[host](filepath, revision, range)
    local url = vim.fs.joinpath(remote_url, pathname)
    vim.ui.open(url)
end

---@param farg string
---@param switch boolean
function M.edit(farg, switch)
    local g_buf = require("gitdive.buf")
    local g_git = require("gitdive.git")
    local config = require("gitdive.config")

    local remote_url = g_git.get_remote_browser_base_url()
    if not remote_url then
        error("can't get remote url")
    end

    local host = config.config.get_host(remote_url)
    if not host then
        error("unknown git host")
    end

    ---@type gitdive.ParsedUrl?
    local parsed_url

    for _, v in ipairs(config.config.url_patterns) do
        local matched = { farg:match(v[1]) }

        if matched[1] then
            parsed_url = v[2](unpack(matched))
            break
        end
    end
    if not parsed_url then
        error("couldn't get parsed_url")
    end

    parsed_url.filepath = vim.uri_decode(parsed_url.filepath)

    if vim.list_contains(config.config.guess_revision, host) then
        parsed_url = g_git.guess_revision_from_url(parsed_url)
        if not parsed_url then
            error("couldn't guess revision")
        end
    end

    if switch then
        if not g_git.switch_revision(parsed_url.revision) then
            error("can't switch revision")
        end
    end

    g_buf.edit_relative_file(parsed_url.filepath)

    if parsed_url.range then
        vim.cmd([[normal! m']]) -- add current cursor position to the jump list
        vim.api.nvim_win_set_cursor(0, { parsed_url.range.from, 0 })
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "nv", false)

        if parsed_url.range.to and parsed_url.range.to ~= parsed_url.range.from then
            vim.schedule(function()
                vim.cmd([[normal! V]])
                vim.api.nvim_win_set_cursor(0, { parsed_url.range.to, 0 })
            end)
        end
    end
end

---@param opts table?
function M.setup(opts)
    local config = require("gitdive.config")
    opts = opts or {}
    config.config = vim.tbl_deep_extend("force", config.config, opts)
end

return M
