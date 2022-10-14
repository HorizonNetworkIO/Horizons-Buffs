HZNBuffs.ShopItems = {}

// Returns all buffs that can be purchased through the shop.
function HZNBuffs.Shop:GetShopItems()
    if (#HZNBuffs.ShopItems != 0) then
        return HZNBuffs.ShopItems
    end

    local items = {}
    for k, v in pairs(HZNBuffs.Buffs) do
        if v.ShopItem then
            table.insert(items, v)
        end
    end

    HZNBuffs.ShopItems = items
    return items
end

function HZNBuffs.Shop:GetSortedShopItems()
    if (#HZNBuffs.ShopItems != 0) then
        return HZNBuffs.ShopItems
    end

    local items = {}
    for k, v in pairs(HZNBuffs.Buffs) do
        if v.ShopItem then
            table.insert(items, v)
        end
    end

    //.sort table based on the type of the buff
    table.sort(items, function(a, b)
        if a.type == b.type then
            return #a.name < #b.name
        else
            return a.type < b.type
        end
    end)

    HZNBuffs.ShopItems = items
    return items
end

