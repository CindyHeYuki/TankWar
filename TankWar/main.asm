
.386
.model flat,STDCALL


INCLUDE C:\masm32\include\GraphWin.inc
INCLUDE gdi32.inc
INCLUDE msimg32.inc
INCLUDELIB gdi32.lib
INCLUDELIB msimg32.lib
INCLUDELIB C:\masm32\lib\irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDE C:\masm32\include\bhw.inc



WriteDec PROTO
Crlf PROTO

.data

WindowName BYTE "Tank",0
className BYTE "Tank",0
imgName BYTE "djb.bmp",0

MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL,COLOR_WINDOW,NULL,className>

msg MSGStruct <>
winRect RECT <>
hMainWnd DWORD ?
hInstance DWORD ?

hbitmap DWORD ?
hdcMem DWORD ?
hdcPic DWORD ?
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
ps PAINTSTRUCT <>

BreakWallType DWORD 0
BreakWallPos DWORD 0
TankToBreak DWORD 0
DirectionMapToW DWORD 4,2,3,1
BulletMove DWORD 7,0,-7,0,0,7,0,-7
TankMove DWORD 3,0,-3,0,0,3,0,-3,3,0,-3,0,0,3,0,-3,5,0,-5,0,0,5,0,-5
BulletPosFix DWORD 10,0,-10,0,0,10,0,-10
DrawHalfSpiritMask DWORD 32,32,16,16,16,16,32,32,0,0,0,16,0,16,0,0
ScoreText BYTE "000000",0
RandomPlace DWORD 64,224,384

WaterSpirit DWORD ?		; 水的图片，需要x/8+3
WhichMenu DWORD 0			; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
ButtonNumber DWORD 2,5,0,2	; 每个界面下的图标数
SelectMenu DWORD 0			; 正在选择的菜单项
GameMode DWORD 0			; 游戏模式 0为闯关模式，1为挑战模式
IsDoublePlayer DWORD 0		; 是双人游戏

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
Map			DWORD 225 DUP(?)
; 类型(0=不存在,1=玩家坦克,2=未使用,3=普通,4=强化,5=快速),X,Y,方向,子弹类型(0=不存在,1=存在,2~9=爆炸),子弹X,Y,方向
YourTank	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
EnemyTank	DWORD 0,0,0,0,0,0,0,0
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
Round		DWORD 0
WaitingTime	DWORD -1
YouDie		DWORD 0

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

RoundEnemy	DWORD 999,999,999,8,0,0,8,0,0,8,0,2,9,3,4,8,5,5
RoundSpeed	DWORD 1,60,60,60,50,50,1

.code
WinMain:
		call Randomize

		push NULL
		call GetModuleHandle;检索指定模块的模块句柄。win32
		mov hInstance,eax
		
		push 999
		push hInstance
		call LoadIcon;从与应用程序实例关联的可执行文件 (.exe) 加载指定的图标资源。
		mov MainWin.hIcon,eax

		push IDC_ARROW
		push NULL
		call LoadCursor;从与应用程序实例关联的可执行 (.EXE) 文件中加载指定的游标资源。
		mov MainWin.hCursor,eax
		
		push offset MainWin
		call RegisterClass;注册一个窗口类，以便在对 CreateWindow 或 CreateWindowEx 函数的调用中随后使用。
		cmp eax,0;如果函数失败，则返回值为零。
		je ExitProgram;窗口加载失败退出
		
		push NULL
		push hInstance
		push NULL
		push NULL
		push 510
		push 650
		push CW_USEDEFAULT
		push CW_USEDEFAULT
		push (WS_BORDER+WS_CAPTION+WS_SYSMENU) ;MAIN_WINDOW_STYLE
		push offset WindowName
		push offset className
		push 0
		call CreateWindowEx;Creates an overlapped, pop-up, or child window with an extended window style
		cmp eax,0
		je ExitProgram
		mov hMainWnd,eax
		
		push SW_SHOW;激活窗口并以当前大小和位置显示窗口。
		push hMainWnd
		call ShowWindow;设置指定窗口的显示状态。
		
		push hMainWnd
		call UpdateWindow;UpdateWindow 函数通过将WM_PAINT消息发送到窗口来更新指定窗口的工作区（如果窗口的更新区域不为空）。
		
	MessageLoop:;读取message
		push NULL
		push NULL
		push NULL
		push offset msg
		call GetMessage;Retrieves a message from the calling thread's message queue.
		
		cmp eax,0
		je ExitProgram
		
		push offset msg
		call TranslateMessage;将虚拟密钥消息转换为字符消息。 字符消息将发布到调用线程的消息队列，下次线程调用 GetMessage 或 PeekMessage 函数时要读取。
		push offset msg
		call DispatchMessage;将消息调度到窗口过程。 它通常用于调度 GetMessage 函数检索的消息。
		
		jmp MessageLoop

	ExitProgram:
		push 0
		call ExitProcess
	
