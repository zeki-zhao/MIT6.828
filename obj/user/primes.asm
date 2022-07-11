
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 b1 0d 00 00       	call   800dfd <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 11 80 00       	push   $0x801100
  800060:	e8 b4 01 00 00       	call   800219 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 65 0d 00 00       	call   800dcf <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 0c 11 80 00       	push   $0x80110c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 15 11 80 00       	push   $0x801115
  800080:	e8 bb 00 00 00       	call   800140 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 64 0d 00 00       	call   800dfd <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 64 0d 00 00       	call   800e14 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 10 0d 00 00       	call   800dcf <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 0c 11 80 00       	push   $0x80110c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 15 11 80 00       	push   $0x801115
  8000d2:	e8 69 00 00 00       	call   800140 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 24 0d 00 00       	call   800e14 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800101:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800104:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80010b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7e 08                	jle    80011a <libmain+0x22>
		binaryname = argv[0];
  800112:	8b 0a                	mov    (%edx),%ecx
  800114:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	52                   	push   %edx
  80011e:	50                   	push   %eax
  80011f:	e8 91 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800124:	e8 05 00 00 00       	call   80012e <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800134:	6a 00                	push   $0x0
  800136:	e8 66 0a 00 00       	call   800ba1 <sys_env_destroy>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014e:	e8 8f 0a 00 00       	call   800be2 <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	56                   	push   %esi
  80015d:	50                   	push   %eax
  80015e:	68 30 11 80 00       	push   $0x801130
  800163:	e8 b1 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	53                   	push   %ebx
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 54 00 00 00       	call   8001c8 <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 54 11 80 00 	movl   $0x801154,(%esp)
  80017b:	e8 99 00 00 00       	call   800219 <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x43>

