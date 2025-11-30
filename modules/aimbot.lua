local P = cloned_mts.Player
local E = cloned_mts.Entity
local V = cloned_mts.Vector
local sub = V.__sub
local add = V.__add
local mul = V.__mul
local A = cloned_mts.Angle

local pid = lje.include("util/pid.lua")

local aimbot = {}
aimbot.target = nil
aimbot.bind = KEY_H
aimbot.min_distance = 1000 -- in units
-- integrals aren't used, because of steady state error not being an issue in aimbot
aimbot.pitch_pid = pid.new(35, 0.2, 0, -360, 360)
aimbot.yaw_pid = pid.new(42, 0.3, 0, -360, 360)
aimbot.last_time = SysTime()

local function normalizeAngle(ang)
    while ang > 180 do ang = ang - 360 end
    while ang < -180 do ang = ang + 360 end
    return ang
end

function aimbot.run()
    local dt = SysTime() - aimbot.last_time
    aimbot.last_time = SysTime()

    if not input.IsKeyDown(aimbot.bind) then
        aimbot.target = nil -- Remove latch on target with key up
    end

    if not aimbot.target and input.IsKeyDown(aimbot.bind) then
        local qualifiedPlayers = {}
        for _, ply in ipairs(player.GetAll()) do
            if (not E.__eq(ply, LocalPlayer())) and V.Distance(E.GetPos(LocalPlayer()), E.GetPos(ply)) <= aimbot.min_distance and P.Alive(ply) then
                table.insert(qualifiedPlayers, ply)
            end
        end

        if #qualifiedPlayers > 0 then
            local aimVectorForward = P.GetAimVector(LocalPlayer())
            table.sort(qualifiedPlayers, function(a, b)
                local distA = V.Distance(E.GetPos(LocalPlayer()), E.GetPos(a))
                local distB = V.Distance(E.GetPos(LocalPlayer()), E.GetPos(b))

                -- Check dot product to also factor in who we're aiming at
                local toA = E.GetPos(a)
                V.Sub(toA, P.GetShootPos(LocalPlayer()))
                V.Normalize(toA)
                local dotA = V.Dot(aimVectorForward, toA)

                local toB = E.GetPos(b)
                V.Sub(toB, P.GetShootPos(LocalPlayer()))
                V.Normalize(toB)
                local dotB = V.Dot(aimVectorForward, toB)

                distA = distA * (1 - dotA)
                distB = distB * (1 - dotB)
                return distA < distB
            end)

            aimbot.target = qualifiedPlayers[1]
        end
    end

    if aimbot.target and P.Alive(aimbot.target) then
        local lp = LocalPlayer()
        local targetPos = E.GetBonePosition(aimbot.target, E.GetHitBoxBone(aimbot.target, 0, 0))
        local selfVelPredict = mul(E.GetVelocity(lp), 0.025)
        targetPos = sub(targetPos, selfVelPredict)

        local targetVelPredict = mul(E.GetVelocity(aimbot.target), 0.015)
        targetPos = add(targetPos, targetVelPredict)

        local startPos = P.GetShootPos(lp)
        local aimAngle = (sub(targetPos, startPos)):Angle()

        -- compute PID outputs
        local currentViewAngles = E.EyeAngles(lp)
        local currentPitch, currentYaw, _ = A.Unpack(currentViewAngles)
        local pitchTarget, yawTarget, _ = A.Unpack(aimAngle)
        currentPitch = normalizeAngle(currentPitch)
        currentYaw = normalizeAngle(currentYaw)
        pitchTarget = normalizeAngle(pitchTarget)
        yawTarget = normalizeAngle(yawTarget)

        local pitchOutput = aimbot.pitch_pid:compute(pitchTarget, currentPitch, dt)
        local yawOutput = aimbot.yaw_pid:compute(yawTarget, currentYaw, dt)
        A.SetUnpacked(currentViewAngles,
            currentPitch + pitchOutput * dt,
            currentYaw + yawOutput * dt,
            0
        )
        P.SetEyeAngles(lp, currentViewAngles)
    end
end

lje.con_print("Aimbot module loaded.")
return aimbot