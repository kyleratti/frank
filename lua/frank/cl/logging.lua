CreateClientConVar("log_showProps", "1", true)

net.Receive("frank.logging.propSpawn", function(iLen)
	if(not GetConVar("log_showProps"):GetBool()) then return end
	
	local objPl = net.ReadEntity()
	if(not IsValid(objPl)) then return end

	MsgC(Color(150, 150, 150, 255), "● ")
	MsgC(team.GetColor(objPl:Team()), objPl:Nick())
	MsgC(color_white, " (")
	MsgC(colorx.gold, objPl:SteamID())
	MsgC(color_white, ") spawned '")
	MsgC(colorx.lime, net.ReadString())
	MsgC(color_white, "'\n")
end)