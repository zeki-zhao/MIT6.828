
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	83 ec 08             	sub    $0x8,%esp
  800048:	8b 45 08             	mov    0x8(%ebp),%eax
  80004b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800055:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 c0                	test   %eax,%eax
  80005a:	7e 08                	jle    800064 <libmain+0x22>
		binaryname = argv[0];
  80005c:	8b 0a                	mov    (%edx),%ecx
  80005e:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	52                   	push   %edx
  800068:	50                   	push   %eax
  800069:	e8 c5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	c9                   	leave  
  800077:	c3                   	ret    

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007e:	6a 00                	push   $0x0
  800080:	e8 42 00 00 00       	call   8000c7 <sys_env_destroy>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	c9                   	leave  
  800089:	c3                   	ret    

0080008a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	57                   	push   %edi
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800090:	b8 00 00 00 00       	mov    $0x0,%eax
  800095:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800098:	8b 55 08             	mov    0x8(%ebp),%edx
  80009b:	89 c3                	mov    %eax,%ebx
  80009d:	89 c7                	mov    %eax,%edi
  80009f:	89 c6                	mov    %eax,%esi
  8000a1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5f                   	pop    %edi
  8000a6:	5d                   	pop    %ebp
  8000a7:	c3                   	ret    

008000a8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b8:	89 d1                	mov    %edx,%ecx
  8000ba:	89 d3                	mov    %edx,%ebx
  8000bc:	89 d7                	mov    %edx,%edi
  8000be:	89 d6                	mov    %edx,%esi
  8000c0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000da:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dd:	89 cb                	mov    %ecx,%ebx
  8000df:	89 cf                	mov    %ecx,%edi
  8000e1:	89 ce                	mov    %ecx,%esi
  8000e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	7e 17                	jle    800100 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e9:	83 ec 0c             	sub    $0xc,%esp
  8000ec:	50                   	push   %eax
  8000ed:	6a 03                	push   $0x3
  8000ef:	68 ca 0f 80 00       	push   $0x800fca
  8000f4:	6a 23                	push   $0x23
  8000f6:	68 e7 0f 80 00       	push   $0x800fe7
  8000fb:	e8 f5 01 00 00       	call   8002f5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5f                   	pop    %edi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	ba 00 00 00 00       	mov    $0x0,%edx
  800113:	b8 02 00 00 00       	mov    $0x2,%eax
  800118:	89 d1                	mov    %edx,%ecx
  80011a:	89 d3                	mov    %edx,%ebx
  80011c:	89 d7                	mov    %edx,%edi
  80011e:	89 d6                	mov    %edx,%esi
  800120:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_yield>:

