
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	83 ec 08             	sub    $0x8,%esp
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800046:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800050:	85 c0                	test   %eax,%eax
  800052:	7e 08                	jle    80005c <libmain+0x22>
		binaryname = argv[0];
  800054:	8b 0a                	mov    (%edx),%ecx
  800056:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	52                   	push   %edx
  800060:	50                   	push   %eax
  800061:	e8 cd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800066:	e8 05 00 00 00       	call   800070 <exit>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800076:	6a 00                	push   $0x0
  800078:	e8 42 00 00 00       	call   8000bf <sys_env_destroy>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	c9                   	leave  
  800081:	c3                   	ret    

00800082 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800088:	b8 00 00 00 00       	mov    $0x0,%eax
  80008d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800090:	8b 55 08             	mov    0x8(%ebp),%edx
  800093:	89 c3                	mov    %eax,%ebx
  800095:	89 c7                	mov    %eax,%edi
  800097:	89 c6                	mov    %eax,%esi
  800099:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5f                   	pop    %edi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b0:	89 d1                	mov    %edx,%ecx
  8000b2:	89 d3                	mov    %edx,%ebx
  8000b4:	89 d7                	mov    %edx,%edi
  8000b6:	89 d6                	mov    %edx,%esi
  8000b8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 cb                	mov    %ecx,%ebx
  8000d7:	89 cf                	mov    %ecx,%edi
  8000d9:	89 ce                	mov    %ecx,%esi
  8000db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dd:	85 c0                	test   %eax,%eax
  8000df:	7e 17                	jle    8000f8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e1:	83 ec 0c             	sub    $0xc,%esp
  8000e4:	50                   	push   %eax
  8000e5:	6a 03                	push   $0x3
  8000e7:	68 ca 0f 80 00       	push   $0x800fca
  8000ec:	6a 23                	push   $0x23
  8000ee:	68 e7 0f 80 00       	push   $0x800fe7
  8000f3:	e8 f5 01 00 00       	call   8002ed <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
  80010b:	b8 02 00 00 00       	mov    $0x2,%eax
  800110:	89 d1                	mov    %edx,%ecx
  800112:	89 d3                	mov    %edx,%ebx
  800114:	89 d7                	mov    %edx,%edi
  800116:	89 d6                	mov    %edx,%esi
  800118:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_yield>:

