-- Tobba GStart or whatever

local PANEL = {}
function PANEL:Init()
	self:MakePopup()
	self.MainApps = {}
	self.AllApps = {}	
end

function PANEL:Close()
	self:Remove()
end

function PANEL:Think()
end

function PANEL:PerformLayout()
	self:SetSize(ScrW()*0.23,ScrH()*0.4)
	self:SetPos(0,(ScrH() - 31)-(ScrH()*0.4))
end

function PANEL:AddMainApp(name, icon, callback, ...)
	local args = {...}
	local w,h = ScrW()*0.23, ScrH()*0.4

	local panel = vgui.Create("DButton", self)
	panel:SetPos(6, 6+(#self.MainApps*42))
	panel:SetSize((w/1.8)-4, 40)
	panel:SetText""
	panel.MouseOver = false
	panel.OnCursorEntered = function()
		panel.MouseOver = true
	end
	panel.OnCursorExited = function()
		panel.MouseOver = false
	end
	panel.Paint = function()
		if panel.MouseOver then
			surface.SetDrawColor(130,130,220, 255)
			surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
			surface.SetDrawColor(160,160,255, 255)
			surface.DrawRect(2, 2, panel:GetWide()-4, panel:GetTall()-4)
			surface.SetDrawColor(255,255,255,85)
			surface.SetTexture(surface.GetTextureID"gui/gradient_down")
			surface.DrawTexturedRect(2, 2, panel:GetWide()-4, panel:GetTall()-4)
		end
		local offset = 4
		if icon then
			offset = 42
			surface.SetTexture(surface.GetTextureID(icon))
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(4, 4, 34, 34)
		end
		surface.SetFont"Default"
		surface.SetTextColor(20,20,20,255)
		surface.SetTextPos(offset, 20-(({surface.GetTextSize(name)})[2]/2)) -- Oneliner for centering text
		surface.DrawText(name)
	end
	panel.DoClick = function()
		self:Remove()
		LuaMenu.FrameBar.ForceOpen = false
		callback(unpack(args))
	end
	table.insert(self.MainApps, {name, icon, callback})
end

function PANEL:Paint()
	local w,h = self:GetWide(), self:GetTall()

	//draw.RoundedBox(4,0,0,w,h,Color(35,35,35,235))
	surface.SetDrawColor(35,35,35,235)
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(255,255,255,55)
	surface.SetTexture(surface.GetTextureID"gui/gradient_down")
	surface.DrawTexturedRect(0,0,w,h)
	draw.RoundedBox(4,4,4,w/1.8,h-8,Color(255,255,255,255))
	/*for k, v in pairs(self.MainApps) do
		surface.SetDrawColor(130,130,220, 255)
		surface.DrawRect(6, 6, (w/1.8)-4, 40)
		surface.SetDrawColor(160,160,255, 255)
		surface.DrawRect(8, 8, (w/1.8)-8, 36)
	end*/
end
vgui.Register("LuaStartMenu",PANEL)