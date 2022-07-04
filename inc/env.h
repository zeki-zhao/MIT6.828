/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ENV_H
#define JOS_INC_ENV_H

#include <inc/types.h>
#include <inc/trap.h>
#include <inc/memlayout.h>

typedef int32_t envid_t;

// An environment ID 'envid_t' has three parts:
//
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/
//
// The environment index ENVX(eid) equals the environment's offset in the
// 'envs[]' array.  The uniqueifier distinguishes environments that were
// created at different times, but share the same environment index.
//
// All real environments are greater than 0 (so the sign bit is zero).
// envid_ts less than 0 signify errors.  The envid_t == 0 is special, and
// stands for the current environment.

#define LOG2NENV		10
#define NENV			(1 << LOG2NENV) //最大支持1024个进程并发
#define ENVX(envid)		((envid) & (NENV - 1))

// Values of env_status in struct Env
enum {
	ENV_FREE = 0,
	ENV_DYING,
	ENV_RUNNABLE,
	ENV_RUNNING,
	ENV_NOT_RUNNABLE
};

// Special environment types
enum EnvType {
	ENV_TYPE_USER = 0,
};

struct Env {
	struct Trapframe env_tf;// Saved registers 							当进程停止运行时用于保存寄存器的值
	struct Env *env_link;	// Next free Env 							指向在env_free_list中，该结构体的后一个free的Env结构体
	envid_t env_id;			// Unique environment identifier 			这个值可以唯一的确定使用这个结构体的用户环境是什么
	envid_t env_parent_id;	// env_id of this env's parent				创建这个用户环境的父用户环境的env_id
	enum EnvType env_type;	// Indicates special system environments	用于区别某个特定的用户环境
	unsigned env_status;	// Status of the environment
	uint32_t env_runs;	// Number of times environment has run			这个环境的页目录的虚拟地址

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir		于保存进程页目录的虚拟地址
}; 

#endif // !JOS_INC_ENV_H
