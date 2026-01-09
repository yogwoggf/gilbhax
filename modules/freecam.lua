local freecam = {}
freecam.current_position = Vector()
freecam.current_angles = Angle()
freecam.current_fov = 70
freecam.is_active = false
freecam.last_scroll = 0

local function lerp(a, b, t)
    return a + (b - a) * t
end

function freecam.start()
    freecam.current_position = LocalPlayer():GetPos() + Vector(0, 0, 50) -- Start slightly above the player
    freecam.lerp_target_position = freecam.current_position
    freecam.lerp_fov = freecam.current_fov
    freecam.current_angles = LocalPlayer():EyeAngles()
    freecam.is_active = true
end

function freecam.stop()
    freecam.is_active = false
end

function freecam.is_freecam_active()
    return freecam.is_active
end

function freecam.toggle()
    if freecam.is_active then
        freecam.stop()
    else
        freecam.start()
    end
end

hook.post("CalcView", "gilbhax.freecam", function(ply, pos, angles, fov)
    if freecam.is_active then
        -- Inputs
        if input.IsKeyDown(KEY_W) then
            freecam.current_position = freecam.current_position + angles:Forward() * 10
        end
        if input.IsKeyDown(KEY_S) then
            freecam.current_position = freecam.current_position - angles:Forward() * 10
        end
        if input.IsKeyDown(KEY_A) then
            freecam.current_position = freecam.current_position - angles:Right() * 10
        end
        if input.IsKeyDown(KEY_D) then
            freecam.current_position = freecam.current_position + angles:Right() * 10
        end

        if input.IsKeyDown(KEY_SPACE) then
            freecam.current_position = freecam.current_position + Vector(0, 0, 10)
        end

        local scroll = input.GetAnalogValue(ANALOG_MOUSE_WHEEL)
        local deltaScroll = scroll - freecam.last_scroll
        freecam.last_scroll = scroll

        freecam.current_fov = math.Clamp(freecam.current_fov - (deltaScroll * 10), 30, 120)

        freecam.lerp_target_position = LerpVector(0.03, freecam.lerp_target_position, freecam.current_position)
        freecam.lerp_fov = lerp(freecam.lerp_fov, freecam.current_fov, 0.1)

        return {
            origin = freecam.lerp_target_position,
            angles = angles,
            fov = freecam.lerp_fov,
            drawviewer = true
        }
    end
end)

return freecam