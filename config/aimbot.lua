local configJson = lje.data.read("gilbhax-aimbot-config")
if configJson then
    local config = util.JSONToTable(configJson)
    if config then
        config.save = function(self)
            local configJson = util.TableToJSON(self, true)
            lje.data.write("gilbhax-aimbot-config", configJson)
        end

        return config
    end
end

return {
    min_distance = 1000, -- in units
    bind = "H",
    pitch_response = {35, 0.25, 0}, -- P, D, I
    yaw_response = {42, 0, 0}, -- P, D, I
    self_velocity_compensation = 0.028,
    target_velocity_compensation = 0.017,
    save = function(self)
        local configJson = util.TableToJSON(self, true)
        lje.data.write("gilbhax-aimbot-config", configJson)
    end,
}