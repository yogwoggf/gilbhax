local pid = {}
pid.__index = pid

local SMOOTH_NOISE_AMPLITUDE = 0.2 -- degrees
local SMOOTH_NOISE_OFFSET = SMOOTH_NOISE_AMPLITUDE / 2
local SMOOTH_NOISE_B = 8 -- frequency, but not real frequency (as that would be 2pi/period)

function pid.new(kp, kd, ki, min_output, max_output)
    return setmetatable({
        kp = kp or 1,
        kd = kd or 0,
        ki = ki or 0,
        last_error = 0,
        integral = 0,
        min_output = min_output or -math.huge,
        max_output = max_output or math.huge,
        phase_shift = math.random() * 2 * math.pi
    }, pid)
end

function pid:compute(setpoint, measured_value, dt)
    local error = setpoint - measured_value
    -- Normalize angle error to [-180, 180] range
    -- This handles wrapping (e.g., going from 170° to -170° is only 20°, not 340°)
    while error > 180 do error = error - 360 end
    while error < -180 do error = error + 360 end

    -- Introduce smooth noise to avoid perfect tracking
    self.phase_shift = self.phase_shift + error * 0.02 -- Randomize based on error
    
    local smooth_noise = (math.sin(SysTime() * SMOOTH_NOISE_B + self.phase_shift) + 1) / 2 * SMOOTH_NOISE_AMPLITUDE - SMOOTH_NOISE_OFFSET
    error = error + smooth_noise

    self.integral = self.integral + error * dt
    local derivative = (error - self.last_error) / dt
    self.last_error = error

    local output = (self.kp * error) + (self.ki * self.integral) + (self.kd * derivative)
    output = math.max(self.min_output, math.min(self.max_output, output))
    return output
end

return pid