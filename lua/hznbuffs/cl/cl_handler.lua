HZNBuffs.Buffs = HZNBuffs.Buffs or {}
HZNBuffs.MyBuffs = HZNBuffs.MyBuffs or {}
HZNBuffs.Shop = {}

net.Receive("HZNBuffs:SyncBuffs", function()
    HZNBuffs.Buffs = net.ReadTable()
end)

net.Receive("HZNBuffs:SyncPlayerBuffs", function()
    HZNBuffs.MyBuffs = net.ReadTable()
    if (HZNBuffs.Shop.Menu) then
        HZNBuffs.Shop.Menu:SetUp()
    end
    if (HZNBuffs.Menu) then
        HZNBuffs.Menu:SetUp()
    end
    PrintTable(HZNBuffs.MyBuffs)
end)

net.Receive("HZNBuffs:Shop:OpenMenu", function()
    local ent = net.ReadEntity()
    print("Ent : "..tostring(ent))
    if (IsValid(ent)) then
        local shop = vgui.Create("HZNBuffs:Shop:Frame")
        shop:SetEntity(ent)
        shop:SetUp()
    end
end)

function HZNBuffs:HasBuff(id, callback)
    for k,v in ipairs(HZNBuffs.MyBuffs) do
        if (v.id == id) then
            if (callback) then
                callback(true, v)
                return
            end
        end
    end
    callback(false)
end