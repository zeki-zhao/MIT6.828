
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 4d 00 00 00       	call   800096 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 d8 0f 80 00       	push   $0x800fd8
  800100:	6a 23                	push   $0x23
  800102:	68 f5 0f 80 00       	push   $0x800ff5
  800107:	e8 f5 01 00 00       	call   800301 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 d8 0f 80 00       	push   $0x800fd8
  800181:	6a 23                	push   $0x23
  800183:	68 f5 0f 80 00       	push   $0x800ff5
  800188:	e8 74 01 00 00       	call   800301 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 d8 0f 80 00       	push   $0x800fd8
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 f5 0f 80 00       	push   $0x800ff5
  8001ca:	e8 32 01 00 00       	call   800301 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 d8 0f 80 00       	push   $0x800fd8
  800205:	6a 23                	push   $0x23
  800207:	68 f5 0f 80 00       	push   $0x800ff5
  80020c:	e8 f0 00 00 00       	call   800301 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 d8 0f 80 00       	push   $0x800fd8
  800247:	6a 23                	push   $0x23
  800249:	68 f5 0f 80 00       	push   $0x800ff5
  80024e:	e8 ae 00 00 00       	call   800301 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 d8 0f 80 00       	push   $0x800fd8
  800289:	6a 23                	push   $0x23
  80028b:	68 f5 0f 80 00       	push   $0x800ff5
  800290:	e8 6c 00 00 00       	call   800301 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 d8 0f 80 00       	push   $0x800fd8
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 f5 0f 80 00       	push   $0x800ff5
  8002f4:	e8 08 00 00 00       	call   800301 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 04 10 80 00       	push   $0x801004
  800324:	e8 b1 00 00 00       	call   8003da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 54 00 00 00       	call   800389 <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  80033c:	e8 99 00 00 00       	call   8003da <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	75 1a                	jne    800380 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 1f fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800399:	00 00 00 
	b.cnt = 0;
  80039c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	68 47 03 80 00       	push   $0x800347
  8003b8:	e8 1a 01 00 00       	call   8004d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bd:	83 c4 08             	add    $0x8,%esp
  8003c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 c4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e3:	50                   	push   %eax
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 9d ff ff ff       	call   800389 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 1c             	sub    $0x1c,%esp
  8003f7:	89 c7                	mov    %eax,%edi
  8003f9:	89 d6                	mov    %edx,%esi
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800407:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800412:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800415:	39 d3                	cmp    %edx,%ebx
  800417:	72 05                	jb     80041e <printnum+0x30>
  800419:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041c:	77 45                	ja     800463 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	ff 75 18             	pushl  0x18(%ebp)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 e4             	pushl  -0x1c(%ebp)
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff 75 dc             	pushl  -0x24(%ebp)
  80043a:	ff 75 d8             	pushl  -0x28(%ebp)
  80043d:	e8 ee 08 00 00       	call   800d30 <__udivdi3>
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	52                   	push   %edx
  800446:	50                   	push   %eax
  800447:	89 f2                	mov    %esi,%edx
  800449:	89 f8                	mov    %edi,%eax
  80044b:	e8 9e ff ff ff       	call   8003ee <printnum>
  800450:	83 c4 20             	add    $0x20,%esp
  800453:	eb 18                	jmp    80046d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	ff 75 18             	pushl  0x18(%ebp)
  80045c:	ff d7                	call   *%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb 03                	jmp    800466 <printnum+0x78>
  800463:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800466:	83 eb 01             	sub    $0x1,%ebx
  800469:	85 db                	test   %ebx,%ebx
  80046b:	7f e8                	jg     800455 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	ff 75 e4             	pushl  -0x1c(%ebp)
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 db 09 00 00       	call   800e60 <__umoddi3>
  800485:	83 c4 14             	add    $0x14,%esp
  800488:	0f be 80 28 10 80 00 	movsbl 0x801028(%eax),%eax
  80048f:	50                   	push   %eax
  800490:	ff d7                	call   *%edi
}
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5f                   	pop    %edi
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a7:	8b 10                	mov    (%eax),%edx
  8004a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ac:	73 0a                	jae    8004b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b6:	88 02                	mov    %al,(%edx)
}
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    

