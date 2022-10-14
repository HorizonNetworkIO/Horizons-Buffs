include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:DrawTranslucent()
	DLL.DrawNPCOverhead(self, "Buffs")
end