time = time or {}

function time.short(iTime) -- credits: mantis
	if(iTime == 0) then
		return "an eternity"
	end
	local str = ""

	local iSeconds = math.floor(iTime % 60)
	local iMinutes = math.floor(iTime / 60 % 60)
	local iHours = math.floor(iTime / 60 / 60 % 24)
	local iDays = math.floor(iTime / 60 / 60 / 24)

	if iDays > 0 then str = str .. iDays .. "d" end
	--if iDays > 1 then str = str .. "s" end
	--if iDays > 0 then str = str .. ", " end
	if iDays > 0 then str = str .. " " end

	if iHours > 0 then str = str .. iHours .. "h" end
	--if iHours > 1 then str = str .. "s" end
	--if iHours > 0 then str = str .. ", " end
	if iHours > 0 then str = str .. " " end

	if iMinutes > 0 then str = str .. iMinutes .. "m" end
	--if iMinutes > 1 then str = str .. "s " end
	--if iMinutes > 0 then str = str .. " and " end
	--if iMinutes > 0 then str = str .. ", " end
	if iMinutes > 0 then str = str .. " " end

	if iSeconds > 0 then str = str .. iSeconds .. "s" end
	--if iSeconds > 1 then str = str .. "s" end

	return string.Trim(str)
end

function time.complex(sec)
	local d,h,m,s = math.floor(sec /60 /60 /23) %365,math.floor(sec /60 /60) %24, math.floor(sec /60) %60, sec %60
	local dw,hw,mw,sw = "day","hour","minute","second"
	if(d ~= 1) then
		dw = dw.."s"
	end
	if(h ~= 1) then
		hw = hw.."s"
	end
	if(m ~= 1) then
		mw = mw.."s"
	end
	if(s ~= 1) then
		sw = sw.."s"
	end
	return {Days = {d, dw}, Hours = {h, hw}, Minutes = {m, mw}, Seconds = {s, sw}}
end

function time.simple(t) -- Credits to Overv
	if (!t or t == nil) then return "forever" end
	if (t == 0) then
		return "Forever"
	elseif (t < 60) then
		if (t == 1) then return "1 second" else return t .. " seconds" end
	elseif (t < 3600) then
		if (math.ceil(t / 60) == 1) then return "1 minute" else return math.ceil(t / 60) .. " minutes" end
	elseif (t < 24 * 3600) then
		if (math.ceil(t / 3600) == 1) then return "1 hour" else return math.ceil(t / 3600) .. " hours" end
	elseif (t < 24 * 3600 * 7) then
		if (math.ceil(t / (24 * 3600)) == 1) then return "1 day" else return math.ceil(t / (24 * 3600)) .. " days" end
	elseif (t < 24 * 3600 * 30) then
		if (math.ceil(t / (24 * 3600 * 7)) == 1) then return "1 week" else return math.ceil(t / (24 * 3600 * 7)) .. " weeks" end
	else
		if (math.ceil(t / (24 * 3600 * 30)) == 1) then return "1 month" else return math.ceil(t / (24 * 3600 * 30))  .. " months" end
	end
end