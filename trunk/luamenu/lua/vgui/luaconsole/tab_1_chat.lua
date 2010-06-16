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
	
	self.ChatData = {}	
	local function Update(c,s)
		for name,str in string.gmatch(c,"([%w_]-)@([%w%s%p]-)~") do
			if !table.HasValue(self.ChatData,str) then
				self.Output:AddLine(name,str:gsub("\n"," "))
				table.insert(self.ChatData,str)
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
	self.Input.OnEnter = function(self)
		local str = self:GetValue()
		self:SetText("")
		self:RequestFocus()
		if str ~= "" and str ~= " " then
			http.Get("http://luastoned.com/gmod/chat.php?name="..GetChat().UserName.."&str="..str:gsub(" ","+"),"",Update)
		end
	end
	
	function GetChat()
		return self
	end
	
	hook.Add("GlobalChat","Shoop",function(name,str)
		local pnl = GetChat().Output:AddLine(name,str:gsub("\n"," "))
	end)
	
	timer.Create("GlobalChatUpdate",30,0,function()
		http.Get("http://luastoned.com/gmod/chat.php","",Update)
	end)
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Output:StretchToParent(0,0,0,24)
	self.Input:StretchToParent(0,self.Output:GetTall() + 5,0,0)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
