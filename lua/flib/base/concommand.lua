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
	util.AddNetworkString( "FLib.Console.SendNWCommand" )
	util.AddNetworkString( "FLib.Console.RedirDedicated" )
	util.AddNetworkString( "FLib.Console.SetupRedir" )
end


------------------------------------------
--[[
	Console command system
--]]

FLib.Console = {}
FLib.Console.BindTable = { } -- for args proceeding "flib" in console, registered through the AddCommand function
local VarArg = { -- for flexible coding and less if statements
	["Player"] = { -- to add a vararg, it has to clone each of these functions
		["Search"] = function( strngbase, arg ) -- return a table of possible 
			local field = {}
			local cleanFormat, replacements = string.gsub( string.lower(arg), "'", "" )
			for k, v in pairs( player.GetAll() ) do
				if string.find( string.lower(v:Nick()), cleanFormat ) then
					table.insert( field, strngbase.." '"..v:Nick().."'" )
				end
			end
			if #field == 0 then
				field = { [1] = strngbase.." <player>" }
			end
			return field
		end,
		["List"] = function( strngbase )
			local field = {}
				for k, v in pairs( player.GetAll() ) do
					table.insert( field, strngbase.." '"..v:Nick().."'" )
				end
			return field
		end,
		["GetObjects"] = function( argNick )
			local objects = {} -- pessimism
			for k, ply in pairs( player.GetAll() ) do
				if string.find( string.lower( ply:Nick() ), string.lower( argNick ) ) then
					table.insert( objects, ply )
				end
			end
			return objects
		end,
		
	}
}

function FLib.Console.FLIBCONSOLE( calling_ply, cmd_shitty, args_shitty, tot_string )
	local tbl = FLib.Console.BindTable
	local vargs = {}
	local abort = false
	local args = string.Split( string.Trim(tot_string), " " )
	local cmd = string.lower(args[1]):gsub( '"', "" ):gsub( "'", "" )
	if tbl[cmd] then -- if the command argument is registered
		if tbl[cmd].varargs then -- if the command has variable arguments
			for order, argType in pairs( tbl[cmd].varargs ) do -- for each variable argument
				if args[1+order] then -- if there is an argument for the respective argument being typed
					local cleaned_arg, replacements = string.gsub( args[1+order], "'", "" ) 
					local cleaned_arg, replacements = string.gsub( cleaned_arg, '"', "" ) 
					local search_results = VarArg[argType].GetObjects( cleaned_arg )
					if search_results[1] then -- get a table of the particular matched objects
						vargs[order] = search_results
					else
						abort = "Invalid "..argType.." ('"..cleaned_arg.."')"
					end
				else
					abort = "Missing a(n) '"..argType.."' value: See usage below"
					break
				end
			end
			if abort then
				FLib.Func.Print( abort.." - usage: "..FLib.Console.GetUsage( cmd ), true )
			else
				tbl[cmd].func( calling_ply, vargs )
			end	
		else
			tbl[cmd].func( calling_ply, vargs )
		end
	else
		FLib.Func.Print( "Command unrecognised ('"..cmd.."')", true )
	end
end



