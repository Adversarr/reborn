@echo off
cp "Minisys1Av2.2\output\*.coe" output"
cp "output\dmem32.coe" "..\cpu\minisys1\minisys1.srcs\sources_1\ip\mem\dmem32.coe"
cp "output\prgmip32.coe" "..\cpu\minisys1\minisys1.srcs\sources_1\ip\prgrom\prgmip32.coe"
dir /B "Minisys1Av2.2\output\*.coe"
echo [INFO] listed files copied successfully
pause