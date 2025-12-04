local urls = {}

urls.ALLOWED_PATTERNS = {
    ".*github%.com.*",
    ".*pastebin%.com.*",
    "asset://.*",
    "data:.*",
    ".*steamcommunity%.com/sharedfiles/filedetails/.*",
}

function urls.is_url_allowed(url)
    for _, pattern in ipairs(urls.ALLOWED_PATTERNS) do
        if string.match(url, pattern) then
            return true
        end
    end
    return false
end

return urls