------------------------------------------
--[[


	Fobro's Library
	File: Primary Init


--]]
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
if SERVER then
	FLib.Info.Realm = "SERVER"
	util.AddNetworkString("FLib.Debug.Transmit")
else
	FLib.Info.Realm = "CLIENT"
end

------------------------------------------
--[[
	Debugging
--]]

-- note: all debugging is off by default and needs to be switched on

FLib.Debug = {}
FLib.Debug.PrintColors = {
	["SERVER"] = Color(206, 171, 255),
	["CLIENT"] = Color(97, 152, 255),
	["ERR"] = Color(255, 64, 64),
	["NORMAL"] = Color(250, 255, 97),
}
if not GetConVar("flib_debug") then
	CreateConVar( "flib_debug", "0", FCVAR_ARCHIVE, "Enable/Disable printing debug messages (primarily for development)")
end
if not GetConVar("flib_debug_transmit") then
	CreateConVar( "flib_debug_transmit", "0", FCVAR_ARCHIVE, "Enable/Disable transmitting server debugs to admins who also have this setting enabled (primarily for development)")
end
FLib.Debug.Convars = { [1] = GetConVar("flib_debug"), [2] = GetConVar("flib_debug_transmit") }

function FLib.Func.DPrint( message, errorBool )
	if not FLib.Debug.Convar[1]:GetBool() then return end
	local msgState = "NORMAL"
	if errorBool then
		msgState = "ERR"
	end
	if SERVER then
		if FLib.Debug.Convars[2]:GetBool() then

			net.Start("FLib.Debug.Transmit")
				net.WriteString(  )
			net.Send( ply )
		end
	else

	end
end

if CLIENT then
	net.Receive( "FLib.Debug.Transmit", function()

	end )
end

------------------------------------------
--[[
	File registration
--]]

-- note: path will be defined relative to the lua flib folder (i.e. path = "modules/pointsystem/init.lua")

function FLib.Func.CheckFile( path ) -- just file.Exists with debug output and relative to FLib
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
		include( tot_path )
	end
end

function FLib.Func.AddServerFile( path ) -- only executes code without sending to client
	if FLib.Func.CheckFile( path ) then
		include( "flib/"..path )
	end
end

function FLib.Func.AddClientFile( path ) -- sends code and only executes if run on the client
	if FLib.Func.CheckFile( path ) then
		local tot_path = "flib/"..path
		AddCSLuaFile( tot_path )
		if CLIENT then
			include( tot_path )
		end
	end
end

------------------------------------------
--[[
	Execute config
--]]