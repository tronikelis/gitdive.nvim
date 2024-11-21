# 🌊 gitdive.nvim

Dive into and from remote repositories with style

<!--toc:start-->
- [🌊 gitdive.nvim](#🌊-gitdivenvim)
  - [Quick start](#quick-start)
  - [Config](#config)
  - [Recipes](#recipes)
  - [Multiple remote host support](#multiple-remote-host-support)
  - [Inspired by / alternatives](#inspired-by-alternatives)
<!--toc:end-->

## Quick start

Install

```lua
{
    "tronikelis/gitdive.nvim",
    opts = {}
}
```

Dive in

`[range]GitDive` current file -> browser

Dive from

`GitDive[!] <url>` browser -> file

`!` switches revision when opening file from browser url


## Config

Default options

```lua
{
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
}
```

## Recipes

Oil.nvim support

```lua
{

    opts = {
        get_absolute_file = function()
            if vim.bo.filetype == "oil" then
                return require("oil").get_current_dir()
            end

            return vim.fn.expand("%:p")
        end,
    },
}
```

## Multiple remote host support

OOTB only github is supported, but more repo hosts can be added
by changing the configuration, specifically the `remote_url_patterns`
`get_host` `url_patterns` `host_to_pathname`

Or even better open a PR that changes the default config, so everyone benefits ;)

## Inspired by / alternatives

- [gitportal.nvim](https://github.com/trevorhauter/gitportal.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
