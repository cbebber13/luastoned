/*************************************************************************\

	LuaMenu @ http://luastoned.googlecode.com/svn/trunk/luamenu/
	Version: 2.1
	Date: 14.07.2010
	Autor: LuaStoned (the-stone/stoned)

	Contributors:
		Deco, Gbps, DrogenViech, Tobba, ...


\*************************************************************************/

LuaMenu = {
	Version = 2.1,
	IsOpen = false,
	Panel = {},
	Console = {["Text"] = ""},
	Settings = {},
	Skins = {
		["Default"] = {
			PaintFrame = function(frame) LuaMenu.Paint(frame) end,
			Info = "The basic derma skin",
		},
		["Steam"] = {
			PaintFrame = function(frame)
				draw.RoundedBox(4,0,0,frame:GetWide(),frame:GetTall(),Color(104,106,101,255))
				draw.RoundedBox(4,1,1,frame:GetWide()-2,frame:GetTall()-2,Color(70,70,70,255))
				draw.RoundedBox(4,0,0,frame:GetWide(),25,Color(90,106,80,255))
			end,
			Info = "The basic derma skin",
		},
	},
	TmpTitle = "", -- don't spam locals
	Info = {
		"Did you find a bug? Let me know and post the issue in the LuaMenu thread.",
		"Did you know that LuaMenu is still a work-in-progress? Give some ideas and we'll add them.",
		"Did you find a bug? Let me know and post the issue in the LuaMenu thread.",
		"If you don't like this popups, turn them off in the settings tab.",
		"_G.arry = nil",
	},
	Closed = true,
	CloseFrames = {},
}

function LuaMenu:Reload(str) -- Add a basic reload command, something might break >:O
	if str then -- it's a tab / plugin
		include("menu_plugins/luaconsole/"..str..".lua")
		return
	end

	for k,frame in pairs(self.CloseFrames) do
		if IsValid(frame) then
			frame:Close() -- frame:Remove()
		end
	end
	include("menu_plugins/lua_menu.lua")
end
concommand.Add("lua_menu_reload",function(p,c,a) LuaMenu:Reload(a[1]) end)

-- Check if it was installed right
if !file.Exists("../lua/includes/modules/gmcl_luamenu.dll") then print("Please execute 'install_luamenu.bat' or copy all files manually.") return end

--------------------------------------------------
-- Add libraries we might need
--------------------------------------------------

if (not markup) then include("includes/modules/markup.lua") end
include("vgui/DTooltip.lua")
include("vgui/DImageButton.lua")
include("vgui/DBevel.lua")
include("vgui/DTree.lua")
include("vgui/DTree_Node.lua")
include("vgui/DTree_Node_Button.lua")
include("vgui/DTinyButton.lua")

/*	what garry loads in the menu, we might need more as seen above
	vgui/DFrame.lua
	vgui/DButton.lua
	vgui/DSysButton.lua
	vgui/DLabel.lua
	vgui/DImage.lua
	vgui/DPanel.lua
	vgui/DPropertySheet.lua
	vgui/DHorizontalScroller.lua
	vgui/DPanelList.lua
	vgui/DVScrollBar.lua
	vgui/DScrollBarGrip.lua
	vgui/DCategoryCollapse.lua
	vgui/DListView_Line.lua
	vgui/DListView.lua
	vgui/DListView_Column.lua
	vgui/DForm.lua
	vgui/DMultiChoice.lua
	vgui/DTextEntry.lua
	vgui/DCheckBox.lua
	vgui/DNumberWang.lua
	vgui/DMenu.lua
	vgui/DMenuOption.lua
	vgui/DColumnSheet.lua
	vgui/DScrollPanel.lua
	vgui/DGrid.lua
	vgui/DLabelURL.lua
*/

