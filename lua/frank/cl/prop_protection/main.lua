net.Receive("protect_prop", function(iLen)
	local iIndex = net.ReadUInt(32)
	local strUniqueID = net.ReadString()

	frank.PP.Entities[iIndex] = strUniqueID
end)

net.Receive("unprotect_prop", function(iLen)
	local iIndex = net.ReadUInt(32)

	if(frank.PP.Entities[iIndex]) then
		frank.PP.Entities[iIndex] = nil
	end
end)

net.Receive("joindata_prop", function(iLen)
	local strUniqueID = net.ReadString()
	local iLen = net.ReadUInt(32)
	local strData = net.ReadData(iLen)
	strData = util.Decompress(strData)

	if(not strData) then
		error("Unable to decompress joindata_prop")
	end

	local tblData = util.JSONToTable(strData)

	for k,v in pairs(tblData) do
		frank.PP.Entities[v] = strUniqueID
	end
end)

net.Receive("clear_props", function(iLen)
	local strUniqueID = net.ReadString()

	for k,v in pairs(frank.PP.Entities) do
		if(v == strUniqueID) then
			frank.PP.Entities[k] = nil
		end
	end
end)

hook.Add("HUDPaint", "frank_PP_HUDPaint", function()
	if(IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then return end

	local objEnt = LocalPlayer():GetEyeTrace().Entity
	if(not IsValid(objEnt) or !objEnt:CPPIControlled()) then return end
	if(objEnt:GetPos():Distance(LocalPlayer():GetPos()) > 512) then return end
	local strUniqueID = objEnt:CPPIGetOwner()
	local objPl = player.GetByUniqueID(strUniqueID)
	local strNick = "N/A"
	local tblBackground = color_white
	local tblIndicator = Color(200, 50, 50, 255)

	if(IsValid(objPl)) then
		strNick = objPl:Nick()
		tblBackground = team.GetColor(objPl:Team())

		if(LocalPlayer():CanTouch(objEnt)) then
			tblIndicator = Color(50, 200, 50, 255)
		end
	end

	surface.SetFont("ChatFont")
	local iWidth = math.Clamp(surface.GetTextSize(strNick), 30, 200)

	draw.RoundedBox(4, ScrW() - 02 - iWidth - 8, ScrH() / 2 - 2, iWidth + 2 + 8, 24, tblIndicator) -- outline for backgruond
	draw.RoundedBox(4, ScrW() - 02 - iWidth - 6, ScrH() / 2, iWidth + 6, 20, tblBackground) -- background
	--draw.RoundedBox(4, ScrW() - 10 - iWidth - 6, ScrH() / 2, 10, 20, Color(0, 0, 0, 0)) -- outline for indicator
	draw.RoundedBox(4, ScrW() - 10 - iWidth - 4, ScrH() / 2 + 2, 6, 16, tblIndicator) -- can touch indicator
	draw.SimpleText(strNick, "ChatFont", ScrW() - 5, ScrH () / 2 + 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
end)