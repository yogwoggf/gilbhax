-- No state necessary for this module, just needs a detour
local urls = lje.require("config/urls.lua")
local origHttp = HTTP
local function httpHk(params)
    lje.hooks.disable()
    lje.env.disable_metatables()
        local url = rawget(params, "url") or ""
        if type(url) ~= "string" then
            url = tostring(url)
        end

        lje.con_printf("[HTTP] HTTP request to URL: $yellow{%s}", url)
        if not urls.is_url_allowed(url) then
            lje.con_printf("[HTTP] Blocked HTTP request to URL: $red{%s}", url)
            lje.env.enable_metatables()
            lje.hooks.enable()
            return true -- make them think it was queued
        end
    lje.env.enable_metatables()
    lje.hooks.enable()

    return origHttp(params)
end

rawset(_G, "HTTP", lje.detour(origHttp, httpHk))