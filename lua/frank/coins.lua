local meta = FindMetaTable("Player")

function meta:getCoins()
	return self:getNWVar("Coins", 0)
end