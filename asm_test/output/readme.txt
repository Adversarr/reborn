UARTCoe_v3.0.exe工具可以将汇编器生成的.coe文件转换成可下载的格式。
打开cmd或Powershell，输入以下命令并执行：
	UARTCoe_v3.0.exe h prgmip32.coe dmem32.coe out.txt
UARTCoe_v3.0.exe工具有n个参数，其含义为：
参数	取值			解释
  1	h或v			拼接模式。其中h代表水平拼接，v代表垂直拼接
2~n-1	.coe文件的路径		.coe文件的顺序不同，生成的结果就不同
  n	输出文件的路径		可用于串口下载的文件的路径