WinProc:

		push ebp
		mov ebp,esp
		;参数列表：
		;ebp+8：HWND hWnd,窗口句柄，一般没啥用
		;ebp+12：UINT message, 事件类型，比如按下键盘，移动鼠标
		;ebp+16：WPARAM wParam,事件具体信息，比如键盘对应wParam：
			;38上 40下 37左 39右 
			;32space 13enter 27esc
			;65a 68d 83s 87w
		;LPARAM lParam，暂时不用
		mov eax,[ebp+12];
		;分支结构，根据事件类型转到不同分支
		cmp eax,WM_KEYDOWN;按下键盘，将对应的Hold变量赋1，且进行对应操作
		je KeyDownMessage
		cmp eax,WM_KEYUP;松开键盘，将对应的Hold变量赋0
		je KeyUpMessage
		cmp eax,WM_CREATE;初始化？
		je CreateWindowMessage
		cmp eax,WM_CLOSE;关闭窗口,销毁计时器
		je CloseWindowMessage
		cmp eax,WM_PAINT;刷新窗口
		je PaintMessage
		cmp eax,WM_TIMER;计时器事件，每隔一段时间重新绘制窗口
		je TimerMessage
		
		jmp OtherMessage;交由默认回调函数处理
	
	KeyDownMessage:		;下面的各个分支对应上下左右wasd等各种键
		mov eax,[ebp+16]

		cmp eax,38
		jne @nup1
		call UpInMenu
		mov UpKeyHold,1
	@nup1:
		cmp eax,40
		jne @ndown1
		call DownInMenu
		mov DownKeyHold,1
	@ndown1:
		cmp eax,37
		jne @nleft1
		mov LeftKeyHold,1
	@nleft1:
		cmp eax,39
		jne @nright1
		mov RightKeyHold,1
	@nright1:
		cmp eax,32
		jne @nspace1
		mov SpaceKeyHold,1
		call EnterInMenu
	@nspace1:
		cmp eax,13
		jne @nenter1
		mov EnterKeyHold,1
		call EnterInMenu
	@nenter1:
		cmp eax,27
		jne @nescape1
		call EscapeInMenu
	@nescape1:
		cmp eax,65
		jne @na1
		mov AKeyHold,1
	@na1:
		cmp eax,68
		jne @nd1
		mov DKeyHold,1
	@nd1:
		cmp eax,83
		jne @ns1
		mov SKeyHold,1
	@ns1:
		cmp eax,87
		jne @nw1
		mov WKeyHold,1
	@nw1:
		
		jmp WinProcExit
		
	KeyUpMessage:		;下面的各个分支对应上下左右wasd等各种键
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
			
	CreateWindowMessage:
		mov eax,[ebp+8]
		mov hMainWnd,eax
	
		push NULL
		push 30
		push 1
		push hMainWnd
		call SetTimer;创建具有指定超时值的计时器。
	
		push hMainWnd
		call GetDC;GetDC 函数检索指定窗口或整个屏幕的工作区的设备上下文 (DC) 的句柄。
		mov hdc,eax
		
		push eax
		call CreateCompatibleDC;CreateCompatibleDC 函数 (DC) 创建与指定设备兼容的内存设备上下文。
		mov hdcPic,eax
		
		push 0
		push 0
		push 0
		push 0
		push 1001
		push hInstance
		call LoadImageA;加载图标、游标、动画游标或位图。
		mov hbitmap,eax
		
		push hbitmap
		push hdcPic
		call SelectObject;SelectObject 函数将对象选择到指定的设备上下文中， (DC) 。 新对象替换同一类型的上一个对象。

		push hdc
		call CreateCompatibleDC
		mov hdcMem,eax

		push 480
		push 640
		push hdc
		call CreateCompatibleBitmap;CreateCompatibleBitmap 函数创建与与指定设备上下文关联的设备的位图。
		mov hbitmap,eax
		
		push hbitmap
		push hdcMem
		call SelectObject
		
		push 0FFFFFFh
		push hdcMem
		call SetTextColor;SetTextColor 函数将指定设备上下文的文本颜色设置为指定颜色。
		
		push 0
		push hdcMem
		call SetBkColor;SetBkColor 函数将当前背景色设置为指定的颜色值;

		push hdc
		push hMainWnd
		call ReleaseDC;The ReleaseDC function releases a device context (DC), freeing it for use by other applications. 

		jmp WinProcExit
		
	CloseWindowMessage:
		push 0
		call PostQuitMessage;向系统指示线程已发出终止 (退出) 的请求。 它通常用于响应 WM_DESTROY 消息。
		push 1
		push hMainWnd
		call KillTimer;销毁指定的计时器。
		jmp WinProcExit
		
	PaintMessage:
		push offset ps
		push hMainWnd
		call BeginPaint;BeginPaint 函数准备用于绘制的指定窗口，并使用有关绘图的信息填充 PAINTSTRUCT 结构。
		mov hdc,eax

		push BLACK_BRUSH
		call GetStockObject;GetStockObject 函数检索某个股票笔、画笔、字体或调色板的句柄。
		
		push eax
		push hdcMem
		call SelectObject;SelectObject 函数将对象选择到指定的设备上下文中， (DC) 。 新对象替换同一类型的上一个对象。
		mov holdbr,eax
		
		push SYSTEM_FIXED_FONT
		call GetStockObject;GetStockObject 函数检索某个股票笔、画笔、字体或调色板的句柄。
		
		push eax
		push hdcMem
		call SelectObject;SelectObject 函数将对象选择到指定的设备上下文中， (DC) 。 新对象替换同一类型的上一个对象。
		mov holdft,eax
		
		push 480
		push 640
		push 0
		push 0
		push hdcMem
		call Rectangle;Rectangle 函数绘制矩形。 该矩形使用当前笔轮廓，并使用当前画笔填充。

		call DrawUI
		
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
		call BitBlt;BitBlt 函数执行与从指定源设备上下文到目标设备上下文中的像素矩形对应的颜色数据的位块传输。
		
		push offset ps
		push hMainWnd
		call EndPaint;EndPaint 函数标记指定窗口中绘制的结尾。 每次调用 BeginPaint 函数时都需要此函数，但仅在绘制完成后才需要此函数。
		
		jmp WinProcExit
	
	TimerMessage:
	
		call TimerTick

		push 1
		push NULL
		push NULL
		push hMainWnd
		call RedrawWindow;RedrawWindow 函数更新窗口的工作区中的指定矩形或区域。

		jmp WinProcExit
		
	OtherMessage:
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call DefWindowProc;调用默认窗口过程，为应用程序未处理的任何窗口消息提供默认处理。 此函数可确保处理每个消息。 使用窗口过程收到的相同参数调用 DefWindowProc。
		
	WinProcExit:
		mov esp,ebp
		pop ebp
		ret 16	;清理4个参数
		
