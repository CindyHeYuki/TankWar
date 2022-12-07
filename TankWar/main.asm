;界面实现
;消息传递与控制：从硬件到操作系统，压栈，进行一些控制（与外界进行信息交流）

;游戏逻辑


.386
.model flat, STDCALL

;使用相对路径导入support文件夹中的三个库
INCLUDE	..\support\GraphWin.inc
INCLUDE gdi32.inc
INCLUDE msimg32.inc
INCLUDELIB gdi32.lib
INCLUDELIB msimg32.lib
INCLUDELIB ..\support\irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDE ..\support\bhw.inc
INCLUDELIB msvcrt.lib


printf	PROTO	C :ptr sbyte,:VARARG
WriteDec PROTO
Crlf PROTO

.data

szMsg	BYTE "%d",0ah,0
WindowName BYTE "StarWar:Before The Dawn", 0
className BYTE "Plane", 0
imgName BYTE "djb.bmp", 0


;创建一个窗口，基于窗口类来实现，必须确定处理窗口的窗口过程(回调函数)。其他参数初始为NULL，后续会在WinMain主函数中填充
MainWin WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

msg MSGStruct <>	;消息结构，用户存放获取的message
winRect RECT <>
hMainWnd DWORD ?	;主窗口的句柄
hInstance DWORD ?

hbitmap DWORD ?		;图片的句柄
hdcMem DWORD ?		;hdc句柄，使用频率高
hdcPic DWORD ?		;hdc句柄，很少使用
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
ps PAINTSTRUCT <>

BreakWallType DWORD 0
BreakWallPos DWORD 0
PlaneToBreak DWORD 0
DirectionMapToW DWORD 4, 2, 3, 1
BulletMove DWORD 7, 0, -7, 0, 0, 7, 0, -7
PlaneMove DWORD 3, 0, -3, 0, 0, 3, 0, -3, 3, 0, -3, 0, 0, 3, 0, -3, 5, 0, -5, 0, 0, 5, 0, -5
BulletPosFix DWORD 10, 0, -10, 0, 0, 10, 0, -10
DrawHalfSpiritMask DWORD 32, 32, 16, 16, 16, 16, 32, 32, 0, 0, 0, 16, 0, 16, 0, 0
ScoreText BYTE "000000", 0
RandomPlace DWORD 64, 224, 384

WaterSpirit DWORD ? ; 水的图片，需要x / 8 + 3
WhichMenu DWORD 0; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
ButtonNumber DWORD 2, 5, 0, 2; 每个界面下的选项数
SelectMenu DWORD 0; 正在选择的菜单项
GameMode DWORD 0; 游戏模式 0为闯关模式，1为挑战模式
IsDoublePlayer DWORD 0; 游戏模式，00是单人游戏，11是双人游戏

;按键操作部分，按下就会变成1，否则就是0
UpKeyHold DWORD 0
DownKeyHold DWORD 0
LeftKeyHold DWORD 0
RightKeyHold DWORD 0
WKeyHold DWORD 0
SKeyHold DWORD 0
AKeyHold DWORD 0
DKeyHold DWORD 0
SpaceKeyHold DWORD 0
EnterKeyHold DWORD 0

; 0=土地,1=水,2=树,3=墙,4~7=各种墙(上下左右),8=老家,11=铁,12~15=各种铁
; Map储存了当前游戏阶段的地图，随着游戏关卡变化而不断变化
Map			DWORD 225 DUP(?)
;YourPlane，一行对应一个玩家，一列对应一个属性，分别如下：
;类型(0=不存在,1=玩家飞机,2=未使用,3=普通,4=强化,5=快速)
;X
;Y
;方向
;子弹类型(0=不存在,1=存在,2~9=爆炸)
;子弹X
;子弹Y
;子弹方向
YourPlane	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			
;EnemyPlane的行数（10）决定了同时能出现的敌方飞机数量，属性和我方飞机一样
EnemyPlane	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
YourLife	DWORD 0,0
EnemyLife	DWORD 0,0,0
Score		DWORD 0,0
Round		DWORD 0	;Round决定了你用哪个地图，0对应无尽模式，12345对应挑战模式的5个关卡
WaitingTime	DWORD -1
YouDie		DWORD 0	;0代表存活，1代表YouDie

;RoundMap存放了预留的地图
;0是无尽模式，12345对应闯关
;地图尺寸为225=15×15
			; Round 0 (挑战模式)
RoundMap	DWORD  3, 3, 0, 3, 3, 3, 3, 0, 3, 3, 3, 3, 0, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3,11, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3,11,11, 3,11, 3,11,11,11, 3,11, 3,11,11, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11,11, 3,11, 3,11,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11,11,11,11,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3, 3, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 0,11, 3, 8, 3,11, 0, 3, 3, 3, 3
			; Round 1                                    
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0, 0, 0, 0, 0
			DWORD 11, 0, 3, 3, 0, 0,13, 0,13, 0, 0, 3, 3, 0,11
			DWORD  1, 0, 3, 0, 0, 0, 3, 3, 3, 0, 0, 0, 3, 0, 1
			DWORD  1, 0, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 3, 0, 1
			; Round 2
			DWORD  0, 0, 0, 5, 6, 7, 0, 0,13,14,15, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 2, 2,11, 0, 0, 0, 0
			DWORD  0, 0, 3, 3, 0, 0, 3, 0, 2, 3,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 0, 3, 0,11, 3, 0, 0, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 0, 0, 1
			DWORD  0, 3, 0, 3, 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1
			DWORD  0, 0, 3, 3, 3, 1, 1, 1, 1, 1, 0, 3, 3, 3, 0
			DWORD  0, 0, 0, 0, 3, 0, 3, 2, 2, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 3, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3,11, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 0, 0, 1
			; Round 3
			DWORD  0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0
			DWORD  0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 0, 0, 3, 0, 3, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 0, 0, 3, 0, 3, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 3, 3, 3, 0, 3, 3, 3,11,11,11, 0
			DWORD  0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 3, 2, 2, 0, 2, 2, 0, 2, 3, 3, 3, 0
			DWORD  0, 3,11, 3, 2, 0,11,11,11,11, 2, 3,11, 3, 0
			DWORD  0, 3, 3, 3, 0, 2, 2, 0, 2, 2, 0, 3,11, 3, 0
			DWORD  0,11,11,11, 0, 0, 2, 2, 2,11, 0, 3, 3, 3, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 2, 0,11, 0, 0, 0, 0, 0
			DWORD  0, 0, 2, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0
			DWORD  0, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 2, 2, 1, 0, 0, 3, 3, 3, 0, 0, 3, 3, 1, 3
			DWORD  0, 0, 0, 1, 0, 0, 3, 8, 3, 0, 0, 3, 3, 1, 3
			; Round 4
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0,11, 0
			DWORD  2, 0,11, 0, 3, 3, 3, 3, 3, 3, 3, 0,11, 0, 0
			DWORD  2, 0,11, 0, 0, 3, 3, 3, 3, 3, 0, 0,11, 0, 1
			DWORD  2, 0,11, 0, 3, 3, 0, 3, 0, 3, 3, 0,11, 0, 1
			DWORD  2, 0,11, 0, 3, 0, 0, 0, 0, 0, 3, 0,11, 0, 1
			DWORD  2, 0, 0,11, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 1
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 1, 1, 1
			DWORD  3, 3, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3
			DWORD  3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 3, 3
			DWORD  3, 1, 1, 1, 1, 1,11,11,11, 0, 0, 0, 0, 3, 3
			DWORD  0, 0, 2, 0, 0, 2, 2, 2, 2, 0, 0, 2, 2, 2, 0
			DWORD  0, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 3, 8, 3, 0, 0, 0, 0, 0, 0
			; Round 5
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0,11, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3,11, 0
			DWORD  0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 0, 2, 2, 2, 0, 3, 3, 3, 0, 2, 2, 2, 0, 0
			DWORD  0, 0, 2, 3, 0, 2, 2, 2, 2, 2, 0, 3, 2, 0, 0
			DWORD  3, 3, 2, 3, 0, 2, 3, 3, 3, 2, 0, 3, 2, 3, 3
			DWORD 11,11, 2, 3, 0, 2,11,11,11, 2, 0, 3, 2,11,11
			DWORD  0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0
			DWORD  0, 1, 1, 1, 0, 0,11,11,11, 0, 0, 1, 1, 1, 0
			DWORD  0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 0, 0
			DWORD  0, 0, 3, 1, 0, 0, 3, 3, 3, 0, 0, 1, 3, 0, 0
			DWORD  0, 0,11, 1, 0, 0, 3, 8, 3, 0, 0, 1,11, 0, 0

