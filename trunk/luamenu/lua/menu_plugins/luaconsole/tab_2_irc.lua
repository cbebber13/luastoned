PANEL = {}
PANEL.Name = "IRC"
PANEL.Desc = "Internet relay chat"
PANEL.TabIcon = "gui/silkicons/new"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.Output = vgui.Create("DListView",self)
	self.Output:AddColumn("TimeStamp"):SetFixedWidth(60)
	self.Output:AddColumn("Message")
	self.Output:SetDataHeight(16)
	
	self.Output.OnRowSelected = function(list,itemid,line)	
		--self:DoClick(itemid,line)	
	end
	self.Output.DoDoubleClick = function(list,itemid,line)
		--self:DoDoubleClick(itemid,line)
	end
	
	self.Input = vgui.Create("DTextEntry",self)
	self.Input:SetText("")
	self.Input:RequestFocus()
	self.Input.OnEnter = function(self)
	    surface.PlaySound("ambient/machines/keyboard"..math.random(6).."_clicks.wav")
		if Irc:IsConnected() == true then
			Irc:Format(self:GetValue())
		else
			Irc:Connect()
			hook.Call("IrcText",nil,"Currently connecting",Irc.Host,"")
		end
		self:SetText("")
		self:RequestFocus()
	end
	
	self.Submit = vgui.Create("DButton",self)
	self.Submit:SetText("Submit")
	self.Submit.DoClick = function(self)
		local str = self:GetParent().Input:GetValue()
		self:GetParent().Input:SetText("")
		self:GetParent().Input:RequestFocus()
	end
	
	hook.Add("IrcText","Shoop",function(name,text,chan)
		local pnl = LuaMenu.Irc.Output:AddLine(tostring(os.date("%I:%M:%S")),name..": "..text)
		pnl.FullText = name..": "..text
	end)
	
	LuaMenu.Panel.Irc = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Output:StretchToParent(0,0,0,24)
	self.Input:StretchToParent(0,self.Output:GetTall() + 5,99,0)
	self.Submit:StretchToParent(self:GetWide() - 100,self.Output:GetTall() + 5,0,0)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
