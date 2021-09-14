------------------------------------------
--[[


	Fobro's Library
	File: Primary Init


--]]
------------------------------------------
if FLib then
	return
end

MsgC( Color( 97, 255, 134, 255 ), [[

///////////////////////////////////
///////////////////////////////////
///////// Fobro's Library /////////
///////////////////////////////////
///////////////////////////////////
]], Color( 63, 232, 111, 255 ), "Starting FLib...\n" )

------------------------------------------
--[[
	Quick Definitions
--]]


AddCSLuaFile()
FLib = {}
FLib.Func = {}
FLib.Info = {}
FLib.Info.ActiveStaff = {}
FLib.Info.Version = "1.0"
FLib.Info.LastStart = CurTime()
if SERVER then
	FLib.Info.Realm = "Server"
	util.AddNetworkString("FLib.Debug.Transmit")
	util.AddNetworkString("FLib.Debug.InitTransmit")
	util.AddNetworkString("FLib.Config.ServConf")
else
	FLib.Info.Realm = "Client"
end
function FLib.Func.Print( message, errorBool )
	if not errorBool then
		MsgC( Color( 255, 170, 0 ), "[FLib] "..message.."\n" )
	else
		MsgC( Color( 255, 170, 0 ), "[FLib] "..message.."\n" )
	end
end
  
------------------------------------------
--[[
	Debugging
--]]

-- note: all debugging is off by default and needs to be switched on

FLib.Debug = {}
FLib.Debug.PrintColors = {
	["ERR"] = Color(255, 64, 64),
	["NORMAL"] = Color(250, 255, 97),
}
if not GetConVar("flib_debug") then
	CreateConVar( "flib_debug", "0", FCVAR_ARCHIVE, "Enable/Disable printing debug messages (primarily for development)")
end
if not GetConVar("flib_debug_transmit") then -- requires both debug options to be enabled by both realms (server/client) to work
	CreateConVar( "flib_debug_transmit", "0", FCVAR_ARCHIVE, "Enable/Disable transmitting server debugs to admins who also have this setting enabled (primarily for development)")
end
FLib.Debug.Convars = { [1] = GetConVar("flib_debug"), [2] = GetConVar("flib_debug_transmit") }

function FLib.Func.DPrint( message, errorBool )
	if not FLib.Debug.Convars[1]:GetBool() then return end -- 
	local msgState = "NORMAL"
	if errorBool then
		msgState = "ERR"
	end
	if SERVER then
		if FLib.Debug.Convars[2]:GetBool() then
			for i = 1, #FLib.Info.ActiveStaff do -- numeric for speed purposes
				net.Start("FLib.Debug.Transmit") -- send server outputs to admins
					net.WriteString( msgState )
					net.WriteString( message )
				net.Send( FLib.Info.ActiveStaff[i] )
			end
		end
		MsgC( Color(255, 182, 87), "[FLib] ", Color(206, 171, 255), "[SERVER DEBUG]", Color(255, 182, 87), " ["..debug.getinfo(2)["short_src"]..":"..debug.getinfo(2)["currentline"].."] ", FLib.Debug.PrintColors[msgState], message.."\n" )
	else
		MsgC( Color(255, 182, 87), "[FLib] ", Color(97, 152, 255), "[CLIENT DEBUG]", Color(255, 182, 87), " ["..debug.getinfo(2)["short_src"]..":"..debug.getinfo(2)["currentline"].."] ", FLib.Debug.PrintColors[msgState], message.."\n" )
	end
end

FLib.LoadedFiles = {}
function FLib.Func.RegisterFile() -- prints when file loads and identifies the file in debug (also shows stored the order of the launch)
	local path = debug.getinfo(2)["short_src"]
	FLib.Func.DPrint( "File was registered and loaded successfully! ("..path..")" )
	table.insert( FLib.LoadedFiles, path )
end
FLib.Func.RegisterFile() -- register this file

