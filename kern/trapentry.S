
/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
 /*有中断处理码的中断预处理*/
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
 /*无中断处理码的中断预处理，这里压入0填补空缺*/
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text
/*
由用户模式发生中断进入内核时，CPU会切换到内核栈，并压入旧的 SS, ESP, EFLAGS, CS, EIP寄存器的值。
接着，执行中断处理程序。先通过 TRAPHANDLER压入中断向量以及错误码(如果有)，
然后在_alltraps中压入旧的DS, ES寄存器以及通用寄存器的值，接着将DS, ES寄存器设置为GD_KD，
并将此时 ESP寄存器的值压入到内核栈中作为trap函数的参数，然后才调用trap(tf)函数
*/

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

 /*初始化中断处理函数,使中断向量和中断处理函数对应,压入中断向量以及错误码*/
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
TRAPHANDLER_NOEC(handler1, T_DEBUG)
TRAPHANDLER_NOEC(handler2, T_NMI)
TRAPHANDLER_NOEC(handler3, T_BRKPT)
TRAPHANDLER_NOEC(handler4, T_OFLOW)
TRAPHANDLER_NOEC(handler5, T_BOUND)
TRAPHANDLER_NOEC(handler6, T_ILLOP)
TRAPHANDLER(handler7, T_DEVICE)
TRAPHANDLER_NOEC(handler8, T_DBLFLT)
TRAPHANDLER(handler10, T_TSS)
TRAPHANDLER(handler11, T_SEGNP)
TRAPHANDLER(handler12, T_STACK)
TRAPHANDLER(handler13, T_GPFLT)
TRAPHANDLER(handler14, T_PGFLT)
TRAPHANDLER_NOEC(handler16, T_FPERR)
TRAPHANDLER_NOEC(handler48, T_SYSCALL)


/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds 
	pushl %es 
	pushal	/*将通用寄存器压栈,EAX,ECX,EDX,EBX,ESP(初始值)，EBP,ESI,EDI.*/

	movw $GD_KD, %ax /*将DS, ES寄存器设置为GD_KD	ps:段寄存器ds，es在mov指令中不支持立即数，所以用到ax寄存器中转下数据*/
	movw %ax, %ds 
	movw %ax, %es 

	pushl %esp
	call trap /*never return*/
