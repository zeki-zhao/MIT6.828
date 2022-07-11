
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 4d 00 00 00       	call   80008f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	83 ec 08             	sub    $0x8,%esp
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005a:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x22>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 05 00 00 00       	call   80007d <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800083:	6a 00                	push   $0x0
  800085:	e8 42 00 00 00       	call   8000cc <sys_env_destroy>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	57                   	push   %edi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800095:	b8 00 00 00 00       	mov    $0x0,%eax
  80009a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	89 c3                	mov    %eax,%ebx
  8000a2:	89 c7                	mov    %eax,%edi
  8000a4:	89 c6                	mov    %eax,%esi
  8000a6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5f                   	pop    %edi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <sys_cgetc>:

int
sys_cgetc(void)
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
  8000b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bd:	89 d1                	mov    %edx,%ecx
  8000bf:	89 d3                	mov    %edx,%ebx
  8000c1:	89 d7                	mov    %edx,%edi
  8000c3:	89 d6                	mov    %edx,%esi
  8000c5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
  8000d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000da:	b8 03 00 00 00       	mov    $0x3,%eax
  8000df:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e2:	89 cb                	mov    %ecx,%ebx
  8000e4:	89 cf                	mov    %ecx,%edi
  8000e6:	89 ce                	mov    %ecx,%esi
  8000e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	7e 17                	jle    800105 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	50                   	push   %eax
  8000f2:	6a 03                	push   $0x3
  8000f4:	68 ca 0f 80 00       	push   $0x800fca
  8000f9:	6a 23                	push   $0x23
  8000fb:	68 e7 0f 80 00       	push   $0x800fe7
  800100:	e8 f5 01 00 00       	call   8002fa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 02 00 00 00       	mov    $0x2,%eax
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	89 d3                	mov    %edx,%ebx
  800121:	89 d7                	mov    %edx,%edi
  800123:	89 d6                	mov    %edx,%esi
  800125:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_yield>:

