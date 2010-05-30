PANEL = {}
PANEL.Name = "Server Browser"
PANEL.Desc = "Search for specific game servers"
PANEL.TabIcon = "gui/silkicons/application_view_columns"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)	
	
	self.ServerList = vgui.Create("DListView",self)
	self.ServerList:SetMultiSelect(false)
	self.ServerList:AddColumn("Hostname"):SetFixedWidth(400)
	self.ServerList:AddColumn("Game"):SetFixedWidth(150)
	self.ServerList:AddColumn("Players"):SetFixedWidth(50)
	self.ServerList:AddColumn("Map")
	self.ServerList:AddColumn("IP"):SetFixedWidth(150)
	
	self.SearchBar = vgui.Create("DTextEntry",self)
	self.SearchBar:RequestFocus()
	self.SearchBar.OnTextChanged = function(self)
	    surface.PlaySound("ambient/machines/keyboard"..math.random(6).."_clicks.wav")
		--SteamServer:Search(self:GetValue())
	end
	
	self.UpdateButton = vgui.Create("DButton",self)
	self.UpdateButton:SetText("Refresh")
	self.UpdateButton.DoClick = function(self)
		SteamServer:Update("0.0.0.0","0")
	end
	
	self.OptionButton = vgui.Create("DButton",self)
	self.OptionButton:SetText("Options")
	self.OptionButton.DoClick = function() 
    	local menu = DermaMenu()
    	local submenu = menu:AddSubMenu("Display Mode >")
			submenu:AddOption("1 - Short",function()
			end)
			submenu:AddOption("2 - Full",function()
			end)
			submenu:AddOption("3 - Advanced",function()
			end)	
        menu:Open()
	end
	--self:Update("0.0.0.0","0")
	
	function GetServerList()
		return self
	end
	
	hook.Add("AddServer","Shoop",function(host,game,players,map,ip)
		self.ServerList:AddLine(host,game,players,map,ip)
	end)
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.ServerList:StretchToParent(0,0,0,43)
	self.SearchBar:StretchToParent(0,self:GetTall() - 39,0,19)	
	self.UpdateButton:StretchToParent(0,self:GetTall() - 20,self:GetWide()/2-1,0)
	self.OptionButton:StretchToParent(self:GetWide()/2,self:GetTall() - 20,0,0)
end

function PANEL:Paint()
end