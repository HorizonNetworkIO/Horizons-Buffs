local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(45)

function PANEL:Init()
    if HZNBuffs.Shop.Menu then
        HZNBuffs.Shop.Menu:Remove()
    end
    HZNBuffs.Shop.Menu = self

    wimg.Register("delete", "https://i.imgur.com/OunTuKU.png")
    self.closeMat = wimg.Create("delete")

    wimg.Register("inventorybox", "https://i.imgur.com/lBgV0cR.png")
    self.inventoryBoxMat = wimg.Create("inventorybox")

    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(true)

    self.inited = false

    self.title = "Buffs Shop"
end

function PANEL:OnRemove()
    HZNBuffs.Shop.Menu = nil
end

function PANEL:SetUp()
    self:SetSize(sw(500), sh(580))
    self:Center()
    self:MakePopup()

    if (self.closeBtn) then
        self.closeBtn:Remove()
    end

    if (self.inventoryBtn) then
        self.inventoryBtn:Remove()
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

    self.inventoryBtn = vgui.Create("DButton", self)
    self.inventoryBtn:SetSize(sh(25), sh(25))
    self.inventoryBtn:SetPos(self:GetWide() - self.closeBtn:GetWide() - self.inventoryBtn:GetWide() - sw(30), header_size/2 - self.closeBtn:GetTall()/2)
    self.inventoryBtn:SetText("")
    self.inventoryBtn.Paint = function(s, w, h)
        local col = color_white
        if (s:IsHovered()) then 
            col = HZNBuffs.Colors[4]
        end
        self.inventoryBoxMat(0, 0, w, h, col)
    end
    self.inventoryBtn.DoClick = function()
        self:Remove()
        local inventory = vgui.Create("HZNBuffs:Frame")
        inventory:SetEntity(self.entity)
    end

    // panel exists already? save our scroll position and remove it
    if (self.scroll) then
        self.scroll:Clear()
    else
        self.scroll = vgui.Create("DScrollPanel", self)
        self.scroll:SetSize(self:GetWide() - sw(20), self:GetTall() - header_size - sw(10))
        self.scroll:SetPos(sw(10), header_size + sh(10))
        self.scroll:GetVBar():SetWide(0)
    end

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

function PANEL:SetEntity(ent)
    if (ent == nil) then
        self:Remove()
        return
    end

    self.entity = ent
end

function PANEL:Paint(w, h)
    HZNShadows.BeginShadow( "HZNBuffs:Shop:Menu2" )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox(4, x, y, w, h, HZNBuffs.Colors[1])
    draw.RoundedBoxEx(4, x, y, w, header_size, HZNBuffs.Colors[2], true, true, false, false)
    draw.SimpleText(self.title, "HZNBuffs:N:35", x + w / 2, y + header_size / 2, HZNBuffs.Colors[3], 1, 1)

    HZNShadows.EndShadow( "HZNBuffs:Shop:Menu2", x, y, 2, 2, 1, 255, 0, 1, false )
end


vgui.Register("HZNBuffs:Shop:Frame", PANEL, "DFrame")