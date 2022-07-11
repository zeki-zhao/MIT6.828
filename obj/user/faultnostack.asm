
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 07 03 80 00       	push   $0x800307
  80003e:	6a 00                	push   $0x0
  800040:	e8 1c 02 00 00       	call   800261 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 08             	sub    $0x8,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	52                   	push   %edx
  80007a:	50                   	push   %eax
  80007b:	e8 b3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800080:	e8 05 00 00 00       	call   80008a <exit>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	c9                   	leave  
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800090:	6a 00                	push   $0x0
  800092:	e8 42 00 00 00       	call   8000d9 <sys_env_destroy>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 17                	jle    800112 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	50                   	push   %eax
  8000ff:	6a 03                	push   $0x3
  800101:	68 0a 10 80 00       	push   $0x80100a
  800106:	6a 23                	push   $0x23
  800108:	68 27 10 80 00       	push   $0x801027
  80010d:	e8 00 02 00 00       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 02 00 00 00       	mov    $0x2,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <sys_yield>:

void
sys_yield(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 0a 00 00 00       	mov    $0xa,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	be 00 00 00 00       	mov    $0x0,%esi
  800166:	b8 04 00 00 00       	mov    $0x4,%eax
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
  800171:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800174:	89 f7                	mov    %esi,%edi
  800176:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800178:	85 c0                	test   %eax,%eax
  80017a:	7e 17                	jle    800193 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017c:	83 ec 0c             	sub    $0xc,%esp
  80017f:	50                   	push   %eax
  800180:	6a 04                	push   $0x4
  800182:	68 0a 10 80 00       	push   $0x80100a
  800187:	6a 23                	push   $0x23
  800189:	68 27 10 80 00       	push   $0x801027
  80018e:	e8 7f 01 00 00       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800196:	5b                   	pop    %ebx
  800197:	5e                   	pop    %esi
  800198:	5f                   	pop    %edi
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	7e 17                	jle    8001d5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	50                   	push   %eax
  8001c2:	6a 05                	push   $0x5
  8001c4:	68 0a 10 80 00       	push   $0x80100a
  8001c9:	6a 23                	push   $0x23
  8001cb:	68 27 10 80 00       	push   $0x801027
  8001d0:	e8 3d 01 00 00       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	89 df                	mov    %ebx,%edi
  8001f8:	89 de                	mov    %ebx,%esi
  8001fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7e 17                	jle    800217 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	50                   	push   %eax
  800204:	6a 06                	push   $0x6
  800206:	68 0a 10 80 00       	push   $0x80100a
  80020b:	6a 23                	push   $0x23
  80020d:	68 27 10 80 00       	push   $0x801027
  800212:	e8 fb 00 00 00       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	b8 08 00 00 00       	mov    $0x8,%eax
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7e 17                	jle    800259 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	50                   	push   %eax
  800246:	6a 08                	push   $0x8
  800248:	68 0a 10 80 00       	push   $0x80100a
  80024d:	6a 23                	push   $0x23
  80024f:	68 27 10 80 00       	push   $0x801027
  800254:	e8 b9 00 00 00       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	b8 09 00 00 00       	mov    $0x9,%eax
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	89 df                	mov    %ebx,%edi
  80027c:	89 de                	mov    %ebx,%esi
  80027e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800280:	85 c0                	test   %eax,%eax
  800282:	7e 17                	jle    80029b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	50                   	push   %eax
  800288:	6a 09                	push   $0x9
  80028a:	68 0a 10 80 00       	push   $0x80100a
  80028f:	6a 23                	push   $0x23
  800291:	68 27 10 80 00       	push   $0x801027
  800296:	e8 77 00 00 00       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5e                   	pop    %esi
  8002a0:	5f                   	pop    %edi
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 cb                	mov    %ecx,%ebx
  8002de:	89 cf                	mov    %ecx,%edi
  8002e0:	89 ce                	mov    %ecx,%esi
  8002e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 17                	jle    8002ff <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	50                   	push   %eax
  8002ec:	6a 0c                	push   $0xc
  8002ee:	68 0a 10 80 00       	push   $0x80100a
  8002f3:	6a 23                	push   $0x23
  8002f5:	68 27 10 80 00       	push   $0x801027
  8002fa:	e8 13 00 00 00       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800307:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800308:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80030d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80030f:	83 c4 04             	add    $0x4,%esp

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800320:	e8 f5 fd ff ff       	call   80011a <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 38 10 80 00       	push   $0x801038
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 14 fd ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 1a 01 00 00       	call   8004e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 b9 fc ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 1d 09 00 00       	call   800d70 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 0a 0a 00 00       	call   800ea0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bd:	73 0a                	jae    8004c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	88 02                	mov    %al,(%edx)
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 10             	pushl  0x10(%ebp)
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 05 00 00 00       	call   8004e8 <vprintfmt>
	va_end(ap);
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	57                   	push   %edi
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 2c             	sub    $0x2c,%esp
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fa:	eb 12                	jmp    80050e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	0f 84 42 04 00 00    	je     800946 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e2                	jne    8004fc <vprintfmt+0x14>
  80051a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 07                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8d 47 01             	lea    0x1(%edi),%eax
  800544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800547:	0f b6 07             	movzbl (%edi),%eax
  80054a:	0f b6 d0             	movzbl %al,%edx
  80054d:	83 e8 23             	sub    $0x23,%eax
  800550:	3c 55                	cmp    $0x55,%al
  800552:	0f 87 d3 03 00 00    	ja     80092b <vprintfmt+0x443>
  800558:	0f b6 c0             	movzbl %al,%eax
  80055b:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800569:	eb d6                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800583:	83 f9 09             	cmp    $0x9,%ecx
  800586:	77 3f                	ja     8005c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 2a                	jmp    8005cd <vprintfmt+0xe5>
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	0f 49 d0             	cmovns %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	eb 89                	jmp    800541 <vprintfmt+0x59>
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c2:	e9 7a ff ff ff       	jmp    800541 <vprintfmt+0x59>
  8005c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 6a ff ff ff    	jns    800541 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 58 ff ff ff       	jmp    800541 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 4d ff ff ff       	jmp    800541 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	ff 30                	pushl  (%eax)
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 fe fe ff ff       	jmp    80050e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 09             	cmp    $0x9,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x145>
  800622:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 1b                	jne    800648 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 75 10 80 00       	push   $0x801075
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 91 fe ff ff       	call   8004cb <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 c6 fe ff ff       	jmp    80050e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 7e 10 80 00       	push   $0x80107e
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 76 fe ff ff       	call   8004cb <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ab fe ff ff       	jmp    80050e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800671:	85 ff                	test   %edi,%edi
  800673:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  800678:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80067b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067f:	0f 8e 94 00 00 00    	jle    800719 <vprintfmt+0x231>
  800685:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800689:	0f 84 98 00 00 00    	je     800727 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 33 03 00 00       	call   8009ce <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1cc>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	29 c1                	sub    %eax,%ecx
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	89 cb                	mov    %ecx,%ebx
  8006e4:	eb 4d                	jmp    800733 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x21f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x21f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 1a                	jmp    800733 <vprintfmt+0x24b>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb 0c                	jmp    800733 <vprintfmt+0x24b>
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 23                	je     800764 <vprintfmt+0x27c>
  800741:	85 f6                	test   %esi,%esi
  800743:	78 a1                	js     8006e6 <vprintfmt+0x1fe>
  800745:	83 ee 01             	sub    $0x1,%esi
  800748:	79 9c                	jns    8006e6 <vprintfmt+0x1fe>
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb 18                	jmp    80076c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 08                	jmp    80076c <vprintfmt+0x284>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7f e4                	jg     800754 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fd ff ff       	jmp    80050e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7e 19                	jle    80079c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
  80079a:	eb 38                	jmp    8007d4 <vprintfmt+0x2ec>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 1b                	je     8007bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb 19                	jmp    8007d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e3:	0f 89 0e 01 00 00    	jns    8008f7 <vprintfmt+0x40f>
				putch('-', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 2d                	push   $0x2d
  8007ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f7:	f7 da                	neg    %edx
  8007f9:	83 d1 00             	adc    $0x0,%ecx
  8007fc:	f7 d9                	neg    %ecx
  8007fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 ec 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 cf 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 1a                	je     800846 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 b1 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 97 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 58                	push   $0x58
  800866:	ff d6                	call   *%esi
			putch('X', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 58                	push   $0x58
  80086e:	ff d6                	call   *%esi
			putch('X', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 58                	push   $0x58
  800876:	ff d6                	call   *%esi
			break;
  800878:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80087e:	e9 8b fc ff ff       	jmp    80050e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 30                	push   $0x30
  800889:	ff d6                	call   *%esi
			putch('x', putdat);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 78                	push   $0x78
  800891:	ff d6                	call   *%esi
			num = (unsigned long long)
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8b 10                	mov    (%eax),%edx
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ab:	eb 4a                	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ad:	83 f9 01             	cmp    $0x1,%ecx
  8008b0:	7e 15                	jle    8008c7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ba:	8d 40 08             	lea    0x8(%eax),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c5:	eb 30                	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 17                	je     8008e2 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008db:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e0:	eb 15                	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008fe:	57                   	push   %edi
  8008ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800902:	50                   	push   %eax
  800903:	51                   	push   %ecx
  800904:	52                   	push   %edx
  800905:	89 da                	mov    %ebx,%edx
  800907:	89 f0                	mov    %esi,%eax
  800909:	e8 f1 fa ff ff       	call   8003ff <printnum>
			break;
  80090e:	83 c4 20             	add    $0x20,%esp
  800911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800914:	e9 f5 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	52                   	push   %edx
  80091e:	ff d6                	call   *%esi
			break;
  800920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800926:	e9 e3 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 25                	push   $0x25
  800931:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb 03                	jmp    80093b <vprintfmt+0x453>
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80093f:	75 f7                	jne    800938 <vprintfmt+0x450>
  800941:	e9 c8 fb ff ff       	jmp    80050e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 18             	sub    $0x18,%esp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800961:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	74 26                	je     800995 <vsnprintf+0x47>
  80096f:	85 d2                	test   %edx,%edx
  800971:	7e 22                	jle    800995 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800973:	ff 75 14             	pushl  0x14(%ebp)
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097c:	50                   	push   %eax
  80097d:	68 ae 04 80 00       	push   $0x8004ae
  800982:	e8 61 fb ff ff       	call   8004e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb 05                	jmp    80099a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a5:	50                   	push   %eax
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 9a ff ff ff       	call   80094e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 03                	jmp    8009c6 <strlen+0x10>
		n++;
  8009c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ca:	75 f7                	jne    8009c3 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	eb 03                	jmp    8009e1 <strnlen+0x13>
		n++;
  8009de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e1:	39 c2                	cmp    %eax,%edx
  8009e3:	74 08                	je     8009ed <strnlen+0x1f>
  8009e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e9:	75 f3                	jne    8009de <strnlen+0x10>
  8009eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a05:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a08:	84 db                	test   %bl,%bl
  800a0a:	75 ef                	jne    8009fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a16:	53                   	push   %ebx
  800a17:	e8 9a ff ff ff       	call   8009b6 <strlen>
  800a1c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	01 d8                	add    %ebx,%eax
  800a24:	50                   	push   %eax
  800a25:	e8 c5 ff ff ff       	call   8009ef <strcpy>
	return dst;
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	89 f2                	mov    %esi,%edx
  800a43:	eb 0f                	jmp    800a54 <strncpy+0x23>
		*dst++ = *src;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	0f b6 01             	movzbl (%ecx),%eax
  800a4b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a51:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	39 da                	cmp    %ebx,%edx
  800a56:	75 ed                	jne    800a45 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a58:	89 f0                	mov    %esi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a69:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	74 21                	je     800a93 <strlcpy+0x35>
  800a72:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a76:	89 f2                	mov    %esi,%edx
  800a78:	eb 09                	jmp    800a83 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	74 09                	je     800a90 <strlcpy+0x32>
  800a87:	0f b6 19             	movzbl (%ecx),%ebx
  800a8a:	84 db                	test   %bl,%bl
  800a8c:	75 ec                	jne    800a7a <strlcpy+0x1c>
  800a8e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a90:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a93:	29 f0                	sub    %esi,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa2:	eb 06                	jmp    800aaa <strcmp+0x11>
		p++, q++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaa:	0f b6 01             	movzbl (%ecx),%eax
  800aad:	84 c0                	test   %al,%al
  800aaf:	74 04                	je     800ab5 <strcmp+0x1c>
  800ab1:	3a 02                	cmp    (%edx),%al
  800ab3:	74 ef                	je     800aa4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 12             	movzbl (%edx),%edx
  800abb:	29 d0                	sub    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	53                   	push   %ebx
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ace:	eb 06                	jmp    800ad6 <strncmp+0x17>
		n--, p++, q++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad6:	39 d8                	cmp    %ebx,%eax
  800ad8:	74 15                	je     800aef <strncmp+0x30>
  800ada:	0f b6 08             	movzbl (%eax),%ecx
  800add:	84 c9                	test   %cl,%cl
  800adf:	74 04                	je     800ae5 <strncmp+0x26>
  800ae1:	3a 0a                	cmp    (%edx),%cl
  800ae3:	74 eb                	je     800ad0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
  800aed:	eb 05                	jmp    800af4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 07                	jmp    800b0a <strchr+0x13>
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 0f                	je     800b16 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b22:	eb 03                	jmp    800b27 <strfind+0xf>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2a:	38 ca                	cmp    %cl,%dl
  800b2c:	74 04                	je     800b32 <strfind+0x1a>
  800b2e:	84 d2                	test   %dl,%dl
  800b30:	75 f2                	jne    800b24 <strfind+0xc>
			break;
	return (char *) s;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	74 36                	je     800b7a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4a:	75 28                	jne    800b74 <memset+0x40>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 23                	jne    800b74 <memset+0x40>
		c &= 0xFF;
  800b51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	c1 e3 08             	shl    $0x8,%ebx
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	c1 e6 18             	shl    $0x18,%esi
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	c1 e0 10             	shl    $0x10,%eax
  800b64:	09 f0                	or     %esi,%eax
  800b66:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	09 d0                	or     %edx,%eax
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
  800b6f:	fc                   	cld    
  800b70:	f3 ab                	rep stos %eax,%es:(%edi)
  800b72:	eb 06                	jmp    800b7a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	fc                   	cld    
  800b78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7a:	89 f8                	mov    %edi,%eax
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	73 35                	jae    800bc8 <memmove+0x47>
  800b93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 2e                	jae    800bc8 <memmove+0x47>
		s += n;
		d += n;
  800b9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	09 fe                	or     %edi,%esi
  800ba1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba7:	75 13                	jne    800bbc <memmove+0x3b>
  800ba9:	f6 c1 03             	test   $0x3,%cl
  800bac:	75 0e                	jne    800bbc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bae:	83 ef 04             	sub    $0x4,%edi
  800bb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
  800bb7:	fd                   	std    
  800bb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bba:	eb 09                	jmp    800bc5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bbc:	83 ef 01             	sub    $0x1,%edi
  800bbf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc2:	fd                   	std    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc5:	fc                   	cld    
  800bc6:	eb 1d                	jmp    800be5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	09 c2                	or     %eax,%edx
  800bcc:	f6 c2 03             	test   $0x3,%dl
  800bcf:	75 0f                	jne    800be0 <memmove+0x5f>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0a                	jne    800be0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 05                	jmp    800be5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be0:	89 c7                	mov    %eax,%edi
  800be2:	fc                   	cld    
  800be3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	ff 75 08             	pushl  0x8(%ebp)
  800bf5:	e8 87 ff ff ff       	call   800b81 <memmove>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0c:	eb 1a                	jmp    800c28 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0e:	0f b6 08             	movzbl (%eax),%ecx
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	38 d9                	cmp    %bl,%cl
  800c16:	74 0a                	je     800c22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c18:	0f b6 c1             	movzbl %cl,%eax
  800c1b:	0f b6 db             	movzbl %bl,%ebx
  800c1e:	29 d8                	sub    %ebx,%eax
  800c20:	eb 0f                	jmp    800c31 <memcmp+0x35>
		s1++, s2++;
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c28:	39 f0                	cmp    %esi,%eax
  800c2a:	75 e2                	jne    800c0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3c:	89 c1                	mov    %eax,%ecx
  800c3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c45:	eb 0a                	jmp    800c51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	0f b6 10             	movzbl (%eax),%edx
  800c4a:	39 da                	cmp    %ebx,%edx
  800c4c:	74 07                	je     800c55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4e:	83 c0 01             	add    $0x1,%eax
  800c51:	39 c8                	cmp    %ecx,%eax
  800c53:	72 f2                	jb     800c47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c55:	5b                   	pop    %ebx
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c64:	eb 03                	jmp    800c69 <strtol+0x11>
		s++;
  800c66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	0f b6 01             	movzbl (%ecx),%eax
  800c6c:	3c 20                	cmp    $0x20,%al
  800c6e:	74 f6                	je     800c66 <strtol+0xe>
  800c70:	3c 09                	cmp    $0x9,%al
  800c72:	74 f2                	je     800c66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c74:	3c 2b                	cmp    $0x2b,%al
  800c76:	75 0a                	jne    800c82 <strtol+0x2a>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 11                	jmp    800c93 <strtol+0x3b>
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c87:	3c 2d                	cmp    $0x2d,%al
  800c89:	75 08                	jne    800c93 <strtol+0x3b>
		s++, neg = 1;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c99:	75 15                	jne    800cb0 <strtol+0x58>
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	75 10                	jne    800cb0 <strtol+0x58>
  800ca0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca4:	75 7c                	jne    800d22 <strtol+0xca>
		s += 2, base = 16;
  800ca6:	83 c1 02             	add    $0x2,%ecx
  800ca9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cae:	eb 16                	jmp    800cc6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cb0:	85 db                	test   %ebx,%ebx
  800cb2:	75 12                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbc:	75 08                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cce:	0f b6 11             	movzbl (%ecx),%edx
  800cd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd4:	89 f3                	mov    %esi,%ebx
  800cd6:	80 fb 09             	cmp    $0x9,%bl
  800cd9:	77 08                	ja     800ce3 <strtol+0x8b>
			dig = *s - '0';
  800cdb:	0f be d2             	movsbl %dl,%edx
  800cde:	83 ea 30             	sub    $0x30,%edx
  800ce1:	eb 22                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 57             	sub    $0x57,%edx
  800cf3:	eb 10                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf8:	89 f3                	mov    %esi,%ebx
  800cfa:	80 fb 19             	cmp    $0x19,%bl
  800cfd:	77 16                	ja     800d15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cff:	0f be d2             	movsbl %dl,%edx
  800d02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d08:	7d 0b                	jge    800d15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d13:	eb b9                	jmp    800cce <strtol+0x76>

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 0d                	je     800d28 <strtol+0xd0>
		*endptr = (char *) s;
  800d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1e:	89 0e                	mov    %ecx,(%esi)
  800d20:	eb 06                	jmp    800d28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	74 98                	je     800cbe <strtol+0x66>
  800d26:	eb 9e                	jmp    800cc6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d28:	89 c2                	mov    %eax,%edx
  800d2a:	f7 da                	neg    %edx
  800d2c:	85 ff                	test   %edi,%edi
  800d2e:	0f 45 c2             	cmovne %edx,%eax
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d3c:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d43:	75 14                	jne    800d59 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 a8 12 80 00       	push   $0x8012a8
  800d4d:	6a 20                	push   $0x20
  800d4f:	68 cc 12 80 00       	push   $0x8012cc
  800d54:	e8 b9 f5 ff ff       	call   800312 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    
  800d63:	66 90                	xchg   %ax,%ax
  800d65:	66 90                	xchg   %ax,%ax
  800d67:	66 90                	xchg   %ax,%ax
  800d69:	66 90                	xchg   %ax,%ax
  800d6b:	66 90                	xchg   %ax,%ax
  800d6d:	66 90                	xchg   %ax,%ax
  800d6f:	90                   	nop

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d87:	85 f6                	test   %esi,%esi
  800d89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d8d:	89 ca                	mov    %ecx,%edx
  800d8f:	89 f8                	mov    %edi,%eax
  800d91:	75 3d                	jne    800dd0 <__udivdi3+0x60>
  800d93:	39 cf                	cmp    %ecx,%edi
  800d95:	0f 87 c5 00 00 00    	ja     800e60 <__udivdi3+0xf0>
  800d9b:	85 ff                	test   %edi,%edi
  800d9d:	89 fd                	mov    %edi,%ebp
  800d9f:	75 0b                	jne    800dac <__udivdi3+0x3c>
  800da1:	b8 01 00 00 00       	mov    $0x1,%eax
  800da6:	31 d2                	xor    %edx,%edx
  800da8:	f7 f7                	div    %edi
  800daa:	89 c5                	mov    %eax,%ebp
  800dac:	89 c8                	mov    %ecx,%eax
  800dae:	31 d2                	xor    %edx,%edx
  800db0:	f7 f5                	div    %ebp
  800db2:	89 c1                	mov    %eax,%ecx
  800db4:	89 d8                	mov    %ebx,%eax
  800db6:	89 cf                	mov    %ecx,%edi
  800db8:	f7 f5                	div    %ebp
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	89 fa                	mov    %edi,%edx
  800dc0:	83 c4 1c             	add    $0x1c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
  800dc8:	90                   	nop
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	39 ce                	cmp    %ecx,%esi
  800dd2:	77 74                	ja     800e48 <__udivdi3+0xd8>
  800dd4:	0f bd fe             	bsr    %esi,%edi
  800dd7:	83 f7 1f             	xor    $0x1f,%edi
  800dda:	0f 84 98 00 00 00    	je     800e78 <__udivdi3+0x108>
  800de0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	89 c5                	mov    %eax,%ebp
  800de9:	29 fb                	sub    %edi,%ebx
  800deb:	d3 e6                	shl    %cl,%esi
  800ded:	89 d9                	mov    %ebx,%ecx
  800def:	d3 ed                	shr    %cl,%ebp
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e0                	shl    %cl,%eax
  800df5:	09 ee                	or     %ebp,%esi
  800df7:	89 d9                	mov    %ebx,%ecx
  800df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfd:	89 d5                	mov    %edx,%ebp
  800dff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e03:	d3 ed                	shr    %cl,%ebp
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	d3 e2                	shl    %cl,%edx
  800e09:	89 d9                	mov    %ebx,%ecx
  800e0b:	d3 e8                	shr    %cl,%eax
  800e0d:	09 c2                	or     %eax,%edx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	89 ea                	mov    %ebp,%edx
  800e13:	f7 f6                	div    %esi
  800e15:	89 d5                	mov    %edx,%ebp
  800e17:	89 c3                	mov    %eax,%ebx
  800e19:	f7 64 24 0c          	mull   0xc(%esp)
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	72 10                	jb     800e31 <__udivdi3+0xc1>
  800e21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e6                	shl    %cl,%esi
  800e29:	39 c6                	cmp    %eax,%esi
  800e2b:	73 07                	jae    800e34 <__udivdi3+0xc4>
  800e2d:	39 d5                	cmp    %edx,%ebp
  800e2f:	75 03                	jne    800e34 <__udivdi3+0xc4>
  800e31:	83 eb 01             	sub    $0x1,%ebx
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 d8                	mov    %ebx,%eax
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	31 ff                	xor    %edi,%edi
  800e4a:	31 db                	xor    %ebx,%ebx
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
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	f7 f7                	div    %edi
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	89 fa                	mov    %edi,%edx
  800e6c:	83 c4 1c             	add    $0x1c,%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	39 ce                	cmp    %ecx,%esi
  800e7a:	72 0c                	jb     800e88 <__udivdi3+0x118>
  800e7c:	31 db                	xor    %ebx,%ebx
  800e7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e82:	0f 87 34 ff ff ff    	ja     800dbc <__udivdi3+0x4c>
  800e88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e8d:	e9 2a ff ff ff       	jmp    800dbc <__udivdi3+0x4c>
  800e92:	66 90                	xchg   %ax,%ax
  800e94:	66 90                	xchg   %ax,%ax
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	66 90                	xchg   %ax,%ax
  800e9a:	66 90                	xchg   %ax,%ax
  800e9c:	66 90                	xchg   %ax,%ax
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <__umoddi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eb7:	85 d2                	test   %edx,%edx
  800eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f3                	mov    %esi,%ebx
  800ec3:	89 3c 24             	mov    %edi,(%esp)
  800ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eca:	75 1c                	jne    800ee8 <__umoddi3+0x48>
  800ecc:	39 f7                	cmp    %esi,%edi
  800ece:	76 50                	jbe    800f20 <__umoddi3+0x80>
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	f7 f7                	div    %edi
  800ed6:	89 d0                	mov    %edx,%eax
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	89 d0                	mov    %edx,%eax
  800eec:	77 52                	ja     800f40 <__umoddi3+0xa0>
  800eee:	0f bd ea             	bsr    %edx,%ebp
  800ef1:	83 f5 1f             	xor    $0x1f,%ebp
  800ef4:	75 5a                	jne    800f50 <__umoddi3+0xb0>
  800ef6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800efa:	0f 82 e0 00 00 00    	jb     800fe0 <__umoddi3+0x140>
  800f00:	39 0c 24             	cmp    %ecx,(%esp)
  800f03:	0f 86 d7 00 00 00    	jbe    800fe0 <__umoddi3+0x140>
  800f09:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f11:	83 c4 1c             	add    $0x1c,%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	85 ff                	test   %edi,%edi
  800f22:	89 fd                	mov    %edi,%ebp
  800f24:	75 0b                	jne    800f31 <__umoddi3+0x91>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f7                	div    %edi
  800f2f:	89 c5                	mov    %eax,%ebp
  800f31:	89 f0                	mov    %esi,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f5                	div    %ebp
  800f37:	89 c8                	mov    %ecx,%eax
  800f39:	f7 f5                	div    %ebp
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	eb 99                	jmp    800ed8 <__umoddi3+0x38>
  800f3f:	90                   	nop
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	83 c4 1c             	add    $0x1c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
  800f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f50:	8b 34 24             	mov    (%esp),%esi
  800f53:	bf 20 00 00 00       	mov    $0x20,%edi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	29 ef                	sub    %ebp,%edi
  800f5c:	d3 e0                	shl    %cl,%eax
  800f5e:	89 f9                	mov    %edi,%ecx
  800f60:	89 f2                	mov    %esi,%edx
  800f62:	d3 ea                	shr    %cl,%edx
  800f64:	89 e9                	mov    %ebp,%ecx
  800f66:	09 c2                	or     %eax,%edx
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	89 14 24             	mov    %edx,(%esp)
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	d3 e2                	shl    %cl,%edx
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	d3 e3                	shl    %cl,%ebx
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 d0                	mov    %edx,%eax
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	09 d8                	or     %ebx,%eax
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 f2                	mov    %esi,%edx
  800f91:	f7 34 24             	divl   (%esp)
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	d3 e3                	shl    %cl,%ebx
  800f98:	f7 64 24 04          	mull   0x4(%esp)
  800f9c:	39 d6                	cmp    %edx,%esi
  800f9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	72 08                	jb     800fb0 <__umoddi3+0x110>
  800fa8:	75 11                	jne    800fbb <__umoddi3+0x11b>
  800faa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fae:	73 0b                	jae    800fbb <__umoddi3+0x11b>
  800fb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fb4:	1b 14 24             	sbb    (%esp),%edx
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fbf:	29 da                	sub    %ebx,%edx
  800fc1:	19 ce                	sbb    %ecx,%esi
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e0                	shl    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	d3 ea                	shr    %cl,%edx
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	d3 ee                	shr    %cl,%esi
  800fd1:	09 d0                	or     %edx,%eax
  800fd3:	89 f2                	mov    %esi,%edx
  800fd5:	83 c4 1c             	add    $0x1c,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
  800fe0:	29 f9                	sub    %edi,%ecx
  800fe2:	19 d6                	sbb    %edx,%esi
  800fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fec:	e9 18 ff ff ff       	jmp    800f09 <__umoddi3+0x69>
