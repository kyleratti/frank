util.AddNetworkString("protect_prop")
util.AddNetworkString("unprotect_prop")
util.AddNetworkString("joindata_prop")
util.AddNetworkString("clear_props")

local pl = FindMetaTable("Player")
local ent = FindMetaTable("Entity")

function pl:AddBuddy(objPl)
end

function pl:RemoveBuddy(objPl)
end

function ent:CPPISetOwner(objPl)
	if(not IsValid(objPl)) then
		error("Passed invalid player to CPPISetOwner, yikes")
	end

	frank.PP.Entities[self:EntIndex()] = objPl:UniqueID()

	net.Start("protect_prop")
		net.WriteUInt(self:EntIndex(), 32)
		net.WriteString(objPl:UniqueID())
	net.Broadcast()

	local objPhys = self:GetPhysicsObject()
	if(objPhys:IsValid() and !self:IsVehicle()) then
		objPhys:SetMass(1)
	end
end

hook.Add("OnPhysgunReload", "frank_PP_OnPhysgunReload", function(objWeapon, objPl)
	local objEnt = objPl:GetEyeTrace().Entity
	if(not IsValid(objEnt)) then return false end

	return objPl:CanTouch(objEnt, true)
end)

hook.Add("PlayerInitialSpawn", "frank_PP_PlayerInitialSpawn", function(objPl)
	local tblData = {}
	for k,v in pairs(frank.PP.Entities) do
		tblData[v] = tblData[v] or {}

		table.insert(tblData[v], k)
	end

	for k,v in pairs(tblData) do
		if(not IsValid(objPl)) then return end

		local strJSON = util.TableToJSON(v)
		local strData = util.Compress(strJSON)

		if(not strData) then
			error("Unable to compress entity data")
		end

		local iLen = string.len(strData)

		net.Start("joindata_prop")
			net.WriteString(k)
			net.WriteUInt(iLen, 32)
			net.WriteData(strData, iLen)
		net.Send(objPl)
	end

	if(timer.Exists("frank_pp_RemoveProps_"..objPl:UniqueID())) then
		timer.Destroy("frank_pp_RemoveProps_"..objPl:UniqueID())
	end
end)

frank.PP = frank.PP or {}

function frank.PP.ClearProps(strUniqueID)
	for k,v in pairs(ents.GetAll()) do
		if(v:CPPIControlled() and v:CPPIGetOwner() == strUniqueID) then
			if(frank.PP.Entities[v:EntIndex()]) then
				frank.PP.Entities[v:EntIndex()] = nil
			end

			v.PP_Ignore = true -- prevent a net message for this prop
			SafeRemoveEntity(v)
		end
	end

	net.Start("clear_props")
		net.WriteString(strUniqueID)
	net.Broadcast()
end

hook.Add("PlayerDisconnected", "frank_PP_PlayerDisconnected", function(objPl)
	local strUniqueID = objPl:UniqueID()

	timer.Create("frank_pp_RemoveProps_"..strUniqueID, 60 * 2, 1, function()
		frank.PP.ClearProps(strUniqueID)
	end)
end)

hook.Add("EntityRemoved", "frank_PP_EntityRemoved", function(objEnt)
	if(objEnt:CPPIControlled() and !objEnt.PP_Ignore) then
		if(frank.PP.Entities[objEnt:EntIndex()]) then
			frank.PP.Entities[objEnt:EntIndex()] = nil
		end

		net.Start("unprotect_prop")
			net.WriteUInt(objEnt:EntIndex(), 32)
		net.Broadcast()
	end
end)

-- nabbed from FPP
if(cleanup) then
	frank.PP.OldCleanup = frank.PP.OldCleanup or cleanup.Add

	function cleanup.Add(objPl, iType, objEnt)
		if(IsValid(objPl) and IsValid(objEnt)) then
			objEnt:CPPISetOwner(objPl)

			if(objEnt:GetClass() == "gmod_wire_expression2") then
				objEnt:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end

		return frank.PP.OldCleanup(objPl, iType, objEnt)
	end
end