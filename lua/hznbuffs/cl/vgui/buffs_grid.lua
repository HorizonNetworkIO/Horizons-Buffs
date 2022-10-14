local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(40)

function PANEL:Init()
    wimg.Register("sadface", "https://i.imgur.com/WKOPtvV.png")
    self.sadfaceMat = wimg.Create("sadface")
end

function PANEL:SetUp()
    // scrollable panel
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)
    self.scroll:GetVBar():SetWide(0)

    self.scroll.Paint = function(s, w, h)
        if (#HZNBuffs.MyBuffs == 0) then
            self.sadfaceMat(w/2-sw(50), h/2-sh(50) + sh(10), sw(100), sh(100))
            draw.DrawText("That's sad, it looks like you don't have any buffs!\nYou can purchase them from the !shop menu.", "HZNBuffs:B:25", w/2, h/2 - sh(110), HZNBuffs.Colors[3], 1, 1)
        end
    end

    for i,v in ipairs(HZNBuffs.MyBuffs) do 
        if (v.permanent) then
            local slot = vgui.Create("HZNBuffs:Slot", self)
            slot:SetSize(self:GetWide(), sh(120))
            slot:Dock(TOP)
            slot:DockMargin(0, 0, 0, sh(10))
            slot.id = v.id
            slot.gridSlot = i
            slot:SetUp()
            self.scroll:AddItem(slot)
        end
    end
end

function PANEL:Paint()
    
end

vgui.Register("HZNBuffs:Grid", PANEL, "DPanel")