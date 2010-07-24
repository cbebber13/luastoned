PANEL = {}

local Open = false

function PANEL:Init()
	if Open then
		self:Remove()
		return
	end
	self:SetTitle"Control Panel"
	self:SetSize(ScrW()/2, ScrH()/2)
	self:Center()
	self:MakePopup()
	local oldpaint = self.Paint
	self.Grid = vgui.Create("DGrid", self)
	self.Grid:StretchToParent(4,25,4,4)
	self.Grid:SetCols( self.Grid:GetWide() / 98 )
	self.Grid:SetColWide( 98 )
	self.Grid:SetRowHeight( 62 )
	local oldlayout = self.Grid.PerformLayout
	self.Grid.PerformLayout = function()
		oldlayout(self.Grid)
		self.Grid:StretchToParent(4,25,4,4)
	end
	self.Grid.Paint = function()
		draw.RoundedBox(4, 0, 0, self.Grid:GetWide(), self.Grid:GetTall(), Color(255,255,255,255))
	end
	for k,tab in pairs(LuaMenu.CPanelTabs) do
		self:AddButton(tab.Name,tab.Icon,tab)
	end
	Open = true
end

function PANEL:Close()
	Open = false
	self:Remove()
end

local buttonTbl = {}

function PANEL:AddButton(name, icon, pnl)
	local panel = vgui.CreateFromTable(buttonTbl)
	panel:Setup(name, icon, pnl)
	self.Grid:AddItem(panel)
end

vgui.Register("OS_ControlMenu", PANEL, "DFrame")

function buttonTbl:Init()
	self:SetSize(96, 60)
	self:SetContentAlignment( 2 )
	
	self:SetTextInset( 0, -5 )
	
	self.Image = vgui.Create( "DImage", self )
	self.Image:SetSize( 36, 36 )
	self.Image:SetMouseInputEnabled( false )
	self.Image:Center()
	self.Image.y = 8
end

function buttonTbl:ApplySchemeSettings()

	self:SetFont( "DefaultSmall" )
	self:SetTextColor( Color( 90, 90, 100, 255 ) )

end

function buttonTbl:Paint()

	if self.Hovered then
	
		draw.RoundedBox( 4, 1, 1, self:GetWide()-2, self:GetTall()-2, Color( 100, 200, 255, 255 ) )
		draw.RoundedBox( 4, 2, 2, self:GetWide()-4, self:GetTall()-4, Color( 130, 230, 255, 255 ) )
	
	end

end

function buttonTbl:Setup(name, icon, panel)
	self:SetText(name)
	self.Image:SetImage(icon)
	self.DoClick = function()
		local pnl = self:GetParent():GetParent()
		pnl.Grid:SetVisible(false)
		local panel2 = vgui.CreateFromTable(panel, pnl)
		panel2:StretchToParent(4,25,4,4)
		local back = vgui.Create("DButton", pnl)
		back:SetPos(pnl:GetWide()-back:GetWide()-6, pnl:GetTall()-back:GetTall()-6)
		back:SetText"Back"
		back.DoClick = function()
			pnl.Grid:SetVisible(true)
			back:Remove()
			panel2:Remove()
		end
	end
end

buttonTbl = vgui.RegisterTable(buttonTbl, "DButton")
