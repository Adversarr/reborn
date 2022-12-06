- [ ] 实现 timer_interface, 和 timer（见代码中的 TODO）
- [x] 对于 dmem（数据存储器），增加一个用于测试的实现：

当前的实现是多体交叉存储，具体而言，

- 对CPU看到的：memory一次可以取出4 Byte
- 对于内存实现：从 4 个 fpga 提供的，一次能够取出1Byte 的存储器（Block Memory）中同时取4 Byte，提供给CPU

缺点：无法写COE文件，然后预先放在内存中进行仿真，因为cpu/汇编器的4Byte 分散在了4个 Block Memory 里面。

需要将原先的实现“拷贝”回来。用于测试。


