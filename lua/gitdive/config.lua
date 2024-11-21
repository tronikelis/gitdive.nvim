local M = {
    config = {
        -- if not specified, opening revisions (branches) with "/" in nvim will not work for some hosts
        -- this incurs a `ls-remote` call to guess correctly
        -- this is only required for hosts that do not escape "/" in revisions in url
        guess_revision = { "github" },
        -- converts local git remote url into browser base url
        remote_url_patterns = {
            { "^(https?://.*)%.git", "%s" },
            { "^git@(.+):(.+)%.git", "https://%s/%s" },
        },
        -- converts browser url into parsed url
        ---@type [string, fun(matches: string[]): gitdive.ParsedUrl][]
        url_patterns = {
            {
                "^https://github.com/.-/.-/tree/(.-)/(.+)#L(%d*)-?L?(%d*)",
                function(...)
                    local m = { ... }
                    return {
                        revision = m[1],
                        filepath = m[2],
                        range = {
                            from = tonumber(m[3]),
                            to = tonumber(m[4] or m[3]),
                        },
                    }
                end,
            },
            {
                "^https://github.com/.-/.-/blob/(.-)/(.+)#L(%d*)-?L?(%d*)",
                function(...)
                    local m = { ... }
                    return {
                        revision = m[1],
                        filepath = m[2],
                        range = {
                            from = tonumber(m[3]),
                            to = tonumber(m[4] or m[3]),
                        },
                    }
                end,
            },
            {
                "^https://github.com/.-/.-/tree/(.-)/(.+)",
                function(...)
                    local m = { ... }
                    return {
                        revision = m[1],
                        filepath = m[2],
                    }
                end,
            },
            {
                "^https://github.com/.-/.-/blob/(.-)/(.+)",
                function(...)
                    local m = { ... }
                    return {
                        revision = m[1],
                        filepath = m[2],
                    }
                end,
            },
        },
        -- converts into relative browser url
        ---@type table<string, fun(string, string, gitdive.Range?): string>
        host_to_pathname = {
            github = function(filepath, revision, range)
                local path = string.format("/blob/%s/%s", revision, filepath)

                if range then
                    path = path .. string.format("#L%d-L%d", range.from, range.to)
                end

                return path
            end,
        },
        ---@param remote_url string
        ---@return string?
        get_host = function(remote_url)
            if remote_url:find("https://github%.com") then
                return "github"
            end
        end,
        ---@return string
        get_absolute_file = function()
            return vim.fn.expand("%:p")
        end,
    },
}

return M
