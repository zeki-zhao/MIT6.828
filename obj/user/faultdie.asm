
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 10 80 00       	push   $0x801020
  80004a:	e8 0c 01 00 00       	call   80015b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 d0 0a 00 00       	call   800b24 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 87 0a 00 00       	call   800ae3 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 a0 0c 00 00       	call   800d11 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	8b 45 08             	mov    0x8(%ebp),%eax
  800089:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800093:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800096:	85 c0                	test   %eax,%eax
  800098:	7e 08                	jle    8000a2 <libmain+0x22>
		binaryname = argv[0];
  80009a:	8b 0a                	mov    (%edx),%ecx
  80009c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	52                   	push   %edx
  8000a6:	50                   	push   %eax
  8000a7:	e8 b5 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 05 00 00 00       	call   8000b6 <exit>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 20 0a 00 00       	call   800ae3 <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	75 1a                	jne    800101 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	68 ff 00 00 00       	push   $0xff
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 ae 09 00 00       	call   800aa6 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fe:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800101:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	ff 75 0c             	pushl  0xc(%ebp)
  80012a:	ff 75 08             	pushl  0x8(%ebp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 c8 00 80 00       	push   $0x8000c8
  800139:	e8 1a 01 00 00       	call   800258 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013e:	83 c4 08             	add    $0x8,%esp
  800141:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 53 09 00 00       	call   800aa6 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	50                   	push   %eax
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	e8 9d ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 1c             	sub    $0x1c,%esp
  800178:	89 c7                	mov    %eax,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800182:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800185:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800190:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800193:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800196:	39 d3                	cmp    %edx,%ebx
  800198:	72 05                	jb     80019f <printnum+0x30>
  80019a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019d:	77 45                	ja     8001e4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 18             	pushl  0x18(%ebp)
  8001a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ab:	53                   	push   %ebx
  8001ac:	ff 75 10             	pushl  0x10(%ebp)
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001be:	e8 cd 0b 00 00       	call   800d90 <__udivdi3>
  8001c3:	83 c4 18             	add    $0x18,%esp
  8001c6:	52                   	push   %edx
  8001c7:	50                   	push   %eax
  8001c8:	89 f2                	mov    %esi,%edx
  8001ca:	89 f8                	mov    %edi,%eax
  8001cc:	e8 9e ff ff ff       	call   80016f <printnum>
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	eb 18                	jmp    8001ee <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	56                   	push   %esi
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	ff d7                	call   *%edi
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	eb 03                	jmp    8001e7 <printnum+0x78>
  8001e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	83 eb 01             	sub    $0x1,%ebx
  8001ea:	85 db                	test   %ebx,%ebx
  8001ec:	7f e8                	jg     8001d6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800201:	e8 ba 0c 00 00       	call   800ec0 <__umoddi3>
  800206:	83 c4 14             	add    $0x14,%esp
  800209:	0f be 80 46 10 80 00 	movsbl 0x801046(%eax),%eax
  800210:	50                   	push   %eax
  800211:	ff d7                	call   *%edi
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800224:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	3b 50 04             	cmp    0x4(%eax),%edx
  80022d:	73 0a                	jae    800239 <sprintputch+0x1b>
		*b->buf++ = ch;
  80022f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800232:	89 08                	mov    %ecx,(%eax)
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	88 02                	mov    %al,(%edx)
}
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800241:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800244:	50                   	push   %eax
  800245:	ff 75 10             	pushl  0x10(%ebp)
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	ff 75 08             	pushl  0x8(%ebp)
  80024e:	e8 05 00 00 00       	call   800258 <vprintfmt>
	va_end(ap);
}
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 2c             	sub    $0x2c,%esp
  800261:	8b 75 08             	mov    0x8(%ebp),%esi
  800264:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800267:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026a:	eb 12                	jmp    80027e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80026c:	85 c0                	test   %eax,%eax
  80026e:	0f 84 42 04 00 00    	je     8006b6 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	53                   	push   %ebx
  800278:	50                   	push   %eax
  800279:	ff d6                	call   *%esi
  80027b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80027e:	83 c7 01             	add    $0x1,%edi
  800281:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800285:	83 f8 25             	cmp    $0x25,%eax
  800288:	75 e2                	jne    80026c <vprintfmt+0x14>
  80028a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80028e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800295:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80029c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a8:	eb 07                	jmp    8002b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ad:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b1:	8d 47 01             	lea    0x1(%edi),%eax
  8002b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b7:	0f b6 07             	movzbl (%edi),%eax
  8002ba:	0f b6 d0             	movzbl %al,%edx
  8002bd:	83 e8 23             	sub    $0x23,%eax
  8002c0:	3c 55                	cmp    $0x55,%al
  8002c2:	0f 87 d3 03 00 00    	ja     80069b <vprintfmt+0x443>
  8002c8:	0f b6 c0             	movzbl %al,%eax
  8002cb:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002d5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d9:	eb d6                	jmp    8002b1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002de:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ed:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f3:	83 f9 09             	cmp    $0x9,%ecx
  8002f6:	77 3f                	ja     800337 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002fb:	eb e9                	jmp    8002e6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8b 00                	mov    (%eax),%eax
  800302:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 40 04             	lea    0x4(%eax),%eax
  80030b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800311:	eb 2a                	jmp    80033d <vprintfmt+0xe5>
  800313:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800316:	85 c0                	test   %eax,%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	0f 49 d0             	cmovns %eax,%edx
  800320:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800326:	eb 89                	jmp    8002b1 <vprintfmt+0x59>
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80032b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800332:	e9 7a ff ff ff       	jmp    8002b1 <vprintfmt+0x59>
  800337:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80033d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800341:	0f 89 6a ff ff ff    	jns    8002b1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800347:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800354:	e9 58 ff ff ff       	jmp    8002b1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800359:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80035f:	e9 4d ff ff ff       	jmp    8002b1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 78 04             	lea    0x4(%eax),%edi
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	53                   	push   %ebx
  80036e:	ff 30                	pushl  (%eax)
  800370:	ff d6                	call   *%esi
			break;
  800372:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800375:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80037b:	e9 fe fe ff ff       	jmp    80027e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 78 04             	lea    0x4(%eax),%edi
  800386:	8b 00                	mov    (%eax),%eax
  800388:	99                   	cltd   
  800389:	31 d0                	xor    %edx,%eax
  80038b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038d:	83 f8 09             	cmp    $0x9,%eax
  800390:	7f 0b                	jg     80039d <vprintfmt+0x145>
  800392:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800399:	85 d2                	test   %edx,%edx
  80039b:	75 1b                	jne    8003b8 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80039d:	50                   	push   %eax
  80039e:	68 5e 10 80 00       	push   $0x80105e
  8003a3:	53                   	push   %ebx
  8003a4:	56                   	push   %esi
  8003a5:	e8 91 fe ff ff       	call   80023b <printfmt>
  8003aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ad:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003b3:	e9 c6 fe ff ff       	jmp    80027e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003b8:	52                   	push   %edx
  8003b9:	68 67 10 80 00       	push   $0x801067
  8003be:	53                   	push   %ebx
  8003bf:	56                   	push   %esi
  8003c0:	e8 76 fe ff ff       	call   80023b <printfmt>
  8003c5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	e9 ab fe ff ff       	jmp    80027e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	83 c0 04             	add    $0x4,%eax
  8003d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003e1:	85 ff                	test   %edi,%edi
  8003e3:	b8 57 10 80 00       	mov    $0x801057,%eax
  8003e8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ef:	0f 8e 94 00 00 00    	jle    800489 <vprintfmt+0x231>
  8003f5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003f9:	0f 84 98 00 00 00    	je     800497 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	ff 75 d0             	pushl  -0x30(%ebp)
  800405:	57                   	push   %edi
  800406:	e8 33 03 00 00       	call   80073e <strnlen>
  80040b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040e:	29 c1                	sub    %eax,%ecx
  800410:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800413:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800416:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80041a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800420:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800422:	eb 0f                	jmp    800433 <vprintfmt+0x1db>
					putch(padc, putdat);
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	53                   	push   %ebx
  800428:	ff 75 e0             	pushl  -0x20(%ebp)
  80042b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042d:	83 ef 01             	sub    $0x1,%edi
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	85 ff                	test   %edi,%edi
  800435:	7f ed                	jg     800424 <vprintfmt+0x1cc>
  800437:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80043a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80043d:	85 c9                	test   %ecx,%ecx
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	0f 49 c1             	cmovns %ecx,%eax
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 75 08             	mov    %esi,0x8(%ebp)
  80044c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800452:	89 cb                	mov    %ecx,%ebx
  800454:	eb 4d                	jmp    8004a3 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800456:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045a:	74 1b                	je     800477 <vprintfmt+0x21f>
  80045c:	0f be c0             	movsbl %al,%eax
  80045f:	83 e8 20             	sub    $0x20,%eax
  800462:	83 f8 5e             	cmp    $0x5e,%eax
  800465:	76 10                	jbe    800477 <vprintfmt+0x21f>
					putch('?', putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	ff 75 0c             	pushl  0xc(%ebp)
  80046d:	6a 3f                	push   $0x3f
  80046f:	ff 55 08             	call   *0x8(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 0d                	jmp    800484 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	52                   	push   %edx
  80047e:	ff 55 08             	call   *0x8(%ebp)
  800481:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800484:	83 eb 01             	sub    $0x1,%ebx
  800487:	eb 1a                	jmp    8004a3 <vprintfmt+0x24b>
  800489:	89 75 08             	mov    %esi,0x8(%ebp)
  80048c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800492:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800495:	eb 0c                	jmp    8004a3 <vprintfmt+0x24b>
  800497:	89 75 08             	mov    %esi,0x8(%ebp)
  80049a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a3:	83 c7 01             	add    $0x1,%edi
  8004a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004aa:	0f be d0             	movsbl %al,%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	74 23                	je     8004d4 <vprintfmt+0x27c>
  8004b1:	85 f6                	test   %esi,%esi
  8004b3:	78 a1                	js     800456 <vprintfmt+0x1fe>
  8004b5:	83 ee 01             	sub    $0x1,%esi
  8004b8:	79 9c                	jns    800456 <vprintfmt+0x1fe>
  8004ba:	89 df                	mov    %ebx,%edi
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	eb 18                	jmp    8004dc <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	6a 20                	push   $0x20
  8004ca:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	eb 08                	jmp    8004dc <vprintfmt+0x284>
  8004d4:	89 df                	mov    %ebx,%edi
  8004d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7f e4                	jg     8004c4 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e9:	e9 90 fd ff ff       	jmp    80027e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ee:	83 f9 01             	cmp    $0x1,%ecx
  8004f1:	7e 19                	jle    80050c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8b 50 04             	mov    0x4(%eax),%edx
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 08             	lea    0x8(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	eb 38                	jmp    800544 <vprintfmt+0x2ec>
	else if (lflag)
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	74 1b                	je     80052b <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	89 c1                	mov    %eax,%ecx
  80051a:	c1 f9 1f             	sar    $0x1f,%ecx
  80051d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	eb 19                	jmp    800544 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80054f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800553:	0f 89 0e 01 00 00    	jns    800667 <vprintfmt+0x40f>
				putch('-', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 2d                	push   $0x2d
  80055f:	ff d6                	call   *%esi
				num = -(long long) num;
  800561:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800564:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800567:	f7 da                	neg    %edx
  800569:	83 d1 00             	adc    $0x0,%ecx
  80056c:	f7 d9                	neg    %ecx
  80056e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
  800576:	e9 ec 00 00 00       	jmp    800667 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7e 18                	jle    800598 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
  800585:	8b 48 04             	mov    0x4(%eax),%ecx
  800588:	8d 40 08             	lea    0x8(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 cf 00 00 00       	jmp    800667 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 1a                	je     8005b6 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 b1 00 00 00       	jmp    800667 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
  8005cb:	e9 97 00 00 00       	jmp    800667 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 58                	push   $0x58
  8005d6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d8:	83 c4 08             	add    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 58                	push   $0x58
  8005de:	ff d6                	call   *%esi
			putch('X', putdat);
  8005e0:	83 c4 08             	add    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	6a 58                	push   $0x58
  8005e6:	ff d6                	call   *%esi
			break;
  8005e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005ee:	e9 8b fc ff ff       	jmp    80027e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 30                	push   $0x30
  8005f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 78                	push   $0x78
  800601:	ff d6                	call   *%esi
			num = (unsigned long long)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800616:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80061b:	eb 4a                	jmp    800667 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061d:	83 f9 01             	cmp    $0x1,%ecx
  800620:	7e 15                	jle    800637 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	8b 48 04             	mov    0x4(%eax),%ecx
  80062a:	8d 40 08             	lea    0x8(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800630:	b8 10 00 00 00       	mov    $0x10,%eax
  800635:	eb 30                	jmp    800667 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 17                	je     800652 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
  800650:	eb 15                	jmp    800667 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800667:	83 ec 0c             	sub    $0xc,%esp
  80066a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066e:	57                   	push   %edi
  80066f:	ff 75 e0             	pushl  -0x20(%ebp)
  800672:	50                   	push   %eax
  800673:	51                   	push   %ecx
  800674:	52                   	push   %edx
  800675:	89 da                	mov    %ebx,%edx
  800677:	89 f0                	mov    %esi,%eax
  800679:	e8 f1 fa ff ff       	call   80016f <printnum>
			break;
  80067e:	83 c4 20             	add    $0x20,%esp
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800684:	e9 f5 fb ff ff       	jmp    80027e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	52                   	push   %edx
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800696:	e9 e3 fb ff ff       	jmp    80027e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 03                	jmp    8006ab <vprintfmt+0x453>
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006af:	75 f7                	jne    8006a8 <vprintfmt+0x450>
  8006b1:	e9 c8 fb ff ff       	jmp    80027e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 18             	sub    $0x18,%esp
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 26                	je     800705 <vsnprintf+0x47>
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	7e 22                	jle    800705 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	ff 75 14             	pushl  0x14(%ebp)
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ec:	50                   	push   %eax
  8006ed:	68 1e 02 80 00       	push   $0x80021e
  8006f2:	e8 61 fb ff ff       	call   800258 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb 05                	jmp    80070a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800715:	50                   	push   %eax
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	ff 75 08             	pushl  0x8(%ebp)
  80071f:	e8 9a ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
  800731:	eb 03                	jmp    800736 <strlen+0x10>
		n++;
  800733:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f7                	jne    800733 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	ba 00 00 00 00       	mov    $0x0,%edx
  80074c:	eb 03                	jmp    800751 <strnlen+0x13>
		n++;
  80074e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800751:	39 c2                	cmp    %eax,%edx
  800753:	74 08                	je     80075d <strnlen+0x1f>
  800755:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800759:	75 f3                	jne    80074e <strnlen+0x10>
  80075b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800769:	89 c2                	mov    %eax,%edx
  80076b:	83 c2 01             	add    $0x1,%edx
  80076e:	83 c1 01             	add    $0x1,%ecx
  800771:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800775:	88 5a ff             	mov    %bl,-0x1(%edx)
  800778:	84 db                	test   %bl,%bl
  80077a:	75 ef                	jne    80076b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800786:	53                   	push   %ebx
  800787:	e8 9a ff ff ff       	call   800726 <strlen>
  80078c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	01 d8                	add    %ebx,%eax
  800794:	50                   	push   %eax
  800795:	e8 c5 ff ff ff       	call   80075f <strcpy>
	return dst;
}
  80079a:	89 d8                	mov    %ebx,%eax
  80079c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ac:	89 f3                	mov    %esi,%ebx
  8007ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b1:	89 f2                	mov    %esi,%edx
  8007b3:	eb 0f                	jmp    8007c4 <strncpy+0x23>
		*dst++ = *src;
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	0f b6 01             	movzbl (%ecx),%eax
  8007bb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007be:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	39 da                	cmp    %ebx,%edx
  8007c6:	75 ed                	jne    8007b5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c8:	89 f0                	mov    %esi,%eax
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007dc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007de:	85 d2                	test   %edx,%edx
  8007e0:	74 21                	je     800803 <strlcpy+0x35>
  8007e2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 09                	jmp    8007f3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	83 c1 01             	add    $0x1,%ecx
  8007f0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f3:	39 c2                	cmp    %eax,%edx
  8007f5:	74 09                	je     800800 <strlcpy+0x32>
  8007f7:	0f b6 19             	movzbl (%ecx),%ebx
  8007fa:	84 db                	test   %bl,%bl
  8007fc:	75 ec                	jne    8007ea <strlcpy+0x1c>
  8007fe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800800:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800803:	29 f0                	sub    %esi,%eax
}
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800812:	eb 06                	jmp    80081a <strcmp+0x11>
		p++, q++;
  800814:	83 c1 01             	add    $0x1,%ecx
  800817:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	84 c0                	test   %al,%al
  80081f:	74 04                	je     800825 <strcmp+0x1c>
  800821:	3a 02                	cmp    (%edx),%al
  800823:	74 ef                	je     800814 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 c0             	movzbl %al,%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 c3                	mov    %eax,%ebx
  80083b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083e:	eb 06                	jmp    800846 <strncmp+0x17>
		n--, p++, q++;
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800846:	39 d8                	cmp    %ebx,%eax
  800848:	74 15                	je     80085f <strncmp+0x30>
  80084a:	0f b6 08             	movzbl (%eax),%ecx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	74 04                	je     800855 <strncmp+0x26>
  800851:	3a 0a                	cmp    (%edx),%cl
  800853:	74 eb                	je     800840 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 00             	movzbl (%eax),%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
  80085d:	eb 05                	jmp    800864 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800871:	eb 07                	jmp    80087a <strchr+0x13>
		if (*s == c)
  800873:	38 ca                	cmp    %cl,%dl
  800875:	74 0f                	je     800886 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	0f b6 10             	movzbl (%eax),%edx
  80087d:	84 d2                	test   %dl,%dl
  80087f:	75 f2                	jne    800873 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 03                	jmp    800897 <strfind+0xf>
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	74 04                	je     8008a2 <strfind+0x1a>
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b0:	85 c9                	test   %ecx,%ecx
  8008b2:	74 36                	je     8008ea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ba:	75 28                	jne    8008e4 <memset+0x40>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 23                	jne    8008e4 <memset+0x40>
		c &= 0xFF;
  8008c1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c5:	89 d3                	mov    %edx,%ebx
  8008c7:	c1 e3 08             	shl    $0x8,%ebx
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	c1 e6 18             	shl    $0x18,%esi
  8008cf:	89 d0                	mov    %edx,%eax
  8008d1:	c1 e0 10             	shl    $0x10,%eax
  8008d4:	09 f0                	or     %esi,%eax
  8008d6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d8:	89 d8                	mov    %ebx,%eax
  8008da:	09 d0                	or     %edx,%eax
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
  8008df:	fc                   	cld    
  8008e0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e2:	eb 06                	jmp    8008ea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e7:	fc                   	cld    
  8008e8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ea:	89 f8                	mov    %edi,%eax
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ff:	39 c6                	cmp    %eax,%esi
  800901:	73 35                	jae    800938 <memmove+0x47>
  800903:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800906:	39 d0                	cmp    %edx,%eax
  800908:	73 2e                	jae    800938 <memmove+0x47>
		s += n;
		d += n;
  80090a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	09 fe                	or     %edi,%esi
  800911:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800917:	75 13                	jne    80092c <memmove+0x3b>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0e                	jne    80092c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091e:	83 ef 04             	sub    $0x4,%edi
  800921:	8d 72 fc             	lea    -0x4(%edx),%esi
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	fd                   	std    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 09                	jmp    800935 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092c:	83 ef 01             	sub    $0x1,%edi
  80092f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800932:	fd                   	std    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800935:	fc                   	cld    
  800936:	eb 1d                	jmp    800955 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800938:	89 f2                	mov    %esi,%edx
  80093a:	09 c2                	or     %eax,%edx
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 0f                	jne    800950 <memmove+0x5f>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0a                	jne    800950 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800946:	c1 e9 02             	shr    $0x2,%ecx
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 05                	jmp    800955 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 87 ff ff ff       	call   8008f1 <memmove>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	89 c6                	mov    %eax,%esi
  800979:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	eb 1a                	jmp    800998 <memcmp+0x2c>
		if (*s1 != *s2)
  80097e:	0f b6 08             	movzbl (%eax),%ecx
  800981:	0f b6 1a             	movzbl (%edx),%ebx
  800984:	38 d9                	cmp    %bl,%cl
  800986:	74 0a                	je     800992 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800988:	0f b6 c1             	movzbl %cl,%eax
  80098b:	0f b6 db             	movzbl %bl,%ebx
  80098e:	29 d8                	sub    %ebx,%eax
  800990:	eb 0f                	jmp    8009a1 <memcmp+0x35>
		s1++, s2++;
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	39 f0                	cmp    %esi,%eax
  80099a:	75 e2                	jne    80097e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ac:	89 c1                	mov    %eax,%ecx
  8009ae:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	eb 0a                	jmp    8009c1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b7:	0f b6 10             	movzbl (%eax),%edx
  8009ba:	39 da                	cmp    %ebx,%edx
  8009bc:	74 07                	je     8009c5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	39 c8                	cmp    %ecx,%eax
  8009c3:	72 f2                	jb     8009b7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d4:	eb 03                	jmp    8009d9 <strtol+0x11>
		s++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d9:	0f b6 01             	movzbl (%ecx),%eax
  8009dc:	3c 20                	cmp    $0x20,%al
  8009de:	74 f6                	je     8009d6 <strtol+0xe>
  8009e0:	3c 09                	cmp    $0x9,%al
  8009e2:	74 f2                	je     8009d6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e4:	3c 2b                	cmp    $0x2b,%al
  8009e6:	75 0a                	jne    8009f2 <strtol+0x2a>
		s++;
  8009e8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f0:	eb 11                	jmp    800a03 <strtol+0x3b>
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f7:	3c 2d                	cmp    $0x2d,%al
  8009f9:	75 08                	jne    800a03 <strtol+0x3b>
		s++, neg = 1;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a09:	75 15                	jne    800a20 <strtol+0x58>
  800a0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0e:	75 10                	jne    800a20 <strtol+0x58>
  800a10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a14:	75 7c                	jne    800a92 <strtol+0xca>
		s += 2, base = 16;
  800a16:	83 c1 02             	add    $0x2,%ecx
  800a19:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1e:	eb 16                	jmp    800a36 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a20:	85 db                	test   %ebx,%ebx
  800a22:	75 12                	jne    800a36 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 08                	jne    800a36 <strtol+0x6e>
		s++, base = 8;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3e:	0f b6 11             	movzbl (%ecx),%edx
  800a41:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	80 fb 09             	cmp    $0x9,%bl
  800a49:	77 08                	ja     800a53 <strtol+0x8b>
			dig = *s - '0';
  800a4b:	0f be d2             	movsbl %dl,%edx
  800a4e:	83 ea 30             	sub    $0x30,%edx
  800a51:	eb 22                	jmp    800a75 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a56:	89 f3                	mov    %esi,%ebx
  800a58:	80 fb 19             	cmp    $0x19,%bl
  800a5b:	77 08                	ja     800a65 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5d:	0f be d2             	movsbl %dl,%edx
  800a60:	83 ea 57             	sub    $0x57,%edx
  800a63:	eb 10                	jmp    800a75 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 19             	cmp    $0x19,%bl
  800a6d:	77 16                	ja     800a85 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6f:	0f be d2             	movsbl %dl,%edx
  800a72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a75:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a78:	7d 0b                	jge    800a85 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a83:	eb b9                	jmp    800a3e <strtol+0x76>

	if (endptr)
  800a85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a89:	74 0d                	je     800a98 <strtol+0xd0>
		*endptr = (char *) s;
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	89 0e                	mov    %ecx,(%esi)
  800a90:	eb 06                	jmp    800a98 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	74 98                	je     800a2e <strtol+0x66>
  800a96:	eb 9e                	jmp    800a36 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a98:	89 c2                	mov    %eax,%edx
  800a9a:	f7 da                	neg    %edx
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	0f 45 c2             	cmovne %edx,%eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 c3                	mov    %eax,%ebx
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad4:	89 d1                	mov    %edx,%ecx
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 d7                	mov    %edx,%edi
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af1:	b8 03 00 00 00       	mov    $0x3,%eax
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	89 cb                	mov    %ecx,%ebx
  800afb:	89 cf                	mov    %ecx,%edi
  800afd:	89 ce                	mov    %ecx,%esi
  800aff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 03                	push   $0x3
  800b0b:	68 88 12 80 00       	push   $0x801288
  800b10:	6a 23                	push   $0x23
  800b12:	68 a5 12 80 00       	push   $0x8012a5
  800b17:	e8 22 02 00 00       	call   800d3e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_yield>:

void
sys_yield(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	be 00 00 00 00       	mov    $0x0,%esi
  800b70:	b8 04 00 00 00       	mov    $0x4,%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7e:	89 f7                	mov    %esi,%edi
  800b80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 04                	push   $0x4
  800b8c:	68 88 12 80 00       	push   $0x801288
  800b91:	6a 23                	push   $0x23
  800b93:	68 a5 12 80 00       	push   $0x8012a5
  800b98:	e8 a1 01 00 00       	call   800d3e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 05                	push   $0x5
  800bce:	68 88 12 80 00       	push   $0x801288
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 a5 12 80 00       	push   $0x8012a5
  800bda:	e8 5f 01 00 00       	call   800d3e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 df                	mov    %ebx,%edi
  800c02:	89 de                	mov    %ebx,%esi
  800c04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 06                	push   $0x6
  800c10:	68 88 12 80 00       	push   $0x801288
  800c15:	6a 23                	push   $0x23
  800c17:	68 a5 12 80 00       	push   $0x8012a5
  800c1c:	e8 1d 01 00 00       	call   800d3e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 08                	push   $0x8
  800c52:	68 88 12 80 00       	push   $0x801288
  800c57:	6a 23                	push   $0x23
  800c59:	68 a5 12 80 00       	push   $0x8012a5
  800c5e:	e8 db 00 00 00       	call   800d3e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 09                	push   $0x9
  800c94:	68 88 12 80 00       	push   $0x801288
  800c99:	6a 23                	push   $0x23
  800c9b:	68 a5 12 80 00       	push   $0x8012a5
  800ca0:	e8 99 00 00 00       	call   800d3e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
  800cb8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 cb                	mov    %ecx,%ebx
  800ce8:	89 cf                	mov    %ecx,%edi
  800cea:	89 ce                	mov    %ecx,%esi
  800cec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 17                	jle    800d09 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 0c                	push   $0xc
  800cf8:	68 88 12 80 00       	push   $0x801288
  800cfd:	6a 23                	push   $0x23
  800cff:	68 a5 12 80 00       	push   $0x8012a5
  800d04:	e8 35 00 00 00       	call   800d3e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d17:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d1e:	75 14                	jne    800d34 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	68 b4 12 80 00       	push   $0x8012b4
  800d28:	6a 20                	push   $0x20
  800d2a:	68 d8 12 80 00       	push   $0x8012d8
  800d2f:	e8 0a 00 00 00       	call   800d3e <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d43:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d46:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d4c:	e8 d3 fd ff ff       	call   800b24 <sys_getenvid>
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	ff 75 08             	pushl  0x8(%ebp)
  800d5a:	56                   	push   %esi
  800d5b:	50                   	push   %eax
  800d5c:	68 e8 12 80 00       	push   $0x8012e8
  800d61:	e8 f5 f3 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d66:	83 c4 18             	add    $0x18,%esp
  800d69:	53                   	push   %ebx
  800d6a:	ff 75 10             	pushl  0x10(%ebp)
  800d6d:	e8 98 f3 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  800d72:	c7 04 24 3a 10 80 00 	movl   $0x80103a,(%esp)
  800d79:	e8 dd f3 ff ff       	call   80015b <cprintf>
  800d7e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d81:	cc                   	int3   
  800d82:	eb fd                	jmp    800d81 <_panic+0x43>
  800d84:	66 90                	xchg   %ax,%ax
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	66 90                	xchg   %ax,%ax
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 f6                	test   %esi,%esi
  800da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dad:	89 ca                	mov    %ecx,%edx
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	75 3d                	jne    800df0 <__udivdi3+0x60>
  800db3:	39 cf                	cmp    %ecx,%edi
  800db5:	0f 87 c5 00 00 00    	ja     800e80 <__udivdi3+0xf0>
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	89 fd                	mov    %edi,%ebp
  800dbf:	75 0b                	jne    800dcc <__udivdi3+0x3c>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	f7 f7                	div    %edi
  800dca:	89 c5                	mov    %eax,%ebp
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f5                	div    %ebp
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	89 cf                	mov    %ecx,%edi
  800dd8:	f7 f5                	div    %ebp
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 ce                	cmp    %ecx,%esi
  800df2:	77 74                	ja     800e68 <__udivdi3+0xd8>
  800df4:	0f bd fe             	bsr    %esi,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0x108>
  800e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	89 c5                	mov    %eax,%ebp
  800e09:	29 fb                	sub    %edi,%ebx
  800e0b:	d3 e6                	shl    %cl,%esi
  800e0d:	89 d9                	mov    %ebx,%ecx
  800e0f:	d3 ed                	shr    %cl,%ebp
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	d3 e0                	shl    %cl,%eax
  800e15:	09 ee                	or     %ebp,%esi
  800e17:	89 d9                	mov    %ebx,%ecx
  800e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1d:	89 d5                	mov    %edx,%ebp
  800e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e23:	d3 ed                	shr    %cl,%ebp
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e2                	shl    %cl,%edx
  800e29:	89 d9                	mov    %ebx,%ecx
  800e2b:	d3 e8                	shr    %cl,%eax
  800e2d:	09 c2                	or     %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	89 ea                	mov    %ebp,%edx
  800e33:	f7 f6                	div    %esi
  800e35:	89 d5                	mov    %edx,%ebp
  800e37:	89 c3                	mov    %eax,%ebx
  800e39:	f7 64 24 0c          	mull   0xc(%esp)
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	72 10                	jb     800e51 <__udivdi3+0xc1>
  800e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e6                	shl    %cl,%esi
  800e49:	39 c6                	cmp    %eax,%esi
  800e4b:	73 07                	jae    800e54 <__udivdi3+0xc4>
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	75 03                	jne    800e54 <__udivdi3+0xc4>
  800e51:	83 eb 01             	sub    $0x1,%ebx
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	31 db                	xor    %ebx,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	f7 f7                	div    %edi
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	89 fa                	mov    %edi,%edx
  800e8c:	83 c4 1c             	add    $0x1c,%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	39 ce                	cmp    %ecx,%esi
  800e9a:	72 0c                	jb     800ea8 <__udivdi3+0x118>
  800e9c:	31 db                	xor    %ebx,%ebx
  800e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ea2:	0f 87 34 ff ff ff    	ja     800ddc <__udivdi3+0x4c>
  800ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ead:	e9 2a ff ff ff       	jmp    800ddc <__udivdi3+0x4c>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 d2                	test   %edx,%edx
  800ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f3                	mov    %esi,%ebx
  800ee3:	89 3c 24             	mov    %edi,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	75 1c                	jne    800f08 <__umoddi3+0x48>
  800eec:	39 f7                	cmp    %esi,%edi
  800eee:	76 50                	jbe    800f40 <__umoddi3+0x80>
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	f7 f7                	div    %edi
  800ef6:	89 d0                	mov    %edx,%eax
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	89 d0                	mov    %edx,%eax
  800f0c:	77 52                	ja     800f60 <__umoddi3+0xa0>
  800f0e:	0f bd ea             	bsr    %edx,%ebp
  800f11:	83 f5 1f             	xor    $0x1f,%ebp
  800f14:	75 5a                	jne    800f70 <__umoddi3+0xb0>
  800f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	39 0c 24             	cmp    %ecx,(%esp)
  800f23:	0f 86 d7 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f31:	83 c4 1c             	add    $0x1c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	85 ff                	test   %edi,%edi
  800f42:	89 fd                	mov    %edi,%ebp
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 c8                	mov    %ecx,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	eb 99                	jmp    800ef8 <__umoddi3+0x38>
  800f5f:	90                   	nop
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	83 c4 1c             	add    $0x1c,%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	8b 34 24             	mov    (%esp),%esi
  800f73:	bf 20 00 00 00       	mov    $0x20,%edi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	29 ef                	sub    %ebp,%edi
  800f7c:	d3 e0                	shl    %cl,%eax
  800f7e:	89 f9                	mov    %edi,%ecx
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	d3 ea                	shr    %cl,%edx
  800f84:	89 e9                	mov    %ebp,%ecx
  800f86:	09 c2                	or     %eax,%edx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 14 24             	mov    %edx,(%esp)
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	d3 e2                	shl    %cl,%edx
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	d3 e3                	shl    %cl,%ebx
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	09 d8                	or     %ebx,%eax
  800fad:	89 d3                	mov    %edx,%ebx
  800faf:	89 f2                	mov    %esi,%edx
  800fb1:	f7 34 24             	divl   (%esp)
  800fb4:	89 d6                	mov    %edx,%esi
  800fb6:	d3 e3                	shl    %cl,%ebx
  800fb8:	f7 64 24 04          	mull   0x4(%esp)
  800fbc:	39 d6                	cmp    %edx,%esi
  800fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	72 08                	jb     800fd0 <__umoddi3+0x110>
  800fc8:	75 11                	jne    800fdb <__umoddi3+0x11b>
  800fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fce:	73 0b                	jae    800fdb <__umoddi3+0x11b>
  800fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fd4:	1b 14 24             	sbb    (%esp),%edx
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fdf:	29 da                	sub    %ebx,%edx
  800fe1:	19 ce                	sbb    %ecx,%esi
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e0                	shl    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	d3 ea                	shr    %cl,%edx
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	d3 ee                	shr    %cl,%esi
  800ff1:	09 d0                	or     %edx,%eax
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	83 c4 1c             	add    $0x1c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 f9                	sub    %edi,%ecx
  801002:	19 d6                	sbb    %edx,%esi
  801004:	89 74 24 04          	mov    %esi,0x4(%esp)
  801008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80100c:	e9 18 ff ff ff       	jmp    800f29 <__umoddi3+0x69>
