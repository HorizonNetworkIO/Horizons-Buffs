// Received from the client to Use an item. Depending on the item's state, it may be set to active or inactive.
util.AddNetworkString("HZNBuffs:UseItem")
net.Receive("HZNBuffs:UseItem", function(len, ply)
    if (ply.hznbuffs_lastuse and ((ply.hznbuffs_lastuse + 2) > os.time())) then
        HZNBuffs:Say(ply, "You can only use an item every 2 seconds.")
        return
    end

    ply.hznbuffs_lastuse = os.time()

    local npc = net.ReadEntity()

    if (!HZNLib:InDistance(ply, npc, HZNLib.USE_DISTANCE)) then
        HZNBuffs:Say(ply, "You are too far away from the shop!")
        return
    end

    local id = net.ReadUInt(8)
    HZNBuffs:UseBuff(ply, id)
end)

// command to add a buff to the player
concommand.Add("hznbuffs_add", function(ply, cmd, args)
    if (!args[1]) then return end
    if (!args[2]) then return end

    local steamid = args[1]
    local buff = tonumber(args[2])
    
    if (!HZNBuffs.Buffs[buff]) then return end
    
    steamid = util.SteamIDFrom64(steamid)

    HZNBuffs:Log("Adding buff " .. HZNBuffs.Buffs[buff].name .. " to " .. steamid)

    HZNBuffs:AddBuff(steamid, tonumber(buff))
end)

HZNBuffs.GivenWeapons = {}
function HZNBuffs:GetRandomWeapon()
    if (#HZNBuffs.GivenWeapons == 0) then
        local weaponList = weapons.GetList()
        for k,v in pairs(weaponList) do
            if (string.sub(v.ClassName, 1, 4) == "m9k_") then
                // category of weapon must be "M9K Pistols"
                if (v.Category != "M9K Specialties" and v.Category != "M9K Machine Guns") then
                    table.insert(HZNBuffs.GivenWeapons, v.ClassName)
                end
            end
        end
    end

    return table.Random(HZNBuffs.GivenWeapons)
end