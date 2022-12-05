# TankWar

北京理工大学2020级汇编语言与接口设计大作业
汇编语言实现“另类”坦克大战

## 环境准备

使用VS2017+MASM32，配置方式在课本上有，网上也有很多，不同版本的VS配置流程是一样的：

> [配置VS+MASM](https://blog.csdn.net/m0_46436640/article/details/106737907?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522166988528916782428614119%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=166988528916782428614119&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~baidu_landing_v2~default-2-106737907-null-null.142^v67^control,201^v3^add_ask,213^v2^t3_control2&utm_term=vs%E6%B1%87%E7%BC%96%E9%85%8D%E7%BD%AE&spm=1018.2226.3001.4187)

如果配置过程中找不到Microsoft Macro Assembly配置项，详见下文：

> [VS2019找不到Microsoft Macro Assembly的问题](https://blog.csdn.net/m0_52813850/article/details/124851595?spm=1001.2101.3001.6650.5&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-5-124851595-blog-90646353.pc_relevant_aa&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-5-124851595-blog-90646353.pc_relevant_aa&utm_relevant_index=10)

之后运行Hello World代码就可以运行了，但是想要直接运行本代码，还需要导入一些库，这不是我们代码写法的问题，而是很多人都会出现的问题。

main.asm最开始使用绝对路径导入三个包，你需要将support文件夹中的文件放到对应路径里（我们是C:\masm32），之后就不会出问题了。

需要注意的是，我们使用了绝对路径，所以我建议你直接把masm32安到C盘，就不要为绝对路径操心了。

## API参考

### 从汇编看

汇编程序的编写，大量调用了windows的API，其都是以stdcall形式调用的。

网上关于这些API的资料少之又少，毕竟是老古董了，所以就要把视角转向源码。库文件又inc和lib两种，inc是头文件，里面有大量的函数原型声明，lib是静态链接库，里面是函数的具体实现，但是貌似是二进制文件，所以一般人是看不了的。但是，仅仅inc文件也足够了，里面有一些参数的说明。

### 从Win32API看

前面说了，都是windows的API，那为什么不干脆去windows官网看呢，虽然你看到的是C语言，但是实际上汇编里调用C语言和C语言语法几乎是一模一样的，你能获得的，是一个完善到恐怖的API文档：

> [Win32API之图像](https://learn.microsoft.com/zh-cn/windows/win32/gdi/windows-gdi)  
> [Win32API之消息与事件](https://learn.microsoft.com/zh-cn/windows/win32/api/_winmsg/)  
> [找不到就看这里](https://learn.microsoft.com/zh-cn/windows/win32/api/_menurc/)