PANEL = {}
PANEL.Name = "App Store"
PANEL.Desc = "Get lua addons directly into your GMod"
PANEL.TabIcon = "gui/silkicons/application_view_list"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.CategoryList = vgui.Create("DPanelList",self)
	self.CategoryList:SetAutoSize(true)
	self.CategoryList:SetSpacing(5)
	self.CategoryList:EnableHorizontal(false)
	self.CategoryList:EnableVerticalScrollbar(true)
	
	self.Cat_Addons = vgui.Create("DCollapsibleCategory")
	self.Cat_Addons:SetExpanded(0)
	self.Cat_Addons:SetLabel("Addons")
	
	self.List_Addons = vgui.Create("DListView")
	self.List_Addons:AddColumn("Run - Config"):SetFixedWidth(100)
	self.List_Addons:AddColumn("Name - Information")
	self.List_Addons:AddColumn("Author"):SetFixedWidth(150)
	self.List_Addons:SetTall(150)
	self.List_Addons:SetDataHeight(16)
	
	self.Cat_Addons:SetContents(self.List_Addons)
	self.CategoryList:AddItem(self.Cat_Addons)
	
	self.Cat_Plugins = vgui.Create("DCollapsibleCategory")
	self.Cat_Plugins:SetExpanded(0)
	self.Cat_Plugins:SetLabel("Plugins")
	
	self.List_Plugins = vgui.Create("DListView")
	self.List_Plugins:AddColumn("Run - Config"):SetFixedWidth(100)
	self.List_Plugins:AddColumn("Name - Information")
	self.List_Plugins:AddColumn("Author"):SetFixedWidth(150)
	self.List_Plugins:SetTall(150)
	self.List_Plugins:SetDataHeight(16)
	
	self.Cat_Plugins:SetContents(self.List_Plugins)	
	self.CategoryList:AddItem(self.Cat_Plugins)
	
	self.Cat_Extensions = vgui.Create("DCollapsibleCategory")
	self.Cat_Extensions:SetExpanded(0)
	self.Cat_Extensions:SetLabel("Extensions")
	
	self.List_Extensions = vgui.Create("DListView")
	self.List_Extensions:AddColumn("Run - Config"):SetFixedWidth(100)
	self.List_Extensions:AddColumn("Name - Information")
	self.List_Extensions:AddColumn("Author"):SetFixedWidth(150)
	self.List_Extensions:SetTall(150)
	self.List_Extensions:SetDataHeight(16)
	
	self.Cat_Extensions:SetContents(self.List_Extensions)
	self.CategoryList:AddItem(self.Cat_Extensions)
	
	self.Cat_Skins = vgui.Create("DCollapsibleCategory")
	self.Cat_Skins:SetExpanded(0)
	self.Cat_Skins:SetLabel("Skins")
	
	self.List_Skins = vgui.Create("DListView")
	self.List_Skins:AddColumn("Run - Config"):SetFixedWidth(100)
	self.List_Skins:AddColumn("Name - Information")
	self.List_Skins:AddColumn("Author"):SetFixedWidth(150)
	self.List_Skins:SetTall(150)
	self.List_Skins:SetDataHeight(16)
	
	self.Cat_Skins:SetContents(self.List_Skins)
	self.CategoryList:AddItem(self.Cat_Skins)

	local old_add = self.List_Addons.AddLine
	function new_add(self,...)
		self.Count = (self.Count or 0) + 1
		self:SetTall(20 + self.Count * 16)
		local panel = vgui.Create("DPanel",self)
		function panel:Paint()
		end
		local checkbox = vgui.Create("DCheckBoxLabel",panel)
		checkbox:SetValue(0)
		checkbox:SetPos(2,1)
		local label = vgui.Create("DLabel",panel)
		label:SetPos(20,1)
		label:SetText("Auto -> Run")
		label:SizeToContents()
		
		local button = vgui.Create("DImageButton",panel)
		button:SetPos(82,0)
		button:SetSize(16,16)
		button:SetImage("gui/silkicons/application_go")
		local line = old_add(self,panel,...)
		line.GetAutoLoad = function() return checkbox:GetChecked() end
		return line
	end
	
	self.List_Addons.AddLine = new_add
	self.List_Plugins.AddLine = new_add
	self.List_Extensions.AddLine = new_add
	self.List_Skins.AddLine = new_add
	
	function GetAppStore()
		return self
	end
	
	self.List_Addons:AddLine("SpyMod - What ever lol ...","Stoned")
	self.List_Plugins:AddLine("iTunes Interface - Control iTunes from GMod","Stoned")
	self.List_Extensions:AddLine("AESLua - AES encryption with pure lua","...")
	self.List_Extensions:AddLine("BitLib - Adds the bitlib to GLua","...")
	self.List_Extensions:AddLine("Sha1 - Hashing with pure lua","...")
	self.List_Extensions:AddLine("utilx - Lib created with FP user input","Gbps/Stoned")
	self.List_Extensions:AddLine("debug - extending the default debug lib","Deco/Stoned")
	self.List_Skins:AddLine("Win7 - Windows 7 themed skin","Stoned")
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.CategoryList:StretchToParent(0,0,0,0)
end

function PANEL:Paint()
end
