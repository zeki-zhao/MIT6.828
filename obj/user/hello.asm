
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 e0 0f 80 00       	push   $0x800fe0
  80003e:	e8 f6 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 0f 80 00       	push   $0x800fee
  800054:	e8 e0 00 00 00       	call   800139 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
  800067:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800071:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	7e 08                	jle    800080 <libmain+0x22>
		binaryname = argv[0];
  800078:	8b 0a                	mov    (%edx),%ecx
  80007a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	52                   	push   %edx
  800084:	50                   	push   %eax
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 05 00 00 00       	call   800094 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 20 0a 00 00       	call   800ac1 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 ae 09 00 00       	call   800a84 <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 1a 01 00 00       	call   800236 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 53 09 00 00       	call   800a84 <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800163:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80016e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800171:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800174:	39 d3                	cmp    %edx,%ebx
  800176:	72 05                	jb     80017d <printnum+0x30>
  800178:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017b:	77 45                	ja     8001c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 18             	pushl  0x18(%ebp)
  800183:	8b 45 14             	mov    0x14(%ebp),%eax
  800186:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 9f 0b 00 00       	call   800d40 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 18                	jmp    8001cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb 03                	jmp    8001c5 <printnum+0x78>
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f e8                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 8c 0c 00 00       	call   800e70 <__umoddi3>
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	0f be 80 0f 10 80 00 	movsbl 0x80100f(%eax),%eax
  8001ee:	50                   	push   %eax
  8001ef:	ff d7                	call   *%edi
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800202:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800206:	8b 10                	mov    (%eax),%edx
  800208:	3b 50 04             	cmp    0x4(%eax),%edx
  80020b:	73 0a                	jae    800217 <sprintputch+0x1b>
		*b->buf++ = ch;
  80020d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800210:	89 08                	mov    %ecx,(%eax)
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	88 02                	mov    %al,(%edx)
}
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80021f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800222:	50                   	push   %eax
  800223:	ff 75 10             	pushl  0x10(%ebp)
  800226:	ff 75 0c             	pushl  0xc(%ebp)
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 05 00 00 00       	call   800236 <vprintfmt>
	va_end(ap);
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 2c             	sub    $0x2c,%esp
  80023f:	8b 75 08             	mov    0x8(%ebp),%esi
  800242:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800245:	8b 7d 10             	mov    0x10(%ebp),%edi
  800248:	eb 12                	jmp    80025c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80024a:	85 c0                	test   %eax,%eax
  80024c:	0f 84 42 04 00 00    	je     800694 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	53                   	push   %ebx
  800256:	50                   	push   %eax
  800257:	ff d6                	call   *%esi
  800259:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80025c:	83 c7 01             	add    $0x1,%edi
  80025f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800263:	83 f8 25             	cmp    $0x25,%eax
  800266:	75 e2                	jne    80024a <vprintfmt+0x14>
  800268:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80026c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800273:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80027a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800281:	b9 00 00 00 00       	mov    $0x0,%ecx
  800286:	eb 07                	jmp    80028f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800288:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80028b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80028f:	8d 47 01             	lea    0x1(%edi),%eax
  800292:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800295:	0f b6 07             	movzbl (%edi),%eax
  800298:	0f b6 d0             	movzbl %al,%edx
  80029b:	83 e8 23             	sub    $0x23,%eax
  80029e:	3c 55                	cmp    $0x55,%al
  8002a0:	0f 87 d3 03 00 00    	ja     800679 <vprintfmt+0x443>
  8002a6:	0f b6 c0             	movzbl %al,%eax
  8002a9:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8002b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b7:	eb d6                	jmp    80028f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002cb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ce:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d1:	83 f9 09             	cmp    $0x9,%ecx
  8002d4:	77 3f                	ja     800315 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002d9:	eb e9                	jmp    8002c4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002db:	8b 45 14             	mov    0x14(%ebp),%eax
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8d 40 04             	lea    0x4(%eax),%eax
  8002e9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002ef:	eb 2a                	jmp    80031b <vprintfmt+0xe5>
  8002f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fb:	0f 49 d0             	cmovns %eax,%edx
  8002fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800304:	eb 89                	jmp    80028f <vprintfmt+0x59>
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800309:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800310:	e9 7a ff ff ff       	jmp    80028f <vprintfmt+0x59>
  800315:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800318:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80031b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80031f:	0f 89 6a ff ff ff    	jns    80028f <vprintfmt+0x59>
				width = precision, precision = -1;
  800325:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800328:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	e9 58 ff ff ff       	jmp    80028f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800337:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80033d:	e9 4d ff ff ff       	jmp    80028f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	8d 78 04             	lea    0x4(%eax),%edi
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	53                   	push   %ebx
  80034c:	ff 30                	pushl  (%eax)
  80034e:	ff d6                	call   *%esi
			break;
  800350:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800353:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800359:	e9 fe fe ff ff       	jmp    80025c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 78 04             	lea    0x4(%eax),%edi
  800364:	8b 00                	mov    (%eax),%eax
  800366:	99                   	cltd   
  800367:	31 d0                	xor    %edx,%eax
  800369:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036b:	83 f8 09             	cmp    $0x9,%eax
  80036e:	7f 0b                	jg     80037b <vprintfmt+0x145>
  800370:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800377:	85 d2                	test   %edx,%edx
  800379:	75 1b                	jne    800396 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80037b:	50                   	push   %eax
  80037c:	68 27 10 80 00       	push   $0x801027
  800381:	53                   	push   %ebx
  800382:	56                   	push   %esi
  800383:	e8 91 fe ff ff       	call   800219 <printfmt>
  800388:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80038b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800391:	e9 c6 fe ff ff       	jmp    80025c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800396:	52                   	push   %edx
  800397:	68 30 10 80 00       	push   $0x801030
  80039c:	53                   	push   %ebx
  80039d:	56                   	push   %esi
  80039e:	e8 76 fe ff ff       	call   800219 <printfmt>
  8003a3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	e9 ab fe ff ff       	jmp    80025c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	83 c0 04             	add    $0x4,%eax
  8003b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003bf:	85 ff                	test   %edi,%edi
  8003c1:	b8 20 10 80 00       	mov    $0x801020,%eax
  8003c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	0f 8e 94 00 00 00    	jle    800467 <vprintfmt+0x231>
  8003d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003d7:	0f 84 98 00 00 00    	je     800475 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e3:	57                   	push   %edi
  8003e4:	e8 33 03 00 00       	call   80071c <strnlen>
  8003e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ec:	29 c1                	sub    %eax,%ecx
  8003ee:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800400:	eb 0f                	jmp    800411 <vprintfmt+0x1db>
					putch(padc, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	53                   	push   %ebx
  800406:	ff 75 e0             	pushl  -0x20(%ebp)
  800409:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80040b:	83 ef 01             	sub    $0x1,%edi
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	85 ff                	test   %edi,%edi
  800413:	7f ed                	jg     800402 <vprintfmt+0x1cc>
  800415:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800418:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80041b:	85 c9                	test   %ecx,%ecx
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	0f 49 c1             	cmovns %ecx,%eax
  800425:	29 c1                	sub    %eax,%ecx
  800427:	89 75 08             	mov    %esi,0x8(%ebp)
  80042a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800430:	89 cb                	mov    %ecx,%ebx
  800432:	eb 4d                	jmp    800481 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800434:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800438:	74 1b                	je     800455 <vprintfmt+0x21f>
  80043a:	0f be c0             	movsbl %al,%eax
  80043d:	83 e8 20             	sub    $0x20,%eax
  800440:	83 f8 5e             	cmp    $0x5e,%eax
  800443:	76 10                	jbe    800455 <vprintfmt+0x21f>
					putch('?', putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 0c             	pushl  0xc(%ebp)
  80044b:	6a 3f                	push   $0x3f
  80044d:	ff 55 08             	call   *0x8(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	eb 0d                	jmp    800462 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 0c             	pushl  0xc(%ebp)
  80045b:	52                   	push   %edx
  80045c:	ff 55 08             	call   *0x8(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	eb 1a                	jmp    800481 <vprintfmt+0x24b>
  800467:	89 75 08             	mov    %esi,0x8(%ebp)
  80046a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800470:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800473:	eb 0c                	jmp    800481 <vprintfmt+0x24b>
  800475:	89 75 08             	mov    %esi,0x8(%ebp)
  800478:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800481:	83 c7 01             	add    $0x1,%edi
  800484:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800488:	0f be d0             	movsbl %al,%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	74 23                	je     8004b2 <vprintfmt+0x27c>
  80048f:	85 f6                	test   %esi,%esi
  800491:	78 a1                	js     800434 <vprintfmt+0x1fe>
  800493:	83 ee 01             	sub    $0x1,%esi
  800496:	79 9c                	jns    800434 <vprintfmt+0x1fe>
  800498:	89 df                	mov    %ebx,%edi
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a0:	eb 18                	jmp    8004ba <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	6a 20                	push   $0x20
  8004a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004aa:	83 ef 01             	sub    $0x1,%edi
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb 08                	jmp    8004ba <vprintfmt+0x284>
  8004b2:	89 df                	mov    %ebx,%edi
  8004b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f e4                	jg     8004a2 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c7:	e9 90 fd ff ff       	jmp    80025c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004cc:	83 f9 01             	cmp    $0x1,%ecx
  8004cf:	7e 19                	jle    8004ea <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8b 50 04             	mov    0x4(%eax),%edx
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 40 08             	lea    0x8(%eax),%eax
  8004e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e8:	eb 38                	jmp    800522 <vprintfmt+0x2ec>
	else if (lflag)
  8004ea:	85 c9                	test   %ecx,%ecx
  8004ec:	74 1b                	je     800509 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	89 c1                	mov    %eax,%ecx
  8004f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 40 04             	lea    0x4(%eax),%eax
  800504:	89 45 14             	mov    %eax,0x14(%ebp)
  800507:	eb 19                	jmp    800522 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800511:	89 c1                	mov    %eax,%ecx
  800513:	c1 f9 1f             	sar    $0x1f,%ecx
  800516:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 04             	lea    0x4(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800528:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80052d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800531:	0f 89 0e 01 00 00    	jns    800645 <vprintfmt+0x40f>
				putch('-', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 2d                	push   $0x2d
  80053d:	ff d6                	call   *%esi
				num = -(long long) num;
  80053f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800542:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800545:	f7 da                	neg    %edx
  800547:	83 d1 00             	adc    $0x0,%ecx
  80054a:	f7 d9                	neg    %ecx
  80054c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800554:	e9 ec 00 00 00       	jmp    800645 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800559:	83 f9 01             	cmp    $0x1,%ecx
  80055c:	7e 18                	jle    800576 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8b 10                	mov    (%eax),%edx
  800563:	8b 48 04             	mov    0x4(%eax),%ecx
  800566:	8d 40 08             	lea    0x8(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80056c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800571:	e9 cf 00 00 00       	jmp    800645 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800576:	85 c9                	test   %ecx,%ecx
  800578:	74 1a                	je     800594 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 10                	mov    (%eax),%edx
  80057f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	e9 b1 00 00 00       	jmp    800645 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 10                	mov    (%eax),%edx
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a9:	e9 97 00 00 00       	jmp    800645 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 58                	push   $0x58
  8005b4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005b6:	83 c4 08             	add    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 58                	push   $0x58
  8005bc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005be:	83 c4 08             	add    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 58                	push   $0x58
  8005c4:	ff d6                	call   *%esi
			break;
  8005c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005cc:	e9 8b fc ff ff       	jmp    80025c <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 30                	push   $0x30
  8005d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d9:	83 c4 08             	add    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 78                	push   $0x78
  8005df:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005eb:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f9:	eb 4a                	jmp    800645 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 15                	jle    800615 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	8b 48 04             	mov    0x4(%eax),%ecx
  800608:	8d 40 08             	lea    0x8(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80060e:	b8 10 00 00 00       	mov    $0x10,%eax
  800613:	eb 30                	jmp    800645 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800615:	85 c9                	test   %ecx,%ecx
  800617:	74 17                	je     800630 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800629:	b8 10 00 00 00       	mov    $0x10,%eax
  80062e:	eb 15                	jmp    800645 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800640:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800645:	83 ec 0c             	sub    $0xc,%esp
  800648:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064c:	57                   	push   %edi
  80064d:	ff 75 e0             	pushl  -0x20(%ebp)
  800650:	50                   	push   %eax
  800651:	51                   	push   %ecx
  800652:	52                   	push   %edx
  800653:	89 da                	mov    %ebx,%edx
  800655:	89 f0                	mov    %esi,%eax
  800657:	e8 f1 fa ff ff       	call   80014d <printnum>
			break;
  80065c:	83 c4 20             	add    $0x20,%esp
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	e9 f5 fb ff ff       	jmp    80025c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	52                   	push   %edx
  80066c:	ff d6                	call   *%esi
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800674:	e9 e3 fb ff ff       	jmp    80025c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 25                	push   $0x25
  80067f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 03                	jmp    800689 <vprintfmt+0x453>
  800686:	83 ef 01             	sub    $0x1,%edi
  800689:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068d:	75 f7                	jne    800686 <vprintfmt+0x450>
  80068f:	e9 c8 fb ff ff       	jmp    80025c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800697:	5b                   	pop    %ebx
  800698:	5e                   	pop    %esi
  800699:	5f                   	pop    %edi
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
  8006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 26                	je     8006e3 <vsnprintf+0x47>
  8006bd:	85 d2                	test   %edx,%edx
  8006bf:	7e 22                	jle    8006e3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c1:	ff 75 14             	pushl  0x14(%ebp)
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ca:	50                   	push   %eax
  8006cb:	68 fc 01 80 00       	push   $0x8001fc
  8006d0:	e8 61 fb ff ff       	call   800236 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 05                	jmp    8006e8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f3:	50                   	push   %eax
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	ff 75 08             	pushl  0x8(%ebp)
  8006fd:	e8 9a ff ff ff       	call   80069c <vsnprintf>
	va_end(ap);

	return rc;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	eb 03                	jmp    800714 <strlen+0x10>
		n++;
  800711:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800714:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800718:	75 f7                	jne    800711 <strlen+0xd>
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	eb 03                	jmp    80072f <strnlen+0x13>
		n++;
  80072c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 c2                	cmp    %eax,%edx
  800731:	74 08                	je     80073b <strnlen+0x1f>
  800733:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800737:	75 f3                	jne    80072c <strnlen+0x10>
  800739:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800747:	89 c2                	mov    %eax,%edx
  800749:	83 c2 01             	add    $0x1,%edx
  80074c:	83 c1 01             	add    $0x1,%ecx
  80074f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800753:	88 5a ff             	mov    %bl,-0x1(%edx)
  800756:	84 db                	test   %bl,%bl
  800758:	75 ef                	jne    800749 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075a:	5b                   	pop    %ebx
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800764:	53                   	push   %ebx
  800765:	e8 9a ff ff ff       	call   800704 <strlen>
  80076a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	01 d8                	add    %ebx,%eax
  800772:	50                   	push   %eax
  800773:	e8 c5 ff ff ff       	call   80073d <strcpy>
	return dst;
}
  800778:	89 d8                	mov    %ebx,%eax
  80077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	89 f2                	mov    %esi,%edx
  800791:	eb 0f                	jmp    8007a2 <strncpy+0x23>
		*dst++ = *src;
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	0f b6 01             	movzbl (%ecx),%eax
  800799:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079c:	80 39 01             	cmpb   $0x1,(%ecx)
  80079f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a2:	39 da                	cmp    %ebx,%edx
  8007a4:	75 ed                	jne    800793 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 21                	je     8007e1 <strlcpy+0x35>
  8007c0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 09                	jmp    8007d1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d1:	39 c2                	cmp    %eax,%edx
  8007d3:	74 09                	je     8007de <strlcpy+0x32>
  8007d5:	0f b6 19             	movzbl (%ecx),%ebx
  8007d8:	84 db                	test   %bl,%bl
  8007da:	75 ec                	jne    8007c8 <strlcpy+0x1c>
  8007dc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e1:	29 f0                	sub    %esi,%eax
}
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strcmp+0x11>
		p++, q++;
  8007f2:	83 c1 01             	add    $0x1,%ecx
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 04                	je     800803 <strcmp+0x1c>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	74 ef                	je     8007f2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 c0             	movzbl %al,%eax
  800806:	0f b6 12             	movzbl (%edx),%edx
  800809:	29 d0                	sub    %edx,%eax
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
  800817:	89 c3                	mov    %eax,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081c:	eb 06                	jmp    800824 <strncmp+0x17>
		n--, p++, q++;
  80081e:	83 c0 01             	add    $0x1,%eax
  800821:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800824:	39 d8                	cmp    %ebx,%eax
  800826:	74 15                	je     80083d <strncmp+0x30>
  800828:	0f b6 08             	movzbl (%eax),%ecx
  80082b:	84 c9                	test   %cl,%cl
  80082d:	74 04                	je     800833 <strncmp+0x26>
  80082f:	3a 0a                	cmp    (%edx),%cl
  800831:	74 eb                	je     80081e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 00             	movzbl (%eax),%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
  80083b:	eb 05                	jmp    800842 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 07                	jmp    800858 <strchr+0x13>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 0f                	je     800864 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 10             	movzbl (%eax),%edx
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	eb 03                	jmp    800875 <strfind+0xf>
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 04                	je     800880 <strfind+0x1a>
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f2                	jne    800872 <strfind+0xc>
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 36                	je     8008c8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800892:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800898:	75 28                	jne    8008c2 <memset+0x40>
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 23                	jne    8008c2 <memset+0x40>
		c &= 0xFF;
  80089f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a3:	89 d3                	mov    %edx,%ebx
  8008a5:	c1 e3 08             	shl    $0x8,%ebx
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	c1 e6 18             	shl    $0x18,%esi
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	c1 e0 10             	shl    $0x10,%eax
  8008b2:	09 f0                	or     %esi,%eax
  8008b4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b6:	89 d8                	mov    %ebx,%eax
  8008b8:	09 d0                	or     %edx,%eax
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
  8008bd:	fc                   	cld    
  8008be:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c0:	eb 06                	jmp    8008c8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	fc                   	cld    
  8008c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dd:	39 c6                	cmp    %eax,%esi
  8008df:	73 35                	jae    800916 <memmove+0x47>
  8008e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	73 2e                	jae    800916 <memmove+0x47>
		s += n;
		d += n;
  8008e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	09 fe                	or     %edi,%esi
  8008ef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f5:	75 13                	jne    80090a <memmove+0x3b>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 0e                	jne    80090a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fc:	83 ef 04             	sub    $0x4,%edi
  8008ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fd                   	std    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 09                	jmp    800913 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090a:	83 ef 01             	sub    $0x1,%edi
  80090d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800910:	fd                   	std    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800913:	fc                   	cld    
  800914:	eb 1d                	jmp    800933 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	89 f2                	mov    %esi,%edx
  800918:	09 c2                	or     %eax,%edx
  80091a:	f6 c2 03             	test   $0x3,%dl
  80091d:	75 0f                	jne    80092e <memmove+0x5f>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 0a                	jne    80092e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb 05                	jmp    800933 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093a:	ff 75 10             	pushl  0x10(%ebp)
  80093d:	ff 75 0c             	pushl  0xc(%ebp)
  800940:	ff 75 08             	pushl  0x8(%ebp)
  800943:	e8 87 ff ff ff       	call   8008cf <memmove>
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
  800955:	89 c6                	mov    %eax,%esi
  800957:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	eb 1a                	jmp    800976 <memcmp+0x2c>
		if (*s1 != *s2)
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	0f b6 1a             	movzbl (%edx),%ebx
  800962:	38 d9                	cmp    %bl,%cl
  800964:	74 0a                	je     800970 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800966:	0f b6 c1             	movzbl %cl,%eax
  800969:	0f b6 db             	movzbl %bl,%ebx
  80096c:	29 d8                	sub    %ebx,%eax
  80096e:	eb 0f                	jmp    80097f <memcmp+0x35>
		s1++, s2++;
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	39 f0                	cmp    %esi,%eax
  800978:	75 e2                	jne    80095c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098a:	89 c1                	mov    %eax,%ecx
  80098c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800993:	eb 0a                	jmp    80099f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	39 da                	cmp    %ebx,%edx
  80099a:	74 07                	je     8009a3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	39 c8                	cmp    %ecx,%eax
  8009a1:	72 f2                	jb     800995 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	eb 03                	jmp    8009b7 <strtol+0x11>
		s++;
  8009b4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	3c 20                	cmp    $0x20,%al
  8009bc:	74 f6                	je     8009b4 <strtol+0xe>
  8009be:	3c 09                	cmp    $0x9,%al
  8009c0:	74 f2                	je     8009b4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c2:	3c 2b                	cmp    $0x2b,%al
  8009c4:	75 0a                	jne    8009d0 <strtol+0x2a>
		s++;
  8009c6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ce:	eb 11                	jmp    8009e1 <strtol+0x3b>
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d5:	3c 2d                	cmp    $0x2d,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x3b>
		s++, neg = 1;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e7:	75 15                	jne    8009fe <strtol+0x58>
  8009e9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ec:	75 10                	jne    8009fe <strtol+0x58>
  8009ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f2:	75 7c                	jne    800a70 <strtol+0xca>
		s += 2, base = 16;
  8009f4:	83 c1 02             	add    $0x2,%ecx
  8009f7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fc:	eb 16                	jmp    800a14 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fe:	85 db                	test   %ebx,%ebx
  800a00:	75 12                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 08                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	0f b6 11             	movzbl (%ecx),%edx
  800a1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 09             	cmp    $0x9,%bl
  800a27:	77 08                	ja     800a31 <strtol+0x8b>
			dig = *s - '0';
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 30             	sub    $0x30,%edx
  800a2f:	eb 22                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 08                	ja     800a43 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3b:	0f be d2             	movsbl %dl,%edx
  800a3e:	83 ea 57             	sub    $0x57,%edx
  800a41:	eb 10                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 19             	cmp    $0x19,%bl
  800a4b:	77 16                	ja     800a63 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 0b                	jge    800a63 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a61:	eb b9                	jmp    800a1c <strtol+0x76>

	if (endptr)
  800a63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a67:	74 0d                	je     800a76 <strtol+0xd0>
		*endptr = (char *) s;
  800a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6c:	89 0e                	mov    %ecx,(%esi)
  800a6e:	eb 06                	jmp    800a76 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	74 98                	je     800a0c <strtol+0x66>
  800a74:	eb 9e                	jmp    800a14 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a76:	89 c2                	mov    %eax,%edx
  800a78:	f7 da                	neg    %edx
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	0f 45 c2             	cmovne %edx,%eax
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	89 c6                	mov    %eax,%esi
  800a9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aad:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab2:	89 d1                	mov    %edx,%ecx
  800ab4:	89 d3                	mov    %edx,%ebx
  800ab6:	89 d7                	mov    %edx,%edi
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 cb                	mov    %ecx,%ebx
  800ad9:	89 cf                	mov    %ecx,%edi
  800adb:	89 ce                	mov    %ecx,%esi
  800add:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	7e 17                	jle    800afa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae3:	83 ec 0c             	sub    $0xc,%esp
  800ae6:	50                   	push   %eax
  800ae7:	6a 03                	push   $0x3
  800ae9:	68 68 12 80 00       	push   $0x801268
  800aee:	6a 23                	push   $0x23
  800af0:	68 85 12 80 00       	push   $0x801285
  800af5:	e8 f5 01 00 00       	call   800cef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_yield>:

void
sys_yield(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	be 00 00 00 00       	mov    $0x0,%esi
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5c:	89 f7                	mov    %esi,%edi
  800b5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 04                	push   $0x4
  800b6a:	68 68 12 80 00       	push   $0x801268
  800b6f:	6a 23                	push   $0x23
  800b71:	68 85 12 80 00       	push   $0x801285
  800b76:	e8 74 01 00 00       	call   800cef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9d:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 05                	push   $0x5
  800bac:	68 68 12 80 00       	push   $0x801268
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 85 12 80 00       	push   $0x801285
  800bb8:	e8 32 01 00 00       	call   800cef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	89 df                	mov    %ebx,%edi
  800be0:	89 de                	mov    %ebx,%esi
  800be2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 06                	push   $0x6
  800bee:	68 68 12 80 00       	push   $0x801268
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 85 12 80 00       	push   $0x801285
  800bfa:	e8 f0 00 00 00       	call   800cef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 08                	push   $0x8
  800c30:	68 68 12 80 00       	push   $0x801268
  800c35:	6a 23                	push   $0x23
  800c37:	68 85 12 80 00       	push   $0x801285
  800c3c:	e8 ae 00 00 00       	call   800cef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 09                	push   $0x9
  800c72:	68 68 12 80 00       	push   $0x801268
  800c77:	6a 23                	push   $0x23
  800c79:	68 85 12 80 00       	push   $0x801285
  800c7e:	e8 6c 00 00 00       	call   800cef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	be 00 00 00 00       	mov    $0x0,%esi
  800c96:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 cb                	mov    %ecx,%ebx
  800cc6:	89 cf                	mov    %ecx,%edi
  800cc8:	89 ce                	mov    %ecx,%esi
  800cca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 0c                	push   $0xc
  800cd6:	68 68 12 80 00       	push   $0x801268
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 85 12 80 00       	push   $0x801285
  800ce2:	e8 08 00 00 00       	call   800cef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cf4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cf7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cfd:	e8 00 fe ff ff       	call   800b02 <sys_getenvid>
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	ff 75 0c             	pushl  0xc(%ebp)
  800d08:	ff 75 08             	pushl  0x8(%ebp)
  800d0b:	56                   	push   %esi
  800d0c:	50                   	push   %eax
  800d0d:	68 94 12 80 00       	push   $0x801294
  800d12:	e8 22 f4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d17:	83 c4 18             	add    $0x18,%esp
  800d1a:	53                   	push   %ebx
  800d1b:	ff 75 10             	pushl  0x10(%ebp)
  800d1e:	e8 c5 f3 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800d23:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d2a:	e8 0a f4 ff ff       	call   800139 <cprintf>
  800d2f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d32:	cc                   	int3   
  800d33:	eb fd                	jmp    800d32 <_panic+0x43>
  800d35:	66 90                	xchg   %ax,%ax
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
