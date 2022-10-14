HZNBuffs.Buffs = {}
HZNBuffs.PlayerBuffTimer = {}
HZNBuffs.PrinterBuffPlayers = {}

// Retrieves the player's buff inventory and syncs it with their client
util.AddNetworkString("HZNBuffs:SyncPlayerBuffs")
function HZNBuffs:SyncPlayerBuffs(ply)
    if (not ply) then
        for k,v in ipairs(player.GetAll()) do
            HZNBuffs:SyncPlayerBuffs(v)
        end
        return
    end
    HZNBuffs:GetBuffs(ply:SteamID(), function(buffs)
        net.Start("HZNBuffs:SyncPlayerBuffs")
            net.WriteTable(buffs)
        net.Send(ply)
    end)
end

// Sends the player all of our buffs. Syncs all types except for functions
util.AddNetworkString("HZNBuffs:SyncBuffs")
function HZNBuffs:SyncBuffs(ply)
    local buffs = {}
    for k,v in pairs(HZNBuffs.Buffs) do
        local buff = {}

        for k2,v2 in pairs(v) do
            if (!isfunction(v2)) then
                buff[k2] = v2
            end
        end

        table.insert(buffs, buff)
    end

    net.Start("HZNBuffs:SyncBuffs")
        net.WriteTable(buffs)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

// Use the buff from the player's inventory based on slotId
function HZNBuffs:UseBuff(ply, slotId)
    if (!slotId) then return end
    if (!IsValid(ply)) then return end

    local plySteamID = ply:SteamID()
    HZNBuffs:GetBuffs(plySteamID, function(buffs)
        local v = buffs[slotId]
        local buffId = v.id
        if (!v) then 
            HZNBuffs:Log("Tried to use a buff that doesn't exist: " .. slotId)
            return
        end

        if (v.active) then // active
            if (!v.permanent) then
                HZNBuffs:TakeBuff(plySteamID, slotId)
            else
                // reset buff
                v.active = false 
                v.startTime = 0

                buffs[slotId] = v
                // update inventory & client
                HZNBuffs:UpdateBuffs(plySteamID, buffs, function()
                    HZNBuffs:Log("Disabled buff " .. HZNBuffs.Buffs[v.id].name .. " from " .. ply:Nick())
                end)
            end
            
            // remove buff effects
            HZNBuffs.Buffs[v.id].onRemove(ply)
        else // not active
            if (v.permanent) then // permanent
                v.active = true
            else // not permanent
                if (HZNBuffs.PlayerBuffTimer[plySteamID]) then
                    if (HZNBuffs.PlayerBuffTimer[plySteamID][buffId]) then
                        if (os.time() - HZNBuffs.PlayerBuffTimer[plySteamID][buffId] < HZNBuffs.Buffs[v.id].cooldown) then
                            HZNBuffs:Say(ply, "You must wait " .. math.ceil(HZNBuffs.Buffs[v.id].cooldown - (os.time() - HZNBuffs.PlayerBuffTimer[plySteamID][buffId])) .. " seconds before using this buff again.")
                            return
                        end
                    end
                else
                    HZNBuffs.PlayerBuffTimer[plySteamID] = {}
                end
                HZNBuffs.PlayerBuffTimer[plySteamID][buffId] = os.time()

                v.active = true
                v.startTime = os.time()

                // start timer for buff's duration. Use again when it runs out
                local timerStr = "HZNBuffs:UseBuffTimer:" .. plySteamID .. ":" .. slotId
                if (!timer.Exists(timerStr)) then
                    timer.Create(timerStr, HZNBuffs.Buffs[v.id].duration, 1, function()
                        HZNBuffs:UseBuff(ply, slotId)
                    end)
                else
                    timer.Adjust(timerStr, HZNBuffs.Buffs[v.id].duration, 1, function()
                        HZNBuffs:UseBuff(ply, slotId)
                    end)
                end
            end

            buffs[slotId] = v
            // Update inventory & client then apply buff effects
            HZNBuffs:UpdateBuffs(plySteamID, buffs, function()
                HZNBuffs:GatherBuff(ply, slotId)
                HZNBuffs:Log("Enabled buff " .. HZNBuffs.Buffs[v.id].name .. " for " .. ply:Nick())
            end)
        end
    end)
end

