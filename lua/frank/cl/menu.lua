local objFrame = nil;

hook.Add( "ScoreboardShow", "frank_ScoreboardShow_Menu", function( )
	local tblInfo = { LocalPlayer( ):GetRank( ).Name }

	if( LocalPlayer( ):IsVIP( ) ) then
		table.insert( tblInfo, "VIP" );
	end

	objFrame = vgui.Create( "DFrame" );
	objFrame:SetSize( 295, 100 );
	objFrame:SetPos( 0, 0 );
	objFrame:SetTitle( table.concat( tblInfo, ", " ) );
	objFrame:ShowCloseButton( false );
	objFrame:SetVisible( true );
	objFrame:SetKeyboardInputEnabled( true );
	function objFrame:OnClose( )
		self = nil;
	end

	local objAvatar = vgui.Create( "AvatarImage", objFrame );
	objAvatar:SetPlayer( LocalPlayer( ), 64 );
	objAvatar:SetSize( 64, 64 );
	objAvatar:SetPos( 5, 30 );

	local objNick = vgui.Create( "DLabel", objFrame );
	objNick:SetText( LocalPlayer( ):Nick( ) );
	objNick:SetTextColor( colorx[LocalPlayer( ):GetRank( ).ID] );
	objNick:SetFont( "ChatFont" );
	objNick:SizeToContents( );
	objNick:SetPos( objAvatar:GetWide( ) + 10, 30 );

	local objSteamID = vgui.Create( "DLabel", objFrame );
	objSteamID:SetText( LocalPlayer( ):SteamID( ) );
	objSteamID:SetTextColor( color_white );
	objSteamID:SetFont( "ChatFont" );
	objSteamID:SizeToContents( );
	objSteamID:SetPos( objAvatar:GetWide( ) + 10, objNick:GetTall( ) + 30 );

	if( LocalPlayer( ):IsVIP( ) ) then
		local iTime = LocalPlayer( ):GetNWVar( "VIP", 0 );
		local strTime = "";

		if( iTime == -1 ) then
			strTime = "∞";
		else
			strTime = time.Simple( iTime - os.time( ) );
		end

		local objVIP = vgui.Create( "DLabel", objFrame );
		objVIP:SetText( strTime.." VIP remaining" );
		objVIP:SetTextColor( colorx["Gold"] );
		objVIP:SetFont( "ChatFont" );
		objVIP:SizeToContents( );
		objVIP:SetPos( objAvatar:GetWide( ) + 10, objNick:GetTall( ) + objSteamID:GetTall( ) + 30 );
	end

	local objReload = vgui.Create( "DButton", objFrame );
	objReload:SetSize( 125, 20 );
	objReload:SetPos( objAvatar:GetWide( ) + 10, objFrame:GetTall( ) - objReload:GetTall( ) - 6 );
	objReload:SetImage( "icon16/arrow_refresh.png" );
	objReload:SetText( "Reload Account" );
	objReload:SetConsoleCommand( "frank_account_reload" );

	local objDonate = vgui.Create( "DButton", objFrame );
	objDonate:SetSize( 85, 20 );
	objDonate:SetPos( objAvatar:GetWide( ) + objReload:GetWide( ) + 15, objFrame:GetTall( ) - objReload:GetTall( ) - 6 );
	objDonate:SetImage( "icon16/star.png" );
	objDonate:SetText( "Donate" );
	function objDonate:DoClick( )
		local objMenu = DermaMenu( );
		objMenu:AddOption( "Me, Myself, I", function( )
			gui.OpenURL( "http://bananabunch.net/misc.php?page=donate&steam="..LocalPlayer( ):SteamID( ) );
		end );
		if( #player.GetAll( ) > 1 ) then
			objMenu:AddSpacer( );
			local tblPlayers = player.GetAll( );
			table.sort( tblPlayers, function( a, b )
				return string.lower( a:Nick( ) ) < string.lower( b:Nick( ) );
			end );

			for k,v in pairs( player.GetAll( ) ) do
				if( v != LocalPlayer( ) ) then
					objMenu:AddOption( v:Nick( ), function( )
						Derma_Query( "Are you positive you want to donate for\n\n"..v:Nick( ).."\n"..v:SteamID( ), "Confirm Donation", "Yes, donate for "..v:Nick( ), function( )
							gui.OpenURL( "http://bananabunch.net/misc.php?page=donate&steam="..v:SteamID( ) );
						end, "Never mind!" );
					end );
				end
			end
		end
		objMenu:Open( );
	end
end );

hook.Add( "ScoreboardHide", "frank_ScoreboardHide_Menu", function( )
	if( objFrame && IsValid( objFrame ) ) then
		objFrame:Close( );
	end
end );