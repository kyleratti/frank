local meta = FindMetaTable("Player")

function meta:isVIP()
	return self:getNWVar("VIP", false)
end

function meta:getChatColor()
	local iRed = self:getNWVar("chat_r", 255)
	local iGreen = self:getNWVar("chat_g", 255)
	local iBlue = self:getNWVar("chat_b", 255)

	return Color(iRed, iGreen, iBlue, 255)
end

function meta:getNickColor(objDefault)
	if(iRed == 255 and iGreen == 255 and iBlue == 255) then
		return team.GetColor(self:Team())
	end

	if(not self:isVIP()) then
		return (objDefault and type(objDefault) == "table" and objDefault or team.GetColor(self:Team()))
	end

	local iRed = self:getNWVar("name_r", 255)
	local iGreen = self:getNWVar("name_g", 255)
	local iBlue = self:getNWVar("name_b", 255)

	return Color(iRed, iGreen, iBlue, 255)
end