if (_G.Player) then return end
concommand.Add("lua_menu_reload",function() include("vgui/lua_menu.lua") end)

function FormatTime(sec,format)
	local i = math.floor(sec)
	
	local h = i / 3600
	local m = ( i / 60 ) % 60
	local s = i % 60
	local ms = math.floor((sec - i)*100)

	return string.format(format,h,m,s,ms)
end

LuaMenu = {
	Version = 1.0,
	IsOpen = false,
	Console = {["Text"] = ""},
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
	self.Frame.OldPaint = self.Frame.Paint
	self.Frame.Paint = function(self)
		draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(104,106,101,255))
		draw.RoundedBox(4,1,1,self:GetWide()-2,self:GetTall()-2,Color(70,70,70,255))
		draw.RoundedBox(4,0,0,self:GetWide(),25,Color(90,106,80,255))
	end
	
	self.PropertySheet = vgui.Create("DPropertySheet")
 	self.PropertySheet:SetParent(self.Frame)
 	self.PropertySheet:SetPos(5,30)
 	self.PropertySheet:SetSize(self.Frame:GetWide() - 10,self.Frame:GetTall() - 35)
	
	for k,tab in pairs(file.FindInLua("vgui/luaconsole/tab_*.lua")) do
		local ok,panel = pcall(vgui.RegisterFile,"vgui/luaconsole/"..tab)
		if ok and panel then
			local ok,cont = pcall(vgui.CreateFromTable,panel,self.PropertySheet)
			if ok then
				self.PropertySheet:AddSheet(panel.Name,cont,panel.TabIcon,false,false,panel.Desc)
				cont:PerformLayout()
			else
				ErrorNoHalt("LuaConsole panel '"..tab.."' failed to create : '"..tostring(panel).."'\n")
			end
		else
			ErrorNoHalt("LuaConsole panel '"..tab.."' failed : '"..tostring(panel).."'\n")
		end
	end

	hook.Add("Think","LuaMenu - Title Time",function()
		if !LuaMenu.Frame then return end
		LuaMenu.Frame:SetTitle("LuaMenu - running since "..FormatTime(CurTime(),"%02i:%02i:%02i").." ("..LuaMenu.Frame:GetWide().." x "..LuaMenu.Frame:GetTall()..")")
	end)
	concommand.Add("lua_menu_close",function() LuaMenu.Frame:Close() end)
	
	http.Get("http://repo.gmod.biz/update.php?version="..self.Version,"",function(cont,size)
		print(cont)
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