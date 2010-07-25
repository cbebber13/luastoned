PANEL.Title = "Example App"

-- All the same hooks as normal panels.

function PANEL:Init()
end

function PANEL:Close()
	self.App:Exit() -- calls APP:Destructor
end

function PANEL:Think()
end

function PANEL:Draw()
end