;RoundEnemy以三个为一节，规定了某个Round中三种飞机的最大总生命
;比如Round0无尽模式，三种飞机都是999
;Round1，只有8个基础飞机
;Round5，有8基础，5加强，5飞机王
RoundEnemy	DWORD 999,999,999,8,0,0,8,0,0,8,0,2,9,3,4,8,5,5
RoundSpeed	DWORD 1,60,60,60,50,50,1

;本项目全部使用经典的STDCALL写法，先push参数，之后call调用，栈由被调用过程清理
.code

;窗口主函数，是程序的入口（Win32程序入口不再是main）
WinMain:
		;整体过程：
		;0. 
		;1. 实例化（程序开始已做）WNDCLASS类并填充
		;2. 将WNDCLASS类注册到windows系统中，此后可以通过这个类的className字段绑定这个窗口
		;3. 创建运行窗口（注册并不等于运行），使用已注册窗口的className字段绑定
		;4. 初始化+显示窗口
		;5. 后台运行窗口的死循环消息队列，不断将消息（可以理解为用户的各种操作）发送给WinProc函数进行响应

		;1. 填充WNDCLASS类
		call Randomize	;why?

		push NULL

		call GetModuleHandle	;返回模块的句柄
		mov hInstance,eax		;hInstance中存有句柄
		
		push 999				;999代表资源里的plane.ico
		push hInstance
		call LoadIcon			;加载图标
		mov MainWin.hIcon,eax	;填充MainWin的图标信息

		push IDC_ARROW			;标准箭头常量，似乎是那个选择关卡的鼠标键
		push NULL
		call LoadCursor
		mov MainWin.hCursor,eax	;填充MainWin的游标信息？游标干啥的？TODO

		;2. 注册窗口
		push offset MainWin	
		call RegisterClass		;注册窗口类 返回一个ATOM，表示注册状态
		cmp eax,0				;是否注册成功
		je ExitProgram
		
		;3. 激活窗口，通过className绑定已注册窗口
		push NULL
		push hInstance		;IpClassName 类名
		push NULL			
		push NULL
		push 510			;x	510->	600
		push 650			;y	650->	1000
		push CW_USEDEFAULT	;nWidth
		push CW_USEDEFAULT	;nHeight 以上四个用来指定位置和大小
		push (WS_BORDER+WS_CAPTION+WS_SYSMENU)	;hWndParent ;MAIN_WINDOW_STYLE
		push offset WindowName	;hMenu	菜单的句柄
		push offset className	;hInstance	要将与窗口关联的模块的实例句柄
		push 0
		call CreateWindowEx		;使用CreateWindowEx来创建一个窗口，从这里开始运行
		cmp eax,0
		je ExitProgram		;创建失败则退出程序
		mov hMainWnd,eax	
		
		;4. 初始化并显示
		push SW_SHOW		;控件的状态 显示窗口
		push hMainWnd
		call ShowWindow
		
		push hMainWnd
		call UpdateWindow

		;5. 后台while死循环，不断获取本应用窗口上的Message，经过简单预处理后发送给WinProc回调函数处理
	MessageLoop:
		push NULL
		push NULL
		push NULL
		push offset msg
		call GetMessage	;获取消息，填充msg结构：GetMessage(&msg, NULL, 0, 0)
		
		cmp eax,0
		je ExitProgram	;如果获取消息失败就退出
		
		push offset msg
		call TranslateMessage	;调整msg内消息，转换成更好的格式
		push offset msg
		call DispatchMessage	;将消息传给WinProc回调函数，这个Dispatch函数其实是将4个参数push进栈后，调用WinProc函数
		;是否过滤消息？

		jmp MessageLoop

	ExitProgram:
		push 0
		call ExitProcess

