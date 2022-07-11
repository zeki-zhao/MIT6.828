
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 08             	sub    $0x8,%esp
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800051:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800054:	85 c0                	test   %eax,%eax
  800056:	7e 08                	jle    800060 <libmain+0x22>
		binaryname = argv[0];
  800058:	8b 0a                	mov    (%edx),%ecx
  80005a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800060:	83 ec 08             	sub    $0x8,%esp
  800063:	52                   	push   %edx
  800064:	50                   	push   %eax
  800065:	e8 c9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007a:	6a 00                	push   $0x0
  80007c:	e8 42 00 00 00       	call   8000c3 <sys_env_destroy>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	c9                   	leave  
  800085:	c3                   	ret    

00800086 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800086:	55                   	push   %ebp
  800087:	89 e5                	mov    %esp,%ebp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
  800091:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800094:	8b 55 08             	mov    0x8(%ebp),%edx
  800097:	89 c3                	mov    %eax,%ebx
  800099:	89 c7                	mov    %eax,%edi
  80009b:	89 c6                	mov    %eax,%esi
  80009d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5f                   	pop    %edi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000af:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b4:	89 d1                	mov    %edx,%ecx
  8000b6:	89 d3                	mov    %edx,%ebx
  8000b8:	89 d7                	mov    %edx,%edi
  8000ba:	89 d6                	mov    %edx,%esi
  8000bc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d9:	89 cb                	mov    %ecx,%ebx
  8000db:	89 cf                	mov    %ecx,%edi
  8000dd:	89 ce                	mov    %ecx,%esi
  8000df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	7e 17                	jle    8000fc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	50                   	push   %eax
  8000e9:	6a 03                	push   $0x3
  8000eb:	68 ca 0f 80 00       	push   $0x800fca
  8000f0:	6a 23                	push   $0x23
  8000f2:	68 e7 0f 80 00       	push   $0x800fe7
  8000f7:	e8 f5 01 00 00       	call   8002f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	ba 00 00 00 00       	mov    $0x0,%edx
  80010f:	b8 02 00 00 00       	mov    $0x2,%eax
  800114:	89 d1                	mov    %edx,%ecx
  800116:	89 d3                	mov    %edx,%ebx
  800118:	89 d7                	mov    %edx,%edi
  80011a:	89 d6                	mov    %edx,%esi
  80011c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_yield>:

