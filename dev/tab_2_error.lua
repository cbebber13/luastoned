PANEL = {}
PANEL.Name = "Error"
PANEL.Desc = "All kinds of errors"
PANEL.TabIcon = "gui/silkicons/error"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.Output = vgui.Create("DListView",self)
	self.Output:AddColumn("TimeStamp"):SetFixedWidth(60)
	self.Output:AddColumn("Type"):SetFixedWidth(100)
	self.Output:AddColumn("Error")
	self.Output:SetDataHeight(16)
	
	self.Output.OnRowSelected = function(list,itemid,line)	
		--self:DoClick(itemid,line)	
	end
	self.Output.DoDoubleClick = function(list,itemid,line)
		--self:DoDoubleClick(itemid,line)
	end
	
	function ErrorPrint(str,typ)
		local pnl = GetError().Output:AddLine(tostring(os.date("%I:%M:%S")),typ,str:gsub("\n"," "))
		pnl.FullText = str
	end
	function GetError()
		return self
	end
	local function ConsoleLineDblClicked(pnl)
		print(pnl.FullText)
	end
	
	hook.Add("ErrorText","Shoop",function(str,typ,clr)
		local pnl = GetError().Output:AddLine(tostring(os.date("%I:%M:%S")),typ,str:gsub("\n"," "))
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
