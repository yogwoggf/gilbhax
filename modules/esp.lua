local P = cloned_mts.Player
local E = cloned_mts.Entity
local V = cloned_mts.Vector

local esp = {}
esp.max_distance = 1000 -- in units
esp.player_mat = Material("models/shiny")

function esp.run()
    for _, ply in ipairs(player.GetAll()) do
        if not E.__eq(ply, LocalPlayer()) and V.Distance(E.GetPos(LocalPlayer()), E.GetPos(ply)) <= esp.max_distance and P.Alive(ply) then
            local plyPos = E.GetBonePosition(ply, E.GetHitBoxBone(ply, 0, 0))
            local pt1 = V.ToScreen(plyPos)

            local x1 = pt1.x - 7.5
            local y1 = pt1.y - 7.5
            local w = 15
            local h = 15

            surface.SetDrawColor(255, 100, 100, 255)
            surface.DrawOutlinedRect(x1, y1, w, h, 1)

            surface.SetFont("DermaDefaultBold")
            surface.SetTextPos(x1 + 18, y1)
            surface.SetTextColor(255, 255, 255, 255)
            surface.DrawText(P.Nick(ply))

            -- Draw team name
            local envTeam = rawget(_G, "team")
            local teamGetName = envTeam and rawget(envTeam, "GetName")

            if teamGetName then -- Teams exist. Some anticheats will randomly remove the team table.. weird.
                local teamInfoName, teamInfo = debug.getupvalue(teamGetName, 1) -- Get the team info table
                
                if teamInfoName == "TeamInfo" and type(teamInfo) == "table" then
                    local teamData = rawget(teamInfo, P.Team(ply))
                    if teamData and type(teamData) == "table" then
                        local teamName = rawget(teamData, "Name") or "Unknown"
                        surface.SetTextPos(x1 + 18, y1 + 15)
                        surface.DrawText("[" .. teamName .. "]")
                    end
                end
            end

            cam.Start({type = "3D"})
                render.SuppressEngineLighting(true)
                render.MaterialOverride(esp.player_mat)
                local oldR, oldG, oldB = render.GetColorModulation()
                local r = V.Distance(E.GetPos(LocalPlayer()), E.GetPos(ply)) / esp.max_distance
                render.SetColorModulation(1 - (r * r * r), 1, 0)
                E.DrawModel(ply)
                render.MaterialOverride(nil)
                render.SetColorModulation(oldR, oldG, oldB)
                render.SuppressEngineLighting(false)
            cam.End()
        end
    end
end

return esp
