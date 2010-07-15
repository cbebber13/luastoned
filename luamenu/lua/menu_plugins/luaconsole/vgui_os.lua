-- LuaStoned's GBar / whatever lul?

local PANEL = {}
function PANEL:Init()
	self.Offset = 0
	self.Direction = 0
	self.Speed = 10
	self.Content = {}
	self.ForceOpen = false
	self.Logo = Material("gui/gmod_logo")
	
	self.Start = vgui.Create("DButton")
	self.Start:SetParent(self)
	self.Start:SetPos(2,2)
	self.Start:SetSize(32,32)
	self.Start:SetText("")
	self.Start.Paint = function(start)
		surface.SetMaterial(self.Logo)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(0,0,32,32)
	end
	self.Start.DoClick = function(self)
		local parent = self:GetParent()
		parent.ForceOpen = true
		local menu = DermaMenu()
		menu:SetMinimumWidth(200)
		menu:SetDrawBorder(false)

		function menu:OpenSubMenu(item, menu) -- thanks to ja_cop
			-- why can menu be nil anyway? Just don't call this callback if it's nil
			if not menu then return end
			local openMenu = self:GetOpenSubMenu()
			if openMenu and openMenu ~= menu then
				self:CloseSubMenu(openMenu)
			else
				local x, y = item:LocalToScreen(self:GetWide(), 0)
				menu:Open(x - 1, y - 36, false, item)
				self:SetOpenSubMenu(menu)
			end
		end		
		local addop = function(self,str,func)
			local pnl = vgui.Create("DMenuOption",self)
			pnl:SetText(str)
			local func = function()
				parent:ForceClose()
				if (func) then func() end
			end
			pnl.DoClick = func
			self:AddPanel(pnl)
			return true
		end
		
		menu.AddOption = addop
		local open = menu:AddSubMenu("Open",function() Popup("LuaMenu","Open cool stuff here.") end)
		open.AddOption = addop
		open:AddOption("LuaMenu",function() Popup("LuaMenu","I'm toggling myself, yay! :D") LuaMenu:Toggle() end)
		open:AddOption("Steam Friends",function() Popup("LuaMenu","Coming soon...") end)
		open:AddOption("Server List",function() Popup("LuaMenu","Coming soon...") end)		
		menu:AddSpacer()
		menu:AddOption("New")
		menu:AddOption("Load")
		menu:AddOption("Save")
		menu:AddSpacer()
		local run = menu:AddSubMenu("Run",function() Popup("LuaMenu","Run Lua everywhere :)") end)
		run.AddOption = addop
		run:AddOption("print('Credtis')",function() print("Credits go to LuaStoned (stoned/the-stone), Deco, Gbps, Tobba, many others...") end)
		run:AddOption("print('Version')",function() print("LuaMenu Version: "..LuaMenu.Version) end)
		menu:Open(0,ScrH()-29)
	end
end

function PANEL:Close()
	self:SetVisible(false)
	self:Remove()
end

function PANEL:ForceClose()
	self.Direction = -1
	self.Down = nil
	self.ForceOpen = false
end

function PANEL:Think()
	if self.ForceOpen == true then return end
	local x,y = gui.MousePos()
	if y > 1075 and self.Offset == 0 then
		self.Direction = 1
	end
	if y == 0 and self.Offset == 1 and self.Down == nil and self.ForceOpen == false then
		self.Down = CurTime() + 0.5
	end	
	
	self.Offset = math.Clamp(self.Offset + (self.Direction * 0.01 * self.Speed),0,1) -- FrameTime()
	self:InvalidateLayout()
	
	if self.Direction == 1 and self.Offset == 1 then
		self.Direction = 0
	end
	if self.Down ~= nil and CurTime() > self.Down then
		self.Direction = -1
		self.Down = nil
	end
end

function PANEL:PerformLayout()
	local w,h = ScrW(),31
	
	self:SetSize(w,h)
	self:SetPos(0,ScrH() - ((h-1) * self.Offset)-1)
end

function PANEL:Paint()
	local w,h = self:GetWide(), self:GetTall()
	local a = 100--self.Offset * 255
	
	surface.SetDrawColor(47,49,45,a+40)
	surface.DrawRect(0,0,w,h/2)
	
	surface.SetDrawColor(47,49,45,a)
	surface.DrawRect(0,h/2,w,h/2)
	
	surface.SetDrawColor(104,106,101,a)
	surface.DrawOutlinedRect(0,0,w,h)
	
	surface.SetDrawColor(255,255,255,a)
end
vgui.Register("LuaMenuBar",PANEL)