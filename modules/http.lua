-- No state necessary for this module, just needs a detour

local ALLOWED_HTTP_URLS = {
    ".*github%.com.*",
    ".*pastebin%.com.*",
}

local origHttp = HTTP
local function httpHk(params)
    lje.hooks.disable()
        local url = rawget(params, "url") or ""
        if type(url) ~= "string" then
            url = tostring(url)
        end

        lje.con_print("HTTP request to URL: " .. url)
        local allowed = false

        for _, pattern in ipairs(ALLOWED_HTTP_URLS) do
            if string.match(url, pattern) then
                allowed = true
                break
            end
        end

        if not allowed then
            lje.con_print("Blocked HTTP request to disallowed URL: " .. url)
            lje.hooks.enable()
            return true -- make them think it was queued
        end
    lje.hooks.enable()

    return origHttp(params)
end

rawset(_G, "HTTP", lje.detour(origHttp, httpHk))