local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(40)

function PANEL:SetUp(gridScroll)
    // scrollable panel
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(0, 0, 0, sh(10))
    self.scroll:GetVBar():SetWide(0)

    timer.Simple(0.1, function()
        if (gridScroll) then
            self.scroll:GetVBar():SetScroll(gridScroll)
        end
    end)

    for k, v in pairs(HZNBuffs.Shop:GetSortedShopItems()) do
        local slot = vgui.Create("HZNBuffs:Shop:Slot", self)
        slot:SetSize(self:GetWide(), sh(120))
        slot.id = v.id
        slot.gridSlot = k
        slot:SetUp()
        self.scroll:AddItem(slot)
        slot:Dock(TOP)
        slot:DockMargin(0, 0, 0, sh(10))
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("HZNBuffs:Shop:Grid", PANEL, "DPanel")