void
sys_yield(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800125:	ba 00 00 00 00       	mov    $0x0,%edx
  80012a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80012f:	89 d1                	mov    %edx,%ecx
  800131:	89 d3                	mov    %edx,%ebx
  800133:	89 d7                	mov    %edx,%edi
  800135:	89 d6                	mov    %edx,%esi
  800137:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
  800144:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800147:	be 00 00 00 00       	mov    $0x0,%esi
  80014c:	b8 04 00 00 00       	mov    $0x4,%eax
  800151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80015a:	89 f7                	mov    %esi,%edi
  80015c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80015e:	85 c0                	test   %eax,%eax
  800160:	7e 17                	jle    800179 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	50                   	push   %eax
  800166:	6a 04                	push   $0x4
  800168:	68 ca 0f 80 00       	push   $0x800fca
  80016d:	6a 23                	push   $0x23
  80016f:	68 e7 0f 80 00       	push   $0x800fe7
  800174:	e8 74 01 00 00       	call   8002ed <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	b8 05 00 00 00       	mov    $0x5,%eax
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800198:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019b:	8b 75 18             	mov    0x18(%ebp),%esi
  80019e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	7e 17                	jle    8001bb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	50                   	push   %eax
  8001a8:	6a 05                	push   $0x5
  8001aa:	68 ca 0f 80 00       	push   $0x800fca
  8001af:	6a 23                	push   $0x23
  8001b1:	68 e7 0f 80 00       	push   $0x800fe7
  8001b6:	e8 32 01 00 00       	call   8002ed <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    

008001c3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	57                   	push   %edi
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 df                	mov    %ebx,%edi
  8001de:	89 de                	mov    %ebx,%esi
  8001e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7e 17                	jle    8001fd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	50                   	push   %eax
  8001ea:	6a 06                	push   $0x6
  8001ec:	68 ca 0f 80 00       	push   $0x800fca
  8001f1:	6a 23                	push   $0x23
  8001f3:	68 e7 0f 80 00       	push   $0x800fe7
  8001f8:	e8 f0 00 00 00       	call   8002ed <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5f                   	pop    %edi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    

00800205 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800213:	b8 08 00 00 00       	mov    $0x8,%eax
  800218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021b:	8b 55 08             	mov    0x8(%ebp),%edx
  80021e:	89 df                	mov    %ebx,%edi
  800220:	89 de                	mov    %ebx,%esi
  800222:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	7e 17                	jle    80023f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800228:	83 ec 0c             	sub    $0xc,%esp
  80022b:	50                   	push   %eax
  80022c:	6a 08                	push   $0x8
  80022e:	68 ca 0f 80 00       	push   $0x800fca
  800233:	6a 23                	push   $0x23
  800235:	68 e7 0f 80 00       	push   $0x800fe7
  80023a:	e8 ae 00 00 00       	call   8002ed <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800250:	bb 00 00 00 00       	mov    $0x0,%ebx
  800255:	b8 09 00 00 00       	mov    $0x9,%eax
  80025a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025d:	8b 55 08             	mov    0x8(%ebp),%edx
  800260:	89 df                	mov    %ebx,%edi
  800262:	89 de                	mov    %ebx,%esi
  800264:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800266:	85 c0                	test   %eax,%eax
  800268:	7e 17                	jle    800281 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	50                   	push   %eax
  80026e:	6a 09                	push   $0x9
  800270:	68 ca 0f 80 00       	push   $0x800fca
  800275:	6a 23                	push   $0x23
  800277:	68 e7 0f 80 00       	push   $0x800fe7
  80027c:	e8 6c 00 00 00       	call   8002ed <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028f:	be 00 00 00 00       	mov    $0x0,%esi
  800294:	b8 0b 00 00 00       	mov    $0xb,%eax
  800299:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002a2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002a5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ba:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 cb                	mov    %ecx,%ebx
  8002c4:	89 cf                	mov    %ecx,%edi
  8002c6:	89 ce                	mov    %ecx,%esi
  8002c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	7e 17                	jle    8002e5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	50                   	push   %eax
  8002d2:	6a 0c                	push   $0xc
  8002d4:	68 ca 0f 80 00       	push   $0x800fca
  8002d9:	6a 23                	push   $0x23
  8002db:	68 e7 0f 80 00       	push   $0x800fe7
  8002e0:	e8 08 00 00 00       	call   8002ed <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5f                   	pop    %edi
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002fb:	e8 00 fe ff ff       	call   800100 <sys_getenvid>
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	56                   	push   %esi
  80030a:	50                   	push   %eax
  80030b:	68 f8 0f 80 00       	push   $0x800ff8
  800310:	e8 b1 00 00 00       	call   8003c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800315:	83 c4 18             	add    $0x18,%esp
  800318:	53                   	push   %ebx
  800319:	ff 75 10             	pushl  0x10(%ebp)
  80031c:	e8 54 00 00 00       	call   800375 <vcprintf>
	cprintf("\n");
  800321:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800328:	e8 99 00 00 00       	call   8003c6 <cprintf>
  80032d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800330:	cc                   	int3   
  800331:	eb fd                	jmp    800330 <_panic+0x43>

00800333 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	53                   	push   %ebx
  800337:	83 ec 04             	sub    $0x4,%esp
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033d:	8b 13                	mov    (%ebx),%edx
  80033f:	8d 42 01             	lea    0x1(%edx),%eax
  800342:	89 03                	mov    %eax,(%ebx)
  800344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800347:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800350:	75 1a                	jne    80036c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800352:	83 ec 08             	sub    $0x8,%esp
  800355:	68 ff 00 00 00       	push   $0xff
  80035a:	8d 43 08             	lea    0x8(%ebx),%eax
  80035d:	50                   	push   %eax
  80035e:	e8 1f fd ff ff       	call   800082 <sys_cputs>
		b->idx = 0;
  800363:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800369:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80036c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800373:	c9                   	leave  
  800374:	c3                   	ret    

00800375 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80037e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800385:	00 00 00 
	b.cnt = 0;
  800388:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80038f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	ff 75 08             	pushl  0x8(%ebp)
  800398:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039e:	50                   	push   %eax
  80039f:	68 33 03 80 00       	push   $0x800333
  8003a4:	e8 1a 01 00 00       	call   8004c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a9:	83 c4 08             	add    $0x8,%esp
  8003ac:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b8:	50                   	push   %eax
  8003b9:	e8 c4 fc ff ff       	call   800082 <sys_cputs>

	return b.cnt;
}
  8003be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003cf:	50                   	push   %eax
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	e8 9d ff ff ff       	call   800375 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	56                   	push   %esi
  8003df:	53                   	push   %ebx
  8003e0:	83 ec 1c             	sub    $0x1c,%esp
  8003e3:	89 c7                	mov    %eax,%edi
  8003e5:	89 d6                	mov    %edx,%esi
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003fe:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800401:	39 d3                	cmp    %edx,%ebx
  800403:	72 05                	jb     80040a <printnum+0x30>
  800405:	39 45 10             	cmp    %eax,0x10(%ebp)
  800408:	77 45                	ja     80044f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040a:	83 ec 0c             	sub    $0xc,%esp
  80040d:	ff 75 18             	pushl  0x18(%ebp)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800416:	53                   	push   %ebx
  800417:	ff 75 10             	pushl  0x10(%ebp)
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800420:	ff 75 e0             	pushl  -0x20(%ebp)
  800423:	ff 75 dc             	pushl  -0x24(%ebp)
  800426:	ff 75 d8             	pushl  -0x28(%ebp)
  800429:	e8 f2 08 00 00       	call   800d20 <__udivdi3>
  80042e:	83 c4 18             	add    $0x18,%esp
  800431:	52                   	push   %edx
  800432:	50                   	push   %eax
  800433:	89 f2                	mov    %esi,%edx
  800435:	89 f8                	mov    %edi,%eax
  800437:	e8 9e ff ff ff       	call   8003da <printnum>
  80043c:	83 c4 20             	add    $0x20,%esp
  80043f:	eb 18                	jmp    800459 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	56                   	push   %esi
  800445:	ff 75 18             	pushl  0x18(%ebp)
  800448:	ff d7                	call   *%edi
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	eb 03                	jmp    800452 <printnum+0x78>
  80044f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800452:	83 eb 01             	sub    $0x1,%ebx
  800455:	85 db                	test   %ebx,%ebx
  800457:	7f e8                	jg     800441 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	83 ec 04             	sub    $0x4,%esp
  800460:	ff 75 e4             	pushl  -0x1c(%ebp)
  800463:	ff 75 e0             	pushl  -0x20(%ebp)
  800466:	ff 75 dc             	pushl  -0x24(%ebp)
  800469:	ff 75 d8             	pushl  -0x28(%ebp)
  80046c:	e8 df 09 00 00       	call   800e50 <__umoddi3>
  800471:	83 c4 14             	add    $0x14,%esp
  800474:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80047b:	50                   	push   %eax
  80047c:	ff d7                	call   *%edi
}
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800484:	5b                   	pop    %ebx
  800485:	5e                   	pop    %esi
  800486:	5f                   	pop    %edi
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800493:	8b 10                	mov    (%eax),%edx
  800495:	3b 50 04             	cmp    0x4(%eax),%edx
  800498:	73 0a                	jae    8004a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	88 02                	mov    %al,(%edx)
}
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004af:	50                   	push   %eax
  8004b0:	ff 75 10             	pushl  0x10(%ebp)
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	ff 75 08             	pushl  0x8(%ebp)
  8004b9:	e8 05 00 00 00       	call   8004c3 <vprintfmt>
	va_end(ap);
}
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	c9                   	leave  
  8004c2:	c3                   	ret    

