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
        require("gitdive").browse(range, ev.bang)
        return
    end

    require("gitdive").edit(ev.fargs[1], ev.bang)
end, {
    nargs = "?",
    range = true,
    bang = true,
})
