frank.PP = {}
frank.PP.Entities = {}
frank.PP.Buddies = {}

local pl = FindMetaTable("Player")
local ent = FindMetaTable("Entity")

function pl:CanTouch(objEnt, bConstrained)
	if(not IsValid(objEnt)) then return false end
	if(not objEnt:CPPIControlled()) then return false end

	local strWeapon = self:GetActiveWeapon()
	if(IsValid(strWeapon)) then
		if(strWeapon == "gmod_tool") then
			local strMode = self:GetTool()["Mode"]

			if(strMode == "physprop" or strMode == "rope" or strMode == "material") then
				return false
			end

			if(objEnt:GetClass() == "gmod_cameraprop" and (strMode == "nocollide" or strMode == "colour" or strMode == "material")) then
				return false
			end
		end
	end

	if(SERVER and bConstrained) then
		local tblEnts = constraint.GetAllConstrainedEntities(objEnt)
		local tblChecked = {}

		for k,v in pairs(tblEnts) do
			if(not tblChecked[v]) then
				if(not self:CanTouch(v)) then
					if(not self.LastPPError or CurTime() - self.LastPPError > 3) then
						self:PrintMessage(HUD_PRINTTALK, "Toolgun disallowed (check constrained entities)")
					end

					return false
				end

				tblChecked[v] = true
			end
		end
	end

	if(objEnt:IsWorld() or self:IsMod()) then return true end

	return self:IsBuddies(player.GetByUniqueID(objEnt:CPPIGetOwner()))
end

function pl:GetBuddies()
	return frank.PP.Buddies[self:UniqueID()] or {}
end

function pl:IsBuddies(objPl)
	if(self == objPl) then return true end

	if(frank.PP.Buddies[self:UniqueID()]) then
		return frank.PP.Buddies[self:UniqueID()][objPl:UniqueID()] == true
	end

	return false
end

function ent:CPPIControlled()
	return frank.PP.Entities[self:EntIndex()] ~= nil
end

function ent:CPPIGetOwner()
	return frank.PP.Entities[self:EntIndex()]
end

hook.Add("GravGunPunt", "frank_PP_GravGunPunt", function(objPl, objEnt)
	if(not IsValid(objEnt)) then return false end

	if(SERVER) then
		DropEntityIfHeld(objEnt)
	end

	return false
end)

hook.Add("PhysgunPickup", "frank_PP_PhysgunPickup", function(objPl, objEnt)
	if(not IsValid(objPl) or !IsValid(objEnt)) then return false end

	if(not objEnt:CPPIControlled()) then return false end

	if(objEnt:CPPIGetOwner() == objPl) then
		return true
	end

	return objPl:CanTouch(objEnt)
end)

hook.Add("Initialize", "frank_PP_Initialize", function()
	GAMEMODE.OldCanTool = GAMEMODE.CanTool

	function GAMEMODE:CanTool(objPl, tblTrace, strMode)
		local objEnt = tblTrace.Entity

		if(not objEnt:IsWorld() and !objEnt:CPPIControlled()) then return false end

		return (objEnt:IsWorld() or objPl:CanTouch(objEnt, true))
	end

	function GAMEMODE:CanProperty(objPl, strProperty, objEnt)
		return false
	end

	function GAMEMODE:CanDrive(objPl, objEnt)
		return false
	end
end)