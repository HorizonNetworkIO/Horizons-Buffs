local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(45)

function PANEL:Init()
    if HZNBuffs.Menu then
        HZNBuffs.Menu:Remove()
    end
    HZNBuffs.Menu = self

    wimg.Register("delete", "https://i.imgur.com/OunTuKU.png")
    self.closeMat = wimg.Create("delete")

    wimg.Register("hourglass", "https://i.imgur.com/EO9xG4I.png")
    self.hourglassMat = wimg.Create("hourglass")

    wimg.Register("shoppingbag", "https://i.imgur.com/UJWe22g.png")
    self.shopMat = wimg.Create("shoppingbag")

    wimg.Register("sadface", "https://i.imgur.com/WKOPtvV.png")
    self.sadfaceMat = wimg.Create("sadface")

    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(true)

    self.title = "Permanent Buffs"
    surface.SetFont("HZNBuffs:N:35")
    self.headSize = select(1, surface.GetTextSize(self.title))

    self:SetUp()
end

function PANEL:SetUp()
    self:SetSize(sw(500), sh(580))
    self:Center()
    self:MakePopup()

    if (self.closeBtn) then
        self.closeBtn:Remove()
    end

    if (self.shopBtn) then
        self.shopBtn:Remove()
    end

    self.closeBtn = vgui.Create("DButton", self)
    self.closeBtn:SetSize(sh(25), sh(25))
    self.closeBtn:SetPos(self:GetWide() - self.closeBtn:GetWide() - sw(15), header_size/2 - self.closeBtn:GetTall()/2)
    self.closeBtn:SetText("")
    self.closeBtn.Paint = function(s, w, h)
        local col = color_white
        if (s:IsHovered()) then 
            col = HZNBuffs.Colors[4]
        end
        self.closeMat(0, 0, w, h, col)
    end
    self.closeBtn.DoClick = function()
        self:Remove()
    end

    self.shopBtn = vgui.Create("DButton", self)
    self.shopBtn:SetSize(sh(25), sh(25))
    self.shopBtn:SetPos(self:GetWide() - self.closeBtn:GetWide() - self.shopBtn:GetWide() - sw(30), header_size/2 - self.closeBtn:GetTall()/2)
    self.shopBtn:SetText("")
    self.shopBtn.Paint = function(s, w, h)
        local col = color_white
        if (s:IsHovered()) then 
            col = HZNBuffs.Colors[4]
        end
        self.shopMat(0, 0, w, h, col)
    end
    self.shopBtn.DoClick = function()
        self:Remove()
        local shop = vgui.Create("HZNBuffs:Shop:Frame")
        shop:SetEntity(self.entity)
        shop:SetUp()
    end

    if (self.scroll) then
        self.scroll:Clear()
    else
        self.scroll = vgui.Create("DScrollPanel", self)
        self.scroll:SetSize(self:GetWide() - sw(20), self:GetTall() - header_size - sw(10))
        self.scroll:SetPos(sw(10), header_size + sh(10))
        self.scroll:GetVBar():SetWide(0)
    end

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

function PANEL:SetEntity(ent)
    if (ent == nil) then
        self:Remove()
        return
    end

    self.entity = ent
end

function PANEL:OnRemove()
    HZNBuffs.Menu = nil
end

function PANEL:Paint(w, h)
    HZNShadows.BeginShadow( "HZNBuffs:Menu3" )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox(4, x, y, w, h, HZNBuffs.Colors[1])
    draw.RoundedBoxEx(4, x, y, w, header_size, HZNBuffs.Colors[2], true, true, false, false)
    draw.SimpleText(self.title, "HZNBuffs:N:35", x + w / 2, y + header_size / 2, HZNBuffs.Colors[3], 1, 1)

    HZNShadows.EndShadow( "HZNBuffs:Menu3", x, y, 2, 2, 1, 255, 0, 1, false )
end

vgui.Register("HZNBuffs:Frame", PANEL, "DFrame")