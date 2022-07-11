
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 10 80 00       	push   $0x801020
  800048:	e8 28 01 00 00       	call   800175 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 03 0b 00 00       	call   800b5d <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 10 80 00       	push   $0x801040
  80006c:	e8 04 01 00 00       	call   800175 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 10 80 00       	push   $0x80106c
  80008d:	e8 e3 00 00 00       	call   800175 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
  8000a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000ad:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b0:	85 c0                	test   %eax,%eax
  8000b2:	7e 08                	jle    8000bc <libmain+0x22>
		binaryname = argv[0];
  8000b4:	8b 0a                	mov    (%edx),%ecx
  8000b6:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	52                   	push   %edx
  8000c0:	50                   	push   %eax
  8000c1:	e8 6d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 05 00 00 00       	call   8000d0 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	c9                   	leave  
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 20 0a 00 00       	call   800afd <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 04             	sub    $0x4,%esp
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ec:	8b 13                	mov    (%ebx),%edx
  8000ee:	8d 42 01             	lea    0x1(%edx),%eax
  8000f1:	89 03                	mov    %eax,(%ebx)
  8000f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 1a                	jne    80011b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	68 ff 00 00 00       	push   $0xff
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	50                   	push   %eax
  80010d:	e8 ae 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  800112:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800118:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e2 00 80 00       	push   $0x8000e2
  800153:	e8 1a 01 00 00       	call   800272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 53 09 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b0:	39 d3                	cmp    %edx,%ebx
  8001b2:	72 05                	jb     8001b9 <printnum+0x30>
  8001b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b7:	77 45                	ja     8001fe <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 18             	pushl  0x18(%ebp)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 a3 0b 00 00       	call   800d80 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	89 f8                	mov    %edi,%eax
  8001e6:	e8 9e ff ff ff       	call   800189 <printnum>
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	eb 18                	jmp    800208 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff d7                	call   *%edi
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 03                	jmp    800201 <printnum+0x78>
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800201:	83 eb 01             	sub    $0x1,%ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f e8                	jg     8001f0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	83 ec 04             	sub    $0x4,%esp
  80020f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800212:	ff 75 e0             	pushl  -0x20(%ebp)
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	e8 90 0c 00 00       	call   800eb0 <__umoddi3>
  800220:	83 c4 14             	add    $0x14,%esp
  800223:	0f be 80 95 10 80 00 	movsbl 0x801095(%eax),%eax
  80022a:	50                   	push   %eax
  80022b:	ff d7                	call   *%edi
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1b>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 05 00 00 00       	call   800272 <vprintfmt>
	va_end(ap);
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	eb 12                	jmp    800298 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800286:	85 c0                	test   %eax,%eax
  800288:	0f 84 42 04 00 00    	je     8006d0 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	53                   	push   %ebx
  800292:	50                   	push   %eax
  800293:	ff d6                	call   *%esi
  800295:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800298:	83 c7 01             	add    $0x1,%edi
  80029b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029f:	83 f8 25             	cmp    $0x25,%eax
  8002a2:	75 e2                	jne    800286 <vprintfmt+0x14>
  8002a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c2:	eb 07                	jmp    8002cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d1:	0f b6 07             	movzbl (%edi),%eax
  8002d4:	0f b6 d0             	movzbl %al,%edx
  8002d7:	83 e8 23             	sub    $0x23,%eax
  8002da:	3c 55                	cmp    $0x55,%al
  8002dc:	0f 87 d3 03 00 00    	ja     8006b5 <vprintfmt+0x443>
  8002e2:	0f b6 c0             	movzbl %al,%eax
  8002e5:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f3:	eb d6                	jmp    8002cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800300:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800303:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800307:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030d:	83 f9 09             	cmp    $0x9,%ecx
  800310:	77 3f                	ja     800351 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800312:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800315:	eb e9                	jmp    800300 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 40 04             	lea    0x4(%eax),%eax
  800325:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032b:	eb 2a                	jmp    800357 <vprintfmt+0xe5>
  80032d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800330:	85 c0                	test   %eax,%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	0f 49 d0             	cmovns %eax,%edx
  80033a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800340:	eb 89                	jmp    8002cb <vprintfmt+0x59>
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800345:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034c:	e9 7a ff ff ff       	jmp    8002cb <vprintfmt+0x59>
  800351:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800354:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	0f 89 6a ff ff ff    	jns    8002cb <vprintfmt+0x59>
				width = precision, precision = -1;
  800361:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800367:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036e:	e9 58 ff ff ff       	jmp    8002cb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800373:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800379:	e9 4d ff ff ff       	jmp    8002cb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 78 04             	lea    0x4(%eax),%edi
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	ff 30                	pushl  (%eax)
  80038a:	ff d6                	call   *%esi
			break;
  80038c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800395:	e9 fe fe ff ff       	jmp    800298 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 78 04             	lea    0x4(%eax),%edi
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	99                   	cltd   
  8003a3:	31 d0                	xor    %edx,%eax
  8003a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a7:	83 f8 09             	cmp    $0x9,%eax
  8003aa:	7f 0b                	jg     8003b7 <vprintfmt+0x145>
  8003ac:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003b3:	85 d2                	test   %edx,%edx
  8003b5:	75 1b                	jne    8003d2 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b7:	50                   	push   %eax
  8003b8:	68 ad 10 80 00       	push   $0x8010ad
  8003bd:	53                   	push   %ebx
  8003be:	56                   	push   %esi
  8003bf:	e8 91 fe ff ff       	call   800255 <printfmt>
  8003c4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 c6 fe ff ff       	jmp    800298 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d2:	52                   	push   %edx
  8003d3:	68 b6 10 80 00       	push   $0x8010b6
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 76 fe ff ff       	call   800255 <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	e9 ab fe ff ff       	jmp    800298 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	83 c0 04             	add    $0x4,%eax
  8003f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fb:	85 ff                	test   %edi,%edi
  8003fd:	b8 a6 10 80 00       	mov    $0x8010a6,%eax
  800402:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	0f 8e 94 00 00 00    	jle    8004a3 <vprintfmt+0x231>
  80040f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800413:	0f 84 98 00 00 00    	je     8004b1 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 d0             	pushl  -0x30(%ebp)
  80041f:	57                   	push   %edi
  800420:	e8 33 03 00 00       	call   800758 <strnlen>
  800425:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800428:	29 c1                	sub    %eax,%ecx
  80042a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800430:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800437:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	eb 0f                	jmp    80044d <vprintfmt+0x1db>
					putch(padc, putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	83 ef 01             	sub    $0x1,%edi
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	85 ff                	test   %edi,%edi
  80044f:	7f ed                	jg     80043e <vprintfmt+0x1cc>
  800451:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800454:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800457:	85 c9                	test   %ecx,%ecx
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	0f 49 c1             	cmovns %ecx,%eax
  800461:	29 c1                	sub    %eax,%ecx
  800463:	89 75 08             	mov    %esi,0x8(%ebp)
  800466:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800469:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046c:	89 cb                	mov    %ecx,%ebx
  80046e:	eb 4d                	jmp    8004bd <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800470:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800474:	74 1b                	je     800491 <vprintfmt+0x21f>
  800476:	0f be c0             	movsbl %al,%eax
  800479:	83 e8 20             	sub    $0x20,%eax
  80047c:	83 f8 5e             	cmp    $0x5e,%eax
  80047f:	76 10                	jbe    800491 <vprintfmt+0x21f>
					putch('?', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	6a 3f                	push   $0x3f
  800489:	ff 55 08             	call   *0x8(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	eb 0d                	jmp    80049e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	ff 75 0c             	pushl  0xc(%ebp)
  800497:	52                   	push   %edx
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	83 eb 01             	sub    $0x1,%ebx
  8004a1:	eb 1a                	jmp    8004bd <vprintfmt+0x24b>
  8004a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004af:	eb 0c                	jmp    8004bd <vprintfmt+0x24b>
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bd:	83 c7 01             	add    $0x1,%edi
  8004c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c4:	0f be d0             	movsbl %al,%edx
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	74 23                	je     8004ee <vprintfmt+0x27c>
  8004cb:	85 f6                	test   %esi,%esi
  8004cd:	78 a1                	js     800470 <vprintfmt+0x1fe>
  8004cf:	83 ee 01             	sub    $0x1,%esi
  8004d2:	79 9c                	jns    800470 <vprintfmt+0x1fe>
  8004d4:	89 df                	mov    %ebx,%edi
  8004d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004dc:	eb 18                	jmp    8004f6 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	6a 20                	push   $0x20
  8004e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x284>
  8004ee:	89 df                	mov    %ebx,%edi
  8004f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f e4                	jg     8004de <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800503:	e9 90 fd ff ff       	jmp    800298 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800508:	83 f9 01             	cmp    $0x1,%ecx
  80050b:	7e 19                	jle    800526 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 50 04             	mov    0x4(%eax),%edx
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 08             	lea    0x8(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
  800524:	eb 38                	jmp    80055e <vprintfmt+0x2ec>
	else if (lflag)
  800526:	85 c9                	test   %ecx,%ecx
  800528:	74 1b                	je     800545 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800532:	89 c1                	mov    %eax,%ecx
  800534:	c1 f9 1f             	sar    $0x1f,%ecx
  800537:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 04             	lea    0x4(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
  800543:	eb 19                	jmp    80055e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	89 c1                	mov    %eax,%ecx
  80054f:	c1 f9 1f             	sar    $0x1f,%ecx
  800552:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800564:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800569:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056d:	0f 89 0e 01 00 00    	jns    800681 <vprintfmt+0x40f>
				putch('-', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	6a 2d                	push   $0x2d
  800579:	ff d6                	call   *%esi
				num = -(long long) num;
  80057b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800581:	f7 da                	neg    %edx
  800583:	83 d1 00             	adc    $0x0,%ecx
  800586:	f7 d9                	neg    %ecx
  800588:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800590:	e9 ec 00 00 00       	jmp    800681 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800595:	83 f9 01             	cmp    $0x1,%ecx
  800598:	7e 18                	jle    8005b2 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a2:	8d 40 08             	lea    0x8(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ad:	e9 cf 00 00 00       	jmp    800681 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b2:	85 c9                	test   %ecx,%ecx
  8005b4:	74 1a                	je     8005d0 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 b1 00 00 00       	jmp    800681 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	e9 97 00 00 00       	jmp    800681 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 58                	push   $0x58
  8005f0:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	6a 58                	push   $0x58
  8005f8:	ff d6                	call   *%esi
			putch('X', putdat);
  8005fa:	83 c4 08             	add    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	6a 58                	push   $0x58
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800608:	e9 8b fc ff ff       	jmp    800298 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 30                	push   $0x30
  800613:	ff d6                	call   *%esi
			putch('x', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 78                	push   $0x78
  80061b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800630:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800635:	eb 4a                	jmp    800681 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7e 15                	jle    800651 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	8b 48 04             	mov    0x4(%eax),%ecx
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
  80064f:	eb 30                	jmp    800681 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800651:	85 c9                	test   %ecx,%ecx
  800653:	74 17                	je     80066c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
  80066a:	eb 15                	jmp    800681 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800688:	57                   	push   %edi
  800689:	ff 75 e0             	pushl  -0x20(%ebp)
  80068c:	50                   	push   %eax
  80068d:	51                   	push   %ecx
  80068e:	52                   	push   %edx
  80068f:	89 da                	mov    %ebx,%edx
  800691:	89 f0                	mov    %esi,%eax
  800693:	e8 f1 fa ff ff       	call   800189 <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 f5 fb ff ff       	jmp    800298 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	52                   	push   %edx
  8006a8:	ff d6                	call   *%esi
			break;
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b0:	e9 e3 fb ff ff       	jmp    800298 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 03                	jmp    8006c5 <vprintfmt+0x453>
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c9:	75 f7                	jne    8006c2 <vprintfmt+0x450>
  8006cb:	e9 c8 fb ff ff       	jmp    800298 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 18             	sub    $0x18,%esp
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 26                	je     80071f <vsnprintf+0x47>
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	7e 22                	jle    80071f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fd:	ff 75 14             	pushl  0x14(%ebp)
  800700:	ff 75 10             	pushl  0x10(%ebp)
  800703:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	68 38 02 80 00       	push   $0x800238
  80070c:	e8 61 fb ff ff       	call   800272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800711:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800714:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 05                	jmp    800724 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072f:	50                   	push   %eax
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	ff 75 08             	pushl  0x8(%ebp)
  800739:	e8 9a ff ff ff       	call   8006d8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
		n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
		n++;
  800768:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 c2                	cmp    %eax,%edx
  80076d:	74 08                	je     800777 <strnlen+0x1f>
  80076f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
  800775:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800783:	89 c2                	mov    %eax,%edx
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800792:	84 db                	test   %bl,%bl
  800794:	75 ef                	jne    800785 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a0:	53                   	push   %ebx
  8007a1:	e8 9a ff ff ff       	call   800740 <strlen>
  8007a6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	01 d8                	add    %ebx,%eax
  8007ae:	50                   	push   %eax
  8007af:	e8 c5 ff ff ff       	call   800779 <strcpy>
	return dst;
}
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	89 f3                	mov    %esi,%ebx
  8007c8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	89 f2                	mov    %esi,%edx
  8007cd:	eb 0f                	jmp    8007de <strncpy+0x23>
		*dst++ = *src;
  8007cf:	83 c2 01             	add    $0x1,%edx
  8007d2:	0f b6 01             	movzbl (%ecx),%eax
  8007d5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007db:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	39 da                	cmp    %ebx,%edx
  8007e0:	75 ed                	jne    8007cf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e2:	89 f0                	mov    %esi,%eax
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	74 21                	je     80081d <strlcpy+0x35>
  8007fc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800800:	89 f2                	mov    %esi,%edx
  800802:	eb 09                	jmp    80080d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	83 c1 01             	add    $0x1,%ecx
  80080a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080d:	39 c2                	cmp    %eax,%edx
  80080f:	74 09                	je     80081a <strlcpy+0x32>
  800811:	0f b6 19             	movzbl (%ecx),%ebx
  800814:	84 db                	test   %bl,%bl
  800816:	75 ec                	jne    800804 <strlcpy+0x1c>
  800818:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081d:	29 f0                	sub    %esi,%eax
}
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	eb 06                	jmp    800834 <strcmp+0x11>
		p++, q++;
  80082e:	83 c1 01             	add    $0x1,%ecx
  800831:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	84 c0                	test   %al,%al
  800839:	74 04                	je     80083f <strcmp+0x1c>
  80083b:	3a 02                	cmp    (%edx),%al
  80083d:	74 ef                	je     80082e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 c0             	movzbl %al,%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 c3                	mov    %eax,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800858:	eb 06                	jmp    800860 <strncmp+0x17>
		n--, p++, q++;
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800860:	39 d8                	cmp    %ebx,%eax
  800862:	74 15                	je     800879 <strncmp+0x30>
  800864:	0f b6 08             	movzbl (%eax),%ecx
  800867:	84 c9                	test   %cl,%cl
  800869:	74 04                	je     80086f <strncmp+0x26>
  80086b:	3a 0a                	cmp    (%edx),%cl
  80086d:	74 eb                	je     80085a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 00             	movzbl (%eax),%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
  800877:	eb 05                	jmp    80087e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 07                	jmp    800894 <strchr+0x13>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 0f                	je     8008a0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 10             	movzbl (%eax),%edx
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f2                	jne    80088d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 03                	jmp    8008b1 <strfind+0xf>
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 04                	je     8008bc <strfind+0x1a>
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strfind+0xc>
			break;
	return (char *) s;
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 36                	je     800904 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d4:	75 28                	jne    8008fe <memset+0x40>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 23                	jne    8008fe <memset+0x40>
		c &= 0xFF;
  8008db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	c1 e3 08             	shl    $0x8,%ebx
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	c1 e6 18             	shl    $0x18,%esi
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 10             	shl    $0x10,%eax
  8008ee:	09 f0                	or     %esi,%eax
  8008f0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	09 d0                	or     %edx,%eax
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
  8008f9:	fc                   	cld    
  8008fa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fc:	eb 06                	jmp    800904 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	73 35                	jae    800952 <memmove+0x47>
  80091d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800920:	39 d0                	cmp    %edx,%eax
  800922:	73 2e                	jae    800952 <memmove+0x47>
		s += n;
		d += n;
  800924:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	89 d6                	mov    %edx,%esi
  800929:	09 fe                	or     %edi,%esi
  80092b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800931:	75 13                	jne    800946 <memmove+0x3b>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0e                	jne    800946 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800938:	83 ef 04             	sub    $0x4,%edi
  80093b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fd                   	std    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 09                	jmp    80094f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800946:	83 ef 01             	sub    $0x1,%edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 1d                	jmp    80096f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 f2                	mov    %esi,%edx
  800954:	09 c2                	or     %eax,%edx
  800956:	f6 c2 03             	test   $0x3,%dl
  800959:	75 0f                	jne    80096a <memmove+0x5f>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0a                	jne    80096a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 05                	jmp    80096f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	ff 75 08             	pushl  0x8(%ebp)
  80097f:	e8 87 ff ff ff       	call   80090b <memmove>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c6                	mov    %eax,%esi
  800993:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	eb 1a                	jmp    8009b2 <memcmp+0x2c>
		if (*s1 != *s2)
  800998:	0f b6 08             	movzbl (%eax),%ecx
  80099b:	0f b6 1a             	movzbl (%edx),%ebx
  80099e:	38 d9                	cmp    %bl,%cl
  8009a0:	74 0a                	je     8009ac <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a2:	0f b6 c1             	movzbl %cl,%eax
  8009a5:	0f b6 db             	movzbl %bl,%ebx
  8009a8:	29 d8                	sub    %ebx,%eax
  8009aa:	eb 0f                	jmp    8009bb <memcmp+0x35>
		s1++, s2++;
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	39 f0                	cmp    %esi,%eax
  8009b4:	75 e2                	jne    800998 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c6:	89 c1                	mov    %eax,%ecx
  8009c8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	eb 0a                	jmp    8009db <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	0f b6 10             	movzbl (%eax),%edx
  8009d4:	39 da                	cmp    %ebx,%edx
  8009d6:	74 07                	je     8009df <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	39 c8                	cmp    %ecx,%eax
  8009dd:	72 f2                	jb     8009d1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 03                	jmp    8009f3 <strtol+0x11>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f6                	je     8009f0 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f2                	je     8009f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	75 0a                	jne    800a0c <strtol+0x2a>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0a:	eb 11                	jmp    800a1d <strtol+0x3b>
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a11:	3c 2d                	cmp    $0x2d,%al
  800a13:	75 08                	jne    800a1d <strtol+0x3b>
		s++, neg = 1;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 15                	jne    800a3a <strtol+0x58>
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	75 10                	jne    800a3a <strtol+0x58>
  800a2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2e:	75 7c                	jne    800aac <strtol+0xca>
		s += 2, base = 16;
  800a30:	83 c1 02             	add    $0x2,%ecx
  800a33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a38:	eb 16                	jmp    800a50 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	75 12                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 08                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a58:	0f b6 11             	movzbl (%ecx),%edx
  800a5b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 09             	cmp    $0x9,%bl
  800a63:	77 08                	ja     800a6d <strtol+0x8b>
			dig = *s - '0';
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 30             	sub    $0x30,%edx
  800a6b:	eb 22                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 19             	cmp    $0x19,%bl
  800a75:	77 08                	ja     800a7f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a77:	0f be d2             	movsbl %dl,%edx
  800a7a:	83 ea 57             	sub    $0x57,%edx
  800a7d:	eb 10                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 19             	cmp    $0x19,%bl
  800a87:	77 16                	ja     800a9f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a89:	0f be d2             	movsbl %dl,%edx
  800a8c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a92:	7d 0b                	jge    800a9f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9d:	eb b9                	jmp    800a58 <strtol+0x76>

	if (endptr)
  800a9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa3:	74 0d                	je     800ab2 <strtol+0xd0>
		*endptr = (char *) s;
  800aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa8:	89 0e                	mov    %ecx,(%esi)
  800aaa:	eb 06                	jmp    800ab2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 98                	je     800a48 <strtol+0x66>
  800ab0:	eb 9e                	jmp    800a50 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	f7 da                	neg    %edx
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	0f 45 c2             	cmovne %edx,%eax
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 03                	push   $0x3
  800b25:	68 e8 12 80 00       	push   $0x8012e8
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 05 13 80 00       	push   $0x801305
  800b31:	e8 f5 01 00 00       	call   800d2b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	be 00 00 00 00       	mov    $0x0,%esi
  800b8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	89 f7                	mov    %esi,%edi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 04                	push   $0x4
  800ba6:	68 e8 12 80 00       	push   $0x8012e8
  800bab:	6a 23                	push   $0x23
  800bad:	68 05 13 80 00       	push   $0x801305
  800bb2:	e8 74 01 00 00       	call   800d2b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 05                	push   $0x5
  800be8:	68 e8 12 80 00       	push   $0x8012e8
  800bed:	6a 23                	push   $0x23
  800bef:	68 05 13 80 00       	push   $0x801305
  800bf4:	e8 32 01 00 00       	call   800d2b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 06                	push   $0x6
  800c2a:	68 e8 12 80 00       	push   $0x8012e8
  800c2f:	6a 23                	push   $0x23
  800c31:	68 05 13 80 00       	push   $0x801305
  800c36:	e8 f0 00 00 00       	call   800d2b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 08 00 00 00       	mov    $0x8,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 08                	push   $0x8
  800c6c:	68 e8 12 80 00       	push   $0x8012e8
  800c71:	6a 23                	push   $0x23
  800c73:	68 05 13 80 00       	push   $0x801305
  800c78:	e8 ae 00 00 00       	call   800d2b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 09 00 00 00       	mov    $0x9,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 09                	push   $0x9
  800cae:	68 e8 12 80 00       	push   $0x8012e8
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 05 13 80 00       	push   $0x801305
  800cba:	e8 6c 00 00 00       	call   800d2b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	be 00 00 00 00       	mov    $0x0,%esi
  800cd2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 cb                	mov    %ecx,%ebx
  800d02:	89 cf                	mov    %ecx,%edi
  800d04:	89 ce                	mov    %ecx,%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 0c                	push   $0xc
  800d12:	68 e8 12 80 00       	push   $0x8012e8
  800d17:	6a 23                	push   $0x23
  800d19:	68 05 13 80 00       	push   $0x801305
  800d1e:	e8 08 00 00 00       	call   800d2b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d30:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d33:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d39:	e8 00 fe ff ff       	call   800b3e <sys_getenvid>
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	ff 75 0c             	pushl  0xc(%ebp)
  800d44:	ff 75 08             	pushl  0x8(%ebp)
  800d47:	56                   	push   %esi
  800d48:	50                   	push   %eax
  800d49:	68 14 13 80 00       	push   $0x801314
  800d4e:	e8 22 f4 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d53:	83 c4 18             	add    $0x18,%esp
  800d56:	53                   	push   %ebx
  800d57:	ff 75 10             	pushl  0x10(%ebp)
  800d5a:	e8 c5 f3 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  800d5f:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  800d66:	e8 0a f4 ff ff       	call   800175 <cprintf>
  800d6b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d6e:	cc                   	int3   
  800d6f:	eb fd                	jmp    800d6e <_panic+0x43>
  800d71:	66 90                	xchg   %ax,%ax
  800d73:	66 90                	xchg   %ax,%ax
  800d75:	66 90                	xchg   %ax,%ax
  800d77:	66 90                	xchg   %ax,%ax
  800d79:	66 90                	xchg   %ax,%ax
  800d7b:	66 90                	xchg   %ax,%ax
  800d7d:	66 90                	xchg   %ax,%ax
  800d7f:	90                   	nop

00800d80 <__udivdi3>:
  800d80:	55                   	push   %ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 1c             	sub    $0x1c,%esp
  800d87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d97:	85 f6                	test   %esi,%esi
  800d99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d9d:	89 ca                	mov    %ecx,%edx
  800d9f:	89 f8                	mov    %edi,%eax
  800da1:	75 3d                	jne    800de0 <__udivdi3+0x60>
  800da3:	39 cf                	cmp    %ecx,%edi
  800da5:	0f 87 c5 00 00 00    	ja     800e70 <__udivdi3+0xf0>
  800dab:	85 ff                	test   %edi,%edi
  800dad:	89 fd                	mov    %edi,%ebp
  800daf:	75 0b                	jne    800dbc <__udivdi3+0x3c>
  800db1:	b8 01 00 00 00       	mov    $0x1,%eax
  800db6:	31 d2                	xor    %edx,%edx
  800db8:	f7 f7                	div    %edi
  800dba:	89 c5                	mov    %eax,%ebp
  800dbc:	89 c8                	mov    %ecx,%eax
  800dbe:	31 d2                	xor    %edx,%edx
  800dc0:	f7 f5                	div    %ebp
  800dc2:	89 c1                	mov    %eax,%ecx
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	89 cf                	mov    %ecx,%edi
  800dc8:	f7 f5                	div    %ebp
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	39 ce                	cmp    %ecx,%esi
  800de2:	77 74                	ja     800e58 <__udivdi3+0xd8>
  800de4:	0f bd fe             	bsr    %esi,%edi
  800de7:	83 f7 1f             	xor    $0x1f,%edi
  800dea:	0f 84 98 00 00 00    	je     800e88 <__udivdi3+0x108>
  800df0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	89 c5                	mov    %eax,%ebp
  800df9:	29 fb                	sub    %edi,%ebx
  800dfb:	d3 e6                	shl    %cl,%esi
  800dfd:	89 d9                	mov    %ebx,%ecx
  800dff:	d3 ed                	shr    %cl,%ebp
  800e01:	89 f9                	mov    %edi,%ecx
  800e03:	d3 e0                	shl    %cl,%eax
  800e05:	09 ee                	or     %ebp,%esi
  800e07:	89 d9                	mov    %ebx,%ecx
  800e09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0d:	89 d5                	mov    %edx,%ebp
  800e0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e13:	d3 ed                	shr    %cl,%ebp
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e2                	shl    %cl,%edx
  800e19:	89 d9                	mov    %ebx,%ecx
  800e1b:	d3 e8                	shr    %cl,%eax
  800e1d:	09 c2                	or     %eax,%edx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	89 ea                	mov    %ebp,%edx
  800e23:	f7 f6                	div    %esi
  800e25:	89 d5                	mov    %edx,%ebp
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	f7 64 24 0c          	mull   0xc(%esp)
  800e2d:	39 d5                	cmp    %edx,%ebp
  800e2f:	72 10                	jb     800e41 <__udivdi3+0xc1>
  800e31:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e6                	shl    %cl,%esi
  800e39:	39 c6                	cmp    %eax,%esi
  800e3b:	73 07                	jae    800e44 <__udivdi3+0xc4>
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	75 03                	jne    800e44 <__udivdi3+0xc4>
  800e41:	83 eb 01             	sub    $0x1,%ebx
  800e44:	31 ff                	xor    %edi,%edi
  800e46:	89 d8                	mov    %ebx,%eax
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	83 c4 1c             	add    $0x1c,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	31 ff                	xor    %edi,%edi
  800e5a:	31 db                	xor    %ebx,%ebx
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	83 c4 1c             	add    $0x1c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	f7 f7                	div    %edi
  800e74:	31 ff                	xor    %edi,%edi
  800e76:	89 c3                	mov    %eax,%ebx
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	89 fa                	mov    %edi,%edx
  800e7c:	83 c4 1c             	add    $0x1c,%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	39 ce                	cmp    %ecx,%esi
  800e8a:	72 0c                	jb     800e98 <__udivdi3+0x118>
  800e8c:	31 db                	xor    %ebx,%ebx
  800e8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e92:	0f 87 34 ff ff ff    	ja     800dcc <__udivdi3+0x4c>
  800e98:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e9d:	e9 2a ff ff ff       	jmp    800dcc <__udivdi3+0x4c>
  800ea2:	66 90                	xchg   %ax,%ax
  800ea4:	66 90                	xchg   %ax,%ax
  800ea6:	66 90                	xchg   %ax,%ax
  800ea8:	66 90                	xchg   %ax,%ax
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 1c             	sub    $0x1c,%esp
  800eb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ebb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ebf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ec7:	85 d2                	test   %edx,%edx
  800ec9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f3                	mov    %esi,%ebx
  800ed3:	89 3c 24             	mov    %edi,(%esp)
  800ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eda:	75 1c                	jne    800ef8 <__umoddi3+0x48>
  800edc:	39 f7                	cmp    %esi,%edi
  800ede:	76 50                	jbe    800f30 <__umoddi3+0x80>
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	f7 f7                	div    %edi
  800ee6:	89 d0                	mov    %edx,%eax
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	39 f2                	cmp    %esi,%edx
  800efa:	89 d0                	mov    %edx,%eax
  800efc:	77 52                	ja     800f50 <__umoddi3+0xa0>
  800efe:	0f bd ea             	bsr    %edx,%ebp
  800f01:	83 f5 1f             	xor    $0x1f,%ebp
  800f04:	75 5a                	jne    800f60 <__umoddi3+0xb0>
  800f06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	39 0c 24             	cmp    %ecx,(%esp)
  800f13:	0f 86 d7 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f19:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	85 ff                	test   %edi,%edi
  800f32:	89 fd                	mov    %edi,%ebp
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 f0                	mov    %esi,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 c8                	mov    %ecx,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	eb 99                	jmp    800ee8 <__umoddi3+0x38>
  800f4f:	90                   	nop
  800f50:	89 c8                	mov    %ecx,%eax
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	83 c4 1c             	add    $0x1c,%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
  800f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f60:	8b 34 24             	mov    (%esp),%esi
  800f63:	bf 20 00 00 00       	mov    $0x20,%edi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	29 ef                	sub    %ebp,%edi
  800f6c:	d3 e0                	shl    %cl,%eax
  800f6e:	89 f9                	mov    %edi,%ecx
  800f70:	89 f2                	mov    %esi,%edx
  800f72:	d3 ea                	shr    %cl,%edx
  800f74:	89 e9                	mov    %ebp,%ecx
  800f76:	09 c2                	or     %eax,%edx
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	89 14 24             	mov    %edx,(%esp)
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	d3 e2                	shl    %cl,%edx
  800f81:	89 f9                	mov    %edi,%ecx
  800f83:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	89 c6                	mov    %eax,%esi
  800f91:	d3 e3                	shl    %cl,%ebx
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 d0                	mov    %edx,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	09 d8                	or     %ebx,%eax
  800f9d:	89 d3                	mov    %edx,%ebx
  800f9f:	89 f2                	mov    %esi,%edx
  800fa1:	f7 34 24             	divl   (%esp)
  800fa4:	89 d6                	mov    %edx,%esi
  800fa6:	d3 e3                	shl    %cl,%ebx
  800fa8:	f7 64 24 04          	mull   0x4(%esp)
  800fac:	39 d6                	cmp    %edx,%esi
  800fae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fb2:	89 d1                	mov    %edx,%ecx
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	72 08                	jb     800fc0 <__umoddi3+0x110>
  800fb8:	75 11                	jne    800fcb <__umoddi3+0x11b>
  800fba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fbe:	73 0b                	jae    800fcb <__umoddi3+0x11b>
  800fc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fc4:	1b 14 24             	sbb    (%esp),%edx
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fcf:	29 da                	sub    %ebx,%edx
  800fd1:	19 ce                	sbb    %ecx,%esi
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 f0                	mov    %esi,%eax
  800fd7:	d3 e0                	shl    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	d3 ea                	shr    %cl,%edx
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	d3 ee                	shr    %cl,%esi
  800fe1:	09 d0                	or     %edx,%eax
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	83 c4 1c             	add    $0x1c,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 f9                	sub    %edi,%ecx
  800ff2:	19 d6                	sbb    %edx,%esi
  800ff4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ffc:	e9 18 ff ff ff       	jmp    800f19 <__umoddi3+0x69>
