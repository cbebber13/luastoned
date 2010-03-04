PANEL = {}
PANEL.Name = "Chat"
PANEL.Desc = "Chat"
PANEL.TabIcon = "gui/silkicons/comments"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.Output = vgui.Create("DListView",self)
	self.Output:AddColumn("TimeStamp"):SetFixedWidth(60)
	self.Output:AddColumn("Name"):SetFixedWidth(200)
	self.Output:AddColumn("Message")
	self.Output:SetDataHeight(16)
	
	self.Output.OnRowSelected = function(list,itemid,line)	
		--self:DoClick(itemid,line)	
	end
	self.Output.DoDoubleClick = function(list,itemid,line)
		--self:DoDoubleClick(itemid,line)
	end
	
	function ChatPrint(str,name)
		local pnl = GetError().Output:AddLine(tostring(os.date("%I:%M:%S")),name,str:gsub("\n"," "))
		pnl.FullText = str
	end
	function GetChat()
		return self
	end
	local function ConsoleLineDblClicked(pnl)
		print(pnl.FullText)
	end
	
	hook.Add("ChatText","Shoop",function(str,clr,name)
		local pnl = GetChat().Output:AddLine(tostring(os.date("%I:%M:%S")),name,str:gsub("\n"," "))
		pnl.FullText = str
	end)
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Output:StretchToParent(0,0,0,0)
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
