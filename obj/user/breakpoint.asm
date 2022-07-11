
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 08             	sub    $0x8,%esp
  80003f:	8b 45 08             	mov    0x8(%ebp),%eax
  800042:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80004f:	85 c0                	test   %eax,%eax
  800051:	7e 08                	jle    80005b <libmain+0x22>
		binaryname = argv[0];
  800053:	8b 0a                	mov    (%edx),%ecx
  800055:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005b:	83 ec 08             	sub    $0x8,%esp
  80005e:	52                   	push   %edx
  80005f:	50                   	push   %eax
  800060:	e8 ce ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800065:	e8 05 00 00 00       	call   80006f <exit>
}
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800075:	6a 00                	push   $0x0
  800077:	e8 42 00 00 00       	call   8000be <sys_env_destroy>
}
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	57                   	push   %edi
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
  80008c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008f:	8b 55 08             	mov    0x8(%ebp),%edx
  800092:	89 c3                	mov    %eax,%ebx
  800094:	89 c7                	mov    %eax,%edi
  800096:	89 c6                	mov    %eax,%esi
  800098:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5f                   	pop    %edi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <sys_cgetc>:

int
sys_cgetc(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000af:	89 d1                	mov    %edx,%ecx
  8000b1:	89 d3                	mov    %edx,%ebx
  8000b3:	89 d7                	mov    %edx,%edi
  8000b5:	89 d6                	mov    %edx,%esi
  8000b7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	89 cb                	mov    %ecx,%ebx
  8000d6:	89 cf                	mov    %ecx,%edi
  8000d8:	89 ce                	mov    %ecx,%esi
  8000da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	7e 17                	jle    8000f7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	50                   	push   %eax
  8000e4:	6a 03                	push   $0x3
  8000e6:	68 aa 0f 80 00       	push   $0x800faa
  8000eb:	6a 23                	push   $0x23
  8000ed:	68 c7 0f 80 00       	push   $0x800fc7
  8000f2:	e8 f5 01 00 00       	call   8002ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 02 00 00 00       	mov    $0x2,%eax
  80010f:	89 d1                	mov    %edx,%ecx
  800111:	89 d3                	mov    %edx,%ebx
  800113:	89 d7                	mov    %edx,%edi
  800115:	89 d6                	mov    %edx,%esi
  800117:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_yield>:

void
sys_yield(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 0a 00 00 00       	mov    $0xa,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	be 00 00 00 00       	mov    $0x0,%esi
  80014b:	b8 04 00 00 00       	mov    $0x4,%eax
  800150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
  800156:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800159:	89 f7                	mov    %esi,%edi
  80015b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80015d:	85 c0                	test   %eax,%eax
  80015f:	7e 17                	jle    800178 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	50                   	push   %eax
  800165:	6a 04                	push   $0x4
  800167:	68 aa 0f 80 00       	push   $0x800faa
  80016c:	6a 23                	push   $0x23
  80016e:	68 c7 0f 80 00       	push   $0x800fc7
  800173:	e8 74 01 00 00       	call   8002ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800189:	b8 05 00 00 00       	mov    $0x5,%eax
  80018e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019a:	8b 75 18             	mov    0x18(%ebp),%esi
  80019d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	7e 17                	jle    8001ba <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	50                   	push   %eax
  8001a7:	6a 05                	push   $0x5
  8001a9:	68 aa 0f 80 00       	push   $0x800faa
  8001ae:	6a 23                	push   $0x23
  8001b0:	68 c7 0f 80 00       	push   $0x800fc7
  8001b5:	e8 32 01 00 00       	call   8002ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	57                   	push   %edi
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	89 df                	mov    %ebx,%edi
  8001dd:	89 de                	mov    %ebx,%esi
  8001df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e1:	85 c0                	test   %eax,%eax
  8001e3:	7e 17                	jle    8001fc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	50                   	push   %eax
  8001e9:	6a 06                	push   $0x6
  8001eb:	68 aa 0f 80 00       	push   $0x800faa
  8001f0:	6a 23                	push   $0x23
  8001f2:	68 c7 0f 80 00       	push   $0x800fc7
  8001f7:	e8 f0 00 00 00       	call   8002ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800212:	b8 08 00 00 00       	mov    $0x8,%eax
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	89 df                	mov    %ebx,%edi
  80021f:	89 de                	mov    %ebx,%esi
  800221:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800223:	85 c0                	test   %eax,%eax
  800225:	7e 17                	jle    80023e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	50                   	push   %eax
  80022b:	6a 08                	push   $0x8
  80022d:	68 aa 0f 80 00       	push   $0x800faa
  800232:	6a 23                	push   $0x23
  800234:	68 c7 0f 80 00       	push   $0x800fc7
  800239:	e8 ae 00 00 00       	call   8002ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800254:	b8 09 00 00 00       	mov    $0x9,%eax
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
  80025f:	89 df                	mov    %ebx,%edi
  800261:	89 de                	mov    %ebx,%esi
  800263:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800265:	85 c0                	test   %eax,%eax
  800267:	7e 17                	jle    800280 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	50                   	push   %eax
  80026d:	6a 09                	push   $0x9
  80026f:	68 aa 0f 80 00       	push   $0x800faa
  800274:	6a 23                	push   $0x23
  800276:	68 c7 0f 80 00       	push   $0x800fc7
  80027b:	e8 6c 00 00 00       	call   8002ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028e:	be 00 00 00 00       	mov    $0x0,%esi
  800293:	b8 0b 00 00 00       	mov    $0xb,%eax
  800298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002a1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002a4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002be:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c1:	89 cb                	mov    %ecx,%ebx
  8002c3:	89 cf                	mov    %ecx,%edi
  8002c5:	89 ce                	mov    %ecx,%esi
  8002c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c9:	85 c0                	test   %eax,%eax
  8002cb:	7e 17                	jle    8002e4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 0c                	push   $0xc
  8002d3:	68 aa 0f 80 00       	push   $0x800faa
  8002d8:	6a 23                	push   $0x23
  8002da:	68 c7 0f 80 00       	push   $0x800fc7
  8002df:	e8 08 00 00 00       	call   8002ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002fa:	e8 00 fe ff ff       	call   8000ff <sys_getenvid>
  8002ff:	83 ec 0c             	sub    $0xc,%esp
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	56                   	push   %esi
  800309:	50                   	push   %eax
  80030a:	68 d8 0f 80 00       	push   $0x800fd8
  80030f:	e8 b1 00 00 00       	call   8003c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800314:	83 c4 18             	add    $0x18,%esp
  800317:	53                   	push   %ebx
  800318:	ff 75 10             	pushl  0x10(%ebp)
  80031b:	e8 54 00 00 00       	call   800374 <vcprintf>
	cprintf("\n");
  800320:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800327:	e8 99 00 00 00       	call   8003c5 <cprintf>
  80032c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032f:	cc                   	int3   
  800330:	eb fd                	jmp    80032f <_panic+0x43>

00800332 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	53                   	push   %ebx
  800336:	83 ec 04             	sub    $0x4,%esp
  800339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033c:	8b 13                	mov    (%ebx),%edx
  80033e:	8d 42 01             	lea    0x1(%edx),%eax
  800341:	89 03                	mov    %eax,(%ebx)
  800343:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800346:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80034f:	75 1a                	jne    80036b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	68 ff 00 00 00       	push   $0xff
  800359:	8d 43 08             	lea    0x8(%ebx),%eax
  80035c:	50                   	push   %eax
  80035d:	e8 1f fd ff ff       	call   800081 <sys_cputs>
		b->idx = 0;
  800362:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800368:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80036b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80037d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800384:	00 00 00 
	b.cnt = 0;
  800387:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80038e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800391:	ff 75 0c             	pushl  0xc(%ebp)
  800394:	ff 75 08             	pushl  0x8(%ebp)
  800397:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039d:	50                   	push   %eax
  80039e:	68 32 03 80 00       	push   $0x800332
  8003a3:	e8 1a 01 00 00       	call   8004c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a8:	83 c4 08             	add    $0x8,%esp
  8003ab:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 c4 fc ff ff       	call   800081 <sys_cputs>

	return b.cnt;
}
  8003bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ce:	50                   	push   %eax
  8003cf:	ff 75 08             	pushl  0x8(%ebp)
  8003d2:	e8 9d ff ff ff       	call   800374 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d7:	c9                   	leave  
  8003d8:	c3                   	ret    

008003d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	57                   	push   %edi
  8003dd:	56                   	push   %esi
  8003de:	53                   	push   %ebx
  8003df:	83 ec 1c             	sub    $0x1c,%esp
  8003e2:	89 c7                	mov    %eax,%edi
  8003e4:	89 d6                	mov    %edx,%esi
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800400:	39 d3                	cmp    %edx,%ebx
  800402:	72 05                	jb     800409 <printnum+0x30>
  800404:	39 45 10             	cmp    %eax,0x10(%ebp)
  800407:	77 45                	ja     80044e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800409:	83 ec 0c             	sub    $0xc,%esp
  80040c:	ff 75 18             	pushl  0x18(%ebp)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800415:	53                   	push   %ebx
  800416:	ff 75 10             	pushl  0x10(%ebp)
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041f:	ff 75 e0             	pushl  -0x20(%ebp)
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	e8 e3 08 00 00       	call   800d10 <__udivdi3>
  80042d:	83 c4 18             	add    $0x18,%esp
  800430:	52                   	push   %edx
  800431:	50                   	push   %eax
  800432:	89 f2                	mov    %esi,%edx
  800434:	89 f8                	mov    %edi,%eax
  800436:	e8 9e ff ff ff       	call   8003d9 <printnum>
  80043b:	83 c4 20             	add    $0x20,%esp
  80043e:	eb 18                	jmp    800458 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	56                   	push   %esi
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	ff d7                	call   *%edi
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	eb 03                	jmp    800451 <printnum+0x78>
  80044e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800451:	83 eb 01             	sub    $0x1,%ebx
  800454:	85 db                	test   %ebx,%ebx
  800456:	7f e8                	jg     800440 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	56                   	push   %esi
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800462:	ff 75 e0             	pushl  -0x20(%ebp)
  800465:	ff 75 dc             	pushl  -0x24(%ebp)
  800468:	ff 75 d8             	pushl  -0x28(%ebp)
  80046b:	e8 d0 09 00 00       	call   800e40 <__umoddi3>
  800470:	83 c4 14             	add    $0x14,%esp
  800473:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  80047a:	50                   	push   %eax
  80047b:	ff d7                	call   *%edi
}
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800483:	5b                   	pop    %ebx
  800484:	5e                   	pop    %esi
  800485:	5f                   	pop    %edi
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800492:	8b 10                	mov    (%eax),%edx
  800494:	3b 50 04             	cmp    0x4(%eax),%edx
  800497:	73 0a                	jae    8004a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  800499:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049c:	89 08                	mov    %ecx,(%eax)
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	88 02                	mov    %al,(%edx)
}
  8004a3:	5d                   	pop    %ebp
  8004a4:	c3                   	ret    