// Calls the buffs onUsefunction, if no ID is provided, it will call all of them
function HZNBuffs:GatherBuff(ply, slotId)
    HZNBuffs:GetBuffs(ply:SteamID(), function(buffs)
        for k,v in ipairs(buffs) do
            if (v.active) then
                if (slotId) then
                    if (v.slotId == slotId) then
                        HZNBuffs.Buffs[v.id].onUse(ply)
                    end
                else
                    HZNBuffs.Buffs[v.id].onUse(ply)
                end
            end
        end
    end)
end

local addBuff = function(tbl)
    tbl.id = #HZNBuffs.Buffs + 1
    tbl.active = false
    table.insert(HZNBuffs.Buffs, tbl)
end

function HZNBuffs:AddBuffs()
    addBuff({
        name = "+5 Max HP",
        icon = 1,
        description = "Increases your max health by 5.",
        permanent = true,
        type = 1,
        onUse = function(ply) // what happens when we use it
            local prev = ply:GetMaxHealth()
            ply:SetMaxHealth(ply:GetMaxHealth() + 5)
            
            if (ply:Health() == prev) then
                ply:SetHealth(ply:GetMaxHealth())
            end
        end,
        onRemove = function(ply) -- what happens when we remove it
            ply:SetMaxHealth(ply:GetMaxHealth() - 5)

            if (ply:Health() > ply:GetMaxHealth()) then
                ply:SetHealth(ply:GetMaxHealth())
            end
        end
    })

    addBuff({
        name = "+5 Starting Armor",
        icon = 2,
        type = 1,
        description = "Increases your starting armor by 5.",
        permanent = true,
        onUse = function(ply) // what happens when we use it
            ply:SetArmor(ply:Armor() + 5)

            if (ply:Armor() > ply:GetMaxArmor()) then
                ply:SetArmor(ply:GetMaxArmor())
            end
        end,
        onRemove = function(ply) -- what happens when we remove it
            // does nothing
        end
    })

    addBuff({
        name = "+5% Walk Speed",
        icon = 3,
        type = 4,
        description = "Increases your walk speed by 5%",
        permanent = true,
        onUse = function(ply) // what happens when we use it
            ply:SetWalkSpeed(ply:GetWalkSpeed() * 1.05)
        end,
        onRemove = function(ply) -- what happens when we remove it
            ply:SetWalkSpeed(ply:GetWalkSpeed() / 1.05)
        end
    })

    addBuff({
        name = "+5% Run Speed",
        icon = 3,
        type = 4,
        description = "Increases your Run speed by 5%",
        permanent = true,
        onUse = function(ply) // what happens when we use it
            ply:SetRunSpeed(ply:GetRunSpeed() * 1.05)
        end,
        onRemove = function(ply) -- what happens when we remove it
            ply:SetRunSpeed(ply:GetRunSpeed() / 1.05)
        end
    })

    addBuff({
        name = "+5% Jump Height",
        icon = 3,
        type = 3,
        description = "Increases your Jump Height by 5%",
        permanent = true,
        onUse = function(ply) // what happens when we use it
            ply:SetJumpPower(ply:GetJumpPower() * 1.05)
        end,
        onRemove = function(ply) -- what happens when we remove it
            if (ply:IsValid() and ply:Alive()) then
                ply:SetJumpPower(ply:GetJumpPower() / 1.05)
            end
        end
    })

    addBuff({
        name = "+5% Lockpick Speed",
        icon = 4,
        type = 4,
        description = "Increases your lockpick speed by 5%",
        permanent = true,
        onUse = function(ply) // what happens when we use it
            if (!ply.hzn_lockpickspeed) then
                ply.hzn_lockpickspeed = 100
            end
            ply.hzn_lockpickspeed = ply.hzn_lockpickspeed - 5
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            if (!ply.hzn_lockpickspeed) then
                ply.hzn_lockpickspeed = 100
            else
                ply.hzn_lockpickspeed = ply.hzn_lockpickspeed + 5

                if (ply.hzn_lockpickspeed > 100) then
                    ply.hzn_lockpickspeed = 100
                end

                if (hard) then
                    ply.hzn_lockpickspeed = 100
                end
            end
        end
    })
end

