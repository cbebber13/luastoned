PANEL = {}
PANEL.Name = "Console"
PANEL.Desc = "Lua Console"
PANEL.TabIcon = "gui/silkicons/application_view_detail" -- gui/silkicons/application_xp_terminal

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.TempCmd = {}
	self.TempIndex = 0
	self.KeyDown = false
	self.MouseDone = true

	self.Output = vgui.Create("DListView",self)
	self.Output:AddColumn("TimeStamp"):SetFixedWidth(60)
	self.Output:AddColumn("Message")
	self.Output:SetDataHeight(16)
	self.Output:SetMultiSelect(false)
	
	self.Output.DoDoubleClick = function(list,itemid,line)
		local cmd = line:GetValue(2)
		MenuCommand(cmd)
		ConPrint(cmd)
	end
	
	self.Output.OnRowRightClick = function(id,lineid,line)
		local menu = DermaMenu()
		menu:AddOption("Copy to clipboard >",function()
			SetClipboardText(line:GetValue(2))
		end)
		menu:AddOption("Copy to command line >",function()
			self.Input:SetText(line:GetValue(2))
		end)
		menu:Open()
	end
	
	self.Input = vgui.Create("DTextEntry",self)
	self.Input:SetText("")
	self.Input:RequestFocus()
	self.Input.OnEnter = function(self)
	    surface.PlaySound("ambient/machines/keyboard"..math.random(6).."_clicks.wav")
		local str = self:GetValue()
		MenuCommand(str)
		ConPrint(Color(0,255,0),"> ",Color(255,255,255),str)
		self:SetText("")
		self:RequestFocus()
		if str ~= "" and str ~= " " then
			self:GetParent().TempIndex = table.insert(self:GetParent().TempCmd,str) + 1
		end
	end
	--self.Input:SetContentAlignment(7) --upper left :D
	
	self.Submit = vgui.Create("DButton",self)
	self.Submit:SetText("Submit")
	self.Submit.DoClick = function(self)
		local str = self:GetParent().Input:GetValue()
		MenuCommand(str)
		ConPrint(Color(0,255,0),"> ",Color(255,255,255),str)
		self:GetParent().Input:SetText("")
		self:GetParent().Input:RequestFocus()
		if str ~= "" and str ~= " " then
			self:GetParent().TempIndex = table.insert(self:GetParent().TempCmd,str) + 1
		end
	end
	
	function ConPrint(...)
		local pnl = LuaConsole().Output
		local line = pnl:AddLine(tostring(os.date("%I:%M:%S")),"")
		local line_paint = line.Paint
		local line_markup = {}
		for k,obj in pairs({...}) do
			if type(obj) == "table" then
				table.insert(line_markup,string.format("<color=%i,%i,%i,255>",obj.r,obj.g,obj.b))
			elseif type(obj) == "string" then
				if obj:sub(1,-2):find("\n") then
					local part1 = obj:sub(1,obj:find("\n")):sub(1,-2)
					local part2 = obj:sub(obj:find("\n"),-1):sub(2,-1)
					table.insert(line_markup,string.format("%s</color>",part1))
					--ConPrint(unpack(string.Explode("$",table.concat({...},"$",k))))
				else
					table.insert(line_markup,string.format("%s</color>",obj))
				end
			else
				ErrorNoHalt("Fatal Parse Error: "..tostring(obj))
			end
		end
		line.Markup = markup.Parse(table.concat(line_markup,""))

		line.Paint = function(self)
			line_paint(self)
			if self.Markup then
				self.Markup:Draw(62,1,0,0)
			end
		end
			
		--pnl.FullText = str
		pnl:ClearSelection()
		timer.Simple(0.01,function()
			local pnl = LuaConsole().Output
			pnl.VBar:SetScroll(math.huge)
		end)
	end
	
	function LuaConsole()
		return self
	end
	local function ConsoleLineDblClicked(pnl)
		print(pnl.FullText)
	end
	
	hook.Add("ConsoleText","Shoop",function(tbl)
		ConPrint(unpack(tbl))
	end)
end

function PANEL:Think()
	if #self.TempCmd < 1 then return end
	if input.IsKeyDown(KEY_UP) and self.KeyDown == false then
		self.TempIndex = math.Clamp(self.TempIndex - 1,1,#self.TempCmd)
		self.Input:SetText(self.TempCmd[self.TempIndex])
		self.KeyDown = true
	elseif input.IsKeyDown(KEY_DOWN) and self.KeyDown == false then
		self.TempIndex = math.Clamp(self.TempIndex + 1,1,#self.TempCmd)
		self.Input:SetText(self.TempCmd[self.TempIndex])
		self.KeyDown = true
	end
	if !input.IsKeyDown(KEY_UP) and !input.IsKeyDown(KEY_DOWN) then
		self.KeyDown = false
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Output:StretchToParent(0,0,0,24)
	self.Input:StretchToParent(0,self.Output:GetTall() + 5,99,0)
	self.Submit:StretchToParent(self:GetWide() - 100,self.Output:GetTall() + 5,0,0)
end

function PANEL:Paint()
	if self.Input:HasFocus() and #self.TempCmd > 0 and self.MouseDone == true then
		--self:MouseCapture(true)
		draw.RoundedBox(4,0,self:GetTall(),200,4 + #self.TempCmd*10,Color(255,255,255,255))
		for k,cmd in pairs(self.TempCmd) do
			draw.DrawText(cmd,"Default",2,self:GetTall() + (k-1)*10,Color(0,0,0),0)
		end
	end
end

function PANEL:OnMousePressed(code)
	local pos = gui.MousePos()
	print(pos)
	if pos.x >= 600 and pos.x <= 800 then -- in the box :P
		if pos.y >= 762 and pos.y <= 774 then-- in the first row
			self.MouseDone = false
		end
	end
end
