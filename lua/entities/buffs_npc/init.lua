AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/breen.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetUseType(SIMPLE_USE)

    self:SetNPCState(NPC_STATE_IDLE)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_MOVE_GROUND)
    self:SetMoveType(MOVETYPE_STEP)  
    
    self:DropToFloor()
end

function ENT:Use(activator, caller)
    if (!IsValid(activator) or !activator:IsPlayer()) then return end
    HZNBuffs.Shop:OpenMenu(activator, self)
end