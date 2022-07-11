
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 22 01 00 00       	call   800169 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 1c 02 00 00       	call   800272 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	8b 45 08             	mov    0x8(%ebp),%eax
  80006e:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800071:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800078:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 c0                	test   %eax,%eax
  80007d:	7e 08                	jle    800087 <libmain+0x22>
		binaryname = argv[0];
  80007f:	8b 0a                	mov    (%edx),%ecx
  800081:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	52                   	push   %edx
  80008b:	50                   	push   %eax
  80008c:	e8 a2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800091:	e8 05 00 00 00       	call   80009b <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	c9                   	leave  
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	e8 42 00 00 00       	call   8000ea <sys_env_destroy>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	89 c3                	mov    %eax,%ebx
  8000c0:	89 c7                	mov    %eax,%edi
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000db:	89 d1                	mov    %edx,%ecx
  8000dd:	89 d3                	mov    %edx,%ebx
  8000df:	89 d7                	mov    %edx,%edi
  8000e1:	89 d6                	mov    %edx,%esi
  8000e3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	89 cb                	mov    %ecx,%ebx
  800102:	89 cf                	mov    %ecx,%edi
  800104:	89 ce                	mov    %ecx,%esi
  800106:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	7e 17                	jle    800123 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	50                   	push   %eax
  800110:	6a 03                	push   $0x3
  800112:	68 ea 0f 80 00       	push   $0x800fea
  800117:	6a 23                	push   $0x23
  800119:	68 07 10 80 00       	push   $0x801007
  80011e:	e8 f5 01 00 00       	call   800318 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 02 00 00 00       	mov    $0x2,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_yield>:

