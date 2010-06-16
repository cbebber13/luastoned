PANEL = {}
PANEL.Name = "Base"
PANEL.Desc = "Base Panel"
PANEL.TabIcon = "gui/silkicons/comments"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	function GetBase()
		return self
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
