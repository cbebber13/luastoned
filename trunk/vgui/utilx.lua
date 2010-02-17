-----------------------------------
-- utilx
-- A project stared by Gbps
-- expanded with community input
-----------------------------------

utilx = {}
utilx.Version = 1.0

--------------------
--      Meta      --
--------------------

local meta = FindMetaTable("Player")  
if (!meta) then return end

--[[
User: blackops7799
Name: GetUserGroup()
Usage:
	if player.GetByID(1):GetUserGroup() == "<group name>" then
		-- do something
	end
]]

function meta:GetUserGroup()
	return self:GetNetworkedString("UserGroup")  
end

--[[
User: Python1320
Name: IsStuck() - Taken from Source SDK, doesn't fully work though. Just throwing ideas.
Usage:
	<missing>
]]

function meta:IsStuck()
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos()
	tracedata.mask = MASK_PLAYERSOLID or 33636363
	tracedata.filter = self
	local trace = util.TraceEntity(tracedata,self)
	return trace.StartSolid
end

---------------------
--      utilx      --
---------------------

--[[
User: Kogitsune
Name: InSet(object:value,vararg list ...) - used to determine if value is inside the list of parameters.
Usage:
	if utilx.InSet(ent:GetClass(),"prop_door_rotating","player","prop_vehicle_jeep") then
		ent:Remove() 
	end
]]

function utilx.InSet(val,...)
	local k, v
	for k, v in ipairs{...} do
		if v == val then
			return true
		end
	end
	return false
end

--[[
User: Kogitsune
Name: HasBit(value,bit) - used to determine if the bit value contains the mask bit.
Usage:
	local a,b,c,d,firemodes,mask

	a = 0x01
	b = 0x02
	c = 0x04
	d = 0x08

	firemodes = a & b & d
	
	if utilx.HasBit(firemodes,c) then
		-- do something
	end	
]]

function utilx.HasBit(value,bit)
	return (value & bit) == bit
end

--[[
User: Kogitsune
Name: SimplePointEntity(string:class) - Creates a simple point entity with no special methods (pretty much stolen from thomasfn, I believe)
Usage:
	utilx.SimplePointEntity("info_player_zombie")
	utilx.SimplePointEntity("info_player_human")
]]

function utilx.SimplePointEntity(class)
	local t	
	t = { }	
	t.Type = "point"
	t.Base = "base_point"
	t.Data = {}
	
	function t:SetKeyValue(k,v)
		self.Data[k] = v
	end
	
	function t:GetKeyValue(k)
		return self.Data[k]
	end	
	scripted_ents.Register(t,class)
end

--[[
User: Kogitsune
Name: FastExplode(str:string,str:sep) - Performs a very fast, pattern-based explode on the string, only works with one char as seperator
Usage:
	for k,v in ipairs(utilx.FastExplode(file.Read("sometextfile.txt"),"\n")) do
		-- do something
	end
]]

function utilx.FastExplode(str,sep)
	local k,t
	t = {}
	for k in str:gmatch("[^"..sep.."]+") do
		table.insert(t,k)
	end
	return t
end

--[[
User: Overv
Name: IndexFromValue(table:tbl,string:val) - Quickly get the index of the given value or nil if the value wasn't found
Usage:
	local tbl = {"a","b","c","d","e","f","g"}
	print(utilx.IndexFromValue(tbl,"f"))
]]

function utilx.IndexFromValue(tbl,val)
	local k,v
	for k,v in pairs(tbl) do  
		if (v == val) return k end  
	end
	return nil
end

--[[
User: stoned (the-stone)
Name: CleanString(string:str) - Makes string usable for filenames
Usage:
	file.Write(utilx.CleanString(ply:SteamID())..".txt","file content...")
]]

function utilx.CleanString(str)
	local str = str:gsub(" ","_")
	str = str:gsub("[^%a%d_]","")
	return str
end

--[[
User: Carnag3
Name: GetSoundLength(string:strPath) - Gets the sound length
Usage:
	local len = utilx.GetSoundLength("sounds/mysong.wav")
	print(len)
]]

function utilx.GetSoundLength(strPath)  
	return string.ToMinutesSeconds(SoundDuration(strPath))  
end

--[[
User: Gbps
Name: FindPointsInLine(vector:vec1,vector:vec2) - It returns a table of all the points(vectors) that make up the line between vec1 and vec2.
Usage:
	<missing>
]]

function utilx.FindPointsInLine(vec1,vec2)  
	local ptstbl = {}  
	for i=1,100 do  
		ptstbl[i] = LerpVector(i*0.01,vec1,vec2)  
	end
	return ptstbl  
end

--[[
User: Gbps
Name: GetPlayerTrace(ply,distance) - In a sense, it's GetPlayerTrace with the added distance argument that is 'missing' from the current ply:GetPlayerTrace()
Usage:
	<missing>
]]

function utilx.GetPlayerTrace(ply,distance)  
	local pos = ply:GetShootPos()    
	local ang = ply:GetAimVector()    
	local tracedata = {}    
	tracedata.start = pos    
	tracedata.endpos = pos+(ang*distance)    
	tracedata.filter = ply  
	local trace = util.TraceLine(tracedata)    
	return trace
end

--[[
User: slayer3032
Name: AddSteamFriend(steamid) -- Adds the given user to your steam friendlist
Usage:

]]

function utilx.AddSteamFriend(steamid)  
	local expl = string.Explode(":",steamid)  
	local serverid,accountid = tonumber(expl[2]),tonumber(expl[3])  
	local friendid = string.format("765%0.f",accountid * 2 + 61197960265728 + serverid)
	http.Get("http://www.garry.tv/go.php?steam://friends/add/"..friendid,"",function() print("User has been added!") end)
end

--[[
User: awatemonosan
Name: AngleOffset(angle:ang1,angle:ang2) - Finds the difference between ang1 and ang2. Because DOT just doesn't always do the job.
Usage:
	local off = utilx.AngleOffset(Angle(0,0,0),Angle(0,90,0))
	> Angle(0,90,0)
	local off = utilx.AngleOffset(Angle(345,270,0),Angle(0,180,0))
	> Angle(-15,-90,0)	
]]

function utilx.AngleOffset(ang1,ang2)
	return Angle((ang1.p+180-ang2.p)%360-180,(ang1.y+180-ang2.y)%360-180,(ang1..r+180-ang2.r)%360-180)
end

--[[
User: thomasfn
Name: AddToTable(tbl,val) / RemoveFromTable(tbl,val) - Secure adds and removes values from a given table
Usage:
	<missing>
]]

function utilx.AddToTable(tbl,val)  
	if (!table.HasValue(tbl,val)) then
		table.insert(tbl,val)
	end  
end  

function utilx.RemoveFromTable(tbl,val)  
	for k,v in pairs(tbl) do  
		if (v == val) then  
			table.remove(tbl,k)  
			return  
		end  
	end  
end

--[[
User: Overv
Name: getCommand(string:str) / getArguments(string:str)
Usage:
	<missing>
]]

function utilx.getCommand(str)  
	return str:match("%w+")  
end  

function utilx.getArguments(str)  
	local args = {}  
	local i = 1
	
	for v in str:gmatch("%S+") do  
		if i > 1 then table.insert(args,v) end  
		i = i + 1  
	end  
	return args  
end

--[[
User: MakeR
Name: Average
Usage:
	<missing>
]]

function utilx.Average(...)  
	local ret, num = 0  
	for _, num in ipairs(arg) do  
		ret = ret + num  
	end  
	return ret / #arg, ret  
end  










