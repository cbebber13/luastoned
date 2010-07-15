PANEL = {}
PANEL.Name = "Chat"
PANEL.Desc = "Chat"
PANEL.TabIcon = "gui/silkicons/comments"

function PANEL:Init()
	self.UserName = GetMenuVar("globalchat_name") or Derma_StringRequest("What's your Name?","Please enter your Name for the global chat.","User"..math.random(9)..math.random(9)..math.random(9),function(str)
		GetChat().UserName = str
		SetMenuVar("globalchat_name",str)
	end)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	local function Update(c,s)
		local i = 31
		for name,str in string.gmatch(c,"([%w_]-)@([%w%s%p]-)~") do
			i = i - 1
			if self.Output.VBar:GetScroll() == self.Output.VBar.CanvasSize then -- thanks to tobba
				timer.Simple(0,function(self) self.Output.VBar:SetScroll(self.Output.VBar.CanvasSize) end,self)
			end
			if !self.Output:GetLines()[i] then
				self.Output:AddLine(name,str:gsub("\n"," "))
			else
				self.Output:GetLines()[i]:SetColumnText(1, name)
				self.Output:GetLines()[i]:SetColumnText(2, str:gsub("\n"," "))
			end
		end
	end

	self.Output = vgui.Create("DListView",self)
	self.Output:AddColumn("Name"):SetFixedWidth(200)
	self.Output:AddColumn("Message")
	self.Output:SetDataHeight(16)
	
	self.Input = vgui.Create("DTextEntry",self)
	self.Input:SetText("")
	self.Input:RequestFocus()
	self.Input.OnEnter = function(inp)
		local str = inp:GetValue()
		inp:SetText("")
		inp:RequestFocus()
		if str ~= "" and str ~= " " then
			str = str:gsub("~","-")
			str = str:gsub("@","[at]")
			http.Get("http://gmod.luastoned.com/chat.php?name="..self.UserName.."&str="..str:gsub(" ","+"),"",Update)
		end
	end
	
	hook.Add("GlobalChat","Shoop",function(name,str)
		local pnl = GetChat().Output:AddLine(name,str:gsub("\n"," "))
	end)
	
	timer.Create("GlobalChatUpdate",10,0,function()
		http.Get("http://gmod.luastoned.com/chat.php","",Update)
	end)
	LuaMenu.Panel.Chat = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Output:StretchToParent(0,0,0,24)
	self.Input:StretchToParent(0,self.Output:GetTall() + 5,0,0)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