;回调函数，用于响应窗口上产生的一切事件，比如鼠标，键盘等。
WinProc:
		;函数原型：LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
		;参数列表：
		;ebp+8：HWND hWnd,窗口句柄
		;ebp+12：UINT message, 事件类型，比如按下键盘，移动鼠标
		;ebp+16：WPARAM wParam,事件具体信息，比如键盘：
			;38上 40下 37左 39右 
			;32space 13enter 27esc
			;65a 68d 83s 87w
		;ebp+24：LPARAM lParam

		push ebp		;被调用者保存寄存器
		mov ebp,esp		;栈顶指针%esp

		;第一级分支结构，根据基本事件类型转到不同分支
		mov eax,[ebp+12]	;取message参数

		cmp eax,WM_KEYDOWN	;按下键盘，将对应的Hold变量赋1，且进行对应操作
		je KeyDownMessage
		cmp eax,WM_KEYUP	;松开键盘，将对应的Hold变量赋0
		je KeyUpMessage
		cmp eax,WM_CREATE	;在程序运行之初，初始化窗口，只会调用一次
		je CreateWindowMessage
		cmp eax,WM_CLOSE	;点击窗口右上角×号，关闭窗口，退出程序，同时销毁后台的计时器
		je CloseWindowMessage
		cmp eax,WM_PAINT	;任何对窗口的更改，都会产生一个WM_PAINT消息（包括定时器也会触发WM_PAINT）
		je PaintMessage
		cmp eax,WM_TIMER	;计时器事件，每隔一段时间重新绘制窗口（基本和PaintMessage交替出现）
		je TimerMessage
		
		jmp OtherMessage	;交由默认回调函数处理
	
		;第二级分支，通过判断具体事件类型转到不同分支
		;按键下压
		;下面的各个分支对应上下左右wasd等各种键，空格和enter执行相同功能（跳转的label相同）
		;注意，所有按键都会影响Hold变量，但是up，down，esc，space和enter会调用额外的处理函数，比如界面跳转，发射子弹等等
	KeyDownMessage:
		mov eax,[ebp+16];取wParam参数

		cmp eax,38
		jne @nup1
		call UpInMenu;上
		mov UpKeyHold,1
	@nup1:
		cmp eax,40
		jne @ndown1
		call DownInMenu;下
		mov DownKeyHold,1
	@ndown1:
		cmp eax,37
		jne @nleft1
		mov LeftKeyHold,1;左
	@nleft1:
		cmp eax,39
		jne @nright1
		mov RightKeyHold,1;右
	@nright1:
		cmp eax,32
		jne @nspace1
		mov SpaceKeyHold,1
		call EnterInMenu;空格，调用函数
	@nspace1:
		cmp eax,13
		jne @nenter1
		mov EnterKeyHold,1
		call EnterInMenu;回车，调用函数
	@nenter1:
		cmp eax,27
		jne @nescape1
		call EscapeInMenu;esc键，调用函数
	@nescape1:
		cmp eax,65
		jne @na1
		mov AKeyHold,1;A
	@na1:
		cmp eax,68
		jne @nd1
		mov DKeyHold,1;D
	@nd1:
		cmp eax,83
		jne @ns1
		mov SKeyHold,1;S
	@ns1:
		cmp eax,87
		jne @nw1
		mov WKeyHold,1;W
	@nw1:
		jmp WinProcExit;不需要处理的键
		
		;按键释放
		;结构同按键下压
	KeyUpMessage:
		mov eax,[ebp+16]

		cmp eax,38
		jne @nup2
		mov UpKeyHold,0
	@nup2:
		cmp eax,40
		jne @ndown2
		mov DownKeyHold,0
	@ndown2:
		cmp eax,37
		jne @nleft2
		mov LeftKeyHold,0
	@nleft2:
		cmp eax,39
		jne @nright2
		mov RightKeyHold,0
	@nright2:
		cmp eax,32
		jne @nspace2
		mov SpaceKeyHold,0
	@nspace2:
		cmp eax,13
		jne @nenter2
		mov EnterKeyHold,0
	@nenter2:
		cmp eax,65
		jne @na2
		mov AKeyHold,0
	@na2:
		cmp eax,68
		jne @nd2
		mov DKeyHold,0
	@nd2:
		cmp eax,83
		jne @ns2
		mov SKeyHold,0
	@ns2:
		cmp eax,87
		jne @nw2
		mov WKeyHold,0
	@nw2:
		jmp WinProcExit

		;在程序运行之初初始化窗口信息，只会调用一次
		;初始化只是给你整了个背景，把bitmap加载到内存中
		;并不涉及到飞机，地图之类的绘制，所有的绘制都由DrawUI实现
	CreateWindowMessage:
		;获取窗口句柄，初始化hMainWnd（其实在此之前已经初始化过了，或许这两个有所不同）
		mov eax,[ebp+8]
		mov hMainWnd,eax
		invoke printf,offset szMsg,eax

		push NULL
		push 30	;超时值，每30个时间单位发送一个信息，可以理解为刷新间隔，时钟周期
		push 1
		push hMainWnd
		call SetTimer	;为当前窗口加一个计时器，计时器会不断发出计时器事件
	
		push hMainWnd
		call GetDC			;获取环境上下文句柄，该函数检索一指定窗口的客户区域或整个屏幕的显示设备上下文环境的句柄
		mov hdc,eax				;返回当前窗口工作区DC句柄
		
		push eax
		call CreateCompatibleDC	;环境兼容化：该函数创建一个与指定设备兼容的内存设备上下文环境（DC）
		mov hdcPic,eax		;兼容的内存DC句柄（相当于生成个画布）
		
		push 0
		push 0
		push 0
		push 0	;type=位图
		push 1001
		push hInstance
		call LoadImageA			;加载1001号资源（对应目录下的bmp资源位图）
		mov hbitmap,eax			;返回资源图句柄
		
		push hbitmap
		push hdcPic
		call SelectObject		;把位图放到DC中

		push hdc
		call CreateCompatibleDC	;为什么这里还要创建一次？？？
		mov hdcMem,eax	;创建第二个兼容DC

		push 480	;480->100 可以大，但是不可以小
		push 640
		push hdc
		call CreateCompatibleBitmap	;该函数创建与指定的设备环境相关的设备兼容的位图
									;指定高度、宽度、设备环境句柄(按照上面入栈的顺序来看)
		
		mov hbitmap,eax	;返回创造好的位图的句柄
		
		push hbitmap	;把位图句柄				hdc
		push hdcMem		;和新的地图句柄都压入栈	hgdobj
		call SelectObject	;似乎是将两个融合在一起？？
		
		push 0FFFFFFh
		push hdcMem
		call SetTextColor	;设置新地图的文本颜色
		
		push 0
		push hdcMem
		call SetBkColor		;设置背景颜色 黑色

		push hdc
		push hMainWnd
		call ReleaseDC		;释放由调用GetDC或GetWindowDC函数获取的指定设备场景。
		
		jmp WinProcExit

		;关闭窗口事件
	CloseWindowMessage:
		;invoke printf,offset szMsg,2
		push 0
		call PostQuitMessage	;给进程发送退出指令
		push 1
		push hMainWnd
		call KillTimer	;关闭计时器
		jmp WinProcExit
		
		;绘制所有的UI
		;核心调用：DrawUI
	PaintMessage:
		invoke printf,offset szMsg,1
		push offset ps	;绘制窗口的信息都有
		push hMainWnd
		call BeginPaint
		mov hdc,eax

		push BLACK_BRUSH
		call GetStockObject
		
		push eax
		push hdcMem
		call SelectObject	;应该是绘制游戏界面中飞机数量等等信息的操作
		mov holdbr,eax
		
		push SYSTEM_FIXED_FONT
		call GetStockObject
		
		push eax
		push hdcMem
		call SelectObject
		mov holdft,eax
		
		push 480		;480->1000
		push 640
		push 0
		push 0
		push hdcMem
		call Rectangle

		call DrawUI	;调用核心的UI绘制函数，在给定背景下放置各种图片资源。所有的绘制全部由DrawUI实现。
		
		push holdbr
		push hdcMem
		call SelectObject

		push holdft
		push hdcMem
		call SelectObject
		
		push SRCCOPY
		push 0
		push 0
		push hdcMem
		push 480
		push 640
		push 0
		push 0
		push hdc
		call BitBlt		;该函数对指定的源设备环境中的像素进行位块转换，以传送到目标设备环境。
		
		push offset ps
		push hMainWnd
		call EndPaint
		
		jmp WinProcExit
	
		;计时器事件
		;核心调用：TimerTick
	TimerMessage:
		invoke printf,offset szMsg,2
		call TimerTick	;游戏开始了？？ TimerTick里面是游戏运行逻辑

		push 1
		push NULL
		push NULL
		push hMainWnd
		call RedrawWindow;重新画一遍窗口

		jmp WinProcExit
		
		;默认回调函数
	OtherMessage:	
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call DefWindowProc
		
		;退出WinProc
	WinProcExit:
		mov esp,ebp
		pop ebp
		ret 16

