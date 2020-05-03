local meta = FindMetaTable( "Player" );

function meta:SetCoins( iAmount, bSave )
	self:SetNWVar( "Coins", iAmount );

	if( bSave ) then
		self:SaveCoins( );
	end
end

function meta:AddCoins( iAmount )
	local iCoins = self:GetNWVar( "Coins", 0 );
	self:SetNWVar( iCoins + iAmount );
end

function meta:SaveCoins( )
	// TODO: save to mysql
end