---------------------------------------------
-- IRC Plugin
-- o Part of the luamenu addon
-- o Users can chat and talk about the addon
---------------------------------------------

Irc = {
	Name = GetMenuVar("globalchat_name") or Derma_StringRequest("What's your Name?","Please enter your Name for (irc) chat.","User"..math.random(9)..math.random(9)..math.random(9),function(str)
		Irc.Name = str
		SetMenuVar("globalchat_name",str)
	end),
	EMail = "luamenu@bot.net",
	Host = "irc.gamesurge.net",
	Channels = {"#gmod"},
	Debug = CreateClientConVar("irc_debug",0,true,false),
	Version = 1.0,
}
Irc.Chan = Irc.Channels[1]

function Irc.Callback(sock,call,id,err,data,peer)
	if (call == SCKCALL_CONNECT and err == SCKERR_OK) then
		sock:ReceiveLine()
	end

	if (call == SCKCALL_REC_LINE and err == SCKERR_OK and data:len() > 0) then
		Irc:Parse(data,sock)	
		sock:ReceiveLine()
	end
end

function Irc:IsConnected()
	return self.Socket ~= nil
end

function Irc:Connect()
	local sock = OOSock(IPPROTO_TCP) -- IPPROTO_TCP or IPPROTO_UDP 
	sock:Connect(self.Host,6667) -- http 80, https 443
	sock:SetCallback(self.Callback)
	sock:Send("USER "..self.Name.." 0 * :"..self.EMail.."\r\n")
	sock:Send("NICK "..self.Name.."\r\n")
	self.Time = CurTime()
	self.Socket = sock
end
concommand.Add("irc_connect",function(p,c,a) Irc:Connect() end)

function Irc:Disconnect(arg)
	arg = table.concat(arg," ") or "Bye."
	if !self:IsConnected() then
		print("Not connected to "..self.Host)
		return
	end
	self.Socket:Send("QUIT :"..arg.."\r\n")
	self.Socket = nil
end
concommand.Add("irc_disconnect",function(p,c,a) Irc:Disconnect(a) end)

function Irc:Join(arg)
	if !arg[1] then print("No channel(s) specified.") return end

	if !self:IsConnected() then
		print("Not connected to "..self.Host)
		return
	end
  	self.Socket:Send("JOIN "..table.concat(arg,",").."\r\n")
	self.Chan = arg[1]
end
concommand.Add("irc_join",function(p,c,a) Irc:Join(a) end)

function Irc:Leave(arg)
	if !arg[1] then print("No channel(s) specified.") return end
	if !self:IsConnected() then
		print("Not connected to "..self.Host)
		return
	end
  	self.Socket:Send("PART "..table.concat(arg,",").."\r\n")
end
concommand.Add("irc_leave",function(p,c,a) Irc:Leave(a) end)

function Irc:SetName(arg)
	if !arg then print("No name specified.") return end
	if !self:IsConnected() then
		print("Not connected to "..self.Host)
		return
	end
	self.Socket:Send("NICK "..arg.."\r\n")
	self.Name = arg
end
concommand.Add("irc_setname",function(p,c,a) Irc:SetName(a[1]) end)

function Irc:Parse(str,sock)
	local ping = str:match("PING :([%w_]+)")
	local err = str:match("ERROR :([%w%p_]+)")
	local pong = str:match(":?[%w%p%-]+%sPONG%s[%w%p%-]+%s:([%w%p_]+)")
	local name,cmd,to,arg = str:match(":?([%w_]*)!*[%w%p%-]+%s([%w]+)%s([%w%p#_]+)%s:?(.*)")

	if ping then
		sock:Send("PONG "..ping.."\r\n")
	end
	if pong then
		local time = math.floor((CurTime()-pong)*1000)
		sock:Send("PRIVMSG "..self.Chan.." :"..time.."ms\r\n")
	end
	if err and err == ":closing link:" then
		self:Disconnect({"~closing link~"})
	end
	if cmd == "001" then -- Connection successful
		print("[IRC] Sucessfully connected to "..self.Host)
	end
	if cmd == "353" then -- Names List
		local chan,namestr = str:match(":?[%w%p%-]+%s353%s[%w%p_]+%s=?@?%s(#[%w%p_]+)%s:[%w_]+(.*)")
		print("[IRC] People on "..(chan or "<no channel>")..": "..(namestr or "<no names>"))
	end
	if cmd == "366" then -- End of Names list.
		print("[IRC] You are now on "..self.Chan)
	end
	if cmd == "376" then -- End of MOTD.
		print("[IRC] End of MOTD")
		self:Join({self.Chan})
	end
	if cmd == "422" then -- MOTD is missing.
		print("[IRC] MOTD is missing")
		self:Join({self.Chan})
	end
	if cmd == "404" then -- You are not in the channel.
		print("[IRC] You are not in "..self.Chan)
	end
	if cmd == "KICK" and arg == self.Name then -- Kicked from channel.
		print("[IRC] You got kicked from "..self.Chan)
		--self:Disconnect({"I got kicked :V"})
	end
	if cmd == "433" then -- Nickname already in use.
		print("[IRC] Nickname already in use ("..self.Name..")")
		self:SetName(self.Name.."_")
	end
	if cmd == "PRIVMSG" then
		hook.Call("IrcText",nil,name,arg,to)
	end
	if self.Debug:GetBool() == true then
		print("[IRC DEBUG] "..str)
	end
end

function Irc:Raw(arg)
	self.Socket:Send(arg.."\r\n")
end

function Irc:Send(to,txt)
	self.Socket:Send("PRIVMSG "..to.." :"..txt.."\r\n")
end

function Irc:Notice(to,txt)
	self.Socket:Send("NOTICE "..to.." :"..txt.."\r\n")
end

function Irc:Format(str)
	if str:sub(1,1) == "/" then
		local cmd,arg = str:sub(2):match("([%w_]+)%s?(.*)")
		if cmd == "join" then
			self:Join({arg})
		elseif cmd == "leave" then
			self:LeaveChan({arg})
		elseif cmd == "quit" then
			self:Disconnect({arg})
		elseif cmd == "nick" then
			self:SetName(arg)
		elseif cmd == "w" then
			local user,txt = arg:match("([%w_]+)%s?(.*)")
			self:Send(user,txt)
		elseif cmd == "n" then
			local user,txt = arg:match("([%w_]+)%s?(.*)")
			self:Notice(user,txt)
		elseif cmd == "c" then
			self.Chan = arg
		else
			hook.Call("IrcText",nil,self.Name,str,self.Chan)
			self:Send(self.Chan,str)
		end
	else
		hook.Call("IrcText",nil,self.Name,str,self.Chan)
		self:Send(self.Chan,str)
	end
end