00800186 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	53                   	push   %ebx
  80018a:	83 ec 04             	sub    $0x4,%esp
  80018d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800190:	8b 13                	mov    (%ebx),%edx
  800192:	8d 42 01             	lea    0x1(%edx),%eax
  800195:	89 03                	mov    %eax,(%ebx)
  800197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a3:	75 1a                	jne    8001bf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	68 ff 00 00 00       	push   $0xff
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ae 09 00 00       	call   800b64 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 86 01 80 00       	push   $0x800186
  8001f7:	e8 1a 01 00 00       	call   800316 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 53 09 00 00       	call   800b64 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800222:	50                   	push   %eax
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	e8 9d ff ff ff       	call   8001c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 1c             	sub    $0x1c,%esp
  800236:	89 c7                	mov    %eax,%edi
  800238:	89 d6                	mov    %edx,%esi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800243:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800246:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800251:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800254:	39 d3                	cmp    %edx,%ebx
  800256:	72 05                	jb     80025d <printnum+0x30>
  800258:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025b:	77 45                	ja     8002a2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	ff 75 18             	pushl  0x18(%ebp)
  800263:	8b 45 14             	mov    0x14(%ebp),%eax
  800266:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800269:	53                   	push   %ebx
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 ef 0b 00 00       	call   800e70 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9e ff ff ff       	call   80022d <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 18                	jmp    8002ac <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	eb 03                	jmp    8002a5 <printnum+0x78>
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f e8                	jg     800294 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bf:	e8 dc 0c 00 00       	call   800fa0 <__umoddi3>
  8002c4:	83 c4 14             	add    $0x14,%esp
  8002c7:	0f be 80 56 11 80 00 	movsbl 0x801156(%eax),%eax
  8002ce:	50                   	push   %eax
  8002cf:	ff d7                	call   *%edi
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002eb:	73 0a                	jae    8002f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	88 02                	mov    %al,(%edx)
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	ff 75 08             	pushl  0x8(%ebp)
  80030c:	e8 05 00 00 00       	call   800316 <vprintfmt>
	va_end(ap);
}
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 2c             	sub    $0x2c,%esp
  80031f:	8b 75 08             	mov    0x8(%ebp),%esi
  800322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800325:	8b 7d 10             	mov    0x10(%ebp),%edi
  800328:	eb 12                	jmp    80033c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	0f 84 42 04 00 00    	je     800774 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	53                   	push   %ebx
  800336:	50                   	push   %eax
  800337:	ff d6                	call   *%esi
  800339:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033c:	83 c7 01             	add    $0x1,%edi
  80033f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800343:	83 f8 25             	cmp    $0x25,%eax
  800346:	75 e2                	jne    80032a <vprintfmt+0x14>
  800348:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800353:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800361:	b9 00 00 00 00       	mov    $0x0,%ecx
  800366:	eb 07                	jmp    80036f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8d 47 01             	lea    0x1(%edi),%eax
  800372:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800375:	0f b6 07             	movzbl (%edi),%eax
  800378:	0f b6 d0             	movzbl %al,%edx
  80037b:	83 e8 23             	sub    $0x23,%eax
  80037e:	3c 55                	cmp    $0x55,%al
  800380:	0f 87 d3 03 00 00    	ja     800759 <vprintfmt+0x443>
  800386:	0f b6 c0             	movzbl %al,%eax
  800389:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800393:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800397:	eb d6                	jmp    80036f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ab:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ae:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b1:	83 f9 09             	cmp    $0x9,%ecx
  8003b4:	77 3f                	ja     8003f5 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b9:	eb e9                	jmp    8003a4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8d 40 04             	lea    0x4(%eax),%eax
  8003c9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cf:	eb 2a                	jmp    8003fb <vprintfmt+0xe5>
  8003d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	0f 49 d0             	cmovns %eax,%edx
  8003de:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e4:	eb 89                	jmp    80036f <vprintfmt+0x59>
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f0:	e9 7a ff ff ff       	jmp    80036f <vprintfmt+0x59>
  8003f5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	0f 89 6a ff ff ff    	jns    80036f <vprintfmt+0x59>
				width = precision, precision = -1;
  800405:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800408:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800412:	e9 58 ff ff ff       	jmp    80036f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800417:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041d:	e9 4d ff ff ff       	jmp    80036f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 78 04             	lea    0x4(%eax),%edi
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	ff 30                	pushl  (%eax)
  80042e:	ff d6                	call   *%esi
			break;
  800430:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800433:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800439:	e9 fe fe ff ff       	jmp    80033c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 78 04             	lea    0x4(%eax),%edi
  800444:	8b 00                	mov    (%eax),%eax
  800446:	99                   	cltd   
  800447:	31 d0                	xor    %edx,%eax
  800449:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 f8 09             	cmp    $0x9,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x145>
  800450:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800457:	85 d2                	test   %edx,%edx
  800459:	75 1b                	jne    800476 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 6e 11 80 00       	push   $0x80116e
  800461:	53                   	push   %ebx
  800462:	56                   	push   %esi
  800463:	e8 91 fe ff ff       	call   8002f9 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800471:	e9 c6 fe ff ff       	jmp    80033c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800476:	52                   	push   %edx
  800477:	68 77 11 80 00       	push   $0x801177
  80047c:	53                   	push   %ebx
  80047d:	56                   	push   %esi
  80047e:	e8 76 fe ff ff       	call   8002f9 <printfmt>
  800483:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048c:	e9 ab fe ff ff       	jmp    80033c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	83 c0 04             	add    $0x4,%eax
  800497:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049f:	85 ff                	test   %edi,%edi
  8004a1:	b8 67 11 80 00       	mov    $0x801167,%eax
  8004a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ad:	0f 8e 94 00 00 00    	jle    800547 <vprintfmt+0x231>
  8004b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b7:	0f 84 98 00 00 00    	je     800555 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c3:	57                   	push   %edi
  8004c4:	e8 33 03 00 00       	call   8007fc <strnlen>
  8004c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cc:	29 c1                	sub    %eax,%ecx
  8004ce:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	eb 0f                	jmp    8004f1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	83 ef 01             	sub    $0x1,%edi
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	7f ed                	jg     8004e2 <vprintfmt+0x1cc>
  8004f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004fb:	85 c9                	test   %ecx,%ecx
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	0f 49 c1             	cmovns %ecx,%eax
  800505:	29 c1                	sub    %eax,%ecx
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	89 cb                	mov    %ecx,%ebx
  800512:	eb 4d                	jmp    800561 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800514:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800518:	74 1b                	je     800535 <vprintfmt+0x21f>
  80051a:	0f be c0             	movsbl %al,%eax
  80051d:	83 e8 20             	sub    $0x20,%eax
  800520:	83 f8 5e             	cmp    $0x5e,%eax
  800523:	76 10                	jbe    800535 <vprintfmt+0x21f>
					putch('?', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	6a 3f                	push   $0x3f
  80052d:	ff 55 08             	call   *0x8(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb 0d                	jmp    800542 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	52                   	push   %edx
  80053c:	ff 55 08             	call   *0x8(%ebp)
  80053f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	83 eb 01             	sub    $0x1,%ebx
  800545:	eb 1a                	jmp    800561 <vprintfmt+0x24b>
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800553:	eb 0c                	jmp    800561 <vprintfmt+0x24b>
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800561:	83 c7 01             	add    $0x1,%edi
  800564:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800568:	0f be d0             	movsbl %al,%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	74 23                	je     800592 <vprintfmt+0x27c>
  80056f:	85 f6                	test   %esi,%esi
  800571:	78 a1                	js     800514 <vprintfmt+0x1fe>
  800573:	83 ee 01             	sub    $0x1,%esi
  800576:	79 9c                	jns    800514 <vprintfmt+0x1fe>
  800578:	89 df                	mov    %ebx,%edi
  80057a:	8b 75 08             	mov    0x8(%ebp),%esi
  80057d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800580:	eb 18                	jmp    80059a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	6a 20                	push   $0x20
  800588:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058a:	83 ef 01             	sub    $0x1,%edi
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	eb 08                	jmp    80059a <vprintfmt+0x284>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	85 ff                	test   %edi,%edi
  80059c:	7f e4                	jg     800582 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 90 fd ff ff       	jmp    80033c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 f9 01             	cmp    $0x1,%ecx
  8005af:	7e 19                	jle    8005ca <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 50 04             	mov    0x4(%eax),%edx
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 08             	lea    0x8(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c8:	eb 38                	jmp    800602 <vprintfmt+0x2ec>
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 1b                	je     8005e9 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e7:	eb 19                	jmp    800602 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800602:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800605:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800611:	0f 89 0e 01 00 00    	jns    800725 <vprintfmt+0x40f>
				putch('-', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 2d                	push   $0x2d
  80061d:	ff d6                	call   *%esi
				num = -(long long) num;
  80061f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800622:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800625:	f7 da                	neg    %edx
  800627:	83 d1 00             	adc    $0x0,%ecx
  80062a:	f7 d9                	neg    %ecx
  80062c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 ec 00 00 00       	jmp    800725 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800639:	83 f9 01             	cmp    $0x1,%ecx
  80063c:	7e 18                	jle    800656 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	8b 48 04             	mov    0x4(%eax),%ecx
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800651:	e9 cf 00 00 00       	jmp    800725 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	74 1a                	je     800674 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 b1 00 00 00       	jmp    800725 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800684:	b8 0a 00 00 00       	mov    $0xa,%eax
  800689:	e9 97 00 00 00       	jmp    800725 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 58                	push   $0x58
  800694:	ff d6                	call   *%esi
			putch('X', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 58                	push   $0x58
  80069c:	ff d6                	call   *%esi
			putch('X', putdat);
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 58                	push   $0x58
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006ac:	e9 8b fc ff ff       	jmp    80033c <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 30                	push   $0x30
  8006b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b9:	83 c4 08             	add    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 78                	push   $0x78
  8006bf:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cb:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d9:	eb 4a                	jmp    800725 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7e 15                	jle    8006f5 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e8:	8d 40 08             	lea    0x8(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f3:	eb 30                	jmp    800725 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006f5:	85 c9                	test   %ecx,%ecx
  8006f7:	74 17                	je     800710 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800709:	b8 10 00 00 00       	mov    $0x10,%eax
  80070e:	eb 15                	jmp    800725 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071a:	8d 40 04             	lea    0x4(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800720:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800725:	83 ec 0c             	sub    $0xc,%esp
  800728:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072c:	57                   	push   %edi
  80072d:	ff 75 e0             	pushl  -0x20(%ebp)
  800730:	50                   	push   %eax
  800731:	51                   	push   %ecx
  800732:	52                   	push   %edx
  800733:	89 da                	mov    %ebx,%edx
  800735:	89 f0                	mov    %esi,%eax
  800737:	e8 f1 fa ff ff       	call   80022d <printnum>
			break;
  80073c:	83 c4 20             	add    $0x20,%esp
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	e9 f5 fb ff ff       	jmp    80033c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	52                   	push   %edx
  80074c:	ff d6                	call   *%esi
			break;
  80074e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800754:	e9 e3 fb ff ff       	jmp    80033c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 25                	push   $0x25
  80075f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 03                	jmp    800769 <vprintfmt+0x453>
  800766:	83 ef 01             	sub    $0x1,%edi
  800769:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80076d:	75 f7                	jne    800766 <vprintfmt+0x450>
  80076f:	e9 c8 fb ff ff       	jmp    80033c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5f                   	pop    %edi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 18             	sub    $0x18,%esp
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800788:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800792:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 26                	je     8007c3 <vsnprintf+0x47>
  80079d:	85 d2                	test   %edx,%edx
  80079f:	7e 22                	jle    8007c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a1:	ff 75 14             	pushl  0x14(%ebp)
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007aa:	50                   	push   %eax
  8007ab:	68 dc 02 80 00       	push   $0x8002dc
  8007b0:	e8 61 fb ff ff       	call   800316 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 05                	jmp    8007c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d3:	50                   	push   %eax
  8007d4:	ff 75 10             	pushl  0x10(%ebp)
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 9a ff ff ff       	call   80077c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	eb 03                	jmp    8007f4 <strlen+0x10>
		n++;
  8007f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f8:	75 f7                	jne    8007f1 <strlen+0xd>
		n++;
	return n;
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	eb 03                	jmp    80080f <strnlen+0x13>
		n++;
  80080c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 c2                	cmp    %eax,%edx
  800811:	74 08                	je     80081b <strnlen+0x1f>
  800813:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800817:	75 f3                	jne    80080c <strnlen+0x10>
  800819:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800827:	89 c2                	mov    %eax,%edx
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800833:	88 5a ff             	mov    %bl,-0x1(%edx)
  800836:	84 db                	test   %bl,%bl
  800838:	75 ef                	jne    800829 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800844:	53                   	push   %ebx
  800845:	e8 9a ff ff ff       	call   8007e4 <strlen>
  80084a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	01 d8                	add    %ebx,%eax
  800852:	50                   	push   %eax
  800853:	e8 c5 ff ff ff       	call   80081d <strcpy>
	return dst;
}
  800858:	89 d8                	mov    %ebx,%eax
  80085a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086a:	89 f3                	mov    %esi,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086f:	89 f2                	mov    %esi,%edx
  800871:	eb 0f                	jmp    800882 <strncpy+0x23>
		*dst++ = *src;
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087c:	80 39 01             	cmpb   $0x1,(%ecx)
  80087f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	39 da                	cmp    %ebx,%edx
  800884:	75 ed                	jne    800873 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800886:	89 f0                	mov    %esi,%eax
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
  80089a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	85 d2                	test   %edx,%edx
  80089e:	74 21                	je     8008c1 <strlcpy+0x35>
  8008a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 09                	jmp    8008b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	83 c1 01             	add    $0x1,%ecx
  8008ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b1:	39 c2                	cmp    %eax,%edx
  8008b3:	74 09                	je     8008be <strlcpy+0x32>
  8008b5:	0f b6 19             	movzbl (%ecx),%ebx
  8008b8:	84 db                	test   %bl,%bl
  8008ba:	75 ec                	jne    8008a8 <strlcpy+0x1c>
  8008bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c1:	29 f0                	sub    %esi,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strcmp+0x11>
		p++, q++;
  8008d2:	83 c1 01             	add    $0x1,%ecx
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d8:	0f b6 01             	movzbl (%ecx),%eax
  8008db:	84 c0                	test   %al,%al
  8008dd:	74 04                	je     8008e3 <strcmp+0x1c>
  8008df:	3a 02                	cmp    (%edx),%al
  8008e1:	74 ef                	je     8008d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 c0             	movzbl %al,%eax
  8008e6:	0f b6 12             	movzbl (%edx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fc:	eb 06                	jmp    800904 <strncmp+0x17>
		n--, p++, q++;
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800904:	39 d8                	cmp    %ebx,%eax
  800906:	74 15                	je     80091d <strncmp+0x30>
  800908:	0f b6 08             	movzbl (%eax),%ecx
  80090b:	84 c9                	test   %cl,%cl
  80090d:	74 04                	je     800913 <strncmp+0x26>
  80090f:	3a 0a                	cmp    (%edx),%cl
  800911:	74 eb                	je     8008fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 00             	movzbl (%eax),%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
  80091b:	eb 05                	jmp    800922 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092f:	eb 07                	jmp    800938 <strchr+0x13>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 0f                	je     800944 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 10             	movzbl (%eax),%edx
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f2                	jne    800931 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800950:	eb 03                	jmp    800955 <strfind+0xf>
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 04                	je     800960 <strfind+0x1a>
  80095c:	84 d2                	test   %dl,%dl
  80095e:	75 f2                	jne    800952 <strfind+0xc>
			break;
	return (char *) s;
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 36                	je     8009a8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800972:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800978:	75 28                	jne    8009a2 <memset+0x40>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 23                	jne    8009a2 <memset+0x40>
		c &= 0xFF;
  80097f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800983:	89 d3                	mov    %edx,%ebx
  800985:	c1 e3 08             	shl    $0x8,%ebx
  800988:	89 d6                	mov    %edx,%esi
  80098a:	c1 e6 18             	shl    $0x18,%esi
  80098d:	89 d0                	mov    %edx,%eax
  80098f:	c1 e0 10             	shl    $0x10,%eax
  800992:	09 f0                	or     %esi,%eax
  800994:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800996:	89 d8                	mov    %ebx,%eax
  800998:	09 d0                	or     %edx,%eax
  80099a:	c1 e9 02             	shr    $0x2,%ecx
  80099d:	fc                   	cld    
  80099e:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a0:	eb 06                	jmp    8009a8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	fc                   	cld    
  8009a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a8:	89 f8                	mov    %edi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 35                	jae    8009f6 <memmove+0x47>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 2e                	jae    8009f6 <memmove+0x47>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	09 fe                	or     %edi,%esi
  8009cf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d5:	75 13                	jne    8009ea <memmove+0x3b>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0e                	jne    8009ea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009dc:	83 ef 04             	sub    $0x4,%edi
  8009df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
  8009e5:	fd                   	std    
  8009e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e8:	eb 09                	jmp    8009f3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ea:	83 ef 01             	sub    $0x1,%edi
  8009ed:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f0:	fd                   	std    
  8009f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f3:	fc                   	cld    
  8009f4:	eb 1d                	jmp    800a13 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	89 f2                	mov    %esi,%edx
  8009f8:	09 c2                	or     %eax,%edx
  8009fa:	f6 c2 03             	test   $0x3,%dl
  8009fd:	75 0f                	jne    800a0e <memmove+0x5f>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 0a                	jne    800a0e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a04:	c1 e9 02             	shr    $0x2,%ecx
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0c:	eb 05                	jmp    800a13 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1a:	ff 75 10             	pushl  0x10(%ebp)
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	ff 75 08             	pushl  0x8(%ebp)
  800a23:	e8 87 ff ff ff       	call   8009af <memmove>
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a35:	89 c6                	mov    %eax,%esi
  800a37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	eb 1a                	jmp    800a56 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3c:	0f b6 08             	movzbl (%eax),%ecx
  800a3f:	0f b6 1a             	movzbl (%edx),%ebx
  800a42:	38 d9                	cmp    %bl,%cl
  800a44:	74 0a                	je     800a50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a46:	0f b6 c1             	movzbl %cl,%eax
  800a49:	0f b6 db             	movzbl %bl,%ebx
  800a4c:	29 d8                	sub    %ebx,%eax
  800a4e:	eb 0f                	jmp    800a5f <memcmp+0x35>
		s1++, s2++;
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a56:	39 f0                	cmp    %esi,%eax
  800a58:	75 e2                	jne    800a3c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6a:	89 c1                	mov    %eax,%ecx
  800a6c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a73:	eb 0a                	jmp    800a7f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	39 da                	cmp    %ebx,%edx
  800a7a:	74 07                	je     800a83 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	39 c8                	cmp    %ecx,%eax
  800a81:	72 f2                	jb     800a75 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a83:	5b                   	pop    %ebx
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a92:	eb 03                	jmp    800a97 <strtol+0x11>
		s++;
  800a94:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	0f b6 01             	movzbl (%ecx),%eax
  800a9a:	3c 20                	cmp    $0x20,%al
  800a9c:	74 f6                	je     800a94 <strtol+0xe>
  800a9e:	3c 09                	cmp    $0x9,%al
  800aa0:	74 f2                	je     800a94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa2:	3c 2b                	cmp    $0x2b,%al
  800aa4:	75 0a                	jne    800ab0 <strtol+0x2a>
		s++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb 11                	jmp    800ac1 <strtol+0x3b>
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab5:	3c 2d                	cmp    $0x2d,%al
  800ab7:	75 08                	jne    800ac1 <strtol+0x3b>
		s++, neg = 1;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac7:	75 15                	jne    800ade <strtol+0x58>
  800ac9:	80 39 30             	cmpb   $0x30,(%ecx)
  800acc:	75 10                	jne    800ade <strtol+0x58>
  800ace:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad2:	75 7c                	jne    800b50 <strtol+0xca>
		s += 2, base = 16;
  800ad4:	83 c1 02             	add    $0x2,%ecx
  800ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adc:	eb 16                	jmp    800af4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	75 12                	jne    800af4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aea:	75 08                	jne    800af4 <strtol+0x6e>
		s++, base = 8;
  800aec:	83 c1 01             	add    $0x1,%ecx
  800aef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afc:	0f b6 11             	movzbl (%ecx),%edx
  800aff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 09             	cmp    $0x9,%bl
  800b07:	77 08                	ja     800b11 <strtol+0x8b>
			dig = *s - '0';
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 30             	sub    $0x30,%edx
  800b0f:	eb 22                	jmp    800b33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 57             	sub    $0x57,%edx
  800b21:	eb 10                	jmp    800b33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 16                	ja     800b43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b36:	7d 0b                	jge    800b43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b38:	83 c1 01             	add    $0x1,%ecx
  800b3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b41:	eb b9                	jmp    800afc <strtol+0x76>

	if (endptr)
  800b43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b47:	74 0d                	je     800b56 <strtol+0xd0>
		*endptr = (char *) s;
  800b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4c:	89 0e                	mov    %ecx,(%esi)
  800b4e:	eb 06                	jmp    800b56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	74 98                	je     800aec <strtol+0x66>
  800b54:	eb 9e                	jmp    800af4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	f7 da                	neg    %edx
  800b5a:	85 ff                	test   %edi,%edi
  800b5c:	0f 45 c2             	cmovne %edx,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	89 c3                	mov    %eax,%ebx
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	89 c6                	mov    %eax,%esi
  800b7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 cb                	mov    %ecx,%ebx
  800bb9:	89 cf                	mov    %ecx,%edi
  800bbb:	89 ce                	mov    %ecx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 03                	push   $0x3
  800bc9:	68 a8 13 80 00       	push   $0x8013a8
  800bce:	6a 23                	push   $0x23
  800bd0:	68 c5 13 80 00       	push   $0x8013c5
  800bd5:	e8 66 f5 ff ff       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_yield>:

void
sys_yield(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	be 00 00 00 00       	mov    $0x0,%esi
  800c2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3c:	89 f7                	mov    %esi,%edi
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 04                	push   $0x4
  800c4a:	68 a8 13 80 00       	push   $0x8013a8
  800c4f:	6a 23                	push   $0x23
  800c51:	68 c5 13 80 00       	push   $0x8013c5
  800c56:	e8 e5 f4 ff ff       	call   800140 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 05                	push   $0x5
  800c8c:	68 a8 13 80 00       	push   $0x8013a8
  800c91:	6a 23                	push   $0x23
  800c93:	68 c5 13 80 00       	push   $0x8013c5
  800c98:	e8 a3 f4 ff ff       	call   800140 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 06                	push   $0x6
  800cce:	68 a8 13 80 00       	push   $0x8013a8
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 c5 13 80 00       	push   $0x8013c5
  800cda:	e8 61 f4 ff ff       	call   800140 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 08                	push   $0x8
  800d10:	68 a8 13 80 00       	push   $0x8013a8
  800d15:	6a 23                	push   $0x23
  800d17:	68 c5 13 80 00       	push   $0x8013c5
  800d1c:	e8 1f f4 ff ff       	call   800140 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 09                	push   $0x9
  800d52:	68 a8 13 80 00       	push   $0x8013a8
  800d57:	6a 23                	push   $0x23
  800d59:	68 c5 13 80 00       	push   $0x8013c5
  800d5e:	e8 dd f3 ff ff       	call   800140 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d87:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 cb                	mov    %ecx,%ebx
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	89 ce                	mov    %ecx,%esi
  800daa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 17                	jle    800dc7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	50                   	push   %eax
  800db4:	6a 0c                	push   $0xc
  800db6:	68 a8 13 80 00       	push   $0x8013a8
  800dbb:	6a 23                	push   $0x23
  800dbd:	68 c5 13 80 00       	push   $0x8013c5
  800dc2:	e8 79 f3 ff ff       	call   800140 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800dd5:	68 df 13 80 00       	push   $0x8013df
  800dda:	6a 51                	push   $0x51
  800ddc:	68 d3 13 80 00       	push   $0x8013d3
  800de1:	e8 5a f3 ff ff       	call   800140 <_panic>

00800de6 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dec:	68 de 13 80 00       	push   $0x8013de
  800df1:	6a 58                	push   $0x58
  800df3:	68 d3 13 80 00       	push   $0x8013d3
  800df8:	e8 43 f3 ff ff       	call   800140 <_panic>

00800dfd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e03:	68 f4 13 80 00       	push   $0x8013f4
  800e08:	6a 1a                	push   $0x1a
  800e0a:	68 0d 14 80 00       	push   $0x80140d
  800e0f:	e8 2c f3 ff ff       	call   800140 <_panic>

00800e14 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e1a:	68 17 14 80 00       	push   $0x801417
  800e1f:	6a 2a                	push   $0x2a
  800e21:	68 0d 14 80 00       	push   $0x80140d
  800e26:	e8 15 f3 ff ff       	call   800140 <_panic>

00800e2b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e36:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e39:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e3f:	8b 52 50             	mov    0x50(%edx),%edx
  800e42:	39 ca                	cmp    %ecx,%edx
  800e44:	75 0d                	jne    800e53 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e46:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e49:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4e:	8b 40 48             	mov    0x48(%eax),%eax
  800e51:	eb 0f                	jmp    800e62 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e53:	83 c0 01             	add    $0x1,%eax
  800e56:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e5b:	75 d9                	jne    800e36 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	66 90                	xchg   %ax,%ax
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
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
