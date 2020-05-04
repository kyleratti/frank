string = string or {}

function string.isSteamID(strString)
	return strString:match("^STEAM_%d:%d:%d+$") ~= nil
end