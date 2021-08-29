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
	Player Loaded Hook
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
	VGUI & Scale Draw & Hot Load
--]]

-- notes: 
--		- all scaling is done relative to a 1920 x 1080 anchor (most common for games/default)
--		- all of these are built at some level using surface functions, so changing attributes of drawing can be done there if not specified
if CLIENT then
	FLib.Resources = {}

	

	local extensionTypes = {
		png = "image",
		jpeg = "image",
		jpg = "image",
		vtf = "material",
		vmt = "material",
		mp3 = "sound",
		wav = "sound",
		ogg = "sound",
		txt = "data",
		dat = "data",
		csv = "data",
		xml = "data",
		json = "data",
	}
	FLib.HotLoad ={}


	local TypeFunctions = {
		image = {
			prepare = function( identifier, filetype ) -- if you wanna fuck around with png parameters, just use the returned material and steal the texture using GetTexture/SetTexture
				if identifier == "loadingIcon" then
					FLib.Resources[identifier] = Material( "phoenix_storms/wood" )
				elseif FLib.Resources["loadingIcon"] then
					FLib.Resources[identifier] = Material( FLib.Resources["loadingIcon"]:GetTexture( "$basetexture" ):GetName() )
				else
					FLib.Resources[identifier] = Material( "icon16/user.png" )
				end
				return FLib.Resources[identifier] -- lord knows why, but returning this into itself causes it to actually set the value... Nice? IG?
			end,
			load = function( path, identifier, filetype )
				FLib.Resources[identifier] = Material( path )
				return FLib.Resources[identifier]
			end
		},
		material = {
			load = function( path, identifier, filetype )
				if string.lower(filetype) == "vtf" then -- if vtf, mark the identifier
					if not FLib.Resources[identifier] then
						FLib.Resources[identifier] = Material( path )
					else
						FLib.Resources[identifier]:SetTexture( "$basetexture", path )
					end
				else -- if vmt
					if FLib.Resources[identifier] then
						FLib.Resources[identifier] = Material( path ):SetTexture( "$basetexture", FLib.Resources[identifier]:GetTexture( "$basetexture"):GetName() )
					else
						FLib.Resources[identifier] = Material( path )
					end
				end
				return FLib.Resources[identifier]
			end,
			prepare = function( identifier, filetype )
				FLib.Resources[identifier] = Material( "models/wireframe" )
				return FLib.Resources[identifier]
			end
		},

		sound = {
			load = function( path, identifier, filetype )
				sound.Add( {
					name = identifier,
					channel = CHAN_STATIC,
					volume = 1.0,
					level = 80,
					pitch = {95, 110},
					sound = path
				} )
				sound.PlayFile( path, "noplay", function( soundObj, errCode, errStr )
					if ( IsValid( soundObj ) ) then
						FLib.Resources[identifier] = soundObj
					else
						FLib.Func.Print( "Error activating downloaded sound! CODE: "..errCode..". REASON: "..errStr.."." )
					end
				end )
				return FLib.Resources[identifier]
			end
		},
		data = function( path, identifier, filetype )
			-- idk what to do with this yet tbh
		end,
	}

	if not file.Exists( "flib/hotload", "DATA" ) then
		file.CreateDir( "flib/hotload" )
	end

	function FLib.HotLoad.URLSource( identifier, url, filetype, onLoad ) -- must be a valid file.Write filtype (example field would be a string, "png" or "mp3")
		if not identifier or not url or not filetype then
			FLib.Func.Print( "Failed to create URL source ("..(identifier or "NO NAME FOUND").."). Reason: Missing key parameters" )
			return
		end
		local divide = string.Split( url, "." )
		local extension = divide[#divide] or "unspec"
		if extension == "unspec" then -- fall back to predicted filetype if it can't be found in the URL
			local abort = false
			extension = filetype
		end
		if not extensionTypes[extension] then
			FLib.Func.Print( "Couldn't load URL source (invalid file type: "..filetype..")" )
			return
		end
		
		if not file.Exists( "flib/hotload/"..extensionTypes[extension], "DATA" ) then
			file.CreateDir( "flib/hotload/"..extensionTypes[extension] )
		end
		local urlHash = util.CRC( url ) -- identifier for URL in a stable string storage format
		local path = "flib/hotload/"..extensionTypes[extension].."/" .. urlHash .. "." .. extension
		if file.Exists( path, "DATA" ) then
			if TypeFunctions[extensionTypes[extension]]["prepare"] then -- if the load function updates a filler item (i.e. updating a material texture)
				FLib.Resources[identifier] = TypeFunctions[extensionTypes[extension]]["prepare"]( identifier, filetype )
			end
			FLib.Resources[identifier] = TypeFunctions[extensionTypes[extension]]["load"]( "data/"..path, identifier, filetype )
			if onLoad then
				onLoad( FLib.Resources[identifier] or identifier )
			end
		else
			if TypeFunctions[extensionTypes[extension]]["prepare"] then -- if it needs to prep a value before
				FLib.Resources[identifier] = TypeFunctions[extensionTypes[extension]]["prepare"]( identifier, filetype )
			end
			http.Fetch( url, 
				--onSucc
				function( content )
					file.Write( path, content )
					FLib.Resources[identifier] = TypeFunctions[extensionTypes[extension]]["load"]( "data/"..path, identifier, filetype )
					
					if onLoad then
						onLoad( FLib.Resources[identifier] or identifier )
					end
				end, 

				--OnErr
				function( errString )
					FLib.Func.Print( "Failed to retrieve source from URL. Reason: "..errString)
				end
			)
		end
	end

	FLib.HotLoad.ActiveSequence = {}
	function FLib.HotLoad.SourceInSequence( identifier, LoadTable ) -- identifier is the label to retrieve data by, and entryCount is how many it expects to add
		FLib.HotLoad.ActiveSequence[identifier] = { ["id"] = identifier, ["curSlot"] = 1, ["maxSlot"] = #LoadTable }
		for k, v in pairs( LoadTable ) do -- have the identifier set to loading during queue
			FLib.Func.DPrint( "Preparing to load resource from URL ("..v[2]..")" )
			FLib.Resources[v[1]] = FLib.Resources["loadingIcon"]
		end
		local function NextLoad(  )
			FLib.HotLoad.ActiveSequence[identifier].curSlot = FLib.HotLoad.ActiveSequence[identifier].curSlot + 1
			local curslot = FLib.HotLoad.ActiveSequence[identifier].curSlot
			FLib.Func.DPrint( "Finished downloading, starting next resource ("..LoadTable[curslot][2]..")" )
			if LoadTable[curslot-1][4] then
				LoadTable[curslot-1][4]()
			end
			if curslot == #LoadTable then
				FLib.HotLoad.URLSource( LoadTable[curslot][1], LoadTable[curslot][2], LoadTable[curslot][3], LoadTable[curslot][4] )
			else
				FLib.HotLoad.URLSource( LoadTable[curslot][1], LoadTable[curslot][2], LoadTable[curslot][3], NextLoad )
			end
		end
		FLib.Func.DPrint( "Starting download with URL ("..LoadTable[1][2]..")" )
		FLib.HotLoad.URLSource( LoadTable[1][1], LoadTable[1][2], LoadTable[1][3], NextLoad )
	end


	local url = [[https://image.pngaaa.com/324/121324-middle.png]]
	FLib.HotLoad.URLSource( "loadingIcon", url, "png" ) -- this would be best accessed through FLib.Resources["loadingIcon"]


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

	scaleX = scaleDraw.ScaleX
	scaleY = scaleDraw.ScaleY

end