void
sys_yield(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	be 00 00 00 00       	mov    $0x0,%esi
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800185:	89 f7                	mov    %esi,%edi
  800187:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800189:	85 c0                	test   %eax,%eax
  80018b:	7e 17                	jle    8001a4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	50                   	push   %eax
  800191:	6a 04                	push   $0x4
  800193:	68 ea 0f 80 00       	push   $0x800fea
  800198:	6a 23                	push   $0x23
  80019a:	68 07 10 80 00       	push   $0x801007
  80019f:	e8 74 01 00 00       	call   800318 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5e                   	pop    %esi
  8001a9:	5f                   	pop    %edi
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	7e 17                	jle    8001e6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cf:	83 ec 0c             	sub    $0xc,%esp
  8001d2:	50                   	push   %eax
  8001d3:	6a 05                	push   $0x5
  8001d5:	68 ea 0f 80 00       	push   $0x800fea
  8001da:	6a 23                	push   $0x23
  8001dc:	68 07 10 80 00       	push   $0x801007
  8001e1:	e8 32 01 00 00       	call   800318 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800204:	8b 55 08             	mov    0x8(%ebp),%edx
  800207:	89 df                	mov    %ebx,%edi
  800209:	89 de                	mov    %ebx,%esi
  80020b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	7e 17                	jle    800228 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	50                   	push   %eax
  800215:	6a 06                	push   $0x6
  800217:	68 ea 0f 80 00       	push   $0x800fea
  80021c:	6a 23                	push   $0x23
  80021e:	68 07 10 80 00       	push   $0x801007
  800223:	e8 f0 00 00 00       	call   800318 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 08 00 00 00       	mov    $0x8,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 17                	jle    80026a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	50                   	push   %eax
  800257:	6a 08                	push   $0x8
  800259:	68 ea 0f 80 00       	push   $0x800fea
  80025e:	6a 23                	push   $0x23
  800260:	68 07 10 80 00       	push   $0x801007
  800265:	e8 ae 00 00 00       	call   800318 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	b8 09 00 00 00       	mov    $0x9,%eax
  800285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7e 17                	jle    8002ac <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	50                   	push   %eax
  800299:	6a 09                	push   $0x9
  80029b:	68 ea 0f 80 00       	push   $0x800fea
  8002a0:	6a 23                	push   $0x23
  8002a2:	68 07 10 80 00       	push   $0x801007
  8002a7:	e8 6c 00 00 00       	call   800318 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 cb                	mov    %ecx,%ebx
  8002ef:	89 cf                	mov    %ecx,%edi
  8002f1:	89 ce                	mov    %ecx,%esi
  8002f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 17                	jle    800310 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	50                   	push   %eax
  8002fd:	6a 0c                	push   $0xc
  8002ff:	68 ea 0f 80 00       	push   $0x800fea
  800304:	6a 23                	push   $0x23
  800306:	68 07 10 80 00       	push   $0x801007
  80030b:	e8 08 00 00 00       	call   800318 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80031d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800320:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800326:	e8 00 fe ff ff       	call   80012b <sys_getenvid>
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	56                   	push   %esi
  800335:	50                   	push   %eax
  800336:	68 18 10 80 00       	push   $0x801018
  80033b:	e8 b1 00 00 00       	call   8003f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800340:	83 c4 18             	add    $0x18,%esp
  800343:	53                   	push   %ebx
  800344:	ff 75 10             	pushl  0x10(%ebp)
  800347:	e8 54 00 00 00       	call   8003a0 <vcprintf>
	cprintf("\n");
  80034c:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  800353:	e8 99 00 00 00       	call   8003f1 <cprintf>
  800358:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035b:	cc                   	int3   
  80035c:	eb fd                	jmp    80035b <_panic+0x43>

0080035e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	53                   	push   %ebx
  800362:	83 ec 04             	sub    $0x4,%esp
  800365:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800368:	8b 13                	mov    (%ebx),%edx
  80036a:	8d 42 01             	lea    0x1(%edx),%eax
  80036d:	89 03                	mov    %eax,(%ebx)
  80036f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800372:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800376:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037b:	75 1a                	jne    800397 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	68 ff 00 00 00       	push   $0xff
  800385:	8d 43 08             	lea    0x8(%ebx),%eax
  800388:	50                   	push   %eax
  800389:	e8 1f fd ff ff       	call   8000ad <sys_cputs>
		b->idx = 0;
  80038e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800394:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800397:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b0:	00 00 00 
	b.cnt = 0;
  8003b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003bd:	ff 75 0c             	pushl  0xc(%ebp)
  8003c0:	ff 75 08             	pushl  0x8(%ebp)
  8003c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c9:	50                   	push   %eax
  8003ca:	68 5e 03 80 00       	push   $0x80035e
  8003cf:	e8 1a 01 00 00       	call   8004ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d4:	83 c4 08             	add    $0x8,%esp
  8003d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e3:	50                   	push   %eax
  8003e4:	e8 c4 fc ff ff       	call   8000ad <sys_cputs>

	return b.cnt;
}
  8003e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fa:	50                   	push   %eax
  8003fb:	ff 75 08             	pushl  0x8(%ebp)
  8003fe:	e8 9d ff ff ff       	call   8003a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	57                   	push   %edi
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 1c             	sub    $0x1c,%esp
  80040e:	89 c7                	mov    %eax,%edi
  800410:	89 d6                	mov    %edx,%esi
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	8b 55 0c             	mov    0xc(%ebp),%edx
  800418:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800421:	bb 00 00 00 00       	mov    $0x0,%ebx
  800426:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800429:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042c:	39 d3                	cmp    %edx,%ebx
  80042e:	72 05                	jb     800435 <printnum+0x30>
  800430:	39 45 10             	cmp    %eax,0x10(%ebp)
  800433:	77 45                	ja     80047a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800435:	83 ec 0c             	sub    $0xc,%esp
  800438:	ff 75 18             	pushl  0x18(%ebp)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800441:	53                   	push   %ebx
  800442:	ff 75 10             	pushl  0x10(%ebp)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044b:	ff 75 e0             	pushl  -0x20(%ebp)
  80044e:	ff 75 dc             	pushl  -0x24(%ebp)
  800451:	ff 75 d8             	pushl  -0x28(%ebp)
  800454:	e8 e7 08 00 00       	call   800d40 <__udivdi3>
  800459:	83 c4 18             	add    $0x18,%esp
  80045c:	52                   	push   %edx
  80045d:	50                   	push   %eax
  80045e:	89 f2                	mov    %esi,%edx
  800460:	89 f8                	mov    %edi,%eax
  800462:	e8 9e ff ff ff       	call   800405 <printnum>
  800467:	83 c4 20             	add    $0x20,%esp
  80046a:	eb 18                	jmp    800484 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	56                   	push   %esi
  800470:	ff 75 18             	pushl  0x18(%ebp)
  800473:	ff d7                	call   *%edi
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	eb 03                	jmp    80047d <printnum+0x78>
  80047a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047d:	83 eb 01             	sub    $0x1,%ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f e8                	jg     80046c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	56                   	push   %esi
  800488:	83 ec 04             	sub    $0x4,%esp
  80048b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048e:	ff 75 e0             	pushl  -0x20(%ebp)
  800491:	ff 75 dc             	pushl  -0x24(%ebp)
  800494:	ff 75 d8             	pushl  -0x28(%ebp)
  800497:	e8 d4 09 00 00       	call   800e70 <__umoddi3>
  80049c:	83 c4 14             	add    $0x14,%esp
  80049f:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  8004a6:	50                   	push   %eax
  8004a7:	ff d7                	call   *%edi
}
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5f                   	pop    %edi
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c3:	73 0a                	jae    8004cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cd:	88 02                	mov    %al,(%edx)
}
  8004cf:	5d                   	pop    %ebp
  8004d0:	c3                   	ret    

