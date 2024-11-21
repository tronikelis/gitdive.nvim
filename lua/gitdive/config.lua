local M = {
    config = {
        remote_patterns = {
            { "^(https?://.*)%.git", "%s" },
            { "^git@(.-):(.+)%.git", "https://%s/%s" },
        },
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
                            to = tonumber(m[3]),
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
                            to = tonumber(m[3]),
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
        ---@type table<string, fun(string, string, gitdive.Range?): string>
        host_to_url = {
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