;上面的代码是总控区，底下的代码是具体实现过程
;核心函数：DrawSpirit 前两个参数是坐标，第三个参数是图片标号
;核心函数：DrawLine 参数为 字的标号（数量可变） xy坐标 字的数量（根据最开始的参数个数改变）。
;这两个函数的具体用法请去 DrawMenuSelect的位置参考
DrawUI:
		;第一级分支：根据WhichMenu变量判断当前所处界面，转到对应的绘制分支
		cmp WhichMenu,0
		je DrawMain
		cmp WhichMenu,1
		je DrawMode
		cmp WhichMenu,2
		je DrawGame
		cmp WhichMenu,3
		je DrawResult
		jmp DrawUIReturn

		;主界面绘制
	DrawMain:
		;绘制第一行
		push 0Fh
		push 0Eh
		push 0Dh
		push 0Ch
		push 160
		push 256
		push 4
		call DrawLine
		;绘制第二行
		push 0Eh
		push 0Fh
		push 2Dh	
		push 2Ch
		push 192
		push 256
		push 4
		call DrawLine
		;绘制选择箭头与右下角标
		jmp DrawMenuSelect
		
		;选择界面绘制
	DrawMode:
		;和DrawMain一样，先绘制几行选项
		push 15h
		push 14h
		push 17h
		push 16h
		push 160
		push 256
		push 4
		call DrawLine

		push 1Dh
		push 1Ch
		push 17h
		push 16h
		push 192
		push 256
		push 4
		call DrawLine
		
		push 15h
		push 14h
		push 17h
		push 36h
		push 224
		push 256
		push 4
		call DrawLine
		
		push 1Dh
		push 1Ch
		push 17h
		push 36h
		push 256
		push 256
		push 4
		call DrawLine
		
		push 27h
		push 26h
		push 25h
		push 24h
		push 288
		push 256
		push 4
		call DrawLine
		;和DrawMain一样，绘制选择箭头和右下角标
		jmp DrawMenuSelect
		
		;结算界面绘制，同DrawMain
	DrawResult:

		push 1Fh
		push 1Eh
		push 0Fh
		push 0Eh
		push 96
		push 256
		push 4
		call DrawLine
	
		push 27h
		push 26h
		push 25h
		push 24h
		push 160
		push 256
		push 4
		call DrawLine

		push 0Fh
		push 0Eh
		push 2Dh
		push 2Ch
		push 192
		push 256
		push 4
		call DrawLine
	
		jmp DrawMenuSelect
		
		;游戏界面绘制，与前面不同。
	DrawGame:	
		call DrawGround	;绘制土地（宇宙背景），注意，这个是在底层的黑背景上再画一层背景
		call DrawWall	;绘制墙面
		call DrawPlaneAndBullet	;绘制飞机和子弹
		call DrawTree	;绘制树
		call DrawSideBar;绘制右边计数
		
		jmp DrawUIReturn
	
		;选项箭头+右下角标志绘制，适用于0,1,3号界面
	DrawMenuSelect:
		;右下角绘制，给定4个字，xy坐标，以及4。告诉你有4个字，之后调用DrawLine将一行图片放置上去
		push 0Bh	;0Bh->0Ch
		push 09h
		push 35h
		push 34h
		;push 0Bh	;从无到有，五字测试
		push 448;448->110 y轴位置
		push 480;480->110 x轴位置
		push 4	;4->5 5字测试
		call DrawLine
		;箭头绘制，只需要调用DrawSpirit（单块绘制）即可
		;前两个参数是坐标，第三个参数是图片标号（10对应箭头）
		mov eax,SelectMenu
		sal eax,5	;y轴偏移
		add eax,160
		push eax
		push 220	;x轴偏移
		push 10		;图片标号
		call DrawSpirit
		
	DrawUIReturn:
		ret

;绘制半个图片（用于绘制半个墙）
DrawHalfSpirit:
		push ebp
		mov ebp,esp
		push ecx
		push edx

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5
		
		mov ecx,[ebp+12]

		push 0FF00h
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		push eax
		push ebx
		push hdcPic
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		mov edx,[DWORD PTR ebp+20]
		add edx,[DrawHalfSpiritMask+48+ecx*4]
		push edx
		mov edx,[DWORD PTR ebp+16]
		add edx,[DrawHalfSpiritMask+32+ecx*4];32
		push edx
		push hdcMem
		call TransparentBlt

		pop edx
		pop ecx
		mov esp,ebp
		pop ebp

		ret 16

;绘制一个图片
;核心函数：DrawSpirit 前两个参数是坐标，第三个参数是图片标号	
DrawSpirit:
		push ebp
		mov ebp,esp

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5

		push 0FF00h			;透明色
		push 32	;32->16源高度 似乎变长了？？
		push 32	;32->16源宽度
		push eax
		push ebx
		push hdcPic
		push 32	;32->16
		push 32	;32->16	好像是整体图的宽度 直接缩减了0.5倍 背景色为黑色都漏出来了
		push [DWORD PTR ebp+16];不清楚到底想要读取哪个地址上的信息
		push [DWORD PTR ebp+12]
		;上面应该是想要在hdc上绘制的内容；
		push hdcMem
		call TransparentBlt		;包含透明色的位图绘制

		mov esp,ebp
		pop ebp

		ret 12

;绘制一行图片（封装DrawSpirit）
;核心函数：DrawLine 参数为 字的标号（数量可变） xy坐标 字的数量（根据最开始的参数个数改变）。
DrawLine:
		mov ecx,[esp+4]
		cmp ecx,0
		je DrawLineReturn

		push ebp
		mov ebp,esp
		cmp ecx,0
		mov esi,ebp
		add esi,20
		mov eax,[ebp+12]
	DrawLineLoop:
		push ecx
		push eax
		
		push [ebp+16]
		push eax
		push [esi]
		call DrawSpirit

		pop eax
		pop ecx
		add esi,4
		add eax,32
		loop DrawLineLoop
		
		mov esp,ebp
		pop ebp
		sub esi,16
		mov eax,[esp]
		mov esp,esi
		mov [esp],eax

	DrawLineReturn:
		ret 12

;按键控制
;上下按键会影响SelectMenu值，下一次渲染的时候根据SelectMenu值确定箭头位置
;上
UpInMenu:
		;上移，界限为当前界面的第一个选项	
		dec SelectMenu
		cmp SelectMenu,0 ;if SelectMenu<0 then SelectMenu=0（保证菜单在范围内）
		jnl UpInMenuReturn
		mov SelectMenu,0	
	UpInMenuReturn:
		ret
;下		
DownInMenu:
		;下移，界限为当前界面的最后一个选项	
		push eax;被调用保护eax
		inc SelectMenu
		mov ebx,WhichMenu
		mov eax,[ButtonNumber+ebx*4];获取当前页面内的最大选项数
		dec eax; 修正，把最大图标数转为最大选项索引
		cmp SelectMenu,eax	;if SelectMenu>最大索引 then SelectMenu=最大索引
		jng DownInMenuReturn
		mov SelectMenu,eax
	DownInMenuReturn:
		pop eax
		ret
;enter/space键响应		
EnterInMenu:
		;本函数大量使用if-else if-else if-else的分支判断
		push eax;保护eax
		;第一层分支，判断当前所处界面
		cmp WhichMenu,2	;游戏界面，直接跳出分支（保留EnterHold和SpaceHold，刷新的时候要用这个发子弹）
		je EnterInMenuReturn
		mov SpaceKeyHold,0;不发射子弹则清零两个键（防止影响子弹发射）
		mov EnterKeyHold,0
		cmp WhichMenu,0	;初始界面
		je EnterInMain
		cmp WhichMenu,1	;模式选择
		je EnterInMode
		cmp WhichMenu,3	;结束界面
		je EnterInResult
		jmp EnterToEndGame;意外情况结束游戏

		;第二层分支
		;下面的EnterInXX都是在XX界面进行跳转分支判断

		;0号界面转移（初始界面）
	EnterInMain:
		cmp SelectMenu,0
		je EnterToMode;0号选项，对应选择模式
		cmp SelectMenu,1
		je EnterToEndGame;否则就是1号选项，对应退出游戏
		jmp EnterToEndGame;选到了其他选项暂定退出，后续可以考虑加继续游戏的分支

		;1号界面转移（模式选择）
	EnterInMode:
		cmp SelectMenu,4;选项4，返回上层
		je EnterToMain
		;剩下的0123选项都是进入游戏，只不过游戏模式不同
		jmp EnterToGame ;转移到游戏界面，在转换过程中要对GameMode和IsDoublePlayer进行赋值，赋值后统一切换到界面2
		jmp EnterInMenuReturn

		;3号界面转移（结算界面）
	EnterInResult:
		cmp SelectMenu,0
		je EnterToMain	;0对应返回主界面
		jmp EnterToEndGame	;1对应退出游戏

		;以下的EnterToXX都是要通过Enter切换到XX界面

		;转移到0：初始界面
	EnterToMain:
		mov WhichMenu,0
		mov SelectMenu,0
		jmp EnterInMenuReturn
	
		;转移到1：模式选择
	EnterToMode:
		mov WhichMenu,1
		jmp EnterInMenuReturn

		;转移到2：游戏界面
		;转移前进行模式赋值
	EnterToGame:
		mov eax,SelectMenu
		and eax,1;取SelectMenu最后一位
		mov GameMode,eax;0，2变成0，对应闯关模式，1,3变成1，对应挑战模式
		mov eax,SelectMenu
		sar eax,1;算数右移，00b和01b都会变成00b，对应单人模式,10b和11b都会变成11b，对应双人模式
		mov IsDoublePlayer,eax	
		mov WhichMenu,2
		call ResetField;游戏初始化？TODO
		jmp EnterInMenuReturn

		;退出游戏
	EnterToEndGame:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
	
	EnterInMenuReturn:
		pop eax
		ret

