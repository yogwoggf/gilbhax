-- Hooks are always disabled during the execution of this script.
-- They re-enable as soon as this script finishes.

lje = lje or {}
local aimbot = lje.include("modules/aimbot.lua")
local esp = lje.include("modules/esp.lua")
local screengrab = lje.require("modules/screengrab.lua")
local bhop = lje.include("modules/bhop.lua")
local freecam = lje.include("modules/freecam.lua")

hook.pre("ljeutil/render", "gilbhax.ui", function()
    aimbot.run()

    cam.Start2D()
    render.PushRenderTarget(lje.util.rendertarget)
        surface.SetFont("ChatFont")
        surface.SetTextPos(10, 10)
        surface.SetTextColor(0, 255, 0, 255)
        surface.DrawText("GILBHAX - LJE")

        local curY = 30
        if aimbot.target then
            surface.SetTextPos(10, curY)
            surface.DrawText("Aimbot Target: " .. aimbot.target:Nick())
            curY = curY + 20
        end

        if screengrab.is_screengrab_recent() then
            surface.SetTextPos(10, curY)
            surface.SetTextColor(255, math.sin(SysTime() * 15) * 127 + 128, 0, 255)
            surface.DrawText(string.format("Screengrabbed %.1f seconds ago!", screengrab.get_time_since_last_screengrab()))
            curY = curY + 20
        end

        if freecam.is_freecam_active() then
            surface.SetTextPos(10, curY)
            surface.SetTextColor(255, 0, 255, 255)
            surface.DrawText("Freecam Active")
            curY = curY + 20
        end

        surface.SetTextPos(10, curY)
        surface.SetTextColor(0, 255, 0, 255)
        surface.DrawText(string.format("GC Memory: %d B", lje.gc.get_total()))
        curY = curY + 20

        esp.run()
    render.PopRenderTarget()
    cam.End2D()
end)

hook.pre("CreateMove", "gilbhax.bhop", function(cmd)
    if input.WasKeyPressed(KEY_P) then
        freecam.toggle()
    end
    
    bhop.run(cmd)
end)

lje.con_printf("$green{GILBHAX} initialized successfully.")