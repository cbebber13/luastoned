-- Originally RabidToaster's achievment popup <3

local PANEL = {}
function PANEL:Init()
	self.Offset = 0
	self.Direction = 1
	self.Speed = 3
	self.Alive = 5
	self.Slot = 1
	self.Text = ""
	self.Head = ""
	self.Size = {240,94}
	self.TextColor = {255,255,255}
	self.HeadColor = {216,222,211}
	self.Flip = false
	
	if GetConVarNumber("lua_popup_sound") > 0 then
		surface.PlaySound(Sound("achievements/achievement_earned.mp3"))
	end
end

function PANEL:Popup(head,text,dur,headclr,textclr,flip,x,y)
	local gts = surface.GetTextSize
	local tbl = {}
    local newstr = ""
    for k,line in pairs(string.Explode("\n",text)) do
        for i,word in pairs(string.Explode(" ",line)) do       
            if gts(newstr) + gts(word) < ((x or self.Size[1]) - 30) then
                newstr = newstr..word.." "
            else
                table.insert(tbl,newstr)
                newstr = "\n"..word.." "
            end
        end
        table.insert(tbl,newstr)
        newstr = "\n"  
    end
	self.Text = table.concat(tbl)
	self.Head = head
	self.Size = {x,y}
	self.Alive = dur
	self.Flip = flip
	self.TextColor = {textclr.r,textclr.g,textclr.b}
	self.HeadColor = {headclr.r,headclr.g,headclr.b}
end

function PANEL:SetSlot(slot)
	self.Slot = slot
end

function PANEL:GetSlot()
	return self.Slot
end

function PANEL:Think()
	self.Offset = math.Clamp(self.Offset + (self.Direction * 0.005 * self.Speed),0,1) -- FrameTime()
	self:InvalidateLayout()
	
	if self.Direction == 1 and self.Offset == 1 then
		self.Direction = 0
		self.Down = CurTime() + self.Alive
	end
	if self.Down != nil and CurTime() > self.Down then
		self.Direction = -1
		self.Down = nil
	end
	if self.Offset == 0 then
		self.Removed = true
		--self:Remove()
	end
end

function PANEL:PerformLayout()
	local w, h = self.Size[1],self.Size[2]
	
	self:SetSize(w,h)
	if self.Flip == true then
		self:SetPos(ScrW() - w,(h * self.Offset * self.Slot) - h)
	else
		self:SetPos(ScrW() - w,ScrH() - (h * self.Offset * self.Slot))
	end
end

function PANEL:Paint()
	local w, h = self:GetWide(), self:GetTall()
	local a = self.Offset * 255
	
	surface.SetDrawColor(47,49,45,a)
	surface.DrawRect(0,0,w,h)
	
	surface.SetDrawColor(104,106,101,a)
	surface.DrawOutlinedRect(0,0,w,h)
	
	surface.SetDrawColor(255,255,255,a)
	
	--[[if ( self.Image ) then
		surface.SetMaterial( self.Material )
		surface.DrawTexturedRect( 14, 14, 64, 64 )
		
		surface.SetDrawColor( 70, 70, 70, a )
		surface.DrawOutlinedRect( 13, 13, 66, 66 )
	end]]
	
	draw.DrawText(self.Head,"Default14",10,10,Color(self.HeadColor[1],self.HeadColor[2],self.HeadColor[3],a),TEXT_ALIGN_LEFT) -- 88,30
	draw.DrawText(self.Text,"Default",10,26,Color(self.TextColor[1],self.TextColor[2],self.TextColor[3],a),TEXT_ALIGN_LEFT) -- 88,46	
end
vgui.Register("Popup",PANEL)