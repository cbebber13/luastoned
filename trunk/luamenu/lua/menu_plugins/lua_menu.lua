if (_G.Player) then return end
concommand.Add("lua_menu_reload",function()
	if LuaMenu and LuaMenu.Frame then LuaMenu.Frame:Close() end
	include("menu_plugins/lua_menu.lua")
end)
if (not markup) then include("includes/modules/markup.lua") end
if !file.Exists("../lua/includes/modules/gmcl_luamenu.dll") then print("Please execute 'install_luamenu.bat' or copy all files manually.") return end
require("luamenu")
require("oosocks")
require("glon")

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

RunString = MenuRunString

ConsoleQueue = {}
ConsoleIgnore = { -- C_BaseAnimating::SequenceDuration( 2047 ) out of range
	"C_BaseAnimating",
	--"ScriptEnforce:",
	"SetConVar",
	"can't be found on disk",
	"not found",
	"Loading",
	"Material:",
}

hook.Add("RawConsole","LuaMenu - ConsoleHook",function(str,clr)
	for k,ignore in pairs(ConsoleIgnore) do
		if str:find(ignore) then
			return
		end
	end

	table.insert(ConsoleQueue,clr)
	table.insert(ConsoleQueue,str)
	if string.byte(str:sub(-1,-1)) == 10 then -- new line
		hook.Call("ConsoleText",nil,ConsoleQueue)
		ConsoleQueue = {}
	end
end)


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

function FormatTime(sec,format)
	local i = math.floor(sec)
	
	local h = i / 3600
	local m = ( i / 60 ) % 60
	local s = i % 60
	local ms = math.floor((sec - i)*100)

	return string.format(format,h,m,s,ms)
end

function LoadSettings()
	if !file.Exists("luamenu/settings.txt") then return {AutoOpen = false,Skin = "Default",Title = "LuaMenu"} end
	return glon.decode(file.Read("luamenu/settings.txt"))
end

function SaveSettings()
	file.Write("luamenu/settings.txt",glon.encode(LuaMenu.Settings))
end

LuaMenu = {
	Version = 2.0,
	IsOpen = false,
	Console = {["Text"] = ""},
	Settings = LoadSettings(),
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
}

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