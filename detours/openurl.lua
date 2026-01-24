-- Detours, logs and possibly blocks both Panel:OpenURL and gui.OpenURL
local urls = lje.require("config/urls.lua")
-- running in preinit, so no need to use rawget or anything

local origPanelOpenURL = FindMetaTable("Panel").OpenURL
local function panelOpenUrlHk(self, url)
    lje.con_printf("[Panel:OpenURL] Attempt to open URL: $yellow{%s}", url)
    if urls.is_url_allowed(url) then
        lje.con_printf("[Panel:OpenURL] Allowing URL: $yellow{%s}", url)
        return origPanelOpenURL(self, url)
    else
        lje.con_printf("[Panel:OpenURL] Blocking URL: $red{%s}", url)
        return
    end
end

FindMetaTable("Panel").OpenURL = lje.detour(origPanelOpenURL, panelOpenUrlHk)

local origGuiOpenURL = gui.OpenURL
local function guiOpenUrlHk(url)
    lje.con_printf("[gui.OpenURL] Attempt to open URL: $yellow{%s}", url)
    if urls.is_url_allowed(url) then
        lje.con_printf("[gui.OpenURL] Allowing URL: $yellow{%s}", url)
        return origGuiOpenURL(url)
    else
        lje.con_printf("[gui.OpenURL] Blocking URL: $red{%s}", url)
        return
    end
end

_G.gui.OpenURL = lje.detour(origGuiOpenURL, guiOpenUrlHk)