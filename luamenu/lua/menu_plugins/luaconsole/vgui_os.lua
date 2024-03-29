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

		if !self.StartMenu or !self.StartMenu:IsValid() then
			self.StartMenu = vgui.Create("LuaStartMenu")
			self.StartMenu:AddMainApp("LuaMenu", "gui/silkicons/application", function()
				if !LuaMenu.Closed then
					Popup("Already Running", "LuaMenu is already running!\nYou can only have one instance of LuaMenu running at a time!")
				else
					LuaMenu:Toggle()
				end
			end)
			parent.ForceOpen = true
		else
			self.StartMenu:Remove()
			self.StartMenu = nil
			parent.ForceOpen = false
		end
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

/*function PANEL:OnCursorEntered()
	self.Direction = 1
end*/

/*function PANEL:OnCursorExited()
	self.Direction = -1
end*/

function PANEL:Think()
	if self.ForceOpen == true then return end
	local x,y = gui.MousePos()
	
	if y < ScrH() - 35 and self.Offset == 1 and self.Down == nil and self.ForceOpen == false then
		self.Down = CurTime() + 0.5
	elseif y > ScrH() - 35 and self.Offset == 0 then
		self.Direction = 1
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