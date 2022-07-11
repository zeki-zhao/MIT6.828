
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 e0 0f 80 00       	push   $0x800fe0
  800056:	e8 e0 00 00 00       	call   80013b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 05 00 00 00       	call   800096 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 20 0a 00 00       	call   800ac3 <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 13                	mov    (%ebx),%edx
  8000b4:	8d 42 01             	lea    0x1(%edx),%eax
  8000b7:	89 03                	mov    %eax,(%ebx)
  8000b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c5:	75 1a                	jne    8000e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	68 ff 00 00 00       	push   $0xff
  8000cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 ae 09 00 00       	call   800a86 <sys_cputs>
		b->idx = 0;
  8000d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a8 00 80 00       	push   $0x8000a8
  800119:	e8 1a 01 00 00       	call   800238 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 53 09 00 00       	call   800a86 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800165:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800170:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800173:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800176:	39 d3                	cmp    %edx,%ebx
  800178:	72 05                	jb     80017f <printnum+0x30>
  80017a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017d:	77 45                	ja     8001c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 18             	pushl  0x18(%ebp)
  800185:	8b 45 14             	mov    0x14(%ebp),%eax
  800188:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018b:	53                   	push   %ebx
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	ff 75 e4             	pushl  -0x1c(%ebp)
  800195:	ff 75 e0             	pushl  -0x20(%ebp)
  800198:	ff 75 dc             	pushl  -0x24(%ebp)
  80019b:	ff 75 d8             	pushl  -0x28(%ebp)
  80019e:	e8 9d 0b 00 00       	call   800d40 <__udivdi3>
  8001a3:	83 c4 18             	add    $0x18,%esp
  8001a6:	52                   	push   %edx
  8001a7:	50                   	push   %eax
  8001a8:	89 f2                	mov    %esi,%edx
  8001aa:	89 f8                	mov    %edi,%eax
  8001ac:	e8 9e ff ff ff       	call   80014f <printnum>
  8001b1:	83 c4 20             	add    $0x20,%esp
  8001b4:	eb 18                	jmp    8001ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	ff d7                	call   *%edi
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	eb 03                	jmp    8001c7 <printnum+0x78>
  8001c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c7:	83 eb 01             	sub    $0x1,%ebx
  8001ca:	85 db                	test   %ebx,%ebx
  8001cc:	7f e8                	jg     8001b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001db:	ff 75 dc             	pushl  -0x24(%ebp)
  8001de:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e1:	e8 8a 0c 00 00       	call   800e70 <__umoddi3>
  8001e6:	83 c4 14             	add    $0x14,%esp
  8001e9:	0f be 80 f8 0f 80 00 	movsbl 0x800ff8(%eax),%eax
  8001f0:	50                   	push   %eax
  8001f1:	ff d7                	call   *%edi
}
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800204:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800208:	8b 10                	mov    (%eax),%edx
  80020a:	3b 50 04             	cmp    0x4(%eax),%edx
  80020d:	73 0a                	jae    800219 <sprintputch+0x1b>
		*b->buf++ = ch;
  80020f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800212:	89 08                	mov    %ecx,(%eax)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	88 02                	mov    %al,(%edx)
}
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800221:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800224:	50                   	push   %eax
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	e8 05 00 00 00       	call   800238 <vprintfmt>
	va_end(ap);
}
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
  800241:	8b 75 08             	mov    0x8(%ebp),%esi
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800247:	8b 7d 10             	mov    0x10(%ebp),%edi
  80024a:	eb 12                	jmp    80025e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80024c:	85 c0                	test   %eax,%eax
  80024e:	0f 84 42 04 00 00    	je     800696 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	53                   	push   %ebx
  800258:	50                   	push   %eax
  800259:	ff d6                	call   *%esi
  80025b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80025e:	83 c7 01             	add    $0x1,%edi
  800261:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800265:	83 f8 25             	cmp    $0x25,%eax
  800268:	75 e2                	jne    80024c <vprintfmt+0x14>
  80026a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80026e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800275:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80027c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800283:	b9 00 00 00 00       	mov    $0x0,%ecx
  800288:	eb 07                	jmp    800291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80028a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80028d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800291:	8d 47 01             	lea    0x1(%edi),%eax
  800294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800297:	0f b6 07             	movzbl (%edi),%eax
  80029a:	0f b6 d0             	movzbl %al,%edx
  80029d:	83 e8 23             	sub    $0x23,%eax
  8002a0:	3c 55                	cmp    $0x55,%al
  8002a2:	0f 87 d3 03 00 00    	ja     80067b <vprintfmt+0x443>
  8002a8:	0f b6 c0             	movzbl %al,%eax
  8002ab:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b9:	eb d6                	jmp    800291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002be:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d3:	83 f9 09             	cmp    $0x9,%ecx
  8002d6:	77 3f                	ja     800317 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002db:	eb e9                	jmp    8002c6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e0:	8b 00                	mov    (%eax),%eax
  8002e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e8:	8d 40 04             	lea    0x4(%eax),%eax
  8002eb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002f1:	eb 2a                	jmp    80031d <vprintfmt+0xe5>
  8002f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	0f 49 d0             	cmovns %eax,%edx
  800300:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800306:	eb 89                	jmp    800291 <vprintfmt+0x59>
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80030b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800312:	e9 7a ff ff ff       	jmp    800291 <vprintfmt+0x59>
  800317:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80031d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800321:	0f 89 6a ff ff ff    	jns    800291 <vprintfmt+0x59>
				width = precision, precision = -1;
  800327:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80032a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800334:	e9 58 ff ff ff       	jmp    800291 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800339:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80033f:	e9 4d ff ff ff       	jmp    800291 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 78 04             	lea    0x4(%eax),%edi
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	ff 30                	pushl  (%eax)
  800350:	ff d6                	call   *%esi
			break;
  800352:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800355:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80035b:	e9 fe fe ff ff       	jmp    80025e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 78 04             	lea    0x4(%eax),%edi
  800366:	8b 00                	mov    (%eax),%eax
  800368:	99                   	cltd   
  800369:	31 d0                	xor    %edx,%eax
  80036b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036d:	83 f8 09             	cmp    $0x9,%eax
  800370:	7f 0b                	jg     80037d <vprintfmt+0x145>
  800372:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800379:	85 d2                	test   %edx,%edx
  80037b:	75 1b                	jne    800398 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80037d:	50                   	push   %eax
  80037e:	68 10 10 80 00       	push   $0x801010
  800383:	53                   	push   %ebx
  800384:	56                   	push   %esi
  800385:	e8 91 fe ff ff       	call   80021b <printfmt>
  80038a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800393:	e9 c6 fe ff ff       	jmp    80025e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800398:	52                   	push   %edx
  800399:	68 19 10 80 00       	push   $0x801019
  80039e:	53                   	push   %ebx
  80039f:	56                   	push   %esi
  8003a0:	e8 76 fe ff ff       	call   80021b <printfmt>
  8003a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	e9 ab fe ff ff       	jmp    80025e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	83 c0 04             	add    $0x4,%eax
  8003b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c1:	85 ff                	test   %edi,%edi
  8003c3:	b8 09 10 80 00       	mov    $0x801009,%eax
  8003c8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cf:	0f 8e 94 00 00 00    	jle    800469 <vprintfmt+0x231>
  8003d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003d9:	0f 84 98 00 00 00    	je     800477 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e5:	57                   	push   %edi
  8003e6:	e8 33 03 00 00       	call   80071e <strnlen>
  8003eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ee:	29 c1                	sub    %eax,%ecx
  8003f0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800400:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800402:	eb 0f                	jmp    800413 <vprintfmt+0x1db>
					putch(padc, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	83 ef 01             	sub    $0x1,%edi
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 ff                	test   %edi,%edi
  800415:	7f ed                	jg     800404 <vprintfmt+0x1cc>
  800417:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80041a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80041d:	85 c9                	test   %ecx,%ecx
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
  800424:	0f 49 c1             	cmovns %ecx,%eax
  800427:	29 c1                	sub    %eax,%ecx
  800429:	89 75 08             	mov    %esi,0x8(%ebp)
  80042c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800432:	89 cb                	mov    %ecx,%ebx
  800434:	eb 4d                	jmp    800483 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800436:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043a:	74 1b                	je     800457 <vprintfmt+0x21f>
  80043c:	0f be c0             	movsbl %al,%eax
  80043f:	83 e8 20             	sub    $0x20,%eax
  800442:	83 f8 5e             	cmp    $0x5e,%eax
  800445:	76 10                	jbe    800457 <vprintfmt+0x21f>
					putch('?', putdat);
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	ff 75 0c             	pushl  0xc(%ebp)
  80044d:	6a 3f                	push   $0x3f
  80044f:	ff 55 08             	call   *0x8(%ebp)
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	eb 0d                	jmp    800464 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 0c             	pushl  0xc(%ebp)
  80045d:	52                   	push   %edx
  80045e:	ff 55 08             	call   *0x8(%ebp)
  800461:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800464:	83 eb 01             	sub    $0x1,%ebx
  800467:	eb 1a                	jmp    800483 <vprintfmt+0x24b>
  800469:	89 75 08             	mov    %esi,0x8(%ebp)
  80046c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800472:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800475:	eb 0c                	jmp    800483 <vprintfmt+0x24b>
  800477:	89 75 08             	mov    %esi,0x8(%ebp)
  80047a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800480:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800483:	83 c7 01             	add    $0x1,%edi
  800486:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048a:	0f be d0             	movsbl %al,%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	74 23                	je     8004b4 <vprintfmt+0x27c>
  800491:	85 f6                	test   %esi,%esi
  800493:	78 a1                	js     800436 <vprintfmt+0x1fe>
  800495:	83 ee 01             	sub    $0x1,%esi
  800498:	79 9c                	jns    800436 <vprintfmt+0x1fe>
  80049a:	89 df                	mov    %ebx,%edi
  80049c:	8b 75 08             	mov    0x8(%ebp),%esi
  80049f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a2:	eb 18                	jmp    8004bc <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	53                   	push   %ebx
  8004a8:	6a 20                	push   $0x20
  8004aa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ac:	83 ef 01             	sub    $0x1,%edi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	eb 08                	jmp    8004bc <vprintfmt+0x284>
  8004b4:	89 df                	mov    %ebx,%edi
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bc:	85 ff                	test   %edi,%edi
  8004be:	7f e4                	jg     8004a4 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	e9 90 fd ff ff       	jmp    80025e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ce:	83 f9 01             	cmp    $0x1,%ecx
  8004d1:	7e 19                	jle    8004ec <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8b 50 04             	mov    0x4(%eax),%edx
  8004d9:	8b 00                	mov    (%eax),%eax
  8004db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 40 08             	lea    0x8(%eax),%eax
  8004e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ea:	eb 38                	jmp    800524 <vprintfmt+0x2ec>
	else if (lflag)
  8004ec:	85 c9                	test   %ecx,%ecx
  8004ee:	74 1b                	je     80050b <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f8:	89 c1                	mov    %eax,%ecx
  8004fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 40 04             	lea    0x4(%eax),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
  800509:	eb 19                	jmp    800524 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 c1                	mov    %eax,%ecx
  800515:	c1 f9 1f             	sar    $0x1f,%ecx
  800518:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80052a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80052f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800533:	0f 89 0e 01 00 00    	jns    800647 <vprintfmt+0x40f>
				putch('-', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	6a 2d                	push   $0x2d
  80053f:	ff d6                	call   *%esi
				num = -(long long) num;
  800541:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800547:	f7 da                	neg    %edx
  800549:	83 d1 00             	adc    $0x0,%ecx
  80054c:	f7 d9                	neg    %ecx
  80054e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800551:	b8 0a 00 00 00       	mov    $0xa,%eax
  800556:	e9 ec 00 00 00       	jmp    800647 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055b:	83 f9 01             	cmp    $0x1,%ecx
  80055e:	7e 18                	jle    800578 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 10                	mov    (%eax),%edx
  800565:	8b 48 04             	mov    0x4(%eax),%ecx
  800568:	8d 40 08             	lea    0x8(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800573:	e9 cf 00 00 00       	jmp    800647 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	74 1a                	je     800596 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	b9 00 00 00 00       	mov    $0x0,%ecx
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800591:	e9 b1 00 00 00       	jmp    800647 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a0:	8d 40 04             	lea    0x4(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 97 00 00 00       	jmp    800647 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 58                	push   $0x58
  8005b6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005b8:	83 c4 08             	add    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	6a 58                	push   $0x58
  8005be:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c0:	83 c4 08             	add    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 58                	push   $0x58
  8005c6:	ff d6                	call   *%esi
			break;
  8005c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005ce:	e9 8b fc ff ff       	jmp    80025e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 30                	push   $0x30
  8005d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 78                	push   $0x78
  8005e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ed:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005fb:	eb 4a                	jmp    800647 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fd:	83 f9 01             	cmp    $0x1,%ecx
  800600:	7e 15                	jle    800617 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	8b 48 04             	mov    0x4(%eax),%ecx
  80060a:	8d 40 08             	lea    0x8(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800610:	b8 10 00 00 00       	mov    $0x10,%eax
  800615:	eb 30                	jmp    800647 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	74 17                	je     800632 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
  800630:	eb 15                	jmp    800647 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800642:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800647:	83 ec 0c             	sub    $0xc,%esp
  80064a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064e:	57                   	push   %edi
  80064f:	ff 75 e0             	pushl  -0x20(%ebp)
  800652:	50                   	push   %eax
  800653:	51                   	push   %ecx
  800654:	52                   	push   %edx
  800655:	89 da                	mov    %ebx,%edx
  800657:	89 f0                	mov    %esi,%eax
  800659:	e8 f1 fa ff ff       	call   80014f <printnum>
			break;
  80065e:	83 c4 20             	add    $0x20,%esp
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800664:	e9 f5 fb ff ff       	jmp    80025e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	52                   	push   %edx
  80066e:	ff d6                	call   *%esi
			break;
  800670:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800676:	e9 e3 fb ff ff       	jmp    80025e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 25                	push   $0x25
  800681:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 03                	jmp    80068b <vprintfmt+0x453>
  800688:	83 ef 01             	sub    $0x1,%edi
  80068b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068f:	75 f7                	jne    800688 <vprintfmt+0x450>
  800691:	e9 c8 fb ff ff       	jmp    80025e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 18             	sub    $0x18,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 26                	je     8006e5 <vsnprintf+0x47>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 22                	jle    8006e5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	ff 75 14             	pushl  0x14(%ebp)
  8006c6:	ff 75 10             	pushl  0x10(%ebp)
  8006c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	68 fe 01 80 00       	push   $0x8001fe
  8006d2:	e8 61 fb ff ff       	call   800238 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb 05                	jmp    8006ea <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f5:	50                   	push   %eax
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	ff 75 08             	pushl  0x8(%ebp)
  8006ff:	e8 9a ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070c:	b8 00 00 00 00       	mov    $0x0,%eax
  800711:	eb 03                	jmp    800716 <strlen+0x10>
		n++;
  800713:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071a:	75 f7                	jne    800713 <strlen+0xd>
		n++;
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	ba 00 00 00 00       	mov    $0x0,%edx
  80072c:	eb 03                	jmp    800731 <strnlen+0x13>
		n++;
  80072e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800731:	39 c2                	cmp    %eax,%edx
  800733:	74 08                	je     80073d <strnlen+0x1f>
  800735:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800739:	75 f3                	jne    80072e <strnlen+0x10>
  80073b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800749:	89 c2                	mov    %eax,%edx
  80074b:	83 c2 01             	add    $0x1,%edx
  80074e:	83 c1 01             	add    $0x1,%ecx
  800751:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800755:	88 5a ff             	mov    %bl,-0x1(%edx)
  800758:	84 db                	test   %bl,%bl
  80075a:	75 ef                	jne    80074b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075c:	5b                   	pop    %ebx
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800766:	53                   	push   %ebx
  800767:	e8 9a ff ff ff       	call   800706 <strlen>
  80076c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	01 d8                	add    %ebx,%eax
  800774:	50                   	push   %eax
  800775:	e8 c5 ff ff ff       	call   80073f <strcpy>
	return dst;
}
  80077a:	89 d8                	mov    %ebx,%eax
  80077c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	89 f3                	mov    %esi,%ebx
  80078e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	89 f2                	mov    %esi,%edx
  800793:	eb 0f                	jmp    8007a4 <strncpy+0x23>
		*dst++ = *src;
  800795:	83 c2 01             	add    $0x1,%edx
  800798:	0f b6 01             	movzbl (%ecx),%eax
  80079b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079e:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a4:	39 da                	cmp    %ebx,%edx
  8007a6:	75 ed                	jne    800795 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	56                   	push   %esi
  8007b2:	53                   	push   %ebx
  8007b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	74 21                	je     8007e3 <strlcpy+0x35>
  8007c2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c6:	89 f2                	mov    %esi,%edx
  8007c8:	eb 09                	jmp    8007d3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d3:	39 c2                	cmp    %eax,%edx
  8007d5:	74 09                	je     8007e0 <strlcpy+0x32>
  8007d7:	0f b6 19             	movzbl (%ecx),%ebx
  8007da:	84 db                	test   %bl,%bl
  8007dc:	75 ec                	jne    8007ca <strlcpy+0x1c>
  8007de:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e3:	29 f0                	sub    %esi,%eax
}
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f2:	eb 06                	jmp    8007fa <strcmp+0x11>
		p++, q++;
  8007f4:	83 c1 01             	add    $0x1,%ecx
  8007f7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fa:	0f b6 01             	movzbl (%ecx),%eax
  8007fd:	84 c0                	test   %al,%al
  8007ff:	74 04                	je     800805 <strcmp+0x1c>
  800801:	3a 02                	cmp    (%edx),%al
  800803:	74 ef                	je     8007f4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800805:	0f b6 c0             	movzbl %al,%eax
  800808:	0f b6 12             	movzbl (%edx),%edx
  80080b:	29 d0                	sub    %edx,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 c3                	mov    %eax,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081e:	eb 06                	jmp    800826 <strncmp+0x17>
		n--, p++, q++;
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800826:	39 d8                	cmp    %ebx,%eax
  800828:	74 15                	je     80083f <strncmp+0x30>
  80082a:	0f b6 08             	movzbl (%eax),%ecx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	74 04                	je     800835 <strncmp+0x26>
  800831:	3a 0a                	cmp    (%edx),%cl
  800833:	74 eb                	je     800820 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 00             	movzbl (%eax),%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
  80083d:	eb 05                	jmp    800844 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800844:	5b                   	pop    %ebx
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800851:	eb 07                	jmp    80085a <strchr+0x13>
		if (*s == c)
  800853:	38 ca                	cmp    %cl,%dl
  800855:	74 0f                	je     800866 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	0f b6 10             	movzbl (%eax),%edx
  80085d:	84 d2                	test   %dl,%dl
  80085f:	75 f2                	jne    800853 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800872:	eb 03                	jmp    800877 <strfind+0xf>
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087a:	38 ca                	cmp    %cl,%dl
  80087c:	74 04                	je     800882 <strfind+0x1a>
  80087e:	84 d2                	test   %dl,%dl
  800880:	75 f2                	jne    800874 <strfind+0xc>
			break;
	return (char *) s;
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800890:	85 c9                	test   %ecx,%ecx
  800892:	74 36                	je     8008ca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800894:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089a:	75 28                	jne    8008c4 <memset+0x40>
  80089c:	f6 c1 03             	test   $0x3,%cl
  80089f:	75 23                	jne    8008c4 <memset+0x40>
		c &= 0xFF;
  8008a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a5:	89 d3                	mov    %edx,%ebx
  8008a7:	c1 e3 08             	shl    $0x8,%ebx
  8008aa:	89 d6                	mov    %edx,%esi
  8008ac:	c1 e6 18             	shl    $0x18,%esi
  8008af:	89 d0                	mov    %edx,%eax
  8008b1:	c1 e0 10             	shl    $0x10,%eax
  8008b4:	09 f0                	or     %esi,%eax
  8008b6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b8:	89 d8                	mov    %ebx,%eax
  8008ba:	09 d0                	or     %edx,%eax
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
  8008bf:	fc                   	cld    
  8008c0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c2:	eb 06                	jmp    8008ca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c7:	fc                   	cld    
  8008c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ca:	89 f8                	mov    %edi,%eax
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008df:	39 c6                	cmp    %eax,%esi
  8008e1:	73 35                	jae    800918 <memmove+0x47>
  8008e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e6:	39 d0                	cmp    %edx,%eax
  8008e8:	73 2e                	jae    800918 <memmove+0x47>
		s += n;
		d += n;
  8008ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	09 fe                	or     %edi,%esi
  8008f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f7:	75 13                	jne    80090c <memmove+0x3b>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 0e                	jne    80090c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	8d 72 fc             	lea    -0x4(%edx),%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
  800907:	fd                   	std    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 09                	jmp    800915 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090c:	83 ef 01             	sub    $0x1,%edi
  80090f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800912:	fd                   	std    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800915:	fc                   	cld    
  800916:	eb 1d                	jmp    800935 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	89 f2                	mov    %esi,%edx
  80091a:	09 c2                	or     %eax,%edx
  80091c:	f6 c2 03             	test   $0x3,%dl
  80091f:	75 0f                	jne    800930 <memmove+0x5f>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 0a                	jne    800930 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800926:	c1 e9 02             	shr    $0x2,%ecx
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 05                	jmp    800935 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800930:	89 c7                	mov    %eax,%edi
  800932:	fc                   	cld    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093c:	ff 75 10             	pushl  0x10(%ebp)
  80093f:	ff 75 0c             	pushl  0xc(%ebp)
  800942:	ff 75 08             	pushl  0x8(%ebp)
  800945:	e8 87 ff ff ff       	call   8008d1 <memmove>
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 c6                	mov    %eax,%esi
  800959:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095c:	eb 1a                	jmp    800978 <memcmp+0x2c>
		if (*s1 != *s2)
  80095e:	0f b6 08             	movzbl (%eax),%ecx
  800961:	0f b6 1a             	movzbl (%edx),%ebx
  800964:	38 d9                	cmp    %bl,%cl
  800966:	74 0a                	je     800972 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800968:	0f b6 c1             	movzbl %cl,%eax
  80096b:	0f b6 db             	movzbl %bl,%ebx
  80096e:	29 d8                	sub    %ebx,%eax
  800970:	eb 0f                	jmp    800981 <memcmp+0x35>
		s1++, s2++;
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	39 f0                	cmp    %esi,%eax
  80097a:	75 e2                	jne    80095e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098c:	89 c1                	mov    %eax,%ecx
  80098e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	eb 0a                	jmp    8009a1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 10             	movzbl (%eax),%edx
  80099a:	39 da                	cmp    %ebx,%edx
  80099c:	74 07                	je     8009a5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	39 c8                	cmp    %ecx,%eax
  8009a3:	72 f2                	jb     800997 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b4:	eb 03                	jmp    8009b9 <strtol+0x11>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b9:	0f b6 01             	movzbl (%ecx),%eax
  8009bc:	3c 20                	cmp    $0x20,%al
  8009be:	74 f6                	je     8009b6 <strtol+0xe>
  8009c0:	3c 09                	cmp    $0x9,%al
  8009c2:	74 f2                	je     8009b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c4:	3c 2b                	cmp    $0x2b,%al
  8009c6:	75 0a                	jne    8009d2 <strtol+0x2a>
		s++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d0:	eb 11                	jmp    8009e3 <strtol+0x3b>
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d7:	3c 2d                	cmp    $0x2d,%al
  8009d9:	75 08                	jne    8009e3 <strtol+0x3b>
		s++, neg = 1;
  8009db:	83 c1 01             	add    $0x1,%ecx
  8009de:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e9:	75 15                	jne    800a00 <strtol+0x58>
  8009eb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ee:	75 10                	jne    800a00 <strtol+0x58>
  8009f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f4:	75 7c                	jne    800a72 <strtol+0xca>
		s += 2, base = 16;
  8009f6:	83 c1 02             	add    $0x2,%ecx
  8009f9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fe:	eb 16                	jmp    800a16 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a00:	85 db                	test   %ebx,%ebx
  800a02:	75 12                	jne    800a16 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a04:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a09:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0c:	75 08                	jne    800a16 <strtol+0x6e>
		s++, base = 8;
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1e:	0f b6 11             	movzbl (%ecx),%edx
  800a21:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 09             	cmp    $0x9,%bl
  800a29:	77 08                	ja     800a33 <strtol+0x8b>
			dig = *s - '0';
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 30             	sub    $0x30,%edx
  800a31:	eb 22                	jmp    800a55 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a33:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 08                	ja     800a45 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 57             	sub    $0x57,%edx
  800a43:	eb 10                	jmp    800a55 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a45:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 19             	cmp    $0x19,%bl
  800a4d:	77 16                	ja     800a65 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a55:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a58:	7d 0b                	jge    800a65 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a61:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a63:	eb b9                	jmp    800a1e <strtol+0x76>

	if (endptr)
  800a65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a69:	74 0d                	je     800a78 <strtol+0xd0>
		*endptr = (char *) s;
  800a6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6e:	89 0e                	mov    %ecx,(%esi)
  800a70:	eb 06                	jmp    800a78 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a72:	85 db                	test   %ebx,%ebx
  800a74:	74 98                	je     800a0e <strtol+0x66>
  800a76:	eb 9e                	jmp    800a16 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a78:	89 c2                	mov    %eax,%edx
  800a7a:	f7 da                	neg    %edx
  800a7c:	85 ff                	test   %edi,%edi
  800a7e:	0f 45 c2             	cmovne %edx,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	89 c6                	mov    %eax,%esi
  800a9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab4:	89 d1                	mov    %edx,%ecx
  800ab6:	89 d3                	mov    %edx,%ebx
  800ab8:	89 d7                	mov    %edx,%edi
  800aba:	89 d6                	mov    %edx,%esi
  800abc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	89 cb                	mov    %ecx,%ebx
  800adb:	89 cf                	mov    %ecx,%edi
  800add:	89 ce                	mov    %ecx,%esi
  800adf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	7e 17                	jle    800afc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	50                   	push   %eax
  800ae9:	6a 03                	push   $0x3
  800aeb:	68 48 12 80 00       	push   $0x801248
  800af0:	6a 23                	push   $0x23
  800af2:	68 65 12 80 00       	push   $0x801265
  800af7:	e8 f5 01 00 00       	call   800cf1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_yield>:

void
sys_yield(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	be 00 00 00 00       	mov    $0x0,%esi
  800b50:	b8 04 00 00 00       	mov    $0x4,%eax
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5e:	89 f7                	mov    %esi,%edi
  800b60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 04                	push   $0x4
  800b6c:	68 48 12 80 00       	push   $0x801248
  800b71:	6a 23                	push   $0x23
  800b73:	68 65 12 80 00       	push   $0x801265
  800b78:	e8 74 01 00 00       	call   800cf1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 17                	jle    800bbf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 05                	push   $0x5
  800bae:	68 48 12 80 00       	push   $0x801248
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 65 12 80 00       	push   $0x801265
  800bba:	e8 32 01 00 00       	call   800cf1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800be0:	89 df                	mov    %ebx,%edi
  800be2:	89 de                	mov    %ebx,%esi
  800be4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7e 17                	jle    800c01 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 06                	push   $0x6
  800bf0:	68 48 12 80 00       	push   $0x801248
  800bf5:	6a 23                	push   $0x23
  800bf7:	68 65 12 80 00       	push   $0x801265
  800bfc:	e8 f0 00 00 00       	call   800cf1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	89 df                	mov    %ebx,%edi
  800c24:	89 de                	mov    %ebx,%esi
  800c26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7e 17                	jle    800c43 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 08                	push   $0x8
  800c32:	68 48 12 80 00       	push   $0x801248
  800c37:	6a 23                	push   $0x23
  800c39:	68 65 12 80 00       	push   $0x801265
  800c3e:	e8 ae 00 00 00       	call   800cf1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 17                	jle    800c85 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 09                	push   $0x9
  800c74:	68 48 12 80 00       	push   $0x801248
  800c79:	6a 23                	push   $0x23
  800c7b:	68 65 12 80 00       	push   $0x801265
  800c80:	e8 6c 00 00 00       	call   800cf1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	be 00 00 00 00       	mov    $0x0,%esi
  800c98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 cb                	mov    %ecx,%ebx
  800cc8:	89 cf                	mov    %ecx,%edi
  800cca:	89 ce                	mov    %ecx,%esi
  800ccc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 0c                	push   $0xc
  800cd8:	68 48 12 80 00       	push   $0x801248
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 65 12 80 00       	push   $0x801265
  800ce4:	e8 08 00 00 00       	call   800cf1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cf6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cf9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cff:	e8 00 fe ff ff       	call   800b04 <sys_getenvid>
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	ff 75 0c             	pushl  0xc(%ebp)
  800d0a:	ff 75 08             	pushl  0x8(%ebp)
  800d0d:	56                   	push   %esi
  800d0e:	50                   	push   %eax
  800d0f:	68 74 12 80 00       	push   $0x801274
  800d14:	e8 22 f4 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d19:	83 c4 18             	add    $0x18,%esp
  800d1c:	53                   	push   %ebx
  800d1d:	ff 75 10             	pushl  0x10(%ebp)
  800d20:	e8 c5 f3 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800d25:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d2c:	e8 0a f4 ff ff       	call   80013b <cprintf>
  800d31:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d34:	cc                   	int3   
  800d35:	eb fd                	jmp    800d34 <_panic+0x43>
  800d37:	66 90                	xchg   %ax,%ax
  800d39:	66 90                	xchg   %ax,%ax
  800d3b:	66 90                	xchg   %ax,%ax
  800d3d:	66 90                	xchg   %ax,%ax
  800d3f:	90                   	nop

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 f6                	test   %esi,%esi
  800d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5d:	89 ca                	mov    %ecx,%edx
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	75 3d                	jne    800da0 <__udivdi3+0x60>
  800d63:	39 cf                	cmp    %ecx,%edi
  800d65:	0f 87 c5 00 00 00    	ja     800e30 <__udivdi3+0xf0>
  800d6b:	85 ff                	test   %edi,%edi
  800d6d:	89 fd                	mov    %edi,%ebp
  800d6f:	75 0b                	jne    800d7c <__udivdi3+0x3c>
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	31 d2                	xor    %edx,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	89 c5                	mov    %eax,%ebp
  800d7c:	89 c8                	mov    %ecx,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f5                	div    %ebp
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	f7 f5                	div    %ebp
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	89 fa                	mov    %edi,%edx
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
  800d98:	90                   	nop
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 ce                	cmp    %ecx,%esi
  800da2:	77 74                	ja     800e18 <__udivdi3+0xd8>
  800da4:	0f bd fe             	bsr    %esi,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0x108>
  800db0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	89 c5                	mov    %eax,%ebp
  800db9:	29 fb                	sub    %edi,%ebx
  800dbb:	d3 e6                	shl    %cl,%esi
  800dbd:	89 d9                	mov    %ebx,%ecx
  800dbf:	d3 ed                	shr    %cl,%ebp
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e0                	shl    %cl,%eax
  800dc5:	09 ee                	or     %ebp,%esi
  800dc7:	89 d9                	mov    %ebx,%ecx
  800dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcd:	89 d5                	mov    %edx,%ebp
  800dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd3:	d3 ed                	shr    %cl,%ebp
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e2                	shl    %cl,%edx
  800dd9:	89 d9                	mov    %ebx,%ecx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	09 c2                	or     %eax,%edx
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	89 ea                	mov    %ebp,%edx
  800de3:	f7 f6                	div    %esi
  800de5:	89 d5                	mov    %edx,%ebp
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	f7 64 24 0c          	mull   0xc(%esp)
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	72 10                	jb     800e01 <__udivdi3+0xc1>
  800df1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e6                	shl    %cl,%esi
  800df9:	39 c6                	cmp    %eax,%esi
  800dfb:	73 07                	jae    800e04 <__udivdi3+0xc4>
  800dfd:	39 d5                	cmp    %edx,%ebp
  800dff:	75 03                	jne    800e04 <__udivdi3+0xc4>
  800e01:	83 eb 01             	sub    $0x1,%ebx
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	83 c4 1c             	add    $0x1c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e18:	31 ff                	xor    %edi,%edi
  800e1a:	31 db                	xor    %ebx,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	f7 f7                	div    %edi
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	89 fa                	mov    %edi,%edx
  800e3c:	83 c4 1c             	add    $0x1c,%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    
  800e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e48:	39 ce                	cmp    %ecx,%esi
  800e4a:	72 0c                	jb     800e58 <__udivdi3+0x118>
  800e4c:	31 db                	xor    %ebx,%ebx
  800e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e52:	0f 87 34 ff ff ff    	ja     800d8c <__udivdi3+0x4c>
  800e58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e5d:	e9 2a ff ff ff       	jmp    800d8c <__udivdi3+0x4c>
  800e62:	66 90                	xchg   %ax,%ax
  800e64:	66 90                	xchg   %ax,%ax
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 d2                	test   %edx,%edx
  800e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f3                	mov    %esi,%ebx
  800e93:	89 3c 24             	mov    %edi,(%esp)
  800e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9a:	75 1c                	jne    800eb8 <__umoddi3+0x48>
  800e9c:	39 f7                	cmp    %esi,%edi
  800e9e:	76 50                	jbe    800ef0 <__umoddi3+0x80>
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	f7 f7                	div    %edi
  800ea6:	89 d0                	mov    %edx,%eax
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	77 52                	ja     800f10 <__umoddi3+0xa0>
  800ebe:	0f bd ea             	bsr    %edx,%ebp
  800ec1:	83 f5 1f             	xor    $0x1f,%ebp
  800ec4:	75 5a                	jne    800f20 <__umoddi3+0xb0>
  800ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eca:	0f 82 e0 00 00 00    	jb     800fb0 <__umoddi3+0x140>
  800ed0:	39 0c 24             	cmp    %ecx,(%esp)
  800ed3:	0f 86 d7 00 00 00    	jbe    800fb0 <__umoddi3+0x140>
  800ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800edd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	85 ff                	test   %edi,%edi
  800ef2:	89 fd                	mov    %edi,%ebp
  800ef4:	75 0b                	jne    800f01 <__umoddi3+0x91>
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f7                	div    %edi
  800eff:	89 c5                	mov    %eax,%ebp
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	f7 f5                	div    %ebp
  800f07:	89 c8                	mov    %ecx,%eax
  800f09:	f7 f5                	div    %ebp
  800f0b:	89 d0                	mov    %edx,%eax
  800f0d:	eb 99                	jmp    800ea8 <__umoddi3+0x38>
  800f0f:	90                   	nop
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	83 c4 1c             	add    $0x1c,%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
  800f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f20:	8b 34 24             	mov    (%esp),%esi
  800f23:	bf 20 00 00 00       	mov    $0x20,%edi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	29 ef                	sub    %ebp,%edi
  800f2c:	d3 e0                	shl    %cl,%eax
  800f2e:	89 f9                	mov    %edi,%ecx
  800f30:	89 f2                	mov    %esi,%edx
  800f32:	d3 ea                	shr    %cl,%edx
  800f34:	89 e9                	mov    %ebp,%ecx
  800f36:	09 c2                	or     %eax,%edx
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	89 14 24             	mov    %edx,(%esp)
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	d3 e2                	shl    %cl,%edx
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	d3 e3                	shl    %cl,%ebx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	09 d8                	or     %ebx,%eax
  800f5d:	89 d3                	mov    %edx,%ebx
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	f7 34 24             	divl   (%esp)
  800f64:	89 d6                	mov    %edx,%esi
  800f66:	d3 e3                	shl    %cl,%ebx
  800f68:	f7 64 24 04          	mull   0x4(%esp)
  800f6c:	39 d6                	cmp    %edx,%esi
  800f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f72:	89 d1                	mov    %edx,%ecx
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	72 08                	jb     800f80 <__umoddi3+0x110>
  800f78:	75 11                	jne    800f8b <__umoddi3+0x11b>
  800f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f7e:	73 0b                	jae    800f8b <__umoddi3+0x11b>
  800f80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f84:	1b 14 24             	sbb    (%esp),%edx
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f8f:	29 da                	sub    %ebx,%edx
  800f91:	19 ce                	sbb    %ecx,%esi
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e0                	shl    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	d3 ea                	shr    %cl,%edx
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	d3 ee                	shr    %cl,%esi
  800fa1:	09 d0                	or     %edx,%eax
  800fa3:	89 f2                	mov    %esi,%edx
  800fa5:	83 c4 1c             	add    $0x1c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	29 f9                	sub    %edi,%ecx
  800fb2:	19 d6                	sbb    %edx,%esi
  800fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fbc:	e9 18 ff ff ff       	jmp    800ed9 <__umoddi3+0x69>
