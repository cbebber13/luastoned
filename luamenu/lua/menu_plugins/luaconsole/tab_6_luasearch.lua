PANEL = {}
PANEL.Name = "LuaSearch"
PANEL.Desc = "Get info about lua functions"
PANEL.TabIcon = "gui/silkicons/zoom"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.Input = vgui.Create("DTextEntry",self)
	self.Input:SetText("Search")
	self.Input:RequestFocus()
	self.Input.OnTextChanged = function(self)
		--local str = self:GetValue()
	end	
	self.Input.OnGetFocus = function(self)
		if self:GetValue() == "Search" then
			self:SetValue("")
		end
	end
	
	self.Submit = vgui.Create("DButton",self)
	self.Submit:SetText("Search")
	self.Submit.DoClick = function(button)
		local str = self.Input:GetValue()
		if str ~= "" and str ~= " " then
			self:Search(str)
		end
	end
	self.Input.OnEnter = self.Submit.DoClick
	
	local DTreeClear = function(tree)
		tree:Remove()
		self.Tree = vgui.Create("DTree",self)
		self.Tree:SetShowIcons(true)
		self.Tree:StretchToParent(0,0,0,74)
		--self.Tree.Clear = treeclear
	end
	
	local SetDTreeClear = function()
		self.Tree.Clear = DTreeClear	
	end
	
	self.Tree = vgui.Create("DTree",self)
	self.Tree:SetShowIcons(true)
	self.Tree.Clear = DTreeClear

	self.Description = vgui.Create("DPanel",self)
	self.Description:SetBackgroundColor(Color(221,221,221,255))

	self.DescriptionText = vgui.Create("DLabel",self.Description)
	self.DescriptionText:SetPos(5,5)
	self.DescriptionText:SetText("Select a function.")
	self.DescriptionText:SetTextColor(Color(0,0,0,255))
	self.DescriptionText:SizeToContents()
	
	local function FixString(str)
		local tbl = {}
		for i=1,str:len() do
			local char = str:sub(i,i)
			if char:byte() > 160 then
				char = string.char(char:byte()-100)
			end
			table.insert(tbl,char)
		end
		return table.concat(tbl,"")
	end
	
	function self:Search(str)	
		http.Get("http://luasearch.overvprojects.nl/love.php?keywords="..str,"",function(c,s) -- love.php / json.php
			--local tbl = Json.Decode(c)
			local tbl = {}
			for i=1,c:len() do
				local char = c:sub(i,i)
				if (char:upper() == char and char:byte() > 64 and char ~= "{" and char ~= "}") then -- this is a hacky way to get keyvaluestotable work with uppercase letters in the key.
					char = string.char(char:byte()+100)
				end
				table.insert(tbl,char)
			end
			tbl = KeyValuesToTable(table.concat(tbl,""))
			
			self.Tree:Clear()
			SetDTreeClear()
			
			local objects = self.Tree:AddNode("Objects")
			for k,obj in pairs(tbl.objects) do
				if type(obj) == "table" then
					local node = objects:AddNode(FixString(k))
					for i,sub in pairs(obj) do
						local func = node:AddNode(string.gsub("["..string.upper(FixString(sub.state)).."]".." "..FixString(i).."("..FixString(sub.arguments)..")","\n",""))
						func.Function = FixString(i)
						func.ReturnValue = FixString(sub.returns)
						if func.ReturnValue == "" then func.ReturnValue = "Nothing" end
						func.Description = FixString(sub.description)
						func.DoClick = function(node_obj)
							self.DescriptionText:SetText(func.Description.."\nReturns: "..func.ReturnValue, func.Function, "Close")
							self.DescriptionText:SizeToContents()
						end
						func.ShowIcons = function() return false end
					end
				end
			end
			
			local libraries = self.Tree:AddNode("Libraries")
			for k,lib in pairs(tbl.libraries) do
				if type(lib) == "table" then
					local node = libraries:AddNode(FixString(k))
					for i,sub in pairs(lib) do
						local func = node:AddNode(string.gsub("["..string.upper(FixString(sub.state)).."]".." "..FixString(i).."("..FixString(sub.arguments)..")","\n",""))
						func.Function = FixString(i)
						func.ReturnValue = FixString(sub.returns)
						if func.ReturnValue == "" then func.ReturnValue = "Nothing" end
						func.Description = FixString(sub.description)
						func.DoClick = function(node_obj)
							self.DescriptionText:SetText(func.Description.."\nReturns: "..func.ReturnValue, func.Function, "Close")
							self.DescriptionText:SizeToContents()
						end
						func.ShowIcons = function() return false end
					end
				end
			end
			
			local hooks = self.Tree:AddNode("Hooks")
			for k,hook in pairs(tbl.hooks) do
				if(type(hook) == "table") then
					local node = hooks:AddNode(FixString(k))
					for i,sub in pairs(hook) do
						local func = node:AddNode(string.gsub("["..string.upper(FixString(sub.state)).."]".." "..FixString(i).."("..FixString(sub.arguments)..")","\n",""))
						func.Function = FixString(i)
						func.ReturnValue = FixString(sub.returns)
						if func.ReturnValue == "" then func.ReturnValue = "Nothing" end
						func.Description = FixString(sub.description)
						func.DoClick = function(node_obj)
							self.DescriptionText:SetText(func.Description.."\nReturns: "..func.ReturnValue, func.Function, "Close")
							self.DescriptionText:SizeToContents()
						end
						func.ShowIcons = function() return false end
					end
				end
			end
		end)	
	end

	LuaMenu.Panel.LuaSearch = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Tree:StretchToParent(0,0,0,74) -- 24
	self.Description:StretchToParent(0,self.Tree:GetTall() + 5,0,24)
	self.Input:StretchToParent(0,self.Tree:GetTall() + self.Description:GetTall() + 10,99,0) -- 5
	self.Submit:StretchToParent(self:GetWide() - 100,self.Tree:GetTall() + self.Description:GetTall() + 10,0,0) -- 5
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end
