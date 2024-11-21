local gitdive_os = require("gitdive.os")
local config = require("gitdive.config")

local M = {}

function M.get_revision()
    local head = "HEAD"

    local out = gitdive_os.system({ "git", "rev-parse", "--abbrev-ref", head })
    if not out then
        return
    end

    -- we are in detached head
    if out:sub(1, #head) == head then
        out = gitdive_os.system({ "git", "rev-parse", "--short", head })
        if not out then
            return
        end
    end

    return out
end

---@return string?
function M.get_remote_url()
    local out = gitdive_os.system({ "git", "config", "--get", "remote.origin.url" })
    if not out then
        return
    end

    for _, v in ipairs(config.config.remote_patterns) do
        local matched = { out:match(v[1]) }

        if matched[1] then
            return string.format(v[2], unpack(matched))
        end
    end
end

return M