void
sys_yield(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800133:	89 d1                	mov    %edx,%ecx
  800135:	89 d3                	mov    %edx,%ebx
  800137:	89 d7                	mov    %edx,%edi
  800139:	89 d6                	mov    %edx,%esi
  80013b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	57                   	push   %edi
  800146:	56                   	push   %esi
  800147:	53                   	push   %ebx
  800148:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014b:	be 00 00 00 00       	mov    $0x0,%esi
  800150:	b8 04 00 00 00       	mov    $0x4,%eax
  800155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80015e:	89 f7                	mov    %esi,%edi
  800160:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800162:	85 c0                	test   %eax,%eax
  800164:	7e 17                	jle    80017d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	50                   	push   %eax
  80016a:	6a 04                	push   $0x4
  80016c:	68 ca 0f 80 00       	push   $0x800fca
  800171:	6a 23                	push   $0x23
  800173:	68 e7 0f 80 00       	push   $0x800fe7
  800178:	e8 74 01 00 00       	call   8002f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	b8 05 00 00 00       	mov    $0x5,%eax
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019f:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7e 17                	jle    8001bf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	50                   	push   %eax
  8001ac:	6a 05                	push   $0x5
  8001ae:	68 ca 0f 80 00       	push   $0x800fca
  8001b3:	6a 23                	push   $0x23
  8001b5:	68 e7 0f 80 00       	push   $0x800fe7
  8001ba:	e8 32 01 00 00       	call   8002f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 df                	mov    %ebx,%edi
  8001e2:	89 de                	mov    %ebx,%esi
  8001e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7e 17                	jle    800201 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	50                   	push   %eax
  8001ee:	6a 06                	push   $0x6
  8001f0:	68 ca 0f 80 00       	push   $0x800fca
  8001f5:	6a 23                	push   $0x23
  8001f7:	68 e7 0f 80 00       	push   $0x800fe7
  8001fc:	e8 f0 00 00 00       	call   8002f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	b8 08 00 00 00       	mov    $0x8,%eax
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 17                	jle    800243 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	50                   	push   %eax
  800230:	6a 08                	push   $0x8
  800232:	68 ca 0f 80 00       	push   $0x800fca
  800237:	6a 23                	push   $0x23
  800239:	68 e7 0f 80 00       	push   $0x800fe7
  80023e:	e8 ae 00 00 00       	call   8002f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	b8 09 00 00 00       	mov    $0x9,%eax
  80025e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	89 df                	mov    %ebx,%edi
  800266:	89 de                	mov    %ebx,%esi
  800268:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80026a:	85 c0                	test   %eax,%eax
  80026c:	7e 17                	jle    800285 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	50                   	push   %eax
  800272:	6a 09                	push   $0x9
  800274:	68 ca 0f 80 00       	push   $0x800fca
  800279:	6a 23                	push   $0x23
  80027b:	68 e7 0f 80 00       	push   $0x800fe7
  800280:	e8 6c 00 00 00       	call   8002f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	be 00 00 00 00       	mov    $0x0,%esi
  800298:	b8 0b 00 00 00       	mov    $0xb,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002a6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002a9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002be:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	89 cb                	mov    %ecx,%ebx
  8002c8:	89 cf                	mov    %ecx,%edi
  8002ca:	89 ce                	mov    %ecx,%esi
  8002cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 17                	jle    8002e9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	50                   	push   %eax
  8002d6:	6a 0c                	push   $0xc
  8002d8:	68 ca 0f 80 00       	push   $0x800fca
  8002dd:	6a 23                	push   $0x23
  8002df:	68 e7 0f 80 00       	push   $0x800fe7
  8002e4:	e8 08 00 00 00       	call   8002f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002ff:	e8 00 fe ff ff       	call   800104 <sys_getenvid>
  800304:	83 ec 0c             	sub    $0xc,%esp
  800307:	ff 75 0c             	pushl  0xc(%ebp)
  80030a:	ff 75 08             	pushl  0x8(%ebp)
  80030d:	56                   	push   %esi
  80030e:	50                   	push   %eax
  80030f:	68 f8 0f 80 00       	push   $0x800ff8
  800314:	e8 b1 00 00 00       	call   8003ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	53                   	push   %ebx
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	e8 54 00 00 00       	call   800379 <vcprintf>
	cprintf("\n");
  800325:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  80032c:	e8 99 00 00 00       	call   8003ca <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800334:	cc                   	int3   
  800335:	eb fd                	jmp    800334 <_panic+0x43>

00800337 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	53                   	push   %ebx
  80033b:	83 ec 04             	sub    $0x4,%esp
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800341:	8b 13                	mov    (%ebx),%edx
  800343:	8d 42 01             	lea    0x1(%edx),%eax
  800346:	89 03                	mov    %eax,(%ebx)
  800348:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800354:	75 1a                	jne    800370 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	68 ff 00 00 00       	push   $0xff
  80035e:	8d 43 08             	lea    0x8(%ebx),%eax
  800361:	50                   	push   %eax
  800362:	e8 1f fd ff ff       	call   800086 <sys_cputs>
		b->idx = 0;
  800367:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80036d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800370:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800382:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800389:	00 00 00 
	b.cnt = 0;
  80038c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800393:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800396:	ff 75 0c             	pushl  0xc(%ebp)
  800399:	ff 75 08             	pushl  0x8(%ebp)
  80039c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a2:	50                   	push   %eax
  8003a3:	68 37 03 80 00       	push   $0x800337
  8003a8:	e8 1a 01 00 00       	call   8004c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ad:	83 c4 08             	add    $0x8,%esp
  8003b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003bc:	50                   	push   %eax
  8003bd:	e8 c4 fc ff ff       	call   800086 <sys_cputs>

	return b.cnt;
}
  8003c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d3:	50                   	push   %eax
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	e8 9d ff ff ff       	call   800379 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 1c             	sub    $0x1c,%esp
  8003e7:	89 c7                	mov    %eax,%edi
  8003e9:	89 d6                	mov    %edx,%esi
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800402:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800405:	39 d3                	cmp    %edx,%ebx
  800407:	72 05                	jb     80040e <printnum+0x30>
  800409:	39 45 10             	cmp    %eax,0x10(%ebp)
  80040c:	77 45                	ja     800453 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040e:	83 ec 0c             	sub    $0xc,%esp
  800411:	ff 75 18             	pushl  0x18(%ebp)
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80041a:	53                   	push   %ebx
  80041b:	ff 75 10             	pushl  0x10(%ebp)
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	ff 75 e4             	pushl  -0x1c(%ebp)
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	ff 75 dc             	pushl  -0x24(%ebp)
  80042a:	ff 75 d8             	pushl  -0x28(%ebp)
  80042d:	e8 ee 08 00 00       	call   800d20 <__udivdi3>
  800432:	83 c4 18             	add    $0x18,%esp
  800435:	52                   	push   %edx
  800436:	50                   	push   %eax
  800437:	89 f2                	mov    %esi,%edx
  800439:	89 f8                	mov    %edi,%eax
  80043b:	e8 9e ff ff ff       	call   8003de <printnum>
  800440:	83 c4 20             	add    $0x20,%esp
  800443:	eb 18                	jmp    80045d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	56                   	push   %esi
  800449:	ff 75 18             	pushl  0x18(%ebp)
  80044c:	ff d7                	call   *%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	eb 03                	jmp    800456 <printnum+0x78>
  800453:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800456:	83 eb 01             	sub    $0x1,%ebx
  800459:	85 db                	test   %ebx,%ebx
  80045b:	7f e8                	jg     800445 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	56                   	push   %esi
  800461:	83 ec 04             	sub    $0x4,%esp
  800464:	ff 75 e4             	pushl  -0x1c(%ebp)
  800467:	ff 75 e0             	pushl  -0x20(%ebp)
  80046a:	ff 75 dc             	pushl  -0x24(%ebp)
  80046d:	ff 75 d8             	pushl  -0x28(%ebp)
  800470:	e8 db 09 00 00       	call   800e50 <__umoddi3>
  800475:	83 c4 14             	add    $0x14,%esp
  800478:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80047f:	50                   	push   %eax
  800480:	ff d7                	call   *%edi
}
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800488:	5b                   	pop    %ebx
  800489:	5e                   	pop    %esi
  80048a:	5f                   	pop    %edi
  80048b:	5d                   	pop    %ebp
  80048c:	c3                   	ret    

