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
	scaleDraw.CreateFont( "FLib.Menu.Config.ModulePanel.Title", { size = 25, font = "Stratum2 MD" } )
	scaleDraw.CreateFont( "FLib.Menu.Config.ModulePanel.RealmLabel", { size = 30, weight = 750, font = "Courier New" } )


	FLib.Menu = {}
	FLib.Menu.Panels = {}
	FLib.Menu.ActivePanels = {}


	FLib.Menu.Panels["Main"] = {}
	function FLib.Menu.Panels.Main:Init()
		self:SetSize( scaleX( 1000 ), scaleY( 800 ) )
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
		draw.DrawText( "| FLib Menu |", "FLib.Menu.Title", scaleX(500), scaleY(30), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
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
		self:SetPos( scaleX( 780 ), scaleY( 60 ) )
		self:SetSize( scaleX( 120 ), scaleY( 40 ) )
	end

	function FLib.Menu.Panels.CloseMainButton:Paint()
		scaleDraw.RoundedBox( 10, 0, 0, 120, 40, Color( 255, 255, 255, 255 ) )
		self:SetText("")
		draw.DrawText( "[CLOSE]", "FLib.Menu.CloseButton", scaleX( 60 ), scaleY( 8 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	end

	function FLib.Menu.Panels.CloseMainButton:DoClick()
		FLib.Menu.ToggleMenu(  )
	end


	vgui.Register( "FLib.Main.CloseButton", FLib.Menu.Panels["CloseMainButton"], "DButton" )

	FLib.Menu.Panels["PageDisplay"] = {}
	

	function FLib.Menu.Panels.PageDisplay:Init()
		self:SetPos( scaleX( 215 ), scaleY( 170 ) )
		self:SetSize( scaleX( 760 ), scaleY( 600 ) )

		local ScrollBar = self:GetVBar()
		ScrollBar:SetHideButtons( true )
		local posX, posY = ScrollBar:GetPos()
		ScrollBar:SetPos( posX, posY )
		local sx, sy = ScrollBar:GetSize()
		local x = sx-3
		local scrollExpSpeed = 0.01
		function ScrollBar:Paint( w, h )
			if self:IsHovered() or ScrollBar.btnGrip:IsHovered() then
				if self.expand then
					if self.expand + x >= sx then -- topping out expansion
						x = self.expand + sx
					else
						self.expand = self.expand + scrollExpSpeed -- continue growth (speed of iteration)
						x = x + self.expand
					end
				else -- start growth
					self.expand = 1
					x = x + self.expand
				end
			else
				if self.expand then 
					if x - self.expand < 0 then -- bottom out compression
						self.expand = nil
						x = sx/2
					else
						self.expand = self.expand + scrollExpSpeed -- continue decline
						x = x - self.expand
					end
				else
					x = sx/2
				end
			end
			draw.RoundedBox( 15, 0, 0, x, h, Color( 0, 0, 0, 75 ) )
		end

		function ScrollBar.btnGrip:Paint( w, h )
			draw.RoundedBox( 15, 0, 0, x, h, Color( 0, 0, 0, 100 ) )
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
		self:SetPos( scaleX( 30 ), scaleY( 170 ) )
		self:SetSize( scaleX( 165 ), scaleY( 600 ) )
		FLib.Menu.ActivePanels["PageSelectButtons"] = {}
		local y_stor = 0
		for order, pageInfo in pairs(FLib.Menu.Pages) do
			FLib.Menu.ActivePanels["PageSelectButtons"][order] = vgui.Create( "FLib.PageSelection.Button", self )
			FLib.Menu.ActivePanels["PageSelectButtons"][order]:SetPos( 0, (order-1)*scaleY( 60 ) )

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
				draw.DrawText( pageInfo.dispName, "FLib.Menu.PageSelection.Button", scaleX(55), scaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
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
		self:SetSize( scaleX( 165 ), scaleY( 55 ) )
		self:SetText("")
		self:SetPos( 0, 0 )
	end

	vgui.Register( "FLib.PageSelection.Button", FLib.Menu.Panels.PageSelectionButton, "DButton" )

	function FLib.Menu.AddPage( identifier, dispName, iconMaterial, panel ) -- the panel will be automatically have the size and position set (with the size being 745*600), DONT USE INIT, USE OnSelect() WHICH IS CUSTOM
		table.insert( FLib.Menu.Pages, { ["identifier"] = identifier, ["dispName"] = dispName, ["imageIdentifier"] = iconMaterial, ["panel"] = panel } )
	end

	

	FLib.Menu.ActiveLabels = {}
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
								func()
							end
							local mobileText = FLib.Menu.ActivePanels["PageDisplay"]:Add( "FLib.Menu.QuickText" ) -- label panel that moves on scroll
							function mobileText:Paint()
								draw.DrawText(pageInfo.dispName, "FLib.Menu.PageDisplay.Title", scaleX(372.5), scaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
							end
							foundPaint = true
						else
							FLib.Menu.ActivePanels.PageDisplay[pnlKey] = func
						end
						if not foundPaint then 
							local mobileText = FLib.Menu.ActivePanels["PageDisplay"]:Add( "FLib.Menu.QuickText" ) -- label panel that moves on scroll
							function mobileText:Paint()
								draw.DrawText(pageInfo.dispName, "FLib.Menu.PageDisplay.Title", scaleX(372.5), scaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
							end
						end
					end
				end
				break
			end
		end
	end

	local quickText = {}

	function quickText:Init()
		self:SetPos( 0, 0 )
		self:SetSize( scaleX( 1000 ), scaleY( 78 ) )
	end

	


	vgui.Register( "FLib.Menu.QuickText", quickText, "Panel" )

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

	local message = 

[[FLib is a user friendly means of configuring and compatibalizing addons which are produced or supported
by projects developed by Fobro. This primarily a management tool, and will mostly provide utility to
those who are managing server rather than merely playing it]]

	function mainPanel:OnSelect()
		local textPanel = self:Add( "Panel" )
		textPanel:SetSize( scaleDraw.Scale( 800 ), scaleDraw.Scale( 500 ) )
		textPanel:SetPos( 0, 0 )
		function textPanel:Paint()
			draw.DrawText(message, "FLib.Menu.PageDisplay.Body", scaleX(10), scaleY(100), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		end
		
	end

	function mainPanel:Paint()
		
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
		self:SetSize( scaleX( 700 ), scaleY( 300 ) )
		self:SetPos( scaleX( 24 ), scaleY( 100 ) )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["TextEntry"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.EntryText", self )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["ServerButton"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.ServerButton", self )
		FLib.Menu.ActivePanels["DevPanels"]["LuaEnvironment"]["ClientButton"] = vgui.Create( "FLib.Menu.Dev.LuaEnvironment.ClientButton", self )
	end
	function luaEnvironment:Paint()
		local x, y = self:GetSize()
		scaleDraw.RoundedBox( 10, 0, 0, 700, 300, Color( 44, 156, 47, 20 ) )
		scaleDraw.RoundedBox( 20, 20, 200, 660, 10, Color( 0, 0, 0, 255 ) )
		draw.DrawText("Lua Environment", "FLib.Menu.Dev.LuaEnvironment.SubMenuTitle", scaleX(350), scaleY(10), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end

	FLib.Menu.LuaTEXT = nil
	local luaEntry = {}
	function luaEntry:Init()
		self:SetPos( scaleX( 20 ), scaleY( 50 ) )
		self:SetSize( scaleX( 660 ), scaleY( 140 ) )
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
		self:SetPos( scaleX( 100 ), scaleY( 230 ) )
		self:SetSize( scaleX(175 ), scaleY( 50 ) )
		self:SetText( "" )
	end

	function luaRunServer:Paint()
		--scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Color( 247, 22, 22, 100 ) )
		scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Illuminated( Color( 247, 22, 22, 100 ), 50, self ) )
		draw.DrawText("EXECUTE SERVER CODE", "FLib.Menu.Dev.LuaEnvironment.Buttons", scaleX(87), scaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function luaRunServer:DoClick()
		if FLib.Menu.LuaTEXT then
			net.Start( "FLib.Menu.ServerLua" )
				net.WriteString( FLib.Menu.LuaTEXT )
			net.SendToServer()
		end
	end
	function luaRunClient:Init()
		self:SetPos( scaleX(425 ), scaleY( 230 ) )
		self:SetSize( scaleX(175 ), scaleY( 50 ) )
		self:SetText( "" )
	end

	function luaRunClient:Paint()
		scaleDraw.RoundedBox( 8, 0, 0, 175, 50, Illuminated( Color( 38, 107, 255, 100 ), 50, self ) )
		draw.DrawText("EXECUTE CLIENT CODE", "FLib.Menu.Dev.LuaEnvironment.Buttons", scaleX(87), scaleY(15), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
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
		self:SetSize( scaleX(700 ), scaleY( 175 ) )
		self:SetPos( scaleX(24 ), scaleY( 420 ) )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"] =  {}
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Main"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RestartServ"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RestartServ", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["ReloadMap"] = vgui.Create( "FLib.Menu.Dev.QuickTools.ReloadMap", self )
	end

	function quickTools:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 10, 0, 0, x, y, Color( 110, 110, 110, 150 ) )
		scaleDraw.RoundedBox( 20, 20, 50, 660, 10, Color( 0, 0, 0, 255 ) )
		draw.DrawText( "Quick Tools", "FLib.Menu.Dev.LuaEnvironment.SubMenuTitle", x/2, scaleY(10), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	end

	local RCON = {}
	FLib.Menu.RCONString = nil
	function RCON:Init()
		self:SetPos( scaleX(20 ), scaleY(70 ) )
		self:SetSize( scaleX(385 ), scaleY( 40 ) )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Button"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON.Button", self )
		FLib.Menu.ActivePanels["DevPanels"]["QuickTools"]["RCON"]["Text"] = vgui.Create( "FLib.Menu.Dev.QuickTools.RCON.Text", self )
	end

	function RCON:Paint()
		scaleDraw.RoundedBox( 8, 0, 0, 385, 40, Color( 255, 255, 255, 50 ) )
		
	end

	local RCONButton = {}
	function RCONButton:Init()
		self:SetSize( scaleX(113 ), scaleY( 30 ) )
		self:SetPos( scaleX(7 ), scaleY( 5 ) )
		self:SetText( "" )
	end

	function RCONButton:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 6, 0, 0, x, y, Illuminated( Color( 0, 0, 0, 230 ), 25, self ) )
		draw.DrawText( "LAUNCH RCON", "FLib.Menu.Dev.LuaEnvironment.Buttons", x/2, scaleY( 5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
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
		self:SetSize( scaleX(250 ), scaleY( 24 ) )
		self:SetPos( scaleX(125 ), scaleY( 8.5 ) )
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
		self:SetPos( scaleX(415 ), scaleY( 70 ) )
		self:SetSize( scaleX(130 ), scaleY( 40 ) )
		self:SetText( "" )
	end

	function RestartServ:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Illuminated( Color( 240, 38, 24, 170 ), 50, self )  )
		draw.DrawText( "Restart Server","FLib.Menu.Dev.LuaEnvironment.Buttons" , x/2, scaleY( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	function RestartServ:DoClick()
		net.Start( "FLib.Menu.Dev.QuickTools.RestartServ" )
		net.SendToServer()
	end

	local ReloadMap = {}
	function ReloadMap:Init()
		self:SetPos( scaleX( 550 ), scaleY( 70 ) )
		self:SetSize( scaleX( 130 ), scaleY( 40 ) )
		self:SetText( "" )
	end

	function ReloadMap:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Illuminated( Color( 30, 60, 212, 170 ), 50, self ) )
		draw.DrawText( "Reload Map","FLib.Menu.Dev.LuaEnvironment.Buttons" , x/2, scaleY( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
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

	local configPanel = {}
	local pnlBSlot = {}
	local expansion = 0
	function configPanel:OnSelect()
		FLib.Menu.ActivePanels["Config"] = {}
		local slot = 0 -- iterator
		for mod, cfgTable in pairs( FLib.Config.Client ) do
			slot = slot + 1
			local modTitle = string.upper( mod ) 
			FLib.Menu.ActivePanels["Config"][modTitle] = self:Add( "FLib.Menu.Config.ModulePanel" )
			FLib.Menu.ActivePanels["Config"][modTitle].slot = slot
			pnlBSlot[slot] = FLib.Menu.ActivePanels["Config"][modTitle]
			FLib.Menu.ActivePanels["Config"][modTitle].title = modTitle
			FLib.Menu.ActivePanels["Config"][modTitle].clientCFG = cfgTable
			FLib.Menu.ActivePanels["Config"][modTitle]:SetPos( scaleX( 24 ), scaleY( 50 )+(slot*scaleY(50)) )
			FLib.Menu.ActivePanels["Config"][modTitle].ExpandButton:SetSize( FLib.Menu.ActivePanels["Config"][modTitle]:GetSize() )
			FLib.Menu.ActivePanels["Config"][modTitle]:Show()


		end

		if LocalPlayer():IsAdmin() then
			for mod, cfgTable in pairs( FLib.Config.Server ) do
				local modTitle = string.upper( mod ) 
				if FLib.Config.Client[mod] then
					FLib.Menu.ActivePanels["Config"][modTitle].serverCFG = cfgTable
				else
					slot = slot + 1
					local modTitle = string.upper( mod ) 
					FLib.Menu.ActivePanels["Config"][modTitle] = self:Add( "FLib.Menu.Config.ModulePanel" )
					FLib.Menu.ActivePanels["Config"][modTitle].slot = slot
					FLib.Menu.ActivePanels["Config"][modTitle].slot = slot
					pnlBSlot[slot] = FLib.Menu.ActivePanels["Config"][modTitle]
					FLib.Menu.ActivePanels["Config"][modTitle].title = modTitle
					FLib.Menu.ActivePanels["Config"][modTitle].serverCFG = cfgTable
					FLib.Menu.ActivePanels["Config"][modTitle]:SetPos( scaleX( 24 ), scaleY( 50 )+(slot*scaleY(50)) )
					FLib.Menu.ActivePanels["Config"][modTitle].ExpandButton:SetSize( FLib.Menu.ActivePanels["Config"][modTitle]:GetSize() )
					FLib.Menu.ActivePanels["Config"][modTitle]:Show()
				end
			end
		end
	end
	function configPanel:Paint()
		-- do nothing (passive background)
	end

	local modulePanel = {}
	function modulePanel:Init()
		self:Hide()
		self.ExpandButton = vgui.Create( "FLib.Menu.Config.ModulePanelExpand", self )
		self:SetSize( scaleX( 700 ), scaleY( 43 ) )
	end
	function modulePanel:Paint()
		local x, y = self:GetSize()
		draw.RoundedBox( 8, 0, 0, x, y, Color( 255, 255, 255, 255 ) )
		draw.DrawText( string.sub(self.title, 1, 1)..string.lower(string.sub(self.title, 2)), "FLib.Menu.Config.ModulePanel.Title", x/2, scaleY( 8 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	end
	function modulePanel:Expand(  )

	end

	local expandButton = {}
	function expandButton:Init()
		self:SetPos( 0, 0 )
		self:SetText( "" )
	end

	function expandButton:Paint()

	end

	local function FirstCaps( strng )
		return string.upper( string.sub(strng, 1 ) )..string.sub( string.lower(strng), 2 )
	end

	local ServerLabel = {}
	function ServerLabel:Init()
		self:SetSize( scaleX( 670 ), scaleY( 50 ) )
	end

	

	function ServerLabel:LoadContents()
		local surface = surface
		local pnl = self

		surface.SetFont( "FLib.Menu.Config.ModulePanel.RealmLabel" )
		local line_start = surface.GetTextSize( "CLIENT" ) + scaleX( 15 ) -- 5 + 10 because the text starts 5 pixels out
		function pnl:Paint( w, h )
			draw.DrawText( "SERVER", "FLib.Menu.Config.ModulePanel.RealmLabel", scaleX( 5 ), scaleY( 10 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT )
			draw.RoundedBox( 10, line_start, scaleY( 20 ), (scaleX(662)-line_start), scaleY( 11 ), Color( 0, 0, 0, 255 ) )
		end
	end

	local ClientLabel = {}
	function ClientLabel:Init()
		self:SetSize( scaleX( 670 ), scaleY( 50 ) )
	end

	

	function ClientLabel:LoadContents()
		local surface = surface
		local pnl = self

		surface.SetFont( "FLib.Menu.Config.ModulePanel.RealmLabel" )
		local line_start = surface.GetTextSize( "CLIENT" ) + scaleX( 15 ) -- 5 + 10 because the text starts 5 pixels out
		function pnl:Paint( w, h )
			draw.DrawText( "CLIENT", "FLib.Menu.Config.ModulePanel.RealmLabel", scaleX( 5 ), scaleY( 10 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT )
			draw.RoundedBox( 10, line_start, scaleY( 20 ), (scaleX(662)-line_start), scaleY( 11 ), Color( 0, 0, 0, 255 ) )
		end
	end

	local locked = false

	function expandButton:DoClick()
		local CurmodulePanel = self:GetParent()
		local modname = CurmodulePanel.title
		if locked then -- don't let multiple animations happen at once, that might cause problems
			return
		elseif CurmodulePanel.expanded then
			locked = true
			local curslot = CurmodulePanel.slot
			local _, h = CurmodulePanel:GetSize()
			CurmodulePanel:SizeTo( scaleX( 700 ), scaleY( 43 ), 0.2, 0, -1, function()
				locked = false
				CurmodulePanel.expanded = false
			end )
			local diff = h - scaleY( 43 )
				for modname, panel in pairs( FLib.Menu.ActivePanels["Config"] ) do
					if panel.slot > curslot then
						local x, y = panel:GetPos()
						panel:MoveTo( x, y-diff, 0.2, 0, -1, function()
							
						end )
					end
				end
			return
		end
		if not FLib.Menu.ActivePanels.Config[modname].items then -- check if the config module has already been loaded (don't dupe minimized items)
			local expansion, locked = 0, true
			local clientCFG, serverCFG = CurmodulePanel.clientCFG, CurmodulePanel.serverCFG
			FLib.Menu.ActivePanels.Config[modname].items = {}
			if clientCFG then
				local lblpnl = vgui.Create( "FLib.Menu.Config.CategoryDivider.Client", FLib.Menu.ActivePanels.Config[modname] )
				lblpnl:LoadContents()
				table.insert( FLib.Menu.ActivePanels.Config[modname].items, lblpnl )
				for cfgID, properties in pairs( clientCFG ) do
					local pnl = vgui.Create( "FLib.Menu.Config.Item.ConfigItem", FLib.Menu.ActivePanels.Config[modname] )
					pnl:LoadContents( cfgID, properties )
					table.insert( FLib.Menu.ActivePanels.Config[modname].items, pnl )
				end
			end
			if serverCFG then
				local lblpnl = vgui.Create( "FLib.Menu.Config.CategoryDivider.Server", FLib.Menu.ActivePanels.Config[modname] )
				lblpnl:LoadContents()
				table.insert( FLib.Menu.ActivePanels.Config[modname].items, lblpnl )
				for cfgID, properties in pairs( serverCFG ) do
					local pnl = vgui.Create( "FLib.Menu.Config.Item.ConfigItem", FLib.Menu.ActivePanels.Config[modname] )
					pnl:LoadContents( cfgID, properties )
					table.insert( FLib.Menu.ActivePanels.Config[modname].items, pnl )
				end
			end
		end
		


		local modItems = FLib.Menu.ActivePanels.Config[modname].items

		local x, y = scaleX( 15 ), scaleY( 50 )
		local expand = 0
		for order, panel in pairs( modItems ) do
			local w, h = panel:GetSize()
			panel:SetPos( x, y+expand )
			expand = expand + h + scaleY( 5 )
			panel:Show( )
		end
		local _, bottom = modItems[#modItems]:GetPos()
		local _, height = modItems[#modItems]:GetSize()
		bottom = bottom + scaleY( height )

		-- move panels below out of the way
		local curSlot = CurmodulePanel.slot
		for modname, panel in pairs( FLib.Menu.ActivePanels["Config"] ) do
			if panel.slot > curSlot then
				local x, y = panel:GetPos()
				panel:MoveTo( x, y+bottom+scaleY( 7 ), 0.2, 0, -1 )
			end
		end

		FLib.Menu.ActivePanels.Config[modname]:SizeTo( scaleX( 700 ), bottom + scaleY( 50 ), 0.2, 0, -1, function()
			FLib.Menu.ActivePanels.Config[modname].expanded = true
			locked = false
		end )

		
	end

	local itemBase = {}
	function itemBase:Init()
		self:SetPos( scaleX( 5 ), scaleY( 5 ) )
		self:SetSize( scaleX( 125 ), scaleY( 25 ) )
	end

	function itemBase:Load( properties )
		print("this shit working?")
	end

	function itemBase:Paint( w, h ) -- template
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
	end

	local numberBox = itemBase
	local boolBox = itemBase
	local textBox = itemBase
	local categoryBox = itemBase
	function categoryBox:Load( properties )
		print("category box loaded")
	end

	function categoryBox:Paint( w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 255, 255 ) )
	end

	function boolBox:Load( properties )
		print("bool box loaded")
	end

	function boolBox:Paint( w, h ) -- template
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 255, 0, 255 ) )
	end

	function textBox:Load( properties )

	end

	function numberBox:Load( properties )

	end


	local typeDraw = {
		bool = "Bool",
		number = "Number",
		text = "Text",
		list = "Base",
		category = "Category"
	}


	local ConfigItem = {}
	function ConfigItem:Init()
		self:Hide()
		self:SetSize( scaleX( 670 ), scaleY( 35 ) )
	end

	function ConfigItem:LoadContents( cfgID, properties ) -- make the VGUI items and label text
		local pnl = self
		local input
		local itemType = typeDraw[properties.type]

		if itemType then
			input = vgui.Create( "FLib.Menu.Config.Item."..itemType, self )

			input:Load( properties )
		else
			FLib.Func.DPrint("Config property type invalid (lua error). Invalid property type: '"..properties.type.."'")
			input = vgui.Create( "FLib.Menu.Config.Item.Base", self )
		end


		
		function pnl:Paint()
			local w, h = self:GetSize()
			draw.RoundedBox( 5, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
		end
	end

	vgui.Register( "FLib.Menu.Config.Item.Text", textBox, "DTextEntry" )
	vgui.Register( "FLib.Menu.Config.Item.Number", numberBox, "DTextEntry" )
	vgui.Register( "FLib.Menu.Config.Item.Bool", boolBox, "DButton" )
	vgui.Register( "FLib.Menu.Config.Item.Category", categoryBox, "Panel" )
	vgui.Register( "FLib.Menu.Config.Item.Base", itemBase, "Panel" )
	vgui.Register( "FLib.Menu.Config.CategoryDivider.Server", ServerLabel, "Panel" )
	vgui.Register( "FLib.Menu.Config.CategoryDivider.Client", ClientLabel, "Panel" )
	vgui.Register( "FLib.Menu.Config.Item.ConfigItem", ConfigItem, "Panel" )
	vgui.Register( "FLib.Menu.Config.ModulePanelExpand", expandButton, "DButton" )
	vgui.Register( "FLib.Menu.Config.ModulePanel", modulePanel, "Panel" )

	
	FLib.HotLoad.SourceInSequence( "MenuButtons", {
		{ "main", "https://i.imgur.com/695Hxjv.png", "png", 
			function() -- on success function
				FLib.Menu.AddPage( "main", "MAIN", FLib.Resources["main"], mainPanel ) -- exampl
			end 
		},
		{ "manage", "https://i.imgur.com/I10A7NH.png", "png", 
			function()
				FLib.Menu.AddPage( "manage", "MANAGE", FLib.Resources["manage"], mainPanel )
			end 
		},
		{ "analysis", "https://i.imgur.com/4uCuUOt.png", "png", 
			function()
				FLib.Menu.AddPage( "analysis", "ANALYSIS", FLib.Resources["analysis"], mainPanel )
			end 
		},
		{ "config", "https://i.imgur.com/cpRpoL3.png", "png", 
			function()
				FLib.Menu.AddPage( "config", "CONFIG", FLib.Resources["config"], configPanel )
			end 
		},
		{ "develop", "https://i.imgur.com/Sbid91C.png", "png", 
			function()
				FLib.Menu.AddPage( "develop", "DEVELOP", FLib.Resources["develop"], developPanel )
			end
		}
	} )

end


