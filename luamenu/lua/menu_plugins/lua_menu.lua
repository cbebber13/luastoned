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
			func = function(frame) LuaMenu.Paint(frame) end,
			info = "The basic derma skin",
		},
		["Steam"] = {
			func = function(frame)
				draw.RoundedBox(4,0,0,frame:GetWide(),frame:GetTall(),Color(104,106,101,255))
				draw.RoundedBox(4,1,1,frame:GetWide()-2,frame:GetTall()-2,Color(70,70,70,255))
				draw.RoundedBox(4,0,0,frame:GetWide(),25,Color(90,106,80,255))
			end,
			info = "Steam skin by LuaStoned",
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
}

function LuaMenu:Reload(str) -- Add a basic reload command, something might break >:O
	if str then -- it's a tab / plugin
		include("menu_plugins/luaconsole/"..str..".lua")
		return
	end
		
	if LuaMenu and LuaMenu.Frame then LuaMenu.Frame:Close() end
	include("menu_plugins/lua_menu.lua")
end
concommand.Add("lua_menu_reload",function(p,c,a) LuaMenu:Reload(a[1]) end)

-- Check if it was installed right
if !file.Exists("../lua/includes/modules/gmcl_luamenu.dll") then print("Please execute 'install_luamenu.bat' or copy all files manually.") return end

--------------------------------------------------
-- Add libraries we might need
--------------------------------------------------

if (not markup) then include("includes/modules/markup.lua") end
include("vgui/DTooltip.lua") -- garry's restrictions, derp

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

--------------------------------------------------
-- require useful modules
--------------------------------------------------

require("luamenu")
require("oosocks")
require("glon")
require("json")

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

function LoadSettings()
	if !file.Exists("luamenu/settings.txt") then 
		LuaMenu.Settings = {AutoOpen = false,Info=true,Skin = "Default",Title = "LuaMenu",}
		return
	end
	LuaMenu.Settings = glon.decode(file.Read("luamenu/settings.txt"))
end
LoadSettings()

function SaveSettings()
	file.Write("luamenu/settings.txt",glon.encode(LuaMenu.Settings))
end

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

function Popup(head,txt,dur,x,y,hclr,tclr)
	DPopup.Count = DPopup.Count + 1
	local panel = vgui.Create("popup")
	panel:Popup(head or "Head",txt or "Txt",dur or 5,x or 240,y or 92,hclr or Color(216,222,211),tclr or Color(255,255,255))
	panel:SetSlot(DPopup.Count)
	table.insert(DPopup.Popups,panel)
	timer.Simple(dur or 5,function()
		DPopup.Count = DPopup.Count - 1
		for k,pop in pairs(DPopup.Popups) do
			pop:SetSlot(pop:GetSlot() - 1)
		end		
	end)
end

--------------------------------------------------
-- Info, spam the client with popups :D
--------------------------------------------------

timer.Create("LuaMenu - Info",60,5,function()
	if LuaMenu.Settings.Info == true then
		Popup("LuaMenu Information",LuaMenu.Info[math.random(#LuaMenu.Info)])
	end
end)

Popup("LuaMenu","LuaMenu has successfully loaded, enjoy this addon.")

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
end
LuaMenu:Load()

--------------------------------------------------
-- LuaMenu Init, create the frame, don't show yet
--------------------------------------------------

function LuaMenu:Init()
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
		pcall(self.Skins[self.Settings.Skin].func or self.Paint,frame)
	end
	
	self.PropertySheet = vgui.Create("DPropertySheet")
 	self.PropertySheet:SetParent(self.Frame)
 	self.PropertySheet:SetPos(5,30)
 	self.PropertySheet:SetSize(self.Frame:GetWide() - 10,self.Frame:GetTall() - 35)
	
	-- register function needs to be rewritten, does not catch all errors and bugs luamenu sometimes
	
	for k,tab in pairs(file.FindInLua("menu_plugins/luaconsole/tab_*.lua")) do
		local ok,panel = pcall(vgui.RegisterFile,"menu_plugins/luaconsole/"..tab)
		if ok and panel then
			local ok,cont = pcall(vgui.CreateFromTable,panel,self.PropertySheet)
			if ok then
				self.PropertySheet:AddSheet(panel.Name,cont,panel.TabIcon,false,false,panel.Desc)
				cont:PerformLayout()
			else
				ErrorNoHalt("LuaMenu panel '"..tab.."' failed to create : '"..tostring(panel).."'\n")
			end
		else
			ErrorNoHalt("LuaMenu panel '"..tab.."' failed : '"..tostring(panel).."'\n")
		end
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
	if !(self.Frame) then
		LuaMenu:Init()
	end
	if self.IsOpen == false then
		self.IsOpen = true
		self.Frame:SetVisible(true)
		self.Frame:SetKeyboardInputEnabled(true)
		self.Frame:SetMouseInputEnabled(true)
	else
		self.IsOpen = false
		self.Frame:SetVisible(false)
		self.Frame:SetKeyboardInputEnabled(false)
		self.Frame:SetMouseInputEnabled(false)
	end
end
concommand.Add("lua_menu",function() LuaMenu:Toggle() end)

hook.Add("Think","LuaMenu - Init",function()
	if LuaMenu.Settings.AutoOpen == true then
		LuaMenu:Toggle()
	end
	hook.Remove("Think","LuaMenu - Init")
end)