/* Reference

Functions

	PANEL:PaintOver()
		Like Paint except drawn after everything else has drawn.

	PANEL:ActionSignal( key, value, ... )
		Receive an ActionSignal (various things are broadcast here)
	
	PANEL:OnFocusChanged( bLost )
		The panel has lost or gained focus

	PANEL:StatusChanged( text )
		The text in the status bar has changed

	PANEL:ProgressChanged( progress )
		Loading progress changed

	PANEL:FinishedURL( url )
		Finished loading a specific URL

	PANEL:OpeningURL( url, target )
		Page wants to open URL.
		Return true to not load URL.

Member vars

	All
		Hovered			- 	bool (true if panel is hovered)

	Button
		Selected		-	bool (true if button is selected)
		Depressed		-	bool (true if button is depressed)
		Armed			-	bool (true if button is hovered)
		DefaultButton	-	bool (true if button is default button)

	HTML
		Progress		-	float (Progress bar amount between 0-1)
		Status			-	string (Status Bar Text)
		URL				-	string (Current URL)
	
*/

--------------------------------------------------
-- require useful modules
--------------------------------------------------

require("luamenu")
require("oosocks")
require("glon")
require("json")
json = Json -- stupid but heh :3

RunString = MenuRunString

--------------------------------------------------
-- Hook LuaConsole
--------------------------------------------------

local Console = {
	Queue = {},
	Ignore = { -- stuff we don't want to spam our luaconsole with
		"C_BaseAnimating", -- C_BaseAnimating::SequenceDuration( 2047 ) out of range
		--"ScriptEnforce:",
		"SetConVar",
		"can't be found on disk",
		"not found",
		"Loading",
		"Material:",
	},
}

hook.Add("RawConsole","LuaMenu - ConsoleHook",function(str,clr)
	for k,ignore in pairs(Console.Ignore) do
		if str:find(ignore) then
			return
		end
	end

	table.insert(Console.Queue,clr)
	table.insert(Console.Queue,str)
	if string.byte(str:sub(-1,-1)) == 10 then -- new line
		hook.Call("ConsoleText",nil,Console.Queue)
		Console.Queue = {}
	end
end)

--------------------------------------------------
-- Basic variable saving/loading
--------------------------------------------------

function SetMenuVar(str,data)
	str = str:gsub("[^%w_]+","")
	if type(data) ~= "string" then
		print("[MenuVar] Tried to pass invalid data type ("..type(data)..")")
		return
	end
	file.Write("luamenu/menuvar/"..str..".txt",data)
end

function GetMenuVar(str)
	str = str:gsub("[^%w_]+","")
	if file.Exists("luamenu/menuvar/"..str..".txt") then
		return file.Read("luamenu/menuvar/"..str..".txt")
	end
	return nil
end

LuaMenu.Settings = {AutoOpen = false,Info=false,InfoFlip = false,Skin = "Default",Title = "LuaMenu",}
function LoadSettings()
	if !file.Exists("luamenu/settings.txt") then
		
		return
	end
	LuaMenu.Settings = table.Merge(LuaMenu.Settings, glon.decode(file.Read("luamenu/settings.txt")))
end
LoadSettings()

function SaveSettings()
	file.Write("luamenu/settings.txt",glon.encode(LuaMenu.Settings))
end

--------------------------------------------------
-- Load plugins based on their prefix
--------------------------------------------------

function LuaMenu:Load(arg)
	for k,lua in pairs(file.FindInLua("menu_plugins/luaconsole/plugin_*.lua")) do
		if Irc and lua:find("irc") then
			print("[LuaMenu] Irc plugin already loaded.")
		else
			include("menu_plugins/luaconsole/"..lua)
		end
	end

	for k,lua in pairs(file.FindInLua("menu_plugins/luaconsole/vgui_*.lua")) do
		include("menu_plugins/luaconsole/"..lua)
	end
	for k,lua in pairs(file.FindInLua("menu_plugins/luaconsole/skin_*.lua")) do
		local tmp = SKIN
		SKIN = {}
		include("menu_plugins/luaconsole/"..lua)
		SKIN.Name = SKIN.Name or "**ERROR** - NO NAME"
		LuaMenu.Skins[SKIN.Name] = SKIN
		SKIN = tmp
	end
end
LuaMenu:Load()

--------------------------------------------------
-- Create Fonts for LuaMenu and sub plugins
--------------------------------------------------

