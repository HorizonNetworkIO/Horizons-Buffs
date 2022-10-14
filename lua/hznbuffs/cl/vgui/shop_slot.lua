local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end
local header_size = sh(40)

function PANEL:Init()
    wimg.Register("moneysign", "https://i.imgur.com/cDMNE9K.png")
    self.moneyMat = wimg.Create("moneysign")

    wimg.Register("clover", "https://i.imgur.com/GmEe8p3.png")
    self.cloverMat = wimg.Create("clover")

    wimg.Register("upgraph", "https://i.imgur.com/zBlh9iP.png")
    self.upgraphMat = wimg.Create("upgraph")

    wimg.Register("speedclock", "https://i.imgur.com/6Q6b36E.png")
    self.speedclockMat = wimg.Create("speedclock")

    self.icons = {
        [1] = self.moneyMat,
        [2] = self.upgraphMat,
        [3] = self.cloverMat,
        [4] = self.speedclockMat
    }
    self.cols = {
        [1] = Color(97, 241, 60),
        [2] = Color(247, 37, 22),
        [3] = Color(48, 48, 230),
        [4] = Color(228, 228, 37)
    }
end

function PANEL:SetUp()
    self.buff = HZNBuffs.Buffs[self.id]
    self.formatedPrice = DLL.FormatMoney(self.buff.ShopPrice)
    self.description = self.buff.description
    self.iconColor = Color(self.cols[self.buff.type].r, self.cols[self.buff.type].g, self.cols[self.buff.type].b, 100)
    self.verify = false
    HZNBuffs:HasBuff(self.id, function(doesHave, buff)
        self.purchased = doesHave
        if (doesHave) then
            self.buffActive = buff.active
            self.buffStartTime = buff.startTime
            self.slotId = buff.slotId
        end
    end)

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

        if (self.buffActive) then
            maxWidth = sw(150)
            if (self.verify) then
                maxWidth = sw(60)
                // lerp width of box from 5 to 20 starting with hoverTime
                local lerp = math.Clamp(math.TimeFraction(s.hoverTime, s.hoverTime + 0.15, CurTime()), 0, 1)
                width = Lerp(lerp, 150, maxWidth)

                draw.RoundedBox(0, 0, 0, width, h, HZNBuffs.Colors[5])
                draw.SimpleText("Remove Buff?", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            else
                draw.RoundedBox(0, 0, 0, maxWidth, h, boxCol)
                draw.SimpleText("Buff Activated!", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            end

            if (!s:IsHovered()) then
                self.verify = false
            end
            return
        end

        if (self.purchaseTime != nil) then
            if (self.purchaseTime > CurTime() - 1) then
                maxWidth = sw(150)
                if (self.purchased) then
                    draw.SimpleText("Buff Activated!", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
                else
                    draw.SimpleText("Purchased!", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
                end
                draw.RoundedBox(0, 0, 0, maxWidth, h, boxCol)
            else
                self.purchaseTime = nil 
                self.verify = false
            end
            return
        end

        if (s:IsHovered()) then
            if (!s.hoverTime) then
                s.hoverTime = CurTime()
                s.stopHoverTime = nil
                s.hasHovered = true
            end

            // lerp width of box from 5 to 20 starting with hoverTime
            local lerp = math.Clamp(math.TimeFraction(s.hoverTime, s.hoverTime + 0.15, CurTime()), 0, 1)
            width = Lerp(lerp, 5, maxWidth)
        else
            if (s.hasHovered) then
                s.stopHoverTime = CurTime()
                s.hasHovered = false
                self.verify = false
            end
            
            if (s.stopHoverTime != nil) then
                // lerp width of box from 20 to 5 starting with stopHoverTime
                local lerp = math.Clamp(math.TimeFraction(s.stopHoverTime, s.stopHoverTime + 0.1, CurTime()), 0, 1)
                width = Lerp(lerp, maxWidth, 5)
            end

            s.hoverTime = nil
        end


        if (!self.verify) then
            if (self.purchased) then
                boxCol = HZNBuffs.Colors[5]
                draw.RoundedBox(0, 0, 0, width, h, boxCol)
                draw.SimpleText("Use Buff", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            else
                boxCol = HZNBuffs.Colors[6]
                draw.RoundedBox(0, 0, 0, width, h, boxCol)
                draw.SimpleText("Purchase Buff", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
            end
        else
            boxCol = self.purchased and HZNBuffs.Colors[5] or HZNBuffs.Colors[6]
            draw.RoundedBox(0, 0, 0, width, h, boxCol)
            draw.SimpleText("Are you sure?", "HZNBuffs:B:20", w/2, h/2, HZNBuffs.Colors[3], 1, 1)
        end
    end
    self.btn.DoClick = function()
        if (self.buff) then
            if (self.buffActive) then // disable buff
                if (!self.verify) then
                    self.verify = true
                else
                    net.Start("HZNBuffs:UseItem")
                    net.WriteEntity(self:GetParent():GetParent():GetParent().entity)
                    net.WriteUInt(self.slotId, 8)
                    net.SendToServer()
                end
            else
                if (self.purchased) then
                    if (!self.verify) then
                        self.verify = true
                    else // use buff
                        net.Start("HZNBuffs:UseItem")
                        net.WriteEntity(self:GetParent():GetParent():GetParent().entity)
                        net.WriteUInt(self.slotId, 8)
                        net.SendToServer()
                    end
                else
                    if (!self.verify) then
                        self.verify = true
                    elseif (self.purchaseTime == nil) then // purchase buff
                        surface.PlaySound("ui/buttonclick.wav")
                        self.purchaseTime = CurTime()
        
                        net.Start("HZNBuffs:PurchaseItem")
                        net.WriteEntity(self:GetParent():GetParent():GetParent().entity)
                        net.WriteUInt(self.id, 8)
                        net.SendToServer()
                    end
                end
            end
        end
        self.btn.hoverTime = CurTime()
        // play ui sound
    end

    self.descriptionText = vgui.Create("DLabel", self)
    self.descriptionText:SetPos(sw(100), sh(38))
    self.descriptionText:SetSize(self:GetWide() - sw(145) - self.btn:GetWide(), self:GetTall() - sh(20))
    self.descriptionText:SetText(self.description)
    self.descriptionText:SetFont("HZNBuffs:N:20")
    self.descriptionText:SetWrap(true)
    self.descriptionText:SetAutoStretchVertical(true)
    self.descriptionText:SetTextColor(HZNBuffs.Colors[3])
    self.descriptionText:SetExpensiveShadow(2, color_black)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, HZNBuffs.Colors[2])

    if (self.buff) then
        draw.SimpleText(self.buff.name, "HZNBuffs:B:25", sw(100), sh(13), HZNBuffs.Colors[3], TEXT_ALIGN_LEFT)
        
        // money / time
        if (self.buffActive) then
            draw.SimpleText(sam.reverse_parse_length((self.buff.duration - (os.time() - self.buffStartTime)) / 60) .. " left", "HZNBuffs:B:20", w - sw(10), sh(13), HZNBuffs.Colors[3], TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText("Duration: " .. sam.reverse_parse_length(self.buff.duration / 60), "HZNBuffs:B:20", w - sw(15), sh(32), HZNBuffs.Colors[3], TEXT_ALIGN_RIGHT)
            draw.SimpleText("Cooldown: " .. sam.reverse_parse_length(HZNBuffs.Buffs[self.buff.id].cooldown / 60), "HZNBuffs:B:20", w - sw(15), sh(49), HZNBuffs.Colors[3], TEXT_ALIGN_RIGHT)
            if (!self.purchased) then
                draw.SimpleText(self.formatedPrice, "HZNBuffs:B:25", w - sw(15), sh(10), HZNBuffs.Colors[6], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
        end

        self.icons[self.buff.type](sw(22.5), h/2-sh(30), sw(60), sh(60), self.iconColor)

        draw.RoundedBoxEx(4, 0, 0, sw(5), h, self.cols[self.buff.type], true, false, true, false)
    end
end

vgui.Register("HZNBuffs:Shop:Slot", PANEL, "DPanel")