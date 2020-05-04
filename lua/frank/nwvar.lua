local meta = FindMetaTable("Player")
local tblVars = {}

if(SERVER) then
	util.AddNetworkString("nwvar")
	util.AddNetworkString("nwvar_fullupdate")
	util.AddNetworkString("nwvar_clear")
end

function meta:getNWVar(strVar, objVal)
	local strUniqueID = self:UniqueID()

	if(tblVars[strUniqueID] and tblVars[strUniqueID][strVar]) then
		return tblVars[strUniqueID][strVar]
	end

	return objVal
end

net.Receive("nwvar", function(iLen)
	local strUniqueID = net.ReadString()
	local strVar = net.ReadString()
	local strVal = net.ReadString()
	local tblVal = util.JSONToTable(strVal)
	local objVal = tblVal['Data']

	frank.debugPrint("Received '"..strVar.."' (value: '"..tostring(objVal).."', bytes: "..num.format(iLen / 8)..")")

	if(not tblVars[strUniqueID]) then
		tblVars[strUniqueID] = {}
	end

	tblVars[strUniqueID][strVar] = objVal
end)

net.Receive("nwvar_fullupdate", function(iLen)
	frank.debugPrint("Received 'nwvar_fullupdate' (bytes: "..num.format(iLen / 8)..")")

	local strData = net.ReadString()
	local tblData = util.JSONToTable(strData)

	table.Merge(tbldata, tblVars)
end)

net.Receive("nwvar_clear", function(iLen)
	local strUniqueID = net.ReadString()

	if(tblVars[strUniqueID]) then
		tblVars[strUniqueID] = nil
	end
end)

if(CLIENT) then return end

function meta:setNWVar(strVar, objVal, bPrivate)
	local strUniqueID = self:UniqueID()

	if(not tblVars[strUniqueID]) then
		tblVars[strUniqueID] = {}
	end

	tblVars[strUniqueID][strVar] = objVal

	net.Start("nwvar")
		net.WriteString(strUniqueID)
		net.WriteString(strVar)
		net.WriteString(util.TableToJSON({['Data'] = objVal}))
	if(bPrivate) then
		net.Send(self)
	else
		net.Broadcast()
	end

	return objVal
end

hook.Add("PlayerInitialSpawn", "nwvars_PlayerInitialSpawn", function(objPl)
	if(table.Count(tblVars) == 0) then return end
	local tblData = {}

	for strUniqueID,_ in pairs(tblVars) do
		if(strUniqueID ~= objPl:UniqueID()) then
			tblData[strUniqueID] = {}
			for strVar,objVal in pairs(tblVars[strUniqueID]) do
				tblData[strUniqueID][strVar] = objVal
			end
		end
	end

	local strData = util.TableToJSON(tblData)

	net.Start("nwvar_fullupdate")
		net.WriteString(strData)
	net.Send(objPl)
end)

hook.Add("PlayerDisconnected", "nwvars_PlayerDisconnected", function(objPl)
	local strUniqueID = objPl:UniqueID()

	-- if there isn't a timer this conflicts with other hooks that use NWVars
	-- a delay of 0 is probably okay but 0.05 works too, just in case!
	timer.Simple(0.05, function()
		net.Start("nwvar_clear")
			net.WriteString(strUniqueID)
		net.Broadcast()

		if(tblVars[strUniqueID]) then
			tblVars[strUniqueID] = nil
		end
	end)
end)