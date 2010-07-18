PANEL = {}
PANEL.Name = "Editor"
PANEL.Desc = "Edit your lua code on the fly!"
PANEL.TabIcon = "gui/silkicons/application_xp_terminal"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.Toolbar = vgui.Create("DPanelList",self)
	self.Toolbar:SetSpacing(5)
	self.Toolbar:SetPadding(2)
	self.Toolbar:EnableHorizontal(true)
	self.Toolbar:EnableVerticalScrollbar(false)
	self.Toolbar.Paint = function(self)
		draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,100))
	end
	
	self.Editor = vgui.Create("LuaEditor",self)
	self.Editor:SetMultiline(true)
	
	self.Input = vgui.Create("DTextEntry",self)
	self.Input:SetText("")
	self.Input:RequestFocus()
	self.Input.OnEnter = function(self)
	    surface.PlaySound("ambient/machines/keyboard"..math.random(6).."_clicks.wav")
		local str = self:GetValue()
		RunString(str)
		ConPrint(str)
		self:SetText("")
		self:RequestFocus()
	end
	--self.Input:SetContentAlignment(7) --upper left :D
	
	self.Submit = vgui.Create("DButton",self)
	self.Submit:SetText("Run")
	self.Submit.DoClick = function(self)
		local str = self:GetParent().Input:GetValue()
		RunString(str)
		self:GetParent().Input:SetText("")
		self:GetParent().Input:RequestFocus()
	end
	
	self.Tools = self.Tools or {}
	self.Pages = self.Pages or {}
	
	function self:AddTool(img,tooltip,func)
		local tool = vgui.Create("DImageButton")
		tool:SetImage(img)
		tool:SetTooltip(tooltip)
		tool:SetSize(16,16)
		tool.DoClick = func

		table.insert(self.Tools,tool)
		self.Toolbar:AddItem(tool)
	end

	function self:AddToolText(str)
		local spacer = vgui.Create("DLabel")
		spacer:SetText(str)
		spacer:SizeToContents()
		self.Toolbar:AddItem(spacer)
		return spacer
	end
	
	function self:AddPage(name,str)
		local button = vgui.Create("DButton")
		button:SetText(name)
		button:SizeToContents()
		button.Code = str
		button.DoClick = function(button)
			self:SetActive(button)
		end
		button.Paint = function() end
		
		self.Toolbar:AddItem(button)
		button.Spacer = self:AddToolText(" | ")
		table.insert(self.Pages,button)
		self:SetActive(self.Pages[#self.Pages])
	end
	
	function self:SetActive(item)
		SaveTemp()
		if item == nil then
			self.Editor:SetText("")
		end
		for k,page in pairs(self.Pages) do
			if page == item then
				page.Active = true
				self.Editor:SetText(page.Code)
				timer.Simple(0.005,function() page:SetColor(Color(0,200,0,255)) end)
			else
				page.Active = false
				page:SetColor(Color(200,200,200,255))
			end
		end
	end
	
	function SaveTemp()
		for k,page in pairs(self.Pages) do
			if page.Active == true then
				page.Code = self.Editor:GetValue()
			end
		end
	end
	
	function GetCode()
		for k,page in pairs(self.Pages) do
			if page.Active == true then
				return page.Code
			end
		end
	end
	
	function NewPage()	
		self:AddPage("untitled "..(#self.Pages+1),"-- untitled "..(#self.Pages+1).."\n")
	end
	
	function OpenPage()
		self.OpenPanel = vgui.Create("DPanel",self.Editor)
		self.OpenPanel:SetSize(400,300)
		self.OpenPanel:SetVisible(true)
		self.OpenPanel:Center()
		self.OpenPanel.Paint = function(self)
			draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255))
		end
		
		self.OpenLabel = vgui.Create("DLabel",self.OpenPanel)
		self.OpenLabel:SetText("Choose a file to load:")
		self.OpenLabel:SetPos(5,5)
		self.OpenLabel:SizeToContents()
		
		self.OpenButton = vgui.Create("DButton",self.OpenPanel)
		self.OpenButton:SetSize(390,20)
		self.OpenButton:SetText("Open file")
		self.OpenButton:SetPos(5,275)
		self.OpenButton.DoClick = function(button)	
			if self.OpenList:GetSelectedLine() ~= nil then
				local filename = self.OpenList:GetLine(self.OpenList:GetSelectedLine()):GetValue(1)
				local filecode = file.Read("luamenu/"..filename)
				self:AddPage(filename,filecode)
			end
			button:GetParent():Remove()
		end
		
		self.OpenList = vgui.Create("DListView",self.OpenPanel)
		self.OpenList:SetPos(5,25)
		self.OpenList:SetSize(390,250)
		self.OpenList:AddColumn("File")
		
		for k,txt in pairs(file.Find("luamenu/*")) do
			self.OpenList:AddLine(txt)
		end
	end
	
	function SavePage()
		self.SavePanel = vgui.Create("DPanel",self.Editor)
		self.SavePanel:SetSize(400,50)
		self.SavePanel:SetVisible(true)
		self.SavePanel:Center()
		self.SavePanel.Paint = function(self)
			draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255))
		end
		
		self.SaveLabel = vgui.Create("DLabel",self.SavePanel)
		self.SaveLabel:SetText("Enter a filename:")
		self.SaveLabel:SetPos(5,5)
		self.SaveLabel:SizeToContents()
		
		self.SaveInput = vgui.Create("DTextEntry",self.SavePanel)
		self.SaveInput:SetText("")
		self.SaveInput:SetSize(390,20)
		self.SaveInput:SetPos(5,25)
		self.SaveInput:RequestFocus()
		self.SaveInput.OnEnter = function(self)
			local str = self:GetValue()
			SaveTemp()
			local code = GetCode()
			if str:sub(-4) == ".txt" then
				file.Write("luamenu/"..str,code)
			else
				file.Write("luamenu/"..str..".txt",code)
			end
			self:GetParent():Remove()
		end
	end
	
	function ClosePage()
		for k,page in pairs(self.Pages) do
			if page.Active == true then
				
				table.remove(self.Pages,k)
				self.Toolbar:RemoveItem(page)
				self.Toolbar:RemoveItem(page.Spacer)
				self:SetActive(self.Pages[math.min(k-1,1)])
			end			
		end
	end

	function RunPage()
		SaveTemp()
		for k,page in pairs(self.Pages) do
			if page.Active == true then
				RunString(page.Code)
			end
		end
	end

	/*function RunGame()
		SaveTemp()
		for k,page in pairs(self.Pages) do
			if page.Active == true then
				***(page.Code)
			end
		end
	end*/
	
	self:AddTool("gui/silkicons/page_white_add","New (CTRL + N)",NewPage)
	self:AddTool("gui/silkicons/folder_page_white","Open (CTRL + O)",OpenPage) 
	self:AddTool("gui/silkicons/disk","Save (CTRL + S)",SavePage)
	self:AddToolText(" | ")
	self:AddTool("gui/silkicons/page_white_delete","Close tab",ClosePage)
	self:AddTool("gui/silkicons/page_white_go","Run script",RunPage)
	self:AddToolText(" | ")
	--self:AddTool("gui/silkicons/application_go","Run script (game env)",RunGame)
	--self:AddToolText(" | ")
	self:AddPage("untitled 1","-- untitled 1")
	
	LuaMenu.Panels.Editor = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.Toolbar:StretchToParent(0,0,0,self:GetTall()-20)
	self.Editor:StretchToParent(0,20,0,24)
	self.Input:StretchToParent(0,self.Editor:GetTall() + 5 + 20,99,0)
	self.Submit:StretchToParent(self:GetWide() - 100,self.Editor:GetTall() + 5 + 20,0,0)
	for k,tool in pairs(self.Tools) do
		tool.m_Image:SetPos(0,0)
	end
end

function PANEL:Paint()
	--draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
end