@echo off
echo.+--------------------------------------------+
echo./ Copies all modules to the main gmod folder /
echo./                                            /
echo./ - LuaStoned                                /
echo.+--------------------------------------------+
echo.- Checking if all required folders exist:
echo.

if not exist ".\..\..\lua\includes" (
	mkdir ".\..\..\lua\includes"
	echo.- Folder /lua/includes/ was created
) else (
	echo.- Folder /lua/includes/ already exists
)

if not exist ".\..\..\lua\includes\modules" (
	mkdir ".\..\..\lua\includes\modules"
	echo.- Folder /lua/includes/modules/ was created
) else (
	echo.- Folder /lua/includes/modules/ already exists
)

if not exist ".\..\..\lua\menu_plugins" (
	mkdir ".\..\..\lua\menu_plugins"
	echo.- Folder /lua/menu_plugins/ was created
) else (
	echo.- Folder /lua/menu_plugins/ already exists
)

if not exist ".\..\..\lua\menu_plugins\luaconsole" (
	mkdir ".\..\..\lua\menu_plugins\luaconsole"
	echo.- Folder /lua/menu_plugins/luaconsole/ was created
) else (
	echo.- Folder /lua/menu_plugins/luaconsole/ already exists
)


if not exist ".\..\..\lua\menu_plugins_backup" (
	mkdir ".\..\..\lua\menu_plugins_backup"
	echo.- Folder /lua/menu_plugins_backup/ was created
) else (
	echo.- Folder /lua/menu_plugins_backup/ already exists
)

echo.
echo.
echo.- I backed following files up:
echo.
echo.

copy ".\..\..\lua\menu_plugins\luaconsole\*" ".\..\..\lua\menu_plugins_backup\*"

echo.
echo.
echo.- I moved following files:
echo.
echo.

copy ".\lua\includes\modules\*" ".\..\..\lua\includes\modules\*"
copy ".\lua\menu_plugins\*" ".\..\..\lua\menu_plugins\*"
copy ".\lua\menu_plugins\luaconsole\*" ".\..\..\lua\menu_plugins\luaconsole\*"
pause


