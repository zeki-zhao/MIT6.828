
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 b9 0c 00 00       	call   800d03 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 60 11 80 00       	push   $0x801160
  800057:	6a 20                	push   $0x20
  800059:	68 73 11 80 00       	push   $0x801173
  80005e:	e8 c0 01 00 00       	call   800223 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 d0 0c 00 00       	call   800d46 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 83 11 80 00       	push   $0x801183
  800083:	6a 22                	push   $0x22
  800085:	68 73 11 80 00       	push   $0x801173
  80008a:	e8 94 01 00 00       	call   800223 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 f0 09 00 00       	call   800a92 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 d7 0c 00 00       	call   800d88 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 94 11 80 00       	push   $0x801194
  8000be:	6a 25                	push   $0x25
  8000c0:	68 73 11 80 00       	push   $0x801173
  8000c5:	e8 59 01 00 00       	call   800223 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 a7 11 80 00       	push   $0x8011a7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 73 11 80 00       	push   $0x801173
  8000f3:	e8 2b 01 00 00       	call   800223 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 c2 0b 00 00       	call   800cc5 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 69 0c 00 00       	call   800dca <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 b7 11 80 00       	push   $0x8011b7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 73 11 80 00       	push   $0x801173
  800175:	e8 a9 00 00 00       	call   800223 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be d5 11 80 00       	mov    $0x8011d5,%esi
  80019a:	b8 ce 11 80 00       	mov    $0x8011ce,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 db 11 80 00       	push   $0x8011db
  8001b3:	e8 44 01 00 00       	call   8002fc <cprintf>
		sys_yield();
  8001b8:	e8 27 0b 00 00       	call   800ce4 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e7:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8001ee:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 08                	jle    8001fd <libmain+0x22>
		binaryname = argv[0];
  8001f5:	8b 0a                	mov    (%edx),%ecx
  8001f7:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	52                   	push   %edx
  800201:	50                   	push   %eax
  800202:	e8 7c ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800207:	e8 05 00 00 00       	call   800211 <exit>
}
  80020c:	83 c4 10             	add    $0x10,%esp
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800217:	6a 00                	push   $0x0
  800219:	e8 66 0a 00 00       	call   800c84 <sys_env_destroy>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800228:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800231:	e8 8f 0a 00 00       	call   800cc5 <sys_getenvid>
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	56                   	push   %esi
  800240:	50                   	push   %eax
  800241:	68 f8 11 80 00       	push   $0x8011f8
  800246:	e8 b1 00 00 00       	call   8002fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024b:	83 c4 18             	add    $0x18,%esp
  80024e:	53                   	push   %ebx
  80024f:	ff 75 10             	pushl  0x10(%ebp)
  800252:	e8 54 00 00 00       	call   8002ab <vcprintf>
	cprintf("\n");
  800257:	c7 04 24 eb 11 80 00 	movl   $0x8011eb,(%esp)
  80025e:	e8 99 00 00 00       	call   8002fc <cprintf>
  800263:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800266:	cc                   	int3   
  800267:	eb fd                	jmp    800266 <_panic+0x43>

00800269 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	53                   	push   %ebx
  80026d:	83 ec 04             	sub    $0x4,%esp
  800270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800273:	8b 13                	mov    (%ebx),%edx
  800275:	8d 42 01             	lea    0x1(%edx),%eax
  800278:	89 03                	mov    %eax,(%ebx)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800281:	3d ff 00 00 00       	cmp    $0xff,%eax
  800286:	75 1a                	jne    8002a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	68 ff 00 00 00       	push   $0xff
  800290:	8d 43 08             	lea    0x8(%ebx),%eax
  800293:	50                   	push   %eax
  800294:	e8 ae 09 00 00       	call   800c47 <sys_cputs>
		b->idx = 0;
  800299:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bb:	00 00 00 
	b.cnt = 0;
  8002be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c8:	ff 75 0c             	pushl  0xc(%ebp)
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d4:	50                   	push   %eax
  8002d5:	68 69 02 80 00       	push   $0x800269
  8002da:	e8 1a 01 00 00       	call   8003f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002df:	83 c4 08             	add    $0x8,%esp
  8002e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ee:	50                   	push   %eax
  8002ef:	e8 53 09 00 00       	call   800c47 <sys_cputs>

	return b.cnt;
}
  8002f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800302:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800305:	50                   	push   %eax
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	e8 9d ff ff ff       	call   8002ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 1c             	sub    $0x1c,%esp
  800319:	89 c7                	mov    %eax,%edi
  80031b:	89 d6                	mov    %edx,%esi
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	8b 55 0c             	mov    0xc(%ebp),%edx
  800323:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800326:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800329:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80032c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800331:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800334:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800337:	39 d3                	cmp    %edx,%ebx
  800339:	72 05                	jb     800340 <printnum+0x30>
  80033b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033e:	77 45                	ja     800385 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	ff 75 18             	pushl  0x18(%ebp)
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80034c:	53                   	push   %ebx
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	ff 75 e4             	pushl  -0x1c(%ebp)
  800356:	ff 75 e0             	pushl  -0x20(%ebp)
  800359:	ff 75 dc             	pushl  -0x24(%ebp)
  80035c:	ff 75 d8             	pushl  -0x28(%ebp)
  80035f:	e8 5c 0b 00 00       	call   800ec0 <__udivdi3>
  800364:	83 c4 18             	add    $0x18,%esp
  800367:	52                   	push   %edx
  800368:	50                   	push   %eax
  800369:	89 f2                	mov    %esi,%edx
  80036b:	89 f8                	mov    %edi,%eax
  80036d:	e8 9e ff ff ff       	call   800310 <printnum>
  800372:	83 c4 20             	add    $0x20,%esp
  800375:	eb 18                	jmp    80038f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	56                   	push   %esi
  80037b:	ff 75 18             	pushl  0x18(%ebp)
  80037e:	ff d7                	call   *%edi
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	eb 03                	jmp    800388 <printnum+0x78>
  800385:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800388:	83 eb 01             	sub    $0x1,%ebx
  80038b:	85 db                	test   %ebx,%ebx
  80038d:	7f e8                	jg     800377 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	83 ec 04             	sub    $0x4,%esp
  800396:	ff 75 e4             	pushl  -0x1c(%ebp)
  800399:	ff 75 e0             	pushl  -0x20(%ebp)
  80039c:	ff 75 dc             	pushl  -0x24(%ebp)
  80039f:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a2:	e8 49 0c 00 00       	call   800ff0 <__umoddi3>
  8003a7:	83 c4 14             	add    $0x14,%esp
  8003aa:	0f be 80 1c 12 80 00 	movsbl 0x80121c(%eax),%eax
  8003b1:	50                   	push   %eax
  8003b2:	ff d7                	call   *%edi
}
  8003b4:	83 c4 10             	add    $0x10,%esp
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	88 02                	mov    %al,(%edx)
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e5:	50                   	push   %eax
  8003e6:	ff 75 10             	pushl  0x10(%ebp)
  8003e9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ec:	ff 75 08             	pushl  0x8(%ebp)
  8003ef:	e8 05 00 00 00       	call   8003f9 <vprintfmt>
	va_end(ap);
}
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	c9                   	leave  
  8003f8:	c3                   	ret    

