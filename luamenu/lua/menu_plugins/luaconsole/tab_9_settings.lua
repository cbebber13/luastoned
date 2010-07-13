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
	self.Skin:AddChoice("Default")
	self.Skin:AddChoice("Steam")
	self.Skin.OnSelect = function(panel,num,str)
		LuaMenu.Settings.Skin = str
	end
	self.Skin:SetText(LuaMenu.Settings.Skin)
	
	self.TitleHelp = vgui.Create("DLabel",self)
	self.TitleHelp:SetPos(5,55)
	self.TitleHelp:SetText("Set your title (%time%, %size%)")
	self.TitleHelp:SizeToContents()
	
	self.Title = vgui.Create("DTextEntry",self)
	self.Title:SetText(LuaMenu.Settings.Title)
	self.Title:RequestFocus()
	self.Title.OnEnter = function(self)
		LuaMenu.Settings.Title = self:GetValue()
	end
	self.Title:SetPos(5,75)
	self.Title:SetWide(500)

	function GetSettings()
		return self
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Skin:StretchToParent(5,25,5,self:GetTall() - 45)
	self.Title:StretchToParent(5,75,5,self:GetTall() - 95)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
