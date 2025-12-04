-- No state necessary for this module, just needs a detour
local urls = lje.require("config/urls.lua")
local origHttp = HTTP
local function httpHk(params)
    lje.hooks.disable()
        local url = rawget(params, "url") or ""
        if type(url) ~= "string" then
            url = tostring(url)
        end

        lje.con_print("[HTTP] HTTP request to URL: " .. url)
        if not urls.is_url_allowed(url) then
            lje.con_print("[HTTP] Blocked HTTP request to URL: " .. url)
            lje.hooks.enable()
            return true -- make them think it was queued
        end
    lje.hooks.enable()

    return origHttp(params)
end

rawset(_G, "HTTP", lje.detour(origHttp, httpHk))