
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 43 0b 00 00       	call   800b85 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 80 10 80 00       	push   $0x801080
  80004c:	e8 6b 01 00 00       	call   8001bc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 04 07 00 00       	call   800787 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 91 10 80 00       	push   $0x801091
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 c8 06 00 00       	call   80076d <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 c5 0c 00 00       	call   800d72 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 55 00 00 00       	call   800117 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 90 10 80 00       	push   $0x801090
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ed:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000f4:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 08                	jle    800103 <libmain+0x22>
		binaryname = argv[0];
  8000fb:	8b 0a                	mov    (%edx),%ecx
  8000fd:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	52                   	push   %edx
  800107:	50                   	push   %eax
  800108:	e8 bf ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80010d:	e8 05 00 00 00       	call   800117 <exit>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011d:	6a 00                	push   $0x0
  80011f:	e8 20 0a 00 00       	call   800b44 <sys_env_destroy>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	53                   	push   %ebx
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800133:	8b 13                	mov    (%ebx),%edx
  800135:	8d 42 01             	lea    0x1(%edx),%eax
  800138:	89 03                	mov    %eax,(%ebx)
  80013a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800141:	3d ff 00 00 00       	cmp    $0xff,%eax
  800146:	75 1a                	jne    800162 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	68 ff 00 00 00       	push   $0xff
  800150:	8d 43 08             	lea    0x8(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 ae 09 00 00       	call   800b07 <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800162:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017b:	00 00 00 
	b.cnt = 0;
  80017e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800188:	ff 75 0c             	pushl  0xc(%ebp)
  80018b:	ff 75 08             	pushl  0x8(%ebp)
  80018e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	68 29 01 80 00       	push   $0x800129
  80019a:	e8 1a 01 00 00       	call   8002b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019f:	83 c4 08             	add    $0x8,%esp
  8001a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 53 09 00 00       	call   800b07 <sys_cputs>

	return b.cnt;
}
  8001b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	e8 9d ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 1c             	sub    $0x1c,%esp
  8001d9:	89 c7                	mov    %eax,%edi
  8001db:	89 d6                	mov    %edx,%esi
  8001dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f7:	39 d3                	cmp    %edx,%ebx
  8001f9:	72 05                	jb     800200 <printnum+0x30>
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	77 45                	ja     800245 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	ff 75 18             	pushl  0x18(%ebp)
  800206:	8b 45 14             	mov    0x14(%ebp),%eax
  800209:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020c:	53                   	push   %ebx
  80020d:	ff 75 10             	pushl  0x10(%ebp)
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	ff 75 e4             	pushl  -0x1c(%ebp)
  800216:	ff 75 e0             	pushl  -0x20(%ebp)
  800219:	ff 75 dc             	pushl  -0x24(%ebp)
  80021c:	ff 75 d8             	pushl  -0x28(%ebp)
  80021f:	e8 cc 0b 00 00       	call   800df0 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	89 f2                	mov    %esi,%edx
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	e8 9e ff ff ff       	call   8001d0 <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 18                	jmp    80024f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	eb 03                	jmp    800248 <printnum+0x78>
  800245:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800248:	83 eb 01             	sub    $0x1,%ebx
  80024b:	85 db                	test   %ebx,%ebx
  80024d:	7f e8                	jg     800237 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	83 ec 04             	sub    $0x4,%esp
  800256:	ff 75 e4             	pushl  -0x1c(%ebp)
  800259:	ff 75 e0             	pushl  -0x20(%ebp)
  80025c:	ff 75 dc             	pushl  -0x24(%ebp)
  80025f:	ff 75 d8             	pushl  -0x28(%ebp)
  800262:	e8 b9 0c 00 00       	call   800f20 <__umoddi3>
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	0f be 80 a0 10 80 00 	movsbl 0x8010a0(%eax),%eax
  800271:	50                   	push   %eax
  800272:	ff d7                	call   *%edi
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800285:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	3b 50 04             	cmp    0x4(%eax),%edx
  80028e:	73 0a                	jae    80029a <sprintputch+0x1b>
		*b->buf++ = ch;
  800290:	8d 4a 01             	lea    0x1(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	88 02                	mov    %al,(%edx)
}
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	e8 05 00 00 00       	call   8002b9 <vprintfmt>
	va_end(ap);
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	57                   	push   %edi
  8002bd:	56                   	push   %esi
  8002be:	53                   	push   %ebx
  8002bf:	83 ec 2c             	sub    $0x2c,%esp
  8002c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cb:	eb 12                	jmp    8002df <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	0f 84 42 04 00 00    	je     800717 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	53                   	push   %ebx
  8002d9:	50                   	push   %eax
  8002da:	ff d6                	call   *%esi
  8002dc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002df:	83 c7 01             	add    $0x1,%edi
  8002e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e6:	83 f8 25             	cmp    $0x25,%eax
  8002e9:	75 e2                	jne    8002cd <vprintfmt+0x14>
  8002eb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800304:	b9 00 00 00 00       	mov    $0x0,%ecx
  800309:	eb 07                	jmp    800312 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8d 47 01             	lea    0x1(%edi),%eax
  800315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800318:	0f b6 07             	movzbl (%edi),%eax
  80031b:	0f b6 d0             	movzbl %al,%edx
  80031e:	83 e8 23             	sub    $0x23,%eax
  800321:	3c 55                	cmp    $0x55,%al
  800323:	0f 87 d3 03 00 00    	ja     8006fc <vprintfmt+0x443>
  800329:	0f b6 c0             	movzbl %al,%eax
  80032c:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800336:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033a:	eb d6                	jmp    800312 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033f:	b8 00 00 00 00       	mov    $0x0,%eax
  800344:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800347:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800351:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800354:	83 f9 09             	cmp    $0x9,%ecx
  800357:	77 3f                	ja     800398 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800359:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035c:	eb e9                	jmp    800347 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8b 00                	mov    (%eax),%eax
  800363:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 40 04             	lea    0x4(%eax),%eax
  80036c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800372:	eb 2a                	jmp    80039e <vprintfmt+0xe5>
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	85 c0                	test   %eax,%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	0f 49 d0             	cmovns %eax,%edx
  800381:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800387:	eb 89                	jmp    800312 <vprintfmt+0x59>
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800393:	e9 7a ff ff ff       	jmp    800312 <vprintfmt+0x59>
  800398:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a2:	0f 89 6a ff ff ff    	jns    800312 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b5:	e9 58 ff ff ff       	jmp    800312 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ba:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c0:	e9 4d ff ff ff       	jmp    800312 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 78 04             	lea    0x4(%eax),%edi
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	53                   	push   %ebx
  8003cf:	ff 30                	pushl  (%eax)
  8003d1:	ff d6                	call   *%esi
			break;
  8003d3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003dc:	e9 fe fe ff ff       	jmp    8002df <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	99                   	cltd   
  8003ea:	31 d0                	xor    %edx,%eax
  8003ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ee:	83 f8 09             	cmp    $0x9,%eax
  8003f1:	7f 0b                	jg     8003fe <vprintfmt+0x145>
  8003f3:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	75 1b                	jne    800419 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003fe:	50                   	push   %eax
  8003ff:	68 b8 10 80 00       	push   $0x8010b8
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 91 fe ff ff       	call   80029c <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800414:	e9 c6 fe ff ff       	jmp    8002df <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800419:	52                   	push   %edx
  80041a:	68 c1 10 80 00       	push   $0x8010c1
  80041f:	53                   	push   %ebx
  800420:	56                   	push   %esi
  800421:	e8 76 fe ff ff       	call   80029c <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800429:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042f:	e9 ab fe ff ff       	jmp    8002df <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	83 c0 04             	add    $0x4,%eax
  80043a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800442:	85 ff                	test   %edi,%edi
  800444:	b8 b1 10 80 00       	mov    $0x8010b1,%eax
  800449:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800450:	0f 8e 94 00 00 00    	jle    8004ea <vprintfmt+0x231>
  800456:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80045a:	0f 84 98 00 00 00    	je     8004f8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 d0             	pushl  -0x30(%ebp)
  800466:	57                   	push   %edi
  800467:	e8 33 03 00 00       	call   80079f <strnlen>
  80046c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046f:	29 c1                	sub    %eax,%ecx
  800471:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800477:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800481:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0f                	jmp    800494 <vprintfmt+0x1db>
					putch(padc, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	ff 75 e0             	pushl  -0x20(%ebp)
  80048c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	83 ef 01             	sub    $0x1,%edi
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 ff                	test   %edi,%edi
  800496:	7f ed                	jg     800485 <vprintfmt+0x1cc>
  800498:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c1             	cmovns %ecx,%eax
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	89 cb                	mov    %ecx,%ebx
  8004b5:	eb 4d                	jmp    800504 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bb:	74 1b                	je     8004d8 <vprintfmt+0x21f>
  8004bd:	0f be c0             	movsbl %al,%eax
  8004c0:	83 e8 20             	sub    $0x20,%eax
  8004c3:	83 f8 5e             	cmp    $0x5e,%eax
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x21f>
					putch('?', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ce:	6a 3f                	push   $0x3f
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	eb 0d                	jmp    8004e5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	52                   	push   %edx
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e5:	83 eb 01             	sub    $0x1,%ebx
  8004e8:	eb 1a                	jmp    800504 <vprintfmt+0x24b>
  8004ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f6:	eb 0c                	jmp    800504 <vprintfmt+0x24b>
  8004f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800501:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050b:	0f be d0             	movsbl %al,%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	74 23                	je     800535 <vprintfmt+0x27c>
  800512:	85 f6                	test   %esi,%esi
  800514:	78 a1                	js     8004b7 <vprintfmt+0x1fe>
  800516:	83 ee 01             	sub    $0x1,%esi
  800519:	79 9c                	jns    8004b7 <vprintfmt+0x1fe>
  80051b:	89 df                	mov    %ebx,%edi
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800523:	eb 18                	jmp    80053d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb 08                	jmp    80053d <vprintfmt+0x284>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f e4                	jg     800525 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800541:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 90 fd ff ff       	jmp    8002df <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 f9 01             	cmp    $0x1,%ecx
  800552:	7e 19                	jle    80056d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 50 04             	mov    0x4(%eax),%edx
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 40 08             	lea    0x8(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	eb 38                	jmp    8005a5 <vprintfmt+0x2ec>
	else if (lflag)
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	74 1b                	je     80058c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb 19                	jmp    8005a5 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b4:	0f 89 0e 01 00 00    	jns    8006c8 <vprintfmt+0x40f>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c8:	f7 da                	neg    %edx
  8005ca:	83 d1 00             	adc    $0x0,%ecx
  8005cd:	f7 d9                	neg    %ecx
  8005cf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 ec 00 00 00       	jmp    8006c8 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dc:	83 f9 01             	cmp    $0x1,%ecx
  8005df:	7e 18                	jle    8005f9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	e9 cf 00 00 00       	jmp    8006c8 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005f9:	85 c9                	test   %ecx,%ecx
  8005fb:	74 1a                	je     800617 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 10                	mov    (%eax),%edx
  800602:	b9 00 00 00 00       	mov    $0x0,%ecx
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	e9 b1 00 00 00       	jmp    8006c8 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	e9 97 00 00 00       	jmp    8006c8 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 58                	push   $0x58
  800637:	ff d6                	call   *%esi
			putch('X', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 58                	push   $0x58
  80063f:	ff d6                	call   *%esi
			putch('X', putdat);
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 58                	push   $0x58
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80064f:	e9 8b fc ff ff       	jmp    8002df <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 30                	push   $0x30
  80065a:	ff d6                	call   *%esi
			putch('x', putdat);
  80065c:	83 c4 08             	add    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 78                	push   $0x78
  800662:	ff d6                	call   *%esi
			num = (unsigned long long)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067c:	eb 4a                	jmp    8006c8 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067e:	83 f9 01             	cmp    $0x1,%ecx
  800681:	7e 15                	jle    800698 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800691:	b8 10 00 00 00       	mov    $0x10,%eax
  800696:	eb 30                	jmp    8006c8 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 17                	je     8006b3 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b1:	eb 15                	jmp    8006c8 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cf:	57                   	push   %edi
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 f1 fa ff ff       	call   8001d0 <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 f5 fb ff ff       	jmp    8002df <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	52                   	push   %edx
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f7:	e9 e3 fb ff ff       	jmp    8002df <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 25                	push   $0x25
  800702:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 03                	jmp    80070c <vprintfmt+0x453>
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800710:	75 f7                	jne    800709 <vprintfmt+0x450>
  800712:	e9 c8 fb ff ff       	jmp    8002df <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 7f 02 80 00       	push   $0x80027f
  800753:	e8 61 fb ff ff       	call   8002b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 05                	jmp    80076b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 9a ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 c2                	cmp    %eax,%edx
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d9:	84 db                	test   %bl,%bl
  8007db:	75 ef                	jne    8007cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e7:	53                   	push   %ebx
  8007e8:	e8 9a ff ff ff       	call   800787 <strlen>
  8007ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c5 ff ff ff       	call   8007c0 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 10             	mov    0x10(%ebp),%edx
  80083d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 21                	je     800864 <strlcpy+0x35>
  800843:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 09                	jmp    800854 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 c2                	cmp    %eax,%edx
  800856:	74 09                	je     800861 <strlcpy+0x32>
  800858:	0f b6 19             	movzbl (%ecx),%ebx
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ec                	jne    80084b <strlcpy+0x1c>
  80085f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800864:	29 f0                	sub    %esi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800873:	eb 06                	jmp    80087b <strcmp+0x11>
		p++, q++;
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1c>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 ef                	je     800875 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	89 c3                	mov    %eax,%ebx
  80089c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strncmp+0x17>
		n--, p++, q++;
  8008a1:	83 c0 01             	add    $0x1,%eax
  8008a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 15                	je     8008c0 <strncmp+0x30>
  8008ab:	0f b6 08             	movzbl (%eax),%ecx
  8008ae:	84 c9                	test   %cl,%cl
  8008b0:	74 04                	je     8008b6 <strncmp+0x26>
  8008b2:	3a 0a                	cmp    (%edx),%cl
  8008b4:	74 eb                	je     8008a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 00             	movzbl (%eax),%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
  8008be:	eb 05                	jmp    8008c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 07                	jmp    8008db <strchr+0x13>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 0f                	je     8008e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	75 f2                	jne    8008d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	eb 03                	jmp    8008f8 <strfind+0xf>
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 04                	je     800903 <strfind+0x1a>
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 36                	je     80094b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 28                	jne    800945 <memset+0x40>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 23                	jne    800945 <memset+0x40>
		c &= 0xFF;
  800922:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 08             	shl    $0x8,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 18             	shl    $0x18,%esi
  800930:	89 d0                	mov    %edx,%eax
  800932:	c1 e0 10             	shl    $0x10,%eax
  800935:	09 f0                	or     %esi,%eax
  800937:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	fc                   	cld    
  800941:	f3 ab                	rep stos %eax,%es:(%edi)
  800943:	eb 06                	jmp    80094b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	fc                   	cld    
  800949:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 35                	jae    800999 <memmove+0x47>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 d0                	cmp    %edx,%eax
  800969:	73 2e                	jae    800999 <memmove+0x47>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 d6                	mov    %edx,%esi
  800970:	09 fe                	or     %edi,%esi
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x3b>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0e                	jne    80098d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097f:	83 ef 04             	sub    $0x4,%edi
  800982:	8d 72 fc             	lea    -0x4(%edx),%esi
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	fd                   	std    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 09                	jmp    800996 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	8d 72 ff             	lea    -0x1(%edx),%esi
  800993:	fd                   	std    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800996:	fc                   	cld    
  800997:	eb 1d                	jmp    8009b6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 f2                	mov    %esi,%edx
  80099b:	09 c2                	or     %eax,%edx
  80099d:	f6 c2 03             	test   $0x3,%dl
  8009a0:	75 0f                	jne    8009b1 <memmove+0x5f>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 87 ff ff ff       	call   800952 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d8:	89 c6                	mov    %eax,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c1             	movzbl %cl,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f0                	cmp    %esi,%eax
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0d:	89 c1                	mov    %eax,%ecx
  800a0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	eb 0a                	jmp    800a22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	39 da                	cmp    %ebx,%edx
  800a1d:	74 07                	je     800a26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	39 c8                	cmp    %ecx,%eax
  800a24:	72 f2                	jb     800a18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	75 0a                	jne    800a53 <strtol+0x2a>
		s++;
  800a49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	eb 11                	jmp    800a64 <strtol+0x3b>
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	75 08                	jne    800a64 <strtol+0x3b>
		s++, neg = 1;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x58>
  800a6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6f:	75 10                	jne    800a81 <strtol+0x58>
  800a71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a75:	75 7c                	jne    800af3 <strtol+0xca>
		s += 2, base = 16;
  800a77:	83 c1 02             	add    $0x2,%ecx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 16                	jmp    800a97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	75 12                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8d:	75 08                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9f:	0f b6 11             	movzbl (%ecx),%edx
  800aa2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x8b>
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
  800ab2:	eb 22                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
  800ac4:	eb 10                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 16                	ja     800ae6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad9:	7d 0b                	jge    800ae6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae4:	eb b9                	jmp    800a9f <strtol+0x76>

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 0d                	je     800af9 <strtol+0xd0>
		*endptr = (char *) s;
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	89 0e                	mov    %ecx,(%esi)
  800af1:	eb 06                	jmp    800af9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	74 98                	je     800a8f <strtol+0x66>
  800af7:	eb 9e                	jmp    800a97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	85 ff                	test   %edi,%edi
  800aff:	0f 45 c2             	cmovne %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	b8 03 00 00 00       	mov    $0x3,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 03                	push   $0x3
  800b6c:	68 e8 12 80 00       	push   $0x8012e8
  800b71:	6a 23                	push   $0x23
  800b73:	68 05 13 80 00       	push   $0x801305
  800b78:	e8 23 02 00 00       	call   800da0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 04                	push   $0x4
  800bed:	68 e8 12 80 00       	push   $0x8012e8
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 05 13 80 00       	push   $0x801305
  800bf9:	e8 a2 01 00 00       	call   800da0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c20:	8b 75 18             	mov    0x18(%ebp),%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 05                	push   $0x5
  800c2f:	68 e8 12 80 00       	push   $0x8012e8
  800c34:	6a 23                	push   $0x23
  800c36:	68 05 13 80 00       	push   $0x801305
  800c3b:	e8 60 01 00 00       	call   800da0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 06                	push   $0x6
  800c71:	68 e8 12 80 00       	push   $0x8012e8
  800c76:	6a 23                	push   $0x23
  800c78:	68 05 13 80 00       	push   $0x801305
  800c7d:	e8 1e 01 00 00       	call   800da0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 08                	push   $0x8
  800cb3:	68 e8 12 80 00       	push   $0x8012e8
  800cb8:	6a 23                	push   $0x23
  800cba:	68 05 13 80 00       	push   $0x801305
  800cbf:	e8 dc 00 00 00       	call   800da0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 09                	push   $0x9
  800cf5:	68 e8 12 80 00       	push   $0x8012e8
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 05 13 80 00       	push   $0x801305
  800d01:	e8 9a 00 00 00       	call   800da0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	be 00 00 00 00       	mov    $0x0,%esi
  800d19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 cb                	mov    %ecx,%ebx
  800d49:	89 cf                	mov    %ecx,%edi
  800d4b:	89 ce                	mov    %ecx,%esi
  800d4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 0c                	push   $0xc
  800d59:	68 e8 12 80 00       	push   $0x8012e8
  800d5e:	6a 23                	push   $0x23
  800d60:	68 05 13 80 00       	push   $0x801305
  800d65:	e8 36 00 00 00       	call   800da0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d78:	68 1f 13 80 00       	push   $0x80131f
  800d7d:	6a 51                	push   $0x51
  800d7f:	68 13 13 80 00       	push   $0x801313
  800d84:	e8 17 00 00 00       	call   800da0 <_panic>

00800d89 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d8f:	68 1e 13 80 00       	push   $0x80131e
  800d94:	6a 58                	push   $0x58
  800d96:	68 13 13 80 00       	push   $0x801313
  800d9b:	e8 00 00 00 00       	call   800da0 <_panic>

00800da0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800da5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800da8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dae:	e8 d2 fd ff ff       	call   800b85 <sys_getenvid>
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	ff 75 08             	pushl  0x8(%ebp)
  800dbc:	56                   	push   %esi
  800dbd:	50                   	push   %eax
  800dbe:	68 34 13 80 00       	push   $0x801334
  800dc3:	e8 f4 f3 ff ff       	call   8001bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc8:	83 c4 18             	add    $0x18,%esp
  800dcb:	53                   	push   %ebx
  800dcc:	ff 75 10             	pushl  0x10(%ebp)
  800dcf:	e8 97 f3 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  800dd4:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  800ddb:	e8 dc f3 ff ff       	call   8001bc <cprintf>
  800de0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800de3:	cc                   	int3   
  800de4:	eb fd                	jmp    800de3 <_panic+0x43>
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	85 f6                	test   %esi,%esi
  800e09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e0d:	89 ca                	mov    %ecx,%edx
  800e0f:	89 f8                	mov    %edi,%eax
  800e11:	75 3d                	jne    800e50 <__udivdi3+0x60>
  800e13:	39 cf                	cmp    %ecx,%edi
  800e15:	0f 87 c5 00 00 00    	ja     800ee0 <__udivdi3+0xf0>
  800e1b:	85 ff                	test   %edi,%edi
  800e1d:	89 fd                	mov    %edi,%ebp
  800e1f:	75 0b                	jne    800e2c <__udivdi3+0x3c>
  800e21:	b8 01 00 00 00       	mov    $0x1,%eax
  800e26:	31 d2                	xor    %edx,%edx
  800e28:	f7 f7                	div    %edi
  800e2a:	89 c5                	mov    %eax,%ebp
  800e2c:	89 c8                	mov    %ecx,%eax
  800e2e:	31 d2                	xor    %edx,%edx
  800e30:	f7 f5                	div    %ebp
  800e32:	89 c1                	mov    %eax,%ecx
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	89 cf                	mov    %ecx,%edi
  800e38:	f7 f5                	div    %ebp
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 ce                	cmp    %ecx,%esi
  800e52:	77 74                	ja     800ec8 <__udivdi3+0xd8>
  800e54:	0f bd fe             	bsr    %esi,%edi
  800e57:	83 f7 1f             	xor    $0x1f,%edi
  800e5a:	0f 84 98 00 00 00    	je     800ef8 <__udivdi3+0x108>
  800e60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	89 c5                	mov    %eax,%ebp
  800e69:	29 fb                	sub    %edi,%ebx
  800e6b:	d3 e6                	shl    %cl,%esi
  800e6d:	89 d9                	mov    %ebx,%ecx
  800e6f:	d3 ed                	shr    %cl,%ebp
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e0                	shl    %cl,%eax
  800e75:	09 ee                	or     %ebp,%esi
  800e77:	89 d9                	mov    %ebx,%ecx
  800e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e7d:	89 d5                	mov    %edx,%ebp
  800e7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e83:	d3 ed                	shr    %cl,%ebp
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e2                	shl    %cl,%edx
  800e89:	89 d9                	mov    %ebx,%ecx
  800e8b:	d3 e8                	shr    %cl,%eax
  800e8d:	09 c2                	or     %eax,%edx
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	89 ea                	mov    %ebp,%edx
  800e93:	f7 f6                	div    %esi
  800e95:	89 d5                	mov    %edx,%ebp
  800e97:	89 c3                	mov    %eax,%ebx
  800e99:	f7 64 24 0c          	mull   0xc(%esp)
  800e9d:	39 d5                	cmp    %edx,%ebp
  800e9f:	72 10                	jb     800eb1 <__udivdi3+0xc1>
  800ea1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e6                	shl    %cl,%esi
  800ea9:	39 c6                	cmp    %eax,%esi
  800eab:	73 07                	jae    800eb4 <__udivdi3+0xc4>
  800ead:	39 d5                	cmp    %edx,%ebp
  800eaf:	75 03                	jne    800eb4 <__udivdi3+0xc4>
  800eb1:	83 eb 01             	sub    $0x1,%ebx
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 d8                	mov    %ebx,%eax
  800eb8:	89 fa                	mov    %edi,%edx
  800eba:	83 c4 1c             	add    $0x1c,%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
  800ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ec8:	31 ff                	xor    %edi,%edi
  800eca:	31 db                	xor    %ebx,%ebx
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	89 fa                	mov    %edi,%edx
  800ed0:	83 c4 1c             	add    $0x1c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    
  800ed8:	90                   	nop
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 d8                	mov    %ebx,%eax
  800ee2:	f7 f7                	div    %edi
  800ee4:	31 ff                	xor    %edi,%edi
  800ee6:	89 c3                	mov    %eax,%ebx
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	89 fa                	mov    %edi,%edx
  800eec:	83 c4 1c             	add    $0x1c,%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    
  800ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	39 ce                	cmp    %ecx,%esi
  800efa:	72 0c                	jb     800f08 <__udivdi3+0x118>
  800efc:	31 db                	xor    %ebx,%ebx
  800efe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f02:	0f 87 34 ff ff ff    	ja     800e3c <__udivdi3+0x4c>
  800f08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f0d:	e9 2a ff ff ff       	jmp    800e3c <__udivdi3+0x4c>
  800f12:	66 90                	xchg   %ax,%ax
  800f14:	66 90                	xchg   %ax,%ax
  800f16:	66 90                	xchg   %ax,%ax
  800f18:	66 90                	xchg   %ax,%ax
  800f1a:	66 90                	xchg   %ax,%ax
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__umoddi3>:
  800f20:	55                   	push   %ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 1c             	sub    $0x1c,%esp
  800f27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f37:	85 d2                	test   %edx,%edx
  800f39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f41:	89 f3                	mov    %esi,%ebx
  800f43:	89 3c 24             	mov    %edi,(%esp)
  800f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4a:	75 1c                	jne    800f68 <__umoddi3+0x48>
  800f4c:	39 f7                	cmp    %esi,%edi
  800f4e:	76 50                	jbe    800fa0 <__umoddi3+0x80>
  800f50:	89 c8                	mov    %ecx,%eax
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	f7 f7                	div    %edi
  800f56:	89 d0                	mov    %edx,%eax
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	77 52                	ja     800fc0 <__umoddi3+0xa0>
  800f6e:	0f bd ea             	bsr    %edx,%ebp
  800f71:	83 f5 1f             	xor    $0x1f,%ebp
  800f74:	75 5a                	jne    800fd0 <__umoddi3+0xb0>
  800f76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f7a:	0f 82 e0 00 00 00    	jb     801060 <__umoddi3+0x140>
  800f80:	39 0c 24             	cmp    %ecx,(%esp)
  800f83:	0f 86 d7 00 00 00    	jbe    801060 <__umoddi3+0x140>
  800f89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f91:	83 c4 1c             	add    $0x1c,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	85 ff                	test   %edi,%edi
  800fa2:	89 fd                	mov    %edi,%ebp
  800fa4:	75 0b                	jne    800fb1 <__umoddi3+0x91>
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f7                	div    %edi
  800faf:	89 c5                	mov    %eax,%ebp
  800fb1:	89 f0                	mov    %esi,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f5                	div    %ebp
  800fb7:	89 c8                	mov    %ecx,%eax
  800fb9:	f7 f5                	div    %ebp
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	eb 99                	jmp    800f58 <__umoddi3+0x38>
  800fbf:	90                   	nop
  800fc0:	89 c8                	mov    %ecx,%eax
  800fc2:	89 f2                	mov    %esi,%edx
  800fc4:	83 c4 1c             	add    $0x1c,%esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5e                   	pop    %esi
  800fc9:	5f                   	pop    %edi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    
  800fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	8b 34 24             	mov    (%esp),%esi
  800fd3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fd8:	89 e9                	mov    %ebp,%ecx
  800fda:	29 ef                	sub    %ebp,%edi
  800fdc:	d3 e0                	shl    %cl,%eax
  800fde:	89 f9                	mov    %edi,%ecx
  800fe0:	89 f2                	mov    %esi,%edx
  800fe2:	d3 ea                	shr    %cl,%edx
  800fe4:	89 e9                	mov    %ebp,%ecx
  800fe6:	09 c2                	or     %eax,%edx
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	89 14 24             	mov    %edx,(%esp)
  800fed:	89 f2                	mov    %esi,%edx
  800fef:	d3 e2                	shl    %cl,%edx
  800ff1:	89 f9                	mov    %edi,%ecx
  800ff3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ffb:	d3 e8                	shr    %cl,%eax
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	89 c6                	mov    %eax,%esi
  801001:	d3 e3                	shl    %cl,%ebx
  801003:	89 f9                	mov    %edi,%ecx
  801005:	89 d0                	mov    %edx,%eax
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	09 d8                	or     %ebx,%eax
  80100d:	89 d3                	mov    %edx,%ebx
  80100f:	89 f2                	mov    %esi,%edx
  801011:	f7 34 24             	divl   (%esp)
  801014:	89 d6                	mov    %edx,%esi
  801016:	d3 e3                	shl    %cl,%ebx
  801018:	f7 64 24 04          	mull   0x4(%esp)
  80101c:	39 d6                	cmp    %edx,%esi
  80101e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801022:	89 d1                	mov    %edx,%ecx
  801024:	89 c3                	mov    %eax,%ebx
  801026:	72 08                	jb     801030 <__umoddi3+0x110>
  801028:	75 11                	jne    80103b <__umoddi3+0x11b>
  80102a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80102e:	73 0b                	jae    80103b <__umoddi3+0x11b>
  801030:	2b 44 24 04          	sub    0x4(%esp),%eax
  801034:	1b 14 24             	sbb    (%esp),%edx
  801037:	89 d1                	mov    %edx,%ecx
  801039:	89 c3                	mov    %eax,%ebx
  80103b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80103f:	29 da                	sub    %ebx,%edx
  801041:	19 ce                	sbb    %ecx,%esi
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 f0                	mov    %esi,%eax
  801047:	d3 e0                	shl    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	d3 ea                	shr    %cl,%edx
  80104d:	89 e9                	mov    %ebp,%ecx
  80104f:	d3 ee                	shr    %cl,%esi
  801051:	09 d0                	or     %edx,%eax
  801053:	89 f2                	mov    %esi,%edx
  801055:	83 c4 1c             	add    $0x1c,%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	29 f9                	sub    %edi,%ecx
  801062:	19 d6                	sbb    %edx,%esi
  801064:	89 74 24 04          	mov    %esi,0x4(%esp)
  801068:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80106c:	e9 18 ff ff ff       	jmp    800f89 <__umoddi3+0x69>
