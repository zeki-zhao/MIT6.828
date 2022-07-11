
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 60 10 80 00       	push   $0x801060
  80003f:	e8 4c 01 00 00       	call   800190 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 fd 0c 00 00       	call   800d46 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 d8 10 80 00       	push   $0x8010d8
  800058:	e8 33 01 00 00       	call   800190 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 88 10 80 00       	push   $0x801088
  80006c:	e8 1f 01 00 00       	call   800190 <cprintf>
	sys_yield();
  800071:	e8 02 0b 00 00       	call   800b78 <sys_yield>
	sys_yield();
  800076:	e8 fd 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  80007b:	e8 f8 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  800080:	e8 f3 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  800085:	e8 ee 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  80008a:	e8 e9 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  80008f:	e8 e4 0a 00 00       	call   800b78 <sys_yield>
	sys_yield();
  800094:	e8 df 0a 00 00       	call   800b78 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 b0 10 80 00 	movl   $0x8010b0,(%esp)
  8000a0:	e8 eb 00 00 00       	call   800190 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 6b 0a 00 00       	call   800b18 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 08             	sub    $0x8,%esp
  8000bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000be:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c1:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000c8:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7e 08                	jle    8000d7 <libmain+0x22>
		binaryname = argv[0];
  8000cf:	8b 0a                	mov    (%edx),%ecx
  8000d1:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	52                   	push   %edx
  8000db:	50                   	push   %eax
  8000dc:	e8 52 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e1:	e8 05 00 00 00       	call   8000eb <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	e8 20 0a 00 00       	call   800b18 <sys_env_destroy>
}
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	53                   	push   %ebx
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800107:	8b 13                	mov    (%ebx),%edx
  800109:	8d 42 01             	lea    0x1(%edx),%eax
  80010c:	89 03                	mov    %eax,(%ebx)
  80010e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011a:	75 1a                	jne    800136 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	68 ff 00 00 00       	push   $0xff
  800124:	8d 43 08             	lea    0x8(%ebx),%eax
  800127:	50                   	push   %eax
  800128:	e8 ae 09 00 00       	call   800adb <sys_cputs>
		b->idx = 0;
  80012d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800133:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800136:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014f:	00 00 00 
	b.cnt = 0;
  800152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	50                   	push   %eax
  800169:	68 fd 00 80 00       	push   $0x8000fd
  80016e:	e8 1a 01 00 00       	call   80028d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 53 09 00 00       	call   800adb <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 9d ff ff ff       	call   80013f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 1c             	sub    $0x1c,%esp
  8001ad:	89 c7                	mov    %eax,%edi
  8001af:	89 d6                	mov    %edx,%esi
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cb:	39 d3                	cmp    %edx,%ebx
  8001cd:	72 05                	jb     8001d4 <printnum+0x30>
  8001cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d2:	77 45                	ja     800219 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	8b 45 14             	mov    0x14(%ebp),%eax
  8001dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e0:	53                   	push   %ebx
  8001e1:	ff 75 10             	pushl  0x10(%ebp)
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f3:	e8 c8 0b 00 00       	call   800dc0 <__udivdi3>
  8001f8:	83 c4 18             	add    $0x18,%esp
  8001fb:	52                   	push   %edx
  8001fc:	50                   	push   %eax
  8001fd:	89 f2                	mov    %esi,%edx
  8001ff:	89 f8                	mov    %edi,%eax
  800201:	e8 9e ff ff ff       	call   8001a4 <printnum>
  800206:	83 c4 20             	add    $0x20,%esp
  800209:	eb 18                	jmp    800223 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	56                   	push   %esi
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	ff d7                	call   *%edi
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	eb 03                	jmp    80021c <printnum+0x78>
  800219:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021c:	83 eb 01             	sub    $0x1,%ebx
  80021f:	85 db                	test   %ebx,%ebx
  800221:	7f e8                	jg     80020b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	83 ec 04             	sub    $0x4,%esp
  80022a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022d:	ff 75 e0             	pushl  -0x20(%ebp)
  800230:	ff 75 dc             	pushl  -0x24(%ebp)
  800233:	ff 75 d8             	pushl  -0x28(%ebp)
  800236:	e8 b5 0c 00 00       	call   800ef0 <__umoddi3>
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	0f be 80 00 11 80 00 	movsbl 0x801100(%eax),%eax
  800245:	50                   	push   %eax
  800246:	ff d7                	call   *%edi
}
  800248:	83 c4 10             	add    $0x10,%esp
  80024b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800259:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	3b 50 04             	cmp    0x4(%eax),%edx
  800262:	73 0a                	jae    80026e <sprintputch+0x1b>
		*b->buf++ = ch;
  800264:	8d 4a 01             	lea    0x1(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	88 02                	mov    %al,(%edx)
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800276:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800279:	50                   	push   %eax
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	e8 05 00 00 00       	call   80028d <vprintfmt>
	va_end(ap);
}
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 2c             	sub    $0x2c,%esp
  800296:	8b 75 08             	mov    0x8(%ebp),%esi
  800299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029f:	eb 12                	jmp    8002b3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	0f 84 42 04 00 00    	je     8006eb <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	53                   	push   %ebx
  8002ad:	50                   	push   %eax
  8002ae:	ff d6                	call   *%esi
  8002b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b3:	83 c7 01             	add    $0x1,%edi
  8002b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ba:	83 f8 25             	cmp    $0x25,%eax
  8002bd:	75 e2                	jne    8002a1 <vprintfmt+0x14>
  8002bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002dd:	eb 07                	jmp    8002e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8d 47 01             	lea    0x1(%edi),%eax
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	0f b6 07             	movzbl (%edi),%eax
  8002ef:	0f b6 d0             	movzbl %al,%edx
  8002f2:	83 e8 23             	sub    $0x23,%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 d3 03 00 00    	ja     8006d0 <vprintfmt+0x443>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030e:	eb d6                	jmp    8002e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800313:	b8 00 00 00 00       	mov    $0x0,%eax
  800318:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800322:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800325:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800328:	83 f9 09             	cmp    $0x9,%ecx
  80032b:	77 3f                	ja     80036c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800330:	eb e9                	jmp    80031b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8b 00                	mov    (%eax),%eax
  800337:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033a:	8b 45 14             	mov    0x14(%ebp),%eax
  80033d:	8d 40 04             	lea    0x4(%eax),%eax
  800340:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800346:	eb 2a                	jmp    800372 <vprintfmt+0xe5>
  800348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034b:	85 c0                	test   %eax,%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	0f 49 d0             	cmovns %eax,%edx
  800355:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035b:	eb 89                	jmp    8002e6 <vprintfmt+0x59>
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800360:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800367:	e9 7a ff ff ff       	jmp    8002e6 <vprintfmt+0x59>
  80036c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800372:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800376:	0f 89 6a ff ff ff    	jns    8002e6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80037c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800382:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800389:	e9 58 ff ff ff       	jmp    8002e6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800394:	e9 4d ff ff ff       	jmp    8002e6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 78 04             	lea    0x4(%eax),%edi
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	53                   	push   %ebx
  8003a3:	ff 30                	pushl  (%eax)
  8003a5:	ff d6                	call   *%esi
			break;
  8003a7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003aa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b0:	e9 fe fe ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 78 04             	lea    0x4(%eax),%edi
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	99                   	cltd   
  8003be:	31 d0                	xor    %edx,%eax
  8003c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c2:	83 f8 09             	cmp    $0x9,%eax
  8003c5:	7f 0b                	jg     8003d2 <vprintfmt+0x145>
  8003c7:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003ce:	85 d2                	test   %edx,%edx
  8003d0:	75 1b                	jne    8003ed <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d2:	50                   	push   %eax
  8003d3:	68 18 11 80 00       	push   $0x801118
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 91 fe ff ff       	call   800270 <printfmt>
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
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e8:	e9 c6 fe ff ff       	jmp    8002b3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ed:	52                   	push   %edx
  8003ee:	68 21 11 80 00       	push   $0x801121
  8003f3:	53                   	push   %ebx
  8003f4:	56                   	push   %esi
  8003f5:	e8 76 fe ff ff       	call   800270 <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800403:	e9 ab fe ff ff       	jmp    8002b3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	83 c0 04             	add    $0x4,%eax
  80040e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800416:	85 ff                	test   %edi,%edi
  800418:	b8 11 11 80 00       	mov    $0x801111,%eax
  80041d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	0f 8e 94 00 00 00    	jle    8004be <vprintfmt+0x231>
  80042a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042e:	0f 84 98 00 00 00    	je     8004cc <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	ff 75 d0             	pushl  -0x30(%ebp)
  80043a:	57                   	push   %edi
  80043b:	e8 33 03 00 00       	call   800773 <strnlen>
  800440:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800443:	29 c1                	sub    %eax,%ecx
  800445:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800448:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800455:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	eb 0f                	jmp    800468 <vprintfmt+0x1db>
					putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	53                   	push   %ebx
  80045d:	ff 75 e0             	pushl  -0x20(%ebp)
  800460:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	83 ef 01             	sub    $0x1,%edi
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 ff                	test   %edi,%edi
  80046a:	7f ed                	jg     800459 <vprintfmt+0x1cc>
  80046c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800472:	85 c9                	test   %ecx,%ecx
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	0f 49 c1             	cmovns %ecx,%eax
  80047c:	29 c1                	sub    %eax,%ecx
  80047e:	89 75 08             	mov    %esi,0x8(%ebp)
  800481:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800487:	89 cb                	mov    %ecx,%ebx
  800489:	eb 4d                	jmp    8004d8 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048f:	74 1b                	je     8004ac <vprintfmt+0x21f>
  800491:	0f be c0             	movsbl %al,%eax
  800494:	83 e8 20             	sub    $0x20,%eax
  800497:	83 f8 5e             	cmp    $0x5e,%eax
  80049a:	76 10                	jbe    8004ac <vprintfmt+0x21f>
					putch('?', putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	6a 3f                	push   $0x3f
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	eb 0d                	jmp    8004b9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 0c             	pushl  0xc(%ebp)
  8004b2:	52                   	push   %edx
  8004b3:	ff 55 08             	call   *0x8(%ebp)
  8004b6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b9:	83 eb 01             	sub    $0x1,%ebx
  8004bc:	eb 1a                	jmp    8004d8 <vprintfmt+0x24b>
  8004be:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ca:	eb 0c                	jmp    8004d8 <vprintfmt+0x24b>
  8004cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d8:	83 c7 01             	add    $0x1,%edi
  8004db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004df:	0f be d0             	movsbl %al,%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	74 23                	je     800509 <vprintfmt+0x27c>
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	78 a1                	js     80048b <vprintfmt+0x1fe>
  8004ea:	83 ee 01             	sub    $0x1,%esi
  8004ed:	79 9c                	jns    80048b <vprintfmt+0x1fe>
  8004ef:	89 df                	mov    %ebx,%edi
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	eb 18                	jmp    800511 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	6a 20                	push   $0x20
  8004ff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800501:	83 ef 01             	sub    $0x1,%edi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	eb 08                	jmp    800511 <vprintfmt+0x284>
  800509:	89 df                	mov    %ebx,%edi
  80050b:	8b 75 08             	mov    0x8(%ebp),%esi
  80050e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800511:	85 ff                	test   %edi,%edi
  800513:	7f e4                	jg     8004f9 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051e:	e9 90 fd ff ff       	jmp    8002b3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800523:	83 f9 01             	cmp    $0x1,%ecx
  800526:	7e 19                	jle    800541 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 50 04             	mov    0x4(%eax),%edx
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 40 08             	lea    0x8(%eax),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
  80053f:	eb 38                	jmp    800579 <vprintfmt+0x2ec>
	else if (lflag)
  800541:	85 c9                	test   %ecx,%ecx
  800543:	74 1b                	je     800560 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	89 c1                	mov    %eax,%ecx
  80054f:	c1 f9 1f             	sar    $0x1f,%ecx
  800552:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	eb 19                	jmp    800579 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 c1                	mov    %eax,%ecx
  80056a:	c1 f9 1f             	sar    $0x1f,%ecx
  80056d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800584:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800588:	0f 89 0e 01 00 00    	jns    80069c <vprintfmt+0x40f>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059c:	f7 da                	neg    %edx
  80059e:	83 d1 00             	adc    $0x0,%ecx
  8005a1:	f7 d9                	neg    %ecx
  8005a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 ec 00 00 00       	jmp    80069c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7e 18                	jle    8005cd <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bd:	8d 40 08             	lea    0x8(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c8:	e9 cf 00 00 00       	jmp    80069c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	74 1a                	je     8005eb <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 b1 00 00 00       	jmp    80069c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 97 00 00 00       	jmp    80069c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 58                	push   $0x58
  80060b:	ff d6                	call   *%esi
			putch('X', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 58                	push   $0x58
  800613:	ff d6                	call   *%esi
			putch('X', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 58                	push   $0x58
  80061b:	ff d6                	call   *%esi
			break;
  80061d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800623:	e9 8b fc ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 30                	push   $0x30
  80062e:	ff d6                	call   *%esi
			putch('x', putdat);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 78                	push   $0x78
  800636:	ff d6                	call   *%esi
			num = (unsigned long long)
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800650:	eb 4a                	jmp    80069c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800652:	83 f9 01             	cmp    $0x1,%ecx
  800655:	7e 15                	jle    80066c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	8d 40 08             	lea    0x8(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
  80066a:	eb 30                	jmp    80069c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	74 17                	je     800687 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800680:	b8 10 00 00 00       	mov    $0x10,%eax
  800685:	eb 15                	jmp    80069c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a3:	57                   	push   %edi
  8006a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a7:	50                   	push   %eax
  8006a8:	51                   	push   %ecx
  8006a9:	52                   	push   %edx
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	e8 f1 fa ff ff       	call   8001a4 <printnum>
			break;
  8006b3:	83 c4 20             	add    $0x20,%esp
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 f5 fb ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	52                   	push   %edx
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cb:	e9 e3 fb ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 03                	jmp    8006e0 <vprintfmt+0x453>
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e4:	75 f7                	jne    8006dd <vprintfmt+0x450>
  8006e6:	e9 c8 fb ff ff       	jmp    8002b3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5f                   	pop    %edi
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800702:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800706:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 26                	je     80073a <vsnprintf+0x47>
  800714:	85 d2                	test   %edx,%edx
  800716:	7e 22                	jle    80073a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800718:	ff 75 14             	pushl  0x14(%ebp)
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	68 53 02 80 00       	push   $0x800253
  800727:	e8 61 fb ff ff       	call   80028d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 05                	jmp    80073f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	50                   	push   %eax
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	ff 75 08             	pushl  0x8(%ebp)
  800754:	e8 9a ff ff ff       	call   8006f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strlen+0x10>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076f:	75 f7                	jne    800768 <strlen+0xd>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 03                	jmp    800786 <strnlen+0x13>
		n++;
  800783:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 08                	je     800792 <strnlen+0x1f>
  80078a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078e:	75 f3                	jne    800783 <strnlen+0x10>
  800790:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	83 c1 01             	add    $0x1,%ecx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9a ff ff ff       	call   80075b <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	8b 55 10             	mov    0x10(%ebp),%edx
  800811:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	85 d2                	test   %edx,%edx
  800815:	74 21                	je     800838 <strlcpy+0x35>
  800817:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 09                	jmp    800828 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 09                	je     800835 <strlcpy+0x32>
  80082c:	0f b6 19             	movzbl (%ecx),%ebx
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ec                	jne    80081f <strlcpy+0x1c>
  800833:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800838:	29 f0                	sub    %esi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800847:	eb 06                	jmp    80084f <strcmp+0x11>
		p++, q++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084f:	0f b6 01             	movzbl (%ecx),%eax
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x1c>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 ef                	je     800849 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	89 c3                	mov    %eax,%ebx
  800870:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800873:	eb 06                	jmp    80087b <strncmp+0x17>
		n--, p++, q++;
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 15                	je     800894 <strncmp+0x30>
  80087f:	0f b6 08             	movzbl (%eax),%ecx
  800882:	84 c9                	test   %cl,%cl
  800884:	74 04                	je     80088a <strncmp+0x26>
  800886:	3a 0a                	cmp    (%edx),%cl
  800888:	74 eb                	je     800875 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 00             	movzbl (%eax),%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
  800892:	eb 05                	jmp    800899 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800899:	5b                   	pop    %ebx
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 07                	jmp    8008af <strchr+0x13>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 0f                	je     8008bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 03                	jmp    8008cc <strfind+0xf>
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 04                	je     8008d7 <strfind+0x1a>
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 36                	je     80091f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 28                	jne    800919 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 23                	jne    800919 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fa:	89 d3                	mov    %edx,%ebx
  8008fc:	c1 e3 08             	shl    $0x8,%ebx
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	c1 e6 18             	shl    $0x18,%esi
  800904:	89 d0                	mov    %edx,%eax
  800906:	c1 e0 10             	shl    $0x10,%eax
  800909:	09 f0                	or     %esi,%eax
  80090b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090d:	89 d8                	mov    %ebx,%eax
  80090f:	09 d0                	or     %edx,%eax
  800911:	c1 e9 02             	shr    $0x2,%ecx
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 06                	jmp    80091f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 35                	jae    80096d <memmove+0x47>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	73 2e                	jae    80096d <memmove+0x47>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 13                	jne    800961 <memmove+0x3b>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0e                	jne    800961 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 1d                	jmp    80098a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	09 c2                	or     %eax,%edx
  800971:	f6 c2 03             	test   $0x3,%dl
  800974:	75 0f                	jne    800985 <memmove+0x5f>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	ff 75 0c             	pushl  0xc(%ebp)
  800997:	ff 75 08             	pushl  0x8(%ebp)
  80099a:	e8 87 ff ff ff       	call   800926 <memmove>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c6                	mov    %eax,%esi
  8009ae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	eb 1a                	jmp    8009cd <memcmp+0x2c>
		if (*s1 != *s2)
  8009b3:	0f b6 08             	movzbl (%eax),%ecx
  8009b6:	0f b6 1a             	movzbl (%edx),%ebx
  8009b9:	38 d9                	cmp    %bl,%cl
  8009bb:	74 0a                	je     8009c7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bd:	0f b6 c1             	movzbl %cl,%eax
  8009c0:	0f b6 db             	movzbl %bl,%ebx
  8009c3:	29 d8                	sub    %ebx,%eax
  8009c5:	eb 0f                	jmp    8009d6 <memcmp+0x35>
		s1++, s2++;
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	39 f0                	cmp    %esi,%eax
  8009cf:	75 e2                	jne    8009b3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e1:	89 c1                	mov    %eax,%ecx
  8009e3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ea:	eb 0a                	jmp    8009f6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 10             	movzbl (%eax),%edx
  8009ef:	39 da                	cmp    %ebx,%edx
  8009f1:	74 07                	je     8009fa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	39 c8                	cmp    %ecx,%eax
  8009f8:	72 f2                	jb     8009ec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	eb 03                	jmp    800a0e <strtol+0x11>
		s++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f6                	je     800a0b <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f2                	je     800a0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 0a                	jne    800a27 <strtol+0x2a>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
  800a25:	eb 11                	jmp    800a38 <strtol+0x3b>
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2c:	3c 2d                	cmp    $0x2d,%al
  800a2e:	75 08                	jne    800a38 <strtol+0x3b>
		s++, neg = 1;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3e:	75 15                	jne    800a55 <strtol+0x58>
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 10                	jne    800a55 <strtol+0x58>
  800a45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a49:	75 7c                	jne    800ac7 <strtol+0xca>
		s += 2, base = 16;
  800a4b:	83 c1 02             	add    $0x2,%ecx
  800a4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a53:	eb 16                	jmp    800a6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	75 12                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a61:	75 08                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a73:	0f b6 11             	movzbl (%ecx),%edx
  800a76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 09             	cmp    $0x9,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x8b>
			dig = *s - '0';
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 30             	sub    $0x30,%edx
  800a86:	eb 22                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 57             	sub    $0x57,%edx
  800a98:	eb 10                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 16                	ja     800aba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aad:	7d 0b                	jge    800aba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab8:	eb b9                	jmp    800a73 <strtol+0x76>

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 0d                	je     800acd <strtol+0xd0>
		*endptr = (char *) s;
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac3:	89 0e                	mov    %ecx,(%esi)
  800ac5:	eb 06                	jmp    800acd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	74 98                	je     800a63 <strtol+0x66>
  800acb:	eb 9e                	jmp    800a6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	f7 da                	neg    %edx
  800ad1:	85 ff                	test   %edi,%edi
  800ad3:	0f 45 c2             	cmovne %edx,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	89 c6                	mov    %eax,%esi
  800af2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 01 00 00 00       	mov    $0x1,%eax
  800b09:	89 d1                	mov    %edx,%ecx
  800b0b:	89 d3                	mov    %edx,%ebx
  800b0d:	89 d7                	mov    %edx,%edi
  800b0f:	89 d6                	mov    %edx,%esi
  800b11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b26:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	89 cb                	mov    %ecx,%ebx
  800b30:	89 cf                	mov    %ecx,%edi
  800b32:	89 ce                	mov    %ecx,%esi
  800b34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b36:	85 c0                	test   %eax,%eax
  800b38:	7e 17                	jle    800b51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	50                   	push   %eax
  800b3e:	6a 03                	push   $0x3
  800b40:	68 48 13 80 00       	push   $0x801348
  800b45:	6a 23                	push   $0x23
  800b47:	68 65 13 80 00       	push   $0x801365
  800b4c:	e8 23 02 00 00       	call   800d74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 02 00 00 00       	mov    $0x2,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_yield>:

void
sys_yield(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	be 00 00 00 00       	mov    $0x0,%esi
  800ba5:	b8 04 00 00 00       	mov    $0x4,%eax
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb3:	89 f7                	mov    %esi,%edi
  800bb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 04                	push   $0x4
  800bc1:	68 48 13 80 00       	push   $0x801348
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 65 13 80 00       	push   $0x801365
  800bcd:	e8 a2 01 00 00       	call   800d74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	b8 05 00 00 00       	mov    $0x5,%eax
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 05                	push   $0x5
  800c03:	68 48 13 80 00       	push   $0x801348
  800c08:	6a 23                	push   $0x23
  800c0a:	68 65 13 80 00       	push   $0x801365
  800c0f:	e8 60 01 00 00       	call   800d74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 06                	push   $0x6
  800c45:	68 48 13 80 00       	push   $0x801348
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 65 13 80 00       	push   $0x801365
  800c51:	e8 1e 01 00 00       	call   800d74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 08                	push   $0x8
  800c87:	68 48 13 80 00       	push   $0x801348
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 65 13 80 00       	push   $0x801365
  800c93:	e8 dc 00 00 00       	call   800d74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 df                	mov    %ebx,%edi
  800cbb:	89 de                	mov    %ebx,%esi
  800cbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 09                	push   $0x9
  800cc9:	68 48 13 80 00       	push   $0x801348
  800cce:	6a 23                	push   $0x23
  800cd0:	68 65 13 80 00       	push   $0x801365
  800cd5:	e8 9a 00 00 00       	call   800d74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	be 00 00 00 00       	mov    $0x0,%esi
  800ced:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	89 cb                	mov    %ecx,%ebx
  800d1d:	89 cf                	mov    %ecx,%edi
  800d1f:	89 ce                	mov    %ecx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0c                	push   $0xc
  800d2d:	68 48 13 80 00       	push   $0x801348
  800d32:	6a 23                	push   $0x23
  800d34:	68 65 13 80 00       	push   $0x801365
  800d39:	e8 36 00 00 00       	call   800d74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d4c:	68 7f 13 80 00       	push   $0x80137f
  800d51:	6a 51                	push   $0x51
  800d53:	68 73 13 80 00       	push   $0x801373
  800d58:	e8 17 00 00 00       	call   800d74 <_panic>

00800d5d <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d63:	68 7e 13 80 00       	push   $0x80137e
  800d68:	6a 58                	push   $0x58
  800d6a:	68 73 13 80 00       	push   $0x801373
  800d6f:	e8 00 00 00 00       	call   800d74 <_panic>

00800d74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d79:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d7c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d82:	e8 d2 fd ff ff       	call   800b59 <sys_getenvid>
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	ff 75 08             	pushl  0x8(%ebp)
  800d90:	56                   	push   %esi
  800d91:	50                   	push   %eax
  800d92:	68 94 13 80 00       	push   $0x801394
  800d97:	e8 f4 f3 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d9c:	83 c4 18             	add    $0x18,%esp
  800d9f:	53                   	push   %ebx
  800da0:	ff 75 10             	pushl  0x10(%ebp)
  800da3:	e8 97 f3 ff ff       	call   80013f <vcprintf>
	cprintf("\n");
  800da8:	c7 04 24 f4 10 80 00 	movl   $0x8010f4,(%esp)
  800daf:	e8 dc f3 ff ff       	call   800190 <cprintf>
  800db4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800db7:	cc                   	int3   
  800db8:	eb fd                	jmp    800db7 <_panic+0x43>
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