void
sys_yield(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800154:	be 00 00 00 00       	mov    $0x0,%esi
  800159:	b8 04 00 00 00       	mov    $0x4,%eax
  80015e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800161:	8b 55 08             	mov    0x8(%ebp),%edx
  800164:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800167:	89 f7                	mov    %esi,%edi
  800169:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016b:	85 c0                	test   %eax,%eax
  80016d:	7e 17                	jle    800186 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	50                   	push   %eax
  800173:	6a 04                	push   $0x4
  800175:	68 ca 0f 80 00       	push   $0x800fca
  80017a:	6a 23                	push   $0x23
  80017c:	68 e7 0f 80 00       	push   $0x800fe7
  800181:	e8 74 01 00 00       	call   8002fa <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800197:	b8 05 00 00 00       	mov    $0x5,%eax
  80019c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019f:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 17                	jle    8001c8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	50                   	push   %eax
  8001b5:	6a 05                	push   $0x5
  8001b7:	68 ca 0f 80 00       	push   $0x800fca
  8001bc:	6a 23                	push   $0x23
  8001be:	68 e7 0f 80 00       	push   $0x800fe7
  8001c3:	e8 32 01 00 00       	call   8002fa <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e9:	89 df                	mov    %ebx,%edi
  8001eb:	89 de                	mov    %ebx,%esi
  8001ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ef:	85 c0                	test   %eax,%eax
  8001f1:	7e 17                	jle    80020a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f3:	83 ec 0c             	sub    $0xc,%esp
  8001f6:	50                   	push   %eax
  8001f7:	6a 06                	push   $0x6
  8001f9:	68 ca 0f 80 00       	push   $0x800fca
  8001fe:	6a 23                	push   $0x23
  800200:	68 e7 0f 80 00       	push   $0x800fe7
  800205:	e8 f0 00 00 00       	call   8002fa <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	b8 08 00 00 00       	mov    $0x8,%eax
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7e 17                	jle    80024c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	50                   	push   %eax
  800239:	6a 08                	push   $0x8
  80023b:	68 ca 0f 80 00       	push   $0x800fca
  800240:	6a 23                	push   $0x23
  800242:	68 e7 0f 80 00       	push   $0x800fe7
  800247:	e8 ae 00 00 00       	call   8002fa <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 09 00 00 00       	mov    $0x9,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	89 de                	mov    %ebx,%esi
  800271:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800273:	85 c0                	test   %eax,%eax
  800275:	7e 17                	jle    80028e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	50                   	push   %eax
  80027b:	6a 09                	push   $0x9
  80027d:	68 ca 0f 80 00       	push   $0x800fca
  800282:	6a 23                	push   $0x23
  800284:	68 e7 0f 80 00       	push   $0x800fe7
  800289:	e8 6c 00 00 00       	call   8002fa <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	be 00 00 00 00       	mov    $0x0,%esi
  8002a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	57                   	push   %edi
  8002bd:	56                   	push   %esi
  8002be:	53                   	push   %ebx
  8002bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 cb                	mov    %ecx,%ebx
  8002d1:	89 cf                	mov    %ecx,%edi
  8002d3:	89 ce                	mov    %ecx,%esi
  8002d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 17                	jle    8002f2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	50                   	push   %eax
  8002df:	6a 0c                	push   $0xc
  8002e1:	68 ca 0f 80 00       	push   $0x800fca
  8002e6:	6a 23                	push   $0x23
  8002e8:	68 e7 0f 80 00       	push   $0x800fe7
  8002ed:	e8 08 00 00 00       	call   8002fa <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ff:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800302:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800308:	e8 00 fe ff ff       	call   80010d <sys_getenvid>
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	56                   	push   %esi
  800317:	50                   	push   %eax
  800318:	68 f8 0f 80 00       	push   $0x800ff8
  80031d:	e8 b1 00 00 00       	call   8003d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800322:	83 c4 18             	add    $0x18,%esp
  800325:	53                   	push   %ebx
  800326:	ff 75 10             	pushl  0x10(%ebp)
  800329:	e8 54 00 00 00       	call   800382 <vcprintf>
	cprintf("\n");
  80032e:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800335:	e8 99 00 00 00       	call   8003d3 <cprintf>
  80033a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033d:	cc                   	int3   
  80033e:	eb fd                	jmp    80033d <_panic+0x43>

00800340 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	53                   	push   %ebx
  800344:	83 ec 04             	sub    $0x4,%esp
  800347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034a:	8b 13                	mov    (%ebx),%edx
  80034c:	8d 42 01             	lea    0x1(%edx),%eax
  80034f:	89 03                	mov    %eax,(%ebx)
  800351:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800354:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800358:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035d:	75 1a                	jne    800379 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	68 ff 00 00 00       	push   $0xff
  800367:	8d 43 08             	lea    0x8(%ebx),%eax
  80036a:	50                   	push   %eax
  80036b:	e8 1f fd ff ff       	call   80008f <sys_cputs>
		b->idx = 0;
  800370:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800376:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800379:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800392:	00 00 00 
	b.cnt = 0;
  800395:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039f:	ff 75 0c             	pushl  0xc(%ebp)
  8003a2:	ff 75 08             	pushl  0x8(%ebp)
  8003a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ab:	50                   	push   %eax
  8003ac:	68 40 03 80 00       	push   $0x800340
  8003b1:	e8 1a 01 00 00       	call   8004d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b6:	83 c4 08             	add    $0x8,%esp
  8003b9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c5:	50                   	push   %eax
  8003c6:	e8 c4 fc ff ff       	call   80008f <sys_cputs>

	return b.cnt;
}
  8003cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003dc:	50                   	push   %eax
  8003dd:	ff 75 08             	pushl  0x8(%ebp)
  8003e0:	e8 9d ff ff ff       	call   800382 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 1c             	sub    $0x1c,%esp
  8003f0:	89 c7                	mov    %eax,%edi
  8003f2:	89 d6                	mov    %edx,%esi
  8003f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800400:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800403:	bb 00 00 00 00       	mov    $0x0,%ebx
  800408:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80040e:	39 d3                	cmp    %edx,%ebx
  800410:	72 05                	jb     800417 <printnum+0x30>
  800412:	39 45 10             	cmp    %eax,0x10(%ebp)
  800415:	77 45                	ja     80045c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800417:	83 ec 0c             	sub    $0xc,%esp
  80041a:	ff 75 18             	pushl  0x18(%ebp)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800423:	53                   	push   %ebx
  800424:	ff 75 10             	pushl  0x10(%ebp)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042d:	ff 75 e0             	pushl  -0x20(%ebp)
  800430:	ff 75 dc             	pushl  -0x24(%ebp)
  800433:	ff 75 d8             	pushl  -0x28(%ebp)
  800436:	e8 e5 08 00 00       	call   800d20 <__udivdi3>
  80043b:	83 c4 18             	add    $0x18,%esp
  80043e:	52                   	push   %edx
  80043f:	50                   	push   %eax
  800440:	89 f2                	mov    %esi,%edx
  800442:	89 f8                	mov    %edi,%eax
  800444:	e8 9e ff ff ff       	call   8003e7 <printnum>
  800449:	83 c4 20             	add    $0x20,%esp
  80044c:	eb 18                	jmp    800466 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	ff 75 18             	pushl  0x18(%ebp)
  800455:	ff d7                	call   *%edi
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	eb 03                	jmp    80045f <printnum+0x78>
  80045c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045f:	83 eb 01             	sub    $0x1,%ebx
  800462:	85 db                	test   %ebx,%ebx
  800464:	7f e8                	jg     80044e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	83 ec 04             	sub    $0x4,%esp
  80046d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff 75 dc             	pushl  -0x24(%ebp)
  800476:	ff 75 d8             	pushl  -0x28(%ebp)
  800479:	e8 d2 09 00 00       	call   800e50 <__umoddi3>
  80047e:	83 c4 14             	add    $0x14,%esp
  800481:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800488:	50                   	push   %eax
  800489:	ff d7                	call   *%edi
}
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800491:	5b                   	pop    %ebx
  800492:	5e                   	pop    %esi
  800493:	5f                   	pop    %edi
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80049c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a5:	73 0a                	jae    8004b1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	88 02                	mov    %al,(%edx)
}
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    

