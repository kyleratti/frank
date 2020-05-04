local meta = FindMetaTable("Player")

function meta:setCoins(iAmount, bSave)
	self:setNWVar("Coins", iAmount)

	if(bSave) then
		self:SaveCoins()
	end
end

function meta:AddCoins(iAmount)
	local iCoins = self:getNWVar("Coins", 0)
	self:setNWVar(iCoins + iAmount)
end

function meta:SaveCoins()
	-- TODO: save to mysql
end