function HZNBuffs:AddShopBuffs()
    -- addBuff({
    --     name = "Printer Speed Boost",
    --     icon = 4,
    --     type = 4,
    --     description = "This will increase the printer speed on all purchased printers when this buff is active.",
    --     onUse = function(ply) // what happens when we use it
    --         ply.hzn_sprinterspeed = HZNBuffs.Config.PrinterSpeedBuff
    --     end,
    --     onRemove = function(ply, hard) -- what happens when we remove it
    --         ply.hzn_sprinterspeed = 1
    --     end,
    --     ShopItem = true,
    --     ShopPrice = 35000,
    --     duration = 300,
    --     cooldown = 1200,
    --     CanPurchase = function(ply)
    --         return true
    --     end,
    -- })
    addBuff({
        name = "Trash Man Burning Bonus",
        icon = 4,
        type = 1,
        description = "Burning trash will give trash men a bonus money reward when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_trashman_burn = HZNBuffs.Config.TrashManBurnBonus
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_trashman_burn = 1
        end,
        ShopItem = true,
        ShopPrice = 55000,
        duration = 1800,
        cooldown = 600,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Trash Man Recycling Bonus",
        icon = 4,
        type = 1,
        description = "Recycling trash will give trash men a bonus money reward when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_trashman_recycle = HZNBuffs.Config.TrashManRecycleBonus
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_trashman_recycle = 1
        end,
        ShopItem = true,
        ShopPrice = 57500,
        duration = 1800,
        cooldown = 600,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Meth Double Payout",
        icon = 4,
        type = 2,
        description = "Selling meth at the buyer NPC will give you double the payout when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_methdoublepayout = 2
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_methdoublepayout = 1 
        end,
        ShopItem = true,
        ShopPrice = 95000,
        duration = 1800,
        cooldown = 900,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Weed Double Payout",
        icon = 4,
        type = 2,
        description = "Selling weed at the buyer NPC will give you double the payout when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_weeddoublepayout = 2
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_weeddoublepayout = 1
        end,
        ShopItem = true,
        ShopPrice = 95000,
        duration = 1800,
        cooldown = 900,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Bank Robbery Multiplier",
        icon = 4,
        type = 2,
        description = "This will give you a 33% bonus per bag from a bank robbery when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_bankrobberymultiplier = 1.33
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_bankrobberymultiplier = 1
        end,
        ShopItem = true,
        ShopPrice = 75000,
        duration = 1800,
        cooldown = 900,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Hitman Bonus",
        icon = 4,
        type = 1,
        description = "This will give you a random bonus per hit as a hitman when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_hitmanbonus = true
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_hitmanbonus = false
        end,
        ShopItem = true,
        ShopPrice = 65000,
        duration = 1800,
        cooldown = 600,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Credit Multiplier",
        icon = 4,
        type = 2,
        description = "This will give you a 33% bonus when receiving Credits when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_creditmultiplier = 1.33
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_creditmultiplier = 1
        end,
        ShopItem = true,
        ShopPrice = 115000,
        duration = 1800,
        cooldown = 1800,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Weapon Mayhem",
        icon = 4,
        type = 3,
        description = "This will give you a random weapon upon respawn when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_weaponmayhem = true
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            if (!hard) then
                ply.hzn_weaponmayhem = false
            end
        end,
        ShopItem = true,
        ShopPrice = 125000,
        duration = 1200,
        cooldown = 300,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Vape Master",
        icon = 4,
        type = 3,
        description = "This will give you a random vape upon respawn when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_vapemaster = true
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            if (!hard) then
                ply.hzn_vapemaster = false
            end
        end,
        ShopItem = true,
        ShopPrice = 100000,
        duration = 1200,
        cooldown = 300,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Casino Bonus",
        icon = 4,
        type = 1,
        description = "This will give you a random bonus upon receiving money from your casino when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_casinobonus = true
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_casinobonus = false
        end,
        ShopItem = true,
        ShopPrice = 65000,
        duration = 1800,
        cooldown = 1200,
        CanPurchase = function(ply)
            return true
        end,
    })
    addBuff({
        name = "Arresting Bonus",
        icon = 4,
        type = 1,
        description = "This will give you a random bonus upon arresting a player when this buff is active.",
        onUse = function(ply) // what happens when we use it
            ply.hzn_arrestingbonus = true
        end,
        onRemove = function(ply, hard) -- what happens when we remove it
            ply.hzn_arrestingbonus = false
        end,
        ShopItem = true,
        ShopPrice = 50000,
        duration = 1800,
        cooldown = 600,
        CanPurchase = function(ply)
            return true
        end,
    })
end