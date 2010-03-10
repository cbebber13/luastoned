@echo off
echo "+--------------------------------------------+"
echo "| Copies all modules to the main gmod folder |"
echo "|                                            |"
echo "| - Stoned                                   |"
echo "+--------------------------------------------+"

copy ".\modules\*" ".\..\..\lua\includes\modules\*"
pause


