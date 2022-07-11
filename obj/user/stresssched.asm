
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 9a 0b 00 00       	call   800bd7 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 7b 0d 00 00       	call   800dc4 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 95 0b 00 00       	call   800bf6 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 6c 0b 00 00       	call   800bf6 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 a0 10 80 00       	push   $0x8010a0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 c8 10 80 00       	push   $0x8010c8
  8000c4:	e8 6c 00 00 00       	call   800135 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 db 10 80 00       	push   $0x8010db
  8000de:	e8 2b 01 00 00       	call   80020e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f9:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800100:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 08                	jle    80010f <libmain+0x22>
		binaryname = argv[0];
  800107:	8b 0a                	mov    (%edx),%ecx
  800109:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	52                   	push   %edx
  800113:	50                   	push   %eax
  800114:	e8 1a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800119:	e8 05 00 00 00       	call   800123 <exit>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800129:	6a 00                	push   $0x0
  80012b:	e8 66 0a 00 00       	call   800b96 <sys_env_destroy>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	c9                   	leave  
  800134:	c3                   	ret    

00800135 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800143:	e8 8f 0a 00 00       	call   800bd7 <sys_getenvid>
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	ff 75 0c             	pushl  0xc(%ebp)
  80014e:	ff 75 08             	pushl  0x8(%ebp)
  800151:	56                   	push   %esi
  800152:	50                   	push   %eax
  800153:	68 04 11 80 00       	push   $0x801104
  800158:	e8 b1 00 00 00       	call   80020e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015d:	83 c4 18             	add    $0x18,%esp
  800160:	53                   	push   %ebx
  800161:	ff 75 10             	pushl  0x10(%ebp)
  800164:	e8 54 00 00 00       	call   8001bd <vcprintf>
	cprintf("\n");
  800169:	c7 04 24 f7 10 80 00 	movl   $0x8010f7,(%esp)
  800170:	e8 99 00 00 00       	call   80020e <cprintf>
  800175:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800178:	cc                   	int3   
  800179:	eb fd                	jmp    800178 <_panic+0x43>

