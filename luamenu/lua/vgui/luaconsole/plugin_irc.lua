---------------------------------------------
-- IRC Plugin
-- o Part of the luamenu addon
-- o Users can chat and talk about the addon
---------------------------------------------

require("socket")

Irc = {
	Name = "luamenu_user"..math.random(1000),
	EMail = "luamenu@bot.net",
	Hosts = {"irc.gamesurge.net"},
	Socket = {},
	Sockets = {},
	Commands = {},
	Channels = {"#luamenu"},
	Debug = CreateClientConVar("lua_irc_debug",0,true,false),
	Search = false,
	Version = 1.2,
}
Irc.Chan = Irc.Channels[1]
Irc.Nick = Irc.Name

function Irc:IsConnected()
	for k,host in pairs(self.Hosts) do
		if self.Sockets[host] then
			return true
		end
	end
	return false
end

function Irc:Connect(arg)
	for k,host in pairs(self.Hosts) do
		local sock = socket.connect(host,6667)
		sock:settimeout(0)
		sock:send("USER "..self.Name.." 0 * :"..self.EMail.."\r\n")
		sock:send("NICK "..self.Name.."\r\n")
		self.Sockets[host] = {sock = sock,index = table.insert(self.Sockets,sock),time = CurTime(),host = host}
	end
end
concommand.Add("lua_irc_connect",function(p,c,a) Irc:Connect(a) end)

function Irc:Disconnect(arg)
	local arg = table.concat(arg," ") or "Bye."
	for k,host in pairs(self.Hosts) do
		if !self.Sockets[host] then
			print("Not connected to "..host)
			return
		end
		self.Sockets[host].sock:send("QUIT :"..arg.."\r\n")
		self.Sockets[host].sock:close()
		self.Sockets[host] = nil
	end
end
concommand.Add("lua_irc_quit",function(p,c,a) Irc:Disconnect(a) end)

function Irc:JoinChan(arg)
	if !arg[1] then print("No channel specified.") return end
	self.Chan = arg[1]
	for k,host in pairs(self.Hosts) do
	    if !self.Sockets[host] then
			print("Not connected to "..host)
			return
		end
		local list = ""
  		self.Sockets[host].sock:send("JOIN "..table.concat(arg,",").."\r\n")
	end
end
concommand.Add("lua_irc_joinchan",function(p,c,a) Irc:JoinChan(a) end)

function Irc:LeaveChan(arg)
	if !arg[1] then print("No channel specified.") return end
	for k,host in pairs(self.Hosts) do
	    if !self.Sockets[host] then
			print("Not connected to "..host)
			return
		end
		local list = ""
  		self.Sockets[host].sock:send("PART "..table.concat(arg,",").."\r\n")
	end
end
concommand.Add("lua_irc_leavechan",function(p,c,a) Irc:LeaveChan(a) end)

function Irc:SetNick(arg)
	if !arg then print("No name specified.") return end
	for k,host in pairs(self.Hosts) do
		if !self.Sockets[host] then
			print("Not connected to "..host)
			return
		end
		self.Sockets[host].sock:send("NICK "..arg.."\r\n")
		self.Nick = arg
	end
end
concommand.Add("lua_irc_nick",function(p,c,a) Irc:SetNick(a[1]) end)

function Irc:Auth(arg)
	local arg = arg or self.Nick or "Luabot"
	for k,host in pairs(self.Hosts) do
		if !self.Sockets[host] then
			print("Not connected to "..host)
			return
		end
		//self.Sockets[host].sock:send("AUTHSERV auth username password\r\n") -- add your username/pw and uncomment those lines
		//self.Sockets[host].sock:send("MODE "..arg.." +x\r\n")
	end
end
concommand.Add("lua_irc_auth",function(p,c,a) Irc:Auth(a[1]) end)

