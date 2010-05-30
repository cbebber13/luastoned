SteamServer = {}
SteamServer.A2S_INFO_HEADER = "ÿÿÿÿTSource Engine Query"
SteamServer.A2A_PING_HEADER = "ÿÿÿÿi"
SteamServer.A2S_PLAYER_HEADER = "ÿÿÿÿU"
SteamServer.A2S_RULES_HEADER = "ÿÿÿÿV"
SteamServer.A2S_SERVERQUERY_GETCHALLENGE_HEADER = "ÿÿÿÿW"
SteamServer.A2M_GET_SERVERS_BATCH2_HEADER = "ÿÿÿÿ1"

SteamServer.Server = {}
SteamServer.ServerInfo = {}
SteamServer.NumServers = 0
SteamServer.Ip = "hl2master.steampowered.com"
SteamServer.Port = "27011"

function SteamServer:Update(ip,port)
	local sock = socket.udp()
	sock:settimeout(5)
	sock:setpeername(self.Ip,self.Port)
	sock:send("1ÿ"..ip..":"..port.."\0\\gamedir\\garrysmod\\napp\\500\0")
	if !sock then
		print("Socket failed to connect to "..self.Ip..":"..self.Port.."!" )
		return
	end
	local data,err = sock:receive(2048)
	if err then
		print("SteamServer - An Error occured:")
		print(err)
		self.Frame:SetTitle("SteamServer - Error: "..err)
	elseif data then
		local raw = data:ToTable()
		local tbl = {}
		for k,v in pairs(raw) do
			table.insert(tbl,tostring(v:byte()))
		end
		local i = 1
		while tbl[i] do
			if tbl[i + 1] and tbl[i + 2] and tbl[i + 3] and tbl[i + 4] then
				local ip = tbl[i].."."..tbl[i + 1].."."..tbl[i + 2].."."..tbl[i + 3]
				local port = tbl[i + 4] * 256 + tbl[i + 5]
				table.insert(self.Server,{ip = ip,port = port})
			end
			i = i + 6			
		end
		for k,server in pairs(self.Server) do
			self:CheckServer(server.ip,server.port)
		end
		timer.Simple(#self.Server*0.1,function()
			print("Done server query! Found ("..self.NumServers.." valid servers of "..#self.Server..")")
		end)
	end
end

function SteamServer:CheckServer(ip,port)
	local sock = socket.udp()
	sock:settimeout(0.1)
	sock:setpeername(ip,port)
	sock:send(self.A2S_INFO_HEADER)

	local data = sock:receive(1400)
	if data then
		local tbl = string.Explode(string.char(0),data)										
		local playerdata = tbl[5]:ToTable()
		local noideawhat = tbl[6]:ToTable()			
		local playerinfo = {}
		for k,v in ipairs(playerdata) do
			table.insert(playerinfo,string.byte(v))
		end						
		local noideainfo = {}
		for k,v in ipairs(noideawhat) do
			table.insert(noideainfo,string.byte(v))
		end
		
		local servername = tbl[1]:sub(7)
		local gamemode = tbl[4]
		local map = tbl[2]
		local numplayers = playerinfo[3] or noideainfo[2] or 0
		local maxplayers = playerinfo[4] or noideainfo[1] or 0
		
		self.NumServers = self.NumServers + 1
		table.insert(self.ServerInfo,{servername = servername,gamemode = gamemode,numplayers = numplayers,maxplayers = maxplayers,map = map,ip = ip,port = port})
		hook.Call("AddServer",nil,servername,gamemode,numplayers.." / "..maxplayers,map,ip..":"..port)
	end
end

function SteamServer:Search(str)
	--[[self.ListView:Clear()
	if str == "" then
		for k,server in pairs(self.ServerInfo) do
			self.ListView:AddLine(server.servername,server.gamemode,server.numplayers.." / "..server.maxplayers,server.map,server.ip..":"..server.port)
		end
		return
	end
	for k,server in pairs(self.ServerInfo) do
		if !server.servername:find(str) and !server.gamemode:find(str) and !server.map:find(str) then
			self.ListView:RemoveLine(k)
		end
	end]]
end