
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 05 0b 00 00       	call   800b45 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 d4 0c 00 00       	call   800d32 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 80 10 80 00       	push   $0x801080
  80006a:	e8 0d 01 00 00       	call   80017c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 91 10 80 00       	push   $0x801091
  800083:	e8 f4 00 00 00       	call   80017c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 ad 0c 00 00       	call   800d49 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8000aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ad:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000b4:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 c0                	test   %eax,%eax
  8000b9:	7e 08                	jle    8000c3 <libmain+0x22>
		binaryname = argv[0];
  8000bb:	8b 0a                	mov    (%edx),%ecx
  8000bd:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	52                   	push   %edx
  8000c7:	50                   	push   %eax
  8000c8:	e8 66 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 05 00 00 00       	call   8000d7 <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    

008000d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000dd:	6a 00                	push   $0x0
  8000df:	e8 20 0a 00 00       	call   800b04 <sys_env_destroy>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 04             	sub    $0x4,%esp
  8000f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f3:	8b 13                	mov    (%ebx),%edx
  8000f5:	8d 42 01             	lea    0x1(%edx),%eax
  8000f8:	89 03                	mov    %eax,(%ebx)
  8000fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800101:	3d ff 00 00 00       	cmp    $0xff,%eax
  800106:	75 1a                	jne    800122 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 ff 00 00 00       	push   $0xff
  800110:	8d 43 08             	lea    0x8(%ebx),%eax
  800113:	50                   	push   %eax
  800114:	e8 ae 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  800119:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800122:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800134:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013b:	00 00 00 
	b.cnt = 0;
  80013e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800145:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800154:	50                   	push   %eax
  800155:	68 e9 00 80 00       	push   $0x8000e9
  80015a:	e8 1a 01 00 00       	call   800279 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	83 c4 08             	add    $0x8,%esp
  800162:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800168:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 53 09 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  800174:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 9d ff ff ff       	call   80012b <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 1c             	sub    $0x1c,%esp
  800199:	89 c7                	mov    %eax,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b7:	39 d3                	cmp    %edx,%ebx
  8001b9:	72 05                	jb     8001c0 <printnum+0x30>
  8001bb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001be:	77 45                	ja     800205 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	ff 75 18             	pushl  0x18(%ebp)
  8001c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001cc:	53                   	push   %ebx
  8001cd:	ff 75 10             	pushl  0x10(%ebp)
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 fc 0b 00 00       	call   800de0 <__udivdi3>
  8001e4:	83 c4 18             	add    $0x18,%esp
  8001e7:	52                   	push   %edx
  8001e8:	50                   	push   %eax
  8001e9:	89 f2                	mov    %esi,%edx
  8001eb:	89 f8                	mov    %edi,%eax
  8001ed:	e8 9e ff ff ff       	call   800190 <printnum>
  8001f2:	83 c4 20             	add    $0x20,%esp
  8001f5:	eb 18                	jmp    80020f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	56                   	push   %esi
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	ff d7                	call   *%edi
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	eb 03                	jmp    800208 <printnum+0x78>
  800205:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	85 db                	test   %ebx,%ebx
  80020d:	7f e8                	jg     8001f7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	83 ec 04             	sub    $0x4,%esp
  800216:	ff 75 e4             	pushl  -0x1c(%ebp)
  800219:	ff 75 e0             	pushl  -0x20(%ebp)
  80021c:	ff 75 dc             	pushl  -0x24(%ebp)
  80021f:	ff 75 d8             	pushl  -0x28(%ebp)
  800222:	e8 e9 0c 00 00       	call   800f10 <__umoddi3>
  800227:	83 c4 14             	add    $0x14,%esp
  80022a:	0f be 80 b2 10 80 00 	movsbl 0x8010b2(%eax),%eax
  800231:	50                   	push   %eax
  800232:	ff d7                	call   *%edi
}
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800245:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800249:	8b 10                	mov    (%eax),%edx
  80024b:	3b 50 04             	cmp    0x4(%eax),%edx
  80024e:	73 0a                	jae    80025a <sprintputch+0x1b>
		*b->buf++ = ch;
  800250:	8d 4a 01             	lea    0x1(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	88 02                	mov    %al,(%edx)
}
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800262:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800265:	50                   	push   %eax
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	ff 75 0c             	pushl  0xc(%ebp)
  80026c:	ff 75 08             	pushl  0x8(%ebp)
  80026f:	e8 05 00 00 00       	call   800279 <vprintfmt>
	va_end(ap);
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 2c             	sub    $0x2c,%esp
  800282:	8b 75 08             	mov    0x8(%ebp),%esi
  800285:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800288:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028b:	eb 12                	jmp    80029f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028d:	85 c0                	test   %eax,%eax
  80028f:	0f 84 42 04 00 00    	je     8006d7 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	53                   	push   %ebx
  800299:	50                   	push   %eax
  80029a:	ff d6                	call   *%esi
  80029c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029f:	83 c7 01             	add    $0x1,%edi
  8002a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a6:	83 f8 25             	cmp    $0x25,%eax
  8002a9:	75 e2                	jne    80028d <vprintfmt+0x14>
  8002ab:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002af:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	eb 07                	jmp    8002d2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ce:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8d 47 01             	lea    0x1(%edi),%eax
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	0f b6 07             	movzbl (%edi),%eax
  8002db:	0f b6 d0             	movzbl %al,%edx
  8002de:	83 e8 23             	sub    $0x23,%eax
  8002e1:	3c 55                	cmp    $0x55,%al
  8002e3:	0f 87 d3 03 00 00    	ja     8006bc <vprintfmt+0x443>
  8002e9:	0f b6 c0             	movzbl %al,%eax
  8002ec:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fa:	eb d6                	jmp    8002d2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800304:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800307:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800311:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800314:	83 f9 09             	cmp    $0x9,%ecx
  800317:	77 3f                	ja     800358 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800319:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031c:	eb e9                	jmp    800307 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031e:	8b 45 14             	mov    0x14(%ebp),%eax
  800321:	8b 00                	mov    (%eax),%eax
  800323:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800326:	8b 45 14             	mov    0x14(%ebp),%eax
  800329:	8d 40 04             	lea    0x4(%eax),%eax
  80032c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800332:	eb 2a                	jmp    80035e <vprintfmt+0xe5>
  800334:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800337:	85 c0                	test   %eax,%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	0f 49 d0             	cmovns %eax,%edx
  800341:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800347:	eb 89                	jmp    8002d2 <vprintfmt+0x59>
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800353:	e9 7a ff ff ff       	jmp    8002d2 <vprintfmt+0x59>
  800358:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800362:	0f 89 6a ff ff ff    	jns    8002d2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800368:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800375:	e9 58 ff ff ff       	jmp    8002d2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800380:	e9 4d ff ff ff       	jmp    8002d2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 78 04             	lea    0x4(%eax),%edi
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	53                   	push   %ebx
  80038f:	ff 30                	pushl  (%eax)
  800391:	ff d6                	call   *%esi
			break;
  800393:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800396:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039c:	e9 fe fe ff ff       	jmp    80029f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 78 04             	lea    0x4(%eax),%edi
  8003a7:	8b 00                	mov    (%eax),%eax
  8003a9:	99                   	cltd   
  8003aa:	31 d0                	xor    %edx,%eax
  8003ac:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ae:	83 f8 09             	cmp    $0x9,%eax
  8003b1:	7f 0b                	jg     8003be <vprintfmt+0x145>
  8003b3:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  8003ba:	85 d2                	test   %edx,%edx
  8003bc:	75 1b                	jne    8003d9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003be:	50                   	push   %eax
  8003bf:	68 ca 10 80 00       	push   $0x8010ca
  8003c4:	53                   	push   %ebx
  8003c5:	56                   	push   %esi
  8003c6:	e8 91 fe ff ff       	call   80025c <printfmt>
  8003cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d4:	e9 c6 fe ff ff       	jmp    80029f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d9:	52                   	push   %edx
  8003da:	68 d3 10 80 00       	push   $0x8010d3
  8003df:	53                   	push   %ebx
  8003e0:	56                   	push   %esi
  8003e1:	e8 76 fe ff ff       	call   80025c <printfmt>
  8003e6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	e9 ab fe ff ff       	jmp    80029f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	83 c0 04             	add    $0x4,%eax
  8003fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800402:	85 ff                	test   %edi,%edi
  800404:	b8 c3 10 80 00       	mov    $0x8010c3,%eax
  800409:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800410:	0f 8e 94 00 00 00    	jle    8004aa <vprintfmt+0x231>
  800416:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041a:	0f 84 98 00 00 00    	je     8004b8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 d0             	pushl  -0x30(%ebp)
  800426:	57                   	push   %edi
  800427:	e8 33 03 00 00       	call   80075f <strnlen>
  80042c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042f:	29 c1                	sub    %eax,%ecx
  800431:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800434:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800437:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800441:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	eb 0f                	jmp    800454 <vprintfmt+0x1db>
					putch(padc, putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	53                   	push   %ebx
  800449:	ff 75 e0             	pushl  -0x20(%ebp)
  80044c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	83 ef 01             	sub    $0x1,%edi
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 ff                	test   %edi,%edi
  800456:	7f ed                	jg     800445 <vprintfmt+0x1cc>
  800458:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045e:	85 c9                	test   %ecx,%ecx
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	0f 49 c1             	cmovns %ecx,%eax
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	89 cb                	mov    %ecx,%ebx
  800475:	eb 4d                	jmp    8004c4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047b:	74 1b                	je     800498 <vprintfmt+0x21f>
  80047d:	0f be c0             	movsbl %al,%eax
  800480:	83 e8 20             	sub    $0x20,%eax
  800483:	83 f8 5e             	cmp    $0x5e,%eax
  800486:	76 10                	jbe    800498 <vprintfmt+0x21f>
					putch('?', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	6a 3f                	push   $0x3f
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	eb 0d                	jmp    8004a5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	52                   	push   %edx
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	eb 1a                	jmp    8004c4 <vprintfmt+0x24b>
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b6:	eb 0c                	jmp    8004c4 <vprintfmt+0x24b>
  8004b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cb:	0f be d0             	movsbl %al,%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 23                	je     8004f5 <vprintfmt+0x27c>
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	78 a1                	js     800477 <vprintfmt+0x1fe>
  8004d6:	83 ee 01             	sub    $0x1,%esi
  8004d9:	79 9c                	jns    800477 <vprintfmt+0x1fe>
  8004db:	89 df                	mov    %ebx,%edi
  8004dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e3:	eb 18                	jmp    8004fd <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	6a 20                	push   $0x20
  8004eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 08                	jmp    8004fd <vprintfmt+0x284>
  8004f5:	89 df                	mov    %ebx,%edi
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f e4                	jg     8004e5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800501:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800504:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050a:	e9 90 fd ff ff       	jmp    80029f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050f:	83 f9 01             	cmp    $0x1,%ecx
  800512:	7e 19                	jle    80052d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8b 50 04             	mov    0x4(%eax),%edx
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 40 08             	lea    0x8(%eax),%eax
  800528:	89 45 14             	mov    %eax,0x14(%ebp)
  80052b:	eb 38                	jmp    800565 <vprintfmt+0x2ec>
	else if (lflag)
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	74 1b                	je     80054c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 40 04             	lea    0x4(%eax),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
  80054a:	eb 19                	jmp    800565 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 c1                	mov    %eax,%ecx
  800556:	c1 f9 1f             	sar    $0x1f,%ecx
  800559:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 40 04             	lea    0x4(%eax),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800565:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800568:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	0f 89 0e 01 00 00    	jns    800688 <vprintfmt+0x40f>
				putch('-', putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	6a 2d                	push   $0x2d
  800580:	ff d6                	call   *%esi
				num = -(long long) num;
  800582:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800585:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800588:	f7 da                	neg    %edx
  80058a:	83 d1 00             	adc    $0x0,%ecx
  80058d:	f7 d9                	neg    %ecx
  80058f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 ec 00 00 00       	jmp    800688 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7e 18                	jle    8005b9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 cf 00 00 00       	jmp    800688 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	74 1a                	je     8005d7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 b1 00 00 00       	jmp    800688 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 97 00 00 00       	jmp    800688 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 58                	push   $0x58
  8005f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f9:	83 c4 08             	add    $0x8,%esp
  8005fc:	53                   	push   %ebx
  8005fd:	6a 58                	push   $0x58
  8005ff:	ff d6                	call   *%esi
			putch('X', putdat);
  800601:	83 c4 08             	add    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 58                	push   $0x58
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80060f:	e9 8b fc ff ff       	jmp    80029f <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 30                	push   $0x30
  80061a:	ff d6                	call   *%esi
			putch('x', putdat);
  80061c:	83 c4 08             	add    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 78                	push   $0x78
  800622:	ff d6                	call   *%esi
			num = (unsigned long long)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063c:	eb 4a                	jmp    800688 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063e:	83 f9 01             	cmp    $0x1,%ecx
  800641:	7e 15                	jle    800658 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	8b 48 04             	mov    0x4(%eax),%ecx
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800651:	b8 10 00 00 00       	mov    $0x10,%eax
  800656:	eb 30                	jmp    800688 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	74 17                	je     800673 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
  800671:	eb 15                	jmp    800688 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068f:	57                   	push   %edi
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	50                   	push   %eax
  800694:	51                   	push   %ecx
  800695:	52                   	push   %edx
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f0                	mov    %esi,%eax
  80069a:	e8 f1 fa ff ff       	call   800190 <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 f5 fb ff ff       	jmp    80029f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	52                   	push   %edx
  8006af:	ff d6                	call   *%esi
			break;
  8006b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b7:	e9 e3 fb ff ff       	jmp    80029f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 03                	jmp    8006cc <vprintfmt+0x453>
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d0:	75 f7                	jne    8006c9 <vprintfmt+0x450>
  8006d2:	e9 c8 fb ff ff       	jmp    80029f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x47>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 22                	jle    800726 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 3f 02 80 00       	push   $0x80023f
  800713:	e8 61 fb ff ff       	call   800279 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 05                	jmp    80072b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	50                   	push   %eax
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	ff 75 08             	pushl  0x8(%ebp)
  800740:	e8 9a ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strlen+0x10>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075b:	75 f7                	jne    800754 <strlen+0xd>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
  80076d:	eb 03                	jmp    800772 <strnlen+0x13>
		n++;
  80076f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	39 c2                	cmp    %eax,%edx
  800774:	74 08                	je     80077e <strnlen+0x1f>
  800776:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077a:	75 f3                	jne    80076f <strnlen+0x10>
  80077c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078a:	89 c2                	mov    %eax,%edx
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800796:	88 5a ff             	mov    %bl,-0x1(%edx)
  800799:	84 db                	test   %bl,%bl
  80079b:	75 ef                	jne    80078c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a7:	53                   	push   %ebx
  8007a8:	e8 9a ff ff ff       	call   800747 <strlen>
  8007ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 c5 ff ff ff       	call   800780 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
		*dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ff:	85 d2                	test   %edx,%edx
  800801:	74 21                	je     800824 <strlcpy+0x35>
  800803:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 09                	jmp    800814 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 09                	je     800821 <strlcpy+0x32>
  800818:	0f b6 19             	movzbl (%ecx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ec                	jne    80080b <strlcpy+0x1c>
  80081f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 06                	jmp    80083b <strcmp+0x11>
		p++, q++;
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1c>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ef                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strncmp+0x17>
		n--, p++, q++;
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 15                	je     800880 <strncmp+0x30>
  80086b:	0f b6 08             	movzbl (%eax),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x26>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 eb                	je     800861 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
  80087e:	eb 05                	jmp    800885 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 07                	jmp    80089b <strchr+0x13>
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 0f                	je     8008a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 03                	jmp    8008b8 <strfind+0xf>
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 04                	je     8008c3 <strfind+0x1a>
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 36                	je     80090b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 28                	jne    800905 <memset+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 23                	jne    800905 <memset+0x40>
		c &= 0xFF;
  8008e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d3                	mov    %edx,%ebx
  8008e8:	c1 e3 08             	shl    $0x8,%ebx
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	c1 e6 18             	shl    $0x18,%esi
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 10             	shl    $0x10,%eax
  8008f5:	09 f0                	or     %esi,%eax
  8008f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	09 d0                	or     %edx,%eax
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 35                	jae    800959 <memmove+0x47>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 d0                	cmp    %edx,%eax
  800929:	73 2e                	jae    800959 <memmove+0x47>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	75 13                	jne    80094d <memmove+0x3b>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0e                	jne    80094d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093f:	83 ef 04             	sub    $0x4,%edi
  800942:	8d 72 fc             	lea    -0x4(%edx),%esi
  800945:	c1 e9 02             	shr    $0x2,%ecx
  800948:	fd                   	std    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 09                	jmp    800956 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094d:	83 ef 01             	sub    $0x1,%edi
  800950:	8d 72 ff             	lea    -0x1(%edx),%esi
  800953:	fd                   	std    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800956:	fc                   	cld    
  800957:	eb 1d                	jmp    800976 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 f2                	mov    %esi,%edx
  80095b:	09 c2                	or     %eax,%edx
  80095d:	f6 c2 03             	test   $0x3,%dl
  800960:	75 0f                	jne    800971 <memmove+0x5f>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0a                	jne    800971 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 05                	jmp    800976 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097d:	ff 75 10             	pushl  0x10(%ebp)
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	ff 75 08             	pushl  0x8(%ebp)
  800986:	e8 87 ff ff ff       	call   800912 <memmove>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 c6                	mov    %eax,%esi
  80099a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099d:	eb 1a                	jmp    8009b9 <memcmp+0x2c>
		if (*s1 != *s2)
  80099f:	0f b6 08             	movzbl (%eax),%ecx
  8009a2:	0f b6 1a             	movzbl (%edx),%ebx
  8009a5:	38 d9                	cmp    %bl,%cl
  8009a7:	74 0a                	je     8009b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c1             	movzbl %cl,%eax
  8009ac:	0f b6 db             	movzbl %bl,%ebx
  8009af:	29 d8                	sub    %ebx,%eax
  8009b1:	eb 0f                	jmp    8009c2 <memcmp+0x35>
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	39 f0                	cmp    %esi,%eax
  8009bb:	75 e2                	jne    80099f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cd:	89 c1                	mov    %eax,%ecx
  8009cf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	eb 0a                	jmp    8009e2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	74 07                	je     8009e6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	39 c8                	cmp    %ecx,%eax
  8009e4:	72 f2                	jb     8009d8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	eb 03                	jmp    8009fa <strtol+0x11>
		s++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f6                	je     8009f7 <strtol+0xe>
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f2                	je     8009f7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a05:	3c 2b                	cmp    $0x2b,%al
  800a07:	75 0a                	jne    800a13 <strtol+0x2a>
		s++;
  800a09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a11:	eb 11                	jmp    800a24 <strtol+0x3b>
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	75 08                	jne    800a24 <strtol+0x3b>
		s++, neg = 1;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2a:	75 15                	jne    800a41 <strtol+0x58>
  800a2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2f:	75 10                	jne    800a41 <strtol+0x58>
  800a31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a35:	75 7c                	jne    800ab3 <strtol+0xca>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb 16                	jmp    800a57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	75 12                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 08                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x8b>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb 22                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb 10                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 16                	ja     800aa6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 0b                	jge    800aa6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa4:	eb b9                	jmp    800a5f <strtol+0x76>

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 0d                	je     800ab9 <strtol+0xd0>
		*endptr = (char *) s;
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	89 0e                	mov    %ecx,(%esi)
  800ab1:	eb 06                	jmp    800ab9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	74 98                	je     800a4f <strtol+0x66>
  800ab7:	eb 9e                	jmp    800a57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	f7 da                	neg    %edx
  800abd:	85 ff                	test   %edi,%edi
  800abf:	0f 45 c2             	cmovne %edx,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7e 17                	jle    800b3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	50                   	push   %eax
  800b2a:	6a 03                	push   $0x3
  800b2c:	68 08 13 80 00       	push   $0x801308
  800b31:	6a 23                	push   $0x23
  800b33:	68 25 13 80 00       	push   $0x801325
  800b38:	e8 5c 02 00 00       	call   800d99 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	b8 04 00 00 00       	mov    $0x4,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 04                	push   $0x4
  800bad:	68 08 13 80 00       	push   $0x801308
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 25 13 80 00       	push   $0x801325
  800bb9:	e8 db 01 00 00       	call   800d99 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 05                	push   $0x5
  800bef:	68 08 13 80 00       	push   $0x801308
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 25 13 80 00       	push   $0x801325
  800bfb:	e8 99 01 00 00       	call   800d99 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 06                	push   $0x6
  800c31:	68 08 13 80 00       	push   $0x801308
  800c36:	6a 23                	push   $0x23
  800c38:	68 25 13 80 00       	push   $0x801325
  800c3d:	e8 57 01 00 00       	call   800d99 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 08                	push   $0x8
  800c73:	68 08 13 80 00       	push   $0x801308
  800c78:	6a 23                	push   $0x23
  800c7a:	68 25 13 80 00       	push   $0x801325
  800c7f:	e8 15 01 00 00       	call   800d99 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 09                	push   $0x9
  800cb5:	68 08 13 80 00       	push   $0x801308
  800cba:	6a 23                	push   $0x23
  800cbc:	68 25 13 80 00       	push   $0x801325
  800cc1:	e8 d3 00 00 00       	call   800d99 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0c                	push   $0xc
  800d19:	68 08 13 80 00       	push   $0x801308
  800d1e:	6a 23                	push   $0x23
  800d20:	68 25 13 80 00       	push   $0x801325
  800d25:	e8 6f 00 00 00       	call   800d99 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d38:	68 33 13 80 00       	push   $0x801333
  800d3d:	6a 1a                	push   $0x1a
  800d3f:	68 4c 13 80 00       	push   $0x80134c
  800d44:	e8 50 00 00 00       	call   800d99 <_panic>

00800d49 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d4f:	68 56 13 80 00       	push   $0x801356
  800d54:	6a 2a                	push   $0x2a
  800d56:	68 4c 13 80 00       	push   $0x80134c
  800d5b:	e8 39 00 00 00       	call   800d99 <_panic>

00800d60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d74:	8b 52 50             	mov    0x50(%edx),%edx
  800d77:	39 ca                	cmp    %ecx,%edx
  800d79:	75 0d                	jne    800d88 <ipc_find_env+0x28>
			return envs[i].env_id;
  800d7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800d7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d83:	8b 40 48             	mov    0x48(%eax),%eax
  800d86:	eb 0f                	jmp    800d97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d88:	83 c0 01             	add    $0x1,%eax
  800d8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d90:	75 d9                	jne    800d6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d9e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800da1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800da7:	e8 99 fd ff ff       	call   800b45 <sys_getenvid>
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	ff 75 08             	pushl  0x8(%ebp)
  800db5:	56                   	push   %esi
  800db6:	50                   	push   %eax
  800db7:	68 70 13 80 00       	push   $0x801370
  800dbc:	e8 bb f3 ff ff       	call   80017c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc1:	83 c4 18             	add    $0x18,%esp
  800dc4:	53                   	push   %ebx
  800dc5:	ff 75 10             	pushl  0x10(%ebp)
  800dc8:	e8 5e f3 ff ff       	call   80012b <vcprintf>
	cprintf("\n");
  800dcd:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  800dd4:	e8 a3 f3 ff ff       	call   80017c <cprintf>
  800dd9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ddc:	cc                   	int3   
  800ddd:	eb fd                	jmp    800ddc <_panic+0x43>
  800ddf:	90                   	nop

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800deb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800def:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df7:	85 f6                	test   %esi,%esi
  800df9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dfd:	89 ca                	mov    %ecx,%edx
  800dff:	89 f8                	mov    %edi,%eax
  800e01:	75 3d                	jne    800e40 <__udivdi3+0x60>
  800e03:	39 cf                	cmp    %ecx,%edi
  800e05:	0f 87 c5 00 00 00    	ja     800ed0 <__udivdi3+0xf0>
  800e0b:	85 ff                	test   %edi,%edi
  800e0d:	89 fd                	mov    %edi,%ebp
  800e0f:	75 0b                	jne    800e1c <__udivdi3+0x3c>
  800e11:	b8 01 00 00 00       	mov    $0x1,%eax
  800e16:	31 d2                	xor    %edx,%edx
  800e18:	f7 f7                	div    %edi
  800e1a:	89 c5                	mov    %eax,%ebp
  800e1c:	89 c8                	mov    %ecx,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f5                	div    %ebp
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	89 d8                	mov    %ebx,%eax
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	f7 f5                	div    %ebp
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	89 d8                	mov    %ebx,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 1c             	add    $0x1c,%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 ce                	cmp    %ecx,%esi
  800e42:	77 74                	ja     800eb8 <__udivdi3+0xd8>
  800e44:	0f bd fe             	bsr    %esi,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0x108>
  800e50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	89 c5                	mov    %eax,%ebp
  800e59:	29 fb                	sub    %edi,%ebx
  800e5b:	d3 e6                	shl    %cl,%esi
  800e5d:	89 d9                	mov    %ebx,%ecx
  800e5f:	d3 ed                	shr    %cl,%ebp
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e0                	shl    %cl,%eax
  800e65:	09 ee                	or     %ebp,%esi
  800e67:	89 d9                	mov    %ebx,%ecx
  800e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6d:	89 d5                	mov    %edx,%ebp
  800e6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e73:	d3 ed                	shr    %cl,%ebp
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e2                	shl    %cl,%edx
  800e79:	89 d9                	mov    %ebx,%ecx
  800e7b:	d3 e8                	shr    %cl,%eax
  800e7d:	09 c2                	or     %eax,%edx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	89 ea                	mov    %ebp,%edx
  800e83:	f7 f6                	div    %esi
  800e85:	89 d5                	mov    %edx,%ebp
  800e87:	89 c3                	mov    %eax,%ebx
  800e89:	f7 64 24 0c          	mull   0xc(%esp)
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	72 10                	jb     800ea1 <__udivdi3+0xc1>
  800e91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e6                	shl    %cl,%esi
  800e99:	39 c6                	cmp    %eax,%esi
  800e9b:	73 07                	jae    800ea4 <__udivdi3+0xc4>
  800e9d:	39 d5                	cmp    %edx,%ebp
  800e9f:	75 03                	jne    800ea4 <__udivdi3+0xc4>
  800ea1:	83 eb 01             	sub    $0x1,%ebx
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	89 fa                	mov    %edi,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	31 ff                	xor    %edi,%edi
  800eba:	31 db                	xor    %ebx,%ebx
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
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	f7 f7                	div    %edi
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 c3                	mov    %eax,%ebx
  800ed8:	89 d8                	mov    %ebx,%eax
  800eda:	89 fa                	mov    %edi,%edx
  800edc:	83 c4 1c             	add    $0x1c,%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	39 ce                	cmp    %ecx,%esi
  800eea:	72 0c                	jb     800ef8 <__udivdi3+0x118>
  800eec:	31 db                	xor    %ebx,%ebx
  800eee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ef2:	0f 87 34 ff ff ff    	ja     800e2c <__udivdi3+0x4c>
  800ef8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800efd:	e9 2a ff ff ff       	jmp    800e2c <__udivdi3+0x4c>
  800f02:	66 90                	xchg   %ax,%ax
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 d2                	test   %edx,%edx
  800f29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 f3                	mov    %esi,%ebx
  800f33:	89 3c 24             	mov    %edi,(%esp)
  800f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3a:	75 1c                	jne    800f58 <__umoddi3+0x48>
  800f3c:	39 f7                	cmp    %esi,%edi
  800f3e:	76 50                	jbe    800f90 <__umoddi3+0x80>
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	f7 f7                	div    %edi
  800f46:	89 d0                	mov    %edx,%eax
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	77 52                	ja     800fb0 <__umoddi3+0xa0>
  800f5e:	0f bd ea             	bsr    %edx,%ebp
  800f61:	83 f5 1f             	xor    $0x1f,%ebp
  800f64:	75 5a                	jne    800fc0 <__umoddi3+0xb0>
  800f66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	39 0c 24             	cmp    %ecx,(%esp)
  800f73:	0f 86 d7 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f81:	83 c4 1c             	add    $0x1c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	85 ff                	test   %edi,%edi
  800f92:	89 fd                	mov    %edi,%ebp
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 c8                	mov    %ecx,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	eb 99                	jmp    800f48 <__umoddi3+0x38>
  800faf:	90                   	nop
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	83 c4 1c             	add    $0x1c,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	8b 34 24             	mov    (%esp),%esi
  800fc3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	29 ef                	sub    %ebp,%edi
  800fcc:	d3 e0                	shl    %cl,%eax
  800fce:	89 f9                	mov    %edi,%ecx
  800fd0:	89 f2                	mov    %esi,%edx
  800fd2:	d3 ea                	shr    %cl,%edx
  800fd4:	89 e9                	mov    %ebp,%ecx
  800fd6:	09 c2                	or     %eax,%edx
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	89 14 24             	mov    %edx,(%esp)
  800fdd:	89 f2                	mov    %esi,%edx
  800fdf:	d3 e2                	shl    %cl,%edx
  800fe1:	89 f9                	mov    %edi,%ecx
  800fe3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800feb:	d3 e8                	shr    %cl,%eax
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	d3 e3                	shl    %cl,%ebx
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 d0                	mov    %edx,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	09 d8                	or     %ebx,%eax
  800ffd:	89 d3                	mov    %edx,%ebx
  800fff:	89 f2                	mov    %esi,%edx
  801001:	f7 34 24             	divl   (%esp)
  801004:	89 d6                	mov    %edx,%esi
  801006:	d3 e3                	shl    %cl,%ebx
  801008:	f7 64 24 04          	mull   0x4(%esp)
  80100c:	39 d6                	cmp    %edx,%esi
  80100e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801012:	89 d1                	mov    %edx,%ecx
  801014:	89 c3                	mov    %eax,%ebx
  801016:	72 08                	jb     801020 <__umoddi3+0x110>
  801018:	75 11                	jne    80102b <__umoddi3+0x11b>
  80101a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80101e:	73 0b                	jae    80102b <__umoddi3+0x11b>
  801020:	2b 44 24 04          	sub    0x4(%esp),%eax
  801024:	1b 14 24             	sbb    (%esp),%edx
  801027:	89 d1                	mov    %edx,%ecx
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80102f:	29 da                	sub    %ebx,%edx
  801031:	19 ce                	sbb    %ecx,%esi
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 f0                	mov    %esi,%eax
  801037:	d3 e0                	shl    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	d3 ea                	shr    %cl,%edx
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	d3 ee                	shr    %cl,%esi
  801041:	09 d0                	or     %edx,%eax
  801043:	89 f2                	mov    %esi,%edx
  801045:	83 c4 1c             	add    $0x1c,%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 f9                	sub    %edi,%ecx
  801052:	19 d6                	sbb    %edx,%esi
  801054:	89 74 24 04          	mov    %esi,0x4(%esp)
  801058:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105c:	e9 18 ff ff ff       	jmp    800f79 <__umoddi3+0x69>