008004b3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bc:	50                   	push   %eax
  8004bd:	ff 75 10             	pushl  0x10(%ebp)
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	ff 75 08             	pushl  0x8(%ebp)
  8004c6:	e8 05 00 00 00       	call   8004d0 <vprintfmt>
	va_end(ap);
}
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	57                   	push   %edi
  8004d4:	56                   	push   %esi
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 2c             	sub    $0x2c,%esp
  8004d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004df:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e2:	eb 12                	jmp    8004f6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	0f 84 42 04 00 00    	je     80092e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	50                   	push   %eax
  8004f1:	ff d6                	call   *%esi
  8004f3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f6:	83 c7 01             	add    $0x1,%edi
  8004f9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fd:	83 f8 25             	cmp    $0x25,%eax
  800500:	75 e2                	jne    8004e4 <vprintfmt+0x14>
  800502:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800506:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80050d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800514:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80051b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800520:	eb 07                	jmp    800529 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800525:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8d 47 01             	lea    0x1(%edi),%eax
  80052c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052f:	0f b6 07             	movzbl (%edi),%eax
  800532:	0f b6 d0             	movzbl %al,%edx
  800535:	83 e8 23             	sub    $0x23,%eax
  800538:	3c 55                	cmp    $0x55,%al
  80053a:	0f 87 d3 03 00 00    	ja     800913 <vprintfmt+0x443>
  800540:	0f b6 c0             	movzbl %al,%eax
  800543:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80054d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800551:	eb d6                	jmp    800529 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800556:	b8 00 00 00 00       	mov    $0x0,%eax
  80055b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80055e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800561:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800565:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800568:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056b:	83 f9 09             	cmp    $0x9,%ecx
  80056e:	77 3f                	ja     8005af <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800570:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800573:	eb e9                	jmp    80055e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 04             	lea    0x4(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800589:	eb 2a                	jmp    8005b5 <vprintfmt+0xe5>
  80058b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	ba 00 00 00 00       	mov    $0x0,%edx
  800595:	0f 49 d0             	cmovns %eax,%edx
  800598:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059e:	eb 89                	jmp    800529 <vprintfmt+0x59>
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005aa:	e9 7a ff ff ff       	jmp    800529 <vprintfmt+0x59>
  8005af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b9:	0f 89 6a ff ff ff    	jns    800529 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cc:	e9 58 ff ff ff       	jmp    800529 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d1:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d7:	e9 4d ff ff ff       	jmp    800529 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 78 04             	lea    0x4(%eax),%edi
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	ff 30                	pushl  (%eax)
  8005e8:	ff d6                	call   *%esi
			break;
  8005ea:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ed:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f3:	e9 fe fe ff ff       	jmp    8004f6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 78 04             	lea    0x4(%eax),%edi
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	99                   	cltd   
  800601:	31 d0                	xor    %edx,%eax
  800603:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800605:	83 f8 09             	cmp    $0x9,%eax
  800608:	7f 0b                	jg     800615 <vprintfmt+0x145>
  80060a:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800611:	85 d2                	test   %edx,%edx
  800613:	75 1b                	jne    800630 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800615:	50                   	push   %eax
  800616:	68 36 10 80 00       	push   $0x801036
  80061b:	53                   	push   %ebx
  80061c:	56                   	push   %esi
  80061d:	e8 91 fe ff ff       	call   8004b3 <printfmt>
  800622:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800625:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062b:	e9 c6 fe ff ff       	jmp    8004f6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800630:	52                   	push   %edx
  800631:	68 3f 10 80 00       	push   $0x80103f
  800636:	53                   	push   %ebx
  800637:	56                   	push   %esi
  800638:	e8 76 fe ff ff       	call   8004b3 <printfmt>
  80063d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800640:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800646:	e9 ab fe ff ff       	jmp    8004f6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	83 c0 04             	add    $0x4,%eax
  800651:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	0f 8e 94 00 00 00    	jle    800701 <vprintfmt+0x231>
  80066d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800671:	0f 84 98 00 00 00    	je     80070f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d0             	pushl  -0x30(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 33 03 00 00       	call   8009b6 <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x1db>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 ff                	test   %edi,%edi
  8006ad:	7f ed                	jg     80069c <vprintfmt+0x1cc>
  8006af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c1             	cmovns %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x21f>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x21f>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x24b>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x24b>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x27c>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1fe>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1fe>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x284>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800758:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800761:	e9 90 fd ff ff       	jmp    8004f6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800766:	83 f9 01             	cmp    $0x1,%ecx
  800769:	7e 19                	jle    800784 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
  800782:	eb 38                	jmp    8007bc <vprintfmt+0x2ec>
	else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	74 1b                	je     8007a3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 c1                	mov    %eax,%ecx
  800792:	c1 f9 1f             	sar    $0x1f,%ecx
  800795:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a1:	eb 19                	jmp    8007bc <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 c1                	mov    %eax,%ecx
  8007ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007cb:	0f 89 0e 01 00 00    	jns    8008df <vprintfmt+0x40f>
				putch('-', putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	6a 2d                	push   $0x2d
  8007d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007dc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007df:	f7 da                	neg    %edx
  8007e1:	83 d1 00             	adc    $0x0,%ecx
  8007e4:	f7 d9                	neg    %ecx
  8007e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ee:	e9 ec 00 00 00       	jmp    8008df <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f3:	83 f9 01             	cmp    $0x1,%ecx
  8007f6:	7e 18                	jle    800810 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800800:	8d 40 08             	lea    0x8(%eax),%eax
  800803:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800806:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080b:	e9 cf 00 00 00       	jmp    8008df <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800810:	85 c9                	test   %ecx,%ecx
  800812:	74 1a                	je     80082e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081e:	8d 40 04             	lea    0x4(%eax),%eax
  800821:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800824:	b8 0a 00 00 00       	mov    $0xa,%eax
  800829:	e9 b1 00 00 00       	jmp    8008df <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	8b 10                	mov    (%eax),%edx
  800833:	b9 00 00 00 00       	mov    $0x0,%ecx
  800838:	8d 40 04             	lea    0x4(%eax),%eax
  80083b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800843:	e9 97 00 00 00       	jmp    8008df <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	53                   	push   %ebx
  80084c:	6a 58                	push   $0x58
  80084e:	ff d6                	call   *%esi
			putch('X', putdat);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	6a 58                	push   $0x58
  800856:	ff d6                	call   *%esi
			putch('X', putdat);
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 58                	push   $0x58
  80085e:	ff d6                	call   *%esi
			break;
  800860:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800866:	e9 8b fc ff ff       	jmp    8004f6 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	6a 30                	push   $0x30
  800871:	ff d6                	call   *%esi
			putch('x', putdat);
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 78                	push   $0x78
  800879:	ff d6                	call   *%esi
			num = (unsigned long long)
  80087b:	8b 45 14             	mov    0x14(%ebp),%eax
  80087e:	8b 10                	mov    (%eax),%edx
  800880:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800885:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800888:	8d 40 04             	lea    0x4(%eax),%eax
  80088b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800893:	eb 4a                	jmp    8008df <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800895:	83 f9 01             	cmp    $0x1,%ecx
  800898:	7e 15                	jle    8008af <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8b 10                	mov    (%eax),%edx
  80089f:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a2:	8d 40 08             	lea    0x8(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ad:	eb 30                	jmp    8008df <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008af:	85 c9                	test   %ecx,%ecx
  8008b1:	74 17                	je     8008ca <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8b 10                	mov    (%eax),%edx
  8008b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bd:	8d 40 04             	lea    0x4(%eax),%eax
  8008c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c8:	eb 15                	jmp    8008df <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8b 10                	mov    (%eax),%edx
  8008cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d4:	8d 40 04             	lea    0x4(%eax),%eax
  8008d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008da:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008df:	83 ec 0c             	sub    $0xc,%esp
  8008e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008e6:	57                   	push   %edi
  8008e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	51                   	push   %ecx
  8008ec:	52                   	push   %edx
  8008ed:	89 da                	mov    %ebx,%edx
  8008ef:	89 f0                	mov    %esi,%eax
  8008f1:	e8 f1 fa ff ff       	call   8003e7 <printnum>
			break;
  8008f6:	83 c4 20             	add    $0x20,%esp
  8008f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fc:	e9 f5 fb ff ff       	jmp    8004f6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	53                   	push   %ebx
  800905:	52                   	push   %edx
  800906:	ff d6                	call   *%esi
			break;
  800908:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80090e:	e9 e3 fb ff ff       	jmp    8004f6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	53                   	push   %ebx
  800917:	6a 25                	push   $0x25
  800919:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	eb 03                	jmp    800923 <vprintfmt+0x453>
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800927:	75 f7                	jne    800920 <vprintfmt+0x450>
  800929:	e9 c8 fb ff ff       	jmp    8004f6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80092e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 18             	sub    $0x18,%esp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800942:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800945:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800949:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800953:	85 c0                	test   %eax,%eax
  800955:	74 26                	je     80097d <vsnprintf+0x47>
  800957:	85 d2                	test   %edx,%edx
  800959:	7e 22                	jle    80097d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095b:	ff 75 14             	pushl  0x14(%ebp)
  80095e:	ff 75 10             	pushl  0x10(%ebp)
  800961:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	68 96 04 80 00       	push   $0x800496
  80096a:	e8 61 fb ff ff       	call   8004d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800972:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800975:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	eb 05                	jmp    800982 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80097d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098d:	50                   	push   %eax
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 9a ff ff ff       	call   800936 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a9:	eb 03                	jmp    8009ae <strlen+0x10>
		n++;
  8009ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b2:	75 f7                	jne    8009ab <strlen+0xd>
		n++;
	return n;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c4:	eb 03                	jmp    8009c9 <strnlen+0x13>
		n++;
  8009c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c9:	39 c2                	cmp    %eax,%edx
  8009cb:	74 08                	je     8009d5 <strnlen+0x1f>
  8009cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009d1:	75 f3                	jne    8009c6 <strnlen+0x10>
  8009d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	75 ef                	jne    8009e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009fe:	53                   	push   %ebx
  8009ff:	e8 9a ff ff ff       	call   80099e <strlen>
  800a04:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	01 d8                	add    %ebx,%eax
  800a0c:	50                   	push   %eax
  800a0d:	e8 c5 ff ff ff       	call   8009d7 <strcpy>
	return dst;
}
  800a12:	89 d8                	mov    %ebx,%eax
  800a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	89 f2                	mov    %esi,%edx
  800a2b:	eb 0f                	jmp    800a3c <strncpy+0x23>
		*dst++ = *src;
  800a2d:	83 c2 01             	add    $0x1,%edx
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a36:	80 39 01             	cmpb   $0x1,(%ecx)
  800a39:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3c:	39 da                	cmp    %ebx,%edx
  800a3e:	75 ed                	jne    800a2d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a40:	89 f0                	mov    %esi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a51:	8b 55 10             	mov    0x10(%ebp),%edx
  800a54:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a56:	85 d2                	test   %edx,%edx
  800a58:	74 21                	je     800a7b <strlcpy+0x35>
  800a5a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a5e:	89 f2                	mov    %esi,%edx
  800a60:	eb 09                	jmp    800a6b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a6b:	39 c2                	cmp    %eax,%edx
  800a6d:	74 09                	je     800a78 <strlcpy+0x32>
  800a6f:	0f b6 19             	movzbl (%ecx),%ebx
  800a72:	84 db                	test   %bl,%bl
  800a74:	75 ec                	jne    800a62 <strlcpy+0x1c>
  800a76:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a78:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7b:	29 f0                	sub    %esi,%eax
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8a:	eb 06                	jmp    800a92 <strcmp+0x11>
		p++, q++;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a92:	0f b6 01             	movzbl (%ecx),%eax
  800a95:	84 c0                	test   %al,%al
  800a97:	74 04                	je     800a9d <strcmp+0x1c>
  800a99:	3a 02                	cmp    (%edx),%al
  800a9b:	74 ef                	je     800a8c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9d:	0f b6 c0             	movzbl %al,%eax
  800aa0:	0f b6 12             	movzbl (%edx),%edx
  800aa3:	29 d0                	sub    %edx,%eax
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab6:	eb 06                	jmp    800abe <strncmp+0x17>
		n--, p++, q++;
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800abe:	39 d8                	cmp    %ebx,%eax
  800ac0:	74 15                	je     800ad7 <strncmp+0x30>
  800ac2:	0f b6 08             	movzbl (%eax),%ecx
  800ac5:	84 c9                	test   %cl,%cl
  800ac7:	74 04                	je     800acd <strncmp+0x26>
  800ac9:	3a 0a                	cmp    (%edx),%cl
  800acb:	74 eb                	je     800ab8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acd:	0f b6 00             	movzbl (%eax),%eax
  800ad0:	0f b6 12             	movzbl (%edx),%edx
  800ad3:	29 d0                	sub    %edx,%eax
  800ad5:	eb 05                	jmp    800adc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae9:	eb 07                	jmp    800af2 <strchr+0x13>
		if (*s == c)
  800aeb:	38 ca                	cmp    %cl,%dl
  800aed:	74 0f                	je     800afe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	0f b6 10             	movzbl (%eax),%edx
  800af5:	84 d2                	test   %dl,%dl
  800af7:	75 f2                	jne    800aeb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0a:	eb 03                	jmp    800b0f <strfind+0xf>
  800b0c:	83 c0 01             	add    $0x1,%eax
  800b0f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b12:	38 ca                	cmp    %cl,%dl
  800b14:	74 04                	je     800b1a <strfind+0x1a>
  800b16:	84 d2                	test   %dl,%dl
  800b18:	75 f2                	jne    800b0c <strfind+0xc>
			break;
	return (char *) s;
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b28:	85 c9                	test   %ecx,%ecx
  800b2a:	74 36                	je     800b62 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b32:	75 28                	jne    800b5c <memset+0x40>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 23                	jne    800b5c <memset+0x40>
		c &= 0xFF;
  800b39:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b3d:	89 d3                	mov    %edx,%ebx
  800b3f:	c1 e3 08             	shl    $0x8,%ebx
  800b42:	89 d6                	mov    %edx,%esi
  800b44:	c1 e6 18             	shl    $0x18,%esi
  800b47:	89 d0                	mov    %edx,%eax
  800b49:	c1 e0 10             	shl    $0x10,%eax
  800b4c:	09 f0                	or     %esi,%eax
  800b4e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b50:	89 d8                	mov    %ebx,%eax
  800b52:	09 d0                	or     %edx,%eax
  800b54:	c1 e9 02             	shr    $0x2,%ecx
  800b57:	fc                   	cld    
  800b58:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5a:	eb 06                	jmp    800b62 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5f:	fc                   	cld    
  800b60:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b62:	89 f8                	mov    %edi,%eax
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b74:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b77:	39 c6                	cmp    %eax,%esi
  800b79:	73 35                	jae    800bb0 <memmove+0x47>
  800b7b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b7e:	39 d0                	cmp    %edx,%eax
  800b80:	73 2e                	jae    800bb0 <memmove+0x47>
		s += n;
		d += n;
  800b82:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	09 fe                	or     %edi,%esi
  800b89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8f:	75 13                	jne    800ba4 <memmove+0x3b>
  800b91:	f6 c1 03             	test   $0x3,%cl
  800b94:	75 0e                	jne    800ba4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b96:	83 ef 04             	sub    $0x4,%edi
  800b99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
  800b9f:	fd                   	std    
  800ba0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba2:	eb 09                	jmp    800bad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba4:	83 ef 01             	sub    $0x1,%edi
  800ba7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800baa:	fd                   	std    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bad:	fc                   	cld    
  800bae:	eb 1d                	jmp    800bcd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb0:	89 f2                	mov    %esi,%edx
  800bb2:	09 c2                	or     %eax,%edx
  800bb4:	f6 c2 03             	test   $0x3,%dl
  800bb7:	75 0f                	jne    800bc8 <memmove+0x5f>
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 0a                	jne    800bc8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bbe:	c1 e9 02             	shr    $0x2,%ecx
  800bc1:	89 c7                	mov    %eax,%edi
  800bc3:	fc                   	cld    
  800bc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc6:	eb 05                	jmp    800bcd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc8:	89 c7                	mov    %eax,%edi
  800bca:	fc                   	cld    
  800bcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd4:	ff 75 10             	pushl  0x10(%ebp)
  800bd7:	ff 75 0c             	pushl  0xc(%ebp)
  800bda:	ff 75 08             	pushl  0x8(%ebp)
  800bdd:	e8 87 ff ff ff       	call   800b69 <memmove>
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	89 c6                	mov    %eax,%esi
  800bf1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf4:	eb 1a                	jmp    800c10 <memcmp+0x2c>
		if (*s1 != *s2)
  800bf6:	0f b6 08             	movzbl (%eax),%ecx
  800bf9:	0f b6 1a             	movzbl (%edx),%ebx
  800bfc:	38 d9                	cmp    %bl,%cl
  800bfe:	74 0a                	je     800c0a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c00:	0f b6 c1             	movzbl %cl,%eax
  800c03:	0f b6 db             	movzbl %bl,%ebx
  800c06:	29 d8                	sub    %ebx,%eax
  800c08:	eb 0f                	jmp    800c19 <memcmp+0x35>
		s1++, s2++;
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	75 e2                	jne    800bf6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	53                   	push   %ebx
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c24:	89 c1                	mov    %eax,%ecx
  800c26:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c29:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2d:	eb 0a                	jmp    800c39 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2f:	0f b6 10             	movzbl (%eax),%edx
  800c32:	39 da                	cmp    %ebx,%edx
  800c34:	74 07                	je     800c3d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c36:	83 c0 01             	add    $0x1,%eax
  800c39:	39 c8                	cmp    %ecx,%eax
  800c3b:	72 f2                	jb     800c2f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4c:	eb 03                	jmp    800c51 <strtol+0x11>
		s++;
  800c4e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c51:	0f b6 01             	movzbl (%ecx),%eax
  800c54:	3c 20                	cmp    $0x20,%al
  800c56:	74 f6                	je     800c4e <strtol+0xe>
  800c58:	3c 09                	cmp    $0x9,%al
  800c5a:	74 f2                	je     800c4e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5c:	3c 2b                	cmp    $0x2b,%al
  800c5e:	75 0a                	jne    800c6a <strtol+0x2a>
		s++;
  800c60:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
  800c68:	eb 11                	jmp    800c7b <strtol+0x3b>
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c6f:	3c 2d                	cmp    $0x2d,%al
  800c71:	75 08                	jne    800c7b <strtol+0x3b>
		s++, neg = 1;
  800c73:	83 c1 01             	add    $0x1,%ecx
  800c76:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c81:	75 15                	jne    800c98 <strtol+0x58>
  800c83:	80 39 30             	cmpb   $0x30,(%ecx)
  800c86:	75 10                	jne    800c98 <strtol+0x58>
  800c88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8c:	75 7c                	jne    800d0a <strtol+0xca>
		s += 2, base = 16;
  800c8e:	83 c1 02             	add    $0x2,%ecx
  800c91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c96:	eb 16                	jmp    800cae <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c98:	85 db                	test   %ebx,%ebx
  800c9a:	75 12                	jne    800cae <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca4:	75 08                	jne    800cae <strtol+0x6e>
		s++, base = 8;
  800ca6:	83 c1 01             	add    $0x1,%ecx
  800ca9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb6:	0f b6 11             	movzbl (%ecx),%edx
  800cb9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	80 fb 09             	cmp    $0x9,%bl
  800cc1:	77 08                	ja     800ccb <strtol+0x8b>
			dig = *s - '0';
  800cc3:	0f be d2             	movsbl %dl,%edx
  800cc6:	83 ea 30             	sub    $0x30,%edx
  800cc9:	eb 22                	jmp    800ced <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ccb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cce:	89 f3                	mov    %esi,%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cd5:	0f be d2             	movsbl %dl,%edx
  800cd8:	83 ea 57             	sub    $0x57,%edx
  800cdb:	eb 10                	jmp    800ced <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cdd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce0:	89 f3                	mov    %esi,%ebx
  800ce2:	80 fb 19             	cmp    $0x19,%bl
  800ce5:	77 16                	ja     800cfd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce7:	0f be d2             	movsbl %dl,%edx
  800cea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ced:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf0:	7d 0b                	jge    800cfd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cf2:	83 c1 01             	add    $0x1,%ecx
  800cf5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cfb:	eb b9                	jmp    800cb6 <strtol+0x76>

	if (endptr)
  800cfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d01:	74 0d                	je     800d10 <strtol+0xd0>
		*endptr = (char *) s;
  800d03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d06:	89 0e                	mov    %ecx,(%esi)
  800d08:	eb 06                	jmp    800d10 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0a:	85 db                	test   %ebx,%ebx
  800d0c:	74 98                	je     800ca6 <strtol+0x66>
  800d0e:	eb 9e                	jmp    800cae <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	f7 da                	neg    %edx
  800d14:	85 ff                	test   %edi,%edi
  800d16:	0f 45 c2             	cmovne %edx,%eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
