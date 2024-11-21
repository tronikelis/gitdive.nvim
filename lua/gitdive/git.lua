local gitdive_os = require("gitdive.os")
local config = require("gitdive.config")

local M = {}

---@return string?
function M.get_revision()
    local head = "HEAD"

    local out = gitdive_os.system({ "git", "rev-parse", "--abbrev-ref", head })
    if not out then
        return
    end

    -- we are in detached head
    if vim.trim(out) == head then
        out = gitdive_os.system({ "git", "rev-parse", "--short", head })
        if not out then
            return
        end
    end

    return vim.trim(out)
end

---@param revision string
---@return boolean
function M.switch_revision(revision)
    if not gitdive_os.system({ "git", "switch", revision }) then
        if not gitdive_os.system({ "git", "switch", revision, "--detach" }) then
            return false
        end
    end

    return true
end

---@return string?
function M.get_remote_url()
    local out = gitdive_os.system({ "git", "config", "--get", "remote.origin.url" })
    if not out then
        return
    end

    for _, v in ipairs(config.config.remote_url_patterns) do
        local matched = { out:match(v[1]) }

        if matched[1] then
            return string.format(v[2], unpack(matched))
        end
    end
end

return M