--rface.CreateFont("Base font"	,size	,width	,bold	,italic	,"Generic name")
surface.CreateFont("Default"	,12		,700	,false	,false	,"Default12B")
surface.CreateFont("Default"	,13		,700	,false	,false	,"Default13B")
surface.CreateFont("Default"	,14		,700	,true	,false	,"Default14")

--------------------------------------------------
-- Helper functions
--------------------------------------------------

local ExtraTabs = {} -- tobba DEV
function LuaMenu.AddTab(...)
	table.insert(ExtraTabs,{...})
end

function table.Print(tbl,nr,done)
	tbl = tbl or {}
	done = done or {}
	nr = nr or 0
	local maxlen = 0
	for k,_ in pairs(tbl) do
		if tostring(k):len() > maxlen then
			maxlen = tostring(k):len()
		end
	end

	for key,value in pairs(tbl) do
		if type (value) == "table" and not done[value] then
			done[value] = true
			print(string.rep("\t",nr)..tostring(key)..":")
			table.Print(value,nr + 1,done)
		else
			local keylen = tostring(key):len()
			local add = math.floor((maxlen - keylen)) --/7
			print(string.rep("\t",nr)..tostring(key)..string.rep(" ",add).." = "..tostring(value))
		end
	end
end

PrintTable = table.Print

function NumberSuffix(n)
	local last_char = string.sub(tostring(n), -1)
	if string.sub(tostring(n), -2, -2) == "1" then
		return "th"
	elseif last_char == "1" then
		return "st"
	elseif last_char == "2" then
		return "nd"
	elseif last_char == "3" then
		return "rd"
	else
		return "th"
	end
end

function FormatTime(sec,format)
	local i = math.floor(sec)

	local h = i / 3600
	local m = ( i / 60 ) % 60
	local s = i % 60
	local ms = math.floor((sec - i)*100)

	return string.format(format,h,m,s,ms)
end

function LerpVector(num,vec1,vec2)
	local vec = Vector()
	vec.x = Lerp(num,vec1.x,vec2.x)
	vec.y = Lerp(num,vec1.y,vec2.y)
	vec.z = Lerp(num,vec1.z,vec2.z)
	return vec
end

DPopup = {
	Count = 0,
	Popups = {},
}

function Popup(head,txt,dur,hclr,tclr,flip,x,y)
	DPopup.Count = DPopup.Count + 1
	local panel = vgui.Create("Popup")
	panel:Popup(head or "",txt or "",dur or 5,hclr or Color(216,222,211),tclr or Color(255,255,255),flip or LuaMenu.Settings.InfoFlip,x or 240,y or 92)
	panel:SetSlot(DPopup.Count)
	table.insert(DPopup.Popups,panel)
	timer.Simple(dur or 5,function()
		DPopup.Count = DPopup.Count - 1
		for k,pop in pairs(DPopup.Popups) do
			if IsValid(pop) then
				pop:SetSlot(pop:GetSlot() - 1)
			end
		end
	end)
end

function DPopup:Think()
	for k,pop in pairs(self.Popups) do
		if !IsValid(pop) or pop.Removed then
			if !IsValid() then
				table.remove(self.Popups,k)
			else
				pop:Remove()
				table.remove(self.Popups,k)
			end
		end
	end
end
hook.Add("Think","LuaMenu - PopupThink",function() DPopup:Think() end)

--lua: Popup("Popup Title","Popup content, can be pretty long actually. Automatically creates newlines etc...",10,nil,nil,Color(100,255,100))
--lua: Popup("LuaMenu Chat","Stoned: Chat notifications are coming soon, kewl eh?",10,nil,nil,Color(255,255,100))

--------------------------------------------------
-- Info, spam the client with popups :D
--------------------------------------------------

