------------------------------------------
--[[


	Fobro's Library
	File: Miscellenious Base Code


--]]
------------------------------------------




--[[
	Register file
--]]
FLib.Func.RegisterFile()


--[[
	Networking
---]]
if SERVER then
	util.AddNetworkString( "FLib.Hook.PlayerLoaded" )
end

------------------------------------------
--[[
	Player loaded hook
--]]

-- note: this is a way to make sure networking is operational
if SERVER then
	net.Receive( "FLib.Hook.PlayerLoaded", function( len, ply )
		FLib.Func.DPrint( [[Player "]]..ply:Nick()..[[" has fully loaded]] )
		hook.Run( "FLib.PlayerLoaded", ply )
	end )
end

if CLIENT then
	hook.Add( "InitPostEntity", "FLib.PlayerLoaded", function()
		net.Start( "FLib.Hook.PlayerLoaded" )
		net.SendToServer()
		hook.Run( "FLib.PlayerLoaded", LocalPlayer() )
	end )
end

------------------------------------------
--[[
	LOAD CONSOLE SYSTEM
--]]

FLib.Func.AddSharedFile( "base/concommand.lua" )


------------------------------------------
--[[
	VGUI & Scale Draw
--]]

-- notes: 
--		- all scaling is done relative to a 1920 x 1080 anchor (most common for games/default)
--		- all of these are built at some level using surface functions, so changing attributes of drawing can be done there if not specified
if CLIENT then
	FLib.Textures = {}
	scaleDraw = {}
	scaleDraw.Amplifier = ( ScrH()*ScrW() )/( 1920*1080 )
	scaleDraw.AmplifierX = (ScrW()/1920)
	scaleDraw.AmplifierY= (ScrH()/1080)
	scaleDraw.FontAnchor = {}

	hook.Add( "OnScreenSizeChanged", "FLib.ScaleDraw.ChangedSize", function( oldWidth, oldHeight )
		scaleDraw.Amplifier = ( ScrH()*ScrW() )/( 1920*1080 )
		scaleDraw.AmplifierX = (ScrW()/1920)
		scaleDraw.AmplifierY= (ScrH()/1080)
		for fontname, tbl in pairs( scaleDraw.FontAnchor ) do
			local properties = tbl.properties
			properties.size = scaleDraw.Scale( tbl.anchorSize )
			surface.CreateFont( fontname, properties )
		end
		ampX, ampY, amp = scaleDraw.AmplifierX, scaleDraw.AmplifierY, scaleDraw.Amplifier
	end )

	local ampX, ampY, amp = scaleDraw.AmplifierX, scaleDraw.AmplifierY, scaleDraw.Amplifier
	function scaleDraw.Scale( pixelCount )
		return pixelCount*scaleDraw.Amplifier
	end

	function scaleDraw.ScaleX( x )
		return x*scaleDraw.AmplifierX
	end

	function scaleDraw.ScaleY( y )
		return y*scaleDraw.AmplifierY
	end

	function scaleDraw.RoundedBox( cornerRadius, x, y, width, height, color )
		draw.RoundedBox( cornerRadius, ampX*x, ampY*y, ampX*width, ampY*height, color  )
	end

	function scaleDraw.RoundedBox( cornerRadius, x, y, width, height, color )
		draw.RoundedBox( cornerRadius, ampX*x, ampY*y, ampX*width, ampY*height, color  )
	end

	function scaleDraw.DrawRect( x, y, width, height ) 
		surface.DrawRect( ampX*x, ampY*y, ampX*width, ampY*height )
	end

	function scaleDraw.DrawTexturedRect( x, y, width, height, texture )
		surface.SetMaterial( texture )
		surface.DrawTexturedRect( ampX*x, ampY*y, ampX*width, ampY*height )
	end

	function scaleDraw.ScalePoly( vertices ) -- only use this once to scale a table of vertices (requires for loop so usual O^n stuff)
		for i = 1, #vertices do
			vertices[i].x, vertices[i].y = ampX*vertices[i].x, ampY*vertices[i].y
		end
		return vertices
	end

	function scaleDraw.CreateFont( name, properties )
		scaleDraw.FontAnchor[name] = { ["anchorSize"] = properties.size, ["properties"] = properties }
		properties.size = scaleDraw.Scale( scaleDraw.FontAnchor[name].anchorSize )
		surface.CreateFont( name, properties )
	end

	function FLib.Func.AddURLImage( identifier, url, w, h, time ) -- Imported/resembled to save time from @mattkrins on Github (https://gist.github.com/mattkrins/5455b96631cc2ebdf0e577a71d1a3d54)
		if not LocalPlayer():IsValid() then 
			hook.Add( "FLib.PlayerLoaded", "FLib.Textures.LoadImage."..identifier, function()
				FLib.Func.AddURLImage( identifier, url, w, h, time )
			end )
			return
		end
		if not url or not w or not h then FLib.Func.DPrint( "Failed to load URL image into library (missing arguments)", true ) return end
		local HTMLPanel = vgui.Create( "HTML" )
		HTMLPanel:SetAlpha( 0 )
		HTMLPanel:SetSize( scaleDraw.Scale( tonumber(w) ), scaleDraw.Scale( tonumber(h) ) )
		HTMLPanel:OpenURL( url )
		timer.Simple( 3, function() 
			if IsValid(HTMLPanel) then
				if HTMLPanel:GetHTMLMaterial() then
					local htmlmat = HTMLPanel:GetHTMLMaterial()
					local finalMat = CreateMaterial("FLib.Textures."..identifier,"UnlitGeneric",{
					["$basetexture"]= htmlmat:GetName(), 
					["$vertexalpha"] = 1,
					})
					FLib.Textures[identifier] = finalMat
				else
					FLib.Textures[identifier] = Material("error")
				end
				HTMLPanel:Remove()
			end
		end )
	end

	function FLib.Func.GetURLImage( identifier )
		return FLib.Textures[identifier]
	end

	surface.GetImage = FLib.Func.GetURLImage -- quick alias
	surface.AddImage = FLib.Func.AddURLImage


end
