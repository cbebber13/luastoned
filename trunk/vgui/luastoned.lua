--[[

	+----------------------------------------------------------------+
	| Project LuaStoned
	| Author: Stoned
	| Version: 1.0
	+----------------------------------------------------------------+
	| Adding useful code snippets to the menu and client env in GMod |
	|
	|
	|
	|
	|
	+----------------------------------------------------------------+

]]--

local Config = {
	LoadMenu				= true,		-- Shall code snippets be loaded in the menu env?
	LoadClient				= true,		-- Shall code snippets be loaded in the client env?
	Plugins					= {
		["utilx.lua"]		= true,		-- Load utilx?
		["Sha1.lua"]		= true,		-- Load sha1?
		["AESLua.lua"]		= false,	-- Load AES?
		["BigInt.lua"]		= false,	-- Load BigInt?
	},
	AreWeCool		= true,		-- Always yes :D
}	

function IsMenuEnv()
	return _R.Player == nil
end

function GetPlugins()
	return file.Find("../lua/vgui/luastoned/*.lua")
end

function LoadPlugin(str)
	if Config.Plugins[str] ~= false then
		RunString(file.Read("../lua/vgui/luastoned/"..str))
		print("[LS] Plugin [x]: "..str)
	else
		print("[LS] Plugin [ ]: "..str)
	end
end

for k,plugin in pairs(GetPlugins()) do
	LoadPlugin(plugin)
end