if CLIENT then
	net.Receive( "FLib.Debug.InitTransmit", function()
		FLib.Func.DPrint( "Establishing server debug transmit" )
		net.Receive( "FLib.Debug.Transmit", function(  ) -- receives server debugs for admins who are allowed from server end to view (requires both realms to have enabled both debug convars)
			local msgState, message = net.ReadString(), net.ReadString()
			if FLib.Debug.Convars[2]:GetBool() then
				MsgC( Color(255, 182, 87), "[FLib] ", Color(206, 171, 255), "[SERVER DEBUG]", Color(255, 182, 87), " ["..debug.getinfo(2)["short_src"]..":"..debug.getinfo(2)["currentline"].."] ", FLib.Debug.PrintColors[msgState], message.."\n" )
			end
		end )
	end )
end

if SERVER then
	hook.Add( "FLib.PlayerLoaded", "FLib.Debug.PlayerStatus", function( ply )
		if ply:IsAdmin() then -- register the player as admin (so they receive the messages from server end)
			FLib.Func.DPrint( [[Registering "]]..ply:Nick()..[[" as an active staff member]] )
			table.insert( FLib.Info.ActiveStaff, ply ) 
		end 
		if ply:IPAddress() ~= "loopback" then
			if ply:IsAdmin() then
				net.Start( "FLib.Debug.InitTransmit" )
				net.Send( ply )
			end
		else
			FLib.Func.DPrint( "Player ("..ply:Nick()..") IP and host IP matched, abandoning debug transmit", true )
		end
	end )
end



------------------------------------------
--[[
	File registration (lua specifically)
--]]

-- note: path will be defined relative to the lua flib folder (i.e. path = "modules/pointsystem/init.lua")

function FLib.Func.CheckFile( path ) -- this should be only used when adding FLib lua files (to maintain continuity with the rest of FLib, just use file.Exist for other stuff)
	local outcome = false -- pessimism
	if file.Exists( "flib/"..path, "LUA" ) then
		outcome = true
	else
		FLib.Func.DPrint( "File could not be located ("..path..")", true )
	end
	return outcome
end

function FLib.Func.AddSharedFile( path ) -- shares and executes code on shared
	if FLib.Func.CheckFile( path ) then
		local tot_path = "flib/"..path
		AddCSLuaFile( tot_path )
		FLib.Func.DPrint( "Script located - starting application ("..path..")" )
		include( tot_path )
	end
end

function FLib.Func.AddServerFile( path ) -- only executes code without sending to client
	if FLib.Func.CheckFile( path ) then
		FLib.Func.DPrint( "Script located - starting application ("..path..")" )
		include( "flib/"..path )
	end
end

function FLib.Func.AddClientFile( path ) -- sends code and only executes if run on the client
	if FLib.Func.CheckFile( path ) then
		local tot_path = "flib/"..path
		AddCSLuaFile( tot_path )
		FLib.Func.DPrint( "Script located - starting application ("..path..")" )
		if CLIENT then
			include( tot_path )
		end
	end
end


------------------------------------------
--[[
	Config Management and initial load
--]]

-- IMPORTANT NOTE. DO NOT STORE ANY ONLINE AUTHENTICATION USING IN GAME MENU OPTIONS. THESE SHOULD BE ENTERED IN THE
-- "PROTECTED CONFIG" FILE.
-- (so while I do not know of any vulnerabilities to this, it seems reasonable to avoid networking that sort of information)

FLib.Config = {}
FLib.Config.Client = {}
FLib.Config.Server = {}
if file.Exists( "flib/"..FLib.Info.Realm.."config.json", "DATA" ) then
	FLib.Config[FLib.Info.Realm] = util.JSONToTable( file.Read( "flib/"..FLib.Info.Realm.."config.json", "DATA" ) )
end
FLib.Config.LocatedModules = {}
FLib.Config.LocatedModules[FLib.Info.Realm] = {}

