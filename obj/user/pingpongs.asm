
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 65 0d 00 00       	call   800da6 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 4f 0b 00 00       	call   800ba2 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 00 11 80 00       	push   $0x801100
  80005d:	e8 77 01 00 00       	call   8001d9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 38 0b 00 00       	call   800ba2 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 1a 11 80 00       	push   $0x80111a
  800074:	e8 60 01 00 00       	call   8001d9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 4d 0d 00 00       	call   800dd4 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 23 0d 00 00       	call   800dbd <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 ef 0a 00 00       	call   800ba2 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 30 11 80 00       	push   $0x801130
  8000c2:	e8 12 01 00 00       	call   8001d9 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 ea 0c 00 00       	call   800dd4 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800111:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800114:	85 c0                	test   %eax,%eax
  800116:	7e 08                	jle    800120 <libmain+0x22>
		binaryname = argv[0];
  800118:	8b 0a                	mov    (%edx),%ecx
  80011a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	52                   	push   %edx
  800124:	50                   	push   %eax
  800125:	e8 09 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80012a:	e8 05 00 00 00       	call   800134 <exit>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013a:	6a 00                	push   $0x0
  80013c:	e8 20 0a 00 00       	call   800b61 <sys_env_destroy>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	53                   	push   %ebx
  80014a:	83 ec 04             	sub    $0x4,%esp
  80014d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800150:	8b 13                	mov    (%ebx),%edx
  800152:	8d 42 01             	lea    0x1(%edx),%eax
  800155:	89 03                	mov    %eax,(%ebx)
  800157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800163:	75 1a                	jne    80017f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	68 ff 00 00 00       	push   $0xff
  80016d:	8d 43 08             	lea    0x8(%ebx),%eax
  800170:	50                   	push   %eax
  800171:	e8 ae 09 00 00       	call   800b24 <sys_cputs>
		b->idx = 0;
  800176:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800191:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800198:	00 00 00 
	b.cnt = 0;
  80019b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b1:	50                   	push   %eax
  8001b2:	68 46 01 80 00       	push   $0x800146
  8001b7:	e8 1a 01 00 00       	call   8002d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bc:	83 c4 08             	add    $0x8,%esp
  8001bf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	e8 53 09 00 00       	call   800b24 <sys_cputs>

	return b.cnt;
}
  8001d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d7:	c9                   	leave  
  8001d8:	c3                   	ret    

