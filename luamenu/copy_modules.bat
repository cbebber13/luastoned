@echo off
echo.+--------------------------------------------+
echo./ Copies all modules to the main gmod folder /
echo./                                            /
echo./ - LuaStoned                                /
echo.+--------------------------------------------+
echo.- Checking if all required folders exist:

if not exist ".\..\..\lua\vgui" (
	mkdir ".\..\..\lua\vgui"
	echo.- Folder /vgui/ was created
) else (
	echo.- Folder /vgui/ already exists
)
echo.- I moved following files:
echo.

copy ".\lua\includes\modules\*" ".\..\..\lua\includes\modules\*"
copy ".\lua\vgui\lua_menu.lua*" ".\..\..\lua\vgui\*"
copy ".\lua\vgui\luaconsole\*" ".\..\..\lua\vgui\luaconsole\*"
pause


