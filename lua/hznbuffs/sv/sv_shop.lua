HZNBuffs.Shop = {}

util.AddNetworkString("HZNBuffs:Shop:OpenMenu")
function HZNBuffs.Shop:OpenMenu(ply, ent)
    net.Start("HZNBuffs:Shop:OpenMenu")
        net.WriteEntity(ent)
    net.Send(ply)
end

function HZNBuffs.Shop:PurchaseItem(ply, itemid)
    local item = HZNBuffs.Buffs[itemid]
    if not item then return end
    if not item.ShopItem then return end
    if not item.CanPurchase(ply) then 
        HZNBuffs:Say(ply, "You don't have permission to purchase this item!")
        return
    end
    if not ply:canAfford(item.ShopPrice) then 
        HZNBuffs:Say(ply, "You can't afford this item!")
        return
    end

    // add buff to inventory and take money
    HZNBuffs:AddBuff(ply:SteamID(), itemid)
    ply:addMoney(-item.ShopPrice)
end

util.AddNetworkString("HZNBuffs:PurchaseItem")
net.Receive("HZNBuffs:PurchaseItem", function(len, ply)
    local ent = net.ReadEntity()

    if (!ent) then
        HZNBuffs:Log("[ERROR] " .. ply:Nick() .. " (" .. ply:SteamID64() .. ") tried to purchase an item from a non-existent entity! This could indicate that this player is cheating!")
        return
    end

    if (!HZNLib:InDistance(ply, ent, HZNLib.USE_DISTANCE)) then
        HZNBuffs:Say(ply, "You are too far away from the shop!")
        return
    end

    local gridSlot = net.ReadUInt(8)
    HZNBuffs.Shop:PurchaseItem(ply, gridSlot)
end)