008001d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e2:	50                   	push   %eax
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	e8 9d ff ff ff       	call   800188 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 1c             	sub    $0x1c,%esp
  8001f6:	89 c7                	mov    %eax,%edi
  8001f8:	89 d6                	mov    %edx,%esi
  8001fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800200:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800203:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800206:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800211:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800214:	39 d3                	cmp    %edx,%ebx
  800216:	72 05                	jb     80021d <printnum+0x30>
  800218:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021b:	77 45                	ja     800262 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	8b 45 14             	mov    0x14(%ebp),%eax
  800226:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800229:	53                   	push   %ebx
  80022a:	ff 75 10             	pushl  0x10(%ebp)
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	ff 75 e4             	pushl  -0x1c(%ebp)
  800233:	ff 75 e0             	pushl  -0x20(%ebp)
  800236:	ff 75 dc             	pushl  -0x24(%ebp)
  800239:	ff 75 d8             	pushl  -0x28(%ebp)
  80023c:	e8 2f 0c 00 00       	call   800e70 <__udivdi3>
  800241:	83 c4 18             	add    $0x18,%esp
  800244:	52                   	push   %edx
  800245:	50                   	push   %eax
  800246:	89 f2                	mov    %esi,%edx
  800248:	89 f8                	mov    %edi,%eax
  80024a:	e8 9e ff ff ff       	call   8001ed <printnum>
  80024f:	83 c4 20             	add    $0x20,%esp
  800252:	eb 18                	jmp    80026c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	56                   	push   %esi
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	ff d7                	call   *%edi
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	eb 03                	jmp    800265 <printnum+0x78>
  800262:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800265:	83 eb 01             	sub    $0x1,%ebx
  800268:	85 db                	test   %ebx,%ebx
  80026a:	7f e8                	jg     800254 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	83 ec 04             	sub    $0x4,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	ff 75 dc             	pushl  -0x24(%ebp)
  80027c:	ff 75 d8             	pushl  -0x28(%ebp)
  80027f:	e8 1c 0d 00 00       	call   800fa0 <__umoddi3>
  800284:	83 c4 14             	add    $0x14,%esp
  800287:	0f be 80 60 11 80 00 	movsbl 0x801160(%eax),%eax
  80028e:	50                   	push   %eax
  80028f:	ff d7                	call   *%edi
}
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ab:	73 0a                	jae    8002b7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	88 02                	mov    %al,(%edx)
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c2:	50                   	push   %eax
  8002c3:	ff 75 10             	pushl  0x10(%ebp)
  8002c6:	ff 75 0c             	pushl  0xc(%ebp)
  8002c9:	ff 75 08             	pushl  0x8(%ebp)
  8002cc:	e8 05 00 00 00       	call   8002d6 <vprintfmt>
	va_end(ap);
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 2c             	sub    $0x2c,%esp
  8002df:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e8:	eb 12                	jmp    8002fc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 42 04 00 00    	je     800734 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	53                   	push   %ebx
  8002f6:	50                   	push   %eax
  8002f7:	ff d6                	call   *%esi
  8002f9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fc:	83 c7 01             	add    $0x1,%edi
  8002ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800303:	83 f8 25             	cmp    $0x25,%eax
  800306:	75 e2                	jne    8002ea <vprintfmt+0x14>
  800308:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800313:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800321:	b9 00 00 00 00       	mov    $0x0,%ecx
  800326:	eb 07                	jmp    80032f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8d 47 01             	lea    0x1(%edi),%eax
  800332:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800335:	0f b6 07             	movzbl (%edi),%eax
  800338:	0f b6 d0             	movzbl %al,%edx
  80033b:	83 e8 23             	sub    $0x23,%eax
  80033e:	3c 55                	cmp    $0x55,%al
  800340:	0f 87 d3 03 00 00    	ja     800719 <vprintfmt+0x443>
  800346:	0f b6 c0             	movzbl %al,%eax
  800349:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800353:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800357:	eb d6                	jmp    80032f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800364:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800367:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800371:	83 f9 09             	cmp    $0x9,%ecx
  800374:	77 3f                	ja     8003b5 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800376:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800379:	eb e9                	jmp    800364 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 40 04             	lea    0x4(%eax),%eax
  800389:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038f:	eb 2a                	jmp    8003bb <vprintfmt+0xe5>
  800391:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800394:	85 c0                	test   %eax,%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	0f 49 d0             	cmovns %eax,%edx
  80039e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a4:	eb 89                	jmp    80032f <vprintfmt+0x59>
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b0:	e9 7a ff ff ff       	jmp    80032f <vprintfmt+0x59>
  8003b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bf:	0f 89 6a ff ff ff    	jns    80032f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d2:	e9 58 ff ff ff       	jmp    80032f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003dd:	e9 4d ff ff ff       	jmp    80032f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 78 04             	lea    0x4(%eax),%edi
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	53                   	push   %ebx
  8003ec:	ff 30                	pushl  (%eax)
  8003ee:	ff d6                	call   *%esi
			break;
  8003f0:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f9:	e9 fe fe ff ff       	jmp    8002fc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 78 04             	lea    0x4(%eax),%edi
  800404:	8b 00                	mov    (%eax),%eax
  800406:	99                   	cltd   
  800407:	31 d0                	xor    %edx,%eax
  800409:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 09             	cmp    $0x9,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x145>
  800410:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800417:	85 d2                	test   %edx,%edx
  800419:	75 1b                	jne    800436 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80041b:	50                   	push   %eax
  80041c:	68 78 11 80 00       	push   $0x801178
  800421:	53                   	push   %ebx
  800422:	56                   	push   %esi
  800423:	e8 91 fe ff ff       	call   8002b9 <printfmt>
  800428:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800431:	e9 c6 fe ff ff       	jmp    8002fc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800436:	52                   	push   %edx
  800437:	68 81 11 80 00       	push   $0x801181
  80043c:	53                   	push   %ebx
  80043d:	56                   	push   %esi
  80043e:	e8 76 fe ff ff       	call   8002b9 <printfmt>
  800443:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 ab fe ff ff       	jmp    8002fc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	83 c0 04             	add    $0x4,%eax
  800457:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045f:	85 ff                	test   %edi,%edi
  800461:	b8 71 11 80 00       	mov    $0x801171,%eax
  800466:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800469:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046d:	0f 8e 94 00 00 00    	jle    800507 <vprintfmt+0x231>
  800473:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800477:	0f 84 98 00 00 00    	je     800515 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 d0             	pushl  -0x30(%ebp)
  800483:	57                   	push   %edi
  800484:	e8 33 03 00 00       	call   8007bc <strnlen>
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800494:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	eb 0f                	jmp    8004b1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ef 01             	sub    $0x1,%edi
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	7f ed                	jg     8004a2 <vprintfmt+0x1cc>
  8004b5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bb:	85 c9                	test   %ecx,%ecx
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	0f 49 c1             	cmovns %ecx,%eax
  8004c5:	29 c1                	sub    %eax,%ecx
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	89 cb                	mov    %ecx,%ebx
  8004d2:	eb 4d                	jmp    800521 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d8:	74 1b                	je     8004f5 <vprintfmt+0x21f>
  8004da:	0f be c0             	movsbl %al,%eax
  8004dd:	83 e8 20             	sub    $0x20,%eax
  8004e0:	83 f8 5e             	cmp    $0x5e,%eax
  8004e3:	76 10                	jbe    8004f5 <vprintfmt+0x21f>
					putch('?', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 0d                	jmp    800502 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	52                   	push   %edx
  8004fc:	ff 55 08             	call   *0x8(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	eb 1a                	jmp    800521 <vprintfmt+0x24b>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb 0c                	jmp    800521 <vprintfmt+0x24b>
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800521:	83 c7 01             	add    $0x1,%edi
  800524:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800528:	0f be d0             	movsbl %al,%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 23                	je     800552 <vprintfmt+0x27c>
  80052f:	85 f6                	test   %esi,%esi
  800531:	78 a1                	js     8004d4 <vprintfmt+0x1fe>
  800533:	83 ee 01             	sub    $0x1,%esi
  800536:	79 9c                	jns    8004d4 <vprintfmt+0x1fe>
  800538:	89 df                	mov    %ebx,%edi
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	eb 18                	jmp    80055a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 08                	jmp    80055a <vprintfmt+0x284>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f e4                	jg     800542 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 90 fd ff ff       	jmp    8002fc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7e 19                	jle    80058a <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 50 04             	mov    0x4(%eax),%edx
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 40 08             	lea    0x8(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	eb 38                	jmp    8005c2 <vprintfmt+0x2ec>
	else if (lflag)
  80058a:	85 c9                	test   %ecx,%ecx
  80058c:	74 1b                	je     8005a9 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 c1                	mov    %eax,%ecx
  800598:	c1 f9 1f             	sar    $0x1f,%ecx
  80059b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a7:	eb 19                	jmp    8005c2 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d1:	0f 89 0e 01 00 00    	jns    8006e5 <vprintfmt+0x40f>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e5:	f7 da                	neg    %edx
  8005e7:	83 d1 00             	adc    $0x0,%ecx
  8005ea:	f7 d9                	neg    %ecx
  8005ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	e9 ec 00 00 00       	jmp    8006e5 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f9:	83 f9 01             	cmp    $0x1,%ecx
  8005fc:	7e 18                	jle    800616 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	8b 48 04             	mov    0x4(%eax),%ecx
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800611:	e9 cf 00 00 00       	jmp    8006e5 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800616:	85 c9                	test   %ecx,%ecx
  800618:	74 1a                	je     800634 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800624:	8d 40 04             	lea    0x4(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062f:	e9 b1 00 00 00       	jmp    8006e5 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063e:	8d 40 04             	lea    0x4(%eax),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800644:	b8 0a 00 00 00       	mov    $0xa,%eax
  800649:	e9 97 00 00 00       	jmp    8006e5 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 58                	push   $0x58
  800654:	ff d6                	call   *%esi
			putch('X', putdat);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 58                	push   $0x58
  80065c:	ff d6                	call   *%esi
			putch('X', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 58                	push   $0x58
  800664:	ff d6                	call   *%esi
			break;
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80066c:	e9 8b fc ff ff       	jmp    8002fc <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 30                	push   $0x30
  800677:	ff d6                	call   *%esi
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 78                	push   $0x78
  80067f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800699:	eb 4a                	jmp    8006e5 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7e 15                	jle    8006b5 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b3:	eb 30                	jmp    8006e5 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	74 17                	je     8006d0 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ce:	eb 15                	jmp    8006e5 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ec:	57                   	push   %edi
  8006ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f0:	50                   	push   %eax
  8006f1:	51                   	push   %ecx
  8006f2:	52                   	push   %edx
  8006f3:	89 da                	mov    %ebx,%edx
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	e8 f1 fa ff ff       	call   8001ed <printnum>
			break;
  8006fc:	83 c4 20             	add    $0x20,%esp
  8006ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800702:	e9 f5 fb ff ff       	jmp    8002fc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	52                   	push   %edx
  80070c:	ff d6                	call   *%esi
			break;
  80070e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800714:	e9 e3 fb ff ff       	jmp    8002fc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	6a 25                	push   $0x25
  80071f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 03                	jmp    800729 <vprintfmt+0x453>
  800726:	83 ef 01             	sub    $0x1,%edi
  800729:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072d:	75 f7                	jne    800726 <vprintfmt+0x450>
  80072f:	e9 c8 fb ff ff       	jmp    8002fc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 18             	sub    $0x18,%esp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800752:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 26                	je     800783 <vsnprintf+0x47>
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e 22                	jle    800783 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800761:	ff 75 14             	pushl  0x14(%ebp)
  800764:	ff 75 10             	pushl  0x10(%ebp)
  800767:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	68 9c 02 80 00       	push   $0x80029c
  800770:	e8 61 fb ff ff       	call   8002d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	eb 05                	jmp    800788 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800793:	50                   	push   %eax
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	ff 75 08             	pushl  0x8(%ebp)
  80079d:	e8 9a ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 03                	jmp    8007b4 <strlen+0x10>
		n++;
  8007b1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b8:	75 f7                	jne    8007b1 <strlen+0xd>
		n++;
	return n;
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	eb 03                	jmp    8007cf <strnlen+0x13>
		n++;
  8007cc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 c2                	cmp    %eax,%edx
  8007d1:	74 08                	je     8007db <strnlen+0x1f>
  8007d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d7:	75 f3                	jne    8007cc <strnlen+0x10>
  8007d9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	83 c2 01             	add    $0x1,%edx
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	75 ef                	jne    8007e9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800804:	53                   	push   %ebx
  800805:	e8 9a ff ff ff       	call   8007a4 <strlen>
  80080a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	01 d8                	add    %ebx,%eax
  800812:	50                   	push   %eax
  800813:	e8 c5 ff ff ff       	call   8007dd <strcpy>
	return dst;
}
  800818:	89 d8                	mov    %ebx,%eax
  80081a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 75 08             	mov    0x8(%ebp),%esi
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082a:	89 f3                	mov    %esi,%ebx
  80082c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082f:	89 f2                	mov    %esi,%edx
  800831:	eb 0f                	jmp    800842 <strncpy+0x23>
		*dst++ = *src;
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	0f b6 01             	movzbl (%ecx),%eax
  800839:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083c:	80 39 01             	cmpb   $0x1,(%ecx)
  80083f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	39 da                	cmp    %ebx,%edx
  800844:	75 ed                	jne    800833 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800846:	89 f0                	mov    %esi,%eax
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
  80085a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	85 d2                	test   %edx,%edx
  80085e:	74 21                	je     800881 <strlcpy+0x35>
  800860:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800864:	89 f2                	mov    %esi,%edx
  800866:	eb 09                	jmp    800871 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800871:	39 c2                	cmp    %eax,%edx
  800873:	74 09                	je     80087e <strlcpy+0x32>
  800875:	0f b6 19             	movzbl (%ecx),%ebx
  800878:	84 db                	test   %bl,%bl
  80087a:	75 ec                	jne    800868 <strlcpy+0x1c>
  80087c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800881:	29 f0                	sub    %esi,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	eb 06                	jmp    800898 <strcmp+0x11>
		p++, q++;
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	0f b6 01             	movzbl (%ecx),%eax
  80089b:	84 c0                	test   %al,%al
  80089d:	74 04                	je     8008a3 <strcmp+0x1c>
  80089f:	3a 02                	cmp    (%edx),%al
  8008a1:	74 ef                	je     800892 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 c0             	movzbl %al,%eax
  8008a6:	0f b6 12             	movzbl (%edx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b7:	89 c3                	mov    %eax,%ebx
  8008b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bc:	eb 06                	jmp    8008c4 <strncmp+0x17>
		n--, p++, q++;
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c4:	39 d8                	cmp    %ebx,%eax
  8008c6:	74 15                	je     8008dd <strncmp+0x30>
  8008c8:	0f b6 08             	movzbl (%eax),%ecx
  8008cb:	84 c9                	test   %cl,%cl
  8008cd:	74 04                	je     8008d3 <strncmp+0x26>
  8008cf:	3a 0a                	cmp    (%edx),%cl
  8008d1:	74 eb                	je     8008be <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 00             	movzbl (%eax),%eax
  8008d6:	0f b6 12             	movzbl (%edx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
  8008db:	eb 05                	jmp    8008e2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ef:	eb 07                	jmp    8008f8 <strchr+0x13>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 0f                	je     800904 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f2                	jne    8008f1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800910:	eb 03                	jmp    800915 <strfind+0xf>
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 04                	je     800920 <strfind+0x1a>
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f2                	jne    800912 <strfind+0xc>
			break;
	return (char *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	74 36                	je     800968 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800932:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800938:	75 28                	jne    800962 <memset+0x40>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 23                	jne    800962 <memset+0x40>
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 08             	shl    $0x8,%ebx
  800948:	89 d6                	mov    %edx,%esi
  80094a:	c1 e6 18             	shl    $0x18,%esi
  80094d:	89 d0                	mov    %edx,%eax
  80094f:	c1 e0 10             	shl    $0x10,%eax
  800952:	09 f0                	or     %esi,%eax
  800954:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800956:	89 d8                	mov    %ebx,%eax
  800958:	09 d0                	or     %edx,%eax
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb 06                	jmp    800968 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097d:	39 c6                	cmp    %eax,%esi
  80097f:	73 35                	jae    8009b6 <memmove+0x47>
  800981:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800984:	39 d0                	cmp    %edx,%eax
  800986:	73 2e                	jae    8009b6 <memmove+0x47>
		s += n;
		d += n;
  800988:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	89 d6                	mov    %edx,%esi
  80098d:	09 fe                	or     %edi,%esi
  80098f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800995:	75 13                	jne    8009aa <memmove+0x3b>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0e                	jne    8009aa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099c:	83 ef 04             	sub    $0x4,%edi
  80099f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
  8009a5:	fd                   	std    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 09                	jmp    8009b3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009aa:	83 ef 01             	sub    $0x1,%edi
  8009ad:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b0:	fd                   	std    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b3:	fc                   	cld    
  8009b4:	eb 1d                	jmp    8009d3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	89 f2                	mov    %esi,%edx
  8009b8:	09 c2                	or     %eax,%edx
  8009ba:	f6 c2 03             	test   $0x3,%dl
  8009bd:	75 0f                	jne    8009ce <memmove+0x5f>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 0a                	jne    8009ce <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb 05                	jmp    8009d3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009da:	ff 75 10             	pushl  0x10(%ebp)
  8009dd:	ff 75 0c             	pushl  0xc(%ebp)
  8009e0:	ff 75 08             	pushl  0x8(%ebp)
  8009e3:	e8 87 ff ff ff       	call   80096f <memmove>
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f5:	89 c6                	mov    %eax,%esi
  8009f7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fa:	eb 1a                	jmp    800a16 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fc:	0f b6 08             	movzbl (%eax),%ecx
  8009ff:	0f b6 1a             	movzbl (%edx),%ebx
  800a02:	38 d9                	cmp    %bl,%cl
  800a04:	74 0a                	je     800a10 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c1             	movzbl %cl,%eax
  800a09:	0f b6 db             	movzbl %bl,%ebx
  800a0c:	29 d8                	sub    %ebx,%eax
  800a0e:	eb 0f                	jmp    800a1f <memcmp+0x35>
		s1++, s2++;
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	39 f0                	cmp    %esi,%eax
  800a18:	75 e2                	jne    8009fc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2a:	89 c1                	mov    %eax,%ecx
  800a2c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a33:	eb 0a                	jmp    800a3f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	39 da                	cmp    %ebx,%edx
  800a3a:	74 07                	je     800a43 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	39 c8                	cmp    %ecx,%eax
  800a41:	72 f2                	jb     800a35 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 03                	jmp    800a57 <strtol+0x11>
		s++;
  800a54:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	0f b6 01             	movzbl (%ecx),%eax
  800a5a:	3c 20                	cmp    $0x20,%al
  800a5c:	74 f6                	je     800a54 <strtol+0xe>
  800a5e:	3c 09                	cmp    $0x9,%al
  800a60:	74 f2                	je     800a54 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a62:	3c 2b                	cmp    $0x2b,%al
  800a64:	75 0a                	jne    800a70 <strtol+0x2a>
		s++;
  800a66:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6e:	eb 11                	jmp    800a81 <strtol+0x3b>
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	3c 2d                	cmp    $0x2d,%al
  800a77:	75 08                	jne    800a81 <strtol+0x3b>
		s++, neg = 1;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a87:	75 15                	jne    800a9e <strtol+0x58>
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	75 10                	jne    800a9e <strtol+0x58>
  800a8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a92:	75 7c                	jne    800b10 <strtol+0xca>
		s += 2, base = 16;
  800a94:	83 c1 02             	add    $0x2,%ecx
  800a97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9c:	eb 16                	jmp    800ab4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	75 12                	jne    800ab4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	75 08                	jne    800ab4 <strtol+0x6e>
		s++, base = 8;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abc:	0f b6 11             	movzbl (%ecx),%edx
  800abf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 09             	cmp    $0x9,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0x8b>
			dig = *s - '0';
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 30             	sub    $0x30,%edx
  800acf:	eb 22                	jmp    800af3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 19             	cmp    $0x19,%bl
  800ad9:	77 08                	ja     800ae3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 57             	sub    $0x57,%edx
  800ae1:	eb 10                	jmp    800af3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 16                	ja     800b03 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af6:	7d 0b                	jge    800b03 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af8:	83 c1 01             	add    $0x1,%ecx
  800afb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aff:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b01:	eb b9                	jmp    800abc <strtol+0x76>

	if (endptr)
  800b03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b07:	74 0d                	je     800b16 <strtol+0xd0>
		*endptr = (char *) s;
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0c:	89 0e                	mov    %ecx,(%esi)
  800b0e:	eb 06                	jmp    800b16 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b10:	85 db                	test   %ebx,%ebx
  800b12:	74 98                	je     800aac <strtol+0x66>
  800b14:	eb 9e                	jmp    800ab4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	f7 da                	neg    %edx
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	0f 45 c2             	cmovne %edx,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 03                	push   $0x3
  800b89:	68 a8 13 80 00       	push   $0x8013a8
  800b8e:	6a 23                	push   $0x23
  800b90:	68 c5 13 80 00       	push   $0x8013c5
  800b95:	e8 8a 02 00 00       	call   800e24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_yield>:

void
sys_yield(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	be 00 00 00 00       	mov    $0x0,%esi
  800bee:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	89 f7                	mov    %esi,%edi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 04                	push   $0x4
  800c0a:	68 a8 13 80 00       	push   $0x8013a8
  800c0f:	6a 23                	push   $0x23
  800c11:	68 c5 13 80 00       	push   $0x8013c5
  800c16:	e8 09 02 00 00       	call   800e24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 05                	push   $0x5
  800c4c:	68 a8 13 80 00       	push   $0x8013a8
  800c51:	6a 23                	push   $0x23
  800c53:	68 c5 13 80 00       	push   $0x8013c5
  800c58:	e8 c7 01 00 00       	call   800e24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 06 00 00 00       	mov    $0x6,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 06                	push   $0x6
  800c8e:	68 a8 13 80 00       	push   $0x8013a8
  800c93:	6a 23                	push   $0x23
  800c95:	68 c5 13 80 00       	push   $0x8013c5
  800c9a:	e8 85 01 00 00       	call   800e24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 08                	push   $0x8
  800cd0:	68 a8 13 80 00       	push   $0x8013a8
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 c5 13 80 00       	push   $0x8013c5
  800cdc:	e8 43 01 00 00       	call   800e24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 09                	push   $0x9
  800d12:	68 a8 13 80 00       	push   $0x8013a8
  800d17:	6a 23                	push   $0x23
  800d19:	68 c5 13 80 00       	push   $0x8013c5
  800d1e:	e8 01 01 00 00       	call   800e24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	be 00 00 00 00       	mov    $0x0,%esi
  800d36:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 0c                	push   $0xc
  800d76:	68 a8 13 80 00       	push   $0x8013a8
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 c5 13 80 00       	push   $0x8013c5
  800d82:	e8 9d 00 00 00       	call   800e24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d95:	68 df 13 80 00       	push   $0x8013df
  800d9a:	6a 51                	push   $0x51
  800d9c:	68 d3 13 80 00       	push   $0x8013d3
  800da1:	e8 7e 00 00 00       	call   800e24 <_panic>

00800da6 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dac:	68 de 13 80 00       	push   $0x8013de
  800db1:	6a 58                	push   $0x58
  800db3:	68 d3 13 80 00       	push   $0x8013d3
  800db8:	e8 67 00 00 00       	call   800e24 <_panic>

00800dbd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800dc3:	68 f4 13 80 00       	push   $0x8013f4
  800dc8:	6a 1a                	push   $0x1a
  800dca:	68 0d 14 80 00       	push   $0x80140d
  800dcf:	e8 50 00 00 00       	call   800e24 <_panic>

00800dd4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800dda:	68 17 14 80 00       	push   $0x801417
  800ddf:	6a 2a                	push   $0x2a
  800de1:	68 0d 14 80 00       	push   $0x80140d
  800de6:	e8 39 00 00 00       	call   800e24 <_panic>

00800deb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800df6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800df9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dff:	8b 52 50             	mov    0x50(%edx),%edx
  800e02:	39 ca                	cmp    %ecx,%edx
  800e04:	75 0d                	jne    800e13 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e06:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e09:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e0e:	8b 40 48             	mov    0x48(%eax),%eax
  800e11:	eb 0f                	jmp    800e22 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e13:	83 c0 01             	add    $0x1,%eax
  800e16:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e1b:	75 d9                	jne    800df6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e2c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e32:	e8 6b fd ff ff       	call   800ba2 <sys_getenvid>
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 0c             	pushl  0xc(%ebp)
  800e3d:	ff 75 08             	pushl  0x8(%ebp)
  800e40:	56                   	push   %esi
  800e41:	50                   	push   %eax
  800e42:	68 30 14 80 00       	push   $0x801430
  800e47:	e8 8d f3 ff ff       	call   8001d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e4c:	83 c4 18             	add    $0x18,%esp
  800e4f:	53                   	push   %ebx
  800e50:	ff 75 10             	pushl  0x10(%ebp)
  800e53:	e8 30 f3 ff ff       	call   800188 <vcprintf>
	cprintf("\n");
  800e58:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  800e5f:	e8 75 f3 ff ff       	call   8001d9 <cprintf>
  800e64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e67:	cc                   	int3   
  800e68:	eb fd                	jmp    800e67 <_panic+0x43>
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 f6                	test   %esi,%esi
  800e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e8d:	89 ca                	mov    %ecx,%edx
  800e8f:	89 f8                	mov    %edi,%eax
  800e91:	75 3d                	jne    800ed0 <__udivdi3+0x60>
  800e93:	39 cf                	cmp    %ecx,%edi
  800e95:	0f 87 c5 00 00 00    	ja     800f60 <__udivdi3+0xf0>
  800e9b:	85 ff                	test   %edi,%edi
  800e9d:	89 fd                	mov    %edi,%ebp
  800e9f:	75 0b                	jne    800eac <__udivdi3+0x3c>
  800ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea6:	31 d2                	xor    %edx,%edx
  800ea8:	f7 f7                	div    %edi
  800eaa:	89 c5                	mov    %eax,%ebp
  800eac:	89 c8                	mov    %ecx,%eax
  800eae:	31 d2                	xor    %edx,%edx
  800eb0:	f7 f5                	div    %ebp
  800eb2:	89 c1                	mov    %eax,%ecx
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	89 cf                	mov    %ecx,%edi
  800eb8:	f7 f5                	div    %ebp
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	89 fa                	mov    %edi,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 ce                	cmp    %ecx,%esi
  800ed2:	77 74                	ja     800f48 <__udivdi3+0xd8>
  800ed4:	0f bd fe             	bsr    %esi,%edi
  800ed7:	83 f7 1f             	xor    $0x1f,%edi
  800eda:	0f 84 98 00 00 00    	je     800f78 <__udivdi3+0x108>
  800ee0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	89 c5                	mov    %eax,%ebp
  800ee9:	29 fb                	sub    %edi,%ebx
  800eeb:	d3 e6                	shl    %cl,%esi
  800eed:	89 d9                	mov    %ebx,%ecx
  800eef:	d3 ed                	shr    %cl,%ebp
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e0                	shl    %cl,%eax
  800ef5:	09 ee                	or     %ebp,%esi
  800ef7:	89 d9                	mov    %ebx,%ecx
  800ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efd:	89 d5                	mov    %edx,%ebp
  800eff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f03:	d3 ed                	shr    %cl,%ebp
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e2                	shl    %cl,%edx
  800f09:	89 d9                	mov    %ebx,%ecx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	09 c2                	or     %eax,%edx
  800f0f:	89 d0                	mov    %edx,%eax
  800f11:	89 ea                	mov    %ebp,%edx
  800f13:	f7 f6                	div    %esi
  800f15:	89 d5                	mov    %edx,%ebp
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	39 d5                	cmp    %edx,%ebp
  800f1f:	72 10                	jb     800f31 <__udivdi3+0xc1>
  800f21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e6                	shl    %cl,%esi
  800f29:	39 c6                	cmp    %eax,%esi
  800f2b:	73 07                	jae    800f34 <__udivdi3+0xc4>
  800f2d:	39 d5                	cmp    %edx,%ebp
  800f2f:	75 03                	jne    800f34 <__udivdi3+0xc4>
  800f31:	83 eb 01             	sub    $0x1,%ebx
  800f34:	31 ff                	xor    %edi,%edi
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	31 ff                	xor    %edi,%edi
  800f4a:	31 db                	xor    %ebx,%ebx
  800f4c:	89 d8                	mov    %ebx,%eax
  800f4e:	89 fa                	mov    %edi,%edx
  800f50:	83 c4 1c             	add    $0x1c,%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	f7 f7                	div    %edi
  800f64:	31 ff                	xor    %edi,%edi
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	89 fa                	mov    %edi,%edx
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	39 ce                	cmp    %ecx,%esi
  800f7a:	72 0c                	jb     800f88 <__udivdi3+0x118>
  800f7c:	31 db                	xor    %ebx,%ebx
  800f7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f82:	0f 87 34 ff ff ff    	ja     800ebc <__udivdi3+0x4c>
  800f88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f8d:	e9 2a ff ff ff       	jmp    800ebc <__udivdi3+0x4c>
  800f92:	66 90                	xchg   %ax,%ax
  800f94:	66 90                	xchg   %ax,%ax
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fb7:	85 d2                	test   %edx,%edx
  800fb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f3                	mov    %esi,%ebx
  800fc3:	89 3c 24             	mov    %edi,(%esp)
  800fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fca:	75 1c                	jne    800fe8 <__umoddi3+0x48>
  800fcc:	39 f7                	cmp    %esi,%edi
  800fce:	76 50                	jbe    801020 <__umoddi3+0x80>
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	f7 f7                	div    %edi
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	39 f2                	cmp    %esi,%edx
  800fea:	89 d0                	mov    %edx,%eax
  800fec:	77 52                	ja     801040 <__umoddi3+0xa0>
  800fee:	0f bd ea             	bsr    %edx,%ebp
  800ff1:	83 f5 1f             	xor    $0x1f,%ebp
  800ff4:	75 5a                	jne    801050 <__umoddi3+0xb0>
  800ff6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800ffa:	0f 82 e0 00 00 00    	jb     8010e0 <__umoddi3+0x140>
  801000:	39 0c 24             	cmp    %ecx,(%esp)
  801003:	0f 86 d7 00 00 00    	jbe    8010e0 <__umoddi3+0x140>
  801009:	8b 44 24 08          	mov    0x8(%esp),%eax
  80100d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801011:	83 c4 1c             	add    $0x1c,%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    
  801019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801020:	85 ff                	test   %edi,%edi
  801022:	89 fd                	mov    %edi,%ebp
  801024:	75 0b                	jne    801031 <__umoddi3+0x91>
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f7                	div    %edi
  80102f:	89 c5                	mov    %eax,%ebp
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f5                	div    %ebp
  801037:	89 c8                	mov    %ecx,%eax
  801039:	f7 f5                	div    %ebp
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	eb 99                	jmp    800fd8 <__umoddi3+0x38>
  80103f:	90                   	nop
  801040:	89 c8                	mov    %ecx,%eax
  801042:	89 f2                	mov    %esi,%edx
  801044:	83 c4 1c             	add    $0x1c,%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	8b 34 24             	mov    (%esp),%esi
  801053:	bf 20 00 00 00       	mov    $0x20,%edi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	29 ef                	sub    %ebp,%edi
  80105c:	d3 e0                	shl    %cl,%eax
  80105e:	89 f9                	mov    %edi,%ecx
  801060:	89 f2                	mov    %esi,%edx
  801062:	d3 ea                	shr    %cl,%edx
  801064:	89 e9                	mov    %ebp,%ecx
  801066:	09 c2                	or     %eax,%edx
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	89 14 24             	mov    %edx,(%esp)
  80106d:	89 f2                	mov    %esi,%edx
  80106f:	d3 e2                	shl    %cl,%edx
  801071:	89 f9                	mov    %edi,%ecx
  801073:	89 54 24 04          	mov    %edx,0x4(%esp)
  801077:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80107b:	d3 e8                	shr    %cl,%eax
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	89 c6                	mov    %eax,%esi
  801081:	d3 e3                	shl    %cl,%ebx
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 d0                	mov    %edx,%eax
  801087:	d3 e8                	shr    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	09 d8                	or     %ebx,%eax
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 f2                	mov    %esi,%edx
  801091:	f7 34 24             	divl   (%esp)
  801094:	89 d6                	mov    %edx,%esi
  801096:	d3 e3                	shl    %cl,%ebx
  801098:	f7 64 24 04          	mull   0x4(%esp)
  80109c:	39 d6                	cmp    %edx,%esi
  80109e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a2:	89 d1                	mov    %edx,%ecx
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	72 08                	jb     8010b0 <__umoddi3+0x110>
  8010a8:	75 11                	jne    8010bb <__umoddi3+0x11b>
  8010aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ae:	73 0b                	jae    8010bb <__umoddi3+0x11b>
  8010b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010b4:	1b 14 24             	sbb    (%esp),%edx
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	89 c3                	mov    %eax,%ebx
  8010bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010bf:	29 da                	sub    %ebx,%edx
  8010c1:	19 ce                	sbb    %ecx,%esi
  8010c3:	89 f9                	mov    %edi,%ecx
  8010c5:	89 f0                	mov    %esi,%eax
  8010c7:	d3 e0                	shl    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	d3 ea                	shr    %cl,%edx
  8010cd:	89 e9                	mov    %ebp,%ecx
  8010cf:	d3 ee                	shr    %cl,%esi
  8010d1:	09 d0                	or     %edx,%eax
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	83 c4 1c             	add    $0x1c,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	29 f9                	sub    %edi,%ecx
  8010e2:	19 d6                	sbb    %edx,%esi
  8010e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ec:	e9 18 ff ff ff       	jmp    801009 <__umoddi3+0x69>
