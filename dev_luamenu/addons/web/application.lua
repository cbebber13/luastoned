local uuid_MainScreen = APP:LoadPanel("mainscreen.lua")

APP.Name = "Example"
APP.Author = "Haza"
APP.License = "MIT"
APP.Singleton = false
APP.Style = menu.WINDOWED -- or menu.TABBED

function APP:Constructor()
	self.Screen = vgui.Create(uuid_MainScreen)
end

function APP:Destructor()
	
end

function APP:Think()
	
end