008004d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004da:	50                   	push   %eax
  8004db:	ff 75 10             	pushl  0x10(%ebp)
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	ff 75 08             	pushl  0x8(%ebp)
  8004e4:	e8 05 00 00 00       	call   8004ee <vprintfmt>
	va_end(ap);
}
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 2c             	sub    $0x2c,%esp
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800500:	eb 12                	jmp    800514 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800502:	85 c0                	test   %eax,%eax
  800504:	0f 84 42 04 00 00    	je     80094c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	50                   	push   %eax
  80050f:	ff d6                	call   *%esi
  800511:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051b:	83 f8 25             	cmp    $0x25,%eax
  80051e:	75 e2                	jne    800502 <vprintfmt+0x14>
  800520:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800524:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800532:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800539:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053e:	eb 07                	jmp    800547 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800543:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8d 47 01             	lea    0x1(%edi),%eax
  80054a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054d:	0f b6 07             	movzbl (%edi),%eax
  800550:	0f b6 d0             	movzbl %al,%edx
  800553:	83 e8 23             	sub    $0x23,%eax
  800556:	3c 55                	cmp    $0x55,%al
  800558:	0f 87 d3 03 00 00    	ja     800931 <vprintfmt+0x443>
  80055e:	0f b6 c0             	movzbl %al,%eax
  800561:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80056f:	eb d6                	jmp    800547 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800583:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800586:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800589:	83 f9 09             	cmp    $0x9,%ecx
  80058c:	77 3f                	ja     8005cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800591:	eb e9                	jmp    80057c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a7:	eb 2a                	jmp    8005d3 <vprintfmt+0xe5>
  8005a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b3:	0f 49 d0             	cmovns %eax,%edx
  8005b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bc:	eb 89                	jmp    800547 <vprintfmt+0x59>
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c8:	e9 7a ff ff ff       	jmp    800547 <vprintfmt+0x59>
  8005cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d7:	0f 89 6a ff ff ff    	jns    800547 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ea:	e9 58 ff ff ff       	jmp    800547 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f5:	e9 4d ff ff ff       	jmp    800547 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 78 04             	lea    0x4(%eax),%edi
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	ff 30                	pushl  (%eax)
  800606:	ff d6                	call   *%esi
			break;
  800608:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800611:	e9 fe fe ff ff       	jmp    800514 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 78 04             	lea    0x4(%eax),%edi
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	99                   	cltd   
  80061f:	31 d0                	xor    %edx,%eax
  800621:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800623:	83 f8 09             	cmp    $0x9,%eax
  800626:	7f 0b                	jg     800633 <vprintfmt+0x145>
  800628:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  80062f:	85 d2                	test   %edx,%edx
  800631:	75 1b                	jne    80064e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800633:	50                   	push   %eax
  800634:	68 56 10 80 00       	push   $0x801056
  800639:	53                   	push   %ebx
  80063a:	56                   	push   %esi
  80063b:	e8 91 fe ff ff       	call   8004d1 <printfmt>
  800640:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800643:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800649:	e9 c6 fe ff ff       	jmp    800514 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80064e:	52                   	push   %edx
  80064f:	68 5f 10 80 00       	push   $0x80105f
  800654:	53                   	push   %ebx
  800655:	56                   	push   %esi
  800656:	e8 76 fe ff ff       	call   8004d1 <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800664:	e9 ab fe ff ff       	jmp    800514 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	83 c0 04             	add    $0x4,%eax
  80066f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800677:	85 ff                	test   %edi,%edi
  800679:	b8 4f 10 80 00       	mov    $0x80104f,%eax
  80067e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	0f 8e 94 00 00 00    	jle    80071f <vprintfmt+0x231>
  80068b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80068f:	0f 84 98 00 00 00    	je     80072d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	ff 75 d0             	pushl  -0x30(%ebp)
  80069b:	57                   	push   %edi
  80069c:	e8 33 03 00 00       	call   8009d4 <strnlen>
  8006a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a4:	29 c1                	sub    %eax,%ecx
  8006a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	eb 0f                	jmp    8006c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 ff                	test   %edi,%edi
  8006cb:	7f ed                	jg     8006ba <vprintfmt+0x1cc>
  8006cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	0f 49 c1             	cmovns %ecx,%eax
  8006dd:	29 c1                	sub    %eax,%ecx
  8006df:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e8:	89 cb                	mov    %ecx,%ebx
  8006ea:	eb 4d                	jmp    800739 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f0:	74 1b                	je     80070d <vprintfmt+0x21f>
  8006f2:	0f be c0             	movsbl %al,%eax
  8006f5:	83 e8 20             	sub    $0x20,%eax
  8006f8:	83 f8 5e             	cmp    $0x5e,%eax
  8006fb:	76 10                	jbe    80070d <vprintfmt+0x21f>
					putch('?', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	6a 3f                	push   $0x3f
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 0d                	jmp    80071a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	52                   	push   %edx
  800714:	ff 55 08             	call   *0x8(%ebp)
  800717:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	83 eb 01             	sub    $0x1,%ebx
  80071d:	eb 1a                	jmp    800739 <vprintfmt+0x24b>
  80071f:	89 75 08             	mov    %esi,0x8(%ebp)
  800722:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800725:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800728:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072b:	eb 0c                	jmp    800739 <vprintfmt+0x24b>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800739:	83 c7 01             	add    $0x1,%edi
  80073c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800740:	0f be d0             	movsbl %al,%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	74 23                	je     80076a <vprintfmt+0x27c>
  800747:	85 f6                	test   %esi,%esi
  800749:	78 a1                	js     8006ec <vprintfmt+0x1fe>
  80074b:	83 ee 01             	sub    $0x1,%esi
  80074e:	79 9c                	jns    8006ec <vprintfmt+0x1fe>
  800750:	89 df                	mov    %ebx,%edi
  800752:	8b 75 08             	mov    0x8(%ebp),%esi
  800755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800758:	eb 18                	jmp    800772 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 20                	push   $0x20
  800760:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800762:	83 ef 01             	sub    $0x1,%edi
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb 08                	jmp    800772 <vprintfmt+0x284>
  80076a:	89 df                	mov    %ebx,%edi
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800772:	85 ff                	test   %edi,%edi
  800774:	7f e4                	jg     80075a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800776:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	e9 90 fd ff ff       	jmp    800514 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800784:	83 f9 01             	cmp    $0x1,%ecx
  800787:	7e 19                	jle    8007a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 50 04             	mov    0x4(%eax),%edx
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800794:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a0:	eb 38                	jmp    8007da <vprintfmt+0x2ec>
	else if (lflag)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	74 1b                	je     8007c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 00                	mov    (%eax),%eax
  8007ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ae:	89 c1                	mov    %eax,%ecx
  8007b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 40 04             	lea    0x4(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bf:	eb 19                	jmp    8007da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8b 00                	mov    (%eax),%eax
  8007c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c9:	89 c1                	mov    %eax,%ecx
  8007cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 40 04             	lea    0x4(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e9:	0f 89 0e 01 00 00    	jns    8008fd <vprintfmt+0x40f>
				putch('-', putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 2d                	push   $0x2d
  8007f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fd:	f7 da                	neg    %edx
  8007ff:	83 d1 00             	adc    $0x0,%ecx
  800802:	f7 d9                	neg    %ecx
  800804:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080c:	e9 ec 00 00 00       	jmp    8008fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800811:	83 f9 01             	cmp    $0x1,%ecx
  800814:	7e 18                	jle    80082e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	8b 48 04             	mov    0x4(%eax),%ecx
  80081e:	8d 40 08             	lea    0x8(%eax),%eax
  800821:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800824:	b8 0a 00 00 00       	mov    $0xa,%eax
  800829:	e9 cf 00 00 00       	jmp    8008fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80082e:	85 c9                	test   %ecx,%ecx
  800830:	74 1a                	je     80084c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 10                	mov    (%eax),%edx
  800837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083c:	8d 40 04             	lea    0x4(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800842:	b8 0a 00 00 00       	mov    $0xa,%eax
  800847:	e9 b1 00 00 00       	jmp    8008fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	8d 40 04             	lea    0x4(%eax),%eax
  800859:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80085c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800861:	e9 97 00 00 00       	jmp    8008fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 58                	push   $0x58
  80086c:	ff d6                	call   *%esi
			putch('X', putdat);
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	6a 58                	push   $0x58
  800874:	ff d6                	call   *%esi
			putch('X', putdat);
  800876:	83 c4 08             	add    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 58                	push   $0x58
  80087c:	ff d6                	call   *%esi
			break;
  80087e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800884:	e9 8b fc ff ff       	jmp    800514 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	6a 30                	push   $0x30
  80088f:	ff d6                	call   *%esi
			putch('x', putdat);
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	6a 78                	push   $0x78
  800897:	ff d6                	call   *%esi
			num = (unsigned long long)
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 10                	mov    (%eax),%edx
  80089e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a6:	8d 40 04             	lea    0x4(%eax),%eax
  8008a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008b1:	eb 4a                	jmp    8008fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b3:	83 f9 01             	cmp    $0x1,%ecx
  8008b6:	7e 15                	jle    8008cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8b 10                	mov    (%eax),%edx
  8008bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c0:	8d 40 08             	lea    0x8(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008cb:	eb 30                	jmp    8008fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	74 17                	je     8008e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d4:	8b 10                	mov    (%eax),%edx
  8008d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008db:	8d 40 04             	lea    0x4(%eax),%eax
  8008de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e6:	eb 15                	jmp    8008fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8b 10                	mov    (%eax),%edx
  8008ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f2:	8d 40 04             	lea    0x4(%eax),%eax
  8008f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008fd:	83 ec 0c             	sub    $0xc,%esp
  800900:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800904:	57                   	push   %edi
  800905:	ff 75 e0             	pushl  -0x20(%ebp)
  800908:	50                   	push   %eax
  800909:	51                   	push   %ecx
  80090a:	52                   	push   %edx
  80090b:	89 da                	mov    %ebx,%edx
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	e8 f1 fa ff ff       	call   800405 <printnum>
			break;
  800914:	83 c4 20             	add    $0x20,%esp
  800917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091a:	e9 f5 fb ff ff       	jmp    800514 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	52                   	push   %edx
  800924:	ff d6                	call   *%esi
			break;
  800926:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80092c:	e9 e3 fb ff ff       	jmp    800514 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	53                   	push   %ebx
  800935:	6a 25                	push   $0x25
  800937:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	eb 03                	jmp    800941 <vprintfmt+0x453>
  80093e:	83 ef 01             	sub    $0x1,%edi
  800941:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800945:	75 f7                	jne    80093e <vprintfmt+0x450>
  800947:	e9 c8 fb ff ff       	jmp    800514 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80094c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 18             	sub    $0x18,%esp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800960:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800963:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800967:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80096a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 26                	je     80099b <vsnprintf+0x47>
  800975:	85 d2                	test   %edx,%edx
  800977:	7e 22                	jle    80099b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800979:	ff 75 14             	pushl  0x14(%ebp)
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800982:	50                   	push   %eax
  800983:	68 b4 04 80 00       	push   $0x8004b4
  800988:	e8 61 fb ff ff       	call   8004ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80098d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800990:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	eb 05                	jmp    8009a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80099b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ab:	50                   	push   %eax
  8009ac:	ff 75 10             	pushl  0x10(%ebp)
  8009af:	ff 75 0c             	pushl  0xc(%ebp)
  8009b2:	ff 75 08             	pushl  0x8(%ebp)
  8009b5:	e8 9a ff ff ff       	call   800954 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb 03                	jmp    8009cc <strlen+0x10>
		n++;
  8009c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d0:	75 f7                	jne    8009c9 <strlen+0xd>
		n++;
	return n;
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	eb 03                	jmp    8009e7 <strnlen+0x13>
		n++;
  8009e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e7:	39 c2                	cmp    %eax,%edx
  8009e9:	74 08                	je     8009f3 <strnlen+0x1f>
  8009eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ef:	75 f3                	jne    8009e4 <strnlen+0x10>
  8009f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	53                   	push   %ebx
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a0b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a0e:	84 db                	test   %bl,%bl
  800a10:	75 ef                	jne    800a01 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a1c:	53                   	push   %ebx
  800a1d:	e8 9a ff ff ff       	call   8009bc <strlen>
  800a22:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a25:	ff 75 0c             	pushl  0xc(%ebp)
  800a28:	01 d8                	add    %ebx,%eax
  800a2a:	50                   	push   %eax
  800a2b:	e8 c5 ff ff ff       	call   8009f5 <strcpy>
	return dst;
}
  800a30:	89 d8                	mov    %ebx,%eax
  800a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a47:	89 f2                	mov    %esi,%edx
  800a49:	eb 0f                	jmp    800a5a <strncpy+0x23>
		*dst++ = *src;
  800a4b:	83 c2 01             	add    $0x1,%edx
  800a4e:	0f b6 01             	movzbl (%ecx),%eax
  800a51:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a54:	80 39 01             	cmpb   $0x1,(%ecx)
  800a57:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a5a:	39 da                	cmp    %ebx,%edx
  800a5c:	75 ed                	jne    800a4b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a5e:	89 f0                	mov    %esi,%eax
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a72:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a74:	85 d2                	test   %edx,%edx
  800a76:	74 21                	je     800a99 <strlcpy+0x35>
  800a78:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	eb 09                	jmp    800a89 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a80:	83 c2 01             	add    $0x1,%edx
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a89:	39 c2                	cmp    %eax,%edx
  800a8b:	74 09                	je     800a96 <strlcpy+0x32>
  800a8d:	0f b6 19             	movzbl (%ecx),%ebx
  800a90:	84 db                	test   %bl,%bl
  800a92:	75 ec                	jne    800a80 <strlcpy+0x1c>
  800a94:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a99:	29 f0                	sub    %esi,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa8:	eb 06                	jmp    800ab0 <strcmp+0x11>
		p++, q++;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	84 c0                	test   %al,%al
  800ab5:	74 04                	je     800abb <strcmp+0x1c>
  800ab7:	3a 02                	cmp    (%edx),%al
  800ab9:	74 ef                	je     800aaa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abb:	0f b6 c0             	movzbl %al,%eax
  800abe:	0f b6 12             	movzbl (%edx),%edx
  800ac1:	29 d0                	sub    %edx,%eax
}
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad4:	eb 06                	jmp    800adc <strncmp+0x17>
		n--, p++, q++;
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800adc:	39 d8                	cmp    %ebx,%eax
  800ade:	74 15                	je     800af5 <strncmp+0x30>
  800ae0:	0f b6 08             	movzbl (%eax),%ecx
  800ae3:	84 c9                	test   %cl,%cl
  800ae5:	74 04                	je     800aeb <strncmp+0x26>
  800ae7:	3a 0a                	cmp    (%edx),%cl
  800ae9:	74 eb                	je     800ad6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aeb:	0f b6 00             	movzbl (%eax),%eax
  800aee:	0f b6 12             	movzbl (%edx),%edx
  800af1:	29 d0                	sub    %edx,%eax
  800af3:	eb 05                	jmp    800afa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b07:	eb 07                	jmp    800b10 <strchr+0x13>
		if (*s == c)
  800b09:	38 ca                	cmp    %cl,%dl
  800b0b:	74 0f                	je     800b1c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	0f b6 10             	movzbl (%eax),%edx
  800b13:	84 d2                	test   %dl,%dl
  800b15:	75 f2                	jne    800b09 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b28:	eb 03                	jmp    800b2d <strfind+0xf>
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 04                	je     800b38 <strfind+0x1a>
  800b34:	84 d2                	test   %dl,%dl
  800b36:	75 f2                	jne    800b2a <strfind+0xc>
			break;
	return (char *) s;
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b46:	85 c9                	test   %ecx,%ecx
  800b48:	74 36                	je     800b80 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b50:	75 28                	jne    800b7a <memset+0x40>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 23                	jne    800b7a <memset+0x40>
		c &= 0xFF;
  800b57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5b:	89 d3                	mov    %edx,%ebx
  800b5d:	c1 e3 08             	shl    $0x8,%ebx
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	c1 e6 18             	shl    $0x18,%esi
  800b65:	89 d0                	mov    %edx,%eax
  800b67:	c1 e0 10             	shl    $0x10,%eax
  800b6a:	09 f0                	or     %esi,%eax
  800b6c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b6e:	89 d8                	mov    %ebx,%eax
  800b70:	09 d0                	or     %edx,%eax
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	fc                   	cld    
  800b76:	f3 ab                	rep stos %eax,%es:(%edi)
  800b78:	eb 06                	jmp    800b80 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	fc                   	cld    
  800b7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b80:	89 f8                	mov    %edi,%eax
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b95:	39 c6                	cmp    %eax,%esi
  800b97:	73 35                	jae    800bce <memmove+0x47>
  800b99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9c:	39 d0                	cmp    %edx,%eax
  800b9e:	73 2e                	jae    800bce <memmove+0x47>
		s += n;
		d += n;
  800ba0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	09 fe                	or     %edi,%esi
  800ba7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bad:	75 13                	jne    800bc2 <memmove+0x3b>
  800baf:	f6 c1 03             	test   $0x3,%cl
  800bb2:	75 0e                	jne    800bc2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bb4:	83 ef 04             	sub    $0x4,%edi
  800bb7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bba:	c1 e9 02             	shr    $0x2,%ecx
  800bbd:	fd                   	std    
  800bbe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc0:	eb 09                	jmp    800bcb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc2:	83 ef 01             	sub    $0x1,%edi
  800bc5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc8:	fd                   	std    
  800bc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bcb:	fc                   	cld    
  800bcc:	eb 1d                	jmp    800beb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bce:	89 f2                	mov    %esi,%edx
  800bd0:	09 c2                	or     %eax,%edx
  800bd2:	f6 c2 03             	test   $0x3,%dl
  800bd5:	75 0f                	jne    800be6 <memmove+0x5f>
  800bd7:	f6 c1 03             	test   $0x3,%cl
  800bda:	75 0a                	jne    800be6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	fc                   	cld    
  800be2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be4:	eb 05                	jmp    800beb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	fc                   	cld    
  800be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf2:	ff 75 10             	pushl  0x10(%ebp)
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	ff 75 08             	pushl  0x8(%ebp)
  800bfb:	e8 87 ff ff ff       	call   800b87 <memmove>
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0d:	89 c6                	mov    %eax,%esi
  800c0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c12:	eb 1a                	jmp    800c2e <memcmp+0x2c>
		if (*s1 != *s2)
  800c14:	0f b6 08             	movzbl (%eax),%ecx
  800c17:	0f b6 1a             	movzbl (%edx),%ebx
  800c1a:	38 d9                	cmp    %bl,%cl
  800c1c:	74 0a                	je     800c28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c1e:	0f b6 c1             	movzbl %cl,%eax
  800c21:	0f b6 db             	movzbl %bl,%ebx
  800c24:	29 d8                	sub    %ebx,%eax
  800c26:	eb 0f                	jmp    800c37 <memcmp+0x35>
		s1++, s2++;
  800c28:	83 c0 01             	add    $0x1,%eax
  800c2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2e:	39 f0                	cmp    %esi,%eax
  800c30:	75 e2                	jne    800c14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	53                   	push   %ebx
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c42:	89 c1                	mov    %eax,%ecx
  800c44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4b:	eb 0a                	jmp    800c57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	39 da                	cmp    %ebx,%edx
  800c52:	74 07                	je     800c5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c54:	83 c0 01             	add    $0x1,%eax
  800c57:	39 c8                	cmp    %ecx,%eax
  800c59:	72 f2                	jb     800c4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	eb 03                	jmp    800c6f <strtol+0x11>
		s++;
  800c6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6f:	0f b6 01             	movzbl (%ecx),%eax
  800c72:	3c 20                	cmp    $0x20,%al
  800c74:	74 f6                	je     800c6c <strtol+0xe>
  800c76:	3c 09                	cmp    $0x9,%al
  800c78:	74 f2                	je     800c6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c7a:	3c 2b                	cmp    $0x2b,%al
  800c7c:	75 0a                	jne    800c88 <strtol+0x2a>
		s++;
  800c7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c81:	bf 00 00 00 00       	mov    $0x0,%edi
  800c86:	eb 11                	jmp    800c99 <strtol+0x3b>
  800c88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c8d:	3c 2d                	cmp    $0x2d,%al
  800c8f:	75 08                	jne    800c99 <strtol+0x3b>
		s++, neg = 1;
  800c91:	83 c1 01             	add    $0x1,%ecx
  800c94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c9f:	75 15                	jne    800cb6 <strtol+0x58>
  800ca1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca4:	75 10                	jne    800cb6 <strtol+0x58>
  800ca6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800caa:	75 7c                	jne    800d28 <strtol+0xca>
		s += 2, base = 16;
  800cac:	83 c1 02             	add    $0x2,%ecx
  800caf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cb4:	eb 16                	jmp    800ccc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cb6:	85 db                	test   %ebx,%ebx
  800cb8:	75 12                	jne    800ccc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc2:	75 08                	jne    800ccc <strtol+0x6e>
		s++, base = 8;
  800cc4:	83 c1 01             	add    $0x1,%ecx
  800cc7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd4:	0f b6 11             	movzbl (%ecx),%edx
  800cd7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cda:	89 f3                	mov    %esi,%ebx
  800cdc:	80 fb 09             	cmp    $0x9,%bl
  800cdf:	77 08                	ja     800ce9 <strtol+0x8b>
			dig = *s - '0';
  800ce1:	0f be d2             	movsbl %dl,%edx
  800ce4:	83 ea 30             	sub    $0x30,%edx
  800ce7:	eb 22                	jmp    800d0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cec:	89 f3                	mov    %esi,%ebx
  800cee:	80 fb 19             	cmp    $0x19,%bl
  800cf1:	77 08                	ja     800cfb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cf3:	0f be d2             	movsbl %dl,%edx
  800cf6:	83 ea 57             	sub    $0x57,%edx
  800cf9:	eb 10                	jmp    800d0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cfe:	89 f3                	mov    %esi,%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 16                	ja     800d1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d05:	0f be d2             	movsbl %dl,%edx
  800d08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d0e:	7d 0b                	jge    800d1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d10:	83 c1 01             	add    $0x1,%ecx
  800d13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d19:	eb b9                	jmp    800cd4 <strtol+0x76>

	if (endptr)
  800d1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1f:	74 0d                	je     800d2e <strtol+0xd0>
		*endptr = (char *) s;
  800d21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d24:	89 0e                	mov    %ecx,(%esi)
  800d26:	eb 06                	jmp    800d2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	74 98                	je     800cc4 <strtol+0x66>
  800d2c:	eb 9e                	jmp    800ccc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	f7 da                	neg    %edx
  800d32:	85 ff                	test   %edi,%edi
  800d34:	0f 45 c2             	cmovne %edx,%eax
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

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