;esc键响应
EscapeInMenu:
		;按ESC回退到初始界面，可以在初始界面再加一个继续游戏（只要保证其他数据不被修改即可）
		mov SelectMenu,0
		mov WhichMenu,0
		ret


;重置数据
ResetField:
		mov [Score],0
		mov [Score+4],0	;重置两个分数（右下角显示）

		mov eax,GameMode
		mov ebx,1
		sub ebx,eax
		mov [Round],ebx	;Round=1-GameMode，如果GameMode=1（挑战），则Round=0，如果GameMode=0（闯关），则Round=1
		;Round决定了你用哪个地图，0对应无尽模式，12345对应挑战模式的5个关卡
		mov [YourLife],5	
		mov [YourLife+4],5	;重置两个生命
		
		mov YouDie,0	;存活状态
		call NewRound
		ret

;初始化函数
NewRound:
		mov WaitingTime,-1
		;玩家1
		mov [YourPlane],5	;plane number 1->2 开始的时候是哪个飞机
		mov [YourPlane+4],128;飞机左移到边界,飞机初始位置横坐标
		mov [YourPlane+8],448;飞机初始位置纵坐标
		mov [YourPlane+12],3 ;飞机初始朝向，0向右，顺时针增加0-3
		mov [YourPlane+16],7 ;子弹类型
		;玩家2
		mov [YourPlane+32],2
		mov [YourPlane+36],320
		mov [YourPlane+40],448
		mov [YourPlane+44],3
		mov [YourPlane+48],0
		;判断是否双人，双人就把玩家2标志清0，则后面绘制的时候就不会对玩家2相关数据进行绘制
		cmp IsDoublePlayer,0
		jne InitEnemyLife
		mov [YourPlane+32],0	;把玩家2的飞机和生命都清0
		mov [YourLife+4],0
		;注意，这里没有jmp，所以无论单人还是双人，都会执行下面的InitEnemyLife

		;初始化飞机生命，详见初始数据区关于说明RoundEnemy的说明
	InitEnemyLife:
		mov eax,[Round]	;计算偏置：ebx=Round×12，因为一个关卡对应3个DWORD数据
		mov ebx,12
		mul ebx
		mov ebx,eax	

		mov eax,[RoundEnemy+ebx] ;根据关卡初始化三种飞机的总生命
		mov [EnemyLife],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [EnemyLife+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [EnemyLife+8],eax
		
		;清空敌方飞机和子弹（对应10行EnemyPlane）
		mov ecx,10	
		mov esi,offset EnemyPlane
	RemoveEnemyPlane:
		mov DWORD ptr [esi],0	;标记飞机为0不存在
		mov DWORD ptr [esi+16],0;标记子弹为0不存在
		add esi,32				;换下一行（下一个飞机）
		loop RemoveEnemyPlane
		
		;初始化地图
		mov eax,[Round]
		mov ebx,225*4
		mul ebx
		mov ebx,eax	;ebx=Round×225×4，锁定了当前Round在RoundMap中的偏移量
		mov ecx,225	;对应225个地图块，循环225次，把RoundMap中Round对应的地图放到Map中
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap

		ret

;绘制地面
DrawGround:
		;225代表一个地图 225*4代表一个地图的大小
		mov ecx,225
	DrawGroundLoop:
	;画地面函数(泥土巴拉巴拉)
		mov edx,0
		mov eax,ecx
		dec eax;eax=ecx-1	224
		mov esi,15
		div esi;edx=eax%15,eax=eax/15,eax每15轮减一，edx每轮减一，每个地图15列15行，edx是列，eax是行
		sal edx,5;起始map1【14,14】，这一步扩展到【448,448】
		sal eax,5
		add edx,80;【448,528】
		
		cmp [Map+ecx*4-4],1	;为什么会存着1呢？
		je DrawGroundWater
		
		push ecx
		push eax
		push edx
		push 0
		call DrawSpirit
		pop ecx
	
		loop DrawGroundLoop
		jmp DrawGroundReturn
		
	DrawGroundWater:
	
		push ecx
		mov ebx,[WaterSpirit]
		sar ebx,2
		sar eax,5
		sar edx,5
		add ebx,eax
		add ebx,edx
		and ebx,3
		add ebx,3
		sal eax,5
		sal edx,5
		add edx,16
		push eax
		push edx
		push ebx
		call DrawSpirit
		pop ecx
		
		loop DrawGroundLoop
		
	DrawGroundReturn:
		ret

DrawWall:
		mov ecx,225
	DrawWallLoop:
		mov edx,0
		mov eax,ecx ;eax=225
		dec eax
		mov esi,15
		div esi;edx=eax%15,eax=eax/15,eax每15轮减一，edx每轮减一，每个地图15列15行，edx是列，eax是行
		sal edx,5
		sal eax,5
		add edx,80
		
		;判断地图矩阵中的值属于哪一个，然后去对应的函数进行绘制
		test [Map+ecx*4-4],4 ;似乎没有出现
		jnz DrawWallHalf
		cmp [Map+ecx*4-4],3	;砖墙
		je DrawWallBlock
		cmp [Map+ecx*4-4],11;铁墙
		je DrawWallMetal
		cmp [Map+ecx*4-4],8	;老家
		je DrawWallBase
		
	DrawWallDoLoop:
		loop DrawWallLoop
		jmp DrawWallReturn
	
	DrawWallBlock:
		push ecx
		push eax
		push edx
		push 1
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	
	DrawWallMetal:
		push ecx
		push eax
		push edx
		push 2
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallBase:
		push ecx
		push eax
		push edx
		push 8	;红旗子
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
		
	DrawWallHalf:
		test [Map+ecx*4-4],8;半个墙的逻辑是个啥。。。+
		jnz DrawMetalWallHalf
		mov ebx,[Map+ecx*4-4]
		and ebx,3 ;ebx=8 and 3? 0???

		push ecx
		push eax
		push edx
		push ebx  ;0
		push 1
		call DrawHalfSpirit 
		pop ecx
		jmp DrawWallDoLoop

	DrawMetalWallHalf:
		mov ebx,[Map+ecx*4-4]
		and ebx,3
		push ecx
		push eax
		push edx
		push ebx
		push 2
		call DrawHalfSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallReturn:
		ret

DrawPlaneAndBullet:
;绘制飞机和子弹，根据yourplane的参数来选择对应的位图来实现绘制

		mov esi,offset YourPlane
		mov ecx,12	;why 12 times? 我发现改了之后并不会影响实际的子弹的运行，反倒是飞机隐形了。。。
	DrawPlaneAndBulletLoop:
		push esi
		mov eax,0
		cmp [esi],eax;飞机是否为0
		je GoToDrawBulletIThink
		push ecx
		mov eax,[esi];第几种飞机
		inc eax
		sal eax,3
		;找到位图中的地址
		add eax,[esi+12]
		mov ebx,[esi+4]
		add ebx,80
		
		push [esi+8]
		push ebx
		push eax
		;将位置、初始朝向都压入栈 使用drawspirit来绘制
		call DrawSpirit
		pop ecx

	GoToDrawBulletIThink:
		mov esi,[esp];应该还是esi
		add esi,16	;跳转到子弹的描述部分
		mov eax,0
		cmp [esi],eax	;是否为0（不存在）
		je DrawPlaneAndBulletLoopContinue
		push ecx
		mov eax,[esi]
		add eax,54
		mov ebx,[esi+4]
		add ebx,80

		push [esi+8]
		push ebx
		push eax
		call DrawSpirit
		pop ecx
		
	DrawPlaneAndBulletLoopContinue:
		pop esi
		add esi,32	;跳转到下一个飞机，进行绘制 最多可以存在12个吧？
		loop DrawPlaneAndBulletLoop
		ret

DrawTree:
;画树的部分
		mov ecx,225
	DrawTreeLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		cmp [Map+ecx*4-4],2
		je DrawTreeReal

		loop DrawTreeLoop
		jmp DrawTreeReturn
		
	DrawTreeReal:
	
		push ecx
		push eax
		push edx
		push 7	;位图的第七个 为啥没有了，，，
		call DrawSpirit
		pop ecx
		
		loop DrawTreeLoop

	DrawTreeReturn:
		ret
		
DrawSideBar:
;画边框里的内容
		mov ecx,5
		mov eax,64	;64->10
		mov ebx,16
		mov esi,offset YourLife ;生命（两个玩家的）
	DrawSideBarLoop:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax	;Y偏移量
		push 568	;568->	X偏移位置
		push ebx	;16
		call DrawSpirit
		
		;命的数字
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h	;48
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
		push 1
		push offset ScoreText
		push eax
		push 608		;608->1000
		push hdcMem
		call TextOut	;输出文本
		
		pop eax
		pop ecx
		pop ebx
		pop esi
		add esi,4
		add ebx,8	;换做位图中下一个飞机来绘制
		add eax,48
		loop DrawSideBarLoop
		
		mov eax,0
	DrawSideBarRepeat:
	;绘制得分板 我感觉是无限循环的。。。
	;（因为eax被保护了 函数结束之后就Pop，理论上得分之后只用更新score即可，然后这里不断读取score的内容）
		push eax
		sal eax,6
		add eax,320	;320 “分数”的Y位置
		push 2Fh
		push 2Eh
		push eax
		push 568
		push 2
		call DrawLine
		;绘制“分数”

		;每次更新分数板的操作
		mov esi,[esp]			;仍然代表的是两个玩家 plane
		mov eax,[Score+4*esi]	;两个玩家对应的分数
		mov esi,offset ScoreText;esi对应分数板字符串
		add esi,5
		mov ecx,6	;6  代表更新多少位（有6位）
		mov ebx,10
	DrawSideBarGetScoreText:
	;将score中的数字转化为字符后存在对应的scoretest中
		mov edx,0
		div ebx
		add edx,30h	;分数(eax)除以10 余数在edx，数字转化为字符
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText

		;绘制分数板的过程
		mov edi,[esp]
		sal edi,6
		add edi,360
		push 6
		push offset ScoreText
		push edi
		push 576
		push hdcMem
		call TextOut

		push 2Fh
		push 2Eh
		push 320
		push 568
		push 2
		call DrawLine
		
		pop eax
		cmp eax,0
		mov eax,1
		je DrawSideBarRepeat

		ret

;TODO根据按下的按键修改状态。修改后交由PaintMessage里的DrawUI刷新
TimerTick:
		cmp WaitingTime,0;用来判断不同状态
		jl DontWait
		je ChangeGame
		dec WaitingTime
		jmp DontWait
	ChangeGame:
		cmp YouDie,1
		jne NotGameOver
		mov WhichMenu,3;游戏结束
		mov SelectMenu,0
	NotGameOver:
		call NewRound
		mov WaitingTime,-1
	DontWait:

		inc WaterSpirit
		and WaterSpirit,0Fh

		cmp WhichMenu,2;正在游戏
		je TimerTickDontReturn
		jmp TimerTickReturn
	TimerTickDontReturn:
		
		cmp UpKeyHold,1;向上键
		jne TT@1
		mov [YourPlane+12],3;移动方向
		sub [YourPlane+8],4;移动的距离
		push offset YourPlane
		push 1
		call CheckCanGo
		test eax,1
		jz TT@1Bad
		push offset YourPlane
		call GetPlaneRect
		push offset YourPlane
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@4
	TT@1Bad:
		add [YourPlane+8],4
		jmp TT@4
	TT@1:
		cmp DownKeyHold,1
		jne TT@2
		mov [YourPlane+12],1
		add [YourPlane+8],4
		push offset YourPlane
		push 1
		call CheckCanGo
		test eax,1
		jz TT@2Bad
		push offset YourPlane
		call GetPlaneRect
		push offset YourPlane
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@4
	TT@2Bad:
		sub [YourPlane+8],4
		jmp TT@4
	TT@2:
		cmp LeftKeyHold,1
		jne TT@3
		mov [YourPlane+12],2
		sub [YourPlane+4],4
		push offset YourPlane
		push 1
		call CheckCanGo
		test eax,1
		jz TT@3Bad
		push offset YourPlane
		call GetPlaneRect
		push offset YourPlane
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@4
	TT@3Bad:
		add [YourPlane+4],4
		jmp TT@4
	TT@3:
		cmp RightKeyHold,1
		jne TT@4
		mov [YourPlane+12],0
		add [YourPlane+4],4
		push offset YourPlane
		push 1
		call CheckCanGo
		test eax,1
		jz TT@4Bad
		push offset YourPlane
		call GetPlaneRect
		push offset YourPlane
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@4
	TT@4Bad:
		sub [YourPlane+4],4
		jmp TT@4
	TT@4:
		cmp EnterKeyHold,1
		je TT@5@@
		cmp SpaceKeyHold,1
		jne TT@5
		cmp IsDoublePlayer,0
		jne TT@5
	TT@5@@:
		cmp DWORD ptr [YourPlane+16],0
		jne TT@5
		cmp DWORD ptr [YourPlane],0
		je TT@5
		mov ebx,[YourPlane+12]
		mov [YourPlane+16],1
		mov eax,[YourPlane+4]
		add eax,[BulletPosFix+4*ebx]
		mov [YourPlane+20],eax
		mov eax,[YourPlane+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourPlane+24],eax
		mov eax,[YourPlane+12]
		mov [YourPlane+28],eax
	TT@5:
	
		cmp WKeyHold,1
		jne TT@6
		mov [YourPlane+12+32],3
		sub [YourPlane+8+32],4
		push offset YourPlane+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@6Bad
		push offset YourPlane+32
		call GetPlaneRect
		push offset YourPlane+32
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@9
	TT@6Bad:
		add [YourPlane+8+32],4
		jmp TT@9
	TT@6:
		cmp SKeyHold,1
		jne TT@7
		mov [YourPlane+12+32],1
		add [YourPlane+8+32],4
		push offset YourPlane+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@7Bad
		push offset YourPlane+32
		call GetPlaneRect
		push offset YourPlane+32
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@9
	TT@7Bad:
		sub [YourPlane+8+32],4
		jmp TT@9
	TT@7:
		cmp AKeyHold,1
		jne TT@8
		mov [YourPlane+12+32],2
		sub [YourPlane+4+32],4
		push offset YourPlane+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@8Bad
		push offset YourPlane+32
		call GetPlaneRect
		push offset YourPlane+32
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@9
	TT@8Bad:
		add [YourPlane+4+32],4
		jmp TT@9
	TT@8:
		cmp DKeyHold,1
		jne TT@9
		mov [YourPlane+12+32],0
		add [YourPlane+4+32],4
		push offset YourPlane+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@9Bad
		push offset YourPlane+32
		call GetPlaneRect
		push offset YourPlane+32
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		je TT@9
	TT@9Bad:
		sub [YourPlane+4+32],4
		jmp TT@9
	TT@9:
		cmp SpaceKeyHold,1
		jne TT@10
		cmp DWORD ptr [YourPlane+16+32],0
		jne TT@10
		cmp DWORD ptr [YourPlane+32],0
		je TT@10
		mov ebx,[YourPlane+12+32]
		mov [YourPlane+16+32],1
		mov eax,[YourPlane+4+32]
		add eax,[BulletPosFix+4*ebx]
		mov [YourPlane+20+32],eax
		mov eax,[YourPlane+8+32]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourPlane+24+32],eax
		mov eax,[YourPlane+12+32]
		mov [YourPlane+28+32],eax
	TT@10:
		mov ecx,12
		lea esi,YourPlane+16
		jmp TTLoopForBullet
		
	TTLoopForBulletContinue:
		add esi,32
		loop TTLoopForBullet
		jmp TTLoopForBulletDone
		
	TTLoopForBullet:
		cmp DWORD ptr [esi],0
		je TTLoopForBulletContinue
		cmp DWORD ptr [esi],1
		je TTBulletCanMove
		inc DWORD ptr [esi]
		cmp DWORD ptr [esi],10
		jl TTLoopForBulletContinue
		mov DWORD ptr [esi],0
		jmp TTLoopForBulletContinue
	TTBulletCanMove:
		mov ebx,[esi+12]
		mov eax,[esi+4]
		add eax,[BulletMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[BulletMove+16+4*ebx]
		mov [esi+8],eax
		push esi
		push ecx
		push esi
		push 0
		call CheckCanGo
		test eax,1
		jnz TTBreakDone
		mov esi,BreakWallType
		mov edi,BreakWallPos
		cmp edi,225
		jge TTBreakDone
		cmp esi,3
		je TTBreakWall
		cmp esi,11
		je TTBreakMetal
		test esi,4h
		jnz TTBreakHalf
		jmp TTBreakDone
	TTBreakMetal:
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTBreakWall:
		mov esi,[esp+4]
		mov ebx,[esi+12]
		mov eax,[Map+edi*4]
		add eax,[DirectionMapToW+4*ebx]
		mov [Map+edi*4],eax
		mov eax,0
		jmp TTBreakDone
	TTBreakHalf:
		test esi,8h
		jz TTHalfNotMatel
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTHalfNotMatel:
		mov [Map+edi*4],0
	TTBreakDone:
		pop ecx
		pop esi
		test eax,1
		jz TTBulletBoom
		push ecx
		
		push esi
		call GetBulletRect
		
		push esi
		sub esi,16
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTCheckBulletDoom
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jz TTBulletHitPlane
		jmp TTCheckBulletDoom
		
	TTBulletHitPlane:
		mov edi,[ebx]
		mov DWORD ptr [ebx],0
		push ebx
		call IsEnemy
		cmp eax,1
		jne TTYouDie
		push esi
		sub esi,16
		sub esi,offset YourPlane
		sar esi,3
		add [Score+esi],200
		sub edi,3
		sal edi,6
		add [Score+esi],edi
		pop esi
		call HaveEnemy
		test eax,1
		jnz TTBulletBoom
		cmp [EnemyLife],0
		jne TTBulletBoom
		cmp [EnemyLife+4],0
		jne TTBulletBoom
		cmp [EnemyLife+8],0
		jne TTBulletBoom
		mov WaitingTime,20
		inc DWORD ptr [Round]
		jmp TTBulletBoom
	TTYouDie:
		cmp DWORD ptr [YourLife],0
		jne TTBulletBoom
		cmp DWORD ptr [YourLife+4],0
		jne TTBulletBoom
		jmp TTYouReallyDie
		
	TTYouReallyDie:
		mov WaitingTime,20
		mov YouDie,1
		jmp TTBulletBoom
		
	TTCheckBulletDoom:
		push ecx
		push esi
		call GetBulletRect
		
		push esi
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetBulletInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTLoopForBulletContinue
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jnz TTLoopForBulletContinue
		inc DWORD ptr [ebx]

	TTBulletBoom:
		inc DWORD ptr [esi]
		jmp TTLoopForBulletContinue
	TTLoopForBulletDone:
		mov ebx,[Round]
		mov eax,[RoundSpeed+ebx*4]
		call RandomRange
		cmp eax,0
		jne TTCreateNewEnemyDone
		call CreateRandomEnemy
	TTCreateNewEnemyDone:
	
		mov ecx,10
		mov esi,offset EnemyPlane
		jmp TTLoopForEnemy
	TTEnemyLoopEnd:
		add esi,32
		loop TTLoopForEnemy
		jmp TTEnemyLoopDone
		
	TTLoopForEnemy:
		cmp DWORD ptr [esi],0
		je TTEnemyLoopEnd
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		add eax,[PlaneMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[PlaneMove+16+4*ebx]
		mov [esi+8],eax
		push esi
		push ecx
		push esi
		push 1
		call CheckCanGo
		pop ecx
		pop esi
		test eax,1
		jz TTEnemyCantGo

		push ecx
		push esi
		push esi
		call GetPlaneRect
		mov esi,[esp]
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetPlaneInRect
		cmp eax,0
		pop esi
		pop ecx
		je TTEnemyCanGo

	TTEnemyCantGo:
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		sub eax,[PlaneMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		sub eax,[PlaneMove+16+4*ebx]
		mov [esi+8],eax
		mov eax,4
		call RandomRange
		mov [esi+12],eax
	TTEnemyCanGo:
	
		cmp DWORD ptr [esi+16],0
		jne TTEnemyDontShoot
		mov ebx,[esi+12]
		mov DWORD ptr [esi+16],1
		mov eax,[esi+4]
		add eax,[BulletPosFix+4*ebx]
		mov [esi+20],eax
		mov eax,[esi+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [esi+24],eax
		mov eax,[esi+12]
		mov [esi+28],eax
	TTEnemyDontShoot:
		jmp TTEnemyLoopEnd
	TTEnemyLoopDone:
		
		cmp DWORD ptr [Map+217*4],0
		je TTBeseNotThreatened
		push 0
		push 474
		push 250
		push 454
		push 230
		call GetBulletInRect
		cmp eax,0
		je TTBeseNotThreatened
		mov [Map+217*4],0
		mov DWORD ptr [eax],2
		mov YouDie,1
		mov WaitingTime,20
	TTBeseNotThreatened:
	
		cmp [YourPlane],0
		jne TTYouDontNeedResetPlaneA
		cmp [YourLife],0
		jle TTYouDontNeedResetPlaneA
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedResetPlaneA
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetPlaneInRect
		cmp eax,0
		jne TTYouDontNeedResetPlaneA
		mov [YourPlane],1
		mov [YourPlane+4],128
		mov [YourPlane+8],448
		mov [YourPlane+12],3
		dec [YourLife]
	TTYouDontNeedResetPlaneA:
			
		cmp [YourPlane+32],0
		jne TTYouDontNeedResetPlaneB
		cmp [YourLife+4],0
		jle TTYouDontNeedResetPlaneB
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedResetPlaneB
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetPlaneInRect
		cmp eax,0
		jne TTYouDontNeedResetPlaneB
		mov [YourPlane+32],2
		mov [YourPlane+4+32],320
		mov [YourPlane+8+32],448
		mov [YourPlane+12+32],3
		dec [YourLife+4]
	TTYouDontNeedResetPlaneB:
	
	TimerTickReturn:
		ret
		
FromOnePart:
		mov eax,1
		cmp DWORD ptr [esp+4],offset EnemyPlane
		jb FOP1
		xor eax,1
	FOP1:
		cmp DWORD ptr [esp+8],offset EnemyPlane
		jb FOP2
		xor eax,1
	FOP2:
		ret 8

IsEnemy:
		mov eax,0
		cmp DWORD ptr [esp+4],offset EnemyPlane
		jb NoIsntEnemy
		mov eax,1
	NoIsntEnemy:
		ret 4

HaveEnemy:
		push ecx
		push esi
		mov eax,0
		mov ecx,10
		mov esi,offset EnemyPlane
	HaveEnemyLoop:
		cmp DWORD ptr[esi],0
		je NoEnemy
		mov eax,1
		jmp HaveEnemyLoopDone
	NoEnemy:
		add esi,32
		loop HaveEnemyLoop
	HaveEnemyLoopDone:
		pop esi
		pop ecx
		ret

CreateRandomEnemy:
		mov eax,3
		call RandomRange
		mov edi,eax
		
		cmp DWORD ptr [EnemyLife+edi*4],0
		jle CreateEnemyRetry
		mov ecx,10
		mov esi,offset EnemyPlane
		jmp SearchForIdle

	CreateEnemyRetry:
		cmp [EnemyLife],0
		jne CreateRandomEnemy
		cmp [EnemyLife+4],0
		jne CreateRandomEnemy
		cmp [EnemyLife+8],0
		jne CreateRandomEnemy
		jmp CreateRandomEnemyDone
	SearchForIdle:
		cmp DWORD ptr [esi],0
		je SearchForIdleDone
		add esi,32
		loop SearchForIdle
		jmp CreateRandomEnemyDone
	SearchForIdleDone:
		mov eax,3
		call RandomRange

		mov ebx,[RandomPlace+eax*4]

		push 0
		push 32
		add ebx,32
		push ebx
		push 0
		sub ebx,32
		push ebx
		call GetPlaneInRect
		cmp eax,0
		jne CreateRandomEnemyDone

		dec [EnemyLife+edi*4]
		add edi,3
		mov DWORD ptr [esi],edi
		mov DWORD ptr [esi+4],ebx
		mov DWORD ptr [esi+8],0
		mov DWORD ptr [esi+12],1
	CreateRandomEnemyDone:
		ret

GetPlaneInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourPlane
	GetPlaneLoop:
		cmp DWORD ptr [esi],0
		je GetPlaneLoopContinue
		cmp esi,[ebp+24]
		je GetPlaneLoopContinue
		push ecx
		push esi
		call GetPlaneRect
		push edx
		push ecx
		push ebx
		push eax
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetPlaneLoopSucceed
	GetPlaneLoopContinue:
		add esi,32
		loop GetPlaneLoop
	GetPlaneLoopFail:
		mov eax,0
		jmp GetPlaneDone
	GetPlaneLoopSucceed:
		mov eax,esi
	GetPlaneDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20
		

GetBulletInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourPlane
		add esi,16
	GetBulletLoop:
		cmp DWORD ptr [esi],1
		jne GetBulletLoopContinue
		cmp esi,[ebp+24]
		je GetBulletLoopContinue
		push ecx
		push esi
		call GetBulletRect
		push edx
		push ecx
		push ebx
		push eax
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetBulletLoopSucceed
	GetBulletLoopContinue:
		add esi,32
		loop GetBulletLoop
	GetBulletLoopFail:
		mov eax,0
		jmp GetBulletDone
	GetBulletLoopSucceed:
		mov eax,esi
	GetBulletDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20

		
CheckCanGo:
		push ebp
		mov ebp,esp
		mov esi,[ebp+12]
		cmp DWORD ptr [ebp+8],1
		jne CheckBulletCanGo

		push esi
		call GetPlaneRect
		jmp CheckPlaneCanGo
	CheckBulletCanGo:
	
		push esi
		call GetBulletRect
	CheckPlaneCanGo:
		mov BreakWallPos,1000
		cmp eax,0
		jl CheckCanGoFail
		cmp ebx,0
		jl CheckCanGoFail
		cmp ecx,480
		jg CheckCanGoFail
		cmp edx,480
		jg CheckCanGoFail
		
		sub esp,24
		mov [ebp-4],eax
		mov [ebp-8],ebx
		mov [ebp-12],ecx
		mov [ebp-16],edx
		
		mov esi,eax
		mov edi,ebx
		sar esi,5
		sar edi,5
		mov [ebp-20],esi
		mov [ebp-24],edi

		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-20]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-24]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		dec DWORD ptr [ebp-20]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		mov eax,1
		jmp CheckCanGoReturn
		
	CheckCanGoFail:
		mov eax,0
	CheckCanGoReturn:
		mov esp,ebp
		pop ebp
		ret 8

GetBulletRect:	; &bullet
		mov esi,[esp+4]
		mov eax,[esi+4]
		mov ebx,[esi+8]
		add eax,10
		add ebx,10
		mov ecx,eax
		mov edx,ebx
		add ecx,12
		add edx,12
		ret 4
		
GetPlaneRect:	; &plane
		mov esi,[esp+4];esi = yourplane
		mov eax,[esi+4];eax = x
		mov ebx,[esi+8];ebx = y
		add eax,4
		add ebx,4
		mov ecx,eax
		mov edx,ebx
		add ecx,24
		add edx,24;飞机位置矩阵的4个坐标
		ret 4

GetBlockRect:	; x,y,isplane
		push ebp
		mov ebp,esp
		mov eax,[ebp+12]
		mov ebx,15
		mul ebx
		mov ebx,[ebp+8]
		add eax,ebx
		mov ebx,eax
		mov eax,[Map+ebx*4]
		mov BreakWallType,eax
		mov BreakWallPos,ebx
		cmp DWORD ptr [ebp+8],15
		jge NoBlock
		cmp DWORD ptr [ebp+12],15
		jge NoBlock
		cmp ebx,225
		jge NoBlock
		cmp eax,0
		je NoBlock
		cmp eax,2
		je NoBlock
		cmp eax,8
		je NoBlock
		cmp DWORD ptr [ebp+16],1
		je @@notbullet
		cmp eax,1
		je NoBlock
	@@notbullet:
		cmp eax,1
		je AllBlock
		cmp eax,3
		je AllBlock
		cmp eax,11
		je AllBlock
	
		and eax,3h
		mov esi,eax
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		add eax,[DrawHalfSpiritMask+32+esi*4]
		add ebx,[DrawHalfSpiritMask+48+esi*4]
		mov ecx,eax
		mov edx,ebx
		add ecx,[DrawHalfSpiritMask+esi*4]
		add edx,[DrawHalfSpiritMask+16+esi*4]

		jmp GetBlockRectReturn
	AllBlock:
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		mov ecx,eax
		add ecx,32
		mov edx,ebx
		add edx,32
		jmp GetBlockRectReturn
	NoBlock:
		mov eax,-1
		mov ebx,-1
		mov ecx,-1
		mov edx,-1
		jmp GetBlockRectReturn
	GetBlockRectReturn:
		mov esp,ebp
		pop ebp
		ret 12
		
RectConflict:	;r1x1,r1y1,r1x2,r1y2,r2x1,r2y1,r2x2,r2y2
		push ebp
		mov ebp,esp
		
		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		mov eax,[ebp+20]
		dec eax
		push eax
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		mov eax,[ebp+16]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		mov eax,[ebp+20]
		dec eax
		push eax
		mov eax,[ebp+16]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		mov eax,[ebp+36]
		dec eax
		push eax
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		mov eax,[ebp+32]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		mov eax,[ebp+36]
		dec eax
		push eax
		mov eax,[ebp+32]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		mov eax,0
		jmp RectConflictFail
	RectConflictSucceed:
		mov eax,1
	RectConflictFail:
		mov esp,ebp
		pop ebp
		ret 32

PointInRect:	;x1,y1,rx1,ry1,rx2,ry2
		mov eax,0
		mov ebx,[esp+4]
		mov ecx,[esp+8]
		cmp [esp+12],ebx
		jg PointInRectFail
		cmp [esp+20],ebx
		jle PointInRectFail
		cmp [esp+16],ecx
		jg PointInRectFail
		cmp [esp+24],ecx
		jle PointInRectFail
		mov eax,1
	PointInRectFail:
		ret 24
		
END WinMain
