-- Hooks render.Capture to determine if anyone is trying to take a screenshot

local screengrab = {}
local origCapture = render.Capture

screengrab.last_screengrab_time = 0
screengrab.threshold = 10 -- seconds

function screengrab.is_screengrab_recent()
    return (SysTime() - screengrab.last_screengrab_time) <= screengrab.threshold
end

function screengrab.get_time_since_last_screengrab()
    return SysTime() - screengrab.last_screengrab_time
end

local render = rawget(_G, "render")
rawset(render, "Capture", lje.detour(origCapture, function(tbl)
    lje.hooks.disable()
        lje.con_printf("[Screengrab] $yellow{Detected screengrab attempt.}")
        if type(tbl) == "table" then
            local format = rawget(tbl, "format") or "jpeg"
            lje.con_printf("[Screengrab] Format: $green{%s}", format)
        end
        local traceback = debug.traceback("\n\t")
        lje.con_printf("[Screengrab] Traceback: $red{%s}", traceback)
        screengrab.last_screengrab_time = SysTime()
    lje.hooks.enable()
    return origCapture(tbl)
end))
return screengrab