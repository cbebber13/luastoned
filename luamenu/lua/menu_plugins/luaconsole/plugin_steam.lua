SteamServer = {}
SteamServer.A2S_INFO_HEADER = "ÿÿÿÿTSource Engine Query"
SteamServer.A2A_PING_HEADER = "ÿÿÿÿi"
SteamServer.A2S_PLAYER_HEADER = "ÿÿÿÿU"
SteamServer.A2S_RULES_HEADER = "ÿÿÿÿV"
SteamServer.A2S_SERVERQUERY_GETCHALLENGE_HEADER = "ÿÿÿÿW"
SteamServer.A2M_GET_SERVERS_BATCH2_HEADER = "ÿÿÿÿ1"

SteamServer.Server = {}
SteamServer.ServerInfo = {}
SteamServer.NumServer = 0
SteamServer.MasterServer = "hl2master.steampowered.com"
SteamServer.MasterPort = 27011
SteamServer.MaxQueries = 1
SteamServer.CurrentQueries = 0

SteamServer.MasterSocket = OOSock(IPPROTO_UDP)
SteamServer.QuerySocket = OOSock(IPPROTO_UDP)

function SteamServer:QueryString(ip,port,gamename)
	ip = ip or "0.0.0.0"
	port = port or "0"
	gamename = gamename or "garrysmod"
	return string.format("1ÿ%s:%s\0\\gamedir\\%s\\napp\\500\0",ip,port,gamename)
end

function SteamServer:QueryMaster(ip,port)
	self.MasterSocket:Send(self:QueryString(ip,port),self.MasterServer,self.MasterPort)
	self.MasterSocket:ReceiveDatagram()
end

function SteamServer:QueryServer(ip,port)
	self.QuerySocket:Send(self.A2S_INFO_HEADER,ip,tonumber(port))
	self.QuerySocket:ReceiveDatagram()
end

function table.HasIpPort(tbl,ip,port)
	for k,serv in pairs(tbl) do
		if serv.ip == ip and serv.port == port then
			return true
		end	
	end	
	return false
end

function SteamServer.Callback(sock,call,id,err,data,peer)
	local self = SteamServer

	if call == SCKCALL_REC_DATAGRAM and err == SCKERR_OK then
		local tbl = {}
		for k,char in ipairs(data:ToTable()) do
			table.insert(tbl,string.byte(char))
		end
		local i = 1
		while tbl[i] do
			if tbl[i+1] and tbl[i+2] and tbl[i+3] and tbl[i+4] and tbl[i+5] then
				local ip = string.format("%s.%s.%s.%s",tbl[i],tbl[i+1],tbl[i+2],tbl[i+3])
				local port = tbl[i+4] * 256 +tbl[i+5]
				
				if !table.HasIpPort(self.Server,ip,port) then
					table.insert(self.Server,{ip = ip,port = port})
					print("Query "..ip..":"..port)
					--self:QueryServer(ip,port)
				end
			end
			i = i + 6
		end
		
		local lastserver = self.Server[#self.Server] or {ip="0.0.0.0",port="0"}	
		if self.CurrentQueries <= self.MaxQueries then
			sock:Send(self:QueryString(lastserver.ip,lastserver.port,"garrysmod"),self.MasterServer,self.MasterPort)
			sock:ReceiveDatagram()
			self.CurrentQueries = self.CurrentQueries + 1
		else
			print("Found " .. #self.Server .. " during query!")
		end
	end
	
	if err ~= SCKERR_OK then
		print("[Steam] Error, closing mastersocket")
		sock:Close()		
	end
end
SteamServer.MasterSocket:SetCallback(SteamServer.Callback)

SteamServer.Calltypes = {
	[SCKCALL_CONNECT] = "Connect", -- SCKCALL_CONNECT
	[SCKCALL_REC_SIZE] = "Rec Size", -- SCKCALL_REC_SIZE
	[SCKCALL_REC_LINE] = "Rec Line", -- SCKCALL_REC_LINE
	[SCKCALL_SEND] = "Send", -- SCKCALL_SEND
	[SCKCALL_BIND] = "Bind", -- SCKCALL_BIND
	[SCKCALL_ACCEPT] = "Accept", -- SCKCALL_ACCEPT
	[SCKCALL_LISTEN] = "Listen", -- SCKCALL_LISTEN	
	[SCKCALL_REC_DATAGRAM] = "Datagram", -- SCKCALL_REC_DATAGRAM
}

SteamServer.Errtypes = {
	[SCKERR_OK] = "Ok", -- SCKERR_OK
	[SCKERR_BAD] = "Bad", -- SCKERR_BAD
	[SCKERR_CONNECTION_RESET] = "Con Rest", -- SCKERR_CONNECTION_RESET
	[SCKERR_NOT_CONNECTED] = "Not Con", -- SCKERR_NOT_CONNECTED
	[SCKERR_TIMED_OUT] = "Timed Out", -- SCKERR_TIMED_OUT
}

function SteamServer.QueryCallback(sock,call,id,err,data,peer)
	local self = SteamServer

	if call == SCKCALL_REC_DATAGRAM and err == SCKERR_OK and data:len() > 0 then
		local tbl = string.Explode(string.char(0),data)
		
		local playerinfo = {}
		for k,char in pairs(tbl[5]:ToTable()) do
			table.insert(playerinfo,string.byte(char))
		end
		
		local otherinfo = {}
		for k,char in pairs(tbl[6]:ToTable()) do
			table.insert(otherinfo,string.byte(char))
		end

		local hostname = tbl[1]:sub(7)
		local gamemode = tbl[4]
		local map = tbl[2]
		local numplayers = playerinfo[3] or otherinfo[2] or 0
		local maxplayers = playerinfo[4] or otherinfo[1] or 0
		
		local ip,port = self.Server[self.NumServer].ip,self.Server[self.NumServer].port or "0.0.0.0","0" -- uh oh, fix dat

		self.NumServer = self.NumServer + 1
		
		table.insert(self.ServerInfo,{hostname = hostname,gamemode = gamemode,numplayers = numplayers,maxplayers = maxplayers,map = map,ip = ip,port = port})
		hook.Call("AddServer",nil,hostname,gamemode,numplayers,maxplayers,map,ip,port)
	end
	if call == SCKCALL_REC_DATAGRAM and err == SCKERR_OK then
		--sock:ReceiveDatagram()
	end
	--sock:ReceiveDatagram()
	
	print(data)
	print(data:len())
	
	print("[Steam] Call: "..self.Calltypes[call].." - Error: "..self.Errtypes[err])

	if err ~= SCKERR_OK then
		print("[Steam] Error, closing querysocket")
		sock:Close()		
	end
end
SteamServer.QuerySocket:SetCallback(SteamServer.QueryCallback)