
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 15 80 00       	push   $0x801571
  800049:	68 40 15 80 00       	push   $0x801540
  80004e:	e8 5f 06 00 00       	call   8006b2 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 15 80 00       	push   $0x801550
  80005c:	68 54 15 80 00       	push   $0x801554
  800061:	e8 4c 06 00 00       	call   8006b2 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 15 80 00       	push   $0x801564
  800077:	e8 36 06 00 00       	call   8006b2 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 15 80 00       	push   $0x801568
  80008e:	e8 1f 06 00 00       	call   8006b2 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 15 80 00       	push   $0x801572
  8000a6:	68 54 15 80 00       	push   $0x801554
  8000ab:	e8 02 06 00 00       	call   8006b2 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 15 80 00       	push   $0x801564
  8000c3:	e8 ea 05 00 00       	call   8006b2 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 15 80 00       	push   $0x801568
  8000d5:	e8 d8 05 00 00       	call   8006b2 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 15 80 00       	push   $0x801576
  8000ed:	68 54 15 80 00       	push   $0x801554
  8000f2:	e8 bb 05 00 00       	call   8006b2 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 15 80 00       	push   $0x801564
  80010a:	e8 a3 05 00 00       	call   8006b2 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 15 80 00       	push   $0x801568
  80011c:	e8 91 05 00 00       	call   8006b2 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 15 80 00       	push   $0x80157a
  800134:	68 54 15 80 00       	push   $0x801554
  800139:	e8 74 05 00 00       	call   8006b2 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 15 80 00       	push   $0x801564
  800151:	e8 5c 05 00 00       	call   8006b2 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 15 80 00       	push   $0x801568
  800163:	e8 4a 05 00 00       	call   8006b2 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 15 80 00       	push   $0x80157e
  80017b:	68 54 15 80 00       	push   $0x801554
  800180:	e8 2d 05 00 00       	call   8006b2 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 15 80 00       	push   $0x801564
  800198:	e8 15 05 00 00       	call   8006b2 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 15 80 00       	push   $0x801568
  8001aa:	e8 03 05 00 00       	call   8006b2 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 15 80 00       	push   $0x801582
  8001c2:	68 54 15 80 00       	push   $0x801554
  8001c7:	e8 e6 04 00 00       	call   8006b2 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 15 80 00       	push   $0x801564
  8001df:	e8 ce 04 00 00       	call   8006b2 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 15 80 00       	push   $0x801568
  8001f1:	e8 bc 04 00 00       	call   8006b2 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 15 80 00       	push   $0x801586
  800209:	68 54 15 80 00       	push   $0x801554
  80020e:	e8 9f 04 00 00       	call   8006b2 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 15 80 00       	push   $0x801564
  800226:	e8 87 04 00 00       	call   8006b2 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 15 80 00       	push   $0x801568
  800238:	e8 75 04 00 00       	call   8006b2 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 15 80 00       	push   $0x80158a
  800250:	68 54 15 80 00       	push   $0x801554
  800255:	e8 58 04 00 00       	call   8006b2 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 15 80 00       	push   $0x801564
  80026d:	e8 40 04 00 00       	call   8006b2 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 15 80 00       	push   $0x801568
  80027f:	e8 2e 04 00 00       	call   8006b2 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 15 80 00       	push   $0x80158e
  800297:	68 54 15 80 00       	push   $0x801554
  80029c:	e8 11 04 00 00       	call   8006b2 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 15 80 00       	push   $0x801564
  8002b4:	e8 f9 03 00 00       	call   8006b2 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 15 80 00       	push   $0x801595
  8002c4:	68 54 15 80 00       	push   $0x801554
  8002c9:	e8 e4 03 00 00       	call   8006b2 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 15 80 00       	push   $0x801568
  8002e3:	e8 ca 03 00 00       	call   8006b2 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 15 80 00       	push   $0x801595
  8002f3:	68 54 15 80 00       	push   $0x801554
  8002f8:	e8 b5 03 00 00       	call   8006b2 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 15 80 00       	push   $0x801564
  800312:	e8 9b 03 00 00       	call   8006b2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 15 80 00       	push   $0x801599
  800322:	e8 8b 03 00 00       	call   8006b2 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 15 80 00       	push   $0x801568
  800338:	e8 75 03 00 00       	call   8006b2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 15 80 00       	push   $0x801599
  800348:	e8 65 03 00 00       	call   8006b2 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 15 80 00       	push   $0x801564
  80035a:	e8 53 03 00 00       	call   8006b2 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 15 80 00       	push   $0x801568
  80036c:	e8 41 03 00 00       	call   8006b2 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 15 80 00       	push   $0x801564
  80037e:	e8 2f 03 00 00       	call   8006b2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 15 80 00       	push   $0x801599
  80038e:	e8 1f 03 00 00       	call   8006b2 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 16 80 00       	push   $0x801600
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 15 80 00       	push   $0x8015a7
  8003c6:	e8 0e 02 00 00       	call   8005d9 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 bf 15 80 00       	push   $0x8015bf
  800435:	68 cd 15 80 00       	push   $0x8015cd
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 5a 0c 00 00       	call   8010b9 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 d4 15 80 00       	push   $0x8015d4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 a7 15 80 00       	push   $0x8015a7
  800473:	e8 61 01 00 00       	call   8005d9 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 de 0d 00 00       	call   801268 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 34 16 80 00       	push   $0x801634
  800559:	e8 54 01 00 00       	call   8006b2 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 e7 15 80 00       	push   $0x8015e7
  800573:	68 f8 15 80 00       	push   $0x8015f8
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	8b 45 08             	mov    0x8(%ebp),%eax
  80059a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80059d:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005a4:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	7e 08                	jle    8005b3 <libmain+0x22>
		binaryname = argv[0];
  8005ab:	8b 0a                	mov    (%edx),%ecx
  8005ad:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	52                   	push   %edx
  8005b7:	50                   	push   %eax
  8005b8:	e8 bd fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005bd:	e8 05 00 00 00       	call   8005c7 <exit>
}
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 66 0a 00 00       	call   80103a <sys_env_destroy>
}
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    

008005d9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005de:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005e7:	e8 8f 0a 00 00       	call   80107b <sys_getenvid>
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	ff 75 0c             	pushl  0xc(%ebp)
  8005f2:	ff 75 08             	pushl  0x8(%ebp)
  8005f5:	56                   	push   %esi
  8005f6:	50                   	push   %eax
  8005f7:	68 60 16 80 00       	push   $0x801660
  8005fc:	e8 b1 00 00 00       	call   8006b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800601:	83 c4 18             	add    $0x18,%esp
  800604:	53                   	push   %ebx
  800605:	ff 75 10             	pushl  0x10(%ebp)
  800608:	e8 54 00 00 00       	call   800661 <vcprintf>
	cprintf("\n");
  80060d:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  800614:	e8 99 00 00 00       	call   8006b2 <cprintf>
  800619:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80061c:	cc                   	int3   
  80061d:	eb fd                	jmp    80061c <_panic+0x43>