DrawUI:
		cmp WhichMenu,0
		je DrawMain
		cmp WhichMenu,1
		je DrawMode
		cmp WhichMenu,2
		je DrawGame
		cmp WhichMenu,3
		je DrawResult
		jmp DrawUIReturn

	DrawMain:
		push 0Fh
		push 0Eh
		push 0Dh
		push 0Ch
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
		
	DrawMode:
	
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
	
		jmp DrawMenuSelect
		
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
		
	DrawGame:

		call DrawGround
		call DrawWall
		call DrawTankAndBullet
		call DrawTree
		call DrawSideBar
		
		jmp DrawUIReturn
	
	DrawMenuSelect:
	
		push 0Bh
		push 09h
		push 35h
		push 34h
		push 448
		push 480
		push 4
		call DrawLine
		
		mov eax,SelectMenu
		sal eax,5
		add eax,160
		push eax
		push 224
		push 10
		call DrawSpirit
		
	DrawUIReturn:
		ret

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
		push [DrawHalfSpiritMask+16+ecx*4]
		push [DrawHalfSpiritMask+ecx*4]
		push eax
		push ebx
		push hdcPic
		push [DrawHalfSpiritMask+16+ecx*4]
		push [DrawHalfSpiritMask+ecx*4]
		mov edx,[DWORD PTR ebp+20]
		add edx,[DrawHalfSpiritMask+48+ecx*4]
		push edx
		mov edx,[DWORD PTR ebp+16]
		add edx,[DrawHalfSpiritMask+32+ecx*4]
		push edx
		push hdcMem
		call TransparentBlt;TransparentBlt 函数执行与从指定源设备上下文到目标设备上下文中的像素矩形对应的颜色数据的位块传输。

		pop edx
		pop ecx
		mov esp,ebp
		pop ebp

		ret 16
		
