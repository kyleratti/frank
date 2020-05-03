hook.Add( "PlayerSpawnProp", "frank_PP_PlayerSpawnProp", function( objPl, strModel )
	objPl.m_PropCache = objPl.m_PropCache || { }

	strModel = string.Replace( strModel, " ", "" );
	strModel = string.Replace( strModel, "\\", "/" );
	strModel = string.Trim( strModel );

	local iTime = CurTime( );

	if( objPl.m_PropCache[strModel] ) then
		local iAmount = table.Count( objPl.m_PropCache[strModel] ); -- this should be okay because they should automatically be removed from the table

		if( iAmount >= 5 ) then
			if( !objPl.LastError || CurTime( ) - objPl.LastError > 3 ) then
				frank.SendMessage( objPl, true, colorx["Pink"], strModel, color_white, " was caught by the spam filter! Slow down with prop spawns!" );
				objPl.LastError = CurTime( );
			end

			return false;
		end
	end

	if( !frank.Whitelist.Exists( strModel ) ) then
		if( !objPl.LastError || CurTime( ) - objPl.LastError > 3 ) then
			frank.SendMessage( objPl, true, colorx["Pink"], strModel, color_white, " isn't in the whitelist!" );
			objPl.LastError = CurTime( );
		end

		return false;
	end

	objPl.m_PropCache[strModel] = objPl.m_PropCache[strModel] || { }
	objPl.m_PropCache[strModel][iTime] = true;

	timer.Simple( 2, function( )
		if( !IsValid( objPl ) ) then return; end

		if( objPl.m_PropCache && objPl.m_PropCache[strModel] && objPl.m_PropCache[strModel][iTime] ) then
			objPl.m_PropCache[strModel][iTime] = nil;
		end
	end );
end );