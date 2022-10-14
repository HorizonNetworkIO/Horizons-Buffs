local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(40)

function PANEL:Init()
    wimg.Register("shield", "https://i.imgur.com/tEdqCPH.png")
    self.shieldMat = wimg.Create("shield")

    wimg.Register("heart", "https://i.imgur.com/INAYRkF.png")
    self.heartMat = wimg.Create("heart")

    wimg.Register("pistol", "https://i.imgur.com/Aqzb6vH.png")
    self.pistolMat = wimg.Create("pistol")

    wimg.Register("boots", "https://i.imgur.com/Qr0EJMV.png")
    self.bootsMat = wimg.Create("boots")
    
    wimg.Register("key", "https://i.imgur.com/ZqFaaqT.png")
    self.keyMat = wimg.Create("key")

    wimg.Register("moneysign", "https://i.imgur.com/cDMNE9K.png")
    self.moneyMat = wimg.Create("moneysign")

    wimg.Register("clover", "https://i.imgur.com/GmEe8p3.png")
    self.cloverMat = wimg.Create("clover")

    wimg.Register("upgraph", "https://i.imgur.com/zBlh9iP.png")
    self.upgraphMat = wimg.Create("upgraph")

    wimg.Register("speedclock", "https://i.imgur.com/6Q6b36E.png")
    self.speedclockMat = wimg.Create("speedclock")

    self.icons = {
        [1] = self.heartMat,
        [2] = self.shieldMat,
        [3] = self.bootsMat,
        [4] = self.keyMat
    }

    self.cols = {
        [1] = Color(97, 241, 60),
        [2] = Color(247, 37, 22),
        [3] = Color(48, 48, 230),
        [4] = Color(228, 228, 37)
    }

    self:SetText("")
end

function PANEL:SetUp()
    self.buff = HZNBuffs.MyBuffs[self.gridSlot]
    self.iconColor = Color(self.cols[HZNBuffs.Buffs[self.id].type].r, self.cols[HZNBuffs.Buffs[self.id].type].g, self.cols[HZNBuffs.Buffs[self.id].type].b, 100)

    self.btn = vgui.Create("DButton", self)
    self.btn:SetSize(sw(120), sh(35))
    self.btn:SetPos(self:GetWide() - self.btn:GetWide() - sw(30), self:GetTall() - self.btn:GetTall() - sh(10))
    self.btn:SetText("")
    self.btn.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, HZNBuffs.Colors[1])
        local maxWidth = sw(20)
        local boxCol = HZNBuffs.Colors[5]

        if (self.verify) then
            maxWidth = sw(60)
            boxCol = HZNBuffs.Colors[6]
        end
        
        local width = sw(5)

        if (!s:IsHovered()) then
            self.verify = false
            s.hoverTime = 0
        elseif (s.hoverTime == 0) then
            s.hoverTime = CurTime()
        end

        if (self.buff.active) then
            maxWidth = sw(150)
            if (self.verify) then
                maxWidth = sw(60)
                // lerp width of box from 5 to 20 starting with hoverTime
                local lerp = math.Clamp(math.TimeFraction(s.hoverTime, s.hoverTime + 0.15, CurTime()), 0, 1)
                width = Lerp(lerp, 150, maxWidth)

                draw.RoundedBox(0, 0, 0, width, h, HZNBuffs.Colors[5])
                draw.SimpleText("Disable Buff?", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            else
                draw.RoundedBox(0, 0, 0, maxWidth, h, boxCol)
                draw.SimpleText("Active", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            end
            return
        else
            maxWidth = sw(150)
            if (self.verify) then
                maxWidth = sw(60)


                if (self.didClick) then
                    local lerp = math.Clamp(math.TimeFraction(self.didClick, self.didClick + 0.15, CurTime()), 0, 1)
                    width = Lerp(lerp, 20, sw(150))
                else
                    local lerp = math.Clamp(math.TimeFraction(s.hoverTime, s.hoverTime + 0.15, CurTime()), 0, 1)
                    width = Lerp(lerp, 20, maxWidth)
                end

                draw.RoundedBox(0, 0, 0, width, h, HZNBuffs.Colors[5])
                draw.SimpleText("Enable Buff?", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            else
                maxWidth = sw(5)
                if (s:IsHovered()) then
                    maxWidth = sw(20)
                    local lerp = math.Clamp(math.TimeFraction(s.hoverTime, s.hoverTime + 0.15, CurTime()), 0, 1)
                    width = Lerp(lerp, 5, maxWidth)
                    draw.RoundedBox(0, 0, 0, width, h, boxCol)
                else
                    draw.RoundedBox(0, 0, 0, maxWidth, h, boxCol)
                end
                draw.SimpleText("Not Active", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            end

            if (!s:IsHovered()) then
                self.verify = false
            end
            return
        end
    end
    self.btn.DoClick = function()
        if (self.buff) then
            if (!self.verify) then
                self.verify = true 
            else
                net.Start("HZNBuffs:UseItem")
                net.WriteEntity(self:GetParent():GetParent():GetParent().entity)
                net.WriteUInt(self.gridSlot, 8)
                net.SendToServer()
                self.didClick = CurTime()
            end
        end
        self.btn.hoverTime = CurTime()
        // play ui sound
    end

    self.descriptionText = vgui.Create("DLabel", self)
    self.descriptionText:SetPos(sw(100), sh(38))
    self.descriptionText:SetSize(self:GetWide() - sw(145) - self.btn:GetWide(), self:GetTall() - sh(20))
    self.descriptionText:SetText(HZNBuffs.Buffs[self.id].description)
    self.descriptionText:SetFont("HZNBuffs:N:20")
    self.descriptionText:SetWrap(true)
    self.descriptionText:SetAutoStretchVertical(true)
    self.descriptionText:SetTextColor(HZNBuffs.Colors[3])
    self.descriptionText:SetExpensiveShadow(2, color_black)
end

function PANEL:Paint(w, h)
    if (self.buff) then
        draw.RoundedBox(4, 0, 0, w, h, HZNBuffs.Colors[2])

        draw.SimpleText(HZNBuffs.Buffs[self.id].name, "HZNBuffs:B:25", sw(100), sh(13), HZNBuffs.Colors[3], TEXT_ALIGN_LEFT)

        self.icons[HZNBuffs.Buffs[self.id].icon](sw(22.5), h/2-sh(30), sw(60), sh(60), self.iconColor)

        draw.RoundedBoxEx(4, 0, 0, sw(5), h, self.cols[HZNBuffs.Buffs[self.id].type], true, false, true, false)
    end
end

vgui.Register("HZNBuffs:Slot", PANEL, "DPanel")