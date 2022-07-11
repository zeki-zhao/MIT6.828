
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 0e 0d 00 00       	call   800d4f <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 13 0b 00 00       	call   800b62 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 c0 10 80 00       	push   $0x8010c0
  800059:	e8 3b 01 00 00       	call   800199 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 28 0d 00 00       	call   800d94 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 fe 0c 00 00       	call   800d7d <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 d9 0a 00 00       	call   800b62 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 d6 10 80 00       	push   $0x8010d6
  800091:	e8 03 01 00 00       	call   800199 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 e6 0c 00 00       	call   800d94 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ca:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d1:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d4:	85 c0                	test   %eax,%eax
  8000d6:	7e 08                	jle    8000e0 <libmain+0x22>
		binaryname = argv[0];
  8000d8:	8b 0a                	mov    (%edx),%ecx
  8000da:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	52                   	push   %edx
  8000e4:	50                   	push   %eax
  8000e5:	e8 49 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 05 00 00 00       	call   8000f4 <exit>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 20 0a 00 00       	call   800b21 <sys_env_destroy>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	53                   	push   %ebx
  80010a:	83 ec 04             	sub    $0x4,%esp
  80010d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800110:	8b 13                	mov    (%ebx),%edx
  800112:	8d 42 01             	lea    0x1(%edx),%eax
  800115:	89 03                	mov    %eax,(%ebx)
  800117:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	75 1a                	jne    80013f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 ae 09 00 00       	call   800ae4 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800151:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800158:	00 00 00 
	b.cnt = 0;
  80015b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800162:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800165:	ff 75 0c             	pushl  0xc(%ebp)
  800168:	ff 75 08             	pushl  0x8(%ebp)
  80016b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	68 06 01 80 00       	push   $0x800106
  800177:	e8 1a 01 00 00       	call   800296 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017c:	83 c4 08             	add    $0x8,%esp
  80017f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	50                   	push   %eax
  80018c:	e8 53 09 00 00       	call   800ae4 <sys_cputs>

	return b.cnt;
}
  800191:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a2:	50                   	push   %eax
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	e8 9d ff ff ff       	call   800148 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 1c             	sub    $0x1c,%esp
  8001b6:	89 c7                	mov    %eax,%edi
  8001b8:	89 d6                	mov    %edx,%esi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ce:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d4:	39 d3                	cmp    %edx,%ebx
  8001d6:	72 05                	jb     8001dd <printnum+0x30>
  8001d8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001db:	77 45                	ja     800222 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e9:	53                   	push   %ebx
  8001ea:	ff 75 10             	pushl  0x10(%ebp)
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fc:	e8 2f 0c 00 00       	call   800e30 <__udivdi3>
  800201:	83 c4 18             	add    $0x18,%esp
  800204:	52                   	push   %edx
  800205:	50                   	push   %eax
  800206:	89 f2                	mov    %esi,%edx
  800208:	89 f8                	mov    %edi,%eax
  80020a:	e8 9e ff ff ff       	call   8001ad <printnum>
  80020f:	83 c4 20             	add    $0x20,%esp
  800212:	eb 18                	jmp    80022c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	56                   	push   %esi
  800218:	ff 75 18             	pushl  0x18(%ebp)
  80021b:	ff d7                	call   *%edi
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb 03                	jmp    800225 <printnum+0x78>
  800222:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f e8                	jg     800214 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	83 ec 04             	sub    $0x4,%esp
  800233:	ff 75 e4             	pushl  -0x1c(%ebp)
  800236:	ff 75 e0             	pushl  -0x20(%ebp)
  800239:	ff 75 dc             	pushl  -0x24(%ebp)
  80023c:	ff 75 d8             	pushl  -0x28(%ebp)
  80023f:	e8 1c 0d 00 00       	call   800f60 <__umoddi3>
  800244:	83 c4 14             	add    $0x14,%esp
  800247:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  80024e:	50                   	push   %eax
  80024f:	ff d7                	call   *%edi
}
  800251:	83 c4 10             	add    $0x10,%esp
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800262:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800266:	8b 10                	mov    (%eax),%edx
  800268:	3b 50 04             	cmp    0x4(%eax),%edx
  80026b:	73 0a                	jae    800277 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	88 02                	mov    %al,(%edx)
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800282:	50                   	push   %eax
  800283:	ff 75 10             	pushl  0x10(%ebp)
  800286:	ff 75 0c             	pushl  0xc(%ebp)
  800289:	ff 75 08             	pushl  0x8(%ebp)
  80028c:	e8 05 00 00 00       	call   800296 <vprintfmt>
	va_end(ap);
}
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 2c             	sub    $0x2c,%esp
  80029f:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a8:	eb 12                	jmp    8002bc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	0f 84 42 04 00 00    	je     8006f4 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	53                   	push   %ebx
  8002b6:	50                   	push   %eax
  8002b7:	ff d6                	call   *%esi
  8002b9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bc:	83 c7 01             	add    $0x1,%edi
  8002bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c3:	83 f8 25             	cmp    $0x25,%eax
  8002c6:	75 e2                	jne    8002aa <vprintfmt+0x14>
  8002c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e6:	eb 07                	jmp    8002ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8d 47 01             	lea    0x1(%edi),%eax
  8002f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f5:	0f b6 07             	movzbl (%edi),%eax
  8002f8:	0f b6 d0             	movzbl %al,%edx
  8002fb:	83 e8 23             	sub    $0x23,%eax
  8002fe:	3c 55                	cmp    $0x55,%al
  800300:	0f 87 d3 03 00 00    	ja     8006d9 <vprintfmt+0x443>
  800306:	0f b6 c0             	movzbl %al,%eax
  800309:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800313:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800317:	eb d6                	jmp    8002ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031c:	b8 00 00 00 00       	mov    $0x0,%eax
  800321:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800324:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800327:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 3f                	ja     800375 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800336:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800339:	eb e9                	jmp    800324 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8b 00                	mov    (%eax),%eax
  800340:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800343:	8b 45 14             	mov    0x14(%ebp),%eax
  800346:	8d 40 04             	lea    0x4(%eax),%eax
  800349:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034f:	eb 2a                	jmp    80037b <vprintfmt+0xe5>
  800351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800354:	85 c0                	test   %eax,%eax
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	0f 49 d0             	cmovns %eax,%edx
  80035e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800364:	eb 89                	jmp    8002ef <vprintfmt+0x59>
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800369:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800370:	e9 7a ff ff ff       	jmp    8002ef <vprintfmt+0x59>
  800375:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800378:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037f:	0f 89 6a ff ff ff    	jns    8002ef <vprintfmt+0x59>
				width = precision, precision = -1;
  800385:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800392:	e9 58 ff ff ff       	jmp    8002ef <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800397:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039d:	e9 4d ff ff ff       	jmp    8002ef <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 78 04             	lea    0x4(%eax),%edi
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	53                   	push   %ebx
  8003ac:	ff 30                	pushl  (%eax)
  8003ae:	ff d6                	call   *%esi
			break;
  8003b0:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b9:	e9 fe fe ff ff       	jmp    8002bc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 78 04             	lea    0x4(%eax),%edi
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	99                   	cltd   
  8003c7:	31 d0                	xor    %edx,%eax
  8003c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cb:	83 f8 09             	cmp    $0x9,%eax
  8003ce:	7f 0b                	jg     8003db <vprintfmt+0x145>
  8003d0:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003d7:	85 d2                	test   %edx,%edx
  8003d9:	75 1b                	jne    8003f6 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003db:	50                   	push   %eax
  8003dc:	68 0b 11 80 00       	push   $0x80110b
  8003e1:	53                   	push   %ebx
  8003e2:	56                   	push   %esi
  8003e3:	e8 91 fe ff ff       	call   800279 <printfmt>
  8003e8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003eb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f1:	e9 c6 fe ff ff       	jmp    8002bc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f6:	52                   	push   %edx
  8003f7:	68 14 11 80 00       	push   $0x801114
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 76 fe ff ff       	call   800279 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	e9 ab fe ff ff       	jmp    8002bc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 c0 04             	add    $0x4,%eax
  800417:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041f:	85 ff                	test   %edi,%edi
  800421:	b8 04 11 80 00       	mov    $0x801104,%eax
  800426:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	0f 8e 94 00 00 00    	jle    8004c7 <vprintfmt+0x231>
  800433:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800437:	0f 84 98 00 00 00    	je     8004d5 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	ff 75 d0             	pushl  -0x30(%ebp)
  800443:	57                   	push   %edi
  800444:	e8 33 03 00 00       	call   80077c <strnlen>
  800449:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800454:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	eb 0f                	jmp    800471 <vprintfmt+0x1db>
					putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 ff                	test   %edi,%edi
  800473:	7f ed                	jg     800462 <vprintfmt+0x1cc>
  800475:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800478:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80047b:	85 c9                	test   %ecx,%ecx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c1             	cmovns %ecx,%eax
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	89 cb                	mov    %ecx,%ebx
  800492:	eb 4d                	jmp    8004e1 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800494:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800498:	74 1b                	je     8004b5 <vprintfmt+0x21f>
  80049a:	0f be c0             	movsbl %al,%eax
  80049d:	83 e8 20             	sub    $0x20,%eax
  8004a0:	83 f8 5e             	cmp    $0x5e,%eax
  8004a3:	76 10                	jbe    8004b5 <vprintfmt+0x21f>
					putch('?', putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	6a 3f                	push   $0x3f
  8004ad:	ff 55 08             	call   *0x8(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb 0d                	jmp    8004c2 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	52                   	push   %edx
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	eb 1a                	jmp    8004e1 <vprintfmt+0x24b>
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	eb 0c                	jmp    8004e1 <vprintfmt+0x24b>
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e1:	83 c7 01             	add    $0x1,%edi
  8004e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e8:	0f be d0             	movsbl %al,%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 23                	je     800512 <vprintfmt+0x27c>
  8004ef:	85 f6                	test   %esi,%esi
  8004f1:	78 a1                	js     800494 <vprintfmt+0x1fe>
  8004f3:	83 ee 01             	sub    $0x1,%esi
  8004f6:	79 9c                	jns    800494 <vprintfmt+0x1fe>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	6a 20                	push   $0x20
  800508:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb 08                	jmp    80051a <vprintfmt+0x284>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f e4                	jg     800502 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800527:	e9 90 fd ff ff       	jmp    8002bc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052c:	83 f9 01             	cmp    $0x1,%ecx
  80052f:	7e 19                	jle    80054a <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8b 50 04             	mov    0x4(%eax),%edx
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 08             	lea    0x8(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
  800548:	eb 38                	jmp    800582 <vprintfmt+0x2ec>
	else if (lflag)
  80054a:	85 c9                	test   %ecx,%ecx
  80054c:	74 1b                	je     800569 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	eb 19                	jmp    800582 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800582:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800585:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800588:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800591:	0f 89 0e 01 00 00    	jns    8006a5 <vprintfmt+0x40f>
				putch('-', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 2d                	push   $0x2d
  80059d:	ff d6                	call   *%esi
				num = -(long long) num;
  80059f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a5:	f7 da                	neg    %edx
  8005a7:	83 d1 00             	adc    $0x0,%ecx
  8005aa:	f7 d9                	neg    %ecx
  8005ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 ec 00 00 00       	jmp    8006a5 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 18                	jle    8005d6 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	e9 cf 00 00 00       	jmp    8006a5 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d6:	85 c9                	test   %ecx,%ecx
  8005d8:	74 1a                	je     8005f4 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 b1 00 00 00       	jmp    8006a5 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 97 00 00 00       	jmp    8006a5 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 58                	push   $0x58
  800614:	ff d6                	call   *%esi
			putch('X', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 58                	push   $0x58
  80061c:	ff d6                	call   *%esi
			putch('X', putdat);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 58                	push   $0x58
  800624:	ff d6                	call   *%esi
			break;
  800626:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80062c:	e9 8b fc ff ff       	jmp    8002bc <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 30                	push   $0x30
  800637:	ff d6                	call   *%esi
			putch('x', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 78                	push   $0x78
  80063f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800654:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800659:	eb 4a                	jmp    8006a5 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065b:	83 f9 01             	cmp    $0x1,%ecx
  80065e:	7e 15                	jle    800675 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	8b 48 04             	mov    0x4(%eax),%ecx
  800668:	8d 40 08             	lea    0x8(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
  800673:	eb 30                	jmp    8006a5 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800675:	85 c9                	test   %ecx,%ecx
  800677:	74 17                	je     800690 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
  80068e:	eb 15                	jmp    8006a5 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ac:	57                   	push   %edi
  8006ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b0:	50                   	push   %eax
  8006b1:	51                   	push   %ecx
  8006b2:	52                   	push   %edx
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	e8 f1 fa ff ff       	call   8001ad <printnum>
			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c2:	e9 f5 fb ff ff       	jmp    8002bc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	52                   	push   %edx
  8006cc:	ff d6                	call   *%esi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d4:	e9 e3 fb ff ff       	jmp    8002bc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 25                	push   $0x25
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 03                	jmp    8006e9 <vprintfmt+0x453>
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ed:	75 f7                	jne    8006e6 <vprintfmt+0x450>
  8006ef:	e9 c8 fb ff ff       	jmp    8002bc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 18             	sub    $0x18,%esp
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800708:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 26                	je     800743 <vsnprintf+0x47>
  80071d:	85 d2                	test   %edx,%edx
  80071f:	7e 22                	jle    800743 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800721:	ff 75 14             	pushl  0x14(%ebp)
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	68 5c 02 80 00       	push   $0x80025c
  800730:	e8 61 fb ff ff       	call   800296 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800735:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800738:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 05                	jmp    800748 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800753:	50                   	push   %eax
  800754:	ff 75 10             	pushl  0x10(%ebp)
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	ff 75 08             	pushl  0x8(%ebp)
  80075d:	e8 9a ff ff ff       	call   8006fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 03                	jmp    800774 <strlen+0x10>
		n++;
  800771:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800778:	75 f7                	jne    800771 <strlen+0xd>
		n++;
	return n;
}
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
  80078a:	eb 03                	jmp    80078f <strnlen+0x13>
		n++;
  80078c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	39 c2                	cmp    %eax,%edx
  800791:	74 08                	je     80079b <strnlen+0x1f>
  800793:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800797:	75 f3                	jne    80078c <strnlen+0x10>
  800799:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	83 c2 01             	add    $0x1,%edx
  8007ac:	83 c1 01             	add    $0x1,%ecx
  8007af:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b6:	84 db                	test   %bl,%bl
  8007b8:	75 ef                	jne    8007a9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c4:	53                   	push   %ebx
  8007c5:	e8 9a ff ff ff       	call   800764 <strlen>
  8007ca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	01 d8                	add    %ebx,%eax
  8007d2:	50                   	push   %eax
  8007d3:	e8 c5 ff ff ff       	call   80079d <strcpy>
	return dst;
}
  8007d8:	89 d8                	mov    %ebx,%eax
  8007da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	89 f3                	mov    %esi,%ebx
  8007ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ef:	89 f2                	mov    %esi,%edx
  8007f1:	eb 0f                	jmp    800802 <strncpy+0x23>
		*dst++ = *src;
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	0f b6 01             	movzbl (%ecx),%eax
  8007f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800802:	39 da                	cmp    %ebx,%edx
  800804:	75 ed                	jne    8007f3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800806:	89 f0                	mov    %esi,%eax
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800817:	8b 55 10             	mov    0x10(%ebp),%edx
  80081a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081c:	85 d2                	test   %edx,%edx
  80081e:	74 21                	je     800841 <strlcpy+0x35>
  800820:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800824:	89 f2                	mov    %esi,%edx
  800826:	eb 09                	jmp    800831 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800828:	83 c2 01             	add    $0x1,%edx
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800831:	39 c2                	cmp    %eax,%edx
  800833:	74 09                	je     80083e <strlcpy+0x32>
  800835:	0f b6 19             	movzbl (%ecx),%ebx
  800838:	84 db                	test   %bl,%bl
  80083a:	75 ec                	jne    800828 <strlcpy+0x1c>
  80083c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800841:	29 f0                	sub    %esi,%eax
}
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800850:	eb 06                	jmp    800858 <strcmp+0x11>
		p++, q++;
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800858:	0f b6 01             	movzbl (%ecx),%eax
  80085b:	84 c0                	test   %al,%al
  80085d:	74 04                	je     800863 <strcmp+0x1c>
  80085f:	3a 02                	cmp    (%edx),%al
  800861:	74 ef                	je     800852 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 c0             	movzbl %al,%eax
  800866:	0f b6 12             	movzbl (%edx),%edx
  800869:	29 d0                	sub    %edx,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
  800877:	89 c3                	mov    %eax,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 06                	jmp    800884 <strncmp+0x17>
		n--, p++, q++;
  80087e:	83 c0 01             	add    $0x1,%eax
  800881:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 15                	je     80089d <strncmp+0x30>
  800888:	0f b6 08             	movzbl (%eax),%ecx
  80088b:	84 c9                	test   %cl,%cl
  80088d:	74 04                	je     800893 <strncmp+0x26>
  80088f:	3a 0a                	cmp    (%edx),%cl
  800891:	74 eb                	je     80087e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 00             	movzbl (%eax),%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
  80089b:	eb 05                	jmp    8008a2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008af:	eb 07                	jmp    8008b8 <strchr+0x13>
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 0f                	je     8008c4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f2                	jne    8008b1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 03                	jmp    8008d5 <strfind+0xf>
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 04                	je     8008e0 <strfind+0x1a>
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 36                	je     800928 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f8:	75 28                	jne    800922 <memset+0x40>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 23                	jne    800922 <memset+0x40>
		c &= 0xFF;
  8008ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800903:	89 d3                	mov    %edx,%ebx
  800905:	c1 e3 08             	shl    $0x8,%ebx
  800908:	89 d6                	mov    %edx,%esi
  80090a:	c1 e6 18             	shl    $0x18,%esi
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	c1 e0 10             	shl    $0x10,%eax
  800912:	09 f0                	or     %esi,%eax
  800914:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800916:	89 d8                	mov    %ebx,%eax
  800918:	09 d0                	or     %edx,%eax
  80091a:	c1 e9 02             	shr    $0x2,%ecx
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb 06                	jmp    800928 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	fc                   	cld    
  800926:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800928:	89 f8                	mov    %edi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093d:	39 c6                	cmp    %eax,%esi
  80093f:	73 35                	jae    800976 <memmove+0x47>
  800941:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800944:	39 d0                	cmp    %edx,%eax
  800946:	73 2e                	jae    800976 <memmove+0x47>
		s += n;
		d += n;
  800948:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	09 fe                	or     %edi,%esi
  80094f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800955:	75 13                	jne    80096a <memmove+0x3b>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0e                	jne    80096a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095c:	83 ef 04             	sub    $0x4,%edi
  80095f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	fd                   	std    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 09                	jmp    800973 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096a:	83 ef 01             	sub    $0x1,%edi
  80096d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800970:	fd                   	std    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800973:	fc                   	cld    
  800974:	eb 1d                	jmp    800993 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 f2                	mov    %esi,%edx
  800978:	09 c2                	or     %eax,%edx
  80097a:	f6 c2 03             	test   $0x3,%dl
  80097d:	75 0f                	jne    80098e <memmove+0x5f>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 0a                	jne    80098e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 05                	jmp    800993 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098e:	89 c7                	mov    %eax,%edi
  800990:	fc                   	cld    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099a:	ff 75 10             	pushl  0x10(%ebp)
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	ff 75 08             	pushl  0x8(%ebp)
  8009a3:	e8 87 ff ff ff       	call   80092f <memmove>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b5:	89 c6                	mov    %eax,%esi
  8009b7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	eb 1a                	jmp    8009d6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bc:	0f b6 08             	movzbl (%eax),%ecx
  8009bf:	0f b6 1a             	movzbl (%edx),%ebx
  8009c2:	38 d9                	cmp    %bl,%cl
  8009c4:	74 0a                	je     8009d0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c6:	0f b6 c1             	movzbl %cl,%eax
  8009c9:	0f b6 db             	movzbl %bl,%ebx
  8009cc:	29 d8                	sub    %ebx,%eax
  8009ce:	eb 0f                	jmp    8009df <memcmp+0x35>
		s1++, s2++;
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	39 f0                	cmp    %esi,%eax
  8009d8:	75 e2                	jne    8009bc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ea:	89 c1                	mov    %eax,%ecx
  8009ec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	eb 0a                	jmp    8009ff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	39 da                	cmp    %ebx,%edx
  8009fa:	74 07                	je     800a03 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	39 c8                	cmp    %ecx,%eax
  800a01:	72 f2                	jb     8009f5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	eb 03                	jmp    800a17 <strtol+0x11>
		s++;
  800a14:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f6                	je     800a14 <strtol+0xe>
  800a1e:	3c 09                	cmp    $0x9,%al
  800a20:	74 f2                	je     800a14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a22:	3c 2b                	cmp    $0x2b,%al
  800a24:	75 0a                	jne    800a30 <strtol+0x2a>
		s++;
  800a26:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 11                	jmp    800a41 <strtol+0x3b>
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a35:	3c 2d                	cmp    $0x2d,%al
  800a37:	75 08                	jne    800a41 <strtol+0x3b>
		s++, neg = 1;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a47:	75 15                	jne    800a5e <strtol+0x58>
  800a49:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4c:	75 10                	jne    800a5e <strtol+0x58>
  800a4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a52:	75 7c                	jne    800ad0 <strtol+0xca>
		s += 2, base = 16;
  800a54:	83 c1 02             	add    $0x2,%ecx
  800a57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5c:	eb 16                	jmp    800a74 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 12                	jne    800a74 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	75 08                	jne    800a74 <strtol+0x6e>
		s++, base = 8;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7c:	0f b6 11             	movzbl (%ecx),%edx
  800a7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 09             	cmp    $0x9,%bl
  800a87:	77 08                	ja     800a91 <strtol+0x8b>
			dig = *s - '0';
  800a89:	0f be d2             	movsbl %dl,%edx
  800a8c:	83 ea 30             	sub    $0x30,%edx
  800a8f:	eb 22                	jmp    800ab3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 19             	cmp    $0x19,%bl
  800a99:	77 08                	ja     800aa3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9b:	0f be d2             	movsbl %dl,%edx
  800a9e:	83 ea 57             	sub    $0x57,%edx
  800aa1:	eb 10                	jmp    800ab3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 16                	ja     800ac3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab6:	7d 0b                	jge    800ac3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac1:	eb b9                	jmp    800a7c <strtol+0x76>

	if (endptr)
  800ac3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac7:	74 0d                	je     800ad6 <strtol+0xd0>
		*endptr = (char *) s;
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acc:	89 0e                	mov    %ecx,(%esi)
  800ace:	eb 06                	jmp    800ad6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	74 98                	je     800a6c <strtol+0x66>
  800ad4:	eb 9e                	jmp    800a74 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	f7 da                	neg    %edx
  800ada:	85 ff                	test   %edi,%edi
  800adc:	0f 45 c2             	cmovne %edx,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	89 cb                	mov    %ecx,%ebx
  800b39:	89 cf                	mov    %ecx,%edi
  800b3b:	89 ce                	mov    %ecx,%esi
  800b3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 03                	push   $0x3
  800b49:	68 48 13 80 00       	push   $0x801348
  800b4e:	6a 23                	push   $0x23
  800b50:	68 65 13 80 00       	push   $0x801365
  800b55:	e8 8a 02 00 00       	call   800de4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_yield>:

void
sys_yield(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b91:	89 d1                	mov    %edx,%ecx
  800b93:	89 d3                	mov    %edx,%ebx
  800b95:	89 d7                	mov    %edx,%edi
  800b97:	89 d6                	mov    %edx,%esi
  800b99:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	be 00 00 00 00       	mov    $0x0,%esi
  800bae:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbc:	89 f7                	mov    %esi,%edi
  800bbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 04                	push   $0x4
  800bca:	68 48 13 80 00       	push   $0x801348
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 65 13 80 00       	push   $0x801365
  800bd6:	e8 09 02 00 00       	call   800de4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800c00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 05                	push   $0x5
  800c0c:	68 48 13 80 00       	push   $0x801348
  800c11:	6a 23                	push   $0x23
  800c13:	68 65 13 80 00       	push   $0x801365
  800c18:	e8 c7 01 00 00       	call   800de4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 06 00 00 00       	mov    $0x6,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 06                	push   $0x6
  800c4e:	68 48 13 80 00       	push   $0x801348
  800c53:	6a 23                	push   $0x23
  800c55:	68 65 13 80 00       	push   $0x801365
  800c5a:	e8 85 01 00 00       	call   800de4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 08                	push   $0x8
  800c90:	68 48 13 80 00       	push   $0x801348
  800c95:	6a 23                	push   $0x23
  800c97:	68 65 13 80 00       	push   $0x801365
  800c9c:	e8 43 01 00 00       	call   800de4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	89 df                	mov    %ebx,%edi
  800cc4:	89 de                	mov    %ebx,%esi
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 17                	jle    800ce3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 09                	push   $0x9
  800cd2:	68 48 13 80 00       	push   $0x801348
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 65 13 80 00       	push   $0x801365
  800cde:	e8 01 01 00 00       	call   800de4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	be 00 00 00 00       	mov    $0x0,%esi
  800cf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 cb                	mov    %ecx,%ebx
  800d26:	89 cf                	mov    %ecx,%edi
  800d28:	89 ce                	mov    %ecx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 0c                	push   $0xc
  800d36:	68 48 13 80 00       	push   $0x801348
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 65 13 80 00       	push   $0x801365
  800d42:	e8 9d 00 00 00       	call   800de4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d55:	68 7f 13 80 00       	push   $0x80137f
  800d5a:	6a 51                	push   $0x51
  800d5c:	68 73 13 80 00       	push   $0x801373
  800d61:	e8 7e 00 00 00       	call   800de4 <_panic>

00800d66 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d6c:	68 7e 13 80 00       	push   $0x80137e
  800d71:	6a 58                	push   $0x58
  800d73:	68 73 13 80 00       	push   $0x801373
  800d78:	e8 67 00 00 00       	call   800de4 <_panic>

00800d7d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d83:	68 94 13 80 00       	push   $0x801394
  800d88:	6a 1a                	push   $0x1a
  800d8a:	68 ad 13 80 00       	push   $0x8013ad
  800d8f:	e8 50 00 00 00       	call   800de4 <_panic>

00800d94 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d9a:	68 b7 13 80 00       	push   $0x8013b7
  800d9f:	6a 2a                	push   $0x2a
  800da1:	68 ad 13 80 00       	push   $0x8013ad
  800da6:	e8 39 00 00 00       	call   800de4 <_panic>

00800dab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800db6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800db9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dbf:	8b 52 50             	mov    0x50(%edx),%edx
  800dc2:	39 ca                	cmp    %ecx,%edx
  800dc4:	75 0d                	jne    800dd3 <ipc_find_env+0x28>
			return envs[i].env_id;
  800dc6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dc9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800dce:	8b 40 48             	mov    0x48(%eax),%eax
  800dd1:	eb 0f                	jmp    800de2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dd3:	83 c0 01             	add    $0x1,%eax
  800dd6:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ddb:	75 d9                	jne    800db6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800de9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dec:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800df2:	e8 6b fd ff ff       	call   800b62 <sys_getenvid>
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	ff 75 0c             	pushl  0xc(%ebp)
  800dfd:	ff 75 08             	pushl  0x8(%ebp)
  800e00:	56                   	push   %esi
  800e01:	50                   	push   %eax
  800e02:	68 d0 13 80 00       	push   $0x8013d0
  800e07:	e8 8d f3 ff ff       	call   800199 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e0c:	83 c4 18             	add    $0x18,%esp
  800e0f:	53                   	push   %ebx
  800e10:	ff 75 10             	pushl  0x10(%ebp)
  800e13:	e8 30 f3 ff ff       	call   800148 <vcprintf>
	cprintf("\n");
  800e18:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800e1f:	e8 75 f3 ff ff       	call   800199 <cprintf>
  800e24:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e27:	cc                   	int3   
  800e28:	eb fd                	jmp    800e27 <_panic+0x43>
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 f6                	test   %esi,%esi
  800e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4d:	89 ca                	mov    %ecx,%edx
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	75 3d                	jne    800e90 <__udivdi3+0x60>
  800e53:	39 cf                	cmp    %ecx,%edi
  800e55:	0f 87 c5 00 00 00    	ja     800f20 <__udivdi3+0xf0>
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	89 fd                	mov    %edi,%ebp
  800e5f:	75 0b                	jne    800e6c <__udivdi3+0x3c>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	f7 f7                	div    %edi
  800e6a:	89 c5                	mov    %eax,%ebp
  800e6c:	89 c8                	mov    %ecx,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 f5                	div    %ebp
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	f7 f5                	div    %ebp
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 ce                	cmp    %ecx,%esi
  800e92:	77 74                	ja     800f08 <__udivdi3+0xd8>
  800e94:	0f bd fe             	bsr    %esi,%edi
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	0f 84 98 00 00 00    	je     800f38 <__udivdi3+0x108>
  800ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	29 fb                	sub    %edi,%ebx
  800eab:	d3 e6                	shl    %cl,%esi
  800ead:	89 d9                	mov    %ebx,%ecx
  800eaf:	d3 ed                	shr    %cl,%ebp
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e0                	shl    %cl,%eax
  800eb5:	09 ee                	or     %ebp,%esi
  800eb7:	89 d9                	mov    %ebx,%ecx
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	89 d5                	mov    %edx,%ebp
  800ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec3:	d3 ed                	shr    %cl,%ebp
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	89 d9                	mov    %ebx,%ecx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	89 ea                	mov    %ebp,%edx
  800ed3:	f7 f6                	div    %esi
  800ed5:	89 d5                	mov    %edx,%ebp
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	f7 64 24 0c          	mull   0xc(%esp)
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	72 10                	jb     800ef1 <__udivdi3+0xc1>
  800ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e6                	shl    %cl,%esi
  800ee9:	39 c6                	cmp    %eax,%esi
  800eeb:	73 07                	jae    800ef4 <__udivdi3+0xc4>
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	75 03                	jne    800ef4 <__udivdi3+0xc4>
  800ef1:	83 eb 01             	sub    $0x1,%ebx
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	31 db                	xor    %ebx,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	f7 f7                	div    %edi
  800f24:	31 ff                	xor    %edi,%edi
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 fa                	mov    %edi,%edx
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	39 ce                	cmp    %ecx,%esi
  800f3a:	72 0c                	jb     800f48 <__udivdi3+0x118>
  800f3c:	31 db                	xor    %ebx,%ebx
  800f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f42:	0f 87 34 ff ff ff    	ja     800e7c <__udivdi3+0x4c>
  800f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f4d:	e9 2a ff ff ff       	jmp    800e7c <__udivdi3+0x4c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f77:	85 d2                	test   %edx,%edx
  800f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	89 3c 24             	mov    %edi,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	75 1c                	jne    800fa8 <__umoddi3+0x48>
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	76 50                	jbe    800fe0 <__umoddi3+0x80>
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	f7 f7                	div    %edi
  800f96:	89 d0                	mov    %edx,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	77 52                	ja     801000 <__umoddi3+0xa0>
  800fae:	0f bd ea             	bsr    %edx,%ebp
  800fb1:	83 f5 1f             	xor    $0x1f,%ebp
  800fb4:	75 5a                	jne    801010 <__umoddi3+0xb0>
  800fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	39 0c 24             	cmp    %ecx,(%esp)
  800fc3:	0f 86 d7 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	89 fd                	mov    %edi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 c8                	mov    %ecx,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	eb 99                	jmp    800f98 <__umoddi3+0x38>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 34 24             	mov    (%esp),%esi
  801013:	bf 20 00 00 00       	mov    $0x20,%edi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ef                	sub    %ebp,%edi
  80101c:	d3 e0                	shl    %cl,%eax
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	89 f2                	mov    %esi,%edx
  801022:	d3 ea                	shr    %cl,%edx
  801024:	89 e9                	mov    %ebp,%ecx
  801026:	09 c2                	or     %eax,%edx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	d3 e2                	shl    %cl,%edx
  801031:	89 f9                	mov    %edi,%ecx
  801033:	89 54 24 04          	mov    %edx,0x4(%esp)
  801037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	89 c6                	mov    %eax,%esi
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 d0                	mov    %edx,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	09 d8                	or     %ebx,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 f2                	mov    %esi,%edx
  801051:	f7 34 24             	divl   (%esp)
  801054:	89 d6                	mov    %edx,%esi
  801056:	d3 e3                	shl    %cl,%ebx
  801058:	f7 64 24 04          	mull   0x4(%esp)
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 c3                	mov    %eax,%ebx
  801066:	72 08                	jb     801070 <__umoddi3+0x110>
  801068:	75 11                	jne    80107b <__umoddi3+0x11b>
  80106a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80106e:	73 0b                	jae    80107b <__umoddi3+0x11b>
  801070:	2b 44 24 04          	sub    0x4(%esp),%eax
  801074:	1b 14 24             	sbb    (%esp),%edx
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80107f:	29 da                	sub    %ebx,%edx
  801081:	19 ce                	sbb    %ecx,%esi
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e0                	shl    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 ea                	shr    %cl,%edx
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	09 d0                	or     %edx,%eax
  801093:	89 f2                	mov    %esi,%edx
  801095:	83 c4 1c             	add    $0x1c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 f9                	sub    %edi,%ecx
  8010a2:	19 d6                	sbb    %edx,%esi
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	e9 18 ff ff ff       	jmp    800fc9 <__umoddi3+0x69>
