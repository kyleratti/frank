console = console or {}

function console.AddText(...) -- thanks BlackAwps
	local objColor = color_white
	for k, v in pairs({...}) do
		if (type(v) == "table" and v.r and v.g and v.b) then
			objColor = v
		else
			MsgC(objColor, tostring(v))
		end
	end
	MsgC(objColor, "\n")
end

-- TODO: remove GAMEMODE:IsDarkRP/IsPERP calls, they are stupid
--[[hook.Add("Initialize", "undefined_functions", function()
	if(GAMEMODE and !GAMEMODE.IsDarkRP) then
		function GAMEMODE:IsDarkRP()
			return false
		end
	end

	if(GAMEMODE and !GAMEMODE.IsPERP) then
		function GAMEMODE:IsPERP()
			return false
		end
	end
end)]]--