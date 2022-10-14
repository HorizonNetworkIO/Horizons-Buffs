// updates a player's buffs and syncs them to the player.
function HZNBuffs:UpdateBuffs(steamid, dataTbl, callback)
    if not dataTbl then return end
    local data = util.TableToJSON(dataTbl)

    local query = "INSERT INTO `hznbuffs_data` (`steamid`, `buffdata`) VALUES ('" .. steamid .. "', '" .. data .. "') ON DUPLICATE KEY UPDATE `buffdata` = '" .. data .. "'"
    HZNBuffs:QueryDB(query, function()
        local ply = player.GetBySteamID(steamid)
        if (IsValid(ply)) then
            HZNBuffs:SyncPlayerBuffs(ply)
        end
        if (callback) then
            callback()
        end
    end)
end

// Adds a buff to the player's buff inventory
function HZNBuffs:AddBuff(steamid, id)
    if (!HZNBuffs.Buffs[id]) then
        HZNBuffs:Log("Attempted to add invalid buff to player " .. steamid .. " with id " .. id)
        return
    end

    HZNBuffs:GetBuffs(steamid, function(buffs)
        local addedBuff = {
            id = id,
            startTime = 0,
            active = false,
            slotId = #buffs + 1, // the slot number, not the ID. When we use a buff, we go by the slotID.=
        }

        if (!HZNBuffs.Buffs[id].permanent) then
            addedBuff.useAmount = HZNBuffs.Buffs[id].useAmount // starting amount
        end

        if (HZNBuffs.Buffs[id].permanent) then
            addedBuff.permanent = HZNBuffs.Buffs[id].permanent
        end

        table.insert(buffs, addedBuff)
        HZNBuffs:UpdateBuffs(steamid, buffs)

        local ply = player.GetBySteamID(steamid)
        if (IsValid(ply)) then
            HZNBuffs:Say(ply, "You have been given the buff " .. HZNBuffs.Buffs[id].name .. "!")
        end
    end)
end

// Remove Buff from a player's inventory. Uses slotId
function HZNBuffs:TakeBuff(steamid, slotId)
    local taken = false

    HZNBuffs:GetBuffs(steamid, function(buffs)
        for k,v in ipairs(buffs) do
            if v.slotId == slotId then
                if (v.permanent) then
                    break
                else
                    taken = true
                    table.remove(buffs, k)
                end
            end
        end
        
        if (taken) then
            for k,v in ipairs(buffs) do
                v.slotId = k
            end
        end
        
        HZNBuffs:UpdateBuffs(steamid, buffs)
    end)
end

function HZNBuffs:GetBuffs(steamid, callback)
    local q = "SELECT * FROM `hznbuffs_data` WHERE `steamid` = '" .. steamid .. "'"
    HZNBuffs:QueryDB(q, function(data)
        if (data and data[1]) then
            callback(util.JSONToTable(data[1].buffdata))
        else
            callback({})
        end
    end)
end

function HZNBuffs:HasBuff(steamid, id, callback)
    HZNBuffs:GetBuffs(steamid, function(buffs)
        for k,v in ipairs(buffs) do
            if v.id == id then
                callback(true)
                return
            end
        end
        callback(false)
    end)
end

function HZNBuffs:CreateTables()
    local query = "CREATE TABLE IF NOT EXISTS `hznbuffs_data` ( `steamid` VARCHAR(255) NOT NULL, `buffdata` TEXT NOT NULL, PRIMARY KEY (`steamid`) )"
    HZNBuffs:QueryDB(query, function()
        HZNBuffs:Log("Created tables.")
    end)
end

function HZNBuffs:QueryDB(query, callback)
    if (not HZNLib.DatabaseConnected) then
        timer.Simple(3, function()
            HZNLib:Query(query, callback)
        end)
        HZNBuffs:Log("Couldn't connect to the database! Retrying in 3 seconds...")
        return
    end
    HZNLib:Query(query, callback)
end

hook.Add("HZNLib:DatabaseConnected", "HZNBuffs:DBConnect", function()
    HZNBuffs:CreateTables()
end)