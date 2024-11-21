local gitdive_os = require("gitdive.os")
local gitdive_buf = require("gitdive.buf")
local gitdive_git = require("gitdive.git")
local config = require("gitdive.config")

local M = {}

---@class gitdive.Range
---@field from number
---@field to number

---@class gitdive.ParsedUrl
---@field revision string
---@field filepath string
---@field range gitdive.Range?

---@param range gitdive.Range?
function M.browse(range)
    local remote_url = gitdive_git.get_remote_url()
    if not remote_url then
        error("can't get remote url")
    end

    local host = config.config.get_host(remote_url)
    if not host then
        error("unknown git host")
    end

    range = range or gitdive_buf.get_range()

    local filepath = gitdive_buf.get_relative_file()
    if not filepath then
        error("can't get relative file path")
    end

    local revision = gitdive_git.get_revision()
    if not revision then
        error("can't get revision")
    end

    local pathname = config.config.host_to_pathname[host](filepath, revision, range)
    gitdive_os.open_default(vim.fs.joinpath(remote_url, pathname))
end

---@param farg string
function M.edit(farg)
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
        error("can't parse url")
    end

    gitdive_buf.edit_relative_file(parsed_url.filepath)

    if parsed_url.range then
        vim.cmd([[normal! m']]) -- add current cursor position to the jump list
        vim.api.nvim_win_set_cursor(0, { parsed_url.range.from, 0 })
    end
end

function M.setup(opts)
    opts = opts or {}
    config.config = vim.tbl_deep_extend("force", config.config, opts)

    vim.api.nvim_create_user_command("GitDive", function(ev)
        ---@type gitdive.Range?
        local range

        if ev.count ~= -1 then
            range = {
                from = ev.line1,
                to = ev.line2,
            }
        end

        if not ev.fargs[1] then
            M.browse(range)
            return
        end

        M.edit(ev.fargs[1])
    end, {
        nargs = "?",
        range = true,
        bang = true,
    })
end

return M