0080061f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	53                   	push   %ebx
  800623:	83 ec 04             	sub    $0x4,%esp
  800626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800629:	8b 13                	mov    (%ebx),%edx
  80062b:	8d 42 01             	lea    0x1(%edx),%eax
  80062e:	89 03                	mov    %eax,(%ebx)
  800630:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800633:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800637:	3d ff 00 00 00       	cmp    $0xff,%eax
  80063c:	75 1a                	jne    800658 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	68 ff 00 00 00       	push   $0xff
  800646:	8d 43 08             	lea    0x8(%ebx),%eax
  800649:	50                   	push   %eax
  80064a:	e8 ae 09 00 00       	call   800ffd <sys_cputs>
		b->idx = 0;
  80064f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800655:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800658:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80065c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80065f:	c9                   	leave  
  800660:	c3                   	ret    

00800661 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80066a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800671:	00 00 00 
	b.cnt = 0;
  800674:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80067b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	ff 75 08             	pushl  0x8(%ebp)
  800684:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80068a:	50                   	push   %eax
  80068b:	68 1f 06 80 00       	push   $0x80061f
  800690:	e8 1a 01 00 00       	call   8007af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80069e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	e8 53 09 00 00       	call   800ffd <sys_cputs>

	return b.cnt;
}
  8006aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006bb:	50                   	push   %eax
  8006bc:	ff 75 08             	pushl  0x8(%ebp)
  8006bf:	e8 9d ff ff ff       	call   800661 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	57                   	push   %edi
  8006ca:	56                   	push   %esi
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 1c             	sub    $0x1c,%esp
  8006cf:	89 c7                	mov    %eax,%edi
  8006d1:	89 d6                	mov    %edx,%esi
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ea:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006ed:	39 d3                	cmp    %edx,%ebx
  8006ef:	72 05                	jb     8006f6 <printnum+0x30>
  8006f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006f4:	77 45                	ja     80073b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f6:	83 ec 0c             	sub    $0xc,%esp
  8006f9:	ff 75 18             	pushl  0x18(%ebp)
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800702:	53                   	push   %ebx
  800703:	ff 75 10             	pushl  0x10(%ebp)
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	ff 75 e4             	pushl  -0x1c(%ebp)
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	ff 75 dc             	pushl  -0x24(%ebp)
  800712:	ff 75 d8             	pushl  -0x28(%ebp)
  800715:	e8 86 0b 00 00       	call   8012a0 <__udivdi3>
  80071a:	83 c4 18             	add    $0x18,%esp
  80071d:	52                   	push   %edx
  80071e:	50                   	push   %eax
  80071f:	89 f2                	mov    %esi,%edx
  800721:	89 f8                	mov    %edi,%eax
  800723:	e8 9e ff ff ff       	call   8006c6 <printnum>
  800728:	83 c4 20             	add    $0x20,%esp
  80072b:	eb 18                	jmp    800745 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	56                   	push   %esi
  800731:	ff 75 18             	pushl  0x18(%ebp)
  800734:	ff d7                	call   *%edi
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <printnum+0x78>
  80073b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073e:	83 eb 01             	sub    $0x1,%ebx
  800741:	85 db                	test   %ebx,%ebx
  800743:	7f e8                	jg     80072d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	83 ec 04             	sub    $0x4,%esp
  80074c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074f:	ff 75 e0             	pushl  -0x20(%ebp)
  800752:	ff 75 dc             	pushl  -0x24(%ebp)
  800755:	ff 75 d8             	pushl  -0x28(%ebp)
  800758:	e8 73 0c 00 00       	call   8013d0 <__umoddi3>
  80075d:	83 c4 14             	add    $0x14,%esp
  800760:	0f be 80 83 16 80 00 	movsbl 0x801683(%eax),%eax
  800767:	50                   	push   %eax
  800768:	ff d7                	call   *%edi
}
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5f                   	pop    %edi
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80077b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80077f:	8b 10                	mov    (%eax),%edx
  800781:	3b 50 04             	cmp    0x4(%eax),%edx
  800784:	73 0a                	jae    800790 <sprintputch+0x1b>
		*b->buf++ = ch;
  800786:	8d 4a 01             	lea    0x1(%edx),%ecx
  800789:	89 08                	mov    %ecx,(%eax)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	88 02                	mov    %al,(%edx)
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80079b:	50                   	push   %eax
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	ff 75 08             	pushl  0x8(%ebp)
  8007a5:	e8 05 00 00 00       	call   8007af <vprintfmt>
	va_end(ap);
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	57                   	push   %edi
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 2c             	sub    $0x2c,%esp
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007c1:	eb 12                	jmp    8007d5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	0f 84 42 04 00 00    	je     800c0d <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	50                   	push   %eax
  8007d0:	ff d6                	call   *%esi
  8007d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d5:	83 c7 01             	add    $0x1,%edi
  8007d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007dc:	83 f8 25             	cmp    $0x25,%eax
  8007df:	75 e2                	jne    8007c3 <vprintfmt+0x14>
  8007e1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8007e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8007ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8007fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ff:	eb 07                	jmp    800808 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800804:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800808:	8d 47 01             	lea    0x1(%edi),%eax
  80080b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080e:	0f b6 07             	movzbl (%edi),%eax
  800811:	0f b6 d0             	movzbl %al,%edx
  800814:	83 e8 23             	sub    $0x23,%eax
  800817:	3c 55                	cmp    $0x55,%al
  800819:	0f 87 d3 03 00 00    	ja     800bf2 <vprintfmt+0x443>
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  800829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80082c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800830:	eb d6                	jmp    800808 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800832:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80083d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800840:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800844:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800847:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80084a:	83 f9 09             	cmp    $0x9,%ecx
  80084d:	77 3f                	ja     80088e <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80084f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800852:	eb e9                	jmp    80083d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8b 00                	mov    (%eax),%eax
  800859:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 40 04             	lea    0x4(%eax),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800868:	eb 2a                	jmp    800894 <vprintfmt+0xe5>
  80086a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086d:	85 c0                	test   %eax,%eax
  80086f:	ba 00 00 00 00       	mov    $0x0,%edx
  800874:	0f 49 d0             	cmovns %eax,%edx
  800877:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087d:	eb 89                	jmp    800808 <vprintfmt+0x59>
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800882:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800889:	e9 7a ff ff ff       	jmp    800808 <vprintfmt+0x59>
  80088e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800891:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800894:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800898:	0f 89 6a ff ff ff    	jns    800808 <vprintfmt+0x59>
				width = precision, precision = -1;
  80089e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ab:	e9 58 ff ff ff       	jmp    800808 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b0:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008b6:	e9 4d ff ff ff       	jmp    800808 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 78 04             	lea    0x4(%eax),%edi
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	53                   	push   %ebx
  8008c5:	ff 30                	pushl  (%eax)
  8008c7:	ff d6                	call   *%esi
			break;
  8008c9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008cc:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008d2:	e9 fe fe ff ff       	jmp    8007d5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 78 04             	lea    0x4(%eax),%edi
  8008dd:	8b 00                	mov    (%eax),%eax
  8008df:	99                   	cltd   
  8008e0:	31 d0                	xor    %edx,%eax
  8008e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008e4:	83 f8 09             	cmp    $0x9,%eax
  8008e7:	7f 0b                	jg     8008f4 <vprintfmt+0x145>
  8008e9:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	75 1b                	jne    80090f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8008f4:	50                   	push   %eax
  8008f5:	68 9b 16 80 00       	push   $0x80169b
  8008fa:	53                   	push   %ebx
  8008fb:	56                   	push   %esi
  8008fc:	e8 91 fe ff ff       	call   800792 <printfmt>
  800901:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800904:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80090a:	e9 c6 fe ff ff       	jmp    8007d5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80090f:	52                   	push   %edx
  800910:	68 a4 16 80 00       	push   $0x8016a4
  800915:	53                   	push   %ebx
  800916:	56                   	push   %esi
  800917:	e8 76 fe ff ff       	call   800792 <printfmt>
  80091c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800925:	e9 ab fe ff ff       	jmp    8007d5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	83 c0 04             	add    $0x4,%eax
  800930:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800938:	85 ff                	test   %edi,%edi
  80093a:	b8 94 16 80 00       	mov    $0x801694,%eax
  80093f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800942:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800946:	0f 8e 94 00 00 00    	jle    8009e0 <vprintfmt+0x231>
  80094c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800950:	0f 84 98 00 00 00    	je     8009ee <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	ff 75 d0             	pushl  -0x30(%ebp)
  80095c:	57                   	push   %edi
  80095d:	e8 33 03 00 00       	call   800c95 <strnlen>
  800962:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800965:	29 c1                	sub    %eax,%ecx
  800967:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80096a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80096d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800971:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800974:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800977:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800979:	eb 0f                	jmp    80098a <vprintfmt+0x1db>
					putch(padc, putdat);
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	53                   	push   %ebx
  80097f:	ff 75 e0             	pushl  -0x20(%ebp)
  800982:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800984:	83 ef 01             	sub    $0x1,%edi
  800987:	83 c4 10             	add    $0x10,%esp
  80098a:	85 ff                	test   %edi,%edi
  80098c:	7f ed                	jg     80097b <vprintfmt+0x1cc>
  80098e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800991:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800994:	85 c9                	test   %ecx,%ecx
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	0f 49 c1             	cmovns %ecx,%eax
  80099e:	29 c1                	sub    %eax,%ecx
  8009a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8009a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009a9:	89 cb                	mov    %ecx,%ebx
  8009ab:	eb 4d                	jmp    8009fa <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009b1:	74 1b                	je     8009ce <vprintfmt+0x21f>
  8009b3:	0f be c0             	movsbl %al,%eax
  8009b6:	83 e8 20             	sub    $0x20,%eax
  8009b9:	83 f8 5e             	cmp    $0x5e,%eax
  8009bc:	76 10                	jbe    8009ce <vprintfmt+0x21f>
					putch('?', putdat);
  8009be:	83 ec 08             	sub    $0x8,%esp
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	6a 3f                	push   $0x3f
  8009c6:	ff 55 08             	call   *0x8(%ebp)
  8009c9:	83 c4 10             	add    $0x10,%esp
  8009cc:	eb 0d                	jmp    8009db <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	52                   	push   %edx
  8009d5:	ff 55 08             	call   *0x8(%ebp)
  8009d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009db:	83 eb 01             	sub    $0x1,%ebx
  8009de:	eb 1a                	jmp    8009fa <vprintfmt+0x24b>
  8009e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009ec:	eb 0c                	jmp    8009fa <vprintfmt+0x24b>
  8009ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8009f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009fa:	83 c7 01             	add    $0x1,%edi
  8009fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a01:	0f be d0             	movsbl %al,%edx
  800a04:	85 d2                	test   %edx,%edx
  800a06:	74 23                	je     800a2b <vprintfmt+0x27c>
  800a08:	85 f6                	test   %esi,%esi
  800a0a:	78 a1                	js     8009ad <vprintfmt+0x1fe>
  800a0c:	83 ee 01             	sub    $0x1,%esi
  800a0f:	79 9c                	jns    8009ad <vprintfmt+0x1fe>
  800a11:	89 df                	mov    %ebx,%edi
  800a13:	8b 75 08             	mov    0x8(%ebp),%esi
  800a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a19:	eb 18                	jmp    800a33 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a1b:	83 ec 08             	sub    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 20                	push   $0x20
  800a21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a23:	83 ef 01             	sub    $0x1,%edi
  800a26:	83 c4 10             	add    $0x10,%esp
  800a29:	eb 08                	jmp    800a33 <vprintfmt+0x284>
  800a2b:	89 df                	mov    %ebx,%edi
  800a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a33:	85 ff                	test   %edi,%edi
  800a35:	7f e4                	jg     800a1b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a37:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a3a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a40:	e9 90 fd ff ff       	jmp    8007d5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a45:	83 f9 01             	cmp    $0x1,%ecx
  800a48:	7e 19                	jle    800a63 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4d:	8b 50 04             	mov    0x4(%eax),%edx
  800a50:	8b 00                	mov    (%eax),%eax
  800a52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 40 08             	lea    0x8(%eax),%eax
  800a5e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a61:	eb 38                	jmp    800a9b <vprintfmt+0x2ec>
	else if (lflag)
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	74 1b                	je     800a82 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8b 00                	mov    (%eax),%eax
  800a6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a6f:	89 c1                	mov    %eax,%ecx
  800a71:	c1 f9 1f             	sar    $0x1f,%ecx
  800a74:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a77:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7a:	8d 40 04             	lea    0x4(%eax),%eax
  800a7d:	89 45 14             	mov    %eax,0x14(%ebp)
  800a80:	eb 19                	jmp    800a9b <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800a82:	8b 45 14             	mov    0x14(%ebp),%eax
  800a85:	8b 00                	mov    (%eax),%eax
  800a87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8a:	89 c1                	mov    %eax,%ecx
  800a8c:	c1 f9 1f             	sar    $0x1f,%ecx
  800a8f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a92:	8b 45 14             	mov    0x14(%ebp),%eax
  800a95:	8d 40 04             	lea    0x4(%eax),%eax
  800a98:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a9b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a9e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aa1:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aa6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800aaa:	0f 89 0e 01 00 00    	jns    800bbe <vprintfmt+0x40f>
				putch('-', putdat);
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	53                   	push   %ebx
  800ab4:	6a 2d                	push   $0x2d
  800ab6:	ff d6                	call   *%esi
				num = -(long long) num;
  800ab8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800abb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800abe:	f7 da                	neg    %edx
  800ac0:	83 d1 00             	adc    $0x0,%ecx
  800ac3:	f7 d9                	neg    %ecx
  800ac5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ac8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acd:	e9 ec 00 00 00       	jmp    800bbe <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad2:	83 f9 01             	cmp    $0x1,%ecx
  800ad5:	7e 18                	jle    800aef <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  800ada:	8b 10                	mov    (%eax),%edx
  800adc:	8b 48 04             	mov    0x4(%eax),%ecx
  800adf:	8d 40 08             	lea    0x8(%eax),%eax
  800ae2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	e9 cf 00 00 00       	jmp    800bbe <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800aef:	85 c9                	test   %ecx,%ecx
  800af1:	74 1a                	je     800b0d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	8b 10                	mov    (%eax),%edx
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afd:	8d 40 04             	lea    0x4(%eax),%eax
  800b00:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b08:	e9 b1 00 00 00       	jmp    800bbe <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b10:	8b 10                	mov    (%eax),%edx
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	8d 40 04             	lea    0x4(%eax),%eax
  800b1a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	e9 97 00 00 00       	jmp    800bbe <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b27:	83 ec 08             	sub    $0x8,%esp
  800b2a:	53                   	push   %ebx
  800b2b:	6a 58                	push   $0x58
  800b2d:	ff d6                	call   *%esi
			putch('X', putdat);
  800b2f:	83 c4 08             	add    $0x8,%esp
  800b32:	53                   	push   %ebx
  800b33:	6a 58                	push   $0x58
  800b35:	ff d6                	call   *%esi
			putch('X', putdat);
  800b37:	83 c4 08             	add    $0x8,%esp
  800b3a:	53                   	push   %ebx
  800b3b:	6a 58                	push   $0x58
  800b3d:	ff d6                	call   *%esi
			break;
  800b3f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b45:	e9 8b fc ff ff       	jmp    8007d5 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b4a:	83 ec 08             	sub    $0x8,%esp
  800b4d:	53                   	push   %ebx
  800b4e:	6a 30                	push   $0x30
  800b50:	ff d6                	call   *%esi
			putch('x', putdat);
  800b52:	83 c4 08             	add    $0x8,%esp
  800b55:	53                   	push   %ebx
  800b56:	6a 78                	push   $0x78
  800b58:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5d:	8b 10                	mov    (%eax),%edx
  800b5f:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b64:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b67:	8d 40 04             	lea    0x4(%eax),%eax
  800b6a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b6d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b72:	eb 4a                	jmp    800bbe <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b74:	83 f9 01             	cmp    $0x1,%ecx
  800b77:	7e 15                	jle    800b8e <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800b79:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	8b 48 04             	mov    0x4(%eax),%ecx
  800b81:	8d 40 08             	lea    0x8(%eax),%eax
  800b84:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800b87:	b8 10 00 00 00       	mov    $0x10,%eax
  800b8c:	eb 30                	jmp    800bbe <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b8e:	85 c9                	test   %ecx,%ecx
  800b90:	74 17                	je     800ba9 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800b92:	8b 45 14             	mov    0x14(%ebp),%eax
  800b95:	8b 10                	mov    (%eax),%edx
  800b97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9c:	8d 40 04             	lea    0x4(%eax),%eax
  800b9f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ba2:	b8 10 00 00 00       	mov    $0x10,%eax
  800ba7:	eb 15                	jmp    800bbe <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800ba9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bac:	8b 10                	mov    (%eax),%edx
  800bae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb3:	8d 40 04             	lea    0x4(%eax),%eax
  800bb6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bb9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bc5:	57                   	push   %edi
  800bc6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc9:	50                   	push   %eax
  800bca:	51                   	push   %ecx
  800bcb:	52                   	push   %edx
  800bcc:	89 da                	mov    %ebx,%edx
  800bce:	89 f0                	mov    %esi,%eax
  800bd0:	e8 f1 fa ff ff       	call   8006c6 <printnum>
			break;
  800bd5:	83 c4 20             	add    $0x20,%esp
  800bd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bdb:	e9 f5 fb ff ff       	jmp    8007d5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800be0:	83 ec 08             	sub    $0x8,%esp
  800be3:	53                   	push   %ebx
  800be4:	52                   	push   %edx
  800be5:	ff d6                	call   *%esi
			break;
  800be7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bed:	e9 e3 fb ff ff       	jmp    8007d5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bf2:	83 ec 08             	sub    $0x8,%esp
  800bf5:	53                   	push   %ebx
  800bf6:	6a 25                	push   $0x25
  800bf8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb 03                	jmp    800c02 <vprintfmt+0x453>
  800bff:	83 ef 01             	sub    $0x1,%edi
  800c02:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c06:	75 f7                	jne    800bff <vprintfmt+0x450>
  800c08:	e9 c8 fb ff ff       	jmp    8007d5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 18             	sub    $0x18,%esp
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c24:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c28:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	74 26                	je     800c5c <vsnprintf+0x47>
  800c36:	85 d2                	test   %edx,%edx
  800c38:	7e 22                	jle    800c5c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c3a:	ff 75 14             	pushl  0x14(%ebp)
  800c3d:	ff 75 10             	pushl  0x10(%ebp)
  800c40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c43:	50                   	push   %eax
  800c44:	68 75 07 80 00       	push   $0x800775
  800c49:	e8 61 fb ff ff       	call   8007af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c51:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	eb 05                	jmp    800c61 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c69:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c6c:	50                   	push   %eax
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	ff 75 0c             	pushl  0xc(%ebp)
  800c73:	ff 75 08             	pushl  0x8(%ebp)
  800c76:	e8 9a ff ff ff       	call   800c15 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
  800c88:	eb 03                	jmp    800c8d <strlen+0x10>
		n++;
  800c8a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c8d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c91:	75 f7                	jne    800c8a <strlen+0xd>
		n++;
	return n;
}
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	eb 03                	jmp    800ca8 <strnlen+0x13>
		n++;
  800ca5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca8:	39 c2                	cmp    %eax,%edx
  800caa:	74 08                	je     800cb4 <strnlen+0x1f>
  800cac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cb0:	75 f3                	jne    800ca5 <strnlen+0x10>
  800cb2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	53                   	push   %ebx
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	83 c2 01             	add    $0x1,%edx
  800cc5:	83 c1 01             	add    $0x1,%ecx
  800cc8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ccc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ccf:	84 db                	test   %bl,%bl
  800cd1:	75 ef                	jne    800cc2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cd3:	5b                   	pop    %ebx
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	53                   	push   %ebx
  800cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cdd:	53                   	push   %ebx
  800cde:	e8 9a ff ff ff       	call   800c7d <strlen>
  800ce3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ce6:	ff 75 0c             	pushl  0xc(%ebp)
  800ce9:	01 d8                	add    %ebx,%eax
  800ceb:	50                   	push   %eax
  800cec:	e8 c5 ff ff ff       	call   800cb6 <strcpy>
	return dst;
}
  800cf1:	89 d8                	mov    %ebx,%eax
  800cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	8b 75 08             	mov    0x8(%ebp),%esi
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	89 f3                	mov    %esi,%ebx
  800d05:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d08:	89 f2                	mov    %esi,%edx
  800d0a:	eb 0f                	jmp    800d1b <strncpy+0x23>
		*dst++ = *src;
  800d0c:	83 c2 01             	add    $0x1,%edx
  800d0f:	0f b6 01             	movzbl (%ecx),%eax
  800d12:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d15:	80 39 01             	cmpb   $0x1,(%ecx)
  800d18:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d1b:	39 da                	cmp    %ebx,%edx
  800d1d:	75 ed                	jne    800d0c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 10             	mov    0x10(%ebp),%edx
  800d33:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d35:	85 d2                	test   %edx,%edx
  800d37:	74 21                	je     800d5a <strlcpy+0x35>
  800d39:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d3d:	89 f2                	mov    %esi,%edx
  800d3f:	eb 09                	jmp    800d4a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d41:	83 c2 01             	add    $0x1,%edx
  800d44:	83 c1 01             	add    $0x1,%ecx
  800d47:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d4a:	39 c2                	cmp    %eax,%edx
  800d4c:	74 09                	je     800d57 <strlcpy+0x32>
  800d4e:	0f b6 19             	movzbl (%ecx),%ebx
  800d51:	84 db                	test   %bl,%bl
  800d53:	75 ec                	jne    800d41 <strlcpy+0x1c>
  800d55:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d57:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d5a:	29 f0                	sub    %esi,%eax
}
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d69:	eb 06                	jmp    800d71 <strcmp+0x11>
		p++, q++;
  800d6b:	83 c1 01             	add    $0x1,%ecx
  800d6e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d71:	0f b6 01             	movzbl (%ecx),%eax
  800d74:	84 c0                	test   %al,%al
  800d76:	74 04                	je     800d7c <strcmp+0x1c>
  800d78:	3a 02                	cmp    (%edx),%al
  800d7a:	74 ef                	je     800d6b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7c:	0f b6 c0             	movzbl %al,%eax
  800d7f:	0f b6 12             	movzbl (%edx),%edx
  800d82:	29 d0                	sub    %edx,%eax
}
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	53                   	push   %ebx
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d95:	eb 06                	jmp    800d9d <strncmp+0x17>
		n--, p++, q++;
  800d97:	83 c0 01             	add    $0x1,%eax
  800d9a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d9d:	39 d8                	cmp    %ebx,%eax
  800d9f:	74 15                	je     800db6 <strncmp+0x30>
  800da1:	0f b6 08             	movzbl (%eax),%ecx
  800da4:	84 c9                	test   %cl,%cl
  800da6:	74 04                	je     800dac <strncmp+0x26>
  800da8:	3a 0a                	cmp    (%edx),%cl
  800daa:	74 eb                	je     800d97 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 00             	movzbl (%eax),%eax
  800daf:	0f b6 12             	movzbl (%edx),%edx
  800db2:	29 d0                	sub    %edx,%eax
  800db4:	eb 05                	jmp    800dbb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800db6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc8:	eb 07                	jmp    800dd1 <strchr+0x13>
		if (*s == c)
  800dca:	38 ca                	cmp    %cl,%dl
  800dcc:	74 0f                	je     800ddd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dce:	83 c0 01             	add    $0x1,%eax
  800dd1:	0f b6 10             	movzbl (%eax),%edx
  800dd4:	84 d2                	test   %dl,%dl
  800dd6:	75 f2                	jne    800dca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de9:	eb 03                	jmp    800dee <strfind+0xf>
  800deb:	83 c0 01             	add    $0x1,%eax
  800dee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800df1:	38 ca                	cmp    %cl,%dl
  800df3:	74 04                	je     800df9 <strfind+0x1a>
  800df5:	84 d2                	test   %dl,%dl
  800df7:	75 f2                	jne    800deb <strfind+0xc>
			break;
	return (char *) s;
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e07:	85 c9                	test   %ecx,%ecx
  800e09:	74 36                	je     800e41 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e11:	75 28                	jne    800e3b <memset+0x40>
  800e13:	f6 c1 03             	test   $0x3,%cl
  800e16:	75 23                	jne    800e3b <memset+0x40>
		c &= 0xFF;
  800e18:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	c1 e3 08             	shl    $0x8,%ebx
  800e21:	89 d6                	mov    %edx,%esi
  800e23:	c1 e6 18             	shl    $0x18,%esi
  800e26:	89 d0                	mov    %edx,%eax
  800e28:	c1 e0 10             	shl    $0x10,%eax
  800e2b:	09 f0                	or     %esi,%eax
  800e2d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e2f:	89 d8                	mov    %ebx,%eax
  800e31:	09 d0                	or     %edx,%eax
  800e33:	c1 e9 02             	shr    $0x2,%ecx
  800e36:	fc                   	cld    
  800e37:	f3 ab                	rep stos %eax,%es:(%edi)
  800e39:	eb 06                	jmp    800e41 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3e:	fc                   	cld    
  800e3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e41:	89 f8                	mov    %edi,%eax
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e56:	39 c6                	cmp    %eax,%esi
  800e58:	73 35                	jae    800e8f <memmove+0x47>
  800e5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e5d:	39 d0                	cmp    %edx,%eax
  800e5f:	73 2e                	jae    800e8f <memmove+0x47>
		s += n;
		d += n;
  800e61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e64:	89 d6                	mov    %edx,%esi
  800e66:	09 fe                	or     %edi,%esi
  800e68:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e6e:	75 13                	jne    800e83 <memmove+0x3b>
  800e70:	f6 c1 03             	test   $0x3,%cl
  800e73:	75 0e                	jne    800e83 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e75:	83 ef 04             	sub    $0x4,%edi
  800e78:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e7b:	c1 e9 02             	shr    $0x2,%ecx
  800e7e:	fd                   	std    
  800e7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e81:	eb 09                	jmp    800e8c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e83:	83 ef 01             	sub    $0x1,%edi
  800e86:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e89:	fd                   	std    
  800e8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e8c:	fc                   	cld    
  800e8d:	eb 1d                	jmp    800eac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e8f:	89 f2                	mov    %esi,%edx
  800e91:	09 c2                	or     %eax,%edx
  800e93:	f6 c2 03             	test   $0x3,%dl
  800e96:	75 0f                	jne    800ea7 <memmove+0x5f>
  800e98:	f6 c1 03             	test   $0x3,%cl
  800e9b:	75 0a                	jne    800ea7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e9d:	c1 e9 02             	shr    $0x2,%ecx
  800ea0:	89 c7                	mov    %eax,%edi
  800ea2:	fc                   	cld    
  800ea3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ea5:	eb 05                	jmp    800eac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ea7:	89 c7                	mov    %eax,%edi
  800ea9:	fc                   	cld    
  800eaa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800eb3:	ff 75 10             	pushl  0x10(%ebp)
  800eb6:	ff 75 0c             	pushl  0xc(%ebp)
  800eb9:	ff 75 08             	pushl  0x8(%ebp)
  800ebc:	e8 87 ff ff ff       	call   800e48 <memmove>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 c6                	mov    %eax,%esi
  800ed0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed3:	eb 1a                	jmp    800eef <memcmp+0x2c>
		if (*s1 != *s2)
  800ed5:	0f b6 08             	movzbl (%eax),%ecx
  800ed8:	0f b6 1a             	movzbl (%edx),%ebx
  800edb:	38 d9                	cmp    %bl,%cl
  800edd:	74 0a                	je     800ee9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800edf:	0f b6 c1             	movzbl %cl,%eax
  800ee2:	0f b6 db             	movzbl %bl,%ebx
  800ee5:	29 d8                	sub    %ebx,%eax
  800ee7:	eb 0f                	jmp    800ef8 <memcmp+0x35>
		s1++, s2++;
  800ee9:	83 c0 01             	add    $0x1,%eax
  800eec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eef:	39 f0                	cmp    %esi,%eax
  800ef1:	75 e2                	jne    800ed5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	53                   	push   %ebx
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f0c:	eb 0a                	jmp    800f18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f0e:	0f b6 10             	movzbl (%eax),%edx
  800f11:	39 da                	cmp    %ebx,%edx
  800f13:	74 07                	je     800f1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f15:	83 c0 01             	add    $0x1,%eax
  800f18:	39 c8                	cmp    %ecx,%eax
  800f1a:	72 f2                	jb     800f0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f1c:	5b                   	pop    %ebx
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2b:	eb 03                	jmp    800f30 <strtol+0x11>
		s++;
  800f2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f30:	0f b6 01             	movzbl (%ecx),%eax
  800f33:	3c 20                	cmp    $0x20,%al
  800f35:	74 f6                	je     800f2d <strtol+0xe>
  800f37:	3c 09                	cmp    $0x9,%al
  800f39:	74 f2                	je     800f2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f3b:	3c 2b                	cmp    $0x2b,%al
  800f3d:	75 0a                	jne    800f49 <strtol+0x2a>
		s++;
  800f3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f42:	bf 00 00 00 00       	mov    $0x0,%edi
  800f47:	eb 11                	jmp    800f5a <strtol+0x3b>
  800f49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f4e:	3c 2d                	cmp    $0x2d,%al
  800f50:	75 08                	jne    800f5a <strtol+0x3b>
		s++, neg = 1;
  800f52:	83 c1 01             	add    $0x1,%ecx
  800f55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f60:	75 15                	jne    800f77 <strtol+0x58>
  800f62:	80 39 30             	cmpb   $0x30,(%ecx)
  800f65:	75 10                	jne    800f77 <strtol+0x58>
  800f67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f6b:	75 7c                	jne    800fe9 <strtol+0xca>
		s += 2, base = 16;
  800f6d:	83 c1 02             	add    $0x2,%ecx
  800f70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f75:	eb 16                	jmp    800f8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f77:	85 db                	test   %ebx,%ebx
  800f79:	75 12                	jne    800f8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f80:	80 39 30             	cmpb   $0x30,(%ecx)
  800f83:	75 08                	jne    800f8d <strtol+0x6e>
		s++, base = 8;
  800f85:	83 c1 01             	add    $0x1,%ecx
  800f88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f95:	0f b6 11             	movzbl (%ecx),%edx
  800f98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f9b:	89 f3                	mov    %esi,%ebx
  800f9d:	80 fb 09             	cmp    $0x9,%bl
  800fa0:	77 08                	ja     800faa <strtol+0x8b>
			dig = *s - '0';
  800fa2:	0f be d2             	movsbl %dl,%edx
  800fa5:	83 ea 30             	sub    $0x30,%edx
  800fa8:	eb 22                	jmp    800fcc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800faa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fad:	89 f3                	mov    %esi,%ebx
  800faf:	80 fb 19             	cmp    $0x19,%bl
  800fb2:	77 08                	ja     800fbc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fb4:	0f be d2             	movsbl %dl,%edx
  800fb7:	83 ea 57             	sub    $0x57,%edx
  800fba:	eb 10                	jmp    800fcc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fbc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fbf:	89 f3                	mov    %esi,%ebx
  800fc1:	80 fb 19             	cmp    $0x19,%bl
  800fc4:	77 16                	ja     800fdc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fc6:	0f be d2             	movsbl %dl,%edx
  800fc9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fcc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fcf:	7d 0b                	jge    800fdc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fd1:	83 c1 01             	add    $0x1,%ecx
  800fd4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fd8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fda:	eb b9                	jmp    800f95 <strtol+0x76>

	if (endptr)
  800fdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fe0:	74 0d                	je     800fef <strtol+0xd0>
		*endptr = (char *) s;
  800fe2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe5:	89 0e                	mov    %ecx,(%esi)
  800fe7:	eb 06                	jmp    800fef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fe9:	85 db                	test   %ebx,%ebx
  800feb:	74 98                	je     800f85 <strtol+0x66>
  800fed:	eb 9e                	jmp    800f8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fef:	89 c2                	mov    %eax,%edx
  800ff1:	f7 da                	neg    %edx
  800ff3:	85 ff                	test   %edi,%edi
  800ff5:	0f 45 c2             	cmovne %edx,%eax
}
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	89 c3                	mov    %eax,%ebx
  801010:	89 c7                	mov    %eax,%edi
  801012:	89 c6                	mov    %eax,%esi
  801014:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_cgetc>:

int
sys_cgetc(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 d7                	mov    %edx,%edi
  801031:	89 d6                	mov    %edx,%esi
  801033:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	b9 00 00 00 00       	mov    $0x0,%ecx
  801048:	b8 03 00 00 00       	mov    $0x3,%eax
  80104d:	8b 55 08             	mov    0x8(%ebp),%edx
  801050:	89 cb                	mov    %ecx,%ebx
  801052:	89 cf                	mov    %ecx,%edi
  801054:	89 ce                	mov    %ecx,%esi
  801056:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	7e 17                	jle    801073 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	50                   	push   %eax
  801060:	6a 03                	push   $0x3
  801062:	68 c8 18 80 00       	push   $0x8018c8
  801067:	6a 23                	push   $0x23
  801069:	68 e5 18 80 00       	push   $0x8018e5
  80106e:	e8 66 f5 ff ff       	call   8005d9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	b8 02 00 00 00       	mov    $0x2,%eax
  80108b:	89 d1                	mov    %edx,%ecx
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 d7                	mov    %edx,%edi
  801091:	89 d6                	mov    %edx,%esi
  801093:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sys_yield>:

void
sys_yield(void)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010aa:	89 d1                	mov    %edx,%ecx
  8010ac:	89 d3                	mov    %edx,%ebx
  8010ae:	89 d7                	mov    %edx,%edi
  8010b0:	89 d6                	mov    %edx,%esi
  8010b2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d5:	89 f7                	mov    %esi,%edi
  8010d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	7e 17                	jle    8010f4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	50                   	push   %eax
  8010e1:	6a 04                	push   $0x4
  8010e3:	68 c8 18 80 00       	push   $0x8018c8
  8010e8:	6a 23                	push   $0x23
  8010ea:	68 e5 18 80 00       	push   $0x8018e5
  8010ef:	e8 e5 f4 ff ff       	call   8005d9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801105:	b8 05 00 00 00       	mov    $0x5,%eax
  80110a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110d:	8b 55 08             	mov    0x8(%ebp),%edx
  801110:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801113:	8b 7d 14             	mov    0x14(%ebp),%edi
  801116:	8b 75 18             	mov    0x18(%ebp),%esi
  801119:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111b:	85 c0                	test   %eax,%eax
  80111d:	7e 17                	jle    801136 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	50                   	push   %eax
  801123:	6a 05                	push   $0x5
  801125:	68 c8 18 80 00       	push   $0x8018c8
  80112a:	6a 23                	push   $0x23
  80112c:	68 e5 18 80 00       	push   $0x8018e5
  801131:	e8 a3 f4 ff ff       	call   8005d9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	b8 06 00 00 00       	mov    $0x6,%eax
  801151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801154:	8b 55 08             	mov    0x8(%ebp),%edx
  801157:	89 df                	mov    %ebx,%edi
  801159:	89 de                	mov    %ebx,%esi
  80115b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115d:	85 c0                	test   %eax,%eax
  80115f:	7e 17                	jle    801178 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	50                   	push   %eax
  801165:	6a 06                	push   $0x6
  801167:	68 c8 18 80 00       	push   $0x8018c8
  80116c:	6a 23                	push   $0x23
  80116e:	68 e5 18 80 00       	push   $0x8018e5
  801173:	e8 61 f4 ff ff       	call   8005d9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	57                   	push   %edi
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	b8 08 00 00 00       	mov    $0x8,%eax
  801193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801196:	8b 55 08             	mov    0x8(%ebp),%edx
  801199:	89 df                	mov    %ebx,%edi
  80119b:	89 de                	mov    %ebx,%esi
  80119d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	7e 17                	jle    8011ba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	50                   	push   %eax
  8011a7:	6a 08                	push   $0x8
  8011a9:	68 c8 18 80 00       	push   $0x8018c8
  8011ae:	6a 23                	push   $0x23
  8011b0:	68 e5 18 80 00       	push   $0x8018e5
  8011b5:	e8 1f f4 ff ff       	call   8005d9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011db:	89 df                	mov    %ebx,%edi
  8011dd:	89 de                	mov    %ebx,%esi
  8011df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	7e 17                	jle    8011fc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e5:	83 ec 0c             	sub    $0xc,%esp
  8011e8:	50                   	push   %eax
  8011e9:	6a 09                	push   $0x9
  8011eb:	68 c8 18 80 00       	push   $0x8018c8
  8011f0:	6a 23                	push   $0x23
  8011f2:	68 e5 18 80 00       	push   $0x8018e5
  8011f7:	e8 dd f3 ff ff       	call   8005d9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120a:	be 00 00 00 00       	mov    $0x0,%esi
  80120f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801217:	8b 55 08             	mov    0x8(%ebp),%edx
  80121a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80121d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801220:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	57                   	push   %edi
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801230:	b9 00 00 00 00       	mov    $0x0,%ecx
  801235:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123a:	8b 55 08             	mov    0x8(%ebp),%edx
  80123d:	89 cb                	mov    %ecx,%ebx
  80123f:	89 cf                	mov    %ecx,%edi
  801241:	89 ce                	mov    %ecx,%esi
  801243:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801245:	85 c0                	test   %eax,%eax
  801247:	7e 17                	jle    801260 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	50                   	push   %eax
  80124d:	6a 0c                	push   $0xc
  80124f:	68 c8 18 80 00       	push   $0x8018c8
  801254:	6a 23                	push   $0x23
  801256:	68 e5 18 80 00       	push   $0x8018e5
  80125b:	e8 79 f3 ff ff       	call   8005d9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80126e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801275:	75 14                	jne    80128b <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	68 f4 18 80 00       	push   $0x8018f4
  80127f:	6a 20                	push   $0x20
  801281:	68 18 19 80 00       	push   $0x801918
  801286:	e8 4e f3 ff ff       	call   8005d9 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    
  801295:	66 90                	xchg   %ax,%ax
  801297:	66 90                	xchg   %ax,%ax
  801299:	66 90                	xchg   %ax,%ax
  80129b:	66 90                	xchg   %ax,%ax
  80129d:	66 90                	xchg   %ax,%ax
  80129f:	90                   	nop

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 f6                	test   %esi,%esi
  8012b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bd:	89 ca                	mov    %ecx,%edx
  8012bf:	89 f8                	mov    %edi,%eax
  8012c1:	75 3d                	jne    801300 <__udivdi3+0x60>
  8012c3:	39 cf                	cmp    %ecx,%edi
  8012c5:	0f 87 c5 00 00 00    	ja     801390 <__udivdi3+0xf0>
  8012cb:	85 ff                	test   %edi,%edi
  8012cd:	89 fd                	mov    %edi,%ebp
  8012cf:	75 0b                	jne    8012dc <__udivdi3+0x3c>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	31 d2                	xor    %edx,%edx
  8012d8:	f7 f7                	div    %edi
  8012da:	89 c5                	mov    %eax,%ebp
  8012dc:	89 c8                	mov    %ecx,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f5                	div    %ebp
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	89 cf                	mov    %ecx,%edi
  8012e8:	f7 f5                	div    %ebp
  8012ea:	89 c3                	mov    %eax,%ebx
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	89 fa                	mov    %edi,%edx
  8012f0:	83 c4 1c             	add    $0x1c,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	90                   	nop
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 ce                	cmp    %ecx,%esi
  801302:	77 74                	ja     801378 <__udivdi3+0xd8>
  801304:	0f bd fe             	bsr    %esi,%edi
  801307:	83 f7 1f             	xor    $0x1f,%edi
  80130a:	0f 84 98 00 00 00    	je     8013a8 <__udivdi3+0x108>
  801310:	bb 20 00 00 00       	mov    $0x20,%ebx
  801315:	89 f9                	mov    %edi,%ecx
  801317:	89 c5                	mov    %eax,%ebp
  801319:	29 fb                	sub    %edi,%ebx
  80131b:	d3 e6                	shl    %cl,%esi
  80131d:	89 d9                	mov    %ebx,%ecx
  80131f:	d3 ed                	shr    %cl,%ebp
  801321:	89 f9                	mov    %edi,%ecx
  801323:	d3 e0                	shl    %cl,%eax
  801325:	09 ee                	or     %ebp,%esi
  801327:	89 d9                	mov    %ebx,%ecx
  801329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132d:	89 d5                	mov    %edx,%ebp
  80132f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801333:	d3 ed                	shr    %cl,%ebp
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e2                	shl    %cl,%edx
  801339:	89 d9                	mov    %ebx,%ecx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	09 c2                	or     %eax,%edx
  80133f:	89 d0                	mov    %edx,%eax
  801341:	89 ea                	mov    %ebp,%edx
  801343:	f7 f6                	div    %esi
  801345:	89 d5                	mov    %edx,%ebp
  801347:	89 c3                	mov    %eax,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	39 d5                	cmp    %edx,%ebp
  80134f:	72 10                	jb     801361 <__udivdi3+0xc1>
  801351:	8b 74 24 08          	mov    0x8(%esp),%esi
  801355:	89 f9                	mov    %edi,%ecx
  801357:	d3 e6                	shl    %cl,%esi
  801359:	39 c6                	cmp    %eax,%esi
  80135b:	73 07                	jae    801364 <__udivdi3+0xc4>
  80135d:	39 d5                	cmp    %edx,%ebp
  80135f:	75 03                	jne    801364 <__udivdi3+0xc4>
  801361:	83 eb 01             	sub    $0x1,%ebx
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 d8                	mov    %ebx,%eax
  801368:	89 fa                	mov    %edi,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 ff                	xor    %edi,%edi
  80137a:	31 db                	xor    %ebx,%ebx
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 1c             	add    $0x1c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 d8                	mov    %ebx,%eax
  801392:	f7 f7                	div    %edi
  801394:	31 ff                	xor    %edi,%edi
  801396:	89 c3                	mov    %eax,%ebx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 fa                	mov    %edi,%edx
  80139c:	83 c4 1c             	add    $0x1c,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	39 ce                	cmp    %ecx,%esi
  8013aa:	72 0c                	jb     8013b8 <__udivdi3+0x118>
  8013ac:	31 db                	xor    %ebx,%ebx
  8013ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013b2:	0f 87 34 ff ff ff    	ja     8012ec <__udivdi3+0x4c>
  8013b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013bd:	e9 2a ff ff ff       	jmp    8012ec <__udivdi3+0x4c>
  8013c2:	66 90                	xchg   %ax,%ax
  8013c4:	66 90                	xchg   %ax,%ax
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
  8013d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fa:	75 1c                	jne    801418 <__umoddi3+0x48>
  8013fc:	39 f7                	cmp    %esi,%edi
  8013fe:	76 50                	jbe    801450 <__umoddi3+0x80>
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	f7 f7                	div    %edi
  801406:	89 d0                	mov    %edx,%eax
  801408:	31 d2                	xor    %edx,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	39 f2                	cmp    %esi,%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	77 52                	ja     801470 <__umoddi3+0xa0>
  80141e:	0f bd ea             	bsr    %edx,%ebp
  801421:	83 f5 1f             	xor    $0x1f,%ebp
  801424:	75 5a                	jne    801480 <__umoddi3+0xb0>
  801426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80142a:	0f 82 e0 00 00 00    	jb     801510 <__umoddi3+0x140>
  801430:	39 0c 24             	cmp    %ecx,(%esp)
  801433:	0f 86 d7 00 00 00    	jbe    801510 <__umoddi3+0x140>
  801439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80143d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801441:	83 c4 1c             	add    $0x1c,%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    
  801449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801450:	85 ff                	test   %edi,%edi
  801452:	89 fd                	mov    %edi,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x91>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f7                	div    %edi
  80145f:	89 c5                	mov    %eax,%ebp
  801461:	89 f0                	mov    %esi,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f5                	div    %ebp
  801467:	89 c8                	mov    %ecx,%eax
  801469:	f7 f5                	div    %ebp
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	eb 99                	jmp    801408 <__umoddi3+0x38>
  80146f:	90                   	nop
  801470:	89 c8                	mov    %ecx,%eax
  801472:	89 f2                	mov    %esi,%edx
  801474:	83 c4 1c             	add    $0x1c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	8b 34 24             	mov    (%esp),%esi
  801483:	bf 20 00 00 00       	mov    $0x20,%edi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	29 ef                	sub    %ebp,%edi
  80148c:	d3 e0                	shl    %cl,%eax
  80148e:	89 f9                	mov    %edi,%ecx
  801490:	89 f2                	mov    %esi,%edx
  801492:	d3 ea                	shr    %cl,%edx
  801494:	89 e9                	mov    %ebp,%ecx
  801496:	09 c2                	or     %eax,%edx
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	89 14 24             	mov    %edx,(%esp)
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	d3 e2                	shl    %cl,%edx
  8014a1:	89 f9                	mov    %edi,%ecx
  8014a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014ab:	d3 e8                	shr    %cl,%eax
  8014ad:	89 e9                	mov    %ebp,%ecx
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	d3 e3                	shl    %cl,%ebx
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	09 d8                	or     %ebx,%eax
  8014bd:	89 d3                	mov    %edx,%ebx
  8014bf:	89 f2                	mov    %esi,%edx
  8014c1:	f7 34 24             	divl   (%esp)
  8014c4:	89 d6                	mov    %edx,%esi
  8014c6:	d3 e3                	shl    %cl,%ebx
  8014c8:	f7 64 24 04          	mull   0x4(%esp)
  8014cc:	39 d6                	cmp    %edx,%esi
  8014ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d2:	89 d1                	mov    %edx,%ecx
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	72 08                	jb     8014e0 <__umoddi3+0x110>
  8014d8:	75 11                	jne    8014eb <__umoddi3+0x11b>
  8014da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014de:	73 0b                	jae    8014eb <__umoddi3+0x11b>
  8014e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014e4:	1b 14 24             	sbb    (%esp),%edx
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014ef:	29 da                	sub    %ebx,%edx
  8014f1:	19 ce                	sbb    %ecx,%esi
  8014f3:	89 f9                	mov    %edi,%ecx
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	d3 e0                	shl    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	d3 ea                	shr    %cl,%edx
  8014fd:	89 e9                	mov    %ebp,%ecx
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	09 d0                	or     %edx,%eax
  801503:	89 f2                	mov    %esi,%edx
  801505:	83 c4 1c             	add    $0x1c,%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	29 f9                	sub    %edi,%ecx
  801512:	19 d6                	sbb    %edx,%esi
  801514:	89 74 24 04          	mov    %esi,0x4(%esp)
  801518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151c:	e9 18 ff ff ff       	jmp    801439 <__umoddi3+0x69>
