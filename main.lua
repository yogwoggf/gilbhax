-- Hooks are always disabled during the execution of this script.
-- They re-enable as soon as this script finishes.

lje = lje or {}
lje.con_print("Starting LJE startup script...")
local HOOK_CALL_BC_HASH = 0xBD59600A
local p = cloned_mts.Player
local PlayerNick = p.Nick
local cam_Start = cam.Start
local cam_End2D = cam.End2D
local surface_SetFont = surface.SetFont
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText

local function cam_Start2D()
    cam_Start({type = "2D"})
end

local aimbot = lje.include("modules/aimbot.lua")
local esp = lje.include("modules/esp.lua")
local screengrab = lje.require("modules/screengrab.lua")

local origHook = rawget(_G, "hook")
if not origHook then
    lje.con_print("Error: hook table not found!")
    return
end

local lastHookCallTime = SysTime()
local hookCallThreshold = 5 -- seconds
local origHookCall = rawget(origHook, "Call")
local hook = {Call = origHookCall}
local inHook = false

local function hookCallHk(name, gm, ...)
    lje.hooks.disable()
    -- Re-entrancy guard (disable hooks for the if statement as it will count towards instructions)
    if inHook then
        lje.hooks.enable()
        return origHookCall(name, gm, ...)
    end
    lje.hooks.enable()

    inHook = true
    local a, b, c, d, e, f = hook.Call(name, gm, ...)
    inHook = false

    lje.hooks.disable()
        -- If an anticheat is doing hook.Call("PostRender", ...), it's probably to detect us and we'll just skip our code.
        -- Skip 1 frame (us) to avoid false positives.
        local lua_involved = lje.env.is_lua_involved(1)

        if name == "PostRender" then
            lastHookCallTime = SysTime()

            if not lua_involved then
                aimbot.run()

                cam_Start2D()
                    surface_SetFont("ChatFont")
                    surface_SetTextPos(10, 10)
                    surface_SetTextColor(0, 255, 0, 255)
                    surface_DrawText("GILBHAX - LJE")

                    local curY = 30
                    if aimbot.target then
                        surface_SetTextPos(10, curY)
                        surface_DrawText("Aimbot Target: " .. PlayerNick(aimbot.target))
                        curY = curY + 20
                    end

                    if screengrab.is_screengrab_recent() then
                        surface_SetTextPos(10, curY)
                        surface_SetTextColor(255, math.sin(SysTime() * 15) * 127 + 128, 0, 255)
                        surface_DrawText(string.format("Screengrabbed %.1f seconds ago!", screengrab.get_time_since_last_screengrab()))
                        curY = curY + 20
                    end

                    surface_SetTextPos(10, curY)
                    surface_SetTextColor(0, 255, 0, 255)
                    surface_DrawText(string.format("GC Memory: %d B", lje.gc.get_total()))
                    curY = curY + 20

                    esp.run()
                cam_End2D()
            else
                lje.con_print("Detected Lua interference in PostRender, bailing...")
            end
        end
    lje.hooks.enable()
    return a, b, c, d, e, f
end

local hk = rawget(_G, "hook")
rawset(hk, "Call", lje.detour(origHookCall, hookCallHk))

lje.con_print("hook.Call detoured in startup script.")
if lje.util.get_bytecode_hash(origHookCall) ~= HOOK_CALL_BC_HASH then
    lje.con_printf("$red{WARNING}: hook.Call bytecode hash mismatch! Expected $green{0x%X}, got $red{0x%X} **", HOOK_CALL_BC_HASH, lje.util.get_bytecode_hash(origHookCall))
else
    lje.con_print("hook.Call bytecode hash verified.")
end

local stringCount = 0
lje.util.set_push_string_callback(function()
    lje.hooks.disable()
    stringCount = stringCount + 1
    if stringCount % 4000 == 0 then
        -- Check if hook.Call was overriden
        local hk = rawget(_G, "hook")
        local callFn = hk and rawget(hk, "Call")
        local spoofed = lje.func.is_spoofed(callFn)
        if not spoofed then
            hook.Call = callFn
            -- Restore hook.Call. Must have been modified.
            if lje.util.get_bytecode_hash(callFn) ~= HOOK_CALL_BC_HASH then
                lje.con_printf("$red{WARNING}: hook.Call bytecode hash mismatch during periodic check! Expected $green{0x%X}, got $red{0x%X} **", HOOK_CALL_BC_HASH, lje.util.get_bytecode_hash(callFn))
            else
                lje.con_print("hook.Call bytecode hash verified during periodic check.")
            end
            
            rawset(hk, "Call", lje.detour(callFn, hookCallHk))
            lje.con_printf("$red{Modification detected}, restored hook.Call detour.")
        end
    end
    lje.hooks.enable()
end)

lje.con_printf("$green{GILBHAX} initialized successfully.")