008004ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c3:	50                   	push   %eax
  8004c4:	ff 75 10             	pushl  0x10(%ebp)
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 05 00 00 00       	call   8004d7 <vprintfmt>
	va_end(ap);
}
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	53                   	push   %ebx
  8004dd:	83 ec 2c             	sub    $0x2c,%esp
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e9:	eb 12                	jmp    8004fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	0f 84 42 04 00 00    	je     800935 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	50                   	push   %eax
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fd:	83 c7 01             	add    $0x1,%edi
  800500:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800504:	83 f8 25             	cmp    $0x25,%eax
  800507:	75 e2                	jne    8004eb <vprintfmt+0x14>
  800509:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80050d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800514:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
  800527:	eb 07                	jmp    800530 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80052c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8d 47 01             	lea    0x1(%edi),%eax
  800533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800536:	0f b6 07             	movzbl (%edi),%eax
  800539:	0f b6 d0             	movzbl %al,%edx
  80053c:	83 e8 23             	sub    $0x23,%eax
  80053f:	3c 55                	cmp    $0x55,%al
  800541:	0f 87 d3 03 00 00    	ja     80091a <vprintfmt+0x443>
  800547:	0f b6 c0             	movzbl %al,%eax
  80054a:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800554:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800558:	eb d6                	jmp    800530 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800565:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800568:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800572:	83 f9 09             	cmp    $0x9,%ecx
  800575:	77 3f                	ja     8005b6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800577:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057a:	eb e9                	jmp    800565 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800590:	eb 2a                	jmp    8005bc <vprintfmt+0xe5>
  800592:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	ba 00 00 00 00       	mov    $0x0,%edx
  80059c:	0f 49 d0             	cmovns %eax,%edx
  80059f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a5:	eb 89                	jmp    800530 <vprintfmt+0x59>
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005aa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b1:	e9 7a ff ff ff       	jmp    800530 <vprintfmt+0x59>
  8005b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c0:	0f 89 6a ff ff ff    	jns    800530 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d3:	e9 58 ff ff ff       	jmp    800530 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d8:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005de:	e9 4d ff ff ff       	jmp    800530 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 78 04             	lea    0x4(%eax),%edi
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	ff 30                	pushl  (%eax)
  8005ef:	ff d6                	call   *%esi
			break;
  8005f1:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005fa:	e9 fe fe ff ff       	jmp    8004fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 78 04             	lea    0x4(%eax),%edi
  800605:	8b 00                	mov    (%eax),%eax
  800607:	99                   	cltd   
  800608:	31 d0                	xor    %edx,%eax
  80060a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060c:	83 f8 09             	cmp    $0x9,%eax
  80060f:	7f 0b                	jg     80061c <vprintfmt+0x145>
  800611:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800618:	85 d2                	test   %edx,%edx
  80061a:	75 1b                	jne    800637 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80061c:	50                   	push   %eax
  80061d:	68 40 10 80 00       	push   $0x801040
  800622:	53                   	push   %ebx
  800623:	56                   	push   %esi
  800624:	e8 91 fe ff ff       	call   8004ba <printfmt>
  800629:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800632:	e9 c6 fe ff ff       	jmp    8004fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800637:	52                   	push   %edx
  800638:	68 49 10 80 00       	push   $0x801049
  80063d:	53                   	push   %ebx
  80063e:	56                   	push   %esi
  80063f:	e8 76 fe ff ff       	call   8004ba <printfmt>
  800644:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800647:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064d:	e9 ab fe ff ff       	jmp    8004fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	83 c0 04             	add    $0x4,%eax
  800658:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800660:	85 ff                	test   %edi,%edi
  800662:	b8 39 10 80 00       	mov    $0x801039,%eax
  800667:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80066a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066e:	0f 8e 94 00 00 00    	jle    800708 <vprintfmt+0x231>
  800674:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800678:	0f 84 98 00 00 00    	je     800716 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	ff 75 d0             	pushl  -0x30(%ebp)
  800684:	57                   	push   %edi
  800685:	e8 33 03 00 00       	call   8009bd <strnlen>
  80068a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068d:	29 c1                	sub    %eax,%ecx
  80068f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800692:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800695:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	eb 0f                	jmp    8006b2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 ef 01             	sub    $0x1,%edi
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 ff                	test   %edi,%edi
  8006b4:	7f ed                	jg     8006a3 <vprintfmt+0x1cc>
  8006b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bc:	85 c9                	test   %ecx,%ecx
  8006be:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c3:	0f 49 c1             	cmovns %ecx,%eax
  8006c6:	29 c1                	sub    %eax,%ecx
  8006c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d1:	89 cb                	mov    %ecx,%ebx
  8006d3:	eb 4d                	jmp    800722 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d9:	74 1b                	je     8006f6 <vprintfmt+0x21f>
  8006db:	0f be c0             	movsbl %al,%eax
  8006de:	83 e8 20             	sub    $0x20,%eax
  8006e1:	83 f8 5e             	cmp    $0x5e,%eax
  8006e4:	76 10                	jbe    8006f6 <vprintfmt+0x21f>
					putch('?', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	6a 3f                	push   $0x3f
  8006ee:	ff 55 08             	call   *0x8(%ebp)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 0d                	jmp    800703 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	52                   	push   %edx
  8006fd:	ff 55 08             	call   *0x8(%ebp)
  800700:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800703:	83 eb 01             	sub    $0x1,%ebx
  800706:	eb 1a                	jmp    800722 <vprintfmt+0x24b>
  800708:	89 75 08             	mov    %esi,0x8(%ebp)
  80070b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800711:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800714:	eb 0c                	jmp    800722 <vprintfmt+0x24b>
  800716:	89 75 08             	mov    %esi,0x8(%ebp)
  800719:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800722:	83 c7 01             	add    $0x1,%edi
  800725:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800729:	0f be d0             	movsbl %al,%edx
  80072c:	85 d2                	test   %edx,%edx
  80072e:	74 23                	je     800753 <vprintfmt+0x27c>
  800730:	85 f6                	test   %esi,%esi
  800732:	78 a1                	js     8006d5 <vprintfmt+0x1fe>
  800734:	83 ee 01             	sub    $0x1,%esi
  800737:	79 9c                	jns    8006d5 <vprintfmt+0x1fe>
  800739:	89 df                	mov    %ebx,%edi
  80073b:	8b 75 08             	mov    0x8(%ebp),%esi
  80073e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800741:	eb 18                	jmp    80075b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 20                	push   $0x20
  800749:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074b:	83 ef 01             	sub    $0x1,%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 08                	jmp    80075b <vprintfmt+0x284>
  800753:	89 df                	mov    %ebx,%edi
  800755:	8b 75 08             	mov    0x8(%ebp),%esi
  800758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075b:	85 ff                	test   %edi,%edi
  80075d:	7f e4                	jg     800743 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	e9 90 fd ff ff       	jmp    8004fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076d:	83 f9 01             	cmp    $0x1,%ecx
  800770:	7e 19                	jle    80078b <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 50 04             	mov    0x4(%eax),%edx
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 40 08             	lea    0x8(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
  800789:	eb 38                	jmp    8007c3 <vprintfmt+0x2ec>
	else if (lflag)
  80078b:	85 c9                	test   %ecx,%ecx
  80078d:	74 1b                	je     8007aa <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 00                	mov    (%eax),%eax
  800794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800797:	89 c1                	mov    %eax,%ecx
  800799:	c1 f9 1f             	sar    $0x1f,%ecx
  80079c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 40 04             	lea    0x4(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a8:	eb 19                	jmp    8007c3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 00                	mov    (%eax),%eax
  8007af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b2:	89 c1                	mov    %eax,%ecx
  8007b4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d2:	0f 89 0e 01 00 00    	jns    8008e6 <vprintfmt+0x40f>
				putch('-', putdat);
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	53                   	push   %ebx
  8007dc:	6a 2d                	push   $0x2d
  8007de:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007e6:	f7 da                	neg    %edx
  8007e8:	83 d1 00             	adc    $0x0,%ecx
  8007eb:	f7 d9                	neg    %ecx
  8007ed:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f5:	e9 ec 00 00 00       	jmp    8008e6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fa:	83 f9 01             	cmp    $0x1,%ecx
  8007fd:	7e 18                	jle    800817 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	8b 48 04             	mov    0x4(%eax),%ecx
  800807:	8d 40 08             	lea    0x8(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80080d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800812:	e9 cf 00 00 00       	jmp    8008e6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800817:	85 c9                	test   %ecx,%ecx
  800819:	74 1a                	je     800835 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	b9 00 00 00 00       	mov    $0x0,%ecx
  800825:	8d 40 04             	lea    0x4(%eax),%eax
  800828:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80082b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800830:	e9 b1 00 00 00       	jmp    8008e6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800845:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084a:	e9 97 00 00 00       	jmp    8008e6 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 58                	push   $0x58
  800855:	ff d6                	call   *%esi
			putch('X', putdat);
  800857:	83 c4 08             	add    $0x8,%esp
  80085a:	53                   	push   %ebx
  80085b:	6a 58                	push   $0x58
  80085d:	ff d6                	call   *%esi
			putch('X', putdat);
  80085f:	83 c4 08             	add    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 58                	push   $0x58
  800865:	ff d6                	call   *%esi
			break;
  800867:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80086d:	e9 8b fc ff ff       	jmp    8004fd <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 30                	push   $0x30
  800878:	ff d6                	call   *%esi
			putch('x', putdat);
  80087a:	83 c4 08             	add    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 78                	push   $0x78
  800880:	ff d6                	call   *%esi
			num = (unsigned long long)
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8b 10                	mov    (%eax),%edx
  800887:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088c:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088f:	8d 40 04             	lea    0x4(%eax),%eax
  800892:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800895:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089a:	eb 4a                	jmp    8008e6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089c:	83 f9 01             	cmp    $0x1,%ecx
  80089f:	7e 15                	jle    8008b6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8b 10                	mov    (%eax),%edx
  8008a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a9:	8d 40 08             	lea    0x8(%eax),%eax
  8008ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008af:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b4:	eb 30                	jmp    8008e6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008b6:	85 c9                	test   %ecx,%ecx
  8008b8:	74 17                	je     8008d1 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8b 10                	mov    (%eax),%edx
  8008bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c4:	8d 40 04             	lea    0x4(%eax),%eax
  8008c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8008cf:	eb 15                	jmp    8008e6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e6:	83 ec 0c             	sub    $0xc,%esp
  8008e9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ed:	57                   	push   %edi
  8008ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f1:	50                   	push   %eax
  8008f2:	51                   	push   %ecx
  8008f3:	52                   	push   %edx
  8008f4:	89 da                	mov    %ebx,%edx
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	e8 f1 fa ff ff       	call   8003ee <printnum>
			break;
  8008fd:	83 c4 20             	add    $0x20,%esp
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800903:	e9 f5 fb ff ff       	jmp    8004fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	52                   	push   %edx
  80090d:	ff d6                	call   *%esi
			break;
  80090f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800915:	e9 e3 fb ff ff       	jmp    8004fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	6a 25                	push   $0x25
  800920:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	eb 03                	jmp    80092a <vprintfmt+0x453>
  800927:	83 ef 01             	sub    $0x1,%edi
  80092a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80092e:	75 f7                	jne    800927 <vprintfmt+0x450>
  800930:	e9 c8 fb ff ff       	jmp    8004fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800935:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	83 ec 18             	sub    $0x18,%esp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800949:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800950:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800953:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095a:	85 c0                	test   %eax,%eax
  80095c:	74 26                	je     800984 <vsnprintf+0x47>
  80095e:	85 d2                	test   %edx,%edx
  800960:	7e 22                	jle    800984 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800962:	ff 75 14             	pushl  0x14(%ebp)
  800965:	ff 75 10             	pushl  0x10(%ebp)
  800968:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096b:	50                   	push   %eax
  80096c:	68 9d 04 80 00       	push   $0x80049d
  800971:	e8 61 fb ff ff       	call   8004d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800976:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800979:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097f:	83 c4 10             	add    $0x10,%esp
  800982:	eb 05                	jmp    800989 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800984:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800991:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800994:	50                   	push   %eax
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 9a ff ff ff       	call   80093d <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	eb 03                	jmp    8009b5 <strlen+0x10>
		n++;
  8009b2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b9:	75 f7                	jne    8009b2 <strlen+0xd>
		n++;
	return n;
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	eb 03                	jmp    8009d0 <strnlen+0x13>
		n++;
  8009cd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d0:	39 c2                	cmp    %eax,%edx
  8009d2:	74 08                	je     8009dc <strnlen+0x1f>
  8009d4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009d8:	75 f3                	jne    8009cd <strnlen+0x10>
  8009da:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	83 c2 01             	add    $0x1,%edx
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f7:	84 db                	test   %bl,%bl
  8009f9:	75 ef                	jne    8009ea <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a05:	53                   	push   %ebx
  800a06:	e8 9a ff ff ff       	call   8009a5 <strlen>
  800a0b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	01 d8                	add    %ebx,%eax
  800a13:	50                   	push   %eax
  800a14:	e8 c5 ff ff ff       	call   8009de <strcpy>
	return dst;
}
  800a19:	89 d8                	mov    %ebx,%eax
  800a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 75 08             	mov    0x8(%ebp),%esi
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a30:	89 f2                	mov    %esi,%edx
  800a32:	eb 0f                	jmp    800a43 <strncpy+0x23>
		*dst++ = *src;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	0f b6 01             	movzbl (%ecx),%eax
  800a3a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3d:	80 39 01             	cmpb   $0x1,(%ecx)
  800a40:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 ed                	jne    800a34 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a47:	89 f0                	mov    %esi,%eax
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 75 08             	mov    0x8(%ebp),%esi
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5d:	85 d2                	test   %edx,%edx
  800a5f:	74 21                	je     800a82 <strlcpy+0x35>
  800a61:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a65:	89 f2                	mov    %esi,%edx
  800a67:	eb 09                	jmp    800a72 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a72:	39 c2                	cmp    %eax,%edx
  800a74:	74 09                	je     800a7f <strlcpy+0x32>
  800a76:	0f b6 19             	movzbl (%ecx),%ebx
  800a79:	84 db                	test   %bl,%bl
  800a7b:	75 ec                	jne    800a69 <strlcpy+0x1c>
  800a7d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a82:	29 f0                	sub    %esi,%eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a91:	eb 06                	jmp    800a99 <strcmp+0x11>
		p++, q++;
  800a93:	83 c1 01             	add    $0x1,%ecx
  800a96:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a99:	0f b6 01             	movzbl (%ecx),%eax
  800a9c:	84 c0                	test   %al,%al
  800a9e:	74 04                	je     800aa4 <strcmp+0x1c>
  800aa0:	3a 02                	cmp    (%edx),%al
  800aa2:	74 ef                	je     800a93 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa4:	0f b6 c0             	movzbl %al,%eax
  800aa7:	0f b6 12             	movzbl (%edx),%edx
  800aaa:	29 d0                	sub    %edx,%eax
}
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	53                   	push   %ebx
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800abd:	eb 06                	jmp    800ac5 <strncmp+0x17>
		n--, p++, q++;
  800abf:	83 c0 01             	add    $0x1,%eax
  800ac2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac5:	39 d8                	cmp    %ebx,%eax
  800ac7:	74 15                	je     800ade <strncmp+0x30>
  800ac9:	0f b6 08             	movzbl (%eax),%ecx
  800acc:	84 c9                	test   %cl,%cl
  800ace:	74 04                	je     800ad4 <strncmp+0x26>
  800ad0:	3a 0a                	cmp    (%edx),%cl
  800ad2:	74 eb                	je     800abf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad4:	0f b6 00             	movzbl (%eax),%eax
  800ad7:	0f b6 12             	movzbl (%edx),%edx
  800ada:	29 d0                	sub    %edx,%eax
  800adc:	eb 05                	jmp    800ae3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af0:	eb 07                	jmp    800af9 <strchr+0x13>
		if (*s == c)
  800af2:	38 ca                	cmp    %cl,%dl
  800af4:	74 0f                	je     800b05 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	0f b6 10             	movzbl (%eax),%edx
  800afc:	84 d2                	test   %dl,%dl
  800afe:	75 f2                	jne    800af2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b11:	eb 03                	jmp    800b16 <strfind+0xf>
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b19:	38 ca                	cmp    %cl,%dl
  800b1b:	74 04                	je     800b21 <strfind+0x1a>
  800b1d:	84 d2                	test   %dl,%dl
  800b1f:	75 f2                	jne    800b13 <strfind+0xc>
			break;
	return (char *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2f:	85 c9                	test   %ecx,%ecx
  800b31:	74 36                	je     800b69 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b33:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b39:	75 28                	jne    800b63 <memset+0x40>
  800b3b:	f6 c1 03             	test   $0x3,%cl
  800b3e:	75 23                	jne    800b63 <memset+0x40>
		c &= 0xFF;
  800b40:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	c1 e3 08             	shl    $0x8,%ebx
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	c1 e6 18             	shl    $0x18,%esi
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	c1 e0 10             	shl    $0x10,%eax
  800b53:	09 f0                	or     %esi,%eax
  800b55:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b57:	89 d8                	mov    %ebx,%eax
  800b59:	09 d0                	or     %edx,%eax
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
  800b5e:	fc                   	cld    
  800b5f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b61:	eb 06                	jmp    800b69 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	fc                   	cld    
  800b67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b69:	89 f8                	mov    %edi,%eax
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7e:	39 c6                	cmp    %eax,%esi
  800b80:	73 35                	jae    800bb7 <memmove+0x47>
  800b82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b85:	39 d0                	cmp    %edx,%eax
  800b87:	73 2e                	jae    800bb7 <memmove+0x47>
		s += n;
		d += n;
  800b89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	09 fe                	or     %edi,%esi
  800b90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b96:	75 13                	jne    800bab <memmove+0x3b>
  800b98:	f6 c1 03             	test   $0x3,%cl
  800b9b:	75 0e                	jne    800bab <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b9d:	83 ef 04             	sub    $0x4,%edi
  800ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 09                	jmp    800bb4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bab:	83 ef 01             	sub    $0x1,%edi
  800bae:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb1:	fd                   	std    
  800bb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb4:	fc                   	cld    
  800bb5:	eb 1d                	jmp    800bd4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb7:	89 f2                	mov    %esi,%edx
  800bb9:	09 c2                	or     %eax,%edx
  800bbb:	f6 c2 03             	test   $0x3,%dl
  800bbe:	75 0f                	jne    800bcf <memmove+0x5f>
  800bc0:	f6 c1 03             	test   $0x3,%cl
  800bc3:	75 0a                	jne    800bcf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc5:	c1 e9 02             	shr    $0x2,%ecx
  800bc8:	89 c7                	mov    %eax,%edi
  800bca:	fc                   	cld    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 05                	jmp    800bd4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcf:	89 c7                	mov    %eax,%edi
  800bd1:	fc                   	cld    
  800bd2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdb:	ff 75 10             	pushl  0x10(%ebp)
  800bde:	ff 75 0c             	pushl  0xc(%ebp)
  800be1:	ff 75 08             	pushl  0x8(%ebp)
  800be4:	e8 87 ff ff ff       	call   800b70 <memmove>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfb:	eb 1a                	jmp    800c17 <memcmp+0x2c>
		if (*s1 != *s2)
  800bfd:	0f b6 08             	movzbl (%eax),%ecx
  800c00:	0f b6 1a             	movzbl (%edx),%ebx
  800c03:	38 d9                	cmp    %bl,%cl
  800c05:	74 0a                	je     800c11 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c07:	0f b6 c1             	movzbl %cl,%eax
  800c0a:	0f b6 db             	movzbl %bl,%ebx
  800c0d:	29 d8                	sub    %ebx,%eax
  800c0f:	eb 0f                	jmp    800c20 <memcmp+0x35>
		s1++, s2++;
  800c11:	83 c0 01             	add    $0x1,%eax
  800c14:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c17:	39 f0                	cmp    %esi,%eax
  800c19:	75 e2                	jne    800bfd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	53                   	push   %ebx
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c2b:	89 c1                	mov    %eax,%ecx
  800c2d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c30:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c34:	eb 0a                	jmp    800c40 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c36:	0f b6 10             	movzbl (%eax),%edx
  800c39:	39 da                	cmp    %ebx,%edx
  800c3b:	74 07                	je     800c44 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3d:	83 c0 01             	add    $0x1,%eax
  800c40:	39 c8                	cmp    %ecx,%eax
  800c42:	72 f2                	jb     800c36 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c44:	5b                   	pop    %ebx
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c53:	eb 03                	jmp    800c58 <strtol+0x11>
		s++;
  800c55:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c58:	0f b6 01             	movzbl (%ecx),%eax
  800c5b:	3c 20                	cmp    $0x20,%al
  800c5d:	74 f6                	je     800c55 <strtol+0xe>
  800c5f:	3c 09                	cmp    $0x9,%al
  800c61:	74 f2                	je     800c55 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c63:	3c 2b                	cmp    $0x2b,%al
  800c65:	75 0a                	jne    800c71 <strtol+0x2a>
		s++;
  800c67:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6f:	eb 11                	jmp    800c82 <strtol+0x3b>
  800c71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c76:	3c 2d                	cmp    $0x2d,%al
  800c78:	75 08                	jne    800c82 <strtol+0x3b>
		s++, neg = 1;
  800c7a:	83 c1 01             	add    $0x1,%ecx
  800c7d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c88:	75 15                	jne    800c9f <strtol+0x58>
  800c8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8d:	75 10                	jne    800c9f <strtol+0x58>
  800c8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c93:	75 7c                	jne    800d11 <strtol+0xca>
		s += 2, base = 16;
  800c95:	83 c1 02             	add    $0x2,%ecx
  800c98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9d:	eb 16                	jmp    800cb5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c9f:	85 db                	test   %ebx,%ebx
  800ca1:	75 12                	jne    800cb5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	80 39 30             	cmpb   $0x30,(%ecx)
  800cab:	75 08                	jne    800cb5 <strtol+0x6e>
		s++, base = 8;
  800cad:	83 c1 01             	add    $0x1,%ecx
  800cb0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cba:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cbd:	0f b6 11             	movzbl (%ecx),%edx
  800cc0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 09             	cmp    $0x9,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0x8b>
			dig = *s - '0';
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 30             	sub    $0x30,%edx
  800cd0:	eb 22                	jmp    800cf4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cd2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 08                	ja     800ce4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 57             	sub    $0x57,%edx
  800ce2:	eb 10                	jmp    800cf4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce7:	89 f3                	mov    %esi,%ebx
  800ce9:	80 fb 19             	cmp    $0x19,%bl
  800cec:	77 16                	ja     800d04 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cee:	0f be d2             	movsbl %dl,%edx
  800cf1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf7:	7d 0b                	jge    800d04 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d00:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d02:	eb b9                	jmp    800cbd <strtol+0x76>

	if (endptr)
  800d04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d08:	74 0d                	je     800d17 <strtol+0xd0>
		*endptr = (char *) s;
  800d0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0d:	89 0e                	mov    %ecx,(%esi)
  800d0f:	eb 06                	jmp    800d17 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d11:	85 db                	test   %ebx,%ebx
  800d13:	74 98                	je     800cad <strtol+0x66>
  800d15:	eb 9e                	jmp    800cb5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	f7 da                	neg    %edx
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	0f 45 c2             	cmovne %edx,%eax
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
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