DrawSpirit:
		push ebp
		mov ebp,esp

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5

		push 0FF00h
		push 32
		push 32
		push eax
		push ebx
		push hdcPic
		push 32
		push 32
		push [DWORD PTR ebp+16]
		push [DWORD PTR ebp+12]
		push hdcMem
		call TransparentBlt;TransparentBlt 函数执行与从指定源设备上下文到目标设备上下文中的像素矩形对应的颜色数据的位块传输。

		mov esp,ebp
		pop ebp

		ret 12

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

UpInMenu:
		dec SelectMenu
		cmp SelectMenu,0
		jnl UpInMenuReturn
		mov SelectMenu,0
	UpInMenuReturn:
		ret
		
DownInMenu:
		push eax
		inc SelectMenu
		mov ebx,WhichMenu
		mov eax,[ButtonNumber+ebx*4]
		dec eax
		cmp SelectMenu,eax
		jng DownInMenuReturn
		mov SelectMenu,eax
	DownInMenuReturn:
		pop eax
		ret
		
EnterInMenu:
		push eax
		cmp WhichMenu,2
		je EnterInMenuReturn
		mov SpaceKeyHold,0
		mov EnterKeyHold,0
		
		cmp WhichMenu,0
		je EnterInMain
		cmp WhichMenu,1
		je EnterInMode
		cmp WhichMenu,3
		je EnterInResult
		
		jmp EnterInMenuReturn

	EnterInMain:
		cmp SelectMenu,0
		je EnterToMode
		jmp EnterToEndGame

	EnterInMode:
		cmp SelectMenu,4
		je EnterToMain
		mov eax,SelectMenu
		and eax,1
		mov GameMode,eax
		mov eax,SelectMenu
		sar eax,1
		mov IsDoublePlayer,eax
		mov WhichMenu,2
		call ResetField
		jmp EnterInMenuReturn

	EnterInResult:
		cmp SelectMenu,0
		je EnterToMain
		jmp EnterToEndGame
		
	EnterToMain:
		mov WhichMenu,0
		mov SelectMenu,0
		jmp EnterInMenuReturn
	
	EnterToMode:
		mov WhichMenu,1
		jmp EnterInMenuReturn
	
	EnterToEndGame:
		push 0
		call PostQuitMessage;向系统指示线程已发出终止 (退出) 的请求。 它通常用于响应 WM_DESTROY 消息。
		push 1
		push hMainWnd
		call KillTimer;销毁指定的计时器。
	
	EnterInMenuReturn:
		pop eax
		ret

