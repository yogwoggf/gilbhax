local config = lje.require("config/bhop.lua")
local aimbotConfig = lje.require("config/aimbot.lua")
config:save()

local bhop = {}

function bhop.run(cmd)
    if not config.enabled then return end

    -- Auto bunnyhop
    if not cmd:KeyDown(IN_JUMP) then
        aimbotConfig.pitch_response[1] = 35 -- Restore original values
        aimbotConfig.yaw_response[1] = 42
        return
    end

    local ply = LocalPlayer()
    if not ply:IsOnGround() then
        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
        -- Strafing
        if config.strafing then
            aimbotConfig.pitch_response[1] = 135 -- Make the PIDS way more responsive for strafing
            aimbotConfig.yaw_response[1] = 142
            -- Just strafe really, really fast left/right (alternating every frame
            -- So, for left strafe, hold down A, move view angle to the left
            -- For right strafe, hold down D, move view angle to the right
            local velocity = ply:GetVelocity()
            local speed = math.sqrt(velocity[1] * velocity[1] + velocity[2] * velocity[2])

            local viewAngles = cmd:GetViewAngles()
            local yaw = viewAngles[2]
            local strafeSpeed = config.strafe_speed or 10
            if math.fmod(SysTime() * 4.5, 2) < 1 then
                -- Left strafe
                yaw = yaw - 1
                cmd:SetSideMove(1000)
            else
                -- Right strafe
                yaw = yaw + 1
                cmd:SetSideMove(-1000)
            end
            viewAngles[2] = yaw
            cmd:SetViewAngles(viewAngles)
        end
    end
end

return bhop