function Irc:Think()
    while true do
		local ready = socket.select(self.Sockets,nil,0)
		if #ready == 0 then break end

		for _,sock in ipairs(ready) do
			local line,err,part = sock:receive('*line')
			local con
			for k,host in pairs(self.Hosts) do
				if self.Sockets[host].sock == sock then
					con = self.Sockets[host]
				end
			end

			if line then				
				local ping = line:match("PING :([%w_]+)")
				local error = line:match("ERROR :([%w%p_]+)")
				local pong = line:match(":?[%w%p%-]+%sPONG%s[%w%p%-]+%s:([%w%p_]+)")
				local name,cmd,to,arg = line:match(":?([%w_]*)!*[%w%p%-]+%s([%w]+)%s([%w%p#_]+)%s:?(.*)")

				if ping then
					sock:send("PONG "..ping.."\r\n")
				end
				if pong then
					local time = math.floor((CurTime()-pong)*1000)
					sock:send("PRIVMSG "..self.Chan.." :"..time.."ms\r\n")
				end
				if error and error == ":closing link:" then
					self:Disconnect({"~closing link~"})
				end
				if cmd == "001" then -- Connection successful
					hook.Call("IrcText",nil,"Sucessfully connected to the network",con.host,self.Chan)
				end
				if cmd == "353" then -- Names List
					local chan,namestr = line:match(":?[%w%p%-]+%s353%s[%w%p_]+%s=?@?%s(#[%w%p_]+)%s:[%w_]+(.*)")
					self:ParseList(chan,namestr)
				end
				if cmd == "366" then -- End of Names list.
					hook.Call("IrcText",nil,"You are now on",self.Chan,self.Chan)
				end
				if cmd == "376" then -- End of MOTD.
					hook.Call("IrcText",nil,"End of","MOTD",self.Chan)
					self:Auth()
					self:JoinChan({self.Chan})
				end
				if cmd == "422" then -- MOTD is missing.
					hook.Call("IrcText",nil,"Missing","MOTD",self.Chan)
					self:Auth()
					self:JoinChan({self.Chan})
				end
				if cmd == "404" then -- You are not in the channel.
					hook.Call("IrcText",nil,"Not in channel",self.Chan,self.Chan)
				end
				if cmd == "KICK" and arg == self.Name then -- Kicked from channel.
					hook.Call("IrcText",nil,"You got kicked from",self.Chan,self.Chan)
					self:Disconnect({"Kicked"})
				end
				if cmd == "433" then -- Nickname already in use.
					hook.Call("IrcText",nil,"Nickname already in use",self.Nick,self.Chan)
					self:SetNick(self.Name.."_")
				end
				if cmd == "PRIVMSG" then
					local text = arg
					local room = to
					hook.Call("IrcText",nil,name,text,room)
				end
				if self.Debug:GetBool() == true then
					print(line)
				end
			elseif err == "closed" then
				print("Socket closed after "..CurTime() - con.time.." seconds.")

				sock:send("QUIT :LuaBot was shut down.\r\n")
				sock:close()

				table.remove(self.Sockets,con.index)
				self.Sockets[sock] = nil
			end
		end
	end
end
hook.Add("Think","Irc Think",function() Irc:Think() end)

function Irc:Format(str)
	if str:sub(1,1) == "!" then
		local cmd,arg = str:sub(2):match("([%w_]+)%s?(.*)")
		if cmd == "join" then
			self:JoinChan({arg})
		elseif cmd == "leave" then
			self:LeaveChan({arg})
		elseif cmd == "quit" then
			self:Disconnect({arg})
		elseif cmd == "nick" then
			self:SetNick(arg)
		elseif cmd == "w" then
			local user,txt = arg:match("([%w_]+)%s?(.*)")
			self:Send(user,txt)
		elseif cmd == "n" then
			local user,txt = arg:match("([%w_]+)%s?(.*)")
			self:Notice(user,txt)
		elseif cmd == "c" then
			self.Chan = arg
		else
			hook.Call("IrcText",nil,self.Nick,str,self.Chan)
			self:Send(self.Chan,str)
		end
	else
		hook.Call("IrcText",nil,self.Nick,str,self.Chan)
		self:Send(self.Chan,str)
	end
end

function Irc:Raw(arg)
	for k,host in pairs(self.Hosts) do
		self.Sockets[host].sock:send(arg.."\r\n")
	end
end

function Irc:Send(to,txt)
	for k,host in pairs(self.Hosts) do
		self.Sockets[host].sock:send("PRIVMSG "..to.." :"..txt.."\r\n")
	end
end

function Irc:Notice(to,txt)
	for k,host in pairs(self.Hosts) do
		self.Sockets[host].sock:send("NOTICE "..to.." :"..txt.."\r\n")
	end
end

function Irc:Quote(...)
    local str = table.concat({...}," ")
    local ret = str:gsub("[\001\\]",{["\001"] = "\\a",["\\"]   = "\\\\"})
    return "\001".. ret.."\001"
end

function Irc:Parse(name,text,chan)
	local arg = string.Explode(" ",text)
	local cmd = arg[1]:Trim()
	if self.Commands[cmd] then
		local ok,err = pcall(function(Irc)
			self.Commands[cmd].func(name,table.concat(arg," ",2),chan)
		end)
		if !ok then
			hook.Call("IrcText",nil,"Function "..cmd,err,self.Chan)
		end
	end
end

function Irc:ParseList(chan,namestr)
	hook.Call("IrcText",nil,"Users on "..chan,namestr,self.Chan)
end