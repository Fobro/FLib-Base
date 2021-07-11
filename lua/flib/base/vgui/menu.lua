------------------------------------------
--[[


	Fobro's Library
	File: FLib Menu VGUI


--]]
------------------------------------------




--[[
	Register file
--]]
FLib.Func.RegisterFile()


------------------------------------------
--[[
	Netowrking
--]]

if SERVER then
	util.AddNetworkString( "FLib.Menu.ServerLua" )
	util.AddNetworkString( "FLib.Menu.Dev.QuickTools.RCON" )
	util.AddNetworkString( "FLib.Menu.Dev.QuickTools.RestartServ" )
	util.AddNetworkString( "FLib.Menu.Dev.QuickTools.ReloadMap" )

	local function TableToVar( tbl ) -- put this directly into a function where

	end

	net.Receive( "FLib.Menu.Dev.QuickTools.RCON", function( len, ply )
		if ply:IsAdmin() then
			local strng = net.ReadString()
			local stringTable = string.Split( strng, " " )
			local cmd, args = stringTable[1], stringTable
			if #args > 0 then
				RunConsoleCommand( cmd, unpack(args, 2) )
			else
				RunConsoleCommand( cmd )
			end
		end
	end )

	net.Receive( "FLib.Menu.ServerLua", function( len, ply )
		if ply:IsAdmin() then
			RunString( net.ReadString() )
		end
	end )

	net.Receive( "FLib.Menu.Dev.QuickTools.RestartServ", function( len, ply )
		if ply:IsAdmin() then
			RunConsoleCommand( "_RESTART" )
		end
	end )

	net.Receive( "FLib.Menu.Dev.QuickTools.ReloadMap", function( len, ply ) 
		if ply:IsAdmin() then
			RunConsoleCommand( "map", game.GetMap() )
		end
	end)
end

------------------------------------------
--[[
	Base VGUI (most of the hard work)
--]]


local surface = surface -- prevent noise from other surface drawing

