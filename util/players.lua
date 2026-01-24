local players = {}

function players.getOthers()
    local others = {}
    local localPlayer = LocalPlayer()
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= localPlayer and ply:IsValid() and ply:Alive() and ply:GetMoveType() == MOVETYPE_WALK then
            table.insert(others, ply)
        end
    end

    return others
end

return players