function FLib.Config.SaveConfig() -- saves config for whatever realm runs it (run on both if the change should be applied to both)
	file.Write( "flib/"..FLib.Info.Realm.."config.json", util.TableToJSON( FLib.Config[FLib.Info.Realm] ) )
	if FLib.Info.Realm == "Server" then
		for key, ply in pairs( player.GetAll() ) do
			if ply:IsAdmin() then
				net.Start( "FLib.Config.ServConf" )
					net.WriteTable( FLib.Config.Server )
				net.Send( ply )
			end
		end
	end
end

function FLib.Config.Register( modname, realm, cfgTable ) -- this should only be used by addons initiated through FLib file structure (through an autorun.lua file located in modules/)
	if (SERVER and realm ~= "server") or (CLIENT and realm ~= "client") then return end
	FLib.Config.LocatedModules[FLib.Info.Realm][modname] = true
	FLib.Config[FLib.Info.Realm][modname] = cfgTable
	for cfgID, properties in pairs( FLib.Config[FLib.Info.Realm][modname] ) do
		if not properties.storedval then
			properties.storedval = properties.default
		end
	end
end

function FLib.Config.ChangeConfig( modname, cfgID, value ) -- modifies and saves the table to disk (for FLib Menu)
	FLib.Config[FLib.Info.Realm][modname][cfgID].storedval = value
	FLib.Config.SaveConfig()
end

function FLib.Config.LoadConfig( modname ) -- returns pre-indexed config value table (only stored values)
	local LCFG = {}
	for cfgID, inf in pairs( FLib.Config[FLib.Info.Realm][modname] ) do
		if inf.type ~= "category" then
			LCFG[cfgID] = inf.storedval
		end
	end
	return LCFG
end

hook.Add( "FLib.Loaded", "FLib.ConfigSetup", function()
	for modname, v in pairs( FLib.Config[FLib.Info.Realm] ) do -- remove unregistered addons from config file
		if not FLib.Config.LocatedModules[FLib.Info.Realm][modname] then
			FLib.Config[FLib.Info.Realm][modname] = nil
		end
	end

	FLib.Config.SaveConfig()
end )

if SERVER then
	hook.Add( "FLib.PlayerLoaded", "FLib.Config.AdminInGame", function( ply )
		if ply:IsAdmin() then
			net.Start( "FLib.Config.ServConf" )
				net.WriteTable( FLib.Config.Server )
			net.Send( ply )
		end
	end )
end

if CLIENT then
	net.Receive( "FLib.Config.ServConf", function( )
		FLib.Config.Server = net.ReadTable()
	end )
end

FLib.Config.Register( "main", "client", {
	["DebugGeneral"] = { type = "bool", default = false, label = "Enable/Disable Debug Messaging" },
	["DebugTransmit"] = { type = "bool", default = false, label = "Enable/Disable Server Debug Broadcast to Admins" }
} )

FLib.Config.Register( "main", "server", {
	["Testone"] = { type = "bool", default = false, label = "Enable/Disable Debug Messaging" },
	["TestTwo"] = { type = "text", default = false, label = "Enable/Disable Server Debug Broadcast to Admins" }
} )

------------------------------------------
--[[
	Module initiation
--]]
FLib.Func.AddSharedFile( "base/autorun.lua" ) -- loads the base first

local files, directs = file.Find( "flib/modules/*", "LUA" ) -- file scan and registry for custom modules
if directs then
	for k, directory in pairs( directs ) do
		FLib.Func.DPrint( "Loading module! ("..string.upper(directory)..")" )
		if file.Exists( "flib/modules/"..directory.."/autorun.lua", "LUA" ) then
			FLib.Func.AddSharedFile( "modules/"..directory.."/autorun.lua" )
		else
			FLib.Func.DPrint( "Module failed to load! Lacks a locateable autorun.lua", true )
		end
	end
else
	FLib.Func.DPrint( "Couldn't locate any additional modules to load", true )
end


------------------------------------------
--[[
	Finish load
--]]

hook.Run( "FLib.Loaded" )
