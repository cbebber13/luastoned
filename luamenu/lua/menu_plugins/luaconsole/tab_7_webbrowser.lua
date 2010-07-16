PANEL = {}
PANEL.Name = "Web Browser"
PANEL.Desc = "Browse the web!"
PANEL.TabIcon = "gui/silkicons/application"

function PANEL:Init()
	self.Forward = {}
	self.History = {}
	self.Settings = {}
	self.ShouldLog = true
	self.VisitedSites = {}
	if file.Exists("luamenu/browser.txt") then
		self.Settings = glon.decode(file.Read("luamenu/browser.txt"))
	else
		self.Settings = {
			["Homepage"] = "http://www.facepunch.com",
			["Favorites"] = {
				"http://www.facepunch.com",
				"http://www.google.com",
			},
		}
		file.Write("luamenu/browser.txt",glon.encode(self.Settings))
	end

	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.AddressBar = vgui.Create("DTextEntry",self)
	self.AddressBar.OnEnter = function(bar)
		local str = bar:GetValue()
		if str:sub(1,7) ~= "http://" and str:sub(1,8) ~= "https://" then
			str = "http://"..str
		end
		bar:SetValue(str)
		self.Browser:OpenURL(str)
	end
	
	self.SearchBar = vgui.Create("DTextEntry",self)
	self.SearchBar:SetText("Google")
	self.SearchBar.OnEnter = function(bar)
		local str = bar:GetValue()
		bar:SetValue("")
		self.Browser:OpenURL("http://www.google.com/#q="..str)
	end	
	self.SearchBar.OnGetFocus = function(self)
		if self:GetValue() == "Google" then
			self:SetValue("")
		end
	end
	
	self.Browser = vgui.Create("HTML",self)
	self.Browser:OpenURL(self.Settings["Homepage"])
	
	self.Browser.StatusChanged = function(panel,url)
		-- The text in the status bar has changed
		self.StatusLabel:SetText(url)
		self.StatusLabel:SizeToContents()
	end

	self.Browser.ProgressChanged = function(panel,progress)
		-- Loading progress changed
		print(progress)
	end

	self.Browser.FinishedURL = function(panel,url)
		-- Finished loading a specific URL
		if self.ShouldLog then		
			table.insert(self.VisitedSites,url)
		end
		print(url)
	end

	self.Browser.OpeningURL = function(panel,url,target)
		-- Page wants to open URL.
		-- Return true to not load URL.
		if !self.AddressBar:HasFocus() then
			self.AddressBar:SetValue(url)
		end
		if url ~= self.Forward[#self.Forward] and url ~= self.History[#self.History] then
			self.Forward = {}
		end
		if url == self.Forward[#self.Forward] then
			table.remove(self.Forward,#self.Forward)
		end
		table.insert(self.History,url)
	end
	
	local StatusColor1, StatusColor2, StatusColor3 = Color(135,135,135,255), Color(175,175,175,255), Color(67,255,10,255) 
	
	self.StatusBar = vgui.Create("DPanel",self)
	self.StatusBar.Paint = function(bar)
		draw.RoundedBox(4,0,0,bar:GetWide(),bar:GetTall(),StatusColor1)
		local loadwide = bar:GetWide() / 8
		local loadheight = bar:GetTall() - 4
		draw.RoundedBox(4,bar:GetWide() - loadwide - 2,2,loadwide,loadheight,color_black)
		draw.RoundedBox(4,bar:GetWide() - loadwide - 1,3,loadwide - 2,loadheight - 2,StatusColor2)
		draw.RoundedBox(4,bar:GetWide() - loadwide - 1,3,loadwide - 2,loadheight - 2,StatusColor3)
	end
	
	self.StatusLabel = vgui.Create("DLabel",self.StatusBar)
	self.StatusLabel:SetText("")
	self.StatusLabel:SizeToContents()
	self.StatusLabel:SetPos(5,-5)
	self.StatusLabel:CenterVertical()
	self.StatusLabel:SetColor(color_white)
	self.StatusLabel:SetExpensiveShadow(1,color_black)
	
	self.Refresh = vgui.Create("DImageButton",self)
	self.Refresh:SetImage("gui/silkicons/arrow_refresh")
	self.Refresh.DoClick = function(button)
		self.Browser:Refresh()
	end
	self.Refresh:SetTooltip("Refresh current site")
	
	self.Stop = vgui.Create("DImageButton",self)
	self.Stop:SetImage("gui/silkicons/check_off")
	self.Stop.DoClick = function(button)
		self.Browser:Stop()
	end
	self.Stop:SetTooltip("Stop loading current page")
	
	self.FavButton = vgui.Create("DImageButton",self)
	self.FavButton:SetImage"gui/silkicons/star"
	self.FavButton.DoClick = function(button)
		local menu = DermaMenu()
		for k,fav in pairs(self.Settings["Favorites"]) do
			menu:AddOption(fav[2],function()
				local url = fav[1]
				if url:sub(1,7) ~= "http://" and url:sub(1,8) ~= "https://" then
					url = "http://"..url
				end
				self.Browser:OpenURL(url)
			end)
		end
		
		menu:AddOption("Add Favorite",function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Add Favorite - Press enter to add")
			frame:MakePopup()
			local text1 = vgui.Create("DTextEntry", frame)
			text1:SetPos(2, 25)
			text1:SetWide(296)
			text1:SetValue(self.Browser.URL or "")
			local text2 = vgui.Create("DTextEntry", frame)
			text2:SetPos(2, 27 + text1:GetTall())
			text2:SetWide(296)
			text2:SetValue("Name of favorite")
			text1.OnEnter = function()
				table.insert(self.Settings["Favorites"], {text1:GetValue(), text2:GetValue()})
				file.Write("luamenu/browser.txt", glon.encode(self.Settings))
				frame:Close()
			end
			text2.OnEnter = text1.OnEnter
			frame:SetSize( 300, 31 + text1:GetTall() + text2:GetTall() )
			frame:Center()
		end)
		local menu2 = menu:AddSubMenu("Remove Favorite")
		if #self.Favorites > 0 then
			for k, v in pairs(self.Favorites) do
				menu2:AddOption(v[2],function()
					table.remove(self.Settings["Favorites"],k)
					file.Write("luamenu/browser.txt", glon.encode(self.Settings))
				end)
			end
		else
			menu2:AddOption("None")
		end
		menu:Open()
	end
	self.FavButton:SetTooltip("Favorites")
	
	self.Forward = vgui.Create("DImageButton",self)
	self.Forward:SetImage("gui/silkicons/arrow_right")
	self.Forward.DoClick = function(button)
		if !self.Forward[#self.Forward] then return end
		table.insert(self.History,self.Forward[#self.Forward])
		self.Browser:OpenURL(self.Forward[#self.Forward])
		table.remove(self.Forward,#self.Forward)
	end
	self.Forward:SetTooltip("Forward")
	
	self.Back = vgui.Create("DImageButton",self)
	self.Back:SetImage("gui/silkicons/arrow_left")
	self.Back.DoClick = function(button)
		if !self.History[#self.History] then return end
		table.insert(self.Forward,self.Browser.URL)
		self.Browser:OpenURL(self.History[#self.History])
		table.remove(self.History,#self.History)
		table.remove(self.History,#self.History)
	end
	self.Back:SetTooltip("Back")
	
	/*self.URLBar.OnGetFocus = function( panel )
	
		local x,y = panel:GetPos()
		local Menu = DermaMenu()
		Menu:SetParent( self.Frame )
		Menu:SetPos( x, y + panel:GetTall() )
		
		for k,v in ipairs( self.VisitedSites ) do		
			if k <= 6 then			
				Menu:AddOption( v, function()				
					self.ShouldLog = false
					self.WebKit:OpenURL( v )					
				end )				
			end
		end		
		timer.Simple( 3, function()		
			if IsValid( Menu ) then			
				Menu:Remove()				
			end			
		end )		
	end*/
	
	self.Refresh:SetPos(45,5)
	self.Refresh:SetSize(16,16)
	self.Refresh.m_Image:SetPos(0,0)
	self.Stop:SetPos(65,5)
	self.Stop:SetSize(16,16)
	self.Stop.m_Image:SetPos(0,0)
	self.Forward:SetPos(25,5)
	self.Forward:SetSize(16,16)
	self.Forward.m_Image:SetPos(0,0)
	self.Back:SetPos(5,5)
	self.Back:SetSize(16,16)
	self.Back.m_Image:SetPos(0,0)
	self.FavButton:SetPos(85,5)
	self.FavButton:SetSize(16,16)
	self.FavButton.m_Image:SetPos(0,0)
	
	LuaMenu.Panel.WebBrowser = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.AddressBar:StretchToParent(120,5,120,self:GetTall() - 24)
	self.SearchBar:StretchToParent(self.AddressBar:GetWide(),5,5,self:GetTall() - 24)
	--self.Refresh:StretchToParent()
	--self.Stop:StretchToParent()
	--self.Forward:StretchToParent()
	--self.Back:StretchToParent()
	--self.FavButton:StretchToParent()
	self.Browser:StretchToParent(0,24,0,24)
	self.StatusBar:StretchToParent(0,self.Browser:GetTall() + 29,0,0)
end

function PANEL:Paint()
end