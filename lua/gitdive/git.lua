local gitdive_os = require("gitdive.os")
local config = require("gitdive.config")

local M = {}

-- as there is literally no way to know whether revision had "/" or not
-- we have to guess this manually, meaning fetching remote revisions
---@param parsed_url gitdive.ParsedUrl
---@return gitdive.ParsedUrl?
function M.guess_revision_from_url(parsed_url)
    local remote = gitdive_os.system({ "git", "config", "--get", "remote.origin.url" })
    if not remote then
        error("can't get remote")
        return
    end

    local out = gitdive_os.system({
        "git",
        "ls-remote",
        "--heads",
        "--exit-code",
        remote,
        string.format("%s*", parsed_url.revision),
    })
    if not out then
        -- probably the revision is a sha
        return parsed_url
    end

    local remote_revisions = {}
    for _, v in ipairs(vim.split(out, "\n")) do
        local rev = v:match("refs/heads/(%S+)")
        if rev then
            remote_revisions[rev] = true
        end
    end

    local rest_slashes = vim.split(parsed_url.filepath, "/")
    local curr = parsed_url.revision

    -- guess the largest revision from the url
    for i, v in ipairs(rest_slashes) do
        if remote_revisions[curr] then
            parsed_url = {
                range = parsed_url.range,
                revision = curr,
                -- steal what is in revision
                filepath = table.concat({ unpack(rest_slashes, i) }, "/"),
            }
        end

        curr = string.format("%s/%s", curr, v)
    end

    return parsed_url
end

---@return string?
function M.get_revision()
    local head = "HEAD"

    local out = gitdive_os.system({ "git", "rev-parse", "--abbrev-ref", head })
    if not out then
        return
    end

    -- we are in detached head
    if out == head then
        out = gitdive_os.system({ "git", "rev-parse", "--short", head })
        if not out then
            return
        end
    end

    return out
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
function M.get_remote_browser_base_url()
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
