hook.Add("HZNLib:FullSpawn", "HZNBuffs:PlayerInitialSpawn", function(ply)
    HZNBuffs:SyncBuffs(ply)
    HZNBuffs:SyncPlayerBuffs(ply)
end)

hook.Add("PlayerSpawn", "HZNBuffs:PlayerSpawn", function(ply)
    HZNBuffs:GatherBuff(ply)
end)

hook.Add("PlayerDeath", "HZNBuffs:PlayerDeath", function(ply)
    local steamid = ply:SteamID() 
    HZNBuffs:GetBuffs(steamid, function(buffs)
        for k,v in ipairs(buffs) do
            if (v.active) then
                HZNBuffs.Buffs[v.id].onRemove(ply, true)
            end
        end
    end)
end)

hook.Add("playerBoughtCustomEntity", "HZNBuffs:PrinterSpeedBuff", function(ply, ent, price)
    if (ent.sPrinter_ent and ply.hzn_sprinterspeed) then
        ent:SetPrintSpeed(ent:GetPrintSpeed() * ply.hzn_sprinterspeed)
    end
end)

hook.Add("PlayerDisconnected", "HZNBuffs:PlayerDisconnect", function(ply)
    local steamid = ply:SteamID() 
    HZNBuffs:GetBuffs(steamid, function(buffs)
        for k,v in ipairs(buffs) do
            if (v.active) then
                if (!v.permanent) then
                    HZNBuffs:TakeBuff(steamid, k)
                    local timerStr = "HZNBuffs:UseBuffTimer:" .. steamid .. ":" .. k
                    timer.Remove(timerStr)
                end
            end
        end
    end)
end)

// buff hooks
hook.Add("ztm_OnTrashBurned", "HZNBuffs:TrashmanBurningBuff", function(ply, trashburner, earning, trash)
    if (ply.hzn_trashman_burn) then
        return earning * ply.hzn_trashman_burn
    end
end)

hook.Add("ztm_OnTrashBlockSold", "HZNBuffs:TrashmanRecyclingBuff", function(ply, buyermachine, earning)
    if (ply.hzn_trashman_recycle) then
        return earning * ply.hzn_trashman_recycle
    end
end)

hook.Add("lockpickTime", "HZNBuffs:LockpickSpeedBuff", function (ply, ent)
    local wep = ply:GetActiveWeapon()
    local curTime = CurTime()
    timer.Simple(0, function ()
        local speed = ply.hzn_lockpickspeed
        if (speed and speed ~= 100) then
            local lockpickTime = wep:GetLockpickEndTime() - curTime
            wep:SetLockpickEndTime(curTime + (lockpickTime * (speed / 100)))
        end
    end)
end)

hook.Add("zmlab2_PreMethSell", "HZNBuffs:MethBuff", function(ply, earning)
    if (ply.hzn_methdoublepayout) then
        return earning * ply.hzn_methdoublepayout
    end
end)

hook.Add("zgo2.NPC.OnQuickSell","HZNBuffs:WeedBuff",function(ply,weed_id,weed_amount,weed_value)
    if (ply.hzn_weeddoublepayout) then
        return weed_value * ply.hzn_weeddoublepayout
    end
end)

hook.Add("pVaultMoneyCleaned", "HZNBuffs:VaultBuff", function(ply, amount)
    if (ply.hzn_bankrobberymultiplier) then
        return amount * ply.hzn_bankrobberymultiplier
    end
end)

hook.Add("zhitman.hitmanKilledTarget", "HZNBuffs:HitmanBuff", function(att, hit, offer)
    if (att.hzn_hitmanbonus) then
        return math.random(offer * 1.05, offer * HZNBuffs.Config.HitmanBonus)
    end
end)

hook.Add("HZNCash:OnPlayTimeReward", "HZNBuffs:CreditsBuff", function(ply, reward)
    if (ply.hzn_creditmultiplier) then
        return reward * ply.hzn_creditmultiplier
    end
end)

hook.Add("HZNCasino.RaisePot", "HZNBuffs:CasinoBuff", function(self, amount, limit, caller)
    if (caller.hzn_casinobonus) then
        // return a random amount between amount * .85 and amount * 1.15
        return math.random(amount * 1.05, amount * HZNBuffs.Config.CasinoBonus), limit
    end
end)

hook.Add("HZNLaw:PlayerArrested", "HZNBuffs:PlayerArrestedBuff", function(criminal, cop, reward)
    if (cop.hzn_arrestingbonus) then
        return math.random(reward * 1.05, reward * HZNBuffs.Config.ArrestingBonus)
    end
end)





hook.Add("PlayerLoadout", "HZNBuffs:LoadoutBuffs", function(ply)
    if (!IsValid(ply)) then return end
    
    if (ply.hzn_vapemaster) then
        local randomWep = table.Random(HZNBuffs.Config.VapeList)
        if (randomWep) then
            local wep = ply:Give(randomWep, true)
            if (wep) then
                wep.isPermanent = true
            end
        end
    end
    
    if (ply.hzn_weaponmayhem) then
        local randomWep = HZNBuffs:GetRandomWeapon()
        if (randomWep) then
            local wep = ply:Give(randomWep, true)
            if (wep) then
                wep.isPermanent = true
            end
        end
    end
end)