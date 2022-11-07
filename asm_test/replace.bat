@echo off
cp "Minisys1Av2.2\output\*.coe" output"
cp "output\*.coe" "..\cpu\minisys1\minisys1.ip_user_files\mem_init_files"
dir /B "Minisys1Av2.2\output\*.coe"
echo [INFO] listed files copied successfully
pause