PANEL = {}
PANEL.Name = "Settings"
PANEL.Desc = "Set your preferences"
PANEL.TabIcon = "gui/silkicons/layout_edit"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.SkinHelp = vgui.Create("DLabel",self)
	self.SkinHelp:SetPos(5,5)
	self.SkinHelp:SetText("Choose your skin")
	self.SkinHelp:SizeToContents()
	
	self.Skin = vgui.Create("DMultiChoice",self)
	self.Skin:SetPos(5,25)
	self.Skin:SetSize(100,20)
	self.Skin:AddChoice("Default")
	self.Skin:AddChoice("Steam")
	self.Skin.OnSelect = function(panel,num,str)
		LuaMenu.Settings.Skin = str
	end
	self.Skin:SetText(LuaMenu.Settings.Skin)

	function GetSettings()
		return self
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
