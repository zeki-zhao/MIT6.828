#include <inc/x86.h>
#include <inc/elf.h>

/**********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(boot.S and main.c) is the bootloader.  It should
 *    be stored in the first sector of the disk.
 *
 *  * The 2nd sector onward holds the kernel image.
 *
 *  * The kernel image must be in ELF format.
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in boot.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 **********************************************************************/

#define SECTSIZE	512
//ELF header在内存当中临时存放的地址
#define ELFHDR		((struct Elf *) 0x10000) // scratch space

void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
	struct Proghdr *ph, *eph;
	/* 
		将系统kernel文件中偏移量的4096字节数据读到0x10000处，
		这是因为readelf -l kernel显示第一个需要被加载的段的地址在偏移两0x1000处，说明前面全部都是
		ELF header的内容，所以我们先将ELF header的内容读到内存当中 
	*/
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
		// p_pa is the load address of this segment (as well
		// as the physical address)
				//根据readelf -l kernel的输出结果，第一个段的offset = 0x1000,p_pa = 0x00100000,size = 0x07dac
                // 所以我们要做的就是，系统镜像偏移0x1000处读取0x07dac个字节的数据到0x00100000
                // 在readseg函数中，我们将offset转为真正的扇区号，因为镜像是存放在第1扇区开始的，所以
                //这个是可以计算的
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;//Zeki:here define the num of sectors it must read in order to fetch the entire kernel from disk

	// round down to sector boundary
	 //这里是因为pa不一定都是512字节对齐的，我们将pa做一个512字节对齐
    //下面进行一个举例，例如pa=700，~(512-1) = 0x1110_0000_0000
    //700 & 0x1110_0000_0000 = 0x200 = 512，这样我们就做到了对齐
	pa &= ~(SECTSIZE - 1);

	//使用偏移量来计算所要读取的扇区是哪个
	//，比如说上面的offset = 0x1000,0x1000/512+1 = 9，就是读取9号扇区。
	//扇区号+1这个应该是这样理解的，
	//硬盘扇区默认就是从1扇区开始计算的。
	//如果我们要读取511字节的内容,511/512=0，肯定是不对的。所以要+1
	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
	// wait for disk to be ready
	waitdisk();

	//使用LBA模式的逻辑扇区方式来寻找扇区,这里和硬件相关
      //就暂且不要管好了，涉及到的硬件细节太多了，确实很麻烦
	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();

	//一次读取的单位是四个字节，所以循环sectorsize/4 = 128次
	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}

