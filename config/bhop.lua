local configJson = lje.data.read("gilbhax-bhop-config")
if configJson then
    local config = util.JSONToTable(configJson)
    if config then
        config.save = function(self)
            local configJson = util.TableToJSON(self, true)
            lje.data.write("gilbhax-bhop-config", configJson)
        end
        return config
    end
end

return {
    enabled = true,
    strafing = false,
    strafe_speed = 300,
    save = function(self)
        local configJson = util.TableToJSON(self, true)
        lje.data.write("gilbhax-bhop-config", configJson)
    end
}