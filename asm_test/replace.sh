#!/bin/bash
cp "Minisys1Av2.2/output/prgmip32.coe" "output"
cp "output/*.coe" "../cpu/minisys1/minisys1.ip_user_files/mem_init_files"
ls -l "output/*.coe"
ls -l "../cpu/minisys1/minisys1.ip_user_files/mem_init_files/*.coe"
echo [INFO] *.coe copied successfully