008003f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	57                   	push   %edi
  8003fd:	56                   	push   %esi
  8003fe:	53                   	push   %ebx
  8003ff:	83 ec 2c             	sub    $0x2c,%esp
  800402:	8b 75 08             	mov    0x8(%ebp),%esi
  800405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800408:	8b 7d 10             	mov    0x10(%ebp),%edi
  80040b:	eb 12                	jmp    80041f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040d:	85 c0                	test   %eax,%eax
  80040f:	0f 84 42 04 00 00    	je     800857 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	50                   	push   %eax
  80041a:	ff d6                	call   *%esi
  80041c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041f:	83 c7 01             	add    $0x1,%edi
  800422:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800426:	83 f8 25             	cmp    $0x25,%eax
  800429:	75 e2                	jne    80040d <vprintfmt+0x14>
  80042b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800436:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800444:	b9 00 00 00 00       	mov    $0x0,%ecx
  800449:	eb 07                	jmp    800452 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8d 47 01             	lea    0x1(%edi),%eax
  800455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800458:	0f b6 07             	movzbl (%edi),%eax
  80045b:	0f b6 d0             	movzbl %al,%edx
  80045e:	83 e8 23             	sub    $0x23,%eax
  800461:	3c 55                	cmp    $0x55,%al
  800463:	0f 87 d3 03 00 00    	ja     80083c <vprintfmt+0x443>
  800469:	0f b6 c0             	movzbl %al,%eax
  80046c:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800476:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80047a:	eb d6                	jmp    800452 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800487:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80048a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80048e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800491:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800494:	83 f9 09             	cmp    $0x9,%ecx
  800497:	77 3f                	ja     8004d8 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800499:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80049c:	eb e9                	jmp    800487 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 40 04             	lea    0x4(%eax),%eax
  8004ac:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b2:	eb 2a                	jmp    8004de <vprintfmt+0xe5>
  8004b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	0f 49 d0             	cmovns %eax,%edx
  8004c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c7:	eb 89                	jmp    800452 <vprintfmt+0x59>
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d3:	e9 7a ff ff ff       	jmp    800452 <vprintfmt+0x59>
  8004d8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004db:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e2:	0f 89 6a ff ff ff    	jns    800452 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f5:	e9 58 ff ff ff       	jmp    800452 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fa:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800500:	e9 4d ff ff ff       	jmp    800452 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 78 04             	lea    0x4(%eax),%edi
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	ff 30                	pushl  (%eax)
  800511:	ff d6                	call   *%esi
			break;
  800513:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800516:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051c:	e9 fe fe ff ff       	jmp    80041f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 78 04             	lea    0x4(%eax),%edi
  800527:	8b 00                	mov    (%eax),%eax
  800529:	99                   	cltd   
  80052a:	31 d0                	xor    %edx,%eax
  80052c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052e:	83 f8 09             	cmp    $0x9,%eax
  800531:	7f 0b                	jg     80053e <vprintfmt+0x145>
  800533:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  80053a:	85 d2                	test   %edx,%edx
  80053c:	75 1b                	jne    800559 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80053e:	50                   	push   %eax
  80053f:	68 34 12 80 00       	push   $0x801234
  800544:	53                   	push   %ebx
  800545:	56                   	push   %esi
  800546:	e8 91 fe ff ff       	call   8003dc <printfmt>
  80054b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800554:	e9 c6 fe ff ff       	jmp    80041f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800559:	52                   	push   %edx
  80055a:	68 3d 12 80 00       	push   $0x80123d
  80055f:	53                   	push   %ebx
  800560:	56                   	push   %esi
  800561:	e8 76 fe ff ff       	call   8003dc <printfmt>
  800566:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800569:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056f:	e9 ab fe ff ff       	jmp    80041f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	83 c0 04             	add    $0x4,%eax
  80057a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800582:	85 ff                	test   %edi,%edi
  800584:	b8 2d 12 80 00       	mov    $0x80122d,%eax
  800589:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80058c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800590:	0f 8e 94 00 00 00    	jle    80062a <vprintfmt+0x231>
  800596:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80059a:	0f 84 98 00 00 00    	je     800638 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a6:	57                   	push   %edi
  8005a7:	e8 33 03 00 00       	call   8008df <strnlen>
  8005ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005af:	29 c1                	sub    %eax,%ecx
  8005b1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	eb 0f                	jmp    8005d4 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005cc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	83 ef 01             	sub    $0x1,%edi
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f ed                	jg     8005c5 <vprintfmt+0x1cc>
  8005d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005db:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e5:	0f 49 c1             	cmovns %ecx,%eax
  8005e8:	29 c1                	sub    %eax,%ecx
  8005ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f3:	89 cb                	mov    %ecx,%ebx
  8005f5:	eb 4d                	jmp    800644 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fb:	74 1b                	je     800618 <vprintfmt+0x21f>
  8005fd:	0f be c0             	movsbl %al,%eax
  800600:	83 e8 20             	sub    $0x20,%eax
  800603:	83 f8 5e             	cmp    $0x5e,%eax
  800606:	76 10                	jbe    800618 <vprintfmt+0x21f>
					putch('?', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	6a 3f                	push   $0x3f
  800610:	ff 55 08             	call   *0x8(%ebp)
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	eb 0d                	jmp    800625 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	ff 75 0c             	pushl  0xc(%ebp)
  80061e:	52                   	push   %edx
  80061f:	ff 55 08             	call   *0x8(%ebp)
  800622:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800625:	83 eb 01             	sub    $0x1,%ebx
  800628:	eb 1a                	jmp    800644 <vprintfmt+0x24b>
  80062a:	89 75 08             	mov    %esi,0x8(%ebp)
  80062d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800630:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800633:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800636:	eb 0c                	jmp    800644 <vprintfmt+0x24b>
  800638:	89 75 08             	mov    %esi,0x8(%ebp)
  80063b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800641:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800644:	83 c7 01             	add    $0x1,%edi
  800647:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80064b:	0f be d0             	movsbl %al,%edx
  80064e:	85 d2                	test   %edx,%edx
  800650:	74 23                	je     800675 <vprintfmt+0x27c>
  800652:	85 f6                	test   %esi,%esi
  800654:	78 a1                	js     8005f7 <vprintfmt+0x1fe>
  800656:	83 ee 01             	sub    $0x1,%esi
  800659:	79 9c                	jns    8005f7 <vprintfmt+0x1fe>
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800663:	eb 18                	jmp    80067d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 20                	push   $0x20
  80066b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066d:	83 ef 01             	sub    $0x1,%edi
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb 08                	jmp    80067d <vprintfmt+0x284>
  800675:	89 df                	mov    %ebx,%edi
  800677:	8b 75 08             	mov    0x8(%ebp),%esi
  80067a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067d:	85 ff                	test   %edi,%edi
  80067f:	7f e4                	jg     800665 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800681:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068a:	e9 90 fd ff ff       	jmp    80041f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 19                	jle    8006ad <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 50 04             	mov    0x4(%eax),%edx
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 40 08             	lea    0x8(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ab:	eb 38                	jmp    8006e5 <vprintfmt+0x2ec>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	74 1b                	je     8006cc <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 00                	mov    (%eax),%eax
  8006b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b9:	89 c1                	mov    %eax,%ecx
  8006bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ca:	eb 19                	jmp    8006e5 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 c1                	mov    %eax,%ecx
  8006d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006eb:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f4:	0f 89 0e 01 00 00    	jns    800808 <vprintfmt+0x40f>
				putch('-', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 2d                	push   $0x2d
  800700:	ff d6                	call   *%esi
				num = -(long long) num;
  800702:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800705:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800708:	f7 da                	neg    %edx
  80070a:	83 d1 00             	adc    $0x0,%ecx
  80070d:	f7 d9                	neg    %ecx
  80070f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	e9 ec 00 00 00       	jmp    800808 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071c:	83 f9 01             	cmp    $0x1,%ecx
  80071f:	7e 18                	jle    800739 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	8b 48 04             	mov    0x4(%eax),%ecx
  800729:	8d 40 08             	lea    0x8(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80072f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800734:	e9 cf 00 00 00       	jmp    800808 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800739:	85 c9                	test   %ecx,%ecx
  80073b:	74 1a                	je     800757 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80074d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800752:	e9 b1 00 00 00       	jmp    800808 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800761:	8d 40 04             	lea    0x4(%eax),%eax
  800764:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800767:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076c:	e9 97 00 00 00       	jmp    800808 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 58                	push   $0x58
  800777:	ff d6                	call   *%esi
			putch('X', putdat);
  800779:	83 c4 08             	add    $0x8,%esp
  80077c:	53                   	push   %ebx
  80077d:	6a 58                	push   $0x58
  80077f:	ff d6                	call   *%esi
			putch('X', putdat);
  800781:	83 c4 08             	add    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 58                	push   $0x58
  800787:	ff d6                	call   *%esi
			break;
  800789:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80078f:	e9 8b fc ff ff       	jmp    80041f <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 30                	push   $0x30
  80079a:	ff d6                	call   *%esi
			putch('x', putdat);
  80079c:	83 c4 08             	add    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 78                	push   $0x78
  8007a2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ae:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bc:	eb 4a                	jmp    800808 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 f9 01             	cmp    $0x1,%ecx
  8007c1:	7e 15                	jle    8007d8 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d6:	eb 30                	jmp    800808 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007d8:	85 c9                	test   %ecx,%ecx
  8007da:	74 17                	je     8007f3 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8b 10                	mov    (%eax),%edx
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e6:	8d 40 04             	lea    0x4(%eax),%eax
  8007e9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f1:	eb 15                	jmp    800808 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800803:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800808:	83 ec 0c             	sub    $0xc,%esp
  80080b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80080f:	57                   	push   %edi
  800810:	ff 75 e0             	pushl  -0x20(%ebp)
  800813:	50                   	push   %eax
  800814:	51                   	push   %ecx
  800815:	52                   	push   %edx
  800816:	89 da                	mov    %ebx,%edx
  800818:	89 f0                	mov    %esi,%eax
  80081a:	e8 f1 fa ff ff       	call   800310 <printnum>
			break;
  80081f:	83 c4 20             	add    $0x20,%esp
  800822:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800825:	e9 f5 fb ff ff       	jmp    80041f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	52                   	push   %edx
  80082f:	ff d6                	call   *%esi
			break;
  800831:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800837:	e9 e3 fb ff ff       	jmp    80041f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 25                	push   $0x25
  800842:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 03                	jmp    80084c <vprintfmt+0x453>
  800849:	83 ef 01             	sub    $0x1,%edi
  80084c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800850:	75 f7                	jne    800849 <vprintfmt+0x450>
  800852:	e9 c8 fb ff ff       	jmp    80041f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800857:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5f                   	pop    %edi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 18             	sub    $0x18,%esp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800872:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800875:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087c:	85 c0                	test   %eax,%eax
  80087e:	74 26                	je     8008a6 <vsnprintf+0x47>
  800880:	85 d2                	test   %edx,%edx
  800882:	7e 22                	jle    8008a6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800884:	ff 75 14             	pushl  0x14(%ebp)
  800887:	ff 75 10             	pushl  0x10(%ebp)
  80088a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088d:	50                   	push   %eax
  80088e:	68 bf 03 80 00       	push   $0x8003bf
  800893:	e8 61 fb ff ff       	call   8003f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800898:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	eb 05                	jmp    8008ab <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	ff 75 08             	pushl  0x8(%ebp)
  8008c0:	e8 9a ff ff ff       	call   80085f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb 03                	jmp    8008d7 <strlen+0x10>
		n++;
  8008d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008db:	75 f7                	jne    8008d4 <strlen+0xd>
		n++;
	return n;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ed:	eb 03                	jmp    8008f2 <strnlen+0x13>
		n++;
  8008ef:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f2:	39 c2                	cmp    %eax,%edx
  8008f4:	74 08                	je     8008fe <strnlen+0x1f>
  8008f6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008fa:	75 f3                	jne    8008ef <strnlen+0x10>
  8008fc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	83 c1 01             	add    $0x1,%ecx
  800912:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800916:	88 5a ff             	mov    %bl,-0x1(%edx)
  800919:	84 db                	test   %bl,%bl
  80091b:	75 ef                	jne    80090c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091d:	5b                   	pop    %ebx
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800927:	53                   	push   %ebx
  800928:	e8 9a ff ff ff       	call   8008c7 <strlen>
  80092d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	01 d8                	add    %ebx,%eax
  800935:	50                   	push   %eax
  800936:	e8 c5 ff ff ff       	call   800900 <strcpy>
	return dst;
}
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 75 08             	mov    0x8(%ebp),%esi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800952:	89 f2                	mov    %esi,%edx
  800954:	eb 0f                	jmp    800965 <strncpy+0x23>
		*dst++ = *src;
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095f:	80 39 01             	cmpb   $0x1,(%ecx)
  800962:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	39 da                	cmp    %ebx,%edx
  800967:	75 ed                	jne    800956 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800969:	89 f0                	mov    %esi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 75 08             	mov    0x8(%ebp),%esi
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097a:	8b 55 10             	mov    0x10(%ebp),%edx
  80097d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097f:	85 d2                	test   %edx,%edx
  800981:	74 21                	je     8009a4 <strlcpy+0x35>
  800983:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800987:	89 f2                	mov    %esi,%edx
  800989:	eb 09                	jmp    800994 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098b:	83 c2 01             	add    $0x1,%edx
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800994:	39 c2                	cmp    %eax,%edx
  800996:	74 09                	je     8009a1 <strlcpy+0x32>
  800998:	0f b6 19             	movzbl (%ecx),%ebx
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ec                	jne    80098b <strlcpy+0x1c>
  80099f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a4:	29 f0                	sub    %esi,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b3:	eb 06                	jmp    8009bb <strcmp+0x11>
		p++, q++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	84 c0                	test   %al,%al
  8009c0:	74 04                	je     8009c6 <strcmp+0x1c>
  8009c2:	3a 02                	cmp    (%edx),%al
  8009c4:	74 ef                	je     8009b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 c0             	movzbl %al,%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009da:	89 c3                	mov    %eax,%ebx
  8009dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009df:	eb 06                	jmp    8009e7 <strncmp+0x17>
		n--, p++, q++;
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e7:	39 d8                	cmp    %ebx,%eax
  8009e9:	74 15                	je     800a00 <strncmp+0x30>
  8009eb:	0f b6 08             	movzbl (%eax),%ecx
  8009ee:	84 c9                	test   %cl,%cl
  8009f0:	74 04                	je     8009f6 <strncmp+0x26>
  8009f2:	3a 0a                	cmp    (%edx),%cl
  8009f4:	74 eb                	je     8009e1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f6:	0f b6 00             	movzbl (%eax),%eax
  8009f9:	0f b6 12             	movzbl (%edx),%edx
  8009fc:	29 d0                	sub    %edx,%eax
  8009fe:	eb 05                	jmp    800a05 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a05:	5b                   	pop    %ebx
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a12:	eb 07                	jmp    800a1b <strchr+0x13>
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 0f                	je     800a27 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	0f b6 10             	movzbl (%eax),%edx
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	75 f2                	jne    800a14 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 03                	jmp    800a38 <strfind+0xf>
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 04                	je     800a43 <strfind+0x1a>
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strfind+0xc>
			break;
	return (char *) s;
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	74 36                	je     800a8b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 28                	jne    800a85 <memset+0x40>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 23                	jne    800a85 <memset+0x40>
		c &= 0xFF;
  800a62:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a66:	89 d3                	mov    %edx,%ebx
  800a68:	c1 e3 08             	shl    $0x8,%ebx
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	c1 e6 18             	shl    $0x18,%esi
  800a70:	89 d0                	mov    %edx,%eax
  800a72:	c1 e0 10             	shl    $0x10,%eax
  800a75:	09 f0                	or     %esi,%eax
  800a77:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	09 d0                	or     %edx,%eax
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
  800a80:	fc                   	cld    
  800a81:	f3 ab                	rep stos %eax,%es:(%edi)
  800a83:	eb 06                	jmp    800a8b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a88:	fc                   	cld    
  800a89:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8b:	89 f8                	mov    %edi,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa0:	39 c6                	cmp    %eax,%esi
  800aa2:	73 35                	jae    800ad9 <memmove+0x47>
  800aa4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa7:	39 d0                	cmp    %edx,%eax
  800aa9:	73 2e                	jae    800ad9 <memmove+0x47>
		s += n;
		d += n;
  800aab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	89 d6                	mov    %edx,%esi
  800ab0:	09 fe                	or     %edi,%esi
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 13                	jne    800acd <memmove+0x3b>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 0e                	jne    800acd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800abf:	83 ef 04             	sub    $0x4,%edi
  800ac2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac5:	c1 e9 02             	shr    $0x2,%ecx
  800ac8:	fd                   	std    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 09                	jmp    800ad6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800acd:	83 ef 01             	sub    $0x1,%edi
  800ad0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad3:	fd                   	std    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad6:	fc                   	cld    
  800ad7:	eb 1d                	jmp    800af6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad9:	89 f2                	mov    %esi,%edx
  800adb:	09 c2                	or     %eax,%edx
  800add:	f6 c2 03             	test   $0x3,%dl
  800ae0:	75 0f                	jne    800af1 <memmove+0x5f>
  800ae2:	f6 c1 03             	test   $0x3,%cl
  800ae5:	75 0a                	jne    800af1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
  800aea:	89 c7                	mov    %eax,%edi
  800aec:	fc                   	cld    
  800aed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aef:	eb 05                	jmp    800af6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afd:	ff 75 10             	pushl  0x10(%ebp)
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	ff 75 08             	pushl  0x8(%ebp)
  800b06:	e8 87 ff ff ff       	call   800a92 <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b18:	89 c6                	mov    %eax,%esi
  800b1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1d:	eb 1a                	jmp    800b39 <memcmp+0x2c>
		if (*s1 != *s2)
  800b1f:	0f b6 08             	movzbl (%eax),%ecx
  800b22:	0f b6 1a             	movzbl (%edx),%ebx
  800b25:	38 d9                	cmp    %bl,%cl
  800b27:	74 0a                	je     800b33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c1             	movzbl %cl,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 0f                	jmp    800b42 <memcmp+0x35>
		s1++, s2++;
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b39:	39 f0                	cmp    %esi,%eax
  800b3b:	75 e2                	jne    800b1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4d:	89 c1                	mov    %eax,%ecx
  800b4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b52:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b56:	eb 0a                	jmp    800b62 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	39 da                	cmp    %ebx,%edx
  800b5d:	74 07                	je     800b66 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5f:	83 c0 01             	add    $0x1,%eax
  800b62:	39 c8                	cmp    %ecx,%eax
  800b64:	72 f2                	jb     800b58 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b66:	5b                   	pop    %ebx
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	eb 03                	jmp    800b7a <strtol+0x11>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 01             	movzbl (%ecx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 f6                	je     800b77 <strtol+0xe>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	74 f2                	je     800b77 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b85:	3c 2b                	cmp    $0x2b,%al
  800b87:	75 0a                	jne    800b93 <strtol+0x2a>
		s++;
  800b89:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	eb 11                	jmp    800ba4 <strtol+0x3b>
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b98:	3c 2d                	cmp    $0x2d,%al
  800b9a:	75 08                	jne    800ba4 <strtol+0x3b>
		s++, neg = 1;
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800baa:	75 15                	jne    800bc1 <strtol+0x58>
  800bac:	80 39 30             	cmpb   $0x30,(%ecx)
  800baf:	75 10                	jne    800bc1 <strtol+0x58>
  800bb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb5:	75 7c                	jne    800c33 <strtol+0xca>
		s += 2, base = 16;
  800bb7:	83 c1 02             	add    $0x2,%ecx
  800bba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbf:	eb 16                	jmp    800bd7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bc1:	85 db                	test   %ebx,%ebx
  800bc3:	75 12                	jne    800bd7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bca:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcd:	75 08                	jne    800bd7 <strtol+0x6e>
		s++, base = 8;
  800bcf:	83 c1 01             	add    $0x1,%ecx
  800bd2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bdf:	0f b6 11             	movzbl (%ecx),%edx
  800be2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 09             	cmp    $0x9,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0x8b>
			dig = *s - '0';
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 30             	sub    $0x30,%edx
  800bf2:	eb 22                	jmp    800c16 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bf4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf7:	89 f3                	mov    %esi,%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 08                	ja     800c06 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bfe:	0f be d2             	movsbl %dl,%edx
  800c01:	83 ea 57             	sub    $0x57,%edx
  800c04:	eb 10                	jmp    800c16 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 16                	ja     800c26 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c10:	0f be d2             	movsbl %dl,%edx
  800c13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c19:	7d 0b                	jge    800c26 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c1b:	83 c1 01             	add    $0x1,%ecx
  800c1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c22:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c24:	eb b9                	jmp    800bdf <strtol+0x76>

	if (endptr)
  800c26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2a:	74 0d                	je     800c39 <strtol+0xd0>
		*endptr = (char *) s;
  800c2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2f:	89 0e                	mov    %ecx,(%esi)
  800c31:	eb 06                	jmp    800c39 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	74 98                	je     800bcf <strtol+0x66>
  800c37:	eb 9e                	jmp    800bd7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	f7 da                	neg    %edx
  800c3d:	85 ff                	test   %edi,%edi
  800c3f:	0f 45 c2             	cmovne %edx,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	89 c7                	mov    %eax,%edi
  800c5c:	89 c6                	mov    %eax,%esi
  800c5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 01 00 00 00       	mov    $0x1,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c92:	b8 03 00 00 00       	mov    $0x3,%eax
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 cb                	mov    %ecx,%ebx
  800c9c:	89 cf                	mov    %ecx,%edi
  800c9e:	89 ce                	mov    %ecx,%esi
  800ca0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 03                	push   $0x3
  800cac:	68 68 14 80 00       	push   $0x801468
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 85 14 80 00       	push   $0x801485
  800cb8:	e8 66 f5 ff ff       	call   800223 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 04 00 00 00       	mov    $0x4,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	89 f7                	mov    %esi,%edi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 04                	push   $0x4
  800d2d:	68 68 14 80 00       	push   $0x801468
  800d32:	6a 23                	push   $0x23
  800d34:	68 85 14 80 00       	push   $0x801485
  800d39:	e8 e5 f4 ff ff       	call   800223 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d60:	8b 75 18             	mov    0x18(%ebp),%esi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 05                	push   $0x5
  800d6f:	68 68 14 80 00       	push   $0x801468
  800d74:	6a 23                	push   $0x23
  800d76:	68 85 14 80 00       	push   $0x801485
  800d7b:	e8 a3 f4 ff ff       	call   800223 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 06                	push   $0x6
  800db1:	68 68 14 80 00       	push   $0x801468
  800db6:	6a 23                	push   $0x23
  800db8:	68 85 14 80 00       	push   $0x801485
  800dbd:	e8 61 f4 ff ff       	call   800223 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 17                	jle    800e04 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 08                	push   $0x8
  800df3:	68 68 14 80 00       	push   $0x801468
  800df8:	6a 23                	push   $0x23
  800dfa:	68 85 14 80 00       	push   $0x801485
  800dff:	e8 1f f4 ff ff       	call   800223 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 09                	push   $0x9
  800e35:	68 68 14 80 00       	push   $0x801468
  800e3a:	6a 23                	push   $0x23
  800e3c:	68 85 14 80 00       	push   $0x801485
  800e41:	e8 dd f3 ff ff       	call   800223 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	be 00 00 00 00       	mov    $0x0,%esi
  800e59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	89 cb                	mov    %ecx,%ebx
  800e89:	89 cf                	mov    %ecx,%edi
  800e8b:	89 ce                	mov    %ecx,%esi
  800e8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 17                	jle    800eaa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 0c                	push   $0xc
  800e99:	68 68 14 80 00       	push   $0x801468
  800e9e:	6a 23                	push   $0x23
  800ea0:	68 85 14 80 00       	push   $0x801485
  800ea5:	e8 79 f3 ff ff       	call   800223 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__udivdi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ecb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ecf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 f6                	test   %esi,%esi
  800ed9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800edd:	89 ca                	mov    %ecx,%edx
  800edf:	89 f8                	mov    %edi,%eax
  800ee1:	75 3d                	jne    800f20 <__udivdi3+0x60>
  800ee3:	39 cf                	cmp    %ecx,%edi
  800ee5:	0f 87 c5 00 00 00    	ja     800fb0 <__udivdi3+0xf0>
  800eeb:	85 ff                	test   %edi,%edi
  800eed:	89 fd                	mov    %edi,%ebp
  800eef:	75 0b                	jne    800efc <__udivdi3+0x3c>
  800ef1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef6:	31 d2                	xor    %edx,%edx
  800ef8:	f7 f7                	div    %edi
  800efa:	89 c5                	mov    %eax,%ebp
  800efc:	89 c8                	mov    %ecx,%eax
  800efe:	31 d2                	xor    %edx,%edx
  800f00:	f7 f5                	div    %ebp
  800f02:	89 c1                	mov    %eax,%ecx
  800f04:	89 d8                	mov    %ebx,%eax
  800f06:	89 cf                	mov    %ecx,%edi
  800f08:	f7 f5                	div    %ebp
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	39 ce                	cmp    %ecx,%esi
  800f22:	77 74                	ja     800f98 <__udivdi3+0xd8>
  800f24:	0f bd fe             	bsr    %esi,%edi
  800f27:	83 f7 1f             	xor    $0x1f,%edi
  800f2a:	0f 84 98 00 00 00    	je     800fc8 <__udivdi3+0x108>
  800f30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f35:	89 f9                	mov    %edi,%ecx
  800f37:	89 c5                	mov    %eax,%ebp
  800f39:	29 fb                	sub    %edi,%ebx
  800f3b:	d3 e6                	shl    %cl,%esi
  800f3d:	89 d9                	mov    %ebx,%ecx
  800f3f:	d3 ed                	shr    %cl,%ebp
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	d3 e0                	shl    %cl,%eax
  800f45:	09 ee                	or     %ebp,%esi
  800f47:	89 d9                	mov    %ebx,%ecx
  800f49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f4d:	89 d5                	mov    %edx,%ebp
  800f4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f53:	d3 ed                	shr    %cl,%ebp
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 e2                	shl    %cl,%edx
  800f59:	89 d9                	mov    %ebx,%ecx
  800f5b:	d3 e8                	shr    %cl,%eax
  800f5d:	09 c2                	or     %eax,%edx
  800f5f:	89 d0                	mov    %edx,%eax
  800f61:	89 ea                	mov    %ebp,%edx
  800f63:	f7 f6                	div    %esi
  800f65:	89 d5                	mov    %edx,%ebp
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	f7 64 24 0c          	mull   0xc(%esp)
  800f6d:	39 d5                	cmp    %edx,%ebp
  800f6f:	72 10                	jb     800f81 <__udivdi3+0xc1>
  800f71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f75:	89 f9                	mov    %edi,%ecx
  800f77:	d3 e6                	shl    %cl,%esi
  800f79:	39 c6                	cmp    %eax,%esi
  800f7b:	73 07                	jae    800f84 <__udivdi3+0xc4>
  800f7d:	39 d5                	cmp    %edx,%ebp
  800f7f:	75 03                	jne    800f84 <__udivdi3+0xc4>
  800f81:	83 eb 01             	sub    $0x1,%ebx
  800f84:	31 ff                	xor    %edi,%edi
  800f86:	89 d8                	mov    %ebx,%eax
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	31 ff                	xor    %edi,%edi
  800f9a:	31 db                	xor    %ebx,%ebx
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	89 fa                	mov    %edi,%edx
  800fa0:	83 c4 1c             	add    $0x1c,%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
  800fa8:	90                   	nop
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	f7 f7                	div    %edi
  800fb4:	31 ff                	xor    %edi,%edi
  800fb6:	89 c3                	mov    %eax,%ebx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 fa                	mov    %edi,%edx
  800fbc:	83 c4 1c             	add    $0x1c,%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    
  800fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	39 ce                	cmp    %ecx,%esi
  800fca:	72 0c                	jb     800fd8 <__udivdi3+0x118>
  800fcc:	31 db                	xor    %ebx,%ebx
  800fce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800fd2:	0f 87 34 ff ff ff    	ja     800f0c <__udivdi3+0x4c>
  800fd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fdd:	e9 2a ff ff ff       	jmp    800f0c <__udivdi3+0x4c>
  800fe2:	66 90                	xchg   %ax,%ax
  800fe4:	66 90                	xchg   %ax,%ax
  800fe6:	66 90                	xchg   %ax,%ax
  800fe8:	66 90                	xchg   %ax,%ax
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 1c             	sub    $0x1c,%esp
  800ff7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ffb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801007:	85 d2                	test   %edx,%edx
  801009:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 f3                	mov    %esi,%ebx
  801013:	89 3c 24             	mov    %edi,(%esp)
  801016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101a:	75 1c                	jne    801038 <__umoddi3+0x48>
  80101c:	39 f7                	cmp    %esi,%edi
  80101e:	76 50                	jbe    801070 <__umoddi3+0x80>
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 f2                	mov    %esi,%edx
  801024:	f7 f7                	div    %edi
  801026:	89 d0                	mov    %edx,%eax
  801028:	31 d2                	xor    %edx,%edx
  80102a:	83 c4 1c             	add    $0x1c,%esp
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    
  801032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801038:	39 f2                	cmp    %esi,%edx
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	77 52                	ja     801090 <__umoddi3+0xa0>
  80103e:	0f bd ea             	bsr    %edx,%ebp
  801041:	83 f5 1f             	xor    $0x1f,%ebp
  801044:	75 5a                	jne    8010a0 <__umoddi3+0xb0>
  801046:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80104a:	0f 82 e0 00 00 00    	jb     801130 <__umoddi3+0x140>
  801050:	39 0c 24             	cmp    %ecx,(%esp)
  801053:	0f 86 d7 00 00 00    	jbe    801130 <__umoddi3+0x140>
  801059:	8b 44 24 08          	mov    0x8(%esp),%eax
  80105d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801061:	83 c4 1c             	add    $0x1c,%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
  801069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801070:	85 ff                	test   %edi,%edi
  801072:	89 fd                	mov    %edi,%ebp
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f7                	div    %edi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	89 f0                	mov    %esi,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f5                	div    %ebp
  801087:	89 c8                	mov    %ecx,%eax
  801089:	f7 f5                	div    %ebp
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	eb 99                	jmp    801028 <__umoddi3+0x38>
  80108f:	90                   	nop
  801090:	89 c8                	mov    %ecx,%eax
  801092:	89 f2                	mov    %esi,%edx
  801094:	83 c4 1c             	add    $0x1c,%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    
  80109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	8b 34 24             	mov    (%esp),%esi
  8010a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	29 ef                	sub    %ebp,%edi
  8010ac:	d3 e0                	shl    %cl,%eax
  8010ae:	89 f9                	mov    %edi,%ecx
  8010b0:	89 f2                	mov    %esi,%edx
  8010b2:	d3 ea                	shr    %cl,%edx
  8010b4:	89 e9                	mov    %ebp,%ecx
  8010b6:	09 c2                	or     %eax,%edx
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	89 14 24             	mov    %edx,(%esp)
  8010bd:	89 f2                	mov    %esi,%edx
  8010bf:	d3 e2                	shl    %cl,%edx
  8010c1:	89 f9                	mov    %edi,%ecx
  8010c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010cb:	d3 e8                	shr    %cl,%eax
  8010cd:	89 e9                	mov    %ebp,%ecx
  8010cf:	89 c6                	mov    %eax,%esi
  8010d1:	d3 e3                	shl    %cl,%ebx
  8010d3:	89 f9                	mov    %edi,%ecx
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	09 d8                	or     %ebx,%eax
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	89 f2                	mov    %esi,%edx
  8010e1:	f7 34 24             	divl   (%esp)
  8010e4:	89 d6                	mov    %edx,%esi
  8010e6:	d3 e3                	shl    %cl,%ebx
  8010e8:	f7 64 24 04          	mull   0x4(%esp)
  8010ec:	39 d6                	cmp    %edx,%esi
  8010ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010f2:	89 d1                	mov    %edx,%ecx
  8010f4:	89 c3                	mov    %eax,%ebx
  8010f6:	72 08                	jb     801100 <__umoddi3+0x110>
  8010f8:	75 11                	jne    80110b <__umoddi3+0x11b>
  8010fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010fe:	73 0b                	jae    80110b <__umoddi3+0x11b>
  801100:	2b 44 24 04          	sub    0x4(%esp),%eax
  801104:	1b 14 24             	sbb    (%esp),%edx
  801107:	89 d1                	mov    %edx,%ecx
  801109:	89 c3                	mov    %eax,%ebx
  80110b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80110f:	29 da                	sub    %ebx,%edx
  801111:	19 ce                	sbb    %ecx,%esi
  801113:	89 f9                	mov    %edi,%ecx
  801115:	89 f0                	mov    %esi,%eax
  801117:	d3 e0                	shl    %cl,%eax
  801119:	89 e9                	mov    %ebp,%ecx
  80111b:	d3 ea                	shr    %cl,%edx
  80111d:	89 e9                	mov    %ebp,%ecx
  80111f:	d3 ee                	shr    %cl,%esi
  801121:	09 d0                	or     %edx,%eax
  801123:	89 f2                	mov    %esi,%edx
  801125:	83 c4 1c             	add    $0x1c,%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	29 f9                	sub    %edi,%ecx
  801132:	19 d6                	sbb    %edx,%esi
  801134:	89 74 24 04          	mov    %esi,0x4(%esp)
  801138:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80113c:	e9 18 ff ff ff       	jmp    801059 <__umoddi3+0x69>