008004a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ae:	50                   	push   %eax
  8004af:	ff 75 10             	pushl  0x10(%ebp)
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 05 00 00 00       	call   8004c2 <vprintfmt>
	va_end(ap);
}
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	57                   	push   %edi
  8004c6:	56                   	push   %esi
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 2c             	sub    $0x2c,%esp
  8004cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004d4:	eb 12                	jmp    8004e8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	0f 84 42 04 00 00    	je     800920 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	50                   	push   %eax
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e8:	83 c7 01             	add    $0x1,%edi
  8004eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ef:	83 f8 25             	cmp    $0x25,%eax
  8004f2:	75 e2                	jne    8004d6 <vprintfmt+0x14>
  8004f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800506:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80050d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800512:	eb 07                	jmp    80051b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800517:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8d 47 01             	lea    0x1(%edi),%eax
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	0f b6 07             	movzbl (%edi),%eax
  800524:	0f b6 d0             	movzbl %al,%edx
  800527:	83 e8 23             	sub    $0x23,%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 d3 03 00 00    	ja     800905 <vprintfmt+0x443>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800543:	eb d6                	jmp    80051b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800548:	b8 00 00 00 00       	mov    $0x0,%eax
  80054d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800550:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800553:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800557:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80055d:	83 f9 09             	cmp    $0x9,%ecx
  800560:	77 3f                	ja     8005a1 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800562:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800565:	eb e9                	jmp    800550 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80057b:	eb 2a                	jmp    8005a7 <vprintfmt+0xe5>
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	85 c0                	test   %eax,%eax
  800582:	ba 00 00 00 00       	mov    $0x0,%edx
  800587:	0f 49 d0             	cmovns %eax,%edx
  80058a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	eb 89                	jmp    80051b <vprintfmt+0x59>
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800595:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80059c:	e9 7a ff ff ff       	jmp    80051b <vprintfmt+0x59>
  8005a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ab:	0f 89 6a ff ff ff    	jns    80051b <vprintfmt+0x59>
				width = precision, precision = -1;
  8005b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005be:	e9 58 ff ff ff       	jmp    80051b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c9:	e9 4d ff ff ff       	jmp    80051b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 78 04             	lea    0x4(%eax),%edi
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	ff 30                	pushl  (%eax)
  8005da:	ff d6                	call   *%esi
			break;
  8005dc:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005df:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e5:	e9 fe fe ff ff       	jmp    8004e8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 78 04             	lea    0x4(%eax),%edi
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	99                   	cltd   
  8005f3:	31 d0                	xor    %edx,%eax
  8005f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f7:	83 f8 09             	cmp    $0x9,%eax
  8005fa:	7f 0b                	jg     800607 <vprintfmt+0x145>
  8005fc:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	75 1b                	jne    800622 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800607:	50                   	push   %eax
  800608:	68 16 10 80 00       	push   $0x801016
  80060d:	53                   	push   %ebx
  80060e:	56                   	push   %esi
  80060f:	e8 91 fe ff ff       	call   8004a5 <printfmt>
  800614:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800617:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061d:	e9 c6 fe ff ff       	jmp    8004e8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800622:	52                   	push   %edx
  800623:	68 1f 10 80 00       	push   $0x80101f
  800628:	53                   	push   %ebx
  800629:	56                   	push   %esi
  80062a:	e8 76 fe ff ff       	call   8004a5 <printfmt>
  80062f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800632:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	e9 ab fe ff ff       	jmp    8004e8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	83 c0 04             	add    $0x4,%eax
  800643:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80064b:	85 ff                	test   %edi,%edi
  80064d:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  800652:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800655:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800659:	0f 8e 94 00 00 00    	jle    8006f3 <vprintfmt+0x231>
  80065f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800663:	0f 84 98 00 00 00    	je     800701 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	ff 75 d0             	pushl  -0x30(%ebp)
  80066f:	57                   	push   %edi
  800670:	e8 33 03 00 00       	call   8009a8 <strnlen>
  800675:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800678:	29 c1                	sub    %eax,%ecx
  80067a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800680:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800684:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800687:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068c:	eb 0f                	jmp    80069d <vprintfmt+0x1db>
					putch(padc, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	ff 75 e0             	pushl  -0x20(%ebp)
  800695:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	83 ef 01             	sub    $0x1,%edi
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 ff                	test   %edi,%edi
  80069f:	7f ed                	jg     80068e <vprintfmt+0x1cc>
  8006a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ae:	0f 49 c1             	cmovns %ecx,%eax
  8006b1:	29 c1                	sub    %eax,%ecx
  8006b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bc:	89 cb                	mov    %ecx,%ebx
  8006be:	eb 4d                	jmp    80070d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c4:	74 1b                	je     8006e1 <vprintfmt+0x21f>
  8006c6:	0f be c0             	movsbl %al,%eax
  8006c9:	83 e8 20             	sub    $0x20,%eax
  8006cc:	83 f8 5e             	cmp    $0x5e,%eax
  8006cf:	76 10                	jbe    8006e1 <vprintfmt+0x21f>
					putch('?', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	ff 75 0c             	pushl  0xc(%ebp)
  8006d7:	6a 3f                	push   $0x3f
  8006d9:	ff 55 08             	call   *0x8(%ebp)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 0d                	jmp    8006ee <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	52                   	push   %edx
  8006e8:	ff 55 08             	call   *0x8(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	83 eb 01             	sub    $0x1,%ebx
  8006f1:	eb 1a                	jmp    80070d <vprintfmt+0x24b>
  8006f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ff:	eb 0c                	jmp    80070d <vprintfmt+0x24b>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	83 c7 01             	add    $0x1,%edi
  800710:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800714:	0f be d0             	movsbl %al,%edx
  800717:	85 d2                	test   %edx,%edx
  800719:	74 23                	je     80073e <vprintfmt+0x27c>
  80071b:	85 f6                	test   %esi,%esi
  80071d:	78 a1                	js     8006c0 <vprintfmt+0x1fe>
  80071f:	83 ee 01             	sub    $0x1,%esi
  800722:	79 9c                	jns    8006c0 <vprintfmt+0x1fe>
  800724:	89 df                	mov    %ebx,%edi
  800726:	8b 75 08             	mov    0x8(%ebp),%esi
  800729:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072c:	eb 18                	jmp    800746 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 20                	push   $0x20
  800734:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800736:	83 ef 01             	sub    $0x1,%edi
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 08                	jmp    800746 <vprintfmt+0x284>
  80073e:	89 df                	mov    %ebx,%edi
  800740:	8b 75 08             	mov    0x8(%ebp),%esi
  800743:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800746:	85 ff                	test   %edi,%edi
  800748:	7f e4                	jg     80072e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800753:	e9 90 fd ff ff       	jmp    8004e8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800758:	83 f9 01             	cmp    $0x1,%ecx
  80075b:	7e 19                	jle    800776 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 50 04             	mov    0x4(%eax),%edx
  800763:	8b 00                	mov    (%eax),%eax
  800765:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800768:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 40 08             	lea    0x8(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
  800774:	eb 38                	jmp    8007ae <vprintfmt+0x2ec>
	else if (lflag)
  800776:	85 c9                	test   %ecx,%ecx
  800778:	74 1b                	je     800795 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800782:	89 c1                	mov    %eax,%ecx
  800784:	c1 f9 1f             	sar    $0x1f,%ecx
  800787:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
  800793:	eb 19                	jmp    8007ae <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079d:	89 c1                	mov    %eax,%ecx
  80079f:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 40 04             	lea    0x4(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b4:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bd:	0f 89 0e 01 00 00    	jns    8008d1 <vprintfmt+0x40f>
				putch('-', putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 2d                	push   $0x2d
  8007c9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d1:	f7 da                	neg    %edx
  8007d3:	83 d1 00             	adc    $0x0,%ecx
  8007d6:	f7 d9                	neg    %ecx
  8007d8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e0:	e9 ec 00 00 00       	jmp    8008d1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e5:	83 f9 01             	cmp    $0x1,%ecx
  8007e8:	7e 18                	jle    800802 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f2:	8d 40 08             	lea    0x8(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fd:	e9 cf 00 00 00       	jmp    8008d1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800802:	85 c9                	test   %ecx,%ecx
  800804:	74 1a                	je     800820 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	e9 b1 00 00 00       	jmp    8008d1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 10                	mov    (%eax),%edx
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	8d 40 04             	lea    0x4(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
  800835:	e9 97 00 00 00       	jmp    8008d1 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	53                   	push   %ebx
  80083e:	6a 58                	push   $0x58
  800840:	ff d6                	call   *%esi
			putch('X', putdat);
  800842:	83 c4 08             	add    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 58                	push   $0x58
  800848:	ff d6                	call   *%esi
			putch('X', putdat);
  80084a:	83 c4 08             	add    $0x8,%esp
  80084d:	53                   	push   %ebx
  80084e:	6a 58                	push   $0x58
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800858:	e9 8b fc ff ff       	jmp    8004e8 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 30                	push   $0x30
  800863:	ff d6                	call   *%esi
			putch('x', putdat);
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 78                	push   $0x78
  80086b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800877:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087a:	8d 40 04             	lea    0x4(%eax),%eax
  80087d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800880:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800885:	eb 4a                	jmp    8008d1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800887:	83 f9 01             	cmp    $0x1,%ecx
  80088a:	7e 15                	jle    8008a1 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	8b 10                	mov    (%eax),%edx
  800891:	8b 48 04             	mov    0x4(%eax),%ecx
  800894:	8d 40 08             	lea    0x8(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80089a:	b8 10 00 00 00       	mov    $0x10,%eax
  80089f:	eb 30                	jmp    8008d1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 17                	je     8008bc <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8b 10                	mov    (%eax),%edx
  8008aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008af:	8d 40 04             	lea    0x4(%eax),%eax
  8008b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ba:	eb 15                	jmp    8008d1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8b 10                	mov    (%eax),%edx
  8008c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c6:	8d 40 04             	lea    0x4(%eax),%eax
  8008c9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008cc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d8:	57                   	push   %edi
  8008d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008dc:	50                   	push   %eax
  8008dd:	51                   	push   %ecx
  8008de:	52                   	push   %edx
  8008df:	89 da                	mov    %ebx,%edx
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	e8 f1 fa ff ff       	call   8003d9 <printnum>
			break;
  8008e8:	83 c4 20             	add    $0x20,%esp
  8008eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ee:	e9 f5 fb ff ff       	jmp    8004e8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	53                   	push   %ebx
  8008f7:	52                   	push   %edx
  8008f8:	ff d6                	call   *%esi
			break;
  8008fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800900:	e9 e3 fb ff ff       	jmp    8004e8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	53                   	push   %ebx
  800909:	6a 25                	push   $0x25
  80090b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	eb 03                	jmp    800915 <vprintfmt+0x453>
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800919:	75 f7                	jne    800912 <vprintfmt+0x450>
  80091b:	e9 c8 fb ff ff       	jmp    8004e8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 18             	sub    $0x18,%esp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800937:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800945:	85 c0                	test   %eax,%eax
  800947:	74 26                	je     80096f <vsnprintf+0x47>
  800949:	85 d2                	test   %edx,%edx
  80094b:	7e 22                	jle    80096f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094d:	ff 75 14             	pushl  0x14(%ebp)
  800950:	ff 75 10             	pushl  0x10(%ebp)
  800953:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800956:	50                   	push   %eax
  800957:	68 88 04 80 00       	push   $0x800488
  80095c:	e8 61 fb ff ff       	call   8004c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800964:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096a:	83 c4 10             	add    $0x10,%esp
  80096d:	eb 05                	jmp    800974 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097f:	50                   	push   %eax
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	ff 75 08             	pushl  0x8(%ebp)
  800989:	e8 9a ff ff ff       	call   800928 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	eb 03                	jmp    8009a0 <strlen+0x10>
		n++;
  80099d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a4:	75 f7                	jne    80099d <strlen+0xd>
		n++;
	return n;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	eb 03                	jmp    8009bb <strnlen+0x13>
		n++;
  8009b8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bb:	39 c2                	cmp    %eax,%edx
  8009bd:	74 08                	je     8009c7 <strnlen+0x1f>
  8009bf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c3:	75 f3                	jne    8009b8 <strnlen+0x10>
  8009c5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009df:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	75 ef                	jne    8009d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f0:	53                   	push   %ebx
  8009f1:	e8 9a ff ff ff       	call   800990 <strlen>
  8009f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f9:	ff 75 0c             	pushl  0xc(%ebp)
  8009fc:	01 d8                	add    %ebx,%eax
  8009fe:	50                   	push   %eax
  8009ff:	e8 c5 ff ff ff       	call   8009c9 <strcpy>
	return dst;
}
  800a04:	89 d8                	mov    %ebx,%eax
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 75 08             	mov    0x8(%ebp),%esi
  800a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1b:	89 f2                	mov    %esi,%edx
  800a1d:	eb 0f                	jmp    800a2e <strncpy+0x23>
		*dst++ = *src;
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	0f b6 01             	movzbl (%ecx),%eax
  800a25:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a28:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2e:	39 da                	cmp    %ebx,%edx
  800a30:	75 ed                	jne    800a1f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a32:	89 f0                	mov    %esi,%eax
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	8b 55 10             	mov    0x10(%ebp),%edx
  800a46:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a48:	85 d2                	test   %edx,%edx
  800a4a:	74 21                	je     800a6d <strlcpy+0x35>
  800a4c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a50:	89 f2                	mov    %esi,%edx
  800a52:	eb 09                	jmp    800a5d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a54:	83 c2 01             	add    $0x1,%edx
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5d:	39 c2                	cmp    %eax,%edx
  800a5f:	74 09                	je     800a6a <strlcpy+0x32>
  800a61:	0f b6 19             	movzbl (%ecx),%ebx
  800a64:	84 db                	test   %bl,%bl
  800a66:	75 ec                	jne    800a54 <strlcpy+0x1c>
  800a68:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6d:	29 f0                	sub    %esi,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7c:	eb 06                	jmp    800a84 <strcmp+0x11>
		p++, q++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a84:	0f b6 01             	movzbl (%ecx),%eax
  800a87:	84 c0                	test   %al,%al
  800a89:	74 04                	je     800a8f <strcmp+0x1c>
  800a8b:	3a 02                	cmp    (%edx),%al
  800a8d:	74 ef                	je     800a7e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8f:	0f b6 c0             	movzbl %al,%eax
  800a92:	0f b6 12             	movzbl (%edx),%edx
  800a95:	29 d0                	sub    %edx,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa8:	eb 06                	jmp    800ab0 <strncmp+0x17>
		n--, p++, q++;
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab0:	39 d8                	cmp    %ebx,%eax
  800ab2:	74 15                	je     800ac9 <strncmp+0x30>
  800ab4:	0f b6 08             	movzbl (%eax),%ecx
  800ab7:	84 c9                	test   %cl,%cl
  800ab9:	74 04                	je     800abf <strncmp+0x26>
  800abb:	3a 0a                	cmp    (%edx),%cl
  800abd:	74 eb                	je     800aaa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abf:	0f b6 00             	movzbl (%eax),%eax
  800ac2:	0f b6 12             	movzbl (%edx),%edx
  800ac5:	29 d0                	sub    %edx,%eax
  800ac7:	eb 05                	jmp    800ace <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adb:	eb 07                	jmp    800ae4 <strchr+0x13>
		if (*s == c)
  800add:	38 ca                	cmp    %cl,%dl
  800adf:	74 0f                	je     800af0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae1:	83 c0 01             	add    $0x1,%eax
  800ae4:	0f b6 10             	movzbl (%eax),%edx
  800ae7:	84 d2                	test   %dl,%dl
  800ae9:	75 f2                	jne    800add <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afc:	eb 03                	jmp    800b01 <strfind+0xf>
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b04:	38 ca                	cmp    %cl,%dl
  800b06:	74 04                	je     800b0c <strfind+0x1a>
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	75 f2                	jne    800afe <strfind+0xc>
			break;
	return (char *) s;
}
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1a:	85 c9                	test   %ecx,%ecx
  800b1c:	74 36                	je     800b54 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b24:	75 28                	jne    800b4e <memset+0x40>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 23                	jne    800b4e <memset+0x40>
		c &= 0xFF;
  800b2b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	c1 e3 08             	shl    $0x8,%ebx
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	c1 e6 18             	shl    $0x18,%esi
  800b39:	89 d0                	mov    %edx,%eax
  800b3b:	c1 e0 10             	shl    $0x10,%eax
  800b3e:	09 f0                	or     %esi,%eax
  800b40:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b42:	89 d8                	mov    %ebx,%eax
  800b44:	09 d0                	or     %edx,%eax
  800b46:	c1 e9 02             	shr    $0x2,%ecx
  800b49:	fc                   	cld    
  800b4a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4c:	eb 06                	jmp    800b54 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	fc                   	cld    
  800b52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b54:	89 f8                	mov    %edi,%eax
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b69:	39 c6                	cmp    %eax,%esi
  800b6b:	73 35                	jae    800ba2 <memmove+0x47>
  800b6d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b70:	39 d0                	cmp    %edx,%eax
  800b72:	73 2e                	jae    800ba2 <memmove+0x47>
		s += n;
		d += n;
  800b74:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	09 fe                	or     %edi,%esi
  800b7b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b81:	75 13                	jne    800b96 <memmove+0x3b>
  800b83:	f6 c1 03             	test   $0x3,%cl
  800b86:	75 0e                	jne    800b96 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b88:	83 ef 04             	sub    $0x4,%edi
  800b8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8e:	c1 e9 02             	shr    $0x2,%ecx
  800b91:	fd                   	std    
  800b92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b94:	eb 09                	jmp    800b9f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b96:	83 ef 01             	sub    $0x1,%edi
  800b99:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9c:	fd                   	std    
  800b9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9f:	fc                   	cld    
  800ba0:	eb 1d                	jmp    800bbf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba2:	89 f2                	mov    %esi,%edx
  800ba4:	09 c2                	or     %eax,%edx
  800ba6:	f6 c2 03             	test   $0x3,%dl
  800ba9:	75 0f                	jne    800bba <memmove+0x5f>
  800bab:	f6 c1 03             	test   $0x3,%cl
  800bae:	75 0a                	jne    800bba <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb0:	c1 e9 02             	shr    $0x2,%ecx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	fc                   	cld    
  800bb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb8:	eb 05                	jmp    800bbf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bba:	89 c7                	mov    %eax,%edi
  800bbc:	fc                   	cld    
  800bbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc6:	ff 75 10             	pushl  0x10(%ebp)
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	ff 75 08             	pushl  0x8(%ebp)
  800bcf:	e8 87 ff ff ff       	call   800b5b <memmove>
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be1:	89 c6                	mov    %eax,%esi
  800be3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be6:	eb 1a                	jmp    800c02 <memcmp+0x2c>
		if (*s1 != *s2)
  800be8:	0f b6 08             	movzbl (%eax),%ecx
  800beb:	0f b6 1a             	movzbl (%edx),%ebx
  800bee:	38 d9                	cmp    %bl,%cl
  800bf0:	74 0a                	je     800bfc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf2:	0f b6 c1             	movzbl %cl,%eax
  800bf5:	0f b6 db             	movzbl %bl,%ebx
  800bf8:	29 d8                	sub    %ebx,%eax
  800bfa:	eb 0f                	jmp    800c0b <memcmp+0x35>
		s1++, s2++;
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c02:	39 f0                	cmp    %esi,%eax
  800c04:	75 e2                	jne    800be8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	53                   	push   %ebx
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c16:	89 c1                	mov    %eax,%ecx
  800c18:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1f:	eb 0a                	jmp    800c2b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c21:	0f b6 10             	movzbl (%eax),%edx
  800c24:	39 da                	cmp    %ebx,%edx
  800c26:	74 07                	je     800c2f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c28:	83 c0 01             	add    $0x1,%eax
  800c2b:	39 c8                	cmp    %ecx,%eax
  800c2d:	72 f2                	jb     800c21 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3e:	eb 03                	jmp    800c43 <strtol+0x11>
		s++;
  800c40:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	0f b6 01             	movzbl (%ecx),%eax
  800c46:	3c 20                	cmp    $0x20,%al
  800c48:	74 f6                	je     800c40 <strtol+0xe>
  800c4a:	3c 09                	cmp    $0x9,%al
  800c4c:	74 f2                	je     800c40 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4e:	3c 2b                	cmp    $0x2b,%al
  800c50:	75 0a                	jne    800c5c <strtol+0x2a>
		s++;
  800c52:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5a:	eb 11                	jmp    800c6d <strtol+0x3b>
  800c5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c61:	3c 2d                	cmp    $0x2d,%al
  800c63:	75 08                	jne    800c6d <strtol+0x3b>
		s++, neg = 1;
  800c65:	83 c1 01             	add    $0x1,%ecx
  800c68:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c73:	75 15                	jne    800c8a <strtol+0x58>
  800c75:	80 39 30             	cmpb   $0x30,(%ecx)
  800c78:	75 10                	jne    800c8a <strtol+0x58>
  800c7a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7e:	75 7c                	jne    800cfc <strtol+0xca>
		s += 2, base = 16;
  800c80:	83 c1 02             	add    $0x2,%ecx
  800c83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c88:	eb 16                	jmp    800ca0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8a:	85 db                	test   %ebx,%ebx
  800c8c:	75 12                	jne    800ca0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c93:	80 39 30             	cmpb   $0x30,(%ecx)
  800c96:	75 08                	jne    800ca0 <strtol+0x6e>
		s++, base = 8;
  800c98:	83 c1 01             	add    $0x1,%ecx
  800c9b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca8:	0f b6 11             	movzbl (%ecx),%edx
  800cab:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cae:	89 f3                	mov    %esi,%ebx
  800cb0:	80 fb 09             	cmp    $0x9,%bl
  800cb3:	77 08                	ja     800cbd <strtol+0x8b>
			dig = *s - '0';
  800cb5:	0f be d2             	movsbl %dl,%edx
  800cb8:	83 ea 30             	sub    $0x30,%edx
  800cbb:	eb 22                	jmp    800cdf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cbd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc0:	89 f3                	mov    %esi,%ebx
  800cc2:	80 fb 19             	cmp    $0x19,%bl
  800cc5:	77 08                	ja     800ccf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc7:	0f be d2             	movsbl %dl,%edx
  800cca:	83 ea 57             	sub    $0x57,%edx
  800ccd:	eb 10                	jmp    800cdf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ccf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd2:	89 f3                	mov    %esi,%ebx
  800cd4:	80 fb 19             	cmp    $0x19,%bl
  800cd7:	77 16                	ja     800cef <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd9:	0f be d2             	movsbl %dl,%edx
  800cdc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cdf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce2:	7d 0b                	jge    800cef <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce4:	83 c1 01             	add    $0x1,%ecx
  800ce7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ceb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ced:	eb b9                	jmp    800ca8 <strtol+0x76>

	if (endptr)
  800cef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf3:	74 0d                	je     800d02 <strtol+0xd0>
		*endptr = (char *) s;
  800cf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf8:	89 0e                	mov    %ecx,(%esi)
  800cfa:	eb 06                	jmp    800d02 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	74 98                	je     800c98 <strtol+0x66>
  800d00:	eb 9e                	jmp    800ca0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	f7 da                	neg    %edx
  800d06:	85 ff                	test   %edi,%edi
  800d08:	0f 45 c2             	cmovne %edx,%eax
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