008004c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	57                   	push   %edi
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
  8004c9:	83 ec 2c             	sub    $0x2c,%esp
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004d5:	eb 12                	jmp    8004e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	0f 84 42 04 00 00    	je     800921 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	50                   	push   %eax
  8004e4:	ff d6                	call   *%esi
  8004e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	83 f8 25             	cmp    $0x25,%eax
  8004f3:	75 e2                	jne    8004d7 <vprintfmt+0x14>
  8004f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800507:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800513:	eb 07                	jmp    80051c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800518:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8d 47 01             	lea    0x1(%edi),%eax
  80051f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800522:	0f b6 07             	movzbl (%edi),%eax
  800525:	0f b6 d0             	movzbl %al,%edx
  800528:	83 e8 23             	sub    $0x23,%eax
  80052b:	3c 55                	cmp    $0x55,%al
  80052d:	0f 87 d3 03 00 00    	ja     800906 <vprintfmt+0x443>
  800533:	0f b6 c0             	movzbl %al,%eax
  800536:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800540:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800544:	eb d6                	jmp    80051c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800551:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800554:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800558:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80055e:	83 f9 09             	cmp    $0x9,%ecx
  800561:	77 3f                	ja     8005a2 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800563:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800566:	eb e9                	jmp    800551 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80057c:	eb 2a                	jmp    8005a8 <vprintfmt+0xe5>
  80057e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800581:	85 c0                	test   %eax,%eax
  800583:	ba 00 00 00 00       	mov    $0x0,%edx
  800588:	0f 49 d0             	cmovns %eax,%edx
  80058b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	eb 89                	jmp    80051c <vprintfmt+0x59>
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800596:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80059d:	e9 7a ff ff ff       	jmp    80051c <vprintfmt+0x59>
  8005a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ac:	0f 89 6a ff ff ff    	jns    80051c <vprintfmt+0x59>
				width = precision, precision = -1;
  8005b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005bf:	e9 58 ff ff ff       	jmp    80051c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ca:	e9 4d ff ff ff       	jmp    80051c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 78 04             	lea    0x4(%eax),%edi
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	ff 30                	pushl  (%eax)
  8005db:	ff d6                	call   *%esi
			break;
  8005dd:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e6:	e9 fe fe ff ff       	jmp    8004e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 78 04             	lea    0x4(%eax),%edi
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	99                   	cltd   
  8005f4:	31 d0                	xor    %edx,%eax
  8005f6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f8:	83 f8 09             	cmp    $0x9,%eax
  8005fb:	7f 0b                	jg     800608 <vprintfmt+0x145>
  8005fd:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	75 1b                	jne    800623 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800608:	50                   	push   %eax
  800609:	68 36 10 80 00       	push   $0x801036
  80060e:	53                   	push   %ebx
  80060f:	56                   	push   %esi
  800610:	e8 91 fe ff ff       	call   8004a6 <printfmt>
  800615:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800618:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061e:	e9 c6 fe ff ff       	jmp    8004e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800623:	52                   	push   %edx
  800624:	68 3f 10 80 00       	push   $0x80103f
  800629:	53                   	push   %ebx
  80062a:	56                   	push   %esi
  80062b:	e8 76 fe ff ff       	call   8004a6 <printfmt>
  800630:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800633:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800639:	e9 ab fe ff ff       	jmp    8004e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	83 c0 04             	add    $0x4,%eax
  800644:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80064c:	85 ff                	test   %edi,%edi
  80064e:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  800653:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800656:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065a:	0f 8e 94 00 00 00    	jle    8006f4 <vprintfmt+0x231>
  800660:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800664:	0f 84 98 00 00 00    	je     800702 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	ff 75 d0             	pushl  -0x30(%ebp)
  800670:	57                   	push   %edi
  800671:	e8 33 03 00 00       	call   8009a9 <strnlen>
  800676:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800679:	29 c1                	sub    %eax,%ecx
  80067b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80067e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800681:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800685:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800688:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068d:	eb 0f                	jmp    80069e <vprintfmt+0x1db>
					putch(padc, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	ff 75 e0             	pushl  -0x20(%ebp)
  800696:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800698:	83 ef 01             	sub    $0x1,%edi
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	7f ed                	jg     80068f <vprintfmt+0x1cc>
  8006a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006af:	0f 49 c1             	cmovns %ecx,%eax
  8006b2:	29 c1                	sub    %eax,%ecx
  8006b4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bd:	89 cb                	mov    %ecx,%ebx
  8006bf:	eb 4d                	jmp    80070e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c5:	74 1b                	je     8006e2 <vprintfmt+0x21f>
  8006c7:	0f be c0             	movsbl %al,%eax
  8006ca:	83 e8 20             	sub    $0x20,%eax
  8006cd:	83 f8 5e             	cmp    $0x5e,%eax
  8006d0:	76 10                	jbe    8006e2 <vprintfmt+0x21f>
					putch('?', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	6a 3f                	push   $0x3f
  8006da:	ff 55 08             	call   *0x8(%ebp)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 0d                	jmp    8006ef <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	52                   	push   %edx
  8006e9:	ff 55 08             	call   *0x8(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ef:	83 eb 01             	sub    $0x1,%ebx
  8006f2:	eb 1a                	jmp    80070e <vprintfmt+0x24b>
  8006f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800700:	eb 0c                	jmp    80070e <vprintfmt+0x24b>
  800702:	89 75 08             	mov    %esi,0x8(%ebp)
  800705:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800708:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070e:	83 c7 01             	add    $0x1,%edi
  800711:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800715:	0f be d0             	movsbl %al,%edx
  800718:	85 d2                	test   %edx,%edx
  80071a:	74 23                	je     80073f <vprintfmt+0x27c>
  80071c:	85 f6                	test   %esi,%esi
  80071e:	78 a1                	js     8006c1 <vprintfmt+0x1fe>
  800720:	83 ee 01             	sub    $0x1,%esi
  800723:	79 9c                	jns    8006c1 <vprintfmt+0x1fe>
  800725:	89 df                	mov    %ebx,%edi
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072d:	eb 18                	jmp    800747 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 20                	push   $0x20
  800735:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800737:	83 ef 01             	sub    $0x1,%edi
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 08                	jmp    800747 <vprintfmt+0x284>
  80073f:	89 df                	mov    %ebx,%edi
  800741:	8b 75 08             	mov    0x8(%ebp),%esi
  800744:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800747:	85 ff                	test   %edi,%edi
  800749:	7f e4                	jg     80072f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800754:	e9 90 fd ff ff       	jmp    8004e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800759:	83 f9 01             	cmp    $0x1,%ecx
  80075c:	7e 19                	jle    800777 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 50 04             	mov    0x4(%eax),%edx
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800769:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 40 08             	lea    0x8(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
  800775:	eb 38                	jmp    8007af <vprintfmt+0x2ec>
	else if (lflag)
  800777:	85 c9                	test   %ecx,%ecx
  800779:	74 1b                	je     800796 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800783:	89 c1                	mov    %eax,%ecx
  800785:	c1 f9 1f             	sar    $0x1f,%ecx
  800788:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 40 04             	lea    0x4(%eax),%eax
  800791:	89 45 14             	mov    %eax,0x14(%ebp)
  800794:	eb 19                	jmp    8007af <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079e:	89 c1                	mov    %eax,%ecx
  8007a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007be:	0f 89 0e 01 00 00    	jns    8008d2 <vprintfmt+0x40f>
				putch('-', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	6a 2d                	push   $0x2d
  8007ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8007cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d2:	f7 da                	neg    %edx
  8007d4:	83 d1 00             	adc    $0x0,%ecx
  8007d7:	f7 d9                	neg    %ecx
  8007d9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 ec 00 00 00       	jmp    8008d2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e6:	83 f9 01             	cmp    $0x1,%ecx
  8007e9:	7e 18                	jle    800803 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8b 10                	mov    (%eax),%edx
  8007f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f3:	8d 40 08             	lea    0x8(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fe:	e9 cf 00 00 00       	jmp    8008d2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	74 1a                	je     800821 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081c:	e9 b1 00 00 00       	jmp    8008d2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
  800836:	e9 97 00 00 00       	jmp    8008d2 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	53                   	push   %ebx
  80083f:	6a 58                	push   $0x58
  800841:	ff d6                	call   *%esi
			putch('X', putdat);
  800843:	83 c4 08             	add    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 58                	push   $0x58
  800849:	ff d6                	call   *%esi
			putch('X', putdat);
  80084b:	83 c4 08             	add    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 58                	push   $0x58
  800851:	ff d6                	call   *%esi
			break;
  800853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800859:	e9 8b fc ff ff       	jmp    8004e9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	6a 30                	push   $0x30
  800864:	ff d6                	call   *%esi
			putch('x', putdat);
  800866:	83 c4 08             	add    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 78                	push   $0x78
  80086c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800878:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087b:	8d 40 04             	lea    0x4(%eax),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800881:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800886:	eb 4a                	jmp    8008d2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800888:	83 f9 01             	cmp    $0x1,%ecx
  80088b:	7e 15                	jle    8008a2 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 10                	mov    (%eax),%edx
  800892:	8b 48 04             	mov    0x4(%eax),%ecx
  800895:	8d 40 08             	lea    0x8(%eax),%eax
  800898:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80089b:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a0:	eb 30                	jmp    8008d2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 17                	je     8008bd <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 10                	mov    (%eax),%edx
  8008ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008bb:	eb 15                	jmp    8008d2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8b 10                	mov    (%eax),%edx
  8008c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ca:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008cd:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d2:	83 ec 0c             	sub    $0xc,%esp
  8008d5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d9:	57                   	push   %edi
  8008da:	ff 75 e0             	pushl  -0x20(%ebp)
  8008dd:	50                   	push   %eax
  8008de:	51                   	push   %ecx
  8008df:	52                   	push   %edx
  8008e0:	89 da                	mov    %ebx,%edx
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	e8 f1 fa ff ff       	call   8003da <printnum>
			break;
  8008e9:	83 c4 20             	add    $0x20,%esp
  8008ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ef:	e9 f5 fb ff ff       	jmp    8004e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	52                   	push   %edx
  8008f9:	ff d6                	call   *%esi
			break;
  8008fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800901:	e9 e3 fb ff ff       	jmp    8004e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 25                	push   $0x25
  80090c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 03                	jmp    800916 <vprintfmt+0x453>
  800913:	83 ef 01             	sub    $0x1,%edi
  800916:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091a:	75 f7                	jne    800913 <vprintfmt+0x450>
  80091c:	e9 c8 fb ff ff       	jmp    8004e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800921:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 18             	sub    $0x18,%esp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800935:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800938:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800946:	85 c0                	test   %eax,%eax
  800948:	74 26                	je     800970 <vsnprintf+0x47>
  80094a:	85 d2                	test   %edx,%edx
  80094c:	7e 22                	jle    800970 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094e:	ff 75 14             	pushl  0x14(%ebp)
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800957:	50                   	push   %eax
  800958:	68 89 04 80 00       	push   $0x800489
  80095d:	e8 61 fb ff ff       	call   8004c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800962:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800965:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800968:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	eb 05                	jmp    800975 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800970:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800980:	50                   	push   %eax
  800981:	ff 75 10             	pushl  0x10(%ebp)
  800984:	ff 75 0c             	pushl  0xc(%ebp)
  800987:	ff 75 08             	pushl  0x8(%ebp)
  80098a:	e8 9a ff ff ff       	call   800929 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
  80099c:	eb 03                	jmp    8009a1 <strlen+0x10>
		n++;
  80099e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a5:	75 f7                	jne    80099e <strlen+0xd>
		n++;
	return n;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	eb 03                	jmp    8009bc <strnlen+0x13>
		n++;
  8009b9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bc:	39 c2                	cmp    %eax,%edx
  8009be:	74 08                	je     8009c8 <strnlen+0x1f>
  8009c0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c4:	75 f3                	jne    8009b9 <strnlen+0x10>
  8009c6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	53                   	push   %ebx
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ef                	jne    8009d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f1:	53                   	push   %ebx
  8009f2:	e8 9a ff ff ff       	call   800991 <strlen>
  8009f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	01 d8                	add    %ebx,%eax
  8009ff:	50                   	push   %eax
  800a00:	e8 c5 ff ff ff       	call   8009ca <strcpy>
	return dst;
}
  800a05:	89 d8                	mov    %ebx,%eax
  800a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 08             	mov    0x8(%ebp),%esi
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	eb 0f                	jmp    800a2f <strncpy+0x23>
		*dst++ = *src;
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a29:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	75 ed                	jne    800a20 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a33:	89 f0                	mov    %esi,%eax
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a44:	8b 55 10             	mov    0x10(%ebp),%edx
  800a47:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	74 21                	je     800a6e <strlcpy+0x35>
  800a4d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	eb 09                	jmp    800a5e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5e:	39 c2                	cmp    %eax,%edx
  800a60:	74 09                	je     800a6b <strlcpy+0x32>
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	84 db                	test   %bl,%bl
  800a67:	75 ec                	jne    800a55 <strlcpy+0x1c>
  800a69:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6e:	29 f0                	sub    %esi,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7d:	eb 06                	jmp    800a85 <strcmp+0x11>
		p++, q++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
  800a82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a85:	0f b6 01             	movzbl (%ecx),%eax
  800a88:	84 c0                	test   %al,%al
  800a8a:	74 04                	je     800a90 <strcmp+0x1c>
  800a8c:	3a 02                	cmp    (%edx),%al
  800a8e:	74 ef                	je     800a7f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a90:	0f b6 c0             	movzbl %al,%eax
  800a93:	0f b6 12             	movzbl (%edx),%edx
  800a96:	29 d0                	sub    %edx,%eax
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa9:	eb 06                	jmp    800ab1 <strncmp+0x17>
		n--, p++, q++;
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab1:	39 d8                	cmp    %ebx,%eax
  800ab3:	74 15                	je     800aca <strncmp+0x30>
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	84 c9                	test   %cl,%cl
  800aba:	74 04                	je     800ac0 <strncmp+0x26>
  800abc:	3a 0a                	cmp    (%edx),%cl
  800abe:	74 eb                	je     800aab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac0:	0f b6 00             	movzbl (%eax),%eax
  800ac3:	0f b6 12             	movzbl (%edx),%edx
  800ac6:	29 d0                	sub    %edx,%eax
  800ac8:	eb 05                	jmp    800acf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adc:	eb 07                	jmp    800ae5 <strchr+0x13>
		if (*s == c)
  800ade:	38 ca                	cmp    %cl,%dl
  800ae0:	74 0f                	je     800af1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afd:	eb 03                	jmp    800b02 <strfind+0xf>
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b05:	38 ca                	cmp    %cl,%dl
  800b07:	74 04                	je     800b0d <strfind+0x1a>
  800b09:	84 d2                	test   %dl,%dl
  800b0b:	75 f2                	jne    800aff <strfind+0xc>
			break;
	return (char *) s;
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	74 36                	je     800b55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b25:	75 28                	jne    800b4f <memset+0x40>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 23                	jne    800b4f <memset+0x40>
		c &= 0xFF;
  800b2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	c1 e3 08             	shl    $0x8,%ebx
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	c1 e6 18             	shl    $0x18,%esi
  800b3a:	89 d0                	mov    %edx,%eax
  800b3c:	c1 e0 10             	shl    $0x10,%eax
  800b3f:	09 f0                	or     %esi,%eax
  800b41:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	09 d0                	or     %edx,%eax
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fc                   	cld    
  800b4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4d:	eb 06                	jmp    800b55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	fc                   	cld    
  800b53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b55:	89 f8                	mov    %edi,%eax
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6a:	39 c6                	cmp    %eax,%esi
  800b6c:	73 35                	jae    800ba3 <memmove+0x47>
  800b6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b71:	39 d0                	cmp    %edx,%eax
  800b73:	73 2e                	jae    800ba3 <memmove+0x47>
		s += n;
		d += n;
  800b75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	09 fe                	or     %edi,%esi
  800b7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b82:	75 13                	jne    800b97 <memmove+0x3b>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0e                	jne    800b97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b89:	83 ef 04             	sub    $0x4,%edi
  800b8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
  800b92:	fd                   	std    
  800b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b95:	eb 09                	jmp    800ba0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b97:	83 ef 01             	sub    $0x1,%edi
  800b9a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9d:	fd                   	std    
  800b9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba0:	fc                   	cld    
  800ba1:	eb 1d                	jmp    800bc0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba3:	89 f2                	mov    %esi,%edx
  800ba5:	09 c2                	or     %eax,%edx
  800ba7:	f6 c2 03             	test   $0x3,%dl
  800baa:	75 0f                	jne    800bbb <memmove+0x5f>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 0a                	jne    800bbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb1:	c1 e9 02             	shr    $0x2,%ecx
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	fc                   	cld    
  800bb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb9:	eb 05                	jmp    800bc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	fc                   	cld    
  800bbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	ff 75 0c             	pushl  0xc(%ebp)
  800bcd:	ff 75 08             	pushl  0x8(%ebp)
  800bd0:	e8 87 ff ff ff       	call   800b5c <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be2:	89 c6                	mov    %eax,%esi
  800be4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be7:	eb 1a                	jmp    800c03 <memcmp+0x2c>
		if (*s1 != *s2)
  800be9:	0f b6 08             	movzbl (%eax),%ecx
  800bec:	0f b6 1a             	movzbl (%edx),%ebx
  800bef:	38 d9                	cmp    %bl,%cl
  800bf1:	74 0a                	je     800bfd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf3:	0f b6 c1             	movzbl %cl,%eax
  800bf6:	0f b6 db             	movzbl %bl,%ebx
  800bf9:	29 d8                	sub    %ebx,%eax
  800bfb:	eb 0f                	jmp    800c0c <memcmp+0x35>
		s1++, s2++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c03:	39 f0                	cmp    %esi,%eax
  800c05:	75 e2                	jne    800be9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	53                   	push   %ebx
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c17:	89 c1                	mov    %eax,%ecx
  800c19:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c20:	eb 0a                	jmp    800c2c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c22:	0f b6 10             	movzbl (%eax),%edx
  800c25:	39 da                	cmp    %ebx,%edx
  800c27:	74 07                	je     800c30 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c29:	83 c0 01             	add    $0x1,%eax
  800c2c:	39 c8                	cmp    %ecx,%eax
  800c2e:	72 f2                	jb     800c22 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3f:	eb 03                	jmp    800c44 <strtol+0x11>
		s++;
  800c41:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	0f b6 01             	movzbl (%ecx),%eax
  800c47:	3c 20                	cmp    $0x20,%al
  800c49:	74 f6                	je     800c41 <strtol+0xe>
  800c4b:	3c 09                	cmp    $0x9,%al
  800c4d:	74 f2                	je     800c41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4f:	3c 2b                	cmp    $0x2b,%al
  800c51:	75 0a                	jne    800c5d <strtol+0x2a>
		s++;
  800c53:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	eb 11                	jmp    800c6e <strtol+0x3b>
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c62:	3c 2d                	cmp    $0x2d,%al
  800c64:	75 08                	jne    800c6e <strtol+0x3b>
		s++, neg = 1;
  800c66:	83 c1 01             	add    $0x1,%ecx
  800c69:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c74:	75 15                	jne    800c8b <strtol+0x58>
  800c76:	80 39 30             	cmpb   $0x30,(%ecx)
  800c79:	75 10                	jne    800c8b <strtol+0x58>
  800c7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7f:	75 7c                	jne    800cfd <strtol+0xca>
		s += 2, base = 16;
  800c81:	83 c1 02             	add    $0x2,%ecx
  800c84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c89:	eb 16                	jmp    800ca1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 12                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	75 08                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
  800c99:	83 c1 01             	add    $0x1,%ecx
  800c9c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca9:	0f b6 11             	movzbl (%ecx),%edx
  800cac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 09             	cmp    $0x9,%bl
  800cb4:	77 08                	ja     800cbe <strtol+0x8b>
			dig = *s - '0';
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 30             	sub    $0x30,%edx
  800cbc:	eb 22                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cbe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 19             	cmp    $0x19,%bl
  800cc6:	77 08                	ja     800cd0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	83 ea 57             	sub    $0x57,%edx
  800cce:	eb 10                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd3:	89 f3                	mov    %esi,%ebx
  800cd5:	80 fb 19             	cmp    $0x19,%bl
  800cd8:	77 16                	ja     800cf0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cda:	0f be d2             	movsbl %dl,%edx
  800cdd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce3:	7d 0b                	jge    800cf0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce5:	83 c1 01             	add    $0x1,%ecx
  800ce8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cee:	eb b9                	jmp    800ca9 <strtol+0x76>

	if (endptr)
  800cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf4:	74 0d                	je     800d03 <strtol+0xd0>
		*endptr = (char *) s;
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	89 0e                	mov    %ecx,(%esi)
  800cfb:	eb 06                	jmp    800d03 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 98                	je     800c99 <strtol+0x66>
  800d01:	eb 9e                	jmp    800ca1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	f7 da                	neg    %edx
  800d07:	85 ff                	test   %edi,%edi
  800d09:	0f 45 c2             	cmovne %edx,%eax
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
  800d11:	66 90                	xchg   %ax,%ax
  800d13:	66 90                	xchg   %ax,%ax
  800d15:	66 90                	xchg   %ax,%ax
  800d17:	66 90                	xchg   %ax,%ax
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