if CLIENT then
	-- quick lua refresh protection for dev
	if FLib.Menu then
		FLib.Func.DPrint( "Handling file refresh" )
		if FLib.Menu.ActivePanels["Main"] then
			FLib.Func.DPrint( "Located main panel: Removing..." )
			FLib.Menu.ActivePanels["Main"]:Remove()
			FLib.Menu.ActivePanels["Main"] = nil
		end
	end
	scaleDraw.CreateFont( "FLib.Menu.Title", { size = 100, font = "Brush Script MT" } )
	scaleDraw.CreateFont( "FLib.Menu.CloseButton", { size = 25, font = "Georgia" } )
	scaleDraw.CreateFont( "FLib.Menu.PageSelection.Button", { size = 25, weight = 1000, font = "Calibri" } )
	scaleDraw.CreateFont( "FLib.Menu.PageDisplay.Title", { size = 75, font = "Courier New" } )
	scaleDraw.CreateFont( "FLib.Menu.PageDisplay.Body", { size = 18, font = "Tahoma" } )
	scaleDraw.CreateFont( "FLib.Menu.Dev.LuaEnvironment.Code", { size = 18, font = "Tahoma", weight = 750 } )
	scaleDraw.CreateFont( "FLib.Menu.Dev.LuaEnvironment.SubMenuTitle", { size = 40, font = "Courier New", weight = 750 } )
	scaleDraw.CreateFont( "FLib.Menu.Dev.LuaEnvironment.SubSubMenuTitle", { size = 30, font = "Courier New", weight = 750 } )
	scaleDraw.CreateFont( "FLib.Menu.Dev.LuaEnvironment.Buttons", { size = 21, weight = 1000, font = "Calibri" } )


	FLib.Menu = {}
	FLib.Menu.Panels = {}
	FLib.Menu.ActivePanels = {}


	FLib.Menu.Panels["Main"] = {}
	function FLib.Menu.Panels.Main:Init()
		self:SetSize( scaleDraw.ScaleX( 1000 ), scaleDraw.ScaleY( 800 ) )
		self:Center()
		self:MakePopup()
		self:SetTitle( "" )
		self:ShowCloseButton( false )
		FLib.Menu.ActivePanels["CloseMainButton"] = vgui.Create( "FLib.Main.CloseButton", self )
		FLib.Menu.ActivePanels["PageSelection"] = vgui.Create( "FLib.PageSelection", self )
		FLib.Menu.ActivePanels["PageDisplay"] = vgui.Create( "FLib.PageDisplay", self )
	end

	function FLib.Menu.Panels.Main:Paint()
		draw.NoTexture()
		scaleDraw.RoundedBox( 10, 0, 0, 1000, 800, Color( 3, 252, 223, 80 ) )
		scaleDraw.RoundedBox( 5, 7, 7, 986, 786, Color( 41, 43, 43, 255 ) )
		draw.DrawText( "| FLib Menu |", "FLib.Menu.Title", scaleDraw.ScaleX(500), scaleDraw.ScaleY(30), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		surface.SetDrawColor( 0, 0, 0, 255 )
		scaleDraw.DrawRect( 30, 150, 940, 10 )
		scaleDraw.DrawRect( 205, 170, 7, 600 )

	end

	vgui.Register( "FLib.Main", FLib.Menu.Panels["Main"], "DFrame" )
	
	function FLib.Menu.ToggleMenu(  )
		if FLib.Menu.ActivePanels["Main"] then
			FLib.Menu.ActivePanels["Main"]:Remove()
			FLib.Menu.ActivePanels = {}
		else
			FLib.Menu.ActivePanels["Main"] = vgui.Create( "FLib.Main" )
		end
	end
	FLib.Func.AddCommand( "menu", FLib.Menu.ToggleMenu, {}, "Opens menu" )

	FLib.Menu.Panels["CloseMainButton"] = {}
	function FLib.Menu.Panels.CloseMainButton:Init()
		self:SetPos( scaleDraw.ScaleX( 780 ), scaleDraw.ScaleY( 60 ) )
		self:SetSize( scaleDraw.ScaleX( 120 ), scaleDraw.ScaleY( 40 ) )
	end

	function FLib.Menu.Panels.CloseMainButton:Paint()
		scaleDraw.RoundedBox( 10, 0, 0, 120, 40, Color( 255, 255, 255, 255 ) )
		self:SetText("")
		draw.DrawText( "[CLOSE]", "FLib.Menu.CloseButton", scaleDraw.ScaleX( 60 ), scaleDraw.ScaleY( 8 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	end

	function FLib.Menu.Panels.CloseMainButton:DoClick()
		FLib.Menu.ToggleMenu(  )
	end


	vgui.Register( "FLib.Main.CloseButton", FLib.Menu.Panels["CloseMainButton"], "DButton" )

	FLib.Menu.Panels["PageDisplay"] = {}
	function FLib.Menu.Panels.PageDisplay:Init()
		self:SetPos( scaleDraw.ScaleX( 215 ), scaleDraw.ScaleY( 170 ) )
		self:SetSize( scaleDraw.ScaleX( 760 ), scaleDraw.ScaleY( 600 ) )
		local ScrollBar = self:GetVBar()
		ScrollBar:SetHideButtons( true )
		function ScrollBar:Paint( w, h )
			draw.RoundedBox( 15, 0, 0, w, h, Color( 0, 0, 0, 75 ) )
		end
		function ScrollBar.btnGrip:Paint( w, h )
			draw.RoundedBox( 15, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
		end
		function ScrollBar.btnUp:Paint( w, h )

		end
		function ScrollBar.btnDown:Paint( w, h )

		end
	end

	function FLib.Menu.Panels.PageDisplay:Paint()
	end

	vgui.Register( "FLib.PageDisplay", FLib.Menu.Panels.PageDisplay, "DScrollPanel" )

	FLib.Menu.Panels["PageSelection"] = {}
	FLib.Menu.Pages = {}
	function FLib.Menu.Panels.PageSelection:Init()
		self:SetPos( scaleDraw.ScaleX( 30 ), scaleDraw.ScaleY( 170 ) )
		self:SetSize( scaleDraw.ScaleX( 165 ), scaleDraw.ScaleY( 600 ) )
		FLib.Menu.ActivePanels["PageSelectButtons"] = {}
		local y_stor = 0
		for order, pageInfo in pairs(FLib.Menu.Pages) do
			FLib.Menu.ActivePanels["PageSelectButtons"][order] = vgui.Create( "FLib.PageSelection.Button", self )
			FLib.Menu.ActivePanels["PageSelectButtons"][order]:SetPos( 0, (order-1)*scaleDraw.ScaleY( 60 ) )

			-- Paint function for buttons
			FLib.Menu.ActivePanels.PageSelectButtons[order]["Paint"] = function()

				scaleDraw.RoundedBox( 10, 0, 0, 165, 55, Color( 61, 102, 227, 10 ) )
				if FLib.Menu.ActivePanels.PageSelectButtons[order]:IsHovered() and order ~= FLib.Menu.ActivePanels.PageSelection.SelectedButton then
					local abort = false
					if FLib.Menu.ActivePanels.PageSelectButtons[order].lastiterated then
						if CurTime() - FLib.Menu.ActivePanels.PageSelectButtons[order].lastiterated < 0 then
							abort = true
						end
					else
						FLib.Menu.ActivePanels.PageSelectButtons[order].iterated = 1
						FLib.Menu.ActivePanels.PageSelectButtons[order].lastiterated = CurTime()
					end
					if abort then return end
					if FLib.Menu.ActivePanels.PageSelectButtons[order].iterated >= 165 then
						scaleDraw.RoundedBox( 10, 0, 0, 165, 55, Color( 61, 102, 227, 30 ) )
					else
						local iteration = FLib.Menu.ActivePanels.PageSelectButtons[order].iterated
						FLib.Menu.ActivePanels.PageSelectButtons[order].iterated = iteration + 4
						scaleDraw.RoundedBox( 10, 82.5-((iteration+1)/2), 0, iteration+1, 55, Color( 61, 102, 227, 30 ) )
					end
				else
					FLib.Menu.ActivePanels.PageSelectButtons[order].iterated = 0
				end
				draw.DrawText( pageInfo.dispName, "FLib.Menu.PageSelection.Button", scaleDraw.ScaleX(55), scaleDraw.ScaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
				surface.SetDrawColor( 255, 255, 255, 255 )
				scaleDraw.DrawTexturedRect( 6, 8, 40, 40, pageInfo.imageIdentifier )

				-- Click function
				FLib.Menu.ActivePanels.PageSelectButtons[order]["DoClick"] = function()
					FLib.Menu.SelectPage( pageInfo.identifier, order )
				end
			end
		end
	end

	function FLib.Menu.Panels.PageSelection:Paint()
		if FLib.Menu.ActivePanels.PageSelection.SelectedButton then
			local button_slot = FLib.Menu.ActivePanels.PageSelection.SelectedButton
			scaleDraw.RoundedBox( 10, 0, (button_slot-1)*60, 165, 55, Color( 237, 0, 0, 255 ) )
		end
	end

	FLib.Menu.Panels.PageSelection["SelectedPage"] = nil

	vgui.Register( "FLib.PageSelection", FLib.Menu.Panels.PageSelection, "Panel" )

	FLib.Menu.Panels["PageSelectionButton"] = {}
	function FLib.Menu.Panels.PageSelectionButton:Init()
		self:SetSize( scaleDraw.ScaleX( 165 ), scaleDraw.ScaleY( 55 ) )
		self:SetText("")
		self:SetPos( 0, 0 )
	end

	vgui.Register( "FLib.PageSelection.Button", FLib.Menu.Panels.PageSelectionButton, "DButton" )

	function FLib.Menu.AddPage( identifier, dispName, iconMaterial, panel ) -- the panel will be automatically have the size and position set (with the size being 745*600), DONT USE INIT, USE OnSelect() WHICH IS CUSTOM
		table.insert( FLib.Menu.Pages, { ["identifier"] = identifier, ["dispName"] = dispName, ["imageIdentifier"] = iconMaterial, ["panel"] = panel } )
	end


	function FLib.Menu.SelectPage( identifier, order )
		local pageSelected = false
		for order, pageInfo in pairs( FLib.Menu.Pages ) do -- I know, I know. A cursed for loop rather than an indexed table and "blah blah o^n blah blah", but this is tiny table and code that is run in single iterations, so doesn't matter
			if pageInfo.identifier == identifier then
				if FLib.Menu.ActivePanels.PageSelection.SelectedButton == order then break end
				FLib.Menu.ActivePanels.PageSelection.SelectedButton = order
				FLib.Menu.ActivePanels["PageDisplay"]:Remove()
				FLib.Menu.ActivePanels["PageDisplay"] = vgui.Create( "FLib.PageDisplay", FLib.Menu.ActivePanels["Main"] ) -- reset page display
				if pageInfo.panel.OnSelect then
					FLib.Menu.ActivePanels.PageDisplay["OnSelect"] = pageInfo.panel.OnSelect
					FLib.Menu.ActivePanels.PageDisplay:OnSelect() -- runs in reference to itself (preserves "self")
				end
				local foundPaint = false
				for pnlKey, func in pairs( pageInfo.panel ) do
					if pnlKey ~= "Base" then
						if pnlKey == "Paint" then
							FLib.Menu.ActivePanels.PageDisplay[pnlKey] = function()
								func() -- the function stored by the custom panel
								local mobileText = -- this is only for title text so it moves with scroll panel
								draw.DrawText(pageInfo.dispName, "FLib.Menu.PageDisplay.Title", scaleDraw.ScaleX(372.5), scaleDraw.ScaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
							end
							foundPaint = true
						else
							FLib.Menu.ActivePanels.PageDisplay[pnlKey] = func
						end
						if not foundPaint then 
							FLib.Menu.ActivePanels.PageDisplay["Paint"] = function()
								draw.DrawText(pageInfo.dispName, "FLib.Menu.PageDisplay.Title", scaleDraw.ScaleX(372.5), scaleDraw.ScaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
							end 
						end
					end
				end
				break
			end
		end
	end

	--[[
		EXAMPLES AND DEFAULT FEATURES
	--]]


	-- quick function
	local function Illuminated( color, range, panel )
		if panel:IsHovered() then
			if panel.illuminated then
				if panel.illuminated >= range then -- if exceeding alpha increase range
					color.a = color.a + range
				else
					panel.illuminated = panel.illuminated + 0.6
					color.a = color.a + panel.illuminated
				end
			else
				panel.illuminated = 1
				color.a = color.a + panel.illuminated
			end
		else
			panel.illuminated = nil
		end
		return color
	end

	-- Main page
	local mainPanel = {}

	function mainPanel:OnSelect()
	end

	function mainPanel:Paint()
		local message = [[FLib is a user friendly means of configuring and compatibalizing addons which are produced or supported
by projects developed by Fobro. This primarily a management tool, and will mostly provide utility to
those who are managing server rather than merely playing it]]

		draw.DrawText(message, "FLib.Menu.PageDisplay.Body", scaleDraw.ScaleX(10), scaleDraw.ScaleY(100), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
	end


	-- Development page
	local developPanel = {}
	function developPanel:OnSelect()

		FLib.Menu.ActivePanels["DevPanels"] = {}
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"] = {}
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["Main"] = FLib.Menu.ActivePanels["PageDisplay"]:Add( "FLib.Menu.Dev.LuaEnvironment" )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"] = {}
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["Main"] = FLib.Menu.ActivePanels["PageDisplay"]:Add( "FLib.Menu.Dev.QuickTools" )

	end

	

	local luaEnvironment = {}
	function luaEnvironment:Init()
		self:SetSize( scaleDraw.ScaleX( 700 ), scaleDraw.ScaleY( 300 ) )
		self:SetPos( scaleDraw.ScaleX( 24 ), scaleDraw.ScaleY( 100 ) )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["TextEntry"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.EntryText", self )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["ServerButton"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.ServerButton", self )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["ClientButton"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.ClientButton", self )
	end
	function luaEnvironment:Paint()
		local x, y = self:GetSize()
		scaleDraw.RoundedBox( 10, 0, 0, 700, 300, Color( 44, 156, 47, 20 ) )
		scaleDraw.RoundedBox( 20, 20, 200, 660, 10, Color( 0, 0, 0, 255 ) )
		draw.DrawText("Lua Environment", "FLib.Menu.Dev.LuaEnvironment.SubMenuTitle", scaleDraw.ScaleX(350), scaleDraw.ScaleY(10), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end

	FLib.Menu.LuaTEXT = nil
	local luaEntry = {}
	function luaEntry:Init()
		self:SetPos( scaleDraw.ScaleX( 20 ), scaleDraw.ScaleY( 50 ) )
		self:SetSize( scaleDraw.ScaleX( 660 ), scaleDraw.ScaleY( 140 ) )
		self:SetMultiline( true )
		self:SetUpdateOnType( true )
		self:SetTabbingDisabled( true )
		if FLib.Menu.LuaTEXT then
			self:SetText( FLib.Menu.LuaTEXT )
		end
		self:SetPlaceholderText( [[print("hello world")]] )
		self:SetFont( "FLib.Menu.Dev.LuaEnvironment.Code" )
	end

	function luaEntry:OnValueChange( strng )
		FLib.Menu.LuaTEXT = strng
	end

	local bannedCharacters = { ["`"] = true }
	function luaEntry:AllowInput( charString )
		local cancel = false
		if bannedCharacters[charString] then
			cancel = true
		end
		return cancel
	end

	function luaEntry:Paint()
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawRect( 0, 0, self:GetSize() )
		self:DrawTextEntryText( Color( 0, 0, 0, 255 ), Color( 255, 47, 0, 255 ), Color( 0, 0, 0, 255 ) )
	end



	local luaRunServer = { }
	local luaRunClient = { }

	function luaRunServer:Init()
		self:SetPos( scaleDraw.ScaleX( 100 ), scaleDraw.ScaleY( 230 ) )
		self:SetSize( scaleDraw.ScaleX(175 ), scaleDraw.ScaleY( 50 ) )
		self:SetText( "" )
	end

	function luaRunServer:Paint()
		--scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Color( 247, 22, 22, 100 ) )
		scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Illuminated( Color( 247, 22, 22, 100 ), 50, self ) )
		draw.DrawText("EXECUTE SERVER CODE", "FLib.Menu.Dev.LuaEnvironment.Buttons", scaleDraw.ScaleX(87), scaleDraw.ScaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function luaRunServer:DoClick()
		if FLib.Menu.LuaTEXT then
			net.Start( "FLib.Menu.ServerLua" )
				net.WriteString( FLib.Menu.LuaTEXT )
			net.SendToServer()
		end
	end
	function luaRunClient:Init()
		self:SetPos( scaleDraw.ScaleX(425 ), scaleDraw.ScaleY( 230 ) )
		self:SetSize( scaleDraw.ScaleX(175 ), scaleDraw.ScaleY( 50 ) )
		self:SetText( "" )
	end

	function luaRunClient:Paint()
		scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Illuminated( Color( 38, 107, 255, 100 ), 50, self ) )
		draw.DrawText("EXECUTE CLIENT CODE", "FLib.Menu.Dev.LuaEnvironment.Buttons", scaleDraw.ScaleX(87), scaleDraw.ScaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function luaRunClient:DoClick()
		if FLib.Menu.LuaTEXT then
			if LocalPlayer():IsAdmin() then -- this is a shitty defense to prevent people who get here from failed prior permission checks, but if they can modify this then they've already compromised
				RunString( FLib.Menu.LuaTEXT )
			end
		end
	end

	vgui.Register( "FLib.Menu.Dev.LuaEnvironment.ServerButton", luaRunServer, "DButton" )
	vgui.Register( "FLib.Menu.Dev.LuaEnvironment.ClientButton", luaRunClient, "DButton" )
	vgui.Register( "FLib.Menu.Dev.LuaEnvironment.EntryText", luaEntry, "DTextEntry" )
	vgui.Register( "FLib.Menu.Dev.LuaEnvironment", luaEnvironment, "Panel" )

	local quickTools = {}
	function quickTools:Init()
		self:SetSize( scaleDraw.ScaleX(700 ), scaleDraw.ScaleY( 175 ) )
		self:SetPos( scaleDraw.ScaleX(24 ), scaleDraw.ScaleY( 420 ) )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"] =  {}
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Main"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RestartServ"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RestartServ", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["ReloadMap"] = vgui.Create( "FLib.Menu.Dev.QuickTools.ReloadMap", self )
	end

	function quickTools:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 10, 0, 0, x, y, Color( 110, 110, 110, 150 ) )
		scaleDraw.RoundedBox( 20, 20, 50, 660, 10, Color( 0, 0, 0, 255 ) )
		draw.DrawText( "Quick Tools", "FLib.Menu.Dev.LuaEnvironment.SubMenuTitle", x/2, scaleDraw.ScaleY(10), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	end

	local RCON = {}
	FLib.Menu.RCONString = nil
	function RCON:Init()
		self:SetPos( scaleDraw.ScaleX(20 ), scaleDraw.ScaleY(70 ) )
		self:SetSize( scaleDraw.ScaleX(385 ), scaleDraw.ScaleY( 40 ) )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Button"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON.Button", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Text"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON.Text", self )
	end

	function RCON:Paint()
		scaleDraw.RoundedBox( 8, 0, 0, 385, 40, Color( 255, 255, 255, 50 ) )
		
	end

	local RCONButton = {}
	function RCONButton:Init()
		self:SetSize( scaleDraw.ScaleX(113 ), scaleDraw.ScaleY( 30 ) )
		self:SetPos( scaleDraw.ScaleX(7 ), scaleDraw.ScaleY( 5 ) )
		self:SetText( "" )
	end

	function RCONButton:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Illuminated( Color( 0, 0, 0, 230 ), 25, self ) )
		draw.DrawText( "LAUNCH RCON", "FLib.Menu.Dev.LuaEnvironment.Buttons", x/2, scaleDraw.ScaleY( 5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function RCONButton:DoClick()
		local RCONTextString = FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Text"]:GetValue()
		if RCONTextString then
			net.Start( "FLib.Menu.Dev.QuickTools.RCON" )
				net.WriteString( RCONTextString )
			net.SendToServer()
		end
	end

	local RCONText = {}
	function RCONText:Init()
		self:SetSize( scaleDraw.ScaleX(250 ), scaleDraw.ScaleY( 24 ) )
		self:SetPos( scaleDraw.ScaleX(125 ), scaleDraw.ScaleY( 8.5 ) )
		self:SetUpdateOnType( true )
		if FLib.Menu.RCONString then
			self:SetText( FLib.Menu.RCONString )
		end
		self:SetPlaceholderText( "Command" )
	end

	function RCONText:OnEnter( strng )
		net.Start( "FLib.Menu.Dev.QuickTools.RCON" )
			net.WriteString( strng )
		net.SendToServer()
	end

	function RCONText:OnValueChange( strng )
		FLib.Menu.RCONString = strng
	end

	function RCONText:AllowInput( charString ) -- blocks console tilda bind from also going in (more time saved than functionality lost)
		local cancel = false
		if bannedCharacters[charString] then
			cancel = true
		end
		return cancel
	end

	local RestartServ = {}
	function RestartServ:Init()
		self:SetPos( scaleDraw.ScaleX(415 ), scaleDraw.ScaleY( 70 ) )
		self:SetSize( scaleDraw.ScaleX(130 ), scaleDraw.ScaleY( 40 ) )
		self:SetText( "" )
	end

	function RestartServ:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Illuminated( Color( 240, 38, 24, 170 ), 50, self )  )
		draw.DrawText( "Restart Server","FLib.Menu.Dev.LuaEnvironment.Buttons" , x/2, scaleDraw.ScaleY( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function RestartServ:DoClick()
		net.Start( "FLib.Menu.Dev.QuickTools.RestartServ" )
		net.SendToServer()
	end

	local ReloadMap = {}
	function ReloadMap:Init()
		self:SetPos( scaleDraw.ScaleX( 550 ), scaleDraw.ScaleY( 70 ) )
		self:SetSize( scaleDraw.ScaleX( 130 ), scaleDraw.ScaleY( 40 ) )
		self:SetText( "" )
	end

	function ReloadMap:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Illuminated( Color( 30, 60, 212, 170 ), 50, self ) )
		draw.DrawText( "Reload Map","FLib.Menu.Dev.LuaEnvironment.Buttons" , x/2, scaleDraw.ScaleY( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function ReloadMap:DoClick()
		net.Start( "FLib.Menu.Dev.QuickTools.ReloadMap" )
		net.SendToServer()
	end

	vgui.Register( "FLib.Menu.Dev.QuickTools.RestartServ", RestartServ, "DButton" )
	vgui.Register( "FLib.Menu.Dev.QuickTools.ReloadMap", ReloadMap, "DButton" )
	vgui.Register( "FLib.Menu.Dev.QuickTools.RCON.Text", RCONText, "DTextEntry" )
	vgui.Register( "FLib.Menu.Dev.QuickTools.RCON.Button", RCONButton, "DButton" )
	vgui.Register( "FLib.Menu.Dev.QuickTools.RCON", RCON, "Panel" )
	vgui.Register( "FLib.Menu.Dev.QuickTools", quickTools, "Panel" )


	FLib.Menu.AddPage( "main", "MAIN", Material( "flib/icons/mainmenu/48_menu.png" ), mainPanel )
	FLib.Menu.AddPage( "manage", "MANAGE", Material( "flib/icons/mainmenu/50_manage.png" ), mainPanel )
	FLib.Menu.AddPage( "analysis", "ANALYSIS", Material( "flib/icons/mainmenu/60_analyze.png" ), mainPanel )
	FLib.Menu.AddPage( "config", "CONFIG", Material( "flib/icons/mainmenu/60_settings.png" ), mainPanel )
	FLib.Menu.AddPage( "develop", "DEVELOP", Material( "flib/icons/mainmenu/50_dev.png" ), developPanel )

end


