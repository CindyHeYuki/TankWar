<!-- vscode-markdown-toc -->
* 1. [环境准备](#)
* 2. [API参考](#API)
	* 2.1. [从汇编看](#-1)
	* 2.2. [从Win32API看](#Win32API)
* 3. [程序逻辑](#-1)
	* 3.1. [变量说明](#-1)
	* 3.2. [如何实现UI动画](#UI)
	* 3.3. [宏观控制流](#-1)
		* 3.3.1. [WinMain函数](#WinMain)
		* 3.3.2. [WinProc函数](#WinProc)
		* 3.3.3. [按键控制区](#-1)
	* 3.4. [DrawUI区](#DrawUI)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc --># TankWar

北京理工大学2020级汇编语言与接口设计大作业，星战前夜：无烬黎明

##  1. <a name=''></a>环境准备

使用VS2017+MASM32，配置方式在课本上有，网上也有很多，不同版本的VS配置流程是一样的：

> [配置VS+MASM](https://blog.csdn.net/m0_46436640/article/details/106737907?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522166988528916782428614119%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=166988528916782428614119&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~baidu_landing_v2~default-2-106737907-null-null.142^v67^control,201^v3^add_ask,213^v2^t3_control2&utm_term=vs%E6%B1%87%E7%BC%96%E9%85%8D%E7%BD%AE&spm=1018.2226.3001.4187)

如果配置过程中找不到Microsoft Macro Assembly配置项，详见下文：

> [VS2019找不到Microsoft Macro Assembly的问题](https://blog.csdn.net/m0_52813850/article/details/124851595?spm=1001.2101.3001.6650.5&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-5-124851595-blog-90646353.pc_relevant_aa&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-5-124851595-blog-90646353.pc_relevant_aa&utm_relevant_index=10)

之后运行Hello World代码就可以运行了，但是想要直接运行本代码，还需要导入一些库，这不是我们代码写法的问题，而是很多人都会出现的问题。

main.asm最开始使用绝对路径导入三个包，你需要将support文件夹中的文件放到对应路径里（我们是C:\masm32），之后就不会出问题了。

需要注意的是，我们使用了绝对路径，所以我建议你直接把masm32安到C盘，就不要为绝对路径操心了。

##  2. <a name='API'></a>API参考

###  2.1. <a name='-1'></a>从汇编看

汇编程序的编写，大量调用了windows的API，其都是以stdcall形式调用的。

网上关于这些API的资料少之又少，毕竟是老古董了，所以就要把视角转向源码。库文件又inc和lib两种，inc是头文件，里面有大量的函数原型声明，lib是静态链接库，里面是函数的具体实现，但是貌似是二进制文件，所以一般人是看不了的。但是，仅仅inc文件也足够了，里面有一些参数的说明。

###  2.2. <a name='Win32API'></a>从Win32API看

前面说了，都是windows的API，那为什么不干脆去windows官网看呢，虽然你看到的是C语言，但是实际上汇编里调用C语言和C语言语法几乎是一模一样的，你能获得的，是一个完善到恐怖的API文档：

> [Win32API之图像](https://learn.microsoft.com/zh-cn/windows/win32/gdi/windows-gdi)  
> [Win32API之消息与事件](https://learn.microsoft.com/zh-cn/windows/win32/api/_winmsg/)  
> [找不到就看这里](https://learn.microsoft.com/zh-cn/windows/win32/api/_menurc/)

##  3. <a name='-1'></a>程序逻辑

###  3.1. <a name='-1'></a>变量说明

详见代码注释

###  3.2. <a name='UI'></a>如何实现UI动画

UI的绘制由数据决定，UI保持高频率地刷新，每次都会用数据重新绘制一次界面。

一旦数据发生变化，UI就会迅速反应，在视觉上就好像是我们按下一个键后UI马上就会变化。实际上，在按下键到UI变化之间还隔着一次刷新，只不过刷新频率太快，人眼感觉不到罢了。

明白这一点后，你就知道控制和UI其实是分开的，整体的工作分为两部分：

1. 控制逻辑：通过检测键盘输入修改数据
2. UI绘制：利用数据绘制UI

###  3.3. <a name='-1'></a>宏观控制流

####  3.3.1. <a name='WinMain'></a>WinMain函数

这个函数是Win32的经典窗口，WinMain函数发挥了main函数的作用，充当程序入口，其整体过程为：

1. 实例化（程序开始已做，同时绑定WinProc回调函数）WNDCLASS类并填充
2. 将WNDCLASS类注册到windows系统中，此后可以通过这个类的className字段绑定这个窗口
3. 创建运行窗口（注册并不等于运行），使用已注册窗口的className字段绑定
4. 初始化+显示窗口
5. 后台运行窗口的死循环消息队列，不断将消息（可以理解为用户的各种操作）进行预处理后发送给WinProc函数进行响应

####  3.3.2. <a name='WinProc'></a>WinProc函数

这个函数同样是Win32窗口程序的经典套路，在前面的WNDCLASS实例化的时候，其中的一个参数就已经将这个函数绑定进去了，即这个函数将处理来自于这个窗口的所有信息。

WinProc有两层分支结构：

1. 第一层分支结构用message参数判断message的宏观类型，比如键盘按下，键盘松开，计时器事件等等。
2. 第二层分支，通过判断具体事件类型转到不同分支，比如按下的是哪个键，wasd还是上下左右，还是enter，esc，space

需要注意的是，所有的键按下都会将XXHold变量置1，但是有一些键会有额外的处理过程，因为他们的情况比较复杂：

1. 上下键关系到菜单选项的切换
2. esc会涉及到界面的切换
3. enter键和space键涉及到界面切换与子弹发射

####  3.3.3. <a name='-1'></a>按键控制区

这一部分从UpInMenu标签开始。分别实现各种按键的附加功能：

1. 上下键。对选择菜单有副作用，影响菜单指针的上下移动
2. Enter和Space键。
    - 如果在游戏界面，则不做额外处理
    - 如果在其他界面，会根据选项产生复杂的界面转移效果
3. Esc键。回退到初始界面

###  3.4. <a name='DrawUI'></a>DrawUI区

其他人补