timer.Create("LuaMenu - Info",60,5,function()
	if LuaMenu.Settings.Info == true then
		Popup("LuaMenu Information",LuaMenu.Info[math.random(#LuaMenu.Info)],15)
	end
end)

Popup("LuaMenu","LuaMenu has successfully loaded, enjoy this addon.")

--------------------------------------------------
-- FrameBar, very hacky at the moment, needs work
--------------------------------------------------

LuaMenu.Frames = 0
LuaMenu.FrameBar = vgui.Create("LuaMenuBar")
LuaMenu.FrameBar:MakePopup()
table.insert(LuaMenu.CloseFrames,LuaMenu.FrameBar)

function LuaMenu:AddFrame(panel,name,align)
	panel.SysButton = vgui.Create("DSysButton")
	panel.SysButton:SetParent(panel)
	panel.SysButton:SetPos(panel:GetWide()-40,0)
	panel.SysButton:SetSize(20,20)
	panel.SysButton:SetType("down") -- This can be "up", "down", "left", "right", "updown", "close", "grip", "tick", "question", and "none".
	panel.SysButton.Paint = function() end
	panel.SysButton.DoClick = function(self) panel:SetVisible(false) end
		
	-- Move this code to the bar as soon as possible
	local buttontab = vgui.Create("DButton")
	buttontab:SetParent(self.FrameBar)
	buttontab:SetSize(100,20)
	buttontab:SetPos(40 + self.Frames * 120,5)
	buttontab:SetText(name or "untitled")
	buttontab.DoClick = function(self)
		if panel:IsVisible()  then
			panel:SetVisible(false)
		else
			panel:SetVisible(true)
			panel:RequestFocus()
		end
	end
	
	buttontab.Paint = function(self)
		if self.Hovered then
			draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(110,126,100,255))
		else
			draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(90,106,80,255))
		end
	end
	
	self.Frames = self.Frames + 1
	
	-- very hacky, fix this
	local close = panel.Close
	panel.Close = function(panel)
		close(panel)
		--panel.Close = close -- that does not makse sense at all, wtf
		buttontab:Remove()
		self.Frames = self.Frames - 1
	end
end

--------------------------------------------------
-- LuaMenu Init, create the frame, don't show yet
--------------------------------------------------

function LuaMenu:Init()
	self.Closed = false
	self.Frame = vgui.Create("DFrame")
	self.Frame:SetSize(ScrW() / 1.5,ScrH() / 1.5)
	self.Frame:SetPos(ScrW() - ScrW() / 1.5 - 50,50)
	self.Frame:SetMinimumSize(300,150)
	self.Frame:SetTitle("LuaMenu")
	self.Frame:SetVisible(false)
	self.Frame:SetDraggable(true)
	self.Frame:SetSizable(true)
	self.Frame:SetScreenLock(false)
	self.Frame:ShowCloseButton(true)
	self.Frame:SetBackgroundBlur(false)
	self.Frame:MakePopup()
	self.Frame.Close = function(self)
		LuaMenu.IsOpen = false
		self:SetVisible(false)
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(false)
	end
	self.Frame.OldPerformLayout = self.Frame.PerformLayout
	self.Frame.PerformLayout = function(self)
		LuaMenu.PropertySheet:StretchToParent(5,30,5,5)
		local tab = LuaMenu.PropertySheet:GetActiveTab()
		if tab then
			tab:StretchToParent(2,2,2,2)
			tab:PerformLayout()
		end
		LuaMenu.PropertySheet:PerformLayout()
		self:OldPerformLayout(self)
	end
	self.Paint = self.Frame.Paint
	self.Frame.Paint = function(frame)
		pcall(self.Skins[self.Settings.Skin].PaintFrame or self.Paint,frame)
	end
	
	self:AddFrame(self.Frame,"LuaMenu") -- Add the mainframe to the bar
	table.insert(self.CloseFrames,self.Frame)

	self.PropertySheet = vgui.Create("DPropertySheet")
 	self.PropertySheet:SetParent(self.Frame)
 	self.PropertySheet:SetPos(5,30)
 	self.PropertySheet:SetSize(self.Frame:GetWide() - 10,self.Frame:GetTall() - 35)

	-- register function needs to be rewritten, does not catch all errors and bugs luamenu sometimes

	local pstable = self.PropertySheet:GetTable() -- revise this, lololol
	local num_errors = {}
	for k,tab in pairs(file.FindInLua("menu_plugins/luaconsole/tab_*.lua")) do
		local ok,panel = pcall(vgui.RegisterFile,"menu_plugins/luaconsole/"..tab)
		if ok and panel then
			for k, v in pairs(panel) do
				if type(v) == "function" then
					local old = v
					panel[k] = function(...)
						local ok, err = pcall(old, ...)
						if !ok then
							--num_errors[tab] = num_errors[tab] or 0
							--num_errors[tab] = num_errors[tab] + 1
							--local str = err
							--Msg("ERROR: "..str)
							--timer.Simple(0, function()
								--local pnl = GetError().Output:AddLine(tostring(os.date("%I:%M:%S")),"Tab Error",str:gsub("\n"," "))
								--pnl.FullText = str
							--end)
						end
					end
				end
			end
			local ok,cont = pcall(vgui.CreateFromTable,panel,self.PropertySheet)
			if ok then
				if !panel or !cont or !panel.Name then
					//Msg("Failed adding tab "..tab.." panel or content did not exist!")
				else
					self.PropertySheet:AddSheet(panel.Name,cont,panel.TabIcon,false,false,panel.Desc)
					local pnl = pstable.Items[#pstable.Items].Tab.Panel

					--local img = vgui.Create("DImage",pnl)
					--img:SetPos(pnl:GetWide() - 25,-10)
					--img:SetSize(16,16)
					--img:NoClipping(true)
					--img:SetImage("gui/silkicons/delete")
					--img.p = img.Paint
					--img.Paint = function(self)
					--	if !num_errors[tab] then return end
					--	self.p(self)
					--	draw.RoundedBox(0,4,7,8,2,Color(238,102,82,255))
					--	if num_errors[tab] > 9 then
					--		draw.DrawText("+","Default",5,1,Color(255,255,255,255),ALIGN_LEFT)
					--	else
					--		draw.DrawText(num_errors[tab],"Default",5,1,Color(255,255,255,255),ALIGN_LEFT)
					--	end
					--end
					cont:PerformLayout()
				end
			else
				ErrorNoHalt("LuaMenu panel '"..tab.."' failed to create : '"..tostring(cont).."'\n")
			end
		else
			ErrorNoHalt("LuaMenu panel '"..tab.."' failed : '"..tostring(cont).."'\n")
		end
	end

	for k,v in pairs(ExtraTabs) do
		self.PropertySheet:AddSheet(unpack(v))
	end

	hook.Add("Think","LuaMenu - Title Time",function()
		if !LuaMenu.Frame then return end
		LuaMenu.TmpTitle = LuaMenu.Settings.Title:gsub("%%time%%",FormatTime(CurTime(),"%02i:%02i:%02i"))
		LuaMenu.TmpTitle = LuaMenu.TmpTitle:gsub("%%size%%","("..LuaMenu.Frame:GetWide().." x "..LuaMenu.Frame:GetTall()..")")

		LuaMenu.Frame:SetTitle(LuaMenu.TmpTitle)
	end)
	concommand.Add("lua_menu_close",function() LuaMenu.Frame:Close() end)

	http.Get("http://gmod.luastoned.com/update.php?version="..self.Version,"",function(cont,size)
		--print(cont)
	end)
end

function LuaMenu:Toggle()
	if !self.Frame then
		LuaMenu:Init()
	end
	if self.IsOpen == false then
		self.IsOpen = true
		self.Frame:SetVisible(true)
		self.Frame:SetKeyboardInputEnabled(true)
		self.Frame:SetMouseInputEnabled(true)
		if LuaMenu.Closed then
			self:AddFrame(self.Frame,"LuaMenu") -- Add the mainframe to the bar
			LuaMenu.Closed = false
		end
	else
		self.IsOpen = false
		self.Frame:SetVisible(false)
		self.Frame:SetKeyboardInputEnabled(false)
		self.Frame:SetMouseInputEnabled(false)
	end
end
concommand.Add("lua_menu",function() LuaMenu:Toggle() end)

hook.Add("Think","LuaMenu - Init",function()
	if LuaMenu.Settings.AutoOpen then
		LuaMenu:Toggle()
	end
	hook.Remove("Think","LuaMenu - Init")
end)