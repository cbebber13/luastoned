PANEL = {}
PANEL.Name = "Web Browser"
PANEL.Desc = "Browse the web!"
PANEL.TabIcon = "gui/silkicons/application"

-- Settings
local iButtonSize = 24
local iButtonSpacing = 5

function PANEL:Init()
	self.FHist = {}
	self.History = {}
	self.Settings = {}
	self.ShouldLog = true
	self.Downloaded = {}
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
	self.AddressBar:SetValue(self.Settings["Homepage"])
	
	self.Browser.StatusChanged = function(panel,url)
		-- The text in the status bar has changed
		self.StatusLabel:SetText(url)
		self.StatusLabel:SizeToContents()
	end

	self.Browser.ProgressChanged = function(panel,progress)
		-- Loading progress changed
		--print(progress)
	end

	self.Browser.FinishedURL = function(panel,url)
		-- Finished loading a specific URL
		if self.ShouldLog then		
			table.insert(self.VisitedSites,url)
		end
		--print(url)
	end

	self.Browser.OpeningURL = function(panel,url,target)
		-- Page wants to open URL.
		-- Return true to not load URL.
		if url:find("s3.garrysmod.org") and !table.HasValue(self.Downloaded,url) then -- download
			table.insert(self.Downloaded,url)
			InstallAddon(url)
		end
		if !self.AddressBar:HasFocus() then
			self.AddressBar:SetValue(url)
		end
		if url ~= self.FHist[#self.FHist] and url ~= self.History[#self.History] then
			self.FHist = {}
		end
		if url == self.FHist[#self.FHist] then
			table.remove(self.FHist,#self.FHist)
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
	self.Refresh:SetImage("gui/chromium/reload_noborder")
	self.Refresh.DoClick = function(button)
		self.Browser:Refresh()
	end
	self.Refresh:SetTooltip("Reload Page")
	
	self.Stop = vgui.Create("DImageButton",self)
	self.Stop:SetImage("gui/chromium/stop_noborder")
	self.Stop.DoClick = function(button)
		self.Browser:Stop()
	end
	self.Stop:SetTooltip("Stop Page Load")
	
	self.FavButton = vgui.Create("DImageButton",self)
	self.FavButton:SetImage"gui/chromium/menu_bookmark"
	self.FavButton.DoClick = function(button)
		local menu = DermaMenu()
		local favCount = 0
		for k,fav in pairs(self.Settings["Favorites"]) do
			if(type(fav[2]) == "string") then
				menu:AddOption(fav[2],function()
					local url = fav[1]
					if url:sub(1,7) ~= "http://" and url:sub(1,8) ~= "https://" then
						url = "http://"..url
					end
					self.Browser:OpenURL(url)
				end)
				favCount = favCount + 1
			end
		end
		
		if(favCount > 0) then
			menu:AddSpacer()
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
				table.insert(self.Settings["Favorites"], {text1:GetValue() or "", text2:GetValue() or ""})
				file.Write("luamenu/browser.txt", glon.encode(self.Settings))
				frame:Close()
			end
			text2.OnEnter = text1.OnEnter
			local button = vgui.Create("DButton", frame)
			button:SetPos(2, 29 + text1:GetTall() + text2:GetTall())
			button:SetWide(296)
			button:SetText("Add")
			button.DoClick = text1.OnEnter
			frame:SetSize(300, 33 + text1:GetTall() + text2:GetTall() + button:GetTall())
			frame:Center()
		end)
		
		local menu2 = menu:AddSubMenu("Remove Favorite")
		if #self.Settings["Favorites"] > 0 then
			for k, v in pairs(self.Settings["Favorites"]) do
				if(type(v[2]) == "string") then
					menu2:AddOption(v[2],function()
						table.remove(self.Settings["Favorites"],k)
						file.Write("luamenu/browser.txt", glon.encode(self.Settings))
					end)
				end
			end
		else
			menu2:AddOption("None")
		end
		menu:SetPos(gui.MouseX(), gui.MouseY())
		menu:Open()
	end
	self.FavButton:SetTooltip("Favorites")
	
	self.Forward = vgui.Create("DImageButton",self)
	self.Forward:SetImage("gui/chromium/forward_noborder")
	self.Forward.DoClick = function(button)
		if !self.FHist[#self.FHist] then return end
		table.insert(self.History,self.FHist[#self.FHist])
		self.Browser:OpenURL(self.FHist[#self.FHist])
		table.remove(self.FHist,#self.FHist)
	end
	self.Forward:SetTooltip("Forward")
	
	self.Back = vgui.Create("DImageButton",self)
	self.Back:SetImage("gui/chromium/back_noborder")
	self.Back.DoClick = function(button)
		if !self.History[#self.History] then return end
		table.insert(self.FHist,self.Browser.URL)
		self.Browser:OpenURL(self.History[#self.History])
		table.remove(self.History,#self.History)
		table.remove(self.History,#self.History)
	end
	self.Back:SetTooltip("Backward")
	
	--[[ Button layout ]]--
	local x = iButtonSpacing
	
	self.Back:SetPos(x,iButtonSpacing)
	self.Back:SetSize(iButtonSize,iButtonSize)
	
	x = x + iButtonSize + iButtonSpacing
	
	self.Forward:SetPos(x,iButtonSpacing)
	self.Forward:SetSize(iButtonSize,iButtonSize)	
	
	x = x + iButtonSize + iButtonSpacing * 3
	
	self.Refresh:SetPos(x,iButtonSpacing)
	self.Refresh:SetSize(iButtonSize,iButtonSize)
	
	x = x + iButtonSize + iButtonSpacing
	
	self.Stop:SetPos(x,iButtonSpacing)
	self.Stop:SetSize(iButtonSize,iButtonSize)
	
	x = x + iButtonSize + iButtonSpacing
	
	self.FavButton:SetPos(x,iButtonSpacing)
	self.FavButton:SetSize(iButtonSize,iButtonSize)
	
	self.AddressBarX = x + iButtonSize + iButtonSpacing	
	
	LuaMenu.Panel.WebBrowser = self
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.AddressBar:StretchToParent(self.AddressBarX,iButtonSpacing,200,self:GetTall() - iButtonSpacing - iButtonSize)
	self.SearchBar:StretchToParent(self.AddressBarX + iButtonSpacing + self.AddressBar:GetWide(),iButtonSpacing,iButtonSpacing,self:GetTall() - iButtonSpacing - iButtonSize)

	self.Refresh.m_Image:SetPos(0,0)
	self.Stop.m_Image:SetPos(0,0)
	self.Forward.m_Image:SetPos(0,0)
	self.Back.m_Image:SetPos(0,0)
	self.FavButton.m_Image:SetPos(0,0)
	
	self.Browser:StretchToParent(0,iButtonSpacing + iButtonSize + iButtonSpacing + iButtonSpacing,0,28)
	self.StatusBar:StretchToParent(0,iButtonSpacing + iButtonSize + iButtonSpacing + iButtonSpacing + self.Browser:GetTall() + iButtonSpacing,0,0)
end

function PANEL:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), iButtonSpacing + iButtonSize + iButtonSpacing, Color(32, 32, 32, 64))
end

function PANEL:Think()
end