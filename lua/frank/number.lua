num = num or {}

function num.format(str)
	str = tostring(str)
	local _,_,str,dec = str:find("^(-?%d+)(%.*%d*)$")
	return str:reverse():gsub("(...)", "%1,"):gsub(",$", ""):reverse()..dec
end