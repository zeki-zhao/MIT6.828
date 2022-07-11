
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 4d 00 00 00       	call   800092 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x22>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 05 00 00 00       	call   800080 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 ca 0f 80 00       	push   $0x800fca
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 e7 0f 80 00       	push   $0x800fe7
  800103:	e8 f5 01 00 00       	call   8002fd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	b8 04 00 00 00       	mov    $0x4,%eax
  800161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 04                	push   $0x4
  800178:	68 ca 0f 80 00       	push   $0x800fca
  80017d:	6a 23                	push   $0x23
  80017f:	68 e7 0f 80 00       	push   $0x800fe7
  800184:	e8 74 01 00 00       	call   8002fd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	b8 05 00 00 00       	mov    $0x5,%eax
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 05                	push   $0x5
  8001ba:	68 ca 0f 80 00       	push   $0x800fca
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 e7 0f 80 00       	push   $0x800fe7
  8001c6:	e8 32 01 00 00       	call   8002fd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 06                	push   $0x6
  8001fc:	68 ca 0f 80 00       	push   $0x800fca
  800201:	6a 23                	push   $0x23
  800203:	68 e7 0f 80 00       	push   $0x800fe7
  800208:	e8 f0 00 00 00       	call   8002fd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 08                	push   $0x8
  80023e:	68 ca 0f 80 00       	push   $0x800fca
  800243:	6a 23                	push   $0x23
  800245:	68 e7 0f 80 00       	push   $0x800fe7
  80024a:	e8 ae 00 00 00       	call   8002fd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 09                	push   $0x9
  800280:	68 ca 0f 80 00       	push   $0x800fca
  800285:	6a 23                	push   $0x23
  800287:	68 e7 0f 80 00       	push   $0x800fe7
  80028c:	e8 6c 00 00 00       	call   8002fd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	be 00 00 00 00       	mov    $0x0,%esi
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0c                	push   $0xc
  8002e4:	68 ca 0f 80 00       	push   $0x800fca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 0f 80 00       	push   $0x800fe7
  8002f0:	e8 08 00 00 00       	call   8002fd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 f8 0f 80 00       	push   $0x800ff8
  800320:	e8 b1 00 00 00       	call   8003d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	e8 54 00 00 00       	call   800385 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800338:	e8 99 00 00 00       	call   8003d6 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	75 1a                	jne    80037c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	68 ff 00 00 00       	push   $0xff
  80036a:	8d 43 08             	lea    0x8(%ebx),%eax
  80036d:	50                   	push   %eax
  80036e:	e8 1f fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800373:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800379:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800395:	00 00 00 
	b.cnt = 0;
  800398:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	68 43 03 80 00       	push   $0x800343
  8003b4:	e8 1a 01 00 00       	call   8004d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b9:	83 c4 08             	add    $0x8,%esp
  8003bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c4 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003df:	50                   	push   %eax
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 9d ff ff ff       	call   800385 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 1c             	sub    $0x1c,%esp
  8003f3:	89 c7                	mov    %eax,%edi
  8003f5:	89 d6                	mov    %edx,%esi
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800400:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800411:	39 d3                	cmp    %edx,%ebx
  800413:	72 05                	jb     80041a <printnum+0x30>
  800415:	39 45 10             	cmp    %eax,0x10(%ebp)
  800418:	77 45                	ja     80045f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041a:	83 ec 0c             	sub    $0xc,%esp
  80041d:	ff 75 18             	pushl  0x18(%ebp)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800426:	53                   	push   %ebx
  800427:	ff 75 10             	pushl  0x10(%ebp)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	ff 75 dc             	pushl  -0x24(%ebp)
  800436:	ff 75 d8             	pushl  -0x28(%ebp)
  800439:	e8 f2 08 00 00       	call   800d30 <__udivdi3>
  80043e:	83 c4 18             	add    $0x18,%esp
  800441:	52                   	push   %edx
  800442:	50                   	push   %eax
  800443:	89 f2                	mov    %esi,%edx
  800445:	89 f8                	mov    %edi,%eax
  800447:	e8 9e ff ff ff       	call   8003ea <printnum>
  80044c:	83 c4 20             	add    $0x20,%esp
  80044f:	eb 18                	jmp    800469 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	ff 75 18             	pushl  0x18(%ebp)
  800458:	ff d7                	call   *%edi
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	eb 03                	jmp    800462 <printnum+0x78>
  80045f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f e8                	jg     800451 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 df 09 00 00       	call   800e60 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff d7                	call   *%edi
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80049f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a3:	8b 10                	mov    (%eax),%edx
  8004a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a8:	73 0a                	jae    8004b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b2:	88 02                	mov    %al,(%edx)
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bf:	50                   	push   %eax
  8004c0:	ff 75 10             	pushl  0x10(%ebp)
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	ff 75 08             	pushl  0x8(%ebp)
  8004c9:	e8 05 00 00 00       	call   8004d3 <vprintfmt>
	va_end(ap);
}
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	57                   	push   %edi
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
  8004d9:	83 ec 2c             	sub    $0x2c,%esp
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e5:	eb 12                	jmp    8004f9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	0f 84 42 04 00 00    	je     800931 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	50                   	push   %eax
  8004f4:	ff d6                	call   *%esi
  8004f6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	83 f8 25             	cmp    $0x25,%eax
  800503:	75 e2                	jne    8004e7 <vprintfmt+0x14>
  800505:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800509:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800510:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800517:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800523:	eb 07                	jmp    80052c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800528:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8d 47 01             	lea    0x1(%edi),%eax
  80052f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800532:	0f b6 07             	movzbl (%edi),%eax
  800535:	0f b6 d0             	movzbl %al,%edx
  800538:	83 e8 23             	sub    $0x23,%eax
  80053b:	3c 55                	cmp    $0x55,%al
  80053d:	0f 87 d3 03 00 00    	ja     800916 <vprintfmt+0x443>
  800543:	0f b6 c0             	movzbl %al,%eax
  800546:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800554:	eb d6                	jmp    80052c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800559:	b8 00 00 00 00       	mov    $0x0,%eax
  80055e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800561:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800564:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800568:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056e:	83 f9 09             	cmp    $0x9,%ecx
  800571:	77 3f                	ja     8005b2 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800573:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800576:	eb e9                	jmp    800561 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 04             	lea    0x4(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058c:	eb 2a                	jmp    8005b8 <vprintfmt+0xe5>
  80058e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	ba 00 00 00 00       	mov    $0x0,%edx
  800598:	0f 49 d0             	cmovns %eax,%edx
  80059b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	eb 89                	jmp    80052c <vprintfmt+0x59>
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ad:	e9 7a ff ff ff       	jmp    80052c <vprintfmt+0x59>
  8005b2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bc:	0f 89 6a ff ff ff    	jns    80052c <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cf:	e9 58 ff ff ff       	jmp    80052c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005da:	e9 4d ff ff ff       	jmp    80052c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 78 04             	lea    0x4(%eax),%edi
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	ff 30                	pushl  (%eax)
  8005eb:	ff d6                	call   *%esi
			break;
  8005ed:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f6:	e9 fe fe ff ff       	jmp    8004f9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 78 04             	lea    0x4(%eax),%edi
  800601:	8b 00                	mov    (%eax),%eax
  800603:	99                   	cltd   
  800604:	31 d0                	xor    %edx,%eax
  800606:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800608:	83 f8 09             	cmp    $0x9,%eax
  80060b:	7f 0b                	jg     800618 <vprintfmt+0x145>
  80060d:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800614:	85 d2                	test   %edx,%edx
  800616:	75 1b                	jne    800633 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800618:	50                   	push   %eax
  800619:	68 36 10 80 00       	push   $0x801036
  80061e:	53                   	push   %ebx
  80061f:	56                   	push   %esi
  800620:	e8 91 fe ff ff       	call   8004b6 <printfmt>
  800625:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800628:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062e:	e9 c6 fe ff ff       	jmp    8004f9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800633:	52                   	push   %edx
  800634:	68 3f 10 80 00       	push   $0x80103f
  800639:	53                   	push   %ebx
  80063a:	56                   	push   %esi
  80063b:	e8 76 fe ff ff       	call   8004b6 <printfmt>
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
  800649:	e9 ab fe ff ff       	jmp    8004f9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	83 c0 04             	add    $0x4,%eax
  800654:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80065c:	85 ff                	test   %edi,%edi
  80065e:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  800663:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800666:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066a:	0f 8e 94 00 00 00    	jle    800704 <vprintfmt+0x231>
  800670:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800674:	0f 84 98 00 00 00    	je     800712 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	ff 75 d0             	pushl  -0x30(%ebp)
  800680:	57                   	push   %edi
  800681:	e8 33 03 00 00       	call   8009b9 <strnlen>
  800686:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800689:	29 c1                	sub    %eax,%ecx
  80068b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80068e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800691:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800695:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800698:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	eb 0f                	jmp    8006ae <vprintfmt+0x1db>
					putch(padc, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	85 ff                	test   %edi,%edi
  8006b0:	7f ed                	jg     80069f <vprintfmt+0x1cc>
  8006b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	0f 49 c1             	cmovns %ecx,%eax
  8006c2:	29 c1                	sub    %eax,%ecx
  8006c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cd:	89 cb                	mov    %ecx,%ebx
  8006cf:	eb 4d                	jmp    80071e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d5:	74 1b                	je     8006f2 <vprintfmt+0x21f>
  8006d7:	0f be c0             	movsbl %al,%eax
  8006da:	83 e8 20             	sub    $0x20,%eax
  8006dd:	83 f8 5e             	cmp    $0x5e,%eax
  8006e0:	76 10                	jbe    8006f2 <vprintfmt+0x21f>
					putch('?', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	6a 3f                	push   $0x3f
  8006ea:	ff 55 08             	call   *0x8(%ebp)
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 0d                	jmp    8006ff <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	52                   	push   %edx
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ff:	83 eb 01             	sub    $0x1,%ebx
  800702:	eb 1a                	jmp    80071e <vprintfmt+0x24b>
  800704:	89 75 08             	mov    %esi,0x8(%ebp)
  800707:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800710:	eb 0c                	jmp    80071e <vprintfmt+0x24b>
  800712:	89 75 08             	mov    %esi,0x8(%ebp)
  800715:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800718:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071e:	83 c7 01             	add    $0x1,%edi
  800721:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800725:	0f be d0             	movsbl %al,%edx
  800728:	85 d2                	test   %edx,%edx
  80072a:	74 23                	je     80074f <vprintfmt+0x27c>
  80072c:	85 f6                	test   %esi,%esi
  80072e:	78 a1                	js     8006d1 <vprintfmt+0x1fe>
  800730:	83 ee 01             	sub    $0x1,%esi
  800733:	79 9c                	jns    8006d1 <vprintfmt+0x1fe>
  800735:	89 df                	mov    %ebx,%edi
  800737:	8b 75 08             	mov    0x8(%ebp),%esi
  80073a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073d:	eb 18                	jmp    800757 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 20                	push   $0x20
  800745:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800747:	83 ef 01             	sub    $0x1,%edi
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 08                	jmp    800757 <vprintfmt+0x284>
  80074f:	89 df                	mov    %ebx,%edi
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800757:	85 ff                	test   %edi,%edi
  800759:	7f e4                	jg     80073f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800764:	e9 90 fd ff ff       	jmp    8004f9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800769:	83 f9 01             	cmp    $0x1,%ecx
  80076c:	7e 19                	jle    800787 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8b 50 04             	mov    0x4(%eax),%edx
  800774:	8b 00                	mov    (%eax),%eax
  800776:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800779:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 40 08             	lea    0x8(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
  800785:	eb 38                	jmp    8007bf <vprintfmt+0x2ec>
	else if (lflag)
  800787:	85 c9                	test   %ecx,%ecx
  800789:	74 1b                	je     8007a6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800793:	89 c1                	mov    %eax,%ecx
  800795:	c1 f9 1f             	sar    $0x1f,%ecx
  800798:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 40 04             	lea    0x4(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a4:	eb 19                	jmp    8007bf <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 00                	mov    (%eax),%eax
  8007ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ae:	89 c1                	mov    %eax,%ecx
  8007b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 40 04             	lea    0x4(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ce:	0f 89 0e 01 00 00    	jns    8008e2 <vprintfmt+0x40f>
				putch('-', putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	6a 2d                	push   $0x2d
  8007da:	ff d6                	call   *%esi
				num = -(long long) num;
  8007dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007e2:	f7 da                	neg    %edx
  8007e4:	83 d1 00             	adc    $0x0,%ecx
  8007e7:	f7 d9                	neg    %ecx
  8007e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f1:	e9 ec 00 00 00       	jmp    8008e2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f6:	83 f9 01             	cmp    $0x1,%ecx
  8007f9:	7e 18                	jle    800813 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	8b 48 04             	mov    0x4(%eax),%ecx
  800803:	8d 40 08             	lea    0x8(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800809:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080e:	e9 cf 00 00 00       	jmp    8008e2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800813:	85 c9                	test   %ecx,%ecx
  800815:	74 1a                	je     800831 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8b 10                	mov    (%eax),%edx
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800821:	8d 40 04             	lea    0x4(%eax),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800827:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082c:	e9 b1 00 00 00       	jmp    8008e2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 10                	mov    (%eax),%edx
  800836:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083b:	8d 40 04             	lea    0x4(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
  800846:	e9 97 00 00 00       	jmp    8008e2 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 58                	push   $0x58
  800851:	ff d6                	call   *%esi
			putch('X', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 58                	push   $0x58
  800859:	ff d6                	call   *%esi
			putch('X', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 58                	push   $0x58
  800861:	ff d6                	call   *%esi
			break;
  800863:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800869:	e9 8b fc ff ff       	jmp    8004f9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	6a 30                	push   $0x30
  800874:	ff d6                	call   *%esi
			putch('x', putdat);
  800876:	83 c4 08             	add    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 78                	push   $0x78
  80087c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8b 10                	mov    (%eax),%edx
  800883:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800888:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088b:	8d 40 04             	lea    0x4(%eax),%eax
  80088e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800891:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800896:	eb 4a                	jmp    8008e2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800898:	83 f9 01             	cmp    $0x1,%ecx
  80089b:	7e 15                	jle    8008b2 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a5:	8d 40 08             	lea    0x8(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b0:	eb 30                	jmp    8008e2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	74 17                	je     8008cd <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008cb:	eb 15                	jmp    8008e2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d7:	8d 40 04             	lea    0x4(%eax),%eax
  8008da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008dd:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e2:	83 ec 0c             	sub    $0xc,%esp
  8008e5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008e9:	57                   	push   %edi
  8008ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ed:	50                   	push   %eax
  8008ee:	51                   	push   %ecx
  8008ef:	52                   	push   %edx
  8008f0:	89 da                	mov    %ebx,%edx
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	e8 f1 fa ff ff       	call   8003ea <printnum>
			break;
  8008f9:	83 c4 20             	add    $0x20,%esp
  8008fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ff:	e9 f5 fb ff ff       	jmp    8004f9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	53                   	push   %ebx
  800908:	52                   	push   %edx
  800909:	ff d6                	call   *%esi
			break;
  80090b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800911:	e9 e3 fb ff ff       	jmp    8004f9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	53                   	push   %ebx
  80091a:	6a 25                	push   $0x25
  80091c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	eb 03                	jmp    800926 <vprintfmt+0x453>
  800923:	83 ef 01             	sub    $0x1,%edi
  800926:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80092a:	75 f7                	jne    800923 <vprintfmt+0x450>
  80092c:	e9 c8 fb ff ff       	jmp    8004f9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800931:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	83 ec 18             	sub    $0x18,%esp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800945:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800948:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800956:	85 c0                	test   %eax,%eax
  800958:	74 26                	je     800980 <vsnprintf+0x47>
  80095a:	85 d2                	test   %edx,%edx
  80095c:	7e 22                	jle    800980 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095e:	ff 75 14             	pushl  0x14(%ebp)
  800961:	ff 75 10             	pushl  0x10(%ebp)
  800964:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800967:	50                   	push   %eax
  800968:	68 99 04 80 00       	push   $0x800499
  80096d:	e8 61 fb ff ff       	call   8004d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800972:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800975:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	eb 05                	jmp    800985 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800980:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800990:	50                   	push   %eax
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	ff 75 0c             	pushl  0xc(%ebp)
  800997:	ff 75 08             	pushl  0x8(%ebp)
  80099a:	e8 9a ff ff ff       	call   800939 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ac:	eb 03                	jmp    8009b1 <strlen+0x10>
		n++;
  8009ae:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b5:	75 f7                	jne    8009ae <strlen+0xd>
		n++;
	return n;
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c7:	eb 03                	jmp    8009cc <strnlen+0x13>
		n++;
  8009c9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cc:	39 c2                	cmp    %eax,%edx
  8009ce:	74 08                	je     8009d8 <strnlen+0x1f>
  8009d0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009d4:	75 f3                	jne    8009c9 <strnlen+0x10>
  8009d6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f3:	84 db                	test   %bl,%bl
  8009f5:	75 ef                	jne    8009e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a01:	53                   	push   %ebx
  800a02:	e8 9a ff ff ff       	call   8009a1 <strlen>
  800a07:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	01 d8                	add    %ebx,%eax
  800a0f:	50                   	push   %eax
  800a10:	e8 c5 ff ff ff       	call   8009da <strcpy>
	return dst;
}
  800a15:	89 d8                	mov    %ebx,%eax
  800a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 75 08             	mov    0x8(%ebp),%esi
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a27:	89 f3                	mov    %esi,%ebx
  800a29:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2c:	89 f2                	mov    %esi,%edx
  800a2e:	eb 0f                	jmp    800a3f <strncpy+0x23>
		*dst++ = *src;
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	0f b6 01             	movzbl (%ecx),%eax
  800a36:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a39:	80 39 01             	cmpb   $0x1,(%ecx)
  800a3c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 ed                	jne    800a30 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a43:	89 f0                	mov    %esi,%eax
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a54:	8b 55 10             	mov    0x10(%ebp),%edx
  800a57:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a59:	85 d2                	test   %edx,%edx
  800a5b:	74 21                	je     800a7e <strlcpy+0x35>
  800a5d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a61:	89 f2                	mov    %esi,%edx
  800a63:	eb 09                	jmp    800a6e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a6e:	39 c2                	cmp    %eax,%edx
  800a70:	74 09                	je     800a7b <strlcpy+0x32>
  800a72:	0f b6 19             	movzbl (%ecx),%ebx
  800a75:	84 db                	test   %bl,%bl
  800a77:	75 ec                	jne    800a65 <strlcpy+0x1c>
  800a79:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7e:	29 f0                	sub    %esi,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8d:	eb 06                	jmp    800a95 <strcmp+0x11>
		p++, q++;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a95:	0f b6 01             	movzbl (%ecx),%eax
  800a98:	84 c0                	test   %al,%al
  800a9a:	74 04                	je     800aa0 <strcmp+0x1c>
  800a9c:	3a 02                	cmp    (%edx),%al
  800a9e:	74 ef                	je     800a8f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa0:	0f b6 c0             	movzbl %al,%eax
  800aa3:	0f b6 12             	movzbl (%edx),%edx
  800aa6:	29 d0                	sub    %edx,%eax
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab9:	eb 06                	jmp    800ac1 <strncmp+0x17>
		n--, p++, q++;
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac1:	39 d8                	cmp    %ebx,%eax
  800ac3:	74 15                	je     800ada <strncmp+0x30>
  800ac5:	0f b6 08             	movzbl (%eax),%ecx
  800ac8:	84 c9                	test   %cl,%cl
  800aca:	74 04                	je     800ad0 <strncmp+0x26>
  800acc:	3a 0a                	cmp    (%edx),%cl
  800ace:	74 eb                	je     800abb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad0:	0f b6 00             	movzbl (%eax),%eax
  800ad3:	0f b6 12             	movzbl (%edx),%edx
  800ad6:	29 d0                	sub    %edx,%eax
  800ad8:	eb 05                	jmp    800adf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aec:	eb 07                	jmp    800af5 <strchr+0x13>
		if (*s == c)
  800aee:	38 ca                	cmp    %cl,%dl
  800af0:	74 0f                	je     800b01 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	0f b6 10             	movzbl (%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 f2                	jne    800aee <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0d:	eb 03                	jmp    800b12 <strfind+0xf>
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b15:	38 ca                	cmp    %cl,%dl
  800b17:	74 04                	je     800b1d <strfind+0x1a>
  800b19:	84 d2                	test   %dl,%dl
  800b1b:	75 f2                	jne    800b0f <strfind+0xc>
			break;
	return (char *) s;
}
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	74 36                	je     800b65 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b35:	75 28                	jne    800b5f <memset+0x40>
  800b37:	f6 c1 03             	test   $0x3,%cl
  800b3a:	75 23                	jne    800b5f <memset+0x40>
		c &= 0xFF;
  800b3c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	c1 e3 08             	shl    $0x8,%ebx
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	c1 e6 18             	shl    $0x18,%esi
  800b4a:	89 d0                	mov    %edx,%eax
  800b4c:	c1 e0 10             	shl    $0x10,%eax
  800b4f:	09 f0                	or     %esi,%eax
  800b51:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b53:	89 d8                	mov    %ebx,%eax
  800b55:	09 d0                	or     %edx,%eax
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	fc                   	cld    
  800b5b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5d:	eb 06                	jmp    800b65 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	fc                   	cld    
  800b63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b65:	89 f8                	mov    %edi,%eax
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7a:	39 c6                	cmp    %eax,%esi
  800b7c:	73 35                	jae    800bb3 <memmove+0x47>
  800b7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b81:	39 d0                	cmp    %edx,%eax
  800b83:	73 2e                	jae    800bb3 <memmove+0x47>
		s += n;
		d += n;
  800b85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	09 fe                	or     %edi,%esi
  800b8c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b92:	75 13                	jne    800ba7 <memmove+0x3b>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 0e                	jne    800ba7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b99:	83 ef 04             	sub    $0x4,%edi
  800b9c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
  800ba2:	fd                   	std    
  800ba3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba5:	eb 09                	jmp    800bb0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba7:	83 ef 01             	sub    $0x1,%edi
  800baa:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bad:	fd                   	std    
  800bae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb0:	fc                   	cld    
  800bb1:	eb 1d                	jmp    800bd0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb3:	89 f2                	mov    %esi,%edx
  800bb5:	09 c2                	or     %eax,%edx
  800bb7:	f6 c2 03             	test   $0x3,%dl
  800bba:	75 0f                	jne    800bcb <memmove+0x5f>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 0a                	jne    800bcb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc1:	c1 e9 02             	shr    $0x2,%ecx
  800bc4:	89 c7                	mov    %eax,%edi
  800bc6:	fc                   	cld    
  800bc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc9:	eb 05                	jmp    800bd0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	fc                   	cld    
  800bce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd7:	ff 75 10             	pushl  0x10(%ebp)
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	ff 75 08             	pushl  0x8(%ebp)
  800be0:	e8 87 ff ff ff       	call   800b6c <memmove>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf2:	89 c6                	mov    %eax,%esi
  800bf4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	eb 1a                	jmp    800c13 <memcmp+0x2c>
		if (*s1 != *s2)
  800bf9:	0f b6 08             	movzbl (%eax),%ecx
  800bfc:	0f b6 1a             	movzbl (%edx),%ebx
  800bff:	38 d9                	cmp    %bl,%cl
  800c01:	74 0a                	je     800c0d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c03:	0f b6 c1             	movzbl %cl,%eax
  800c06:	0f b6 db             	movzbl %bl,%ebx
  800c09:	29 d8                	sub    %ebx,%eax
  800c0b:	eb 0f                	jmp    800c1c <memcmp+0x35>
		s1++, s2++;
  800c0d:	83 c0 01             	add    $0x1,%eax
  800c10:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c13:	39 f0                	cmp    %esi,%eax
  800c15:	75 e2                	jne    800bf9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c27:	89 c1                	mov    %eax,%ecx
  800c29:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c30:	eb 0a                	jmp    800c3c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c32:	0f b6 10             	movzbl (%eax),%edx
  800c35:	39 da                	cmp    %ebx,%edx
  800c37:	74 07                	je     800c40 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c39:	83 c0 01             	add    $0x1,%eax
  800c3c:	39 c8                	cmp    %ecx,%eax
  800c3e:	72 f2                	jb     800c32 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c40:	5b                   	pop    %ebx
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4f:	eb 03                	jmp    800c54 <strtol+0x11>
		s++;
  800c51:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c54:	0f b6 01             	movzbl (%ecx),%eax
  800c57:	3c 20                	cmp    $0x20,%al
  800c59:	74 f6                	je     800c51 <strtol+0xe>
  800c5b:	3c 09                	cmp    $0x9,%al
  800c5d:	74 f2                	je     800c51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5f:	3c 2b                	cmp    $0x2b,%al
  800c61:	75 0a                	jne    800c6d <strtol+0x2a>
		s++;
  800c63:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c66:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6b:	eb 11                	jmp    800c7e <strtol+0x3b>
  800c6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c72:	3c 2d                	cmp    $0x2d,%al
  800c74:	75 08                	jne    800c7e <strtol+0x3b>
		s++, neg = 1;
  800c76:	83 c1 01             	add    $0x1,%ecx
  800c79:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c84:	75 15                	jne    800c9b <strtol+0x58>
  800c86:	80 39 30             	cmpb   $0x30,(%ecx)
  800c89:	75 10                	jne    800c9b <strtol+0x58>
  800c8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8f:	75 7c                	jne    800d0d <strtol+0xca>
		s += 2, base = 16;
  800c91:	83 c1 02             	add    $0x2,%ecx
  800c94:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c99:	eb 16                	jmp    800cb1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c9b:	85 db                	test   %ebx,%ebx
  800c9d:	75 12                	jne    800cb1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c9f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca7:	75 08                	jne    800cb1 <strtol+0x6e>
		s++, base = 8;
  800ca9:	83 c1 01             	add    $0x1,%ecx
  800cac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb9:	0f b6 11             	movzbl (%ecx),%edx
  800cbc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cbf:	89 f3                	mov    %esi,%ebx
  800cc1:	80 fb 09             	cmp    $0x9,%bl
  800cc4:	77 08                	ja     800cce <strtol+0x8b>
			dig = *s - '0';
  800cc6:	0f be d2             	movsbl %dl,%edx
  800cc9:	83 ea 30             	sub    $0x30,%edx
  800ccc:	eb 22                	jmp    800cf0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cce:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 08                	ja     800ce0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cd8:	0f be d2             	movsbl %dl,%edx
  800cdb:	83 ea 57             	sub    $0x57,%edx
  800cde:	eb 10                	jmp    800cf0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce3:	89 f3                	mov    %esi,%ebx
  800ce5:	80 fb 19             	cmp    $0x19,%bl
  800ce8:	77 16                	ja     800d00 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cea:	0f be d2             	movsbl %dl,%edx
  800ced:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf3:	7d 0b                	jge    800d00 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cfc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cfe:	eb b9                	jmp    800cb9 <strtol+0x76>

	if (endptr)
  800d00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d04:	74 0d                	je     800d13 <strtol+0xd0>
		*endptr = (char *) s;
  800d06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d09:	89 0e                	mov    %ecx,(%esi)
  800d0b:	eb 06                	jmp    800d13 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0d:	85 db                	test   %ebx,%ebx
  800d0f:	74 98                	je     800ca9 <strtol+0x66>
  800d11:	eb 9e                	jmp    800cb1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	f7 da                	neg    %edx
  800d17:	85 ff                	test   %edi,%edi
  800d19:	0f 45 c2             	cmovne %edx,%eax
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
  800d21:	66 90                	xchg   %ax,%ax
  800d23:	66 90                	xchg   %ax,%ax
  800d25:	66 90                	xchg   %ax,%ax
  800d27:	66 90                	xchg   %ax,%ax
  800d29:	66 90                	xchg   %ax,%ax
  800d2b:	66 90                	xchg   %ax,%ax
  800d2d:	66 90                	xchg   %ax,%ax
  800d2f:	90                   	nop

00800d30 <__udivdi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 f6                	test   %esi,%esi
  800d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d4d:	89 ca                	mov    %ecx,%edx
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	75 3d                	jne    800d90 <__udivdi3+0x60>
  800d53:	39 cf                	cmp    %ecx,%edi
  800d55:	0f 87 c5 00 00 00    	ja     800e20 <__udivdi3+0xf0>
  800d5b:	85 ff                	test   %edi,%edi
  800d5d:	89 fd                	mov    %edi,%ebp
  800d5f:	75 0b                	jne    800d6c <__udivdi3+0x3c>
  800d61:	b8 01 00 00 00       	mov    $0x1,%eax
  800d66:	31 d2                	xor    %edx,%edx
  800d68:	f7 f7                	div    %edi
  800d6a:	89 c5                	mov    %eax,%ebp
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f5                	div    %ebp
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	89 d8                	mov    %ebx,%eax
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	f7 f5                	div    %ebp
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	89 fa                	mov    %edi,%edx
  800d80:	83 c4 1c             	add    $0x1c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
  800d88:	90                   	nop
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 ce                	cmp    %ecx,%esi
  800d92:	77 74                	ja     800e08 <__udivdi3+0xd8>
  800d94:	0f bd fe             	bsr    %esi,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0x108>
  800da0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	89 c5                	mov    %eax,%ebp
  800da9:	29 fb                	sub    %edi,%ebx
  800dab:	d3 e6                	shl    %cl,%esi
  800dad:	89 d9                	mov    %ebx,%ecx
  800daf:	d3 ed                	shr    %cl,%ebp
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e0                	shl    %cl,%eax
  800db5:	09 ee                	or     %ebp,%esi
  800db7:	89 d9                	mov    %ebx,%ecx
  800db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbd:	89 d5                	mov    %edx,%ebp
  800dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc3:	d3 ed                	shr    %cl,%ebp
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e2                	shl    %cl,%edx
  800dc9:	89 d9                	mov    %ebx,%ecx
  800dcb:	d3 e8                	shr    %cl,%eax
  800dcd:	09 c2                	or     %eax,%edx
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	89 ea                	mov    %ebp,%edx
  800dd3:	f7 f6                	div    %esi
  800dd5:	89 d5                	mov    %edx,%ebp
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	72 10                	jb     800df1 <__udivdi3+0xc1>
  800de1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	d3 e6                	shl    %cl,%esi
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 07                	jae    800df4 <__udivdi3+0xc4>
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	75 03                	jne    800df4 <__udivdi3+0xc4>
  800df1:	83 eb 01             	sub    $0x1,%ebx
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 1c             	add    $0x1c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 db                	xor    %ebx,%ebx
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
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	f7 f7                	div    %edi
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	89 d8                	mov    %ebx,%eax
  800e2a:	89 fa                	mov    %edi,%edx
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	39 ce                	cmp    %ecx,%esi
  800e3a:	72 0c                	jb     800e48 <__udivdi3+0x118>
  800e3c:	31 db                	xor    %ebx,%ebx
  800e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e42:	0f 87 34 ff ff ff    	ja     800d7c <__udivdi3+0x4c>
  800e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e4d:	e9 2a ff ff ff       	jmp    800d7c <__udivdi3+0x4c>
  800e52:	66 90                	xchg   %ax,%ax
  800e54:	66 90                	xchg   %ax,%ax
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 d2                	test   %edx,%edx
  800e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	89 3c 24             	mov    %edi,(%esp)
  800e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8a:	75 1c                	jne    800ea8 <__umoddi3+0x48>
  800e8c:	39 f7                	cmp    %esi,%edi
  800e8e:	76 50                	jbe    800ee0 <__umoddi3+0x80>
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	f7 f7                	div    %edi
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	77 52                	ja     800f00 <__umoddi3+0xa0>
  800eae:	0f bd ea             	bsr    %edx,%ebp
  800eb1:	83 f5 1f             	xor    $0x1f,%ebp
  800eb4:	75 5a                	jne    800f10 <__umoddi3+0xb0>
  800eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eba:	0f 82 e0 00 00 00    	jb     800fa0 <__umoddi3+0x140>
  800ec0:	39 0c 24             	cmp    %ecx,(%esp)
  800ec3:	0f 86 d7 00 00 00    	jbe    800fa0 <__umoddi3+0x140>
  800ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	85 ff                	test   %edi,%edi
  800ee2:	89 fd                	mov    %edi,%ebp
  800ee4:	75 0b                	jne    800ef1 <__umoddi3+0x91>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f7                	div    %edi
  800eef:	89 c5                	mov    %eax,%ebp
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f5                	div    %ebp
  800ef7:	89 c8                	mov    %ecx,%eax
  800ef9:	f7 f5                	div    %ebp
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	eb 99                	jmp    800e98 <__umoddi3+0x38>
  800eff:	90                   	nop
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	83 c4 1c             	add    $0x1c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    
  800f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f10:	8b 34 24             	mov    (%esp),%esi
  800f13:	bf 20 00 00 00       	mov    $0x20,%edi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	29 ef                	sub    %ebp,%edi
  800f1c:	d3 e0                	shl    %cl,%eax
  800f1e:	89 f9                	mov    %edi,%ecx
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	d3 ea                	shr    %cl,%edx
  800f24:	89 e9                	mov    %ebp,%ecx
  800f26:	09 c2                	or     %eax,%edx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 14 24             	mov    %edx,(%esp)
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	d3 e2                	shl    %cl,%edx
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	d3 e3                	shl    %cl,%ebx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	09 d8                	or     %ebx,%eax
  800f4d:	89 d3                	mov    %edx,%ebx
  800f4f:	89 f2                	mov    %esi,%edx
  800f51:	f7 34 24             	divl   (%esp)
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	d3 e3                	shl    %cl,%ebx
  800f58:	f7 64 24 04          	mull   0x4(%esp)
  800f5c:	39 d6                	cmp    %edx,%esi
  800f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	72 08                	jb     800f70 <__umoddi3+0x110>
  800f68:	75 11                	jne    800f7b <__umoddi3+0x11b>
  800f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f6e:	73 0b                	jae    800f7b <__umoddi3+0x11b>
  800f70:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f74:	1b 14 24             	sbb    (%esp),%edx
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f7f:	29 da                	sub    %ebx,%edx
  800f81:	19 ce                	sbb    %ecx,%esi
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	d3 e0                	shl    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	d3 ea                	shr    %cl,%edx
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	d3 ee                	shr    %cl,%esi
  800f91:	09 d0                	or     %edx,%eax
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	83 c4 1c             	add    $0x1c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	29 f9                	sub    %edi,%ecx
  800fa2:	19 d6                	sbb    %edx,%esi
  800fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fac:	e9 18 ff ff ff       	jmp    800ec9 <__umoddi3+0x69>
