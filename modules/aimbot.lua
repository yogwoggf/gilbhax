local pid = lje.include("util/pid.lua")

local config = lje.require("config/aimbot.lua")
config:save()
local aimbot = {}
aimbot.target = nil
-- integrals aren't used, because of steady state error not being an issue in aimbot
aimbot.pitch_pid = pid.new(config.pitch_response[1], config.pitch_response[2], config.pitch_response[3], -360, 360)
aimbot.yaw_pid = pid.new(config.yaw_response[1], config.yaw_response[2], config.yaw_response[3], -360, 360)
aimbot.last_time = SysTime()

local function normalizeAngle(ang)
    while ang > 180 do ang = ang - 360 end
    while ang < -180 do ang = ang + 360 end
    return ang
end
-- Bind key is specified as the enum name for the corresponding KEY_* enum value
-- This is a little gross so brace yourself
aimbot.bind_code = _L["KEY_" .. config.bind] 
if not aimbot.bind_code then
    lje.con_print("Invalid bind key specified in config/aimbot.lua")
    aimbot.bind_code = KEY_H
end

function aimbot.run()
    -- update pids
    aimbot.pitch_pid.kp = config.pitch_response[1]
    aimbot.yaw_pid.kp = config.yaw_response[1]
    local dt = SysTime() - aimbot.last_time
    aimbot.last_time = SysTime()

    if not input.IsKeyDown(aimbot.bind_code) then
        aimbot.target = nil -- Remove latch on target with key up
    end

    -- Bind key is specified as the enum name for the corresponding KEY_* enum value
    -- This is a little gross so brace yourself
    if not aimbot.target and input.IsKeyDown(aimbot.bind_code) and not vgui.CursorVisible() then
        local qualifiedPlayers = {}
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= LocalPlayer() and LocalPlayer():GetPos():Distance(ply:GetPos()) <= config.min_distance and ply:Alive() then
                table.insert(qualifiedPlayers, ply)
            end
        end

        if #qualifiedPlayers > 0 then
            local aimVectorForward = LocalPlayer():GetAimVector()
            table.sort(qualifiedPlayers, function(a, b)
                local distA = LocalPlayer():GetPos():Distance(a:GetPos())
                local distB = LocalPlayer():GetPos():Distance(b:GetPos())

                -- Check dot product to also factor in who we're aiming at
                local toA = a:GetPos()
                toA:Sub(LocalPlayer():GetShootPos())
                toA:Normalize()
                local dotA = aimVectorForward:Dot(toA)

                local toB = b:GetPos()
                toB:Sub(LocalPlayer():GetShootPos())
                toB:Normalize()
                local dotB = aimVectorForward:Dot(toB)

                distA = distA * (1 - dotA)
                distB = distB * (1 - dotB)
                return distA < distB
            end)

            aimbot.target = qualifiedPlayers[1]
        end
    end

    if aimbot.target and aimbot.target:Alive() then
        local lp = LocalPlayer()
        local targetPos = aimbot.target:GetBonePosition(aimbot.target:GetHitBoxBone(0, 0))
        local selfVelPredict = lp:GetVelocity() * config.self_velocity_compensation
        targetPos = targetPos - selfVelPredict

        local targetVelPredict = aimbot.target:GetVelocity() * config.target_velocity_compensation
        targetPos = targetPos + targetVelPredict

        local startPos = lp:GetShootPos()
        local aimAngle = (targetPos - startPos):Angle()
        -- compute PID outputs
        local currentViewAngles = lp:EyeAngles()
        local currentPitch, currentYaw, _ = currentViewAngles:Unpack()
        local pitchTarget, yawTarget, _ = aimAngle:Unpack()
        currentPitch = normalizeAngle(currentPitch)
        currentYaw = normalizeAngle(currentYaw)
        pitchTarget = normalizeAngle(pitchTarget)
        yawTarget = normalizeAngle(yawTarget)

        local pitchOutput = aimbot.pitch_pid:compute(pitchTarget, currentPitch, dt)
        local yawOutput = aimbot.yaw_pid:compute(yawTarget, currentYaw, dt)
        currentViewAngles:SetUnpacked(
            currentPitch + pitchOutput * dt,
            currentYaw + yawOutput * dt,
            0
        )
        lp:SetEyeAngles(currentViewAngles)
    end
end

lje.con_print("Aimbot module loaded.")
return aimbot