0080017b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	53                   	push   %ebx
  80017f:	83 ec 04             	sub    $0x4,%esp
  800182:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800185:	8b 13                	mov    (%ebx),%edx
  800187:	8d 42 01             	lea    0x1(%edx),%eax
  80018a:	89 03                	mov    %eax,(%ebx)
  80018c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800193:	3d ff 00 00 00       	cmp    $0xff,%eax
  800198:	75 1a                	jne    8001b4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	68 ff 00 00 00       	push   $0xff
  8001a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 ae 09 00 00       	call   800b59 <sys_cputs>
		b->idx = 0;
  8001ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cd:	00 00 00 
	b.cnt = 0;
  8001d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001da:	ff 75 0c             	pushl  0xc(%ebp)
  8001dd:	ff 75 08             	pushl  0x8(%ebp)
  8001e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	68 7b 01 80 00       	push   $0x80017b
  8001ec:	e8 1a 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	83 c4 08             	add    $0x8,%esp
  8001f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	e8 53 09 00 00       	call   800b59 <sys_cputs>

	return b.cnt;
}
  800206:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800214:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800217:	50                   	push   %eax
  800218:	ff 75 08             	pushl  0x8(%ebp)
  80021b:	e8 9d ff ff ff       	call   8001bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 1c             	sub    $0x1c,%esp
  80022b:	89 c7                	mov    %eax,%edi
  80022d:	89 d6                	mov    %edx,%esi
  80022f:	8b 45 08             	mov    0x8(%ebp),%eax
  800232:	8b 55 0c             	mov    0xc(%ebp),%edx
  800235:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800238:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800243:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800246:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800249:	39 d3                	cmp    %edx,%ebx
  80024b:	72 05                	jb     800252 <printnum+0x30>
  80024d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800250:	77 45                	ja     800297 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	ff 75 18             	pushl  0x18(%ebp)
  800258:	8b 45 14             	mov    0x14(%ebp),%eax
  80025b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025e:	53                   	push   %ebx
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	ff 75 e4             	pushl  -0x1c(%ebp)
  800268:	ff 75 e0             	pushl  -0x20(%ebp)
  80026b:	ff 75 dc             	pushl  -0x24(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	e8 8a 0b 00 00       	call   800e00 <__udivdi3>
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	52                   	push   %edx
  80027a:	50                   	push   %eax
  80027b:	89 f2                	mov    %esi,%edx
  80027d:	89 f8                	mov    %edi,%eax
  80027f:	e8 9e ff ff ff       	call   800222 <printnum>
  800284:	83 c4 20             	add    $0x20,%esp
  800287:	eb 18                	jmp    8002a1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	ff 75 18             	pushl  0x18(%ebp)
  800290:	ff d7                	call   *%edi
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	eb 03                	jmp    80029a <printnum+0x78>
  800297:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f e8                	jg     800289 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 77 0c 00 00       	call   800f30 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 28 11 80 00 	movsbl 0x801128(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff d7                	call   *%edi
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 42 04 00 00    	je     800769 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 d0             	movzbl %al,%edx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 d3 03 00 00    	ja     80074e <vprintfmt+0x443>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a6:	83 f9 09             	cmp    $0x9,%ecx
  8003a9:	77 3f                	ja     8003ea <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 40 04             	lea    0x4(%eax),%eax
  8003be:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c4:	eb 2a                	jmp    8003f0 <vprintfmt+0xe5>
  8003c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d0:	0f 49 d0             	cmovns %eax,%edx
  8003d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	eb 89                	jmp    800364 <vprintfmt+0x59>
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e5:	e9 7a ff ff ff       	jmp    800364 <vprintfmt+0x59>
  8003ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f4:	0f 89 6a ff ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	e9 58 ff ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800412:	e9 4d ff ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 78 04             	lea    0x4(%eax),%edi
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	53                   	push   %ebx
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d6                	call   *%esi
			break;
  800425:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042e:	e9 fe fe ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 78 04             	lea    0x4(%eax),%edi
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	99                   	cltd   
  80043c:	31 d0                	xor    %edx,%eax
  80043e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800440:	83 f8 09             	cmp    $0x9,%eax
  800443:	7f 0b                	jg     800450 <vprintfmt+0x145>
  800445:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  80044c:	85 d2                	test   %edx,%edx
  80044e:	75 1b                	jne    80046b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800450:	50                   	push   %eax
  800451:	68 40 11 80 00       	push   $0x801140
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 91 fe ff ff       	call   8002ee <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800460:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800466:	e9 c6 fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046b:	52                   	push   %edx
  80046c:	68 49 11 80 00       	push   $0x801149
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 76 fe ff ff       	call   8002ee <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800481:	e9 ab fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	83 c0 04             	add    $0x4,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800494:	85 ff                	test   %edi,%edi
  800496:	b8 39 11 80 00       	mov    $0x801139,%eax
  80049b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a2:	0f 8e 94 00 00 00    	jle    80053c <vprintfmt+0x231>
  8004a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ac:	0f 84 98 00 00 00    	je     80054a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b8:	57                   	push   %edi
  8004b9:	e8 33 03 00 00       	call   8007f1 <strnlen>
  8004be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c1:	29 c1                	sub    %eax,%ecx
  8004c3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	eb 0f                	jmp    8004e6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	ff 75 e0             	pushl  -0x20(%ebp)
  8004de:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	83 ef 01             	sub    $0x1,%edi
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	85 ff                	test   %edi,%edi
  8004e8:	7f ed                	jg     8004d7 <vprintfmt+0x1cc>
  8004ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ed:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f0:	85 c9                	test   %ecx,%ecx
  8004f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f7:	0f 49 c1             	cmovns %ecx,%eax
  8004fa:	29 c1                	sub    %eax,%ecx
  8004fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800502:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800505:	89 cb                	mov    %ecx,%ebx
  800507:	eb 4d                	jmp    800556 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050d:	74 1b                	je     80052a <vprintfmt+0x21f>
  80050f:	0f be c0             	movsbl %al,%eax
  800512:	83 e8 20             	sub    $0x20,%eax
  800515:	83 f8 5e             	cmp    $0x5e,%eax
  800518:	76 10                	jbe    80052a <vprintfmt+0x21f>
					putch('?', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	6a 3f                	push   $0x3f
  800522:	ff 55 08             	call   *0x8(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 0d                	jmp    800537 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	52                   	push   %edx
  800531:	ff 55 08             	call   *0x8(%ebp)
  800534:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800537:	83 eb 01             	sub    $0x1,%ebx
  80053a:	eb 1a                	jmp    800556 <vprintfmt+0x24b>
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800548:	eb 0c                	jmp    800556 <vprintfmt+0x24b>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	83 c7 01             	add    $0x1,%edi
  800559:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055d:	0f be d0             	movsbl %al,%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	74 23                	je     800587 <vprintfmt+0x27c>
  800564:	85 f6                	test   %esi,%esi
  800566:	78 a1                	js     800509 <vprintfmt+0x1fe>
  800568:	83 ee 01             	sub    $0x1,%esi
  80056b:	79 9c                	jns    800509 <vprintfmt+0x1fe>
  80056d:	89 df                	mov    %ebx,%edi
  80056f:	8b 75 08             	mov    0x8(%ebp),%esi
  800572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800575:	eb 18                	jmp    80058f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	53                   	push   %ebx
  80057b:	6a 20                	push   $0x20
  80057d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057f:	83 ef 01             	sub    $0x1,%edi
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	eb 08                	jmp    80058f <vprintfmt+0x284>
  800587:	89 df                	mov    %ebx,%edi
  800589:	8b 75 08             	mov    0x8(%ebp),%esi
  80058c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058f:	85 ff                	test   %edi,%edi
  800591:	7f e4                	jg     800577 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800593:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059c:	e9 90 fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a1:	83 f9 01             	cmp    $0x1,%ecx
  8005a4:	7e 19                	jle    8005bf <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	eb 38                	jmp    8005f7 <vprintfmt+0x2ec>
	else if (lflag)
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	74 1b                	je     8005de <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 c1                	mov    %eax,%ecx
  8005cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb 19                	jmp    8005f7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 c1                	mov    %eax,%ecx
  8005e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 40 04             	lea    0x4(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800602:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800606:	0f 89 0e 01 00 00    	jns    80071a <vprintfmt+0x40f>
				putch('-', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 2d                	push   $0x2d
  800612:	ff d6                	call   *%esi
				num = -(long long) num;
  800614:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800617:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061a:	f7 da                	neg    %edx
  80061c:	83 d1 00             	adc    $0x0,%ecx
  80061f:	f7 d9                	neg    %ecx
  800621:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	e9 ec 00 00 00       	jmp    80071a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062e:	83 f9 01             	cmp    $0x1,%ecx
  800631:	7e 18                	jle    80064b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	8b 48 04             	mov    0x4(%eax),%ecx
  80063b:	8d 40 08             	lea    0x8(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800641:	b8 0a 00 00 00       	mov    $0xa,%eax
  800646:	e9 cf 00 00 00       	jmp    80071a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064b:	85 c9                	test   %ecx,%ecx
  80064d:	74 1a                	je     800669 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	b9 00 00 00 00       	mov    $0x0,%ecx
  800659:	8d 40 04             	lea    0x4(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800664:	e9 b1 00 00 00       	jmp    80071a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	e9 97 00 00 00       	jmp    80071a <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 58                	push   $0x58
  800689:	ff d6                	call   *%esi
			putch('X', putdat);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 58                	push   $0x58
  800691:	ff d6                	call   *%esi
			putch('X', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 58                	push   $0x58
  800699:	ff d6                	call   *%esi
			break;
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a1:	e9 8b fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 78                	push   $0x78
  8006b4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ce:	eb 4a                	jmp    80071a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 15                	jle    8006ea <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dd:	8d 40 08             	lea    0x8(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e8:	eb 30                	jmp    80071a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	74 17                	je     800705 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800703:	eb 15                	jmp    80071a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071a:	83 ec 0c             	sub    $0xc,%esp
  80071d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800721:	57                   	push   %edi
  800722:	ff 75 e0             	pushl  -0x20(%ebp)
  800725:	50                   	push   %eax
  800726:	51                   	push   %ecx
  800727:	52                   	push   %edx
  800728:	89 da                	mov    %ebx,%edx
  80072a:	89 f0                	mov    %esi,%eax
  80072c:	e8 f1 fa ff ff       	call   800222 <printnum>
			break;
  800731:	83 c4 20             	add    $0x20,%esp
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	e9 f5 fb ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	52                   	push   %edx
  800741:	ff d6                	call   *%esi
			break;
  800743:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800749:	e9 e3 fb ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 03                	jmp    80075e <vprintfmt+0x453>
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800762:	75 f7                	jne    80075b <vprintfmt+0x450>
  800764:	e9 c8 fb ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 18             	sub    $0x18,%esp
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800780:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800784:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 26                	je     8007b8 <vsnprintf+0x47>
  800792:	85 d2                	test   %edx,%edx
  800794:	7e 22                	jle    8007b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800796:	ff 75 14             	pushl  0x14(%ebp)
  800799:	ff 75 10             	pushl  0x10(%ebp)
  80079c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	68 d1 02 80 00       	push   $0x8002d1
  8007a5:	e8 61 fb ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	eb 05                	jmp    8007bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c8:	50                   	push   %eax
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	ff 75 08             	pushl  0x8(%ebp)
  8007d2:	e8 9a ff ff ff       	call   800771 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	eb 03                	jmp    8007e9 <strlen+0x10>
		n++;
  8007e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ed:	75 f7                	jne    8007e6 <strlen+0xd>
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ff:	eb 03                	jmp    800804 <strnlen+0x13>
		n++;
  800801:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	39 c2                	cmp    %eax,%edx
  800806:	74 08                	je     800810 <strnlen+0x1f>
  800808:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080c:	75 f3                	jne    800801 <strnlen+0x10>
  80080e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082b:	84 db                	test   %bl,%bl
  80082d:	75 ef                	jne    80081e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800839:	53                   	push   %ebx
  80083a:	e8 9a ff ff ff       	call   8007d9 <strlen>
  80083f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800842:	ff 75 0c             	pushl  0xc(%ebp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	50                   	push   %eax
  800848:	e8 c5 ff ff ff       	call   800812 <strcpy>
	return dst;
}
  80084d:	89 d8                	mov    %ebx,%eax
  80084f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	89 f3                	mov    %esi,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	89 f2                	mov    %esi,%edx
  800866:	eb 0f                	jmp    800877 <strncpy+0x23>
		*dst++ = *src;
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	0f b6 01             	movzbl (%ecx),%eax
  80086e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 39 01             	cmpb   $0x1,(%ecx)
  800874:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	39 da                	cmp    %ebx,%edx
  800879:	75 ed                	jne    800868 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087b:	89 f0                	mov    %esi,%eax
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
  800886:	8b 75 08             	mov    0x8(%ebp),%esi
  800889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088c:	8b 55 10             	mov    0x10(%ebp),%edx
  80088f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800891:	85 d2                	test   %edx,%edx
  800893:	74 21                	je     8008b6 <strlcpy+0x35>
  800895:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800899:	89 f2                	mov    %esi,%edx
  80089b:	eb 09                	jmp    8008a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a6:	39 c2                	cmp    %eax,%edx
  8008a8:	74 09                	je     8008b3 <strlcpy+0x32>
  8008aa:	0f b6 19             	movzbl (%ecx),%ebx
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ec                	jne    80089d <strlcpy+0x1c>
  8008b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b6:	29 f0                	sub    %esi,%eax
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c5:	eb 06                	jmp    8008cd <strcmp+0x11>
		p++, q++;
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cd:	0f b6 01             	movzbl (%ecx),%eax
  8008d0:	84 c0                	test   %al,%al
  8008d2:	74 04                	je     8008d8 <strcmp+0x1c>
  8008d4:	3a 02                	cmp    (%edx),%al
  8008d6:	74 ef                	je     8008c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 c0             	movzbl %al,%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x17>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 15                	je     800912 <strncmp+0x30>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x26>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
  800910:	eb 05                	jmp    800917 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 07                	jmp    80092d <strchr+0x13>
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 0f                	je     800939 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	eb 03                	jmp    80094a <strfind+0xf>
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 04                	je     800955 <strfind+0x1a>
  800951:	84 d2                	test   %dl,%dl
  800953:	75 f2                	jne    800947 <strfind+0xc>
			break;
	return (char *) s;
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800963:	85 c9                	test   %ecx,%ecx
  800965:	74 36                	je     80099d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800967:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096d:	75 28                	jne    800997 <memset+0x40>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 23                	jne    800997 <memset+0x40>
		c &= 0xFF;
  800974:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d3                	mov    %edx,%ebx
  80097a:	c1 e3 08             	shl    $0x8,%ebx
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 18             	shl    $0x18,%esi
  800982:	89 d0                	mov    %edx,%eax
  800984:	c1 e0 10             	shl    $0x10,%eax
  800987:	09 f0                	or     %esi,%eax
  800989:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098b:	89 d8                	mov    %ebx,%eax
  80098d:	09 d0                	or     %edx,%eax
  80098f:	c1 e9 02             	shr    $0x2,%ecx
  800992:	fc                   	cld    
  800993:	f3 ab                	rep stos %eax,%es:(%edi)
  800995:	eb 06                	jmp    80099d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	fc                   	cld    
  80099b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b2:	39 c6                	cmp    %eax,%esi
  8009b4:	73 35                	jae    8009eb <memmove+0x47>
  8009b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b9:	39 d0                	cmp    %edx,%eax
  8009bb:	73 2e                	jae    8009eb <memmove+0x47>
		s += n;
		d += n;
  8009bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	89 d6                	mov    %edx,%esi
  8009c2:	09 fe                	or     %edi,%esi
  8009c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ca:	75 13                	jne    8009df <memmove+0x3b>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0e                	jne    8009df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d1:	83 ef 04             	sub    $0x4,%edi
  8009d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
  8009da:	fd                   	std    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb 09                	jmp    8009e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009df:	83 ef 01             	sub    $0x1,%edi
  8009e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e5:	fd                   	std    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e8:	fc                   	cld    
  8009e9:	eb 1d                	jmp    800a08 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	89 f2                	mov    %esi,%edx
  8009ed:	09 c2                	or     %eax,%edx
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	75 0f                	jne    800a03 <memmove+0x5f>
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 0a                	jne    800a03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 05                	jmp    800a08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0f:	ff 75 10             	pushl  0x10(%ebp)
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	ff 75 08             	pushl  0x8(%ebp)
  800a18:	e8 87 ff ff ff       	call   8009a4 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	89 c6                	mov    %eax,%esi
  800a2c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	eb 1a                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	0f b6 1a             	movzbl (%edx),%ebx
  800a37:	38 d9                	cmp    %bl,%cl
  800a39:	74 0a                	je     800a45 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3b:	0f b6 c1             	movzbl %cl,%eax
  800a3e:	0f b6 db             	movzbl %bl,%ebx
  800a41:	29 d8                	sub    %ebx,%eax
  800a43:	eb 0f                	jmp    800a54 <memcmp+0x35>
		s1++, s2++;
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 f0                	cmp    %esi,%eax
  800a4d:	75 e2                	jne    800a31 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5f:	89 c1                	mov    %eax,%ecx
  800a61:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a64:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a68:	eb 0a                	jmp    800a74 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6a:	0f b6 10             	movzbl (%eax),%edx
  800a6d:	39 da                	cmp    %ebx,%edx
  800a6f:	74 07                	je     800a78 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	39 c8                	cmp    %ecx,%eax
  800a76:	72 f2                	jb     800a6a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	eb 03                	jmp    800a8c <strtol+0x11>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	3c 20                	cmp    $0x20,%al
  800a91:	74 f6                	je     800a89 <strtol+0xe>
  800a93:	3c 09                	cmp    $0x9,%al
  800a95:	74 f2                	je     800a89 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a97:	3c 2b                	cmp    $0x2b,%al
  800a99:	75 0a                	jne    800aa5 <strtol+0x2a>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa3:	eb 11                	jmp    800ab6 <strtol+0x3b>
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aaa:	3c 2d                	cmp    $0x2d,%al
  800aac:	75 08                	jne    800ab6 <strtol+0x3b>
		s++, neg = 1;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abc:	75 15                	jne    800ad3 <strtol+0x58>
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	75 10                	jne    800ad3 <strtol+0x58>
  800ac3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac7:	75 7c                	jne    800b45 <strtol+0xca>
		s += 2, base = 16;
  800ac9:	83 c1 02             	add    $0x2,%ecx
  800acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad1:	eb 16                	jmp    800ae9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad3:	85 db                	test   %ebx,%ebx
  800ad5:	75 12                	jne    800ae9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	80 39 30             	cmpb   $0x30,(%ecx)
  800adf:	75 08                	jne    800ae9 <strtol+0x6e>
		s++, base = 8;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af1:	0f b6 11             	movzbl (%ecx),%edx
  800af4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 09             	cmp    $0x9,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x8b>
			dig = *s - '0';
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 30             	sub    $0x30,%edx
  800b04:	eb 22                	jmp    800b28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 57             	sub    $0x57,%edx
  800b16:	eb 10                	jmp    800b28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 19             	cmp    $0x19,%bl
  800b20:	77 16                	ja     800b38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2b:	7d 0b                	jge    800b38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2d:	83 c1 01             	add    $0x1,%ecx
  800b30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b36:	eb b9                	jmp    800af1 <strtol+0x76>

	if (endptr)
  800b38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3c:	74 0d                	je     800b4b <strtol+0xd0>
		*endptr = (char *) s;
  800b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b41:	89 0e                	mov    %ecx,(%esi)
  800b43:	eb 06                	jmp    800b4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	74 98                	je     800ae1 <strtol+0x66>
  800b49:	eb 9e                	jmp    800ae9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	f7 da                	neg    %edx
  800b4f:	85 ff                	test   %edi,%edi
  800b51:	0f 45 c2             	cmovne %edx,%eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	89 c6                	mov    %eax,%esi
  800b70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	89 d1                	mov    %edx,%ecx
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	89 d7                	mov    %edx,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	89 cb                	mov    %ecx,%ebx
  800bae:	89 cf                	mov    %ecx,%edi
  800bb0:	89 ce                	mov    %ecx,%esi
  800bb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 03                	push   $0x3
  800bbe:	68 68 13 80 00       	push   $0x801368
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 85 13 80 00       	push   $0x801385
  800bca:	e8 66 f5 ff ff       	call   800135 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 02 00 00 00       	mov    $0x2,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_yield>:

void
sys_yield(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
  800c23:	b8 04 00 00 00       	mov    $0x4,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	89 f7                	mov    %esi,%edi
  800c33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 04                	push   $0x4
  800c3f:	68 68 13 80 00       	push   $0x801368
  800c44:	6a 23                	push   $0x23
  800c46:	68 85 13 80 00       	push   $0x801385
  800c4b:	e8 e5 f4 ff ff       	call   800135 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	b8 05 00 00 00       	mov    $0x5,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	8b 75 18             	mov    0x18(%ebp),%esi
  800c75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 05                	push   $0x5
  800c81:	68 68 13 80 00       	push   $0x801368
  800c86:	6a 23                	push   $0x23
  800c88:	68 85 13 80 00       	push   $0x801385
  800c8d:	e8 a3 f4 ff ff       	call   800135 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 06                	push   $0x6
  800cc3:	68 68 13 80 00       	push   $0x801368
  800cc8:	6a 23                	push   $0x23
  800cca:	68 85 13 80 00       	push   $0x801385
  800ccf:	e8 61 f4 ff ff       	call   800135 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 08 00 00 00       	mov    $0x8,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 08                	push   $0x8
  800d05:	68 68 13 80 00       	push   $0x801368
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 85 13 80 00       	push   $0x801385
  800d11:	e8 1f f4 ff ff       	call   800135 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 09                	push   $0x9
  800d47:	68 68 13 80 00       	push   $0x801368
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 85 13 80 00       	push   $0x801385
  800d53:	e8 dd f3 ff ff       	call   800135 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	be 00 00 00 00       	mov    $0x0,%esi
  800d6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 cb                	mov    %ecx,%ebx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	89 ce                	mov    %ecx,%esi
  800d9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 0c                	push   $0xc
  800dab:	68 68 13 80 00       	push   $0x801368
  800db0:	6a 23                	push   $0x23
  800db2:	68 85 13 80 00       	push   $0x801385
  800db7:	e8 79 f3 ff ff       	call   800135 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800dca:	68 9f 13 80 00       	push   $0x80139f
  800dcf:	6a 51                	push   $0x51
  800dd1:	68 93 13 80 00       	push   $0x801393
  800dd6:	e8 5a f3 ff ff       	call   800135 <_panic>

00800ddb <sfork>:
}

// Challenge!
int
sfork(void)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800de1:	68 9e 13 80 00       	push   $0x80139e
  800de6:	6a 58                	push   $0x58
  800de8:	68 93 13 80 00       	push   $0x801393
  800ded:	e8 43 f3 ff ff       	call   800135 <_panic>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	66 90                	xchg   %ax,%ax
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__udivdi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	85 f6                	test   %esi,%esi
  800e19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e1d:	89 ca                	mov    %ecx,%edx
  800e1f:	89 f8                	mov    %edi,%eax
  800e21:	75 3d                	jne    800e60 <__udivdi3+0x60>
  800e23:	39 cf                	cmp    %ecx,%edi
  800e25:	0f 87 c5 00 00 00    	ja     800ef0 <__udivdi3+0xf0>
  800e2b:	85 ff                	test   %edi,%edi
  800e2d:	89 fd                	mov    %edi,%ebp
  800e2f:	75 0b                	jne    800e3c <__udivdi3+0x3c>
  800e31:	b8 01 00 00 00       	mov    $0x1,%eax
  800e36:	31 d2                	xor    %edx,%edx
  800e38:	f7 f7                	div    %edi
  800e3a:	89 c5                	mov    %eax,%ebp
  800e3c:	89 c8                	mov    %ecx,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	f7 f5                	div    %ebp
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	89 cf                	mov    %ecx,%edi
  800e48:	f7 f5                	div    %ebp
  800e4a:	89 c3                	mov    %eax,%ebx
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	89 fa                	mov    %edi,%edx
  800e50:	83 c4 1c             	add    $0x1c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 ce                	cmp    %ecx,%esi
  800e62:	77 74                	ja     800ed8 <__udivdi3+0xd8>
  800e64:	0f bd fe             	bsr    %esi,%edi
  800e67:	83 f7 1f             	xor    $0x1f,%edi
  800e6a:	0f 84 98 00 00 00    	je     800f08 <__udivdi3+0x108>
  800e70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	89 c5                	mov    %eax,%ebp
  800e79:	29 fb                	sub    %edi,%ebx
  800e7b:	d3 e6                	shl    %cl,%esi
  800e7d:	89 d9                	mov    %ebx,%ecx
  800e7f:	d3 ed                	shr    %cl,%ebp
  800e81:	89 f9                	mov    %edi,%ecx
  800e83:	d3 e0                	shl    %cl,%eax
  800e85:	09 ee                	or     %ebp,%esi
  800e87:	89 d9                	mov    %ebx,%ecx
  800e89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8d:	89 d5                	mov    %edx,%ebp
  800e8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e93:	d3 ed                	shr    %cl,%ebp
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e2                	shl    %cl,%edx
  800e99:	89 d9                	mov    %ebx,%ecx
  800e9b:	d3 e8                	shr    %cl,%eax
  800e9d:	09 c2                	or     %eax,%edx
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	89 ea                	mov    %ebp,%edx
  800ea3:	f7 f6                	div    %esi
  800ea5:	89 d5                	mov    %edx,%ebp
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	f7 64 24 0c          	mull   0xc(%esp)
  800ead:	39 d5                	cmp    %edx,%ebp
  800eaf:	72 10                	jb     800ec1 <__udivdi3+0xc1>
  800eb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e6                	shl    %cl,%esi
  800eb9:	39 c6                	cmp    %eax,%esi
  800ebb:	73 07                	jae    800ec4 <__udivdi3+0xc4>
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	75 03                	jne    800ec4 <__udivdi3+0xc4>
  800ec1:	83 eb 01             	sub    $0x1,%ebx
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 d8                	mov    %ebx,%eax
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	31 ff                	xor    %edi,%edi
  800eda:	31 db                	xor    %ebx,%ebx
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	89 fa                	mov    %edi,%edx
  800ee0:	83 c4 1c             	add    $0x1c,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	f7 f7                	div    %edi
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 c3                	mov    %eax,%ebx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 fa                	mov    %edi,%edx
  800efc:	83 c4 1c             	add    $0x1c,%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	39 ce                	cmp    %ecx,%esi
  800f0a:	72 0c                	jb     800f18 <__udivdi3+0x118>
  800f0c:	31 db                	xor    %ebx,%ebx
  800f0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f12:	0f 87 34 ff ff ff    	ja     800e4c <__udivdi3+0x4c>
  800f18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f1d:	e9 2a ff ff ff       	jmp    800e4c <__udivdi3+0x4c>
  800f22:	66 90                	xchg   %ax,%ax
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 d2                	test   %edx,%edx
  800f49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 f3                	mov    %esi,%ebx
  800f53:	89 3c 24             	mov    %edi,(%esp)
  800f56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5a:	75 1c                	jne    800f78 <__umoddi3+0x48>
  800f5c:	39 f7                	cmp    %esi,%edi
  800f5e:	76 50                	jbe    800fb0 <__umoddi3+0x80>
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	f7 f7                	div    %edi
  800f66:	89 d0                	mov    %edx,%eax
  800f68:	31 d2                	xor    %edx,%edx
  800f6a:	83 c4 1c             	add    $0x1c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
  800f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f78:	39 f2                	cmp    %esi,%edx
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	77 52                	ja     800fd0 <__umoddi3+0xa0>
  800f7e:	0f bd ea             	bsr    %edx,%ebp
  800f81:	83 f5 1f             	xor    $0x1f,%ebp
  800f84:	75 5a                	jne    800fe0 <__umoddi3+0xb0>
  800f86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f8a:	0f 82 e0 00 00 00    	jb     801070 <__umoddi3+0x140>
  800f90:	39 0c 24             	cmp    %ecx,(%esp)
  800f93:	0f 86 d7 00 00 00    	jbe    801070 <__umoddi3+0x140>
  800f99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa1:	83 c4 1c             	add    $0x1c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	85 ff                	test   %edi,%edi
  800fb2:	89 fd                	mov    %edi,%ebp
  800fb4:	75 0b                	jne    800fc1 <__umoddi3+0x91>
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f7                	div    %edi
  800fbf:	89 c5                	mov    %eax,%ebp
  800fc1:	89 f0                	mov    %esi,%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	f7 f5                	div    %ebp
  800fc7:	89 c8                	mov    %ecx,%eax
  800fc9:	f7 f5                	div    %ebp
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	eb 99                	jmp    800f68 <__umoddi3+0x38>
  800fcf:	90                   	nop
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	83 c4 1c             	add    $0x1c,%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    
  800fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	8b 34 24             	mov    (%esp),%esi
  800fe3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fe8:	89 e9                	mov    %ebp,%ecx
  800fea:	29 ef                	sub    %ebp,%edi
  800fec:	d3 e0                	shl    %cl,%eax
  800fee:	89 f9                	mov    %edi,%ecx
  800ff0:	89 f2                	mov    %esi,%edx
  800ff2:	d3 ea                	shr    %cl,%edx
  800ff4:	89 e9                	mov    %ebp,%ecx
  800ff6:	09 c2                	or     %eax,%edx
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	89 14 24             	mov    %edx,(%esp)
  800ffd:	89 f2                	mov    %esi,%edx
  800fff:	d3 e2                	shl    %cl,%edx
  801001:	89 f9                	mov    %edi,%ecx
  801003:	89 54 24 04          	mov    %edx,0x4(%esp)
  801007:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	89 e9                	mov    %ebp,%ecx
  80100f:	89 c6                	mov    %eax,%esi
  801011:	d3 e3                	shl    %cl,%ebx
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 d0                	mov    %edx,%eax
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	09 d8                	or     %ebx,%eax
  80101d:	89 d3                	mov    %edx,%ebx
  80101f:	89 f2                	mov    %esi,%edx
  801021:	f7 34 24             	divl   (%esp)
  801024:	89 d6                	mov    %edx,%esi
  801026:	d3 e3                	shl    %cl,%ebx
  801028:	f7 64 24 04          	mull   0x4(%esp)
  80102c:	39 d6                	cmp    %edx,%esi
  80102e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801032:	89 d1                	mov    %edx,%ecx
  801034:	89 c3                	mov    %eax,%ebx
  801036:	72 08                	jb     801040 <__umoddi3+0x110>
  801038:	75 11                	jne    80104b <__umoddi3+0x11b>
  80103a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80103e:	73 0b                	jae    80104b <__umoddi3+0x11b>
  801040:	2b 44 24 04          	sub    0x4(%esp),%eax
  801044:	1b 14 24             	sbb    (%esp),%edx
  801047:	89 d1                	mov    %edx,%ecx
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80104f:	29 da                	sub    %ebx,%edx
  801051:	19 ce                	sbb    %ecx,%esi
  801053:	89 f9                	mov    %edi,%ecx
  801055:	89 f0                	mov    %esi,%eax
  801057:	d3 e0                	shl    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	d3 ea                	shr    %cl,%edx
  80105d:	89 e9                	mov    %ebp,%ecx
  80105f:	d3 ee                	shr    %cl,%esi
  801061:	09 d0                	or     %edx,%eax
  801063:	89 f2                	mov    %esi,%edx
  801065:	83 c4 1c             	add    $0x1c,%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	29 f9                	sub    %edi,%ecx
  801072:	19 d6                	sbb    %edx,%esi
  801074:	89 74 24 04          	mov    %esi,0x4(%esp)
  801078:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80107c:	e9 18 ff ff ff       	jmp    800f99 <__umoddi3+0x69>
