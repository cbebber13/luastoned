@echo off
echo "+--------------------------------------------+"
echo "| Copies all modules to the main gmod folder |"
echo "|                                            |"
echo "| - LuaStoned                                |"
echo "+--------------------------------------------+"

copy ".\lua\includes\modules\*" ".\..\..\lua\includes\modules\*"
copy ".\lua\vgui\lua_menu.lua" ".\..\..\lua\vgui\*"
pause