0080048d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800493:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800497:	8b 10                	mov    (%eax),%edx
  800499:	3b 50 04             	cmp    0x4(%eax),%edx
  80049c:	73 0a                	jae    8004a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	88 02                	mov    %al,(%edx)
}
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    

008004aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b3:	50                   	push   %eax
  8004b4:	ff 75 10             	pushl  0x10(%ebp)
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	ff 75 08             	pushl  0x8(%ebp)
  8004bd:	e8 05 00 00 00       	call   8004c7 <vprintfmt>
	va_end(ap);
}
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	c9                   	leave  
  8004c6:	c3                   	ret    

008004c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	57                   	push   %edi
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
  8004cd:	83 ec 2c             	sub    $0x2c,%esp
  8004d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004d9:	eb 12                	jmp    8004ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	0f 84 42 04 00 00    	je     800925 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	50                   	push   %eax
  8004e8:	ff d6                	call   *%esi
  8004ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	83 f8 25             	cmp    $0x25,%eax
  8004f7:	75 e2                	jne    8004db <vprintfmt+0x14>
  8004f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800504:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
  800517:	eb 07                	jmp    800520 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80051c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8d 47 01             	lea    0x1(%edi),%eax
  800523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800526:	0f b6 07             	movzbl (%edi),%eax
  800529:	0f b6 d0             	movzbl %al,%edx
  80052c:	83 e8 23             	sub    $0x23,%eax
  80052f:	3c 55                	cmp    $0x55,%al
  800531:	0f 87 d3 03 00 00    	ja     80090a <vprintfmt+0x443>
  800537:	0f b6 c0             	movzbl %al,%eax
  80053a:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800544:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800548:	eb d6                	jmp    800520 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800555:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800558:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80055c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80055f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800562:	83 f9 09             	cmp    $0x9,%ecx
  800565:	77 3f                	ja     8005a6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800567:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80056a:	eb e9                	jmp    800555 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800580:	eb 2a                	jmp    8005ac <vprintfmt+0xe5>
  800582:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800585:	85 c0                	test   %eax,%eax
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	0f 49 d0             	cmovns %eax,%edx
  80058f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	eb 89                	jmp    800520 <vprintfmt+0x59>
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a1:	e9 7a ff ff ff       	jmp    800520 <vprintfmt+0x59>
  8005a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b0:	0f 89 6a ff ff ff    	jns    800520 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c3:	e9 58 ff ff ff       	jmp    800520 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c8:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ce:	e9 4d ff ff ff       	jmp    800520 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 78 04             	lea    0x4(%eax),%edi
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	ff 30                	pushl  (%eax)
  8005df:	ff d6                	call   *%esi
			break;
  8005e1:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ea:	e9 fe fe ff ff       	jmp    8004ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 78 04             	lea    0x4(%eax),%edi
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	99                   	cltd   
  8005f8:	31 d0                	xor    %edx,%eax
  8005fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fc:	83 f8 09             	cmp    $0x9,%eax
  8005ff:	7f 0b                	jg     80060c <vprintfmt+0x145>
  800601:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	75 1b                	jne    800627 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80060c:	50                   	push   %eax
  80060d:	68 36 10 80 00       	push   $0x801036
  800612:	53                   	push   %ebx
  800613:	56                   	push   %esi
  800614:	e8 91 fe ff ff       	call   8004aa <printfmt>
  800619:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800622:	e9 c6 fe ff ff       	jmp    8004ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800627:	52                   	push   %edx
  800628:	68 3f 10 80 00       	push   $0x80103f
  80062d:	53                   	push   %ebx
  80062e:	56                   	push   %esi
  80062f:	e8 76 fe ff ff       	call   8004aa <printfmt>
  800634:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800637:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063d:	e9 ab fe ff ff       	jmp    8004ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	83 c0 04             	add    $0x4,%eax
  800648:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800650:	85 ff                	test   %edi,%edi
  800652:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  800657:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80065a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065e:	0f 8e 94 00 00 00    	jle    8006f8 <vprintfmt+0x231>
  800664:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800668:	0f 84 98 00 00 00    	je     800706 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	ff 75 d0             	pushl  -0x30(%ebp)
  800674:	57                   	push   %edi
  800675:	e8 33 03 00 00       	call   8009ad <strnlen>
  80067a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067d:	29 c1                	sub    %eax,%ecx
  80067f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800682:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800685:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800689:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	eb 0f                	jmp    8006a2 <vprintfmt+0x1db>
					putch(padc, putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069c:	83 ef 01             	sub    $0x1,%edi
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	7f ed                	jg     800693 <vprintfmt+0x1cc>
  8006a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b3:	0f 49 c1             	cmovns %ecx,%eax
  8006b6:	29 c1                	sub    %eax,%ecx
  8006b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c1:	89 cb                	mov    %ecx,%ebx
  8006c3:	eb 4d                	jmp    800712 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c9:	74 1b                	je     8006e6 <vprintfmt+0x21f>
  8006cb:	0f be c0             	movsbl %al,%eax
  8006ce:	83 e8 20             	sub    $0x20,%eax
  8006d1:	83 f8 5e             	cmp    $0x5e,%eax
  8006d4:	76 10                	jbe    8006e6 <vprintfmt+0x21f>
					putch('?', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	6a 3f                	push   $0x3f
  8006de:	ff 55 08             	call   *0x8(%ebp)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 0d                	jmp    8006f3 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	52                   	push   %edx
  8006ed:	ff 55 08             	call   *0x8(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f3:	83 eb 01             	sub    $0x1,%ebx
  8006f6:	eb 1a                	jmp    800712 <vprintfmt+0x24b>
  8006f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800701:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800704:	eb 0c                	jmp    800712 <vprintfmt+0x24b>
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	0f be d0             	movsbl %al,%edx
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 23                	je     800743 <vprintfmt+0x27c>
  800720:	85 f6                	test   %esi,%esi
  800722:	78 a1                	js     8006c5 <vprintfmt+0x1fe>
  800724:	83 ee 01             	sub    $0x1,%esi
  800727:	79 9c                	jns    8006c5 <vprintfmt+0x1fe>
  800729:	89 df                	mov    %ebx,%edi
  80072b:	8b 75 08             	mov    0x8(%ebp),%esi
  80072e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800731:	eb 18                	jmp    80074b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 20                	push   $0x20
  800739:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 08                	jmp    80074b <vprintfmt+0x284>
  800743:	89 df                	mov    %ebx,%edi
  800745:	8b 75 08             	mov    0x8(%ebp),%esi
  800748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074b:	85 ff                	test   %edi,%edi
  80074d:	7f e4                	jg     800733 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800758:	e9 90 fd ff ff       	jmp    8004ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075d:	83 f9 01             	cmp    $0x1,%ecx
  800760:	7e 19                	jle    80077b <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 50 04             	mov    0x4(%eax),%edx
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 40 08             	lea    0x8(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
  800779:	eb 38                	jmp    8007b3 <vprintfmt+0x2ec>
	else if (lflag)
  80077b:	85 c9                	test   %ecx,%ecx
  80077d:	74 1b                	je     80079a <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800787:	89 c1                	mov    %eax,%ecx
  800789:	c1 f9 1f             	sar    $0x1f,%ecx
  80078c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
  800798:	eb 19                	jmp    8007b3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 c1                	mov    %eax,%ecx
  8007a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c2:	0f 89 0e 01 00 00    	jns    8008d6 <vprintfmt+0x40f>
				putch('-', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 2d                	push   $0x2d
  8007ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d6:	f7 da                	neg    %edx
  8007d8:	83 d1 00             	adc    $0x0,%ecx
  8007db:	f7 d9                	neg    %ecx
  8007dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e5:	e9 ec 00 00 00       	jmp    8008d6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ea:	83 f9 01             	cmp    $0x1,%ecx
  8007ed:	7e 18                	jle    800807 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f7:	8d 40 08             	lea    0x8(%eax),%eax
  8007fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800802:	e9 cf 00 00 00       	jmp    8008d6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800807:	85 c9                	test   %ecx,%ecx
  800809:	74 1a                	je     800825 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	8d 40 04             	lea    0x4(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800820:	e9 b1 00 00 00       	jmp    8008d6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083a:	e9 97 00 00 00       	jmp    8008d6 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	53                   	push   %ebx
  800843:	6a 58                	push   $0x58
  800845:	ff d6                	call   *%esi
			putch('X', putdat);
  800847:	83 c4 08             	add    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	6a 58                	push   $0x58
  80084d:	ff d6                	call   *%esi
			putch('X', putdat);
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 58                	push   $0x58
  800855:	ff d6                	call   *%esi
			break;
  800857:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80085d:	e9 8b fc ff ff       	jmp    8004ed <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	53                   	push   %ebx
  800866:	6a 30                	push   $0x30
  800868:	ff d6                	call   *%esi
			putch('x', putdat);
  80086a:	83 c4 08             	add    $0x8,%esp
  80086d:	53                   	push   %ebx
  80086e:	6a 78                	push   $0x78
  800870:	ff d6                	call   *%esi
			num = (unsigned long long)
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 10                	mov    (%eax),%edx
  800877:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087c:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087f:	8d 40 04             	lea    0x4(%eax),%eax
  800882:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800885:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088a:	eb 4a                	jmp    8008d6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80088c:	83 f9 01             	cmp    $0x1,%ecx
  80088f:	7e 15                	jle    8008a6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 10                	mov    (%eax),%edx
  800896:	8b 48 04             	mov    0x4(%eax),%ecx
  800899:	8d 40 08             	lea    0x8(%eax),%eax
  80089c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80089f:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a4:	eb 30                	jmp    8008d6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 17                	je     8008c1 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8b 10                	mov    (%eax),%edx
  8008af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b4:	8d 40 04             	lea    0x4(%eax),%eax
  8008b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8008bf:	eb 15                	jmp    8008d6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c4:	8b 10                	mov    (%eax),%edx
  8008c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008cb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008d1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d6:	83 ec 0c             	sub    $0xc,%esp
  8008d9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008dd:	57                   	push   %edi
  8008de:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e1:	50                   	push   %eax
  8008e2:	51                   	push   %ecx
  8008e3:	52                   	push   %edx
  8008e4:	89 da                	mov    %ebx,%edx
  8008e6:	89 f0                	mov    %esi,%eax
  8008e8:	e8 f1 fa ff ff       	call   8003de <printnum>
			break;
  8008ed:	83 c4 20             	add    $0x20,%esp
  8008f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f3:	e9 f5 fb ff ff       	jmp    8004ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	52                   	push   %edx
  8008fd:	ff d6                	call   *%esi
			break;
  8008ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800905:	e9 e3 fb ff ff       	jmp    8004ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	6a 25                	push   $0x25
  800910:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 03                	jmp    80091a <vprintfmt+0x453>
  800917:	83 ef 01             	sub    $0x1,%edi
  80091a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091e:	75 f7                	jne    800917 <vprintfmt+0x450>
  800920:	e9 c8 fb ff ff       	jmp    8004ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800925:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	83 ec 18             	sub    $0x18,%esp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800940:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800943:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094a:	85 c0                	test   %eax,%eax
  80094c:	74 26                	je     800974 <vsnprintf+0x47>
  80094e:	85 d2                	test   %edx,%edx
  800950:	7e 22                	jle    800974 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800952:	ff 75 14             	pushl  0x14(%ebp)
  800955:	ff 75 10             	pushl  0x10(%ebp)
  800958:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095b:	50                   	push   %eax
  80095c:	68 8d 04 80 00       	push   $0x80048d
  800961:	e8 61 fb ff ff       	call   8004c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800966:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800969:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	eb 05                	jmp    800979 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800981:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800984:	50                   	push   %eax
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 9a ff ff ff       	call   80092d <vsnprintf>
	va_end(ap);

	return rc;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	eb 03                	jmp    8009a5 <strlen+0x10>
		n++;
  8009a2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a9:	75 f7                	jne    8009a2 <strlen+0xd>
		n++;
	return n;
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	eb 03                	jmp    8009c0 <strnlen+0x13>
		n++;
  8009bd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c0:	39 c2                	cmp    %eax,%edx
  8009c2:	74 08                	je     8009cc <strnlen+0x1f>
  8009c4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c8:	75 f3                	jne    8009bd <strnlen+0x10>
  8009ca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	83 c2 01             	add    $0x1,%edx
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e7:	84 db                	test   %bl,%bl
  8009e9:	75 ef                	jne    8009da <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f5:	53                   	push   %ebx
  8009f6:	e8 9a ff ff ff       	call   800995 <strlen>
  8009fb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	01 d8                	add    %ebx,%eax
  800a03:	50                   	push   %eax
  800a04:	e8 c5 ff ff ff       	call   8009ce <strcpy>
	return dst;
}
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 08             	mov    0x8(%ebp),%esi
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	89 f2                	mov    %esi,%edx
  800a22:	eb 0f                	jmp    800a33 <strncpy+0x23>
		*dst++ = *src;
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	0f b6 01             	movzbl (%ecx),%eax
  800a2a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2d:	80 39 01             	cmpb   $0x1,(%ecx)
  800a30:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 ed                	jne    800a24 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a37:	89 f0                	mov    %esi,%eax
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 75 08             	mov    0x8(%ebp),%esi
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4d:	85 d2                	test   %edx,%edx
  800a4f:	74 21                	je     800a72 <strlcpy+0x35>
  800a51:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a55:	89 f2                	mov    %esi,%edx
  800a57:	eb 09                	jmp    800a62 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a59:	83 c2 01             	add    $0x1,%edx
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a62:	39 c2                	cmp    %eax,%edx
  800a64:	74 09                	je     800a6f <strlcpy+0x32>
  800a66:	0f b6 19             	movzbl (%ecx),%ebx
  800a69:	84 db                	test   %bl,%bl
  800a6b:	75 ec                	jne    800a59 <strlcpy+0x1c>
  800a6d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a72:	29 f0                	sub    %esi,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strcmp+0x11>
		p++, q++;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	84 c0                	test   %al,%al
  800a8e:	74 04                	je     800a94 <strcmp+0x1c>
  800a90:	3a 02                	cmp    (%edx),%al
  800a92:	74 ef                	je     800a83 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a94:	0f b6 c0             	movzbl %al,%eax
  800a97:	0f b6 12             	movzbl (%edx),%edx
  800a9a:	29 d0                	sub    %edx,%eax
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aad:	eb 06                	jmp    800ab5 <strncmp+0x17>
		n--, p++, q++;
  800aaf:	83 c0 01             	add    $0x1,%eax
  800ab2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab5:	39 d8                	cmp    %ebx,%eax
  800ab7:	74 15                	je     800ace <strncmp+0x30>
  800ab9:	0f b6 08             	movzbl (%eax),%ecx
  800abc:	84 c9                	test   %cl,%cl
  800abe:	74 04                	je     800ac4 <strncmp+0x26>
  800ac0:	3a 0a                	cmp    (%edx),%cl
  800ac2:	74 eb                	je     800aaf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac4:	0f b6 00             	movzbl (%eax),%eax
  800ac7:	0f b6 12             	movzbl (%edx),%edx
  800aca:	29 d0                	sub    %edx,%eax
  800acc:	eb 05                	jmp    800ad3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	eb 07                	jmp    800ae9 <strchr+0x13>
		if (*s == c)
  800ae2:	38 ca                	cmp    %cl,%dl
  800ae4:	74 0f                	je     800af5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 10             	movzbl (%eax),%edx
  800aec:	84 d2                	test   %dl,%dl
  800aee:	75 f2                	jne    800ae2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 03                	jmp    800b06 <strfind+0xf>
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b09:	38 ca                	cmp    %cl,%dl
  800b0b:	74 04                	je     800b11 <strfind+0x1a>
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strfind+0xc>
			break;
	return (char *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1f:	85 c9                	test   %ecx,%ecx
  800b21:	74 36                	je     800b59 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b23:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b29:	75 28                	jne    800b53 <memset+0x40>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	75 23                	jne    800b53 <memset+0x40>
		c &= 0xFF;
  800b30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	c1 e3 08             	shl    $0x8,%ebx
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	c1 e6 18             	shl    $0x18,%esi
  800b3e:	89 d0                	mov    %edx,%eax
  800b40:	c1 e0 10             	shl    $0x10,%eax
  800b43:	09 f0                	or     %esi,%eax
  800b45:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b47:	89 d8                	mov    %ebx,%eax
  800b49:	09 d0                	or     %edx,%eax
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
  800b4e:	fc                   	cld    
  800b4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b51:	eb 06                	jmp    800b59 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	fc                   	cld    
  800b57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b59:	89 f8                	mov    %edi,%eax
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6e:	39 c6                	cmp    %eax,%esi
  800b70:	73 35                	jae    800ba7 <memmove+0x47>
  800b72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b75:	39 d0                	cmp    %edx,%eax
  800b77:	73 2e                	jae    800ba7 <memmove+0x47>
		s += n;
		d += n;
  800b79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	09 fe                	or     %edi,%esi
  800b80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b86:	75 13                	jne    800b9b <memmove+0x3b>
  800b88:	f6 c1 03             	test   $0x3,%cl
  800b8b:	75 0e                	jne    800b9b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8d:	83 ef 04             	sub    $0x4,%edi
  800b90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b93:	c1 e9 02             	shr    $0x2,%ecx
  800b96:	fd                   	std    
  800b97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b99:	eb 09                	jmp    800ba4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9b:	83 ef 01             	sub    $0x1,%edi
  800b9e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba1:	fd                   	std    
  800ba2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba4:	fc                   	cld    
  800ba5:	eb 1d                	jmp    800bc4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba7:	89 f2                	mov    %esi,%edx
  800ba9:	09 c2                	or     %eax,%edx
  800bab:	f6 c2 03             	test   $0x3,%dl
  800bae:	75 0f                	jne    800bbf <memmove+0x5f>
  800bb0:	f6 c1 03             	test   $0x3,%cl
  800bb3:	75 0a                	jne    800bbf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb5:	c1 e9 02             	shr    $0x2,%ecx
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	fc                   	cld    
  800bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbd:	eb 05                	jmp    800bc4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbf:	89 c7                	mov    %eax,%edi
  800bc1:	fc                   	cld    
  800bc2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcb:	ff 75 10             	pushl  0x10(%ebp)
  800bce:	ff 75 0c             	pushl  0xc(%ebp)
  800bd1:	ff 75 08             	pushl  0x8(%ebp)
  800bd4:	e8 87 ff ff ff       	call   800b60 <memmove>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800beb:	eb 1a                	jmp    800c07 <memcmp+0x2c>
		if (*s1 != *s2)
  800bed:	0f b6 08             	movzbl (%eax),%ecx
  800bf0:	0f b6 1a             	movzbl (%edx),%ebx
  800bf3:	38 d9                	cmp    %bl,%cl
  800bf5:	74 0a                	je     800c01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf7:	0f b6 c1             	movzbl %cl,%eax
  800bfa:	0f b6 db             	movzbl %bl,%ebx
  800bfd:	29 d8                	sub    %ebx,%eax
  800bff:	eb 0f                	jmp    800c10 <memcmp+0x35>
		s1++, s2++;
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c07:	39 f0                	cmp    %esi,%eax
  800c09:	75 e2                	jne    800bed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1b:	89 c1                	mov    %eax,%ecx
  800c1d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c20:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c24:	eb 0a                	jmp    800c30 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	0f b6 10             	movzbl (%eax),%edx
  800c29:	39 da                	cmp    %ebx,%edx
  800c2b:	74 07                	je     800c34 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2d:	83 c0 01             	add    $0x1,%eax
  800c30:	39 c8                	cmp    %ecx,%eax
  800c32:	72 f2                	jb     800c26 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	eb 03                	jmp    800c48 <strtol+0x11>
		s++;
  800c45:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 01             	movzbl (%ecx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 f6                	je     800c45 <strtol+0xe>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	74 f2                	je     800c45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 0a                	jne    800c61 <strtol+0x2a>
		s++;
  800c57:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb 11                	jmp    800c72 <strtol+0x3b>
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c66:	3c 2d                	cmp    $0x2d,%al
  800c68:	75 08                	jne    800c72 <strtol+0x3b>
		s++, neg = 1;
  800c6a:	83 c1 01             	add    $0x1,%ecx
  800c6d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c78:	75 15                	jne    800c8f <strtol+0x58>
  800c7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7d:	75 10                	jne    800c8f <strtol+0x58>
  800c7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c83:	75 7c                	jne    800d01 <strtol+0xca>
		s += 2, base = 16;
  800c85:	83 c1 02             	add    $0x2,%ecx
  800c88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8d:	eb 16                	jmp    800ca5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 12                	jne    800ca5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c93:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c98:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9b:	75 08                	jne    800ca5 <strtol+0x6e>
		s++, base = 8;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  800caa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cad:	0f b6 11             	movzbl (%ecx),%edx
  800cb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 09             	cmp    $0x9,%bl
  800cb8:	77 08                	ja     800cc2 <strtol+0x8b>
			dig = *s - '0';
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	83 ea 30             	sub    $0x30,%edx
  800cc0:	eb 22                	jmp    800ce4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc5:	89 f3                	mov    %esi,%ebx
  800cc7:	80 fb 19             	cmp    $0x19,%bl
  800cca:	77 08                	ja     800cd4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ccc:	0f be d2             	movsbl %dl,%edx
  800ccf:	83 ea 57             	sub    $0x57,%edx
  800cd2:	eb 10                	jmp    800ce4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd7:	89 f3                	mov    %esi,%ebx
  800cd9:	80 fb 19             	cmp    $0x19,%bl
  800cdc:	77 16                	ja     800cf4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cde:	0f be d2             	movsbl %dl,%edx
  800ce1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce7:	7d 0b                	jge    800cf4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf2:	eb b9                	jmp    800cad <strtol+0x76>

	if (endptr)
  800cf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf8:	74 0d                	je     800d07 <strtol+0xd0>
		*endptr = (char *) s;
  800cfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfd:	89 0e                	mov    %ecx,(%esi)
  800cff:	eb 06                	jmp    800d07 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d01:	85 db                	test   %ebx,%ebx
  800d03:	74 98                	je     800c9d <strtol+0x66>
  800d05:	eb 9e                	jmp    800ca5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d07:	89 c2                	mov    %eax,%edx
  800d09:	f7 da                	neg    %edx
  800d0b:	85 ff                	test   %edi,%edi
  800d0d:	0f 45 c2             	cmovne %edx,%eax
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
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
