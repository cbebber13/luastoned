local PANEL = {}
function PANEL:Init()
	self.Logo = Material("console/gmod_logo")
	self.PosX = ScrW() / 3
	self.PosY = ScrH() / 3
	self.SizeX = 256
	self.SizeY = 256

	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)	
end

function PANEL:SetPos(x,y)
	self.PosX = x
	self.PosY = y
end

function PANEL:SetSize(x,y)
	self.SizeX = x
	self.SizeY = y
end

function PANEL:Paint()
	surface.SetMaterial(self.Logo)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
end

function PANEL:PerformLayout()
	self:SetPos(self.PosX,self.PosY)
	self:SetSize(self.SizeX,self.SizeY)
	
end
vgui.Register("LuaMenuLogo",PANEL)