EscapeInMenu:

		mov SelectMenu,0
		mov WhichMenu,0
		cmp WhichMenu,2
		jne EscapeInMenuReturn
		mov WhichMenu,1
	EscapeInMenuReturn:
		ret
		
ResetField:
		mov [Score],0
		mov [Score+4],0
		mov eax,GameMode
		mov ebx,1
		sub ebx,eax
		mov [Round],ebx
		mov [YourLife],5
		mov [YourLife+4],5
		
		mov YouDie,0
		call NewRound
		ret
		
NewRound:
		mov WaitingTime,-1

		mov [YourTank],1
		mov [YourTank+4],128
		mov [YourTank+8],448
		mov [YourTank+12],3
		mov [YourTank+16],0
		
		mov [YourTank+32],2
		mov [YourTank+36],320
		mov [YourTank+40],448
		mov [YourTank+44],3
		mov [YourTank+48],0
		
		cmp IsDoublePlayer,0
		jne DoublePlayerOfNewRound
		mov [YourTank+32],0
		mov [YourLife+4],0
		
	DoublePlayerOfNewRound:
		
		mov eax,[Round]
		mov ebx,12
		mul ebx
		mov ebx,eax
		mov eax,[RoundEnemy+ebx]
		mov [EnemyLife],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [EnemyLife+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [EnemyLife+8],eax

		mov ecx,10
		mov esi,offset EnemyTank
	RemoveEnemyTank:
		mov DWORD ptr [esi],0
		mov DWORD ptr [esi+16],0
		add esi,32
		loop RemoveEnemyTank
		
		mov eax,[Round]
		mov ebx,225*4
		mul ebx
		mov ebx,eax
		mov ecx,225
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap

		ret

DrawGround:
		mov ecx,225
	DrawGroundLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		cmp [Map+ecx*4-4],1
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
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		test [Map+ecx*4-4],4
		jnz DrawWallHalf
		cmp [Map+ecx*4-4],3
		je DrawWallBlock
		cmp [Map+ecx*4-4],11
		je DrawWallMetal
		cmp [Map+ecx*4-4],8
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
		push 8
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
		
	DrawWallHalf:
		test [Map+ecx*4-4],8
		jnz DrawMetalWallHalf
		mov ebx,[Map+ecx*4-4]
		and ebx,3

		push ecx
		push eax
		push edx
		push ebx
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

DrawTankAndBullet:
		mov esi,offset YourTank
		mov ecx,12
	DrawTankAndBulletLoop:
		push esi
		mov eax,0
		cmp [esi],eax
		je GoToDrawBulletIThink
		push ecx
		mov eax,[esi]
		inc eax
		sal eax,3
		add eax,[esi+12]
		mov ebx,[esi+4]
		add ebx,80
		
		push [esi+8]
		push ebx
		push eax
		call DrawSpirit
		pop ecx

	GoToDrawBulletIThink:
		mov esi,[esp]
		add esi,16
		mov eax,0
		cmp [esi],eax
		je DrawTankAndBulletLoopContinue
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
		
	DrawTankAndBulletLoopContinue:
		pop esi
		add esi,32
		loop DrawTankAndBulletLoop
		ret

DrawTree:
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
		push 7
		call DrawSpirit
		pop ecx
		
		loop DrawTreeLoop

	DrawTreeReturn:
		ret
		
DrawSideBar:
		mov ecx,5
		mov eax,64
		mov ebx,16
		mov esi,offset YourLife
	DrawSideBarLoop:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax
		push 568
		push ebx
		call DrawSpirit
		
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
		push 1
		push offset ScoreText
		push eax
		push 608
		push hdcMem
		call TextOut;TextOut 函数使用当前选定的字体、背景色和文本颜色在指定位置写入一个字符串。
		
		pop eax
		pop ecx
		pop ebx
		pop esi
		add esi,4
		add ebx,8
		add eax,48
		loop DrawSideBarLoop
		
		mov eax,0
	DrawSideBarRepeat:
		push eax
		sal eax,6
		add eax,320
		push 2Fh
		push 2Eh
		push eax
		push 568
		push 2
		call DrawLine

		mov esi,[esp]
		mov eax,[Score+4*esi]
		mov esi,offset ScoreText
		add esi,5
		mov ecx,6
		mov ebx,10
	DrawSideBarGetScoreText:
		mov edx,0
		div ebx
		add edx,30h
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText

		mov edi,[esp]
		sal edi,6
		add edi,360
		push 6
		push offset ScoreText
		push edi
		push 576
		push hdcMem
		call TextOut;TextOut 函数使用当前选定的字体、背景色和文本颜色在指定位置写入一个字符串。

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

TimerTick:
		cmp WaitingTime,0
		jl DontWait
		je ChangeGame
		dec WaitingTime
		jmp DontWait
	ChangeGame:
		cmp YouDie,1
		jne NotGameOver
		mov WhichMenu,3
		mov SelectMenu,0
	NotGameOver:
		call NewRound
		mov WaitingTime,-1
	DontWait:

		inc WaterSpirit
		and WaterSpirit,0Fh

		cmp WhichMenu,2
		je TimerTickDontReturn
		jmp TimerTickReturn
	TimerTickDontReturn:
		
		cmp UpKeyHold,1
		jne TT@1
		mov [YourTank+12],3
		sub [YourTank+8],4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@1Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@1Bad:
		add [YourTank+8],4
		jmp TT@4
	TT@1:
		cmp DownKeyHold,1
		jne TT@2
		mov [YourTank+12],1
		add [YourTank+8],4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@2Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@2Bad:
		sub [YourTank+8],4
		jmp TT@4
	TT@2:
		cmp LeftKeyHold,1
		jne TT@3
		mov [YourTank+12],2
		sub [YourTank+4],4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@3Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@3Bad:
		add [YourTank+4],4
		jmp TT@4
	TT@3:
		cmp RightKeyHold,1
		jne TT@4
		mov [YourTank+12],0
		add [YourTank+4],4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@4Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@4Bad:
		sub [YourTank+4],4
		jmp TT@4
	TT@4:
		cmp EnterKeyHold,1
		je TT@5@@
		cmp SpaceKeyHold,1
		jne TT@5
		cmp IsDoublePlayer,0
		jne TT@5
	TT@5@@:
		cmp DWORD ptr [YourTank+16],0
		jne TT@5
		cmp DWORD ptr [YourTank],0
		je TT@5
		mov ebx,[YourTank+12]
		mov [YourTank+16],1
		mov eax,[YourTank+4]
		add eax,[BulletPosFix+4*ebx]
		mov [YourTank+20],eax
		mov eax,[YourTank+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourTank+24],eax
		mov eax,[YourTank+12]
		mov [YourTank+28],eax
	TT@5:
	
		cmp WKeyHold,1
		jne TT@6
		mov [YourTank+12+32],3
		sub [YourTank+8+32],4
		push offset YourTank+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@6Bad
		push offset YourTank+32
		call GetTankRect
		push offset YourTank+32
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@9
	TT@6Bad:
		add [YourTank+8+32],4
		jmp TT@9
	TT@6:
		cmp SKeyHold,1
		jne TT@7
		mov [YourTank+12+32],1
		add [YourTank+8+32],4
		push offset YourTank+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@7Bad
		push offset YourTank+32
		call GetTankRect
		push offset YourTank+32
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@9
	TT@7Bad:
		sub [YourTank+8+32],4
		jmp TT@9
	TT@7:
		cmp AKeyHold,1
		jne TT@8
		mov [YourTank+12+32],2
		sub [YourTank+4+32],4
		push offset YourTank+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@8Bad
		push offset YourTank+32
		call GetTankRect
		push offset YourTank+32
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@9
	TT@8Bad:
		add [YourTank+4+32],4
		jmp TT@9
	TT@8:
		cmp DKeyHold,1
		jne TT@9
		mov [YourTank+12+32],0
		add [YourTank+4+32],4
		push offset YourTank+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@9Bad
		push offset YourTank+32
		call GetTankRect
		push offset YourTank+32
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@9
	TT@9Bad:
		sub [YourTank+4+32],4
		jmp TT@9
	TT@9:
		cmp SpaceKeyHold,1
		jne TT@10
		cmp DWORD ptr [YourTank+16+32],0
		jne TT@10
		cmp DWORD ptr [YourTank+32],0
		je TT@10
		mov ebx,[YourTank+12+32]
		mov [YourTank+16+32],1
		mov eax,[YourTank+4+32]
		add eax,[BulletPosFix+4*ebx]
		mov [YourTank+20+32],eax
		mov eax,[YourTank+8+32]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourTank+24+32],eax
		mov eax,[YourTank+12+32]
		mov [YourTank+28+32],eax
	TT@10:
		mov ecx,12
		lea esi,YourTank+16
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
		call GetTankInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTCheckBulletDoom
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jz TTBulletHitTank
		jmp TTCheckBulletDoom
		
	TTBulletHitTank:
		mov edi,[ebx]
		mov DWORD ptr [ebx],0
		push ebx
		call IsEnemy
		cmp eax,1
		jne TTYouDie
		push esi
		sub esi,16
		sub esi,offset YourTank
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
		mov esi,offset EnemyTank
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
		add eax,[TankMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[TankMove+16+4*ebx]
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
		call GetTankRect
		mov esi,[esp]
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
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
		sub eax,[TankMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		sub eax,[TankMove+16+4*ebx]
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
	
		cmp [YourTank],0
		jne TTYouDontNeedResetTankA
		cmp [YourLife],0
		jle TTYouDontNeedResetTankA
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedResetTankA
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetTankInRect
		cmp eax,0
		jne TTYouDontNeedResetTankA
		mov [YourTank],1
		mov [YourTank+4],128
		mov [YourTank+8],448
		mov [YourTank+12],3
		dec [YourLife]
	TTYouDontNeedResetTankA:
			
		cmp [YourTank+32],0
		jne TTYouDontNeedResetTankB
		cmp [YourLife+4],0
		jle TTYouDontNeedResetTankB
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedResetTankB
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetTankInRect
		cmp eax,0
		jne TTYouDontNeedResetTankB
		mov [YourTank+32],2
		mov [YourTank+4+32],320
		mov [YourTank+8+32],448
		mov [YourTank+12+32],3
		dec [YourLife+4]
	TTYouDontNeedResetTankB:
	
	TimerTickReturn:
		ret
		
FromOnePart:
		mov eax,1
		cmp DWORD ptr [esp+4],offset EnemyTank
		jb FOP1
		xor eax,1
	FOP1:
		cmp DWORD ptr [esp+8],offset EnemyTank
		jb FOP2
		xor eax,1
	FOP2:
		ret 8

IsEnemy:
		mov eax,0
		cmp DWORD ptr [esp+4],offset EnemyTank
		jb NoIsntEnemy
		mov eax,1
	NoIsntEnemy:
		ret 4

HaveEnemy:
		push ecx
		push esi
		mov eax,0
		mov ecx,10
		mov esi,offset EnemyTank
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
		mov esi,offset EnemyTank
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
		call GetTankInRect
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

GetTankInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourTank
	GetTankLoop:
		cmp DWORD ptr [esi],0
		je GetTankLoopContinue
		cmp esi,[ebp+24]
		je GetTankLoopContinue
		push ecx
		push esi
		call GetTankRect
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
		jnz GetTankLoopSucceed
	GetTankLoopContinue:
		add esi,32
		loop GetTankLoop
	GetTankLoopFail:
		mov eax,0
		jmp GetTankDone
	GetTankLoopSucceed:
		mov eax,esi
	GetTankDone:
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
		mov esi,offset YourTank
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
		call GetTankRect
		jmp CheckTankCanGo
	CheckBulletCanGo:
	
		push esi
		call GetBulletRect
	CheckTankCanGo:
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
		
GetTankRect:	; &tank
		mov esi,[esp+4]
		mov eax,[esi+4]
		mov ebx,[esi+8]
		add eax,4
		add ebx,4
		mov ecx,eax
		mov edx,ebx
		add ecx,24
		add edx,24
		ret 4

GetBlockRect:	; x,y,istank
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

