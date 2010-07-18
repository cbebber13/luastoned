-- Tobba's GStart or whatever

local Tex_Corner8 	= surface.GetTextureID( "gui/corner8" )
local Tex_Corner16 	= surface.GetTextureID( "gui/corner16" )

local function RoundedBoxEx( bordersize, x, y, w, h, color, a, b, c, d )

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )

	surface.SetDrawColor( color.r, color.g, color.b, color.a )
	
	// Draw as much of the rect as we can without textures
	surface.DrawRect( x+bordersize, y, w-bordersize*2, h )
	surface.DrawRect( x, y+bordersize, bordersize, h-bordersize*2 )
	surface.DrawRect( x+w-bordersize, y+bordersize, bordersize, h-bordersize*2 )
	
	local tex = Tex_Corner8
	if ( bordersize > 8 ) then tex = Tex_Corner16 end
	
	surface.SetTexture( tex )
	
	if ( a ) then
		surface.DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 ) 
	else
		surface.DrawRect( x, y, bordersize, bordersize )
	end
	
	if ( b ) then
		surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 ) 
	else
		surface.DrawRect( x + w - bordersize, y, bordersize, bordersize )
	end
	
	if ( c ) then
		surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 )
	else
		surface.DrawRect( x + w - bordersize, y + h - bordersize, bordersize, bordersize )
	end
	
	if ( d ) then
		surface.DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 ) 
	else
		surface.DrawRect( x, y + h -bordersize, bordersize, bordersize )
	end
end

local PANEL = {}
function PANEL:Init()
	self:MakePopup()
	self.MainApps = {}
	self.AllApps = {}	
	self.SideButtons = 0
	self:AddButtonToSide("Control Panel", function()
		vgui.Create"OS_ControlMenu"
	end)
	self:AddButtonToSide("Source Console toggle", function()
		MenuCommand("toggleconsole")
	end)
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

function PANEL:AddButtonToSide(name, func, ...)
	local args = {...}
	local w,h = ScrW()*0.23, ScrH()*0.4
	local panel = vgui.Create("DButton", self)
	panel:SetPos(8+(w/1.8), 4 + (self.SideButtons*34))
	panel:SetSize(w-(12+(w/1.8)), 32)
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
			/*RoundedBoxEx(4, 1, 1, panel:GetWide()-2, (panel:GetTall()-2)/2, Color(255,255,255,45), true, true, false, false)
			RoundedBoxEx(4, 1, (panel:GetTall()-1)/2, panel:GetWide()-2, (panel:GetTall()-2)/2, Color(155,155,155,45), false, false, true, true)*/
			surface.SetDrawColor(90,90,90, 255)
			surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
			surface.SetDrawColor(120,120,120, 255)
			surface.DrawRect(1, 1, panel:GetWide()-2, panel:GetTall()-2)
			surface.SetDrawColor(255,255,255,85)
			surface.SetTexture(surface.GetTextureID"gui/gradient_down")
			surface.DrawTexturedRect(1, 1, panel:GetWide()-2, panel:GetTall()-2)
		end
		surface.SetFont"Default"
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos(4, ((panel:GetTall()-1)/2)-(({surface.GetTextSize(name)})[2]/2)) -- Oneliner for centering text
		surface.DrawText(name)
	end
	panel.DoClick = function()
		self:Remove()
		LuaMenu.FrameBar.ForceOpen = false
		func(unpack(args))
	end
	self.SideButtons = self.SideButtons + 1
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
			surface.DrawRect(1, 1, panel:GetWide()-2, panel:GetTall()-2)
			surface.SetDrawColor(255,255,255,85)
			surface.SetTexture(surface.GetTextureID"gui/gradient_down")
			surface.DrawTexturedRect(1, 1, panel:GetWide()-2, panel:GetTall()-2)
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