function FLib.Console.AutoComplete( cmd, args ) -- this took way too long
	local fields = {}
	local stringBase = cmd.." "
	local selectedArg, argTable, rawargTable = nil, string.Split( string.Trim(string.lower(args)), " " ), string.Split( string.Trim(args), " " )

	for order, argument in pairs( argTable ) do -- sort through types arguments after "flib "
		if not selectedArg and FLib.Console.BindTable[argument] then -- if there isn't a selected argument and the current typed one is valid (add string base)
			stringBase = stringBase..argument -- changes base string to include argument
			selectedArg = FLib.Console.BindTable[argument]
			if selectedArg.varargs and #argTable <= 1 then
				if #selectedArg.varargs > 0 then
					fields = VarArg[selectedArg.varargs[1]].List( stringBase )
				else
					fields = { [1] = stringBase }
				end
			else
				fields = { [1] = stringBase }
			end
		elseif not selectedArg and not FLib.Console.BindTable[argument] then -- if there isn't a selected argument and the current typed one is invalid (conduct search)
			if (order + 1 <= #argTable) then -- if this is the last argument (next arg is not typed) then show all next possible options (display all)
				for k, vararg in pairs( FLib.Console.BindTable ) do
					table.insert( fields, stringBase..k )
				end
			else 
				for k, vararg in pairs( FLib.Console.BindTable ) do
					if string.find( k, string.lower( argument ) ) then
						table.insert( fields, stringBase..k )
					end
				end
			end
		elseif selectedArg.varargs and #selectedArg.varargs > 0 then -- since the first two branches will inevitably run before this, all further code will be for adaptive varargs
			local vartype = selectedArg.varargs[order-1] -- offset the key value by one to account for the specific commandarg (i.e. moving from slay key to vararg key)
			if vartype then
				if (order - 1 == #argTable) then -- list
					fields = VarArg[vartype].List( stringBase )
				elseif (order == #argTable) then -- search
					fields = VarArg[vartype].Search( stringBase, argument ) 
				elseif (order < #argTable) then -- extend
					stringBase = stringBase.." "..rawargTable[order]
				end
			elseif order == #argTable then -- if there isn't a traceable vararg for the slot, just add to the base string (unless final arg in which set it as the sole field)
				table.insert( fields, stringBase.." "..rawargTable[order] )
			else
				stringBase = stringBase.." "..rawargTable[order]
			end
		else
			if order == #argTable then -- if there isn't a traceable vararg for the slot, just add to the base string (unless final arg in which set it as the sole field)
				table.insert( fields, stringBase.." "..rawargTable[order] )
			else
				stringBase = stringBase.." "..rawargTable[order]
			end
		end
	end

	return fields
end

function FLib.Console.GetUsage( argcmd ) -- the argument after the command which is essentially the command relative to here (returns string with usage)
	local strng = "flib "..argcmd.." "
	if FLib.Console.BindTable[argcmd].varargs then
		for order, argType in pairs( FLib.Console.BindTable[argcmd].varargs ) do
			strng = strng.."<"..string.lower(argType).."> "
		end
	end
	return strng
end


concommand.Add( "flib", FLib.Console.FLIBCONSOLE, FLib.Console.AutoComplete ) -- register the root command

function FLib.Func.AddCommand( cmd, func, varargsTBL, desc, flags ) --- varargs is a TABLE including the sequence of extra variables (i.e. [1] = "Player", [2] = "Number" would be function( calling_ply, target_ply, number ) )
	if game.IsDedicated() then -- if shared console essentially
		FLib.Console.BindTable[cmd] = { ["func"] = func, ["varargs"] = varargsTBL } -- note on the comment above: calling_ply is implicitly first no matter what, cry about it
	else
		if SERVER then
			local function redir( calling_ply, varargs )
				net.Start( "FLib.Console.RedirDedicated" )
					net.WriteTable( { ["calling_ply"] = calling_ply, ["cmd"] = cmd, ["varargs"] = varargs } )
				net.Send( calling_ply )
			end
			FLib.Console.BindTable[cmd] = { ["func"] = redir, ["varargs"] = varargsTBL }
		else
			FLib.Console.BindTable[cmd] = { ["func"] = func, ["varargs"] = varargsTBL }
			hook.Add( "FLib.PlayerLoaded", "FLib.Console.InitRedirSetup", function()
				net.Start( "FLib.Console.SetupRedir" )
					net.WriteTable( { ["cmd"] = cmd, ["varargs"] = varargs } )
				net.SendToServer(  )
			end )
		end
	end
end

if SERVER then
	net.Receive( "FLib.Console.SetupRedir", function( len, ply )
		if ply:IsAdmin() then 
			local args = net.ReadTable()
			local function redir( calling_ply, varargs )
				net.Start( "FLib.Console.RedirDedicated" )
					net.WriteTable( { ["calling_ply"] = calling_ply, ["cmd"] = args.cmd, ["varargs"] = varargs } )
				net.Send( calling_ply )
			end
			FLib.Console.BindTable[args.cmd] = { ["func"] = redir, ["varargs"] = args.varargs }
		end
	end )
end

if CLIENT then
	net.Receive( "FLib.Console.RedirDedicated", function()
		local cmdInf = net.ReadTable()
		FLib.Console.BindTable[cmdInf.cmd].func( cmdInf.calling_ply, cmdInf.varargs )
	end )
end

function FLib.Func.AddNWCommand( cmd, func, varargsTBL, desc ) -- used for when client commands trigger server functions (must be run on shared)
	if CLIENT then
		local function NotifyServerCommand( calling_ply, vargs )
			net.Start( "FLib.Console.SendNWCommand" )
				net.WriteString( cmd )
				net.WriteTable( vargs )
			net.SendToServer()
		end
		FLib.Func.AddCommand( cmd, NotifyServerCommand, varargsTBL, desc )
	else
		FLib.Func.AddCommand( cmd, func, varargsTBL, desc )
	end
	FLib.Console.BindTable[cmd].networked = true
end
	
if SERVER then -- receives and runs serverside commands
	net.Receive( "FLib.Console.SendNWCommand", function( len, ply )
		local cmd = net.ReadString()
		local vargs = net.ReadTable()
		if ply:IPAddress() ~= "loopback" then -- ignore if user is also the host (using the same console)
			FLib.Console.BindTable[cmd].func( ply, vargs )
		end
	end )
end

-- EXAMPLES

local function Slay( calling_ply, vargs )
	if calling_ply:IsAdmin() then
		local target_ply = vargs[1][1]
		if target_ply:GetObserverMode() == OBS_MODE_NONE then
			target_ply:Kill()
		end
	end
end

FLib.Func.AddNWCommand( "slay", Slay, { [1] = "Player" }, "Kills the target player" )