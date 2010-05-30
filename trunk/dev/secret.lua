local pstable = LuaMenu.PropertySheet:GetTable()
local tab = pstable.Items[8].Tab
local pnl = tab:GetTable().Panel

local pushpnl = vgui.Create("DPanel",pnl)
pushpnl:SetSize(20,20)
pushpnl:SetPos(pnl:GetWide() - 25,-10)
pushpnl:NoClipping(true)
pushpaint = pushpnl.Paint
pushpnl.Paint = function(self)
end

local img = vgui.Create("DImage",pushpnl)
img:SetPos(0,0)
img:SetSize(16,16)
img:SetImage("gui/silkicons/delete")
imgp = img.Paint
img.Paint = function(self)
    imgp(self)
    draw.RoundedBox(0,4,7,8,2,Color(238,102,82,255))
    draw.DrawText("6","Default",5,1,Color(255,255,255,255),ALIGN_LEFT)
end


function SetMenuVar(str,data)
	str = str:gsub("[^%w_]+","")
	local ok,err = pcall(function() data = glon.encode(data) end)
	if !ok then	print("[MenuVar] Error ("..err..")") return end
	file.Write("luaconsole/"..str..".txt",data)
end

function GetMenuVar(str)
	str = str:gsub("[^%w_]+","")
	if file.Exists("luaconsole/"..str..".txt") then
		local data = file.Read("luaconsole/"..str..".txt")
		local ok,err = pcall(function() data = glon.encode(data) end)
		if !ok then	print("[MenuVar] Error ("..err..")") return end
		if type(data) == "string" then
			data = data:Trim()
		end
		return data
	end
end