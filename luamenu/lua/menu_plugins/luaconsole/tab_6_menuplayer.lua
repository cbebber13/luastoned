PANEL = {}
PANEL.Name = "UserList"
PANEL.Desc = "Check SteamID's and co"
PANEL.TabIcon = "gui/silkicons/user"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.UserList = vgui.Create("DListView",self)
	self.UserList:SetMultiSelect(false)

	self.UserList.IsPlayerOnList = function(self,ply)
		for k,line in pairs(self:GetLines()) do
			if line.Ent == ply then
				return true,line
			end
		end
		return false
	end

	function self:Update()
		--for k,line in pairs(self.UserList:GetLines()) do
			--if !IsValid(line.Ent) then
			--	self.UserList:RemoveLine(line)
			--else
			--	line:SetColumnText(4,line.Ent:SteamID())
			--end
		--end
		self.UserList:Clear()

		for k,ply in pairs(player.GetAll()) do
			--if !self.UserList:IsPlayerOnList(ply) then
				local line = self.UserList:AddLine(ply:Name(),ply:UserID(),ply:EntIndex(),ply:SteamID(),ply:CommunityID(),tostring(ply:IsBot()))
				line.Ent = ply
			--end
		end
	end

	self.UserList:AddColumn("Name")
	self.UserList:AddColumn("UserID"):SetFixedWidth(50)
	self.UserList:AddColumn("EntIndex"):SetFixedWidth(50)
	self.UserList:AddColumn("SteamID"):SetFixedWidth(125)
	self.UserList:AddColumn("Community ID"):SetFixedWidth(125)
	self.UserList:AddColumn("Bot"):SetFixedWidth(35)
	self.UserList.OnRowRightClick = function(userlist)
		local ply = userlist:GetLine(userlist:GetSelectedLine()).Ent

		--if IsValid(ply) then
			local menu = DermaMenu()
			menu:SetParent(self)
			menu:SetPos(self:CursorPos())
			menu:AddOption("Copy Name",function()
				SetClipboardText(ply:Name())
			end)
			menu:AddOption("Copy SteamID",function()
				SetClipboardText(ply:SteamID())
			end)
			menu:AddOption("Copy CommunityID",function()
				SetClipboardText(ply:CommunityID())
			end)
			menu:AddOption("Go To Steam Page",function()
				gui.OpenURL("steamcommunity.com/profiles/"..ply:CommunityID())
			end)
		--end
	end

	self.UpdateButton = vgui.Create("DButton",self)
	self.UpdateButton:SetText("Update")
	self.UpdateButton.DoClick = function(button)
		self:Update()
	end

	LuaMenu.Panel.UserList = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.UserList:StretchToParent(0,0,0,24)
	self.UpdateButton:StretchToParent(0,self.UserList:GetTall() + 5,0,0)
end

function PANEL:Paint()
end
