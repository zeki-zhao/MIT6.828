
obj/user/sendpage:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 ec 0d 00 00       	call   800e2a <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 fc 0d 00 00       	call   800e58 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 a0 11 80 00       	push   $0x8011a0
  80006c:	e8 03 02 00 00       	call   800274 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 c0 07 00 00       	call   80083f <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 b5 08 00 00       	call   800948 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 b4 11 80 00       	push   $0x8011b4
  8000a2:	e8 cd 01 00 00       	call   800274 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 87 07 00 00       	call   80083f <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 a3 09 00 00       	call   800a72 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 8f 0d 00 00       	call   800e6f <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 7b 0b 00 00       	call   800c7b <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 31 07 00 00       	call   80083f <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 4d 09 00 00       	call   800a72 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 39 0d 00 00       	call   800e6f <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 0f 0d 00 00       	call   800e58 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 a0 11 80 00       	push   $0x8011a0
  800159:	e8 16 01 00 00       	call   800274 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 d3 06 00 00       	call   80083f <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 c8 07 00 00       	call   800948 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 d4 11 80 00       	push   $0x8011d4
  80018f:	e8 e0 00 00 00       	call   800274 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001a5:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8001ac:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 08                	jle    8001bb <libmain+0x22>
		binaryname = argv[0];
  8001b3:	8b 0a                	mov    (%edx),%ecx
  8001b5:	89 0d 08 20 80 00    	mov    %ecx,0x802008

	// call user main routine
	umain(argc, argv);
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	e8 6e fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001c5:	e8 05 00 00 00       	call   8001cf <exit>
}
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001d5:	6a 00                	push   $0x0
  8001d7:	e8 20 0a 00 00       	call   800bfc <sys_env_destroy>
}
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001eb:	8b 13                	mov    (%ebx),%edx
  8001ed:	8d 42 01             	lea    0x1(%edx),%eax
  8001f0:	89 03                	mov    %eax,(%ebx)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fe:	75 1a                	jne    80021a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	68 ff 00 00 00       	push   $0xff
  800208:	8d 43 08             	lea    0x8(%ebx),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 ae 09 00 00       	call   800bbf <sys_cputs>
		b->idx = 0;
  800211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800217:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800233:	00 00 00 
	b.cnt = 0;
  800236:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024c:	50                   	push   %eax
  80024d:	68 e1 01 80 00       	push   $0x8001e1
  800252:	e8 1a 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800257:	83 c4 08             	add    $0x8,%esp
  80025a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800260:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	e8 53 09 00 00       	call   800bbf <sys_cputs>

	return b.cnt;
}
  80026c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 08             	pushl  0x8(%ebp)
  800281:	e8 9d ff ff ff       	call   800223 <vcprintf>
	va_end(ap);

	return cnt;
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 1c             	sub    $0x1c,%esp
  800291:	89 c7                	mov    %eax,%edi
  800293:	89 d6                	mov    %edx,%esi
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002af:	39 d3                	cmp    %edx,%ebx
  8002b1:	72 05                	jb     8002b8 <printnum+0x30>
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	77 45                	ja     8002fd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	ff 75 18             	pushl  0x18(%ebp)
  8002be:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c4:	53                   	push   %ebx
  8002c5:	ff 75 10             	pushl  0x10(%ebp)
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 34 0c 00 00       	call   800f10 <__udivdi3>
  8002dc:	83 c4 18             	add    $0x18,%esp
  8002df:	52                   	push   %edx
  8002e0:	50                   	push   %eax
  8002e1:	89 f2                	mov    %esi,%edx
  8002e3:	89 f8                	mov    %edi,%eax
  8002e5:	e8 9e ff ff ff       	call   800288 <printnum>
  8002ea:	83 c4 20             	add    $0x20,%esp
  8002ed:	eb 18                	jmp    800307 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ef:	83 ec 08             	sub    $0x8,%esp
  8002f2:	56                   	push   %esi
  8002f3:	ff 75 18             	pushl  0x18(%ebp)
  8002f6:	ff d7                	call   *%edi
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	eb 03                	jmp    800300 <printnum+0x78>
  8002fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	85 db                	test   %ebx,%ebx
  800305:	7f e8                	jg     8002ef <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	83 ec 04             	sub    $0x4,%esp
  80030e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800311:	ff 75 e0             	pushl  -0x20(%ebp)
  800314:	ff 75 dc             	pushl  -0x24(%ebp)
  800317:	ff 75 d8             	pushl  -0x28(%ebp)
  80031a:	e8 21 0d 00 00       	call   801040 <__umoddi3>
  80031f:	83 c4 14             	add    $0x14,%esp
  800322:	0f be 80 4c 12 80 00 	movsbl 0x80124c(%eax),%eax
  800329:	50                   	push   %eax
  80032a:	ff d7                	call   *%edi
}
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800341:	8b 10                	mov    (%eax),%edx
  800343:	3b 50 04             	cmp    0x4(%eax),%edx
  800346:	73 0a                	jae    800352 <sprintputch+0x1b>
		*b->buf++ = ch;
  800348:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	88 02                	mov    %al,(%edx)
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
	va_end(ap);
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 2c             	sub    $0x2c,%esp
  80037a:	8b 75 08             	mov    0x8(%ebp),%esi
  80037d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800380:	8b 7d 10             	mov    0x10(%ebp),%edi
  800383:	eb 12                	jmp    800397 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800385:	85 c0                	test   %eax,%eax
  800387:	0f 84 42 04 00 00    	je     8007cf <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	53                   	push   %ebx
  800391:	50                   	push   %eax
  800392:	ff d6                	call   *%esi
  800394:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800397:	83 c7 01             	add    $0x1,%edi
  80039a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039e:	83 f8 25             	cmp    $0x25,%eax
  8003a1:	75 e2                	jne    800385 <vprintfmt+0x14>
  8003a3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c1:	eb 07                	jmp    8003ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8d 47 01             	lea    0x1(%edi),%eax
  8003cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d0:	0f b6 07             	movzbl (%edi),%eax
  8003d3:	0f b6 d0             	movzbl %al,%edx
  8003d6:	83 e8 23             	sub    $0x23,%eax
  8003d9:	3c 55                	cmp    $0x55,%al
  8003db:	0f 87 d3 03 00 00    	ja     8007b4 <vprintfmt+0x443>
  8003e1:	0f b6 c0             	movzbl %al,%eax
  8003e4:	ff 24 85 20 13 80 00 	jmp    *0x801320(,%eax,4)
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f2:	eb d6                	jmp    8003ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800409:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040c:	83 f9 09             	cmp    $0x9,%ecx
  80040f:	77 3f                	ja     800450 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 40 04             	lea    0x4(%eax),%eax
  800424:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042a:	eb 2a                	jmp    800456 <vprintfmt+0xe5>
  80042c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	0f 49 d0             	cmovns %eax,%edx
  800439:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043f:	eb 89                	jmp    8003ca <vprintfmt+0x59>
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800444:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80044b:	e9 7a ff ff ff       	jmp    8003ca <vprintfmt+0x59>
  800450:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800456:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045a:	0f 89 6a ff ff ff    	jns    8003ca <vprintfmt+0x59>
				width = precision, precision = -1;
  800460:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046d:	e9 58 ff ff ff       	jmp    8003ca <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800472:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800478:	e9 4d ff ff ff       	jmp    8003ca <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 78 04             	lea    0x4(%eax),%edi
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 30                	pushl  (%eax)
  800489:	ff d6                	call   *%esi
			break;
  80048b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800494:	e9 fe fe ff ff       	jmp    800397 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 78 04             	lea    0x4(%eax),%edi
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	99                   	cltd   
  8004a2:	31 d0                	xor    %edx,%eax
  8004a4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a6:	83 f8 09             	cmp    $0x9,%eax
  8004a9:	7f 0b                	jg     8004b6 <vprintfmt+0x145>
  8004ab:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	75 1b                	jne    8004d1 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004b6:	50                   	push   %eax
  8004b7:	68 64 12 80 00       	push   $0x801264
  8004bc:	53                   	push   %ebx
  8004bd:	56                   	push   %esi
  8004be:	e8 91 fe ff ff       	call   800354 <printfmt>
  8004c3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cc:	e9 c6 fe ff ff       	jmp    800397 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004d1:	52                   	push   %edx
  8004d2:	68 6d 12 80 00       	push   $0x80126d
  8004d7:	53                   	push   %ebx
  8004d8:	56                   	push   %esi
  8004d9:	e8 76 fe ff ff       	call   800354 <printfmt>
  8004de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e1:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e7:	e9 ab fe ff ff       	jmp    800397 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	83 c0 04             	add    $0x4,%eax
  8004f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	b8 5d 12 80 00       	mov    $0x80125d,%eax
  800501:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800504:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800508:	0f 8e 94 00 00 00    	jle    8005a2 <vprintfmt+0x231>
  80050e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800512:	0f 84 98 00 00 00    	je     8005b0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 d0             	pushl  -0x30(%ebp)
  80051e:	57                   	push   %edi
  80051f:	e8 33 03 00 00       	call   800857 <strnlen>
  800524:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800527:	29 c1                	sub    %eax,%ecx
  800529:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80052c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80052f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800533:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800536:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800539:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	eb 0f                	jmp    80054c <vprintfmt+0x1db>
					putch(padc, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	ff 75 e0             	pushl  -0x20(%ebp)
  800544:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f ed                	jg     80053d <vprintfmt+0x1cc>
  800550:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800553:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800556:	85 c9                	test   %ecx,%ecx
  800558:	b8 00 00 00 00       	mov    $0x0,%eax
  80055d:	0f 49 c1             	cmovns %ecx,%eax
  800560:	29 c1                	sub    %eax,%ecx
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	89 cb                	mov    %ecx,%ebx
  80056d:	eb 4d                	jmp    8005bc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800573:	74 1b                	je     800590 <vprintfmt+0x21f>
  800575:	0f be c0             	movsbl %al,%eax
  800578:	83 e8 20             	sub    $0x20,%eax
  80057b:	83 f8 5e             	cmp    $0x5e,%eax
  80057e:	76 10                	jbe    800590 <vprintfmt+0x21f>
					putch('?', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	ff 75 0c             	pushl  0xc(%ebp)
  800586:	6a 3f                	push   $0x3f
  800588:	ff 55 08             	call   *0x8(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb 0d                	jmp    80059d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	52                   	push   %edx
  800597:	ff 55 08             	call   *0x8(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059d:	83 eb 01             	sub    $0x1,%ebx
  8005a0:	eb 1a                	jmp    8005bc <vprintfmt+0x24b>
  8005a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ae:	eb 0c                	jmp    8005bc <vprintfmt+0x24b>
  8005b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005bc:	83 c7 01             	add    $0x1,%edi
  8005bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c3:	0f be d0             	movsbl %al,%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 23                	je     8005ed <vprintfmt+0x27c>
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	78 a1                	js     80056f <vprintfmt+0x1fe>
  8005ce:	83 ee 01             	sub    $0x1,%esi
  8005d1:	79 9c                	jns    80056f <vprintfmt+0x1fe>
  8005d3:	89 df                	mov    %ebx,%edi
  8005d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005db:	eb 18                	jmp    8005f5 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 20                	push   $0x20
  8005e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e5:	83 ef 01             	sub    $0x1,%edi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 08                	jmp    8005f5 <vprintfmt+0x284>
  8005ed:	89 df                	mov    %ebx,%edi
  8005ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	7f e4                	jg     8005dd <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800602:	e9 90 fd ff ff       	jmp    800397 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 19                	jle    800625 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 50 04             	mov    0x4(%eax),%edx
  800612:	8b 00                	mov    (%eax),%eax
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 40 08             	lea    0x8(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
  800623:	eb 38                	jmp    80065d <vprintfmt+0x2ec>
	else if (lflag)
  800625:	85 c9                	test   %ecx,%ecx
  800627:	74 1b                	je     800644 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
  800642:	eb 19                	jmp    80065d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064c:	89 c1                	mov    %eax,%ecx
  80064e:	c1 f9 1f             	sar    $0x1f,%ecx
  800651:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800660:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800668:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066c:	0f 89 0e 01 00 00    	jns    800780 <vprintfmt+0x40f>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 2d                	push   $0x2d
  800678:	ff d6                	call   *%esi
				num = -(long long) num;
  80067a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800680:	f7 da                	neg    %edx
  800682:	83 d1 00             	adc    $0x0,%ecx
  800685:	f7 d9                	neg    %ecx
  800687:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	e9 ec 00 00 00       	jmp    800780 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7e 18                	jle    8006b1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ac:	e9 cf 00 00 00       	jmp    800780 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	74 1a                	je     8006cf <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 b1 00 00 00       	jmp    800780 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	e9 97 00 00 00       	jmp    800780 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 58                	push   $0x58
  8006ef:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 58                	push   $0x58
  8006f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f9:	83 c4 08             	add    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 58                	push   $0x58
  8006ff:	ff d6                	call   *%esi
			break;
  800701:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800707:	e9 8b fc ff ff       	jmp    800397 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 30                	push   $0x30
  800712:	ff d6                	call   *%esi
			putch('x', putdat);
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 78                	push   $0x78
  80071a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800726:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800734:	eb 4a                	jmp    800780 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800736:	83 f9 01             	cmp    $0x1,%ecx
  800739:	7e 15                	jle    800750 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 10                	mov    (%eax),%edx
  800740:	8b 48 04             	mov    0x4(%eax),%ecx
  800743:	8d 40 08             	lea    0x8(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
  80074e:	eb 30                	jmp    800780 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 17                	je     80076b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
  800769:	eb 15                	jmp    800780 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 10                	mov    (%eax),%edx
  800770:	b9 00 00 00 00       	mov    $0x0,%ecx
  800775:	8d 40 04             	lea    0x4(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800787:	57                   	push   %edi
  800788:	ff 75 e0             	pushl  -0x20(%ebp)
  80078b:	50                   	push   %eax
  80078c:	51                   	push   %ecx
  80078d:	52                   	push   %edx
  80078e:	89 da                	mov    %ebx,%edx
  800790:	89 f0                	mov    %esi,%eax
  800792:	e8 f1 fa ff ff       	call   800288 <printnum>
			break;
  800797:	83 c4 20             	add    $0x20,%esp
  80079a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079d:	e9 f5 fb ff ff       	jmp    800397 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	52                   	push   %edx
  8007a7:	ff d6                	call   *%esi
			break;
  8007a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007af:	e9 e3 fb ff ff       	jmp    800397 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 25                	push   $0x25
  8007ba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 03                	jmp    8007c4 <vprintfmt+0x453>
  8007c1:	83 ef 01             	sub    $0x1,%edi
  8007c4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c8:	75 f7                	jne    8007c1 <vprintfmt+0x450>
  8007ca:	e9 c8 fb ff ff       	jmp    800397 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5f                   	pop    %edi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 18             	sub    $0x18,%esp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 26                	je     80081e <vsnprintf+0x47>
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	7e 22                	jle    80081e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fc:	ff 75 14             	pushl  0x14(%ebp)
  8007ff:	ff 75 10             	pushl  0x10(%ebp)
  800802:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800805:	50                   	push   %eax
  800806:	68 37 03 80 00       	push   $0x800337
  80080b:	e8 61 fb ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800810:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800813:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800816:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082e:	50                   	push   %eax
  80082f:	ff 75 10             	pushl  0x10(%ebp)
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 9a ff ff ff       	call   8007d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	eb 03                	jmp    80084f <strlen+0x10>
		n++;
  80084c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800853:	75 f7                	jne    80084c <strlen+0xd>
		n++;
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800860:	ba 00 00 00 00       	mov    $0x0,%edx
  800865:	eb 03                	jmp    80086a <strnlen+0x13>
		n++;
  800867:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086a:	39 c2                	cmp    %eax,%edx
  80086c:	74 08                	je     800876 <strnlen+0x1f>
  80086e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800872:	75 f3                	jne    800867 <strnlen+0x10>
  800874:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800882:	89 c2                	mov    %eax,%edx
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	83 c1 01             	add    $0x1,%ecx
  80088a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800891:	84 db                	test   %bl,%bl
  800893:	75 ef                	jne    800884 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089f:	53                   	push   %ebx
  8008a0:	e8 9a ff ff ff       	call   80083f <strlen>
  8008a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	01 d8                	add    %ebx,%eax
  8008ad:	50                   	push   %eax
  8008ae:	e8 c5 ff ff ff       	call   800878 <strcpy>
	return dst;
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	89 f3                	mov    %esi,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	eb 0f                	jmp    8008dd <strncpy+0x23>
		*dst++ = *src;
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	0f b6 01             	movzbl (%ecx),%eax
  8008d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d7:	80 39 01             	cmpb   $0x1,(%ecx)
  8008da:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	39 da                	cmp    %ebx,%edx
  8008df:	75 ed                	jne    8008ce <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f2:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f7:	85 d2                	test   %edx,%edx
  8008f9:	74 21                	je     80091c <strlcpy+0x35>
  8008fb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ff:	89 f2                	mov    %esi,%edx
  800901:	eb 09                	jmp    80090c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800903:	83 c2 01             	add    $0x1,%edx
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090c:	39 c2                	cmp    %eax,%edx
  80090e:	74 09                	je     800919 <strlcpy+0x32>
  800910:	0f b6 19             	movzbl (%ecx),%ebx
  800913:	84 db                	test   %bl,%bl
  800915:	75 ec                	jne    800903 <strlcpy+0x1c>
  800917:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800919:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091c:	29 f0                	sub    %esi,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	eb 06                	jmp    800933 <strcmp+0x11>
		p++, q++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800933:	0f b6 01             	movzbl (%ecx),%eax
  800936:	84 c0                	test   %al,%al
  800938:	74 04                	je     80093e <strcmp+0x1c>
  80093a:	3a 02                	cmp    (%edx),%al
  80093c:	74 ef                	je     80092d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 c0             	movzbl %al,%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800952:	89 c3                	mov    %eax,%ebx
  800954:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800957:	eb 06                	jmp    80095f <strncmp+0x17>
		n--, p++, q++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095f:	39 d8                	cmp    %ebx,%eax
  800961:	74 15                	je     800978 <strncmp+0x30>
  800963:	0f b6 08             	movzbl (%eax),%ecx
  800966:	84 c9                	test   %cl,%cl
  800968:	74 04                	je     80096e <strncmp+0x26>
  80096a:	3a 0a                	cmp    (%edx),%cl
  80096c:	74 eb                	je     800959 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096e:	0f b6 00             	movzbl (%eax),%eax
  800971:	0f b6 12             	movzbl (%edx),%edx
  800974:	29 d0                	sub    %edx,%eax
  800976:	eb 05                	jmp    80097d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098a:	eb 07                	jmp    800993 <strchr+0x13>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	74 0f                	je     80099f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	0f b6 10             	movzbl (%eax),%edx
  800996:	84 d2                	test   %dl,%dl
  800998:	75 f2                	jne    80098c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 03                	jmp    8009b0 <strfind+0xf>
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b3:	38 ca                	cmp    %cl,%dl
  8009b5:	74 04                	je     8009bb <strfind+0x1a>
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f2                	jne    8009ad <strfind+0xc>
			break;
	return (char *) s;
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c9:	85 c9                	test   %ecx,%ecx
  8009cb:	74 36                	je     800a03 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d3:	75 28                	jne    8009fd <memset+0x40>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 23                	jne    8009fd <memset+0x40>
		c &= 0xFF;
  8009da:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009de:	89 d3                	mov    %edx,%ebx
  8009e0:	c1 e3 08             	shl    $0x8,%ebx
  8009e3:	89 d6                	mov    %edx,%esi
  8009e5:	c1 e6 18             	shl    $0x18,%esi
  8009e8:	89 d0                	mov    %edx,%eax
  8009ea:	c1 e0 10             	shl    $0x10,%eax
  8009ed:	09 f0                	or     %esi,%eax
  8009ef:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009f1:	89 d8                	mov    %ebx,%eax
  8009f3:	09 d0                	or     %edx,%eax
  8009f5:	c1 e9 02             	shr    $0x2,%ecx
  8009f8:	fc                   	cld    
  8009f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fb:	eb 06                	jmp    800a03 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a00:	fc                   	cld    
  800a01:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a03:	89 f8                	mov    %edi,%eax
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 35                	jae    800a51 <memmove+0x47>
  800a1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 2e                	jae    800a51 <memmove+0x47>
		s += n;
		d += n;
  800a23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	09 fe                	or     %edi,%esi
  800a2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a30:	75 13                	jne    800a45 <memmove+0x3b>
  800a32:	f6 c1 03             	test   $0x3,%cl
  800a35:	75 0e                	jne    800a45 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a37:	83 ef 04             	sub    $0x4,%edi
  800a3a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	fd                   	std    
  800a41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a43:	eb 09                	jmp    800a4e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a45:	83 ef 01             	sub    $0x1,%edi
  800a48:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a4b:	fd                   	std    
  800a4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4e:	fc                   	cld    
  800a4f:	eb 1d                	jmp    800a6e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	09 c2                	or     %eax,%edx
  800a55:	f6 c2 03             	test   $0x3,%dl
  800a58:	75 0f                	jne    800a69 <memmove+0x5f>
  800a5a:	f6 c1 03             	test   $0x3,%cl
  800a5d:	75 0a                	jne    800a69 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 05                	jmp    800a6e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a75:	ff 75 10             	pushl  0x10(%ebp)
  800a78:	ff 75 0c             	pushl  0xc(%ebp)
  800a7b:	ff 75 08             	pushl  0x8(%ebp)
  800a7e:	e8 87 ff ff ff       	call   800a0a <memmove>
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a90:	89 c6                	mov    %eax,%esi
  800a92:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a95:	eb 1a                	jmp    800ab1 <memcmp+0x2c>
		if (*s1 != *s2)
  800a97:	0f b6 08             	movzbl (%eax),%ecx
  800a9a:	0f b6 1a             	movzbl (%edx),%ebx
  800a9d:	38 d9                	cmp    %bl,%cl
  800a9f:	74 0a                	je     800aab <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa1:	0f b6 c1             	movzbl %cl,%eax
  800aa4:	0f b6 db             	movzbl %bl,%ebx
  800aa7:	29 d8                	sub    %ebx,%eax
  800aa9:	eb 0f                	jmp    800aba <memcmp+0x35>
		s1++, s2++;
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	39 f0                	cmp    %esi,%eax
  800ab3:	75 e2                	jne    800a97 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac5:	89 c1                	mov    %eax,%ecx
  800ac7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aca:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ace:	eb 0a                	jmp    800ada <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad0:	0f b6 10             	movzbl (%eax),%edx
  800ad3:	39 da                	cmp    %ebx,%edx
  800ad5:	74 07                	je     800ade <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad7:	83 c0 01             	add    $0x1,%eax
  800ada:	39 c8                	cmp    %ecx,%eax
  800adc:	72 f2                	jb     800ad0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ade:	5b                   	pop    %ebx
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aed:	eb 03                	jmp    800af2 <strtol+0x11>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af2:	0f b6 01             	movzbl (%ecx),%eax
  800af5:	3c 20                	cmp    $0x20,%al
  800af7:	74 f6                	je     800aef <strtol+0xe>
  800af9:	3c 09                	cmp    $0x9,%al
  800afb:	74 f2                	je     800aef <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afd:	3c 2b                	cmp    $0x2b,%al
  800aff:	75 0a                	jne    800b0b <strtol+0x2a>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	eb 11                	jmp    800b1c <strtol+0x3b>
  800b0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b10:	3c 2d                	cmp    $0x2d,%al
  800b12:	75 08                	jne    800b1c <strtol+0x3b>
		s++, neg = 1;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b22:	75 15                	jne    800b39 <strtol+0x58>
  800b24:	80 39 30             	cmpb   $0x30,(%ecx)
  800b27:	75 10                	jne    800b39 <strtol+0x58>
  800b29:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2d:	75 7c                	jne    800bab <strtol+0xca>
		s += 2, base = 16;
  800b2f:	83 c1 02             	add    $0x2,%ecx
  800b32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b37:	eb 16                	jmp    800b4f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b39:	85 db                	test   %ebx,%ebx
  800b3b:	75 12                	jne    800b4f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b42:	80 39 30             	cmpb   $0x30,(%ecx)
  800b45:	75 08                	jne    800b4f <strtol+0x6e>
		s++, base = 8;
  800b47:	83 c1 01             	add    $0x1,%ecx
  800b4a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b57:	0f b6 11             	movzbl (%ecx),%edx
  800b5a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5d:	89 f3                	mov    %esi,%ebx
  800b5f:	80 fb 09             	cmp    $0x9,%bl
  800b62:	77 08                	ja     800b6c <strtol+0x8b>
			dig = *s - '0';
  800b64:	0f be d2             	movsbl %dl,%edx
  800b67:	83 ea 30             	sub    $0x30,%edx
  800b6a:	eb 22                	jmp    800b8e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 57             	sub    $0x57,%edx
  800b7c:	eb 10                	jmp    800b8e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 16                	ja     800b9e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b91:	7d 0b                	jge    800b9e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b9a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9c:	eb b9                	jmp    800b57 <strtol+0x76>

	if (endptr)
  800b9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba2:	74 0d                	je     800bb1 <strtol+0xd0>
		*endptr = (char *) s;
  800ba4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba7:	89 0e                	mov    %ecx,(%esi)
  800ba9:	eb 06                	jmp    800bb1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bab:	85 db                	test   %ebx,%ebx
  800bad:	74 98                	je     800b47 <strtol+0x66>
  800baf:	eb 9e                	jmp    800b4f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb1:	89 c2                	mov    %eax,%edx
  800bb3:	f7 da                	neg    %edx
  800bb5:	85 ff                	test   %edi,%edi
  800bb7:	0f 45 c2             	cmovne %edx,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	89 c6                	mov    %eax,%esi
  800bd6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
  800be8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 d7                	mov    %edx,%edi
  800bf3:	89 d6                	mov    %edx,%esi
  800bf5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	89 cb                	mov    %ecx,%ebx
  800c14:	89 cf                	mov    %ecx,%edi
  800c16:	89 ce                	mov    %ecx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 03                	push   $0x3
  800c24:	68 a8 14 80 00       	push   $0x8014a8
  800c29:	6a 23                	push   $0x23
  800c2b:	68 c5 14 80 00       	push   $0x8014c5
  800c30:	e8 8a 02 00 00       	call   800ebf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_yield>:

void
sys_yield(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
  800c67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6c:	89 d1                	mov    %edx,%ecx
  800c6e:	89 d3                	mov    %edx,%ebx
  800c70:	89 d7                	mov    %edx,%edi
  800c72:	89 d6                	mov    %edx,%esi
  800c74:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	be 00 00 00 00       	mov    $0x0,%esi
  800c89:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c97:	89 f7                	mov    %esi,%edi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 04                	push   $0x4
  800ca5:	68 a8 14 80 00       	push   $0x8014a8
  800caa:	6a 23                	push   $0x23
  800cac:	68 c5 14 80 00       	push   $0x8014c5
  800cb1:	e8 09 02 00 00       	call   800ebf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 05                	push   $0x5
  800ce7:	68 a8 14 80 00       	push   $0x8014a8
  800cec:	6a 23                	push   $0x23
  800cee:	68 c5 14 80 00       	push   $0x8014c5
  800cf3:	e8 c7 01 00 00       	call   800ebf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 06                	push   $0x6
  800d29:	68 a8 14 80 00       	push   $0x8014a8
  800d2e:	6a 23                	push   $0x23
  800d30:	68 c5 14 80 00       	push   $0x8014c5
  800d35:	e8 85 01 00 00       	call   800ebf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 08 00 00 00       	mov    $0x8,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 08                	push   $0x8
  800d6b:	68 a8 14 80 00       	push   $0x8014a8
  800d70:	6a 23                	push   $0x23
  800d72:	68 c5 14 80 00       	push   $0x8014c5
  800d77:	e8 43 01 00 00       	call   800ebf <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 09 00 00 00       	mov    $0x9,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 09                	push   $0x9
  800dad:	68 a8 14 80 00       	push   $0x8014a8
  800db2:	6a 23                	push   $0x23
  800db4:	68 c5 14 80 00       	push   $0x8014c5
  800db9:	e8 01 01 00 00       	call   800ebf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0c                	push   $0xc
  800e11:	68 a8 14 80 00       	push   $0x8014a8
  800e16:	6a 23                	push   $0x23
  800e18:	68 c5 14 80 00       	push   $0x8014c5
  800e1d:	e8 9d 00 00 00       	call   800ebf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e30:	68 df 14 80 00       	push   $0x8014df
  800e35:	6a 51                	push   $0x51
  800e37:	68 d3 14 80 00       	push   $0x8014d3
  800e3c:	e8 7e 00 00 00       	call   800ebf <_panic>

00800e41 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e47:	68 de 14 80 00       	push   $0x8014de
  800e4c:	6a 58                	push   $0x58
  800e4e:	68 d3 14 80 00       	push   $0x8014d3
  800e53:	e8 67 00 00 00       	call   800ebf <_panic>

00800e58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e5e:	68 f4 14 80 00       	push   $0x8014f4
  800e63:	6a 1a                	push   $0x1a
  800e65:	68 0d 15 80 00       	push   $0x80150d
  800e6a:	e8 50 00 00 00       	call   800ebf <_panic>

00800e6f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e75:	68 17 15 80 00       	push   $0x801517
  800e7a:	6a 2a                	push   $0x2a
  800e7c:	68 0d 15 80 00       	push   $0x80150d
  800e81:	e8 39 00 00 00       	call   800ebf <_panic>

00800e86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e91:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e94:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e9a:	8b 52 50             	mov    0x50(%edx),%edx
  800e9d:	39 ca                	cmp    %ecx,%edx
  800e9f:	75 0d                	jne    800eae <ipc_find_env+0x28>
			return envs[i].env_id;
  800ea1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea9:	8b 40 48             	mov    0x48(%eax),%eax
  800eac:	eb 0f                	jmp    800ebd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800eae:	83 c0 01             	add    $0x1,%eax
  800eb1:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eb6:	75 d9                	jne    800e91 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ec4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ec7:	8b 35 08 20 80 00    	mov    0x802008,%esi
  800ecd:	e8 6b fd ff ff       	call   800c3d <sys_getenvid>
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	ff 75 08             	pushl  0x8(%ebp)
  800edb:	56                   	push   %esi
  800edc:	50                   	push   %eax
  800edd:	68 30 15 80 00       	push   $0x801530
  800ee2:	e8 8d f3 ff ff       	call   800274 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ee7:	83 c4 18             	add    $0x18,%esp
  800eea:	53                   	push   %ebx
  800eeb:	ff 75 10             	pushl  0x10(%ebp)
  800eee:	e8 30 f3 ff ff       	call   800223 <vcprintf>
	cprintf("\n");
  800ef3:	c7 04 24 b2 11 80 00 	movl   $0x8011b2,(%esp)
  800efa:	e8 75 f3 ff ff       	call   800274 <cprintf>
  800eff:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f02:	cc                   	int3   
  800f03:	eb fd                	jmp    800f02 <_panic+0x43>
  800f05:	66 90                	xchg   %ax,%ax
  800f07:	66 90                	xchg   %ax,%ax
  800f09:	66 90                	xchg   %ax,%ax
  800f0b:	66 90                	xchg   %ax,%ax
  800f0d:	66 90                	xchg   %ax,%ax
  800f0f:	90                   	nop

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 f6                	test   %esi,%esi
  800f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f2d:	89 ca                	mov    %ecx,%edx
  800f2f:	89 f8                	mov    %edi,%eax
  800f31:	75 3d                	jne    800f70 <__udivdi3+0x60>
  800f33:	39 cf                	cmp    %ecx,%edi
  800f35:	0f 87 c5 00 00 00    	ja     801000 <__udivdi3+0xf0>
  800f3b:	85 ff                	test   %edi,%edi
  800f3d:	89 fd                	mov    %edi,%ebp
  800f3f:	75 0b                	jne    800f4c <__udivdi3+0x3c>
  800f41:	b8 01 00 00 00       	mov    $0x1,%eax
  800f46:	31 d2                	xor    %edx,%edx
  800f48:	f7 f7                	div    %edi
  800f4a:	89 c5                	mov    %eax,%ebp
  800f4c:	89 c8                	mov    %ecx,%eax
  800f4e:	31 d2                	xor    %edx,%edx
  800f50:	f7 f5                	div    %ebp
  800f52:	89 c1                	mov    %eax,%ecx
  800f54:	89 d8                	mov    %ebx,%eax
  800f56:	89 cf                	mov    %ecx,%edi
  800f58:	f7 f5                	div    %ebp
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	89 d8                	mov    %ebx,%eax
  800f5e:	89 fa                	mov    %edi,%edx
  800f60:	83 c4 1c             	add    $0x1c,%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	39 ce                	cmp    %ecx,%esi
  800f72:	77 74                	ja     800fe8 <__udivdi3+0xd8>
  800f74:	0f bd fe             	bsr    %esi,%edi
  800f77:	83 f7 1f             	xor    $0x1f,%edi
  800f7a:	0f 84 98 00 00 00    	je     801018 <__udivdi3+0x108>
  800f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	89 c5                	mov    %eax,%ebp
  800f89:	29 fb                	sub    %edi,%ebx
  800f8b:	d3 e6                	shl    %cl,%esi
  800f8d:	89 d9                	mov    %ebx,%ecx
  800f8f:	d3 ed                	shr    %cl,%ebp
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	d3 e0                	shl    %cl,%eax
  800f95:	09 ee                	or     %ebp,%esi
  800f97:	89 d9                	mov    %ebx,%ecx
  800f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9d:	89 d5                	mov    %edx,%ebp
  800f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fa3:	d3 ed                	shr    %cl,%ebp
  800fa5:	89 f9                	mov    %edi,%ecx
  800fa7:	d3 e2                	shl    %cl,%edx
  800fa9:	89 d9                	mov    %ebx,%ecx
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	09 c2                	or     %eax,%edx
  800faf:	89 d0                	mov    %edx,%eax
  800fb1:	89 ea                	mov    %ebp,%edx
  800fb3:	f7 f6                	div    %esi
  800fb5:	89 d5                	mov    %edx,%ebp
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	f7 64 24 0c          	mull   0xc(%esp)
  800fbd:	39 d5                	cmp    %edx,%ebp
  800fbf:	72 10                	jb     800fd1 <__udivdi3+0xc1>
  800fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fc5:	89 f9                	mov    %edi,%ecx
  800fc7:	d3 e6                	shl    %cl,%esi
  800fc9:	39 c6                	cmp    %eax,%esi
  800fcb:	73 07                	jae    800fd4 <__udivdi3+0xc4>
  800fcd:	39 d5                	cmp    %edx,%ebp
  800fcf:	75 03                	jne    800fd4 <__udivdi3+0xc4>
  800fd1:	83 eb 01             	sub    $0x1,%ebx
  800fd4:	31 ff                	xor    %edi,%edi
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	89 fa                	mov    %edi,%edx
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	31 ff                	xor    %edi,%edi
  800fea:	31 db                	xor    %ebx,%ebx
  800fec:	89 d8                	mov    %ebx,%eax
  800fee:	89 fa                	mov    %edi,%edx
  800ff0:	83 c4 1c             	add    $0x1c,%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    
  800ff8:	90                   	nop
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	89 d8                	mov    %ebx,%eax
  801002:	f7 f7                	div    %edi
  801004:	31 ff                	xor    %edi,%edi
  801006:	89 c3                	mov    %eax,%ebx
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	89 fa                	mov    %edi,%edx
  80100c:	83 c4 1c             	add    $0x1c,%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	39 ce                	cmp    %ecx,%esi
  80101a:	72 0c                	jb     801028 <__udivdi3+0x118>
  80101c:	31 db                	xor    %ebx,%ebx
  80101e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801022:	0f 87 34 ff ff ff    	ja     800f5c <__udivdi3+0x4c>
  801028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80102d:	e9 2a ff ff ff       	jmp    800f5c <__udivdi3+0x4c>
  801032:	66 90                	xchg   %ax,%ax
  801034:	66 90                	xchg   %ax,%ax
  801036:	66 90                	xchg   %ax,%ax
  801038:	66 90                	xchg   %ax,%ax
  80103a:	66 90                	xchg   %ax,%ax
  80103c:	66 90                	xchg   %ax,%ax
  80103e:	66 90                	xchg   %ax,%ax

00801040 <__umoddi3>:
  801040:	55                   	push   %ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 1c             	sub    $0x1c,%esp
  801047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80104b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80104f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801057:	85 d2                	test   %edx,%edx
  801059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80105d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801061:	89 f3                	mov    %esi,%ebx
  801063:	89 3c 24             	mov    %edi,(%esp)
  801066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106a:	75 1c                	jne    801088 <__umoddi3+0x48>
  80106c:	39 f7                	cmp    %esi,%edi
  80106e:	76 50                	jbe    8010c0 <__umoddi3+0x80>
  801070:	89 c8                	mov    %ecx,%eax
  801072:	89 f2                	mov    %esi,%edx
  801074:	f7 f7                	div    %edi
  801076:	89 d0                	mov    %edx,%eax
  801078:	31 d2                	xor    %edx,%edx
  80107a:	83 c4 1c             	add    $0x1c,%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    
  801082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801088:	39 f2                	cmp    %esi,%edx
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	77 52                	ja     8010e0 <__umoddi3+0xa0>
  80108e:	0f bd ea             	bsr    %edx,%ebp
  801091:	83 f5 1f             	xor    $0x1f,%ebp
  801094:	75 5a                	jne    8010f0 <__umoddi3+0xb0>
  801096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80109a:	0f 82 e0 00 00 00    	jb     801180 <__umoddi3+0x140>
  8010a0:	39 0c 24             	cmp    %ecx,(%esp)
  8010a3:	0f 86 d7 00 00 00    	jbe    801180 <__umoddi3+0x140>
  8010a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b1:	83 c4 1c             	add    $0x1c,%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    
  8010b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	85 ff                	test   %edi,%edi
  8010c2:	89 fd                	mov    %edi,%ebp
  8010c4:	75 0b                	jne    8010d1 <__umoddi3+0x91>
  8010c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	f7 f7                	div    %edi
  8010cf:	89 c5                	mov    %eax,%ebp
  8010d1:	89 f0                	mov    %esi,%eax
  8010d3:	31 d2                	xor    %edx,%edx
  8010d5:	f7 f5                	div    %ebp
  8010d7:	89 c8                	mov    %ecx,%eax
  8010d9:	f7 f5                	div    %ebp
  8010db:	89 d0                	mov    %edx,%eax
  8010dd:	eb 99                	jmp    801078 <__umoddi3+0x38>
  8010df:	90                   	nop
  8010e0:	89 c8                	mov    %ecx,%eax
  8010e2:	89 f2                	mov    %esi,%edx
  8010e4:	83 c4 1c             	add    $0x1c,%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    
  8010ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	8b 34 24             	mov    (%esp),%esi
  8010f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010f8:	89 e9                	mov    %ebp,%ecx
  8010fa:	29 ef                	sub    %ebp,%edi
  8010fc:	d3 e0                	shl    %cl,%eax
  8010fe:	89 f9                	mov    %edi,%ecx
  801100:	89 f2                	mov    %esi,%edx
  801102:	d3 ea                	shr    %cl,%edx
  801104:	89 e9                	mov    %ebp,%ecx
  801106:	09 c2                	or     %eax,%edx
  801108:	89 d8                	mov    %ebx,%eax
  80110a:	89 14 24             	mov    %edx,(%esp)
  80110d:	89 f2                	mov    %esi,%edx
  80110f:	d3 e2                	shl    %cl,%edx
  801111:	89 f9                	mov    %edi,%ecx
  801113:	89 54 24 04          	mov    %edx,0x4(%esp)
  801117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80111b:	d3 e8                	shr    %cl,%eax
  80111d:	89 e9                	mov    %ebp,%ecx
  80111f:	89 c6                	mov    %eax,%esi
  801121:	d3 e3                	shl    %cl,%ebx
  801123:	89 f9                	mov    %edi,%ecx
  801125:	89 d0                	mov    %edx,%eax
  801127:	d3 e8                	shr    %cl,%eax
  801129:	89 e9                	mov    %ebp,%ecx
  80112b:	09 d8                	or     %ebx,%eax
  80112d:	89 d3                	mov    %edx,%ebx
  80112f:	89 f2                	mov    %esi,%edx
  801131:	f7 34 24             	divl   (%esp)
  801134:	89 d6                	mov    %edx,%esi
  801136:	d3 e3                	shl    %cl,%ebx
  801138:	f7 64 24 04          	mull   0x4(%esp)
  80113c:	39 d6                	cmp    %edx,%esi
  80113e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801142:	89 d1                	mov    %edx,%ecx
  801144:	89 c3                	mov    %eax,%ebx
  801146:	72 08                	jb     801150 <__umoddi3+0x110>
  801148:	75 11                	jne    80115b <__umoddi3+0x11b>
  80114a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80114e:	73 0b                	jae    80115b <__umoddi3+0x11b>
  801150:	2b 44 24 04          	sub    0x4(%esp),%eax
  801154:	1b 14 24             	sbb    (%esp),%edx
  801157:	89 d1                	mov    %edx,%ecx
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80115f:	29 da                	sub    %ebx,%edx
  801161:	19 ce                	sbb    %ecx,%esi
  801163:	89 f9                	mov    %edi,%ecx
  801165:	89 f0                	mov    %esi,%eax
  801167:	d3 e0                	shl    %cl,%eax
  801169:	89 e9                	mov    %ebp,%ecx
  80116b:	d3 ea                	shr    %cl,%edx
  80116d:	89 e9                	mov    %ebp,%ecx
  80116f:	d3 ee                	shr    %cl,%esi
  801171:	09 d0                	or     %edx,%eax
  801173:	89 f2                	mov    %esi,%edx
  801175:	83 c4 1c             	add    $0x1c,%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    
  80117d:	8d 76 00             	lea    0x0(%esi),%esi
  801180:	29 f9                	sub    %edi,%ecx
  801182:	19 d6                	sbb    %edx,%esi
  801184:	89 74 24 04          	mov    %esi,0x4(%esp)
  801188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118c:	e9 18 ff ff ff       	jmp    8010a9 <__umoddi3+0x69>