void
sys_yield(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 0a 00 00 00       	mov    $0xa,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	be 00 00 00 00       	mov    $0x0,%esi
  800154:	b8 04 00 00 00       	mov    $0x4,%eax
  800159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800162:	89 f7                	mov    %esi,%edi
  800164:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	7e 17                	jle    800181 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	50                   	push   %eax
  80016e:	6a 04                	push   $0x4
  800170:	68 ca 0f 80 00       	push   $0x800fca
  800175:	6a 23                	push   $0x23
  800177:	68 e7 0f 80 00       	push   $0x800fe7
  80017c:	e8 74 01 00 00       	call   8002f5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	b8 05 00 00 00       	mov    $0x5,%eax
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	7e 17                	jle    8001c3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	50                   	push   %eax
  8001b0:	6a 05                	push   $0x5
  8001b2:	68 ca 0f 80 00       	push   $0x800fca
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 e7 0f 80 00       	push   $0x800fe7
  8001be:	e8 32 01 00 00       	call   8002f5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	89 df                	mov    %ebx,%edi
  8001e6:	89 de                	mov    %ebx,%esi
  8001e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	7e 17                	jle    800205 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	50                   	push   %eax
  8001f2:	6a 06                	push   $0x6
  8001f4:	68 ca 0f 80 00       	push   $0x800fca
  8001f9:	6a 23                	push   $0x23
  8001fb:	68 e7 0f 80 00       	push   $0x800fe7
  800200:	e8 f0 00 00 00       	call   8002f5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    

0080020d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	b8 08 00 00 00       	mov    $0x8,%eax
  800220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	89 df                	mov    %ebx,%edi
  800228:	89 de                	mov    %ebx,%esi
  80022a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022c:	85 c0                	test   %eax,%eax
  80022e:	7e 17                	jle    800247 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	50                   	push   %eax
  800234:	6a 08                	push   $0x8
  800236:	68 ca 0f 80 00       	push   $0x800fca
  80023b:	6a 23                	push   $0x23
  80023d:	68 e7 0f 80 00       	push   $0x800fe7
  800242:	e8 ae 00 00 00       	call   8002f5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025d:	b8 09 00 00 00       	mov    $0x9,%eax
  800262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	89 df                	mov    %ebx,%edi
  80026a:	89 de                	mov    %ebx,%esi
  80026c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80026e:	85 c0                	test   %eax,%eax
  800270:	7e 17                	jle    800289 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	50                   	push   %eax
  800276:	6a 09                	push   $0x9
  800278:	68 ca 0f 80 00       	push   $0x800fca
  80027d:	6a 23                	push   $0x23
  80027f:	68 e7 0f 80 00       	push   $0x800fe7
  800284:	e8 6c 00 00 00       	call   8002f5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800297:	be 00 00 00 00       	mov    $0x0,%esi
  80029c:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002aa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ad:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 cb                	mov    %ecx,%ebx
  8002cc:	89 cf                	mov    %ecx,%edi
  8002ce:	89 ce                	mov    %ecx,%esi
  8002d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 17                	jle    8002ed <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	50                   	push   %eax
  8002da:	6a 0c                	push   $0xc
  8002dc:	68 ca 0f 80 00       	push   $0x800fca
  8002e1:	6a 23                	push   $0x23
  8002e3:	68 e7 0f 80 00       	push   $0x800fe7
  8002e8:	e8 08 00 00 00       	call   8002f5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002fa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002fd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800303:	e8 00 fe ff ff       	call   800108 <sys_getenvid>
  800308:	83 ec 0c             	sub    $0xc,%esp
  80030b:	ff 75 0c             	pushl  0xc(%ebp)
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	56                   	push   %esi
  800312:	50                   	push   %eax
  800313:	68 f8 0f 80 00       	push   $0x800ff8
  800318:	e8 b1 00 00 00       	call   8003ce <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80031d:	83 c4 18             	add    $0x18,%esp
  800320:	53                   	push   %ebx
  800321:	ff 75 10             	pushl  0x10(%ebp)
  800324:	e8 54 00 00 00       	call   80037d <vcprintf>
	cprintf("\n");
  800329:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800330:	e8 99 00 00 00       	call   8003ce <cprintf>
  800335:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800338:	cc                   	int3   
  800339:	eb fd                	jmp    800338 <_panic+0x43>

0080033b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	53                   	push   %ebx
  80033f:	83 ec 04             	sub    $0x4,%esp
  800342:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800345:	8b 13                	mov    (%ebx),%edx
  800347:	8d 42 01             	lea    0x1(%edx),%eax
  80034a:	89 03                	mov    %eax,(%ebx)
  80034c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800353:	3d ff 00 00 00       	cmp    $0xff,%eax
  800358:	75 1a                	jne    800374 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	68 ff 00 00 00       	push   $0xff
  800362:	8d 43 08             	lea    0x8(%ebx),%eax
  800365:	50                   	push   %eax
  800366:	e8 1f fd ff ff       	call   80008a <sys_cputs>
		b->idx = 0;
  80036b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800371:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800374:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    

0080037d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800386:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80038d:	00 00 00 
	b.cnt = 0;
  800390:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800397:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039a:	ff 75 0c             	pushl  0xc(%ebp)
  80039d:	ff 75 08             	pushl  0x8(%ebp)
  8003a0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a6:	50                   	push   %eax
  8003a7:	68 3b 03 80 00       	push   $0x80033b
  8003ac:	e8 1a 01 00 00       	call   8004cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b1:	83 c4 08             	add    $0x8,%esp
  8003b4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c0:	50                   	push   %eax
  8003c1:	e8 c4 fc ff ff       	call   80008a <sys_cputs>

	return b.cnt;
}
  8003c6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d7:	50                   	push   %eax
  8003d8:	ff 75 08             	pushl  0x8(%ebp)
  8003db:	e8 9d ff ff ff       	call   80037d <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	57                   	push   %edi
  8003e6:	56                   	push   %esi
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 1c             	sub    $0x1c,%esp
  8003eb:	89 c7                	mov    %eax,%edi
  8003ed:	89 d6                	mov    %edx,%esi
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800403:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800406:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800409:	39 d3                	cmp    %edx,%ebx
  80040b:	72 05                	jb     800412 <printnum+0x30>
  80040d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800410:	77 45                	ja     800457 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 18             	pushl  0x18(%ebp)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80041e:	53                   	push   %ebx
  80041f:	ff 75 10             	pushl  0x10(%ebp)
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	ff 75 e4             	pushl  -0x1c(%ebp)
  800428:	ff 75 e0             	pushl  -0x20(%ebp)
  80042b:	ff 75 dc             	pushl  -0x24(%ebp)
  80042e:	ff 75 d8             	pushl  -0x28(%ebp)
  800431:	e8 ea 08 00 00       	call   800d20 <__udivdi3>
  800436:	83 c4 18             	add    $0x18,%esp
  800439:	52                   	push   %edx
  80043a:	50                   	push   %eax
  80043b:	89 f2                	mov    %esi,%edx
  80043d:	89 f8                	mov    %edi,%eax
  80043f:	e8 9e ff ff ff       	call   8003e2 <printnum>
  800444:	83 c4 20             	add    $0x20,%esp
  800447:	eb 18                	jmp    800461 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	56                   	push   %esi
  80044d:	ff 75 18             	pushl  0x18(%ebp)
  800450:	ff d7                	call   *%edi
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	eb 03                	jmp    80045a <printnum+0x78>
  800457:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045a:	83 eb 01             	sub    $0x1,%ebx
  80045d:	85 db                	test   %ebx,%ebx
  80045f:	7f e8                	jg     800449 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	83 ec 04             	sub    $0x4,%esp
  800468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 75 dc             	pushl  -0x24(%ebp)
  800471:	ff 75 d8             	pushl  -0x28(%ebp)
  800474:	e8 d7 09 00 00       	call   800e50 <__umoddi3>
  800479:	83 c4 14             	add    $0x14,%esp
  80047c:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800483:	50                   	push   %eax
  800484:	ff d7                	call   *%edi
}
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048c:	5b                   	pop    %ebx
  80048d:	5e                   	pop    %esi
  80048e:	5f                   	pop    %edi
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800497:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049b:	8b 10                	mov    (%eax),%edx
  80049d:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a0:	73 0a                	jae    8004ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	88 02                	mov    %al,(%edx)
}
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b7:	50                   	push   %eax
  8004b8:	ff 75 10             	pushl  0x10(%ebp)
  8004bb:	ff 75 0c             	pushl  0xc(%ebp)
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 05 00 00 00       	call   8004cb <vprintfmt>
	va_end(ap);
}
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	57                   	push   %edi
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 2c             	sub    $0x2c,%esp
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004dd:	eb 12                	jmp    8004f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 84 42 04 00 00    	je     800929 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	50                   	push   %eax
  8004ec:	ff d6                	call   *%esi
  8004ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f1:	83 c7 01             	add    $0x1,%edi
  8004f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f8:	83 f8 25             	cmp    $0x25,%eax
  8004fb:	75 e2                	jne    8004df <vprintfmt+0x14>
  8004fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800501:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800508:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800516:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051b:	eb 07                	jmp    800524 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800520:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8d 47 01             	lea    0x1(%edi),%eax
  800527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052a:	0f b6 07             	movzbl (%edi),%eax
  80052d:	0f b6 d0             	movzbl %al,%edx
  800530:	83 e8 23             	sub    $0x23,%eax
  800533:	3c 55                	cmp    $0x55,%al
  800535:	0f 87 d3 03 00 00    	ja     80090e <vprintfmt+0x443>
  80053b:	0f b6 c0             	movzbl %al,%eax
  80053e:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054c:	eb d6                	jmp    800524 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800559:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800560:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800563:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800566:	83 f9 09             	cmp    $0x9,%ecx
  800569:	77 3f                	ja     8005aa <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80056e:	eb e9                	jmp    800559 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800584:	eb 2a                	jmp    8005b0 <vprintfmt+0xe5>
  800586:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	ba 00 00 00 00       	mov    $0x0,%edx
  800590:	0f 49 d0             	cmovns %eax,%edx
  800593:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	eb 89                	jmp    800524 <vprintfmt+0x59>
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a5:	e9 7a ff ff ff       	jmp    800524 <vprintfmt+0x59>
  8005aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ad:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b4:	0f 89 6a ff ff ff    	jns    800524 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c7:	e9 58 ff ff ff       	jmp    800524 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005cc:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d2:	e9 4d ff ff ff       	jmp    800524 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 78 04             	lea    0x4(%eax),%edi
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 30                	pushl  (%eax)
  8005e3:	ff d6                	call   *%esi
			break;
  8005e5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ee:	e9 fe fe ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 78 04             	lea    0x4(%eax),%edi
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	99                   	cltd   
  8005fc:	31 d0                	xor    %edx,%eax
  8005fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800600:	83 f8 09             	cmp    $0x9,%eax
  800603:	7f 0b                	jg     800610 <vprintfmt+0x145>
  800605:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	75 1b                	jne    80062b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800610:	50                   	push   %eax
  800611:	68 36 10 80 00       	push   $0x801036
  800616:	53                   	push   %ebx
  800617:	56                   	push   %esi
  800618:	e8 91 fe ff ff       	call   8004ae <printfmt>
  80061d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800620:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800626:	e9 c6 fe ff ff       	jmp    8004f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80062b:	52                   	push   %edx
  80062c:	68 3f 10 80 00       	push   $0x80103f
  800631:	53                   	push   %ebx
  800632:	56                   	push   %esi
  800633:	e8 76 fe ff ff       	call   8004ae <printfmt>
  800638:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	e9 ab fe ff ff       	jmp    8004f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	83 c0 04             	add    $0x4,%eax
  80064c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800654:	85 ff                	test   %edi,%edi
  800656:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  80065b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80065e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800662:	0f 8e 94 00 00 00    	jle    8006fc <vprintfmt+0x231>
  800668:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80066c:	0f 84 98 00 00 00    	je     80070a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	ff 75 d0             	pushl  -0x30(%ebp)
  800678:	57                   	push   %edi
  800679:	e8 33 03 00 00       	call   8009b1 <strnlen>
  80067e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800681:	29 c1                	sub    %eax,%ecx
  800683:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800686:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800689:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800690:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800693:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x1db>
					putch(padc, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	ff 75 e0             	pushl  -0x20(%ebp)
  80069e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	85 ff                	test   %edi,%edi
  8006a8:	7f ed                	jg     800697 <vprintfmt+0x1cc>
  8006aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ad:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	0f 49 c1             	cmovns %ecx,%eax
  8006ba:	29 c1                	sub    %eax,%ecx
  8006bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c5:	89 cb                	mov    %ecx,%ebx
  8006c7:	eb 4d                	jmp    800716 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006cd:	74 1b                	je     8006ea <vprintfmt+0x21f>
  8006cf:	0f be c0             	movsbl %al,%eax
  8006d2:	83 e8 20             	sub    $0x20,%eax
  8006d5:	83 f8 5e             	cmp    $0x5e,%eax
  8006d8:	76 10                	jbe    8006ea <vprintfmt+0x21f>
					putch('?', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	6a 3f                	push   $0x3f
  8006e2:	ff 55 08             	call   *0x8(%ebp)
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 0d                	jmp    8006f7 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	ff 75 0c             	pushl  0xc(%ebp)
  8006f0:	52                   	push   %edx
  8006f1:	ff 55 08             	call   *0x8(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f7:	83 eb 01             	sub    $0x1,%ebx
  8006fa:	eb 1a                	jmp    800716 <vprintfmt+0x24b>
  8006fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800702:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800705:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800708:	eb 0c                	jmp    800716 <vprintfmt+0x24b>
  80070a:	89 75 08             	mov    %esi,0x8(%ebp)
  80070d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800710:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800713:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800716:	83 c7 01             	add    $0x1,%edi
  800719:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071d:	0f be d0             	movsbl %al,%edx
  800720:	85 d2                	test   %edx,%edx
  800722:	74 23                	je     800747 <vprintfmt+0x27c>
  800724:	85 f6                	test   %esi,%esi
  800726:	78 a1                	js     8006c9 <vprintfmt+0x1fe>
  800728:	83 ee 01             	sub    $0x1,%esi
  80072b:	79 9c                	jns    8006c9 <vprintfmt+0x1fe>
  80072d:	89 df                	mov    %ebx,%edi
  80072f:	8b 75 08             	mov    0x8(%ebp),%esi
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	eb 18                	jmp    80074f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 20                	push   $0x20
  80073d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073f:	83 ef 01             	sub    $0x1,%edi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 08                	jmp    80074f <vprintfmt+0x284>
  800747:	89 df                	mov    %ebx,%edi
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074f:	85 ff                	test   %edi,%edi
  800751:	7f e4                	jg     800737 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075c:	e9 90 fd ff ff       	jmp    8004f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800761:	83 f9 01             	cmp    $0x1,%ecx
  800764:	7e 19                	jle    80077f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 50 04             	mov    0x4(%eax),%edx
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 40 08             	lea    0x8(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
  80077d:	eb 38                	jmp    8007b7 <vprintfmt+0x2ec>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	74 1b                	je     80079e <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 c1                	mov    %eax,%ecx
  80078d:	c1 f9 1f             	sar    $0x1f,%ecx
  800790:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	eb 19                	jmp    8007b7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	89 c1                	mov    %eax,%ecx
  8007a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c6:	0f 89 0e 01 00 00    	jns    8008da <vprintfmt+0x40f>
				putch('-', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 2d                	push   $0x2d
  8007d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007da:	f7 da                	neg    %edx
  8007dc:	83 d1 00             	adc    $0x0,%ecx
  8007df:	f7 d9                	neg    %ecx
  8007e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e9:	e9 ec 00 00 00       	jmp    8008da <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ee:	83 f9 01             	cmp    $0x1,%ecx
  8007f1:	7e 18                	jle    80080b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007fb:	8d 40 08             	lea    0x8(%eax),%eax
  8007fe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 cf 00 00 00       	jmp    8008da <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	74 1a                	je     800829 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8b 10                	mov    (%eax),%edx
  800814:	b9 00 00 00 00       	mov    $0x0,%ecx
  800819:	8d 40 04             	lea    0x4(%eax),%eax
  80081c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800824:	e9 b1 00 00 00       	jmp    8008da <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800833:	8d 40 04             	lea    0x4(%eax),%eax
  800836:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	e9 97 00 00 00       	jmp    8008da <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 58                	push   $0x58
  800849:	ff d6                	call   *%esi
			putch('X', putdat);
  80084b:	83 c4 08             	add    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 58                	push   $0x58
  800851:	ff d6                	call   *%esi
			putch('X', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 58                	push   $0x58
  800859:	ff d6                	call   *%esi
			break;
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800861:	e9 8b fc ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 30                	push   $0x30
  80086c:	ff d6                	call   *%esi
			putch('x', putdat);
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	6a 78                	push   $0x78
  800874:	ff d6                	call   *%esi
			num = (unsigned long long)
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8b 10                	mov    (%eax),%edx
  80087b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800880:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800883:	8d 40 04             	lea    0x4(%eax),%eax
  800886:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800889:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088e:	eb 4a                	jmp    8008da <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800890:	83 f9 01             	cmp    $0x1,%ecx
  800893:	7e 15                	jle    8008aa <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8b 10                	mov    (%eax),%edx
  80089a:	8b 48 04             	mov    0x4(%eax),%ecx
  80089d:	8d 40 08             	lea    0x8(%eax),%eax
  8008a0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008a3:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a8:	eb 30                	jmp    8008da <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 17                	je     8008c5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 10                	mov    (%eax),%edx
  8008b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b8:	8d 40 04             	lea    0x4(%eax),%eax
  8008bb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008be:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c3:	eb 15                	jmp    8008da <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008cf:	8d 40 04             	lea    0x4(%eax),%eax
  8008d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008d5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008da:	83 ec 0c             	sub    $0xc,%esp
  8008dd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008e1:	57                   	push   %edi
  8008e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e5:	50                   	push   %eax
  8008e6:	51                   	push   %ecx
  8008e7:	52                   	push   %edx
  8008e8:	89 da                	mov    %ebx,%edx
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	e8 f1 fa ff ff       	call   8003e2 <printnum>
			break;
  8008f1:	83 c4 20             	add    $0x20,%esp
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f7:	e9 f5 fb ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	52                   	push   %edx
  800901:	ff d6                	call   *%esi
			break;
  800903:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800909:	e9 e3 fb ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	6a 25                	push   $0x25
  800914:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 03                	jmp    80091e <vprintfmt+0x453>
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800922:	75 f7                	jne    80091b <vprintfmt+0x450>
  800924:	e9 c8 fb ff ff       	jmp    8004f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800929:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 18             	sub    $0x18,%esp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800940:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800944:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800947:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094e:	85 c0                	test   %eax,%eax
  800950:	74 26                	je     800978 <vsnprintf+0x47>
  800952:	85 d2                	test   %edx,%edx
  800954:	7e 22                	jle    800978 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800956:	ff 75 14             	pushl  0x14(%ebp)
  800959:	ff 75 10             	pushl  0x10(%ebp)
  80095c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095f:	50                   	push   %eax
  800960:	68 91 04 80 00       	push   $0x800491
  800965:	e8 61 fb ff ff       	call   8004cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800970:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	eb 05                	jmp    80097d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800978:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800988:	50                   	push   %eax
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 9a ff ff ff       	call   800931 <vsnprintf>
	va_end(ap);

	return rc;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb 03                	jmp    8009a9 <strlen+0x10>
		n++;
  8009a6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ad:	75 f7                	jne    8009a6 <strlen+0xd>
		n++;
	return n;
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 03                	jmp    8009c4 <strnlen+0x13>
		n++;
  8009c1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c4:	39 c2                	cmp    %eax,%edx
  8009c6:	74 08                	je     8009d0 <strnlen+0x1f>
  8009c8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009cc:	75 f3                	jne    8009c1 <strnlen+0x10>
  8009ce:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009eb:	84 db                	test   %bl,%bl
  8009ed:	75 ef                	jne    8009de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f9:	53                   	push   %ebx
  8009fa:	e8 9a ff ff ff       	call   800999 <strlen>
  8009ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	01 d8                	add    %ebx,%eax
  800a07:	50                   	push   %eax
  800a08:	e8 c5 ff ff ff       	call   8009d2 <strcpy>
	return dst;
}
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a24:	89 f2                	mov    %esi,%edx
  800a26:	eb 0f                	jmp    800a37 <strncpy+0x23>
		*dst++ = *src;
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a31:	80 39 01             	cmpb   $0x1,(%ecx)
  800a34:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	75 ed                	jne    800a28 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3b:	89 f0                	mov    %esi,%eax
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a51:	85 d2                	test   %edx,%edx
  800a53:	74 21                	je     800a76 <strlcpy+0x35>
  800a55:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a59:	89 f2                	mov    %esi,%edx
  800a5b:	eb 09                	jmp    800a66 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5d:	83 c2 01             	add    $0x1,%edx
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a66:	39 c2                	cmp    %eax,%edx
  800a68:	74 09                	je     800a73 <strlcpy+0x32>
  800a6a:	0f b6 19             	movzbl (%ecx),%ebx
  800a6d:	84 db                	test   %bl,%bl
  800a6f:	75 ec                	jne    800a5d <strlcpy+0x1c>
  800a71:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a73:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a76:	29 f0                	sub    %esi,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a85:	eb 06                	jmp    800a8d <strcmp+0x11>
		p++, q++;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8d:	0f b6 01             	movzbl (%ecx),%eax
  800a90:	84 c0                	test   %al,%al
  800a92:	74 04                	je     800a98 <strcmp+0x1c>
  800a94:	3a 02                	cmp    (%edx),%al
  800a96:	74 ef                	je     800a87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 c0             	movzbl %al,%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab1:	eb 06                	jmp    800ab9 <strncmp+0x17>
		n--, p++, q++;
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab9:	39 d8                	cmp    %ebx,%eax
  800abb:	74 15                	je     800ad2 <strncmp+0x30>
  800abd:	0f b6 08             	movzbl (%eax),%ecx
  800ac0:	84 c9                	test   %cl,%cl
  800ac2:	74 04                	je     800ac8 <strncmp+0x26>
  800ac4:	3a 0a                	cmp    (%edx),%cl
  800ac6:	74 eb                	je     800ab3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac8:	0f b6 00             	movzbl (%eax),%eax
  800acb:	0f b6 12             	movzbl (%edx),%edx
  800ace:	29 d0                	sub    %edx,%eax
  800ad0:	eb 05                	jmp    800ad7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae4:	eb 07                	jmp    800aed <strchr+0x13>
		if (*s == c)
  800ae6:	38 ca                	cmp    %cl,%dl
  800ae8:	74 0f                	je     800af9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 f2                	jne    800ae6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	eb 03                	jmp    800b0a <strfind+0xf>
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b0d:	38 ca                	cmp    %cl,%dl
  800b0f:	74 04                	je     800b15 <strfind+0x1a>
  800b11:	84 d2                	test   %dl,%dl
  800b13:	75 f2                	jne    800b07 <strfind+0xc>
			break;
	return (char *) s;
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b23:	85 c9                	test   %ecx,%ecx
  800b25:	74 36                	je     800b5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2d:	75 28                	jne    800b57 <memset+0x40>
  800b2f:	f6 c1 03             	test   $0x3,%cl
  800b32:	75 23                	jne    800b57 <memset+0x40>
		c &= 0xFF;
  800b34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	c1 e3 08             	shl    $0x8,%ebx
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	c1 e6 18             	shl    $0x18,%esi
  800b42:	89 d0                	mov    %edx,%eax
  800b44:	c1 e0 10             	shl    $0x10,%eax
  800b47:	09 f0                	or     %esi,%eax
  800b49:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b4b:	89 d8                	mov    %ebx,%eax
  800b4d:	09 d0                	or     %edx,%eax
  800b4f:	c1 e9 02             	shr    $0x2,%ecx
  800b52:	fc                   	cld    
  800b53:	f3 ab                	rep stos %eax,%es:(%edi)
  800b55:	eb 06                	jmp    800b5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	fc                   	cld    
  800b5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b72:	39 c6                	cmp    %eax,%esi
  800b74:	73 35                	jae    800bab <memmove+0x47>
  800b76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b79:	39 d0                	cmp    %edx,%eax
  800b7b:	73 2e                	jae    800bab <memmove+0x47>
		s += n;
		d += n;
  800b7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	09 fe                	or     %edi,%esi
  800b84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8a:	75 13                	jne    800b9f <memmove+0x3b>
  800b8c:	f6 c1 03             	test   $0x3,%cl
  800b8f:	75 0e                	jne    800b9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b91:	83 ef 04             	sub    $0x4,%edi
  800b94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b97:	c1 e9 02             	shr    $0x2,%ecx
  800b9a:	fd                   	std    
  800b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9d:	eb 09                	jmp    800ba8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9f:	83 ef 01             	sub    $0x1,%edi
  800ba2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba5:	fd                   	std    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba8:	fc                   	cld    
  800ba9:	eb 1d                	jmp    800bc8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bab:	89 f2                	mov    %esi,%edx
  800bad:	09 c2                	or     %eax,%edx
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 0f                	jne    800bc3 <memmove+0x5f>
  800bb4:	f6 c1 03             	test   $0x3,%cl
  800bb7:	75 0a                	jne    800bc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb9:	c1 e9 02             	shr    $0x2,%ecx
  800bbc:	89 c7                	mov    %eax,%edi
  800bbe:	fc                   	cld    
  800bbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc1:	eb 05                	jmp    800bc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc3:	89 c7                	mov    %eax,%edi
  800bc5:	fc                   	cld    
  800bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcf:	ff 75 10             	pushl  0x10(%ebp)
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	ff 75 08             	pushl  0x8(%ebp)
  800bd8:	e8 87 ff ff ff       	call   800b64 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bea:	89 c6                	mov    %eax,%esi
  800bec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	eb 1a                	jmp    800c0b <memcmp+0x2c>
		if (*s1 != *s2)
  800bf1:	0f b6 08             	movzbl (%eax),%ecx
  800bf4:	0f b6 1a             	movzbl (%edx),%ebx
  800bf7:	38 d9                	cmp    %bl,%cl
  800bf9:	74 0a                	je     800c05 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bfb:	0f b6 c1             	movzbl %cl,%eax
  800bfe:	0f b6 db             	movzbl %bl,%ebx
  800c01:	29 d8                	sub    %ebx,%eax
  800c03:	eb 0f                	jmp    800c14 <memcmp+0x35>
		s1++, s2++;
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0b:	39 f0                	cmp    %esi,%eax
  800c0d:	75 e2                	jne    800bf1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	53                   	push   %ebx
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1f:	89 c1                	mov    %eax,%ecx
  800c21:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c28:	eb 0a                	jmp    800c34 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	0f b6 10             	movzbl (%eax),%edx
  800c2d:	39 da                	cmp    %ebx,%edx
  800c2f:	74 07                	je     800c38 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c31:	83 c0 01             	add    $0x1,%eax
  800c34:	39 c8                	cmp    %ecx,%eax
  800c36:	72 f2                	jb     800c2a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c38:	5b                   	pop    %ebx
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c47:	eb 03                	jmp    800c4c <strtol+0x11>
		s++;
  800c49:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4c:	0f b6 01             	movzbl (%ecx),%eax
  800c4f:	3c 20                	cmp    $0x20,%al
  800c51:	74 f6                	je     800c49 <strtol+0xe>
  800c53:	3c 09                	cmp    $0x9,%al
  800c55:	74 f2                	je     800c49 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c57:	3c 2b                	cmp    $0x2b,%al
  800c59:	75 0a                	jne    800c65 <strtol+0x2a>
		s++;
  800c5b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	eb 11                	jmp    800c76 <strtol+0x3b>
  800c65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c6a:	3c 2d                	cmp    $0x2d,%al
  800c6c:	75 08                	jne    800c76 <strtol+0x3b>
		s++, neg = 1;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c76:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7c:	75 15                	jne    800c93 <strtol+0x58>
  800c7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c81:	75 10                	jne    800c93 <strtol+0x58>
  800c83:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c87:	75 7c                	jne    800d05 <strtol+0xca>
		s += 2, base = 16;
  800c89:	83 c1 02             	add    $0x2,%ecx
  800c8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c91:	eb 16                	jmp    800ca9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c93:	85 db                	test   %ebx,%ebx
  800c95:	75 12                	jne    800ca9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c97:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9f:	75 08                	jne    800ca9 <strtol+0x6e>
		s++, base = 8;
  800ca1:	83 c1 01             	add    $0x1,%ecx
  800ca4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cae:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb1:	0f b6 11             	movzbl (%ecx),%edx
  800cb4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	80 fb 09             	cmp    $0x9,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0x8b>
			dig = *s - '0';
  800cbe:	0f be d2             	movsbl %dl,%edx
  800cc1:	83 ea 30             	sub    $0x30,%edx
  800cc4:	eb 22                	jmp    800ce8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc9:	89 f3                	mov    %esi,%ebx
  800ccb:	80 fb 19             	cmp    $0x19,%bl
  800cce:	77 08                	ja     800cd8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cd0:	0f be d2             	movsbl %dl,%edx
  800cd3:	83 ea 57             	sub    $0x57,%edx
  800cd6:	eb 10                	jmp    800ce8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdb:	89 f3                	mov    %esi,%ebx
  800cdd:	80 fb 19             	cmp    $0x19,%bl
  800ce0:	77 16                	ja     800cf8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce2:	0f be d2             	movsbl %dl,%edx
  800ce5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ceb:	7d 0b                	jge    800cf8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ced:	83 c1 01             	add    $0x1,%ecx
  800cf0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf6:	eb b9                	jmp    800cb1 <strtol+0x76>

	if (endptr)
  800cf8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfc:	74 0d                	je     800d0b <strtol+0xd0>
		*endptr = (char *) s;
  800cfe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d01:	89 0e                	mov    %ecx,(%esi)
  800d03:	eb 06                	jmp    800d0b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d05:	85 db                	test   %ebx,%ebx
  800d07:	74 98                	je     800ca1 <strtol+0x66>
  800d09:	eb 9e                	jmp    800ca9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	f7 da                	neg    %edx
  800d0f:	85 ff                	test   %edi,%edi
  800d11:	0f 45 c2             	cmovne %edx,%eax
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

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
