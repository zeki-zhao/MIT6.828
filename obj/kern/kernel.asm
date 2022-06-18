
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 39 11 f0       	mov    $0xf0113970,%eax
f010004b:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 33 11 f0       	push   $0xf0113300
f0100058:	e8 a4 17 00 00       	call   f0101801 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 88 04 00 00       	call   f01004ea <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 1c 10 f0       	push   $0xf0101ca0
f010006f:	e8 a4 0c 00 00       	call   f0100d18 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2f 08 00 00       	call   f01008a8 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 89 06 00 00       	call   f010070f <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 39 11 f0 00 	cmpl   $0x0,0xf0113960
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 60 39 11 f0    	mov    %esi,0xf0113960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 bb 1c 10 f0       	push   $0xf0101cbb
f01000b5:	e8 5e 0c 00 00       	call   f0100d18 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 2e 0c 00 00       	call   f0100cf2 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 f7 1c 10 f0 	movl   $0xf0101cf7,(%esp)
f01000cb:	e8 48 0c 00 00       	call   f0100d18 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 32 06 00 00       	call   f010070f <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 d3 1c 10 f0       	push   $0xf0101cd3
f01000f7:	e8 1c 0c 00 00       	call   f0100d18 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 ea 0b 00 00       	call   f0100cf2 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 f7 1c 10 f0 	movl   $0xf0101cf7,(%esp)
f010010f:	e8 04 0c 00 00       	call   f0100d18 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 35 11 f0    	mov    0xf0113524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 35 11 f0    	mov    %edx,0xf0113524
f0100159:	88 81 20 33 11 f0    	mov    %al,-0xfeecce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 35 11 f0 00 	movl   $0x0,0xf0113524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f0 00 00 00    	je     f010027c <kbd_proc_data+0xfe>
f010018c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100191:	ec                   	in     (%dx),%al
f0100192:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100194:	3c e0                	cmp    $0xe0,%al
f0100196:	75 0d                	jne    f01001a5 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100198:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
		return 0;
f010019f:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001a4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a5:	55                   	push   %ebp
f01001a6:	89 e5                	mov    %esp,%ebp
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001ac:	84 c0                	test   %al,%al
f01001ae:	79 36                	jns    f01001e6 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b0:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001b6:	89 cb                	mov    %ecx,%ebx
f01001b8:	83 e3 40             	and    $0x40,%ebx
f01001bb:	83 e0 7f             	and    $0x7f,%eax
f01001be:	85 db                	test   %ebx,%ebx
f01001c0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001c3:	0f b6 d2             	movzbl %dl,%edx
f01001c6:	0f b6 82 40 1e 10 f0 	movzbl -0xfefe1c0(%edx),%eax
f01001cd:	83 c8 40             	or     $0x40,%eax
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	f7 d0                	not    %eax
f01001d5:	21 c8                	and    %ecx,%eax
f01001d7:	a3 00 33 11 f0       	mov    %eax,0xf0113300
		return 0;
f01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e1:	e9 9e 00 00 00       	jmp    f0100284 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e6:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001ec:	f6 c1 40             	test   $0x40,%cl
f01001ef:	74 0e                	je     f01001ff <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f1:	83 c8 80             	or     $0xffffff80,%eax
f01001f4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f9:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
	}

	shift |= shiftcode[data];
f01001ff:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100202:	0f b6 82 40 1e 10 f0 	movzbl -0xfefe1c0(%edx),%eax
f0100209:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
f010020f:	0f b6 8a 40 1d 10 f0 	movzbl -0xfefe2c0(%edx),%ecx
f0100216:	31 c8                	xor    %ecx,%eax
f0100218:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f010021d:	89 c1                	mov    %eax,%ecx
f010021f:	83 e1 03             	and    $0x3,%ecx
f0100222:	8b 0c 8d 20 1d 10 f0 	mov    -0xfefe2e0(,%ecx,4),%ecx
f0100229:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010022d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100230:	a8 08                	test   $0x8,%al
f0100232:	74 1b                	je     f010024f <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100234:	89 da                	mov    %ebx,%edx
f0100236:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100239:	83 f9 19             	cmp    $0x19,%ecx
f010023c:	77 05                	ja     f0100243 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010023e:	83 eb 20             	sub    $0x20,%ebx
f0100241:	eb 0c                	jmp    f010024f <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100243:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100246:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024f:	f7 d0                	not    %eax
f0100251:	a8 06                	test   $0x6,%al
f0100253:	75 2d                	jne    f0100282 <kbd_proc_data+0x104>
f0100255:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010025b:	75 25                	jne    f0100282 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025d:	83 ec 0c             	sub    $0xc,%esp
f0100260:	68 ed 1c 10 f0       	push   $0xf0101ced
f0100265:	e8 ae 0a 00 00       	call   f0100d18 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026a:	ba 92 00 00 00       	mov    $0x92,%edx
f010026f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100274:	ee                   	out    %al,(%dx)
f0100275:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100278:	89 d8                	mov    %ebx,%eax
f010027a:	eb 08                	jmp    f0100284 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100282:	89 d8                	mov    %ebx,%eax
}
f0100284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100287:	c9                   	leave  
f0100288:	c3                   	ret    

f0100289 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100289:	55                   	push   %ebp
f010028a:	89 e5                	mov    %esp,%ebp
f010028c:	57                   	push   %edi
f010028d:	56                   	push   %esi
f010028e:	53                   	push   %ebx
f010028f:	83 ec 1c             	sub    $0x1c,%esp
f0100292:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100294:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100299:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029e:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a3:	eb 09                	jmp    f01002ae <cons_putc+0x25>
f01002a5:	89 ca                	mov    %ecx,%edx
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
f01002a9:	ec                   	in     (%dx),%al
f01002aa:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ab:	83 c3 01             	add    $0x1,%ebx
f01002ae:	89 f2                	mov    %esi,%edx
f01002b0:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b1:	a8 20                	test   $0x20,%al
f01002b3:	75 08                	jne    f01002bd <cons_putc+0x34>
f01002b5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002bb:	7e e8                	jle    f01002a5 <cons_putc+0x1c>
f01002bd:	89 f8                	mov    %edi,%eax
f01002bf:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x59>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002eb:	7f 04                	jg     f01002f1 <cons_putc+0x68>
f01002ed:	84 c0                	test   %al,%al
f01002ef:	79 e8                	jns    f01002d9 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100300:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100305:	ee                   	out    %al,(%dx)
f0100306:	b8 08 00 00 00       	mov    $0x8,%eax
f010030b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010030c:	89 fa                	mov    %edi,%edx
f010030e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100314:	89 f8                	mov    %edi,%eax
f0100316:	80 cc 07             	or     $0x7,%ah
f0100319:	85 d2                	test   %edx,%edx
f010031b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031e:	89 f8                	mov    %edi,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	83 f8 09             	cmp    $0x9,%eax
f0100326:	74 74                	je     f010039c <cons_putc+0x113>
f0100328:	83 f8 09             	cmp    $0x9,%eax
f010032b:	7f 0a                	jg     f0100337 <cons_putc+0xae>
f010032d:	83 f8 08             	cmp    $0x8,%eax
f0100330:	74 14                	je     f0100346 <cons_putc+0xbd>
f0100332:	e9 99 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
f0100337:	83 f8 0a             	cmp    $0xa,%eax
f010033a:	74 3a                	je     f0100376 <cons_putc+0xed>
f010033c:	83 f8 0d             	cmp    $0xd,%eax
f010033f:	74 3d                	je     f010037e <cons_putc+0xf5>
f0100341:	e9 8a 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100346:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010034d:	66 85 c0             	test   %ax,%ax
f0100350:	0f 84 e6 00 00 00    	je     f010043c <cons_putc+0x1b3>
			crt_pos--;
f0100356:	83 e8 01             	sub    $0x1,%eax
f0100359:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010035f:	0f b7 c0             	movzwl %ax,%eax
f0100362:	66 81 e7 00 ff       	and    $0xff00,%di
f0100367:	83 cf 20             	or     $0x20,%edi
f010036a:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100370:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100374:	eb 78                	jmp    f01003ee <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100376:	66 83 05 28 35 11 f0 	addw   $0x50,0xf0113528
f010037d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010037e:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f0100385:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010038b:	c1 e8 16             	shr    $0x16,%eax
f010038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100391:	c1 e0 04             	shl    $0x4,%eax
f0100394:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
f010039a:	eb 52                	jmp    f01003ee <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010039c:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a1:	e8 e3 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003a6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ab:	e8 d9 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b5:	e8 cf fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bf:	e8 c5 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c9:	e8 bb fe ff ff       	call   f0100289 <cons_putc>
f01003ce:	eb 1e                	jmp    f01003ee <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003d0:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f01003d7:	8d 50 01             	lea    0x1(%eax),%edx
f01003da:	66 89 15 28 35 11 f0 	mov    %dx,0xf0113528
f01003e1:	0f b7 c0             	movzwl %ax,%eax
f01003e4:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f01003ea:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003ee:	66 81 3d 28 35 11 f0 	cmpw   $0x7cf,0xf0113528
f01003f5:	cf 07 
f01003f7:	76 43                	jbe    f010043c <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f9:	a1 2c 35 11 f0       	mov    0xf011352c,%eax
f01003fe:	83 ec 04             	sub    $0x4,%esp
f0100401:	68 00 0f 00 00       	push   $0xf00
f0100406:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010040c:	52                   	push   %edx
f010040d:	50                   	push   %eax
f010040e:	e8 3b 14 00 00       	call   f010184e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100413:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100419:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100425:	83 c4 10             	add    $0x10,%esp
f0100428:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010042d:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100430:	39 d0                	cmp    %edx,%eax
f0100432:	75 f4                	jne    f0100428 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100434:	66 83 2d 28 35 11 f0 	subw   $0x50,0xf0113528
f010043b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010043c:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f0100442:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100447:	89 ca                	mov    %ecx,%edx
f0100449:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010044a:	0f b7 1d 28 35 11 f0 	movzwl 0xf0113528,%ebx
f0100451:	8d 71 01             	lea    0x1(%ecx),%esi
f0100454:	89 d8                	mov    %ebx,%eax
f0100456:	66 c1 e8 08          	shr    $0x8,%ax
f010045a:	89 f2                	mov    %esi,%edx
f010045c:	ee                   	out    %al,(%dx)
f010045d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100462:	89 ca                	mov    %ecx,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	89 d8                	mov    %ebx,%eax
f0100467:	89 f2                	mov    %esi,%edx
f0100469:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046d:	5b                   	pop    %ebx
f010046e:	5e                   	pop    %esi
f010046f:	5f                   	pop    %edi
f0100470:	5d                   	pop    %ebp
f0100471:	c3                   	ret    

f0100472 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100472:	80 3d 34 35 11 f0 00 	cmpb   $0x0,0xf0113534
f0100479:	74 11                	je     f010048c <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010047b:	55                   	push   %ebp
f010047c:	89 e5                	mov    %esp,%ebp
f010047e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100481:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100486:	e8 b0 fc ff ff       	call   f010013b <cons_intr>
}
f010048b:	c9                   	leave  
f010048c:	f3 c3                	repz ret 

f010048e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048e:	55                   	push   %ebp
f010048f:	89 e5                	mov    %esp,%ebp
f0100491:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100494:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f0100499:	e8 9d fc ff ff       	call   f010013b <cons_intr>
}
f010049e:	c9                   	leave  
f010049f:	c3                   	ret    

f01004a0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a6:	e8 c7 ff ff ff       	call   f0100472 <serial_intr>
	kbd_intr();
f01004ab:	e8 de ff ff ff       	call   f010048e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004b0:	a1 20 35 11 f0       	mov    0xf0113520,%eax
f01004b5:	3b 05 24 35 11 f0    	cmp    0xf0113524,%eax
f01004bb:	74 26                	je     f01004e3 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004bd:	8d 50 01             	lea    0x1(%eax),%edx
f01004c0:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
f01004c6:	0f b6 88 20 33 11 f0 	movzbl -0xfeecce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004cd:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004cf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004d5:	75 11                	jne    f01004e8 <cons_getc+0x48>
			cons.rpos = 0;
f01004d7:	c7 05 20 35 11 f0 00 	movl   $0x0,0xf0113520
f01004de:	00 00 00 
f01004e1:	eb 05                	jmp    f01004e8 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e8:	c9                   	leave  
f01004e9:	c3                   	ret    

f01004ea <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ea:	55                   	push   %ebp
f01004eb:	89 e5                	mov    %esp,%ebp
f01004ed:	57                   	push   %edi
f01004ee:	56                   	push   %esi
f01004ef:	53                   	push   %ebx
f01004f0:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f3:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004fa:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100501:	5a a5 
	if (*cp != 0xA55A) {
f0100503:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010050a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010050e:	74 11                	je     f0100521 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100510:	c7 05 30 35 11 f0 b4 	movl   $0x3b4,0xf0113530
f0100517:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010051a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010051f:	eb 16                	jmp    f0100537 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100521:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100528:	c7 05 30 35 11 f0 d4 	movl   $0x3d4,0xf0113530
f010052f:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100532:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100537:	8b 3d 30 35 11 f0    	mov    0xf0113530,%edi
f010053d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100542:	89 fa                	mov    %edi,%edx
f0100544:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100545:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100548:	89 da                	mov    %ebx,%edx
f010054a:	ec                   	in     (%dx),%al
f010054b:	0f b6 c8             	movzbl %al,%ecx
f010054e:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100551:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100556:	89 fa                	mov    %edi,%edx
f0100558:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100559:	89 da                	mov    %ebx,%edx
f010055b:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055c:	89 35 2c 35 11 f0    	mov    %esi,0xf011352c
	crt_pos = pos;
f0100562:	0f b6 c0             	movzbl %al,%eax
f0100565:	09 c8                	or     %ecx,%eax
f0100567:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056d:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100572:	b8 00 00 00 00       	mov    $0x0,%eax
f0100577:	89 f2                	mov    %esi,%edx
f0100579:	ee                   	out    %al,(%dx)
f010057a:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010057f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100584:	ee                   	out    %al,(%dx)
f0100585:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010058a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058f:	89 da                	mov    %ebx,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100597:	b8 00 00 00 00       	mov    $0x0,%eax
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 03 00 00 00       	mov    $0x3,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01005bd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005be:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005c3:	ec                   	in     (%dx),%al
f01005c4:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c6:	3c ff                	cmp    $0xff,%al
f01005c8:	0f 95 05 34 35 11 f0 	setne  0xf0113534
f01005cf:	89 f2                	mov    %esi,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 da                	mov    %ebx,%edx
f01005d4:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d5:	80 f9 ff             	cmp    $0xff,%cl
f01005d8:	75 10                	jne    f01005ea <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005da:	83 ec 0c             	sub    $0xc,%esp
f01005dd:	68 f9 1c 10 f0       	push   $0xf0101cf9
f01005e2:	e8 31 07 00 00       	call   f0100d18 <cprintf>
f01005e7:	83 c4 10             	add    $0x10,%esp
}
f01005ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ed:	5b                   	pop    %ebx
f01005ee:	5e                   	pop    %esi
f01005ef:	5f                   	pop    %edi
f01005f0:	5d                   	pop    %ebp
f01005f1:	c3                   	ret    

f01005f2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fb:	e8 89 fc ff ff       	call   f0100289 <cons_putc>
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <getchar>:

int
getchar(void)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100608:	e8 93 fe ff ff       	call   f01004a0 <cons_getc>
f010060d:	85 c0                	test   %eax,%eax
f010060f:	74 f7                	je     f0100608 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100611:	c9                   	leave  
f0100612:	c3                   	ret    

f0100613 <iscons>:

int
iscons(int fdnum)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100616:	b8 01 00 00 00       	mov    $0x1,%eax
f010061b:	5d                   	pop    %ebp
f010061c:	c3                   	ret    

f010061d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010061d:	55                   	push   %ebp
f010061e:	89 e5                	mov    %esp,%ebp
f0100620:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100623:	68 40 1f 10 f0       	push   $0xf0101f40
f0100628:	68 5e 1f 10 f0       	push   $0xf0101f5e
f010062d:	68 63 1f 10 f0       	push   $0xf0101f63
f0100632:	e8 e1 06 00 00       	call   f0100d18 <cprintf>
f0100637:	83 c4 0c             	add    $0xc,%esp
f010063a:	68 cc 1f 10 f0       	push   $0xf0101fcc
f010063f:	68 6c 1f 10 f0       	push   $0xf0101f6c
f0100644:	68 63 1f 10 f0       	push   $0xf0101f63
f0100649:	e8 ca 06 00 00       	call   f0100d18 <cprintf>
	return 0;
}
f010064e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100653:	c9                   	leave  
f0100654:	c3                   	ret    

f0100655 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010065b:	68 75 1f 10 f0       	push   $0xf0101f75
f0100660:	e8 b3 06 00 00       	call   f0100d18 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100665:	83 c4 08             	add    $0x8,%esp
f0100668:	68 0c 00 10 00       	push   $0x10000c
f010066d:	68 f4 1f 10 f0       	push   $0xf0101ff4
f0100672:	e8 a1 06 00 00       	call   f0100d18 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100677:	83 c4 0c             	add    $0xc,%esp
f010067a:	68 0c 00 10 00       	push   $0x10000c
f010067f:	68 0c 00 10 f0       	push   $0xf010000c
f0100684:	68 1c 20 10 f0       	push   $0xf010201c
f0100689:	e8 8a 06 00 00       	call   f0100d18 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010068e:	83 c4 0c             	add    $0xc,%esp
f0100691:	68 91 1c 10 00       	push   $0x101c91
f0100696:	68 91 1c 10 f0       	push   $0xf0101c91
f010069b:	68 40 20 10 f0       	push   $0xf0102040
f01006a0:	e8 73 06 00 00       	call   f0100d18 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 00 33 11 00       	push   $0x113300
f01006ad:	68 00 33 11 f0       	push   $0xf0113300
f01006b2:	68 64 20 10 f0       	push   $0xf0102064
f01006b7:	e8 5c 06 00 00       	call   f0100d18 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006bc:	83 c4 0c             	add    $0xc,%esp
f01006bf:	68 70 39 11 00       	push   $0x113970
f01006c4:	68 70 39 11 f0       	push   $0xf0113970
f01006c9:	68 88 20 10 f0       	push   $0xf0102088
f01006ce:	e8 45 06 00 00       	call   f0100d18 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006d3:	b8 6f 3d 11 f0       	mov    $0xf0113d6f,%eax
f01006d8:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006dd:	83 c4 08             	add    $0x8,%esp
f01006e0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006e5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006eb:	85 c0                	test   %eax,%eax
f01006ed:	0f 48 c2             	cmovs  %edx,%eax
f01006f0:	c1 f8 0a             	sar    $0xa,%eax
f01006f3:	50                   	push   %eax
f01006f4:	68 ac 20 10 f0       	push   $0xf01020ac
f01006f9:	e8 1a 06 00 00       	call   f0100d18 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100703:	c9                   	leave  
f0100704:	c3                   	ret    

f0100705 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100705:	55                   	push   %ebp
f0100706:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100708:	b8 00 00 00 00       	mov    $0x0,%eax
f010070d:	5d                   	pop    %ebp
f010070e:	c3                   	ret    

f010070f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010070f:	55                   	push   %ebp
f0100710:	89 e5                	mov    %esp,%ebp
f0100712:	57                   	push   %edi
f0100713:	56                   	push   %esi
f0100714:	53                   	push   %ebx
f0100715:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100718:	68 d8 20 10 f0       	push   $0xf01020d8
f010071d:	e8 f6 05 00 00       	call   f0100d18 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100722:	c7 04 24 fc 20 10 f0 	movl   $0xf01020fc,(%esp)
f0100729:	e8 ea 05 00 00       	call   f0100d18 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100731:	83 ec 0c             	sub    $0xc,%esp
f0100734:	68 8e 1f 10 f0       	push   $0xf0101f8e
f0100739:	e8 6c 0e 00 00       	call   f01015aa <readline>
f010073e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100740:	83 c4 10             	add    $0x10,%esp
f0100743:	85 c0                	test   %eax,%eax
f0100745:	74 ea                	je     f0100731 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100747:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010074e:	be 00 00 00 00       	mov    $0x0,%esi
f0100753:	eb 0a                	jmp    f010075f <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100755:	c6 03 00             	movb   $0x0,(%ebx)
f0100758:	89 f7                	mov    %esi,%edi
f010075a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010075d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010075f:	0f b6 03             	movzbl (%ebx),%eax
f0100762:	84 c0                	test   %al,%al
f0100764:	74 63                	je     f01007c9 <monitor+0xba>
f0100766:	83 ec 08             	sub    $0x8,%esp
f0100769:	0f be c0             	movsbl %al,%eax
f010076c:	50                   	push   %eax
f010076d:	68 92 1f 10 f0       	push   $0xf0101f92
f0100772:	e8 4d 10 00 00       	call   f01017c4 <strchr>
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	85 c0                	test   %eax,%eax
f010077c:	75 d7                	jne    f0100755 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010077e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100781:	74 46                	je     f01007c9 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100783:	83 fe 0f             	cmp    $0xf,%esi
f0100786:	75 14                	jne    f010079c <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100788:	83 ec 08             	sub    $0x8,%esp
f010078b:	6a 10                	push   $0x10
f010078d:	68 97 1f 10 f0       	push   $0xf0101f97
f0100792:	e8 81 05 00 00       	call   f0100d18 <cprintf>
f0100797:	83 c4 10             	add    $0x10,%esp
f010079a:	eb 95                	jmp    f0100731 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010079c:	8d 7e 01             	lea    0x1(%esi),%edi
f010079f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007a3:	eb 03                	jmp    f01007a8 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007a5:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007a8:	0f b6 03             	movzbl (%ebx),%eax
f01007ab:	84 c0                	test   %al,%al
f01007ad:	74 ae                	je     f010075d <monitor+0x4e>
f01007af:	83 ec 08             	sub    $0x8,%esp
f01007b2:	0f be c0             	movsbl %al,%eax
f01007b5:	50                   	push   %eax
f01007b6:	68 92 1f 10 f0       	push   $0xf0101f92
f01007bb:	e8 04 10 00 00       	call   f01017c4 <strchr>
f01007c0:	83 c4 10             	add    $0x10,%esp
f01007c3:	85 c0                	test   %eax,%eax
f01007c5:	74 de                	je     f01007a5 <monitor+0x96>
f01007c7:	eb 94                	jmp    f010075d <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01007c9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01007d0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01007d1:	85 f6                	test   %esi,%esi
f01007d3:	0f 84 58 ff ff ff    	je     f0100731 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007d9:	83 ec 08             	sub    $0x8,%esp
f01007dc:	68 5e 1f 10 f0       	push   $0xf0101f5e
f01007e1:	ff 75 a8             	pushl  -0x58(%ebp)
f01007e4:	e8 7d 0f 00 00       	call   f0101766 <strcmp>
f01007e9:	83 c4 10             	add    $0x10,%esp
f01007ec:	85 c0                	test   %eax,%eax
f01007ee:	74 1e                	je     f010080e <monitor+0xff>
f01007f0:	83 ec 08             	sub    $0x8,%esp
f01007f3:	68 6c 1f 10 f0       	push   $0xf0101f6c
f01007f8:	ff 75 a8             	pushl  -0x58(%ebp)
f01007fb:	e8 66 0f 00 00       	call   f0101766 <strcmp>
f0100800:	83 c4 10             	add    $0x10,%esp
f0100803:	85 c0                	test   %eax,%eax
f0100805:	75 2f                	jne    f0100836 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100807:	b8 01 00 00 00       	mov    $0x1,%eax
f010080c:	eb 05                	jmp    f0100813 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100813:	83 ec 04             	sub    $0x4,%esp
f0100816:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100819:	01 d0                	add    %edx,%eax
f010081b:	ff 75 08             	pushl  0x8(%ebp)
f010081e:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100821:	51                   	push   %ecx
f0100822:	56                   	push   %esi
f0100823:	ff 14 85 2c 21 10 f0 	call   *-0xfefded4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010082a:	83 c4 10             	add    $0x10,%esp
f010082d:	85 c0                	test   %eax,%eax
f010082f:	78 1d                	js     f010084e <monitor+0x13f>
f0100831:	e9 fb fe ff ff       	jmp    f0100731 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100836:	83 ec 08             	sub    $0x8,%esp
f0100839:	ff 75 a8             	pushl  -0x58(%ebp)
f010083c:	68 b4 1f 10 f0       	push   $0xf0101fb4
f0100841:	e8 d2 04 00 00       	call   f0100d18 <cprintf>
f0100846:	83 c4 10             	add    $0x10,%esp
f0100849:	e9 e3 fe ff ff       	jmp    f0100731 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010084e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100851:	5b                   	pop    %ebx
f0100852:	5e                   	pop    %esi
f0100853:	5f                   	pop    %edi
f0100854:	5d                   	pop    %ebp
f0100855:	c3                   	ret    

f0100856 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100856:	55                   	push   %ebp
f0100857:	89 e5                	mov    %esp,%ebp
f0100859:	53                   	push   %ebx
f010085a:	8b 1d 3c 35 11 f0    	mov    0xf011353c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100860:	ba 00 00 00 00       	mov    $0x0,%edx
f0100865:	b8 00 00 00 00       	mov    $0x0,%eax
f010086a:	eb 27                	jmp    f0100893 <page_init+0x3d>
f010086c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100873:	89 d1                	mov    %edx,%ecx
f0100875:	03 0d 6c 39 11 f0    	add    0xf011396c,%ecx
f010087b:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100881:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100883:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100886:	89 d3                	mov    %edx,%ebx
f0100888:	03 1d 6c 39 11 f0    	add    0xf011396c,%ebx
f010088e:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100893:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f0100899:	72 d1                	jb     f010086c <page_init+0x16>
f010089b:	84 d2                	test   %dl,%dl
f010089d:	74 06                	je     f01008a5 <page_init+0x4f>
f010089f:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01008a5:	5b                   	pop    %ebx
f01008a6:	5d                   	pop    %ebp
f01008a7:	c3                   	ret    

f01008a8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01008a8:	55                   	push   %ebp
f01008a9:	89 e5                	mov    %esp,%ebp
f01008ab:	57                   	push   %edi
f01008ac:	56                   	push   %esi
f01008ad:	53                   	push   %ebx
f01008ae:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008b1:	6a 15                	push   $0x15
f01008b3:	e8 f9 03 00 00       	call   f0100cb1 <mc146818_read>
f01008b8:	89 c3                	mov    %eax,%ebx
f01008ba:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01008c1:	e8 eb 03 00 00       	call   f0100cb1 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01008c6:	c1 e0 08             	shl    $0x8,%eax
f01008c9:	09 d8                	or     %ebx,%eax
f01008cb:	c1 e0 0a             	shl    $0xa,%eax
f01008ce:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01008d4:	85 c0                	test   %eax,%eax
f01008d6:	0f 48 c2             	cmovs  %edx,%eax
f01008d9:	c1 f8 0c             	sar    $0xc,%eax
f01008dc:	a3 40 35 11 f0       	mov    %eax,0xf0113540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008e1:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01008e8:	e8 c4 03 00 00       	call   f0100cb1 <mc146818_read>
f01008ed:	89 c3                	mov    %eax,%ebx
f01008ef:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01008f6:	e8 b6 03 00 00       	call   f0100cb1 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01008fb:	c1 e0 08             	shl    $0x8,%eax
f01008fe:	09 d8                	or     %ebx,%eax
f0100900:	c1 e0 0a             	shl    $0xa,%eax
f0100903:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100909:	83 c4 10             	add    $0x10,%esp
f010090c:	85 c0                	test   %eax,%eax
f010090e:	0f 48 c2             	cmovs  %edx,%eax
f0100911:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100914:	85 c0                	test   %eax,%eax
f0100916:	74 0e                	je     f0100926 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100918:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010091e:	89 15 64 39 11 f0    	mov    %edx,0xf0113964
f0100924:	eb 0c                	jmp    f0100932 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0100926:	8b 15 40 35 11 f0    	mov    0xf0113540,%edx
f010092c:	89 15 64 39 11 f0    	mov    %edx,0xf0113964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100932:	c1 e0 0c             	shl    $0xc,%eax
f0100935:	c1 e8 0a             	shr    $0xa,%eax
f0100938:	50                   	push   %eax
f0100939:	a1 40 35 11 f0       	mov    0xf0113540,%eax
f010093e:	c1 e0 0c             	shl    $0xc,%eax
f0100941:	c1 e8 0a             	shr    $0xa,%eax
f0100944:	50                   	push   %eax
f0100945:	a1 64 39 11 f0       	mov    0xf0113964,%eax
f010094a:	c1 e0 0c             	shl    $0xc,%eax
f010094d:	c1 e8 0a             	shr    $0xa,%eax
f0100950:	50                   	push   %eax
f0100951:	68 3c 21 10 f0       	push   $0xf010213c
f0100956:	e8 bd 03 00 00       	call   f0100d18 <cprintf>
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010095b:	83 c4 10             	add    $0x10,%esp
f010095e:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f0100965:	75 0f                	jne    f0100976 <mem_init+0xce>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100967:	b8 6f 49 11 f0       	mov    $0xf011496f,%eax
f010096c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100971:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100976:	c7 05 68 39 11 f0 00 	movl   $0x0,0xf0113968
f010097d:	00 00 00 
	memset(kern_pgdir, 0, PGSIZE);
f0100980:	83 ec 04             	sub    $0x4,%esp
f0100983:	68 00 10 00 00       	push   $0x1000
f0100988:	6a 00                	push   $0x0
f010098a:	6a 00                	push   $0x0
f010098c:	e8 70 0e 00 00       	call   f0101801 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100991:	a1 68 39 11 f0       	mov    0xf0113968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100996:	83 c4 10             	add    $0x10,%esp
f0100999:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010099e:	77 15                	ja     f01009b5 <mem_init+0x10d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01009a0:	50                   	push   %eax
f01009a1:	68 78 21 10 f0       	push   $0xf0102178
f01009a6:	68 8a 00 00 00       	push   $0x8a
f01009ab:	68 3c 22 10 f0       	push   $0xf010223c
f01009b0:	e8 d6 f6 ff ff       	call   f010008b <_panic>
f01009b5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01009bb:	83 ca 05             	or     $0x5,%edx
f01009be:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01009c4:	e8 8d fe ff ff       	call   f0100856 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01009c9:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f01009ce:	85 c0                	test   %eax,%eax
f01009d0:	75 17                	jne    f01009e9 <mem_init+0x141>
		panic("'page_free_list' is a null pointer!");
f01009d2:	83 ec 04             	sub    $0x4,%esp
f01009d5:	68 9c 21 10 f0       	push   $0xf010219c
f01009da:	68 be 01 00 00       	push   $0x1be
f01009df:	68 3c 22 10 f0       	push   $0xf010223c
f01009e4:	e8 a2 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009e9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009f5:	89 c2                	mov    %eax,%edx
f01009f7:	2b 15 6c 39 11 f0    	sub    0xf011396c,%edx
f01009fd:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a03:	0f 95 c2             	setne  %dl
f0100a06:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a09:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a0d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a0f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a13:	8b 00                	mov    (%eax),%eax
f0100a15:	85 c0                	test   %eax,%eax
f0100a17:	75 dc                	jne    f01009f5 <mem_init+0x14d>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a25:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a28:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a2a:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100a2d:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
f0100a33:	eb 54                	jmp    f0100a89 <mem_init+0x1e1>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a35:	89 d8                	mov    %ebx,%eax
f0100a37:	2b 05 6c 39 11 f0    	sub    0xf011396c,%eax
f0100a3d:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a40:	89 c2                	mov    %eax,%edx
f0100a42:	c1 e2 0c             	shl    $0xc,%edx
f0100a45:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0100a4a:	75 3b                	jne    f0100a87 <mem_init+0x1df>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a4c:	89 d0                	mov    %edx,%eax
f0100a4e:	c1 e8 0c             	shr    $0xc,%eax
f0100a51:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f0100a57:	72 12                	jb     f0100a6b <mem_init+0x1c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a59:	52                   	push   %edx
f0100a5a:	68 c0 21 10 f0       	push   $0xf01021c0
f0100a5f:	6a 52                	push   $0x52
f0100a61:	68 48 22 10 f0       	push   $0xf0102248
f0100a66:	e8 20 f6 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a6b:	83 ec 04             	sub    $0x4,%esp
f0100a6e:	68 80 00 00 00       	push   $0x80
f0100a73:	68 97 00 00 00       	push   $0x97
f0100a78:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100a7e:	52                   	push   %edx
f0100a7f:	e8 7d 0d 00 00       	call   f0101801 <memset>
f0100a84:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a87:	8b 1b                	mov    (%ebx),%ebx
f0100a89:	85 db                	test   %ebx,%ebx
f0100a8b:	75 a8                	jne    f0100a35 <mem_init+0x18d>
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a8d:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f0100a94:	75 0f                	jne    f0100aa5 <mem_init+0x1fd>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a96:	b8 6f 49 11 f0       	mov    $0xf011496f,%eax
f0100a9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aa0:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa5:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100aaa:	89 45 c8             	mov    %eax,-0x38(%ebp)
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aad:	8b 0d 6c 39 11 f0    	mov    0xf011396c,%ecx
		assert(pp < pages + npages);
f0100ab3:	8b 3d 64 39 11 f0    	mov    0xf0113964,%edi
f0100ab9:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0100abc:	8d 34 f9             	lea    (%ecx,%edi,8),%esi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100abf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ac2:	89 c2                	mov    %eax,%edx
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ac4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ac9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ace:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100ad1:	e9 0d 01 00 00       	jmp    f0100be3 <mem_init+0x33b>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad6:	39 d1                	cmp    %edx,%ecx
f0100ad8:	76 19                	jbe    f0100af3 <mem_init+0x24b>
f0100ada:	68 56 22 10 f0       	push   $0xf0102256
f0100adf:	68 62 22 10 f0       	push   $0xf0102262
f0100ae4:	68 d8 01 00 00       	push   $0x1d8
f0100ae9:	68 3c 22 10 f0       	push   $0xf010223c
f0100aee:	e8 98 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100af3:	39 f2                	cmp    %esi,%edx
f0100af5:	72 19                	jb     f0100b10 <mem_init+0x268>
f0100af7:	68 77 22 10 f0       	push   $0xf0102277
f0100afc:	68 62 22 10 f0       	push   $0xf0102262
f0100b01:	68 d9 01 00 00       	push   $0x1d9
f0100b06:	68 3c 22 10 f0       	push   $0xf010223c
f0100b0b:	e8 7b f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b10:	89 d0                	mov    %edx,%eax
f0100b12:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b15:	a8 07                	test   $0x7,%al
f0100b17:	74 19                	je     f0100b32 <mem_init+0x28a>
f0100b19:	68 e4 21 10 f0       	push   $0xf01021e4
f0100b1e:	68 62 22 10 f0       	push   $0xf0102262
f0100b23:	68 da 01 00 00       	push   $0x1da
f0100b28:	68 3c 22 10 f0       	push   $0xf010223c
f0100b2d:	e8 59 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b32:	c1 f8 03             	sar    $0x3,%eax
f0100b35:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b38:	85 c0                	test   %eax,%eax
f0100b3a:	75 19                	jne    f0100b55 <mem_init+0x2ad>
f0100b3c:	68 8b 22 10 f0       	push   $0xf010228b
f0100b41:	68 62 22 10 f0       	push   $0xf0102262
f0100b46:	68 dd 01 00 00       	push   $0x1dd
f0100b4b:	68 3c 22 10 f0       	push   $0xf010223c
f0100b50:	e8 36 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b55:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b5a:	75 19                	jne    f0100b75 <mem_init+0x2cd>
f0100b5c:	68 9c 22 10 f0       	push   $0xf010229c
f0100b61:	68 62 22 10 f0       	push   $0xf0102262
f0100b66:	68 de 01 00 00       	push   $0x1de
f0100b6b:	68 3c 22 10 f0       	push   $0xf010223c
f0100b70:	e8 16 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b75:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b7a:	75 19                	jne    f0100b95 <mem_init+0x2ed>
f0100b7c:	68 18 22 10 f0       	push   $0xf0102218
f0100b81:	68 62 22 10 f0       	push   $0xf0102262
f0100b86:	68 df 01 00 00       	push   $0x1df
f0100b8b:	68 3c 22 10 f0       	push   $0xf010223c
f0100b90:	e8 f6 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b95:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b9a:	75 19                	jne    f0100bb5 <mem_init+0x30d>
f0100b9c:	68 b5 22 10 f0       	push   $0xf01022b5
f0100ba1:	68 62 22 10 f0       	push   $0xf0102262
f0100ba6:	68 e0 01 00 00       	push   $0x1e0
f0100bab:	68 3c 22 10 f0       	push   $0xf010223c
f0100bb0:	e8 d6 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bb5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bba:	76 1c                	jbe    f0100bd8 <mem_init+0x330>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bbc:	89 c3                	mov    %eax,%ebx
f0100bbe:	c1 eb 0c             	shr    $0xc,%ebx
f0100bc1:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100bc4:	77 18                	ja     f0100bde <mem_init+0x336>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc6:	50                   	push   %eax
f0100bc7:	68 c0 21 10 f0       	push   $0xf01021c0
f0100bcc:	6a 52                	push   $0x52
f0100bce:	68 48 22 10 f0       	push   $0xf0102248
f0100bd3:	e8 b3 f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bd8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100bdc:	eb 03                	jmp    f0100be1 <mem_init+0x339>
		else
			++nfree_extmem;
f0100bde:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be1:	8b 12                	mov    (%edx),%edx
f0100be3:	85 d2                	test   %edx,%edx
f0100be5:	0f 85 eb fe ff ff    	jne    f0100ad6 <mem_init+0x22e>
f0100beb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100bee:	85 db                	test   %ebx,%ebx
f0100bf0:	7f 19                	jg     f0100c0b <mem_init+0x363>
f0100bf2:	68 cf 22 10 f0       	push   $0xf01022cf
f0100bf7:	68 62 22 10 f0       	push   $0xf0102262
f0100bfc:	68 e9 01 00 00       	push   $0x1e9
f0100c01:	68 3c 22 10 f0       	push   $0xf010223c
f0100c06:	e8 80 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c0b:	85 ff                	test   %edi,%edi
f0100c0d:	7f 19                	jg     f0100c28 <mem_init+0x380>
f0100c0f:	68 e1 22 10 f0       	push   $0xf01022e1
f0100c14:	68 62 22 10 f0       	push   $0xf0102262
f0100c19:	68 ea 01 00 00       	push   $0x1ea
f0100c1e:	68 3c 22 10 f0       	push   $0xf010223c
f0100c23:	e8 63 f4 ff ff       	call   f010008b <_panic>
f0100c28:	8b 45 c8             	mov    -0x38(%ebp),%eax
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100c2b:	85 c9                	test   %ecx,%ecx
f0100c2d:	75 1b                	jne    f0100c4a <mem_init+0x3a2>
		panic("'pages' is a null pointer!");
f0100c2f:	83 ec 04             	sub    $0x4,%esp
f0100c32:	68 f2 22 10 f0       	push   $0xf01022f2
f0100c37:	68 fb 01 00 00       	push   $0x1fb
f0100c3c:	68 3c 22 10 f0       	push   $0xf010223c
f0100c41:	e8 45 f4 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100c46:	8b 00                	mov    (%eax),%eax
f0100c48:	eb 00                	jmp    f0100c4a <mem_init+0x3a2>
f0100c4a:	85 c0                	test   %eax,%eax
f0100c4c:	75 f8                	jne    f0100c46 <mem_init+0x39e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100c4e:	68 0d 23 10 f0       	push   $0xf010230d
f0100c53:	68 62 22 10 f0       	push   $0xf0102262
f0100c58:	68 03 02 00 00       	push   $0x203
f0100c5d:	68 3c 22 10 f0       	push   $0xf010223c
f0100c62:	e8 24 f4 ff ff       	call   f010008b <_panic>

f0100c67 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100c67:	55                   	push   %ebp
f0100c68:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100c6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c6f:	5d                   	pop    %ebp
f0100c70:	c3                   	ret    

f0100c71 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100c71:	55                   	push   %ebp
f0100c72:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100c74:	5d                   	pop    %ebp
f0100c75:	c3                   	ret    

f0100c76 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100c76:	55                   	push   %ebp
f0100c77:	89 e5                	mov    %esp,%ebp
f0100c79:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100c7c:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100c86:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c8b:	5d                   	pop    %ebp
f0100c8c:	c3                   	ret    

f0100c8d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100c8d:	55                   	push   %ebp
f0100c8e:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100c90:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c95:	5d                   	pop    %ebp
f0100c96:	c3                   	ret    

f0100c97 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100c97:	55                   	push   %ebp
f0100c98:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100c9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9f:	5d                   	pop    %ebp
f0100ca0:	c3                   	ret    

f0100ca1 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ca1:	55                   	push   %ebp
f0100ca2:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100ca4:	5d                   	pop    %ebp
f0100ca5:	c3                   	ret    

f0100ca6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100ca6:	55                   	push   %ebp
f0100ca7:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cac:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100caf:	5d                   	pop    %ebp
f0100cb0:	c3                   	ret    

f0100cb1 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100cb1:	55                   	push   %ebp
f0100cb2:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100cb4:	ba 70 00 00 00       	mov    $0x70,%edx
f0100cb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cbc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100cbd:	ba 71 00 00 00       	mov    $0x71,%edx
f0100cc2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100cc3:	0f b6 c0             	movzbl %al,%eax
}
f0100cc6:	5d                   	pop    %ebp
f0100cc7:	c3                   	ret    

f0100cc8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100cc8:	55                   	push   %ebp
f0100cc9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ccb:	ba 70 00 00 00       	mov    $0x70,%edx
f0100cd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cd3:	ee                   	out    %al,(%dx)
f0100cd4:	ba 71 00 00 00       	mov    $0x71,%edx
f0100cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cdc:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100cdd:	5d                   	pop    %ebp
f0100cde:	c3                   	ret    

f0100cdf <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100cdf:	55                   	push   %ebp
f0100ce0:	89 e5                	mov    %esp,%ebp
f0100ce2:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100ce5:	ff 75 08             	pushl  0x8(%ebp)
f0100ce8:	e8 05 f9 ff ff       	call   f01005f2 <cputchar>
	*cnt++;
}
f0100ced:	83 c4 10             	add    $0x10,%esp
f0100cf0:	c9                   	leave  
f0100cf1:	c3                   	ret    

f0100cf2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100cf2:	55                   	push   %ebp
f0100cf3:	89 e5                	mov    %esp,%ebp
f0100cf5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100cf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100cff:	ff 75 0c             	pushl  0xc(%ebp)
f0100d02:	ff 75 08             	pushl  0x8(%ebp)
f0100d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100d08:	50                   	push   %eax
f0100d09:	68 df 0c 10 f0       	push   $0xf0100cdf
f0100d0e:	e8 c9 03 00 00       	call   f01010dc <vprintfmt>
	return cnt;
}
f0100d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d16:	c9                   	leave  
f0100d17:	c3                   	ret    

f0100d18 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100d18:	55                   	push   %ebp
f0100d19:	89 e5                	mov    %esp,%ebp
f0100d1b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100d1e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100d21:	50                   	push   %eax
f0100d22:	ff 75 08             	pushl  0x8(%ebp)
f0100d25:	e8 c8 ff ff ff       	call   f0100cf2 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100d2a:	c9                   	leave  
f0100d2b:	c3                   	ret    

f0100d2c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100d2c:	55                   	push   %ebp
f0100d2d:	89 e5                	mov    %esp,%ebp
f0100d2f:	57                   	push   %edi
f0100d30:	56                   	push   %esi
f0100d31:	53                   	push   %ebx
f0100d32:	83 ec 14             	sub    $0x14,%esp
f0100d35:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100d38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d3b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d3e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100d41:	8b 1a                	mov    (%edx),%ebx
f0100d43:	8b 01                	mov    (%ecx),%eax
f0100d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d48:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100d4f:	eb 7f                	jmp    f0100dd0 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100d54:	01 d8                	add    %ebx,%eax
f0100d56:	89 c6                	mov    %eax,%esi
f0100d58:	c1 ee 1f             	shr    $0x1f,%esi
f0100d5b:	01 c6                	add    %eax,%esi
f0100d5d:	d1 fe                	sar    %esi
f0100d5f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100d62:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100d65:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100d68:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d6a:	eb 03                	jmp    f0100d6f <stab_binsearch+0x43>
			m--;
f0100d6c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d6f:	39 c3                	cmp    %eax,%ebx
f0100d71:	7f 0d                	jg     f0100d80 <stab_binsearch+0x54>
f0100d73:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100d77:	83 ea 0c             	sub    $0xc,%edx
f0100d7a:	39 f9                	cmp    %edi,%ecx
f0100d7c:	75 ee                	jne    f0100d6c <stab_binsearch+0x40>
f0100d7e:	eb 05                	jmp    f0100d85 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100d80:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100d83:	eb 4b                	jmp    f0100dd0 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100d85:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d88:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100d8b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100d8f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100d92:	76 11                	jbe    f0100da5 <stab_binsearch+0x79>
			*region_left = m;
f0100d94:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100d97:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100d99:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100d9c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100da3:	eb 2b                	jmp    f0100dd0 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100da5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100da8:	73 14                	jae    f0100dbe <stab_binsearch+0x92>
			*region_right = m - 1;
f0100daa:	83 e8 01             	sub    $0x1,%eax
f0100dad:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100db0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100db3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100db5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100dbc:	eb 12                	jmp    f0100dd0 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100dbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100dc1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100dc3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100dc7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100dc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100dd0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100dd3:	0f 8e 78 ff ff ff    	jle    f0100d51 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100dd9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ddd:	75 0f                	jne    f0100dee <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100ddf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100de2:	8b 00                	mov    (%eax),%eax
f0100de4:	83 e8 01             	sub    $0x1,%eax
f0100de7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100dea:	89 06                	mov    %eax,(%esi)
f0100dec:	eb 2c                	jmp    f0100e1a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100df3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100df6:	8b 0e                	mov    (%esi),%ecx
f0100df8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dfb:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100dfe:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e01:	eb 03                	jmp    f0100e06 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100e03:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e06:	39 c8                	cmp    %ecx,%eax
f0100e08:	7e 0b                	jle    f0100e15 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100e0a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100e0e:	83 ea 0c             	sub    $0xc,%edx
f0100e11:	39 df                	cmp    %ebx,%edi
f0100e13:	75 ee                	jne    f0100e03 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100e15:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100e18:	89 06                	mov    %eax,(%esi)
	}
}
f0100e1a:	83 c4 14             	add    $0x14,%esp
f0100e1d:	5b                   	pop    %ebx
f0100e1e:	5e                   	pop    %esi
f0100e1f:	5f                   	pop    %edi
f0100e20:	5d                   	pop    %ebp
f0100e21:	c3                   	ret    

f0100e22 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100e22:	55                   	push   %ebp
f0100e23:	89 e5                	mov    %esp,%ebp
f0100e25:	57                   	push   %edi
f0100e26:	56                   	push   %esi
f0100e27:	53                   	push   %ebx
f0100e28:	83 ec 1c             	sub    $0x1c,%esp
f0100e2b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100e2e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100e31:	c7 06 23 23 10 f0    	movl   $0xf0102323,(%esi)
	info->eip_line = 0;
f0100e37:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100e3e:	c7 46 08 23 23 10 f0 	movl   $0xf0102323,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100e45:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100e4c:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100e4f:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100e56:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100e5c:	76 11                	jbe    f0100e6f <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e5e:	b8 45 84 10 f0       	mov    $0xf0108445,%eax
f0100e63:	3d 6d 68 10 f0       	cmp    $0xf010686d,%eax
f0100e68:	77 19                	ja     f0100e83 <debuginfo_eip+0x61>
f0100e6a:	e9 62 01 00 00       	jmp    f0100fd1 <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100e6f:	83 ec 04             	sub    $0x4,%esp
f0100e72:	68 2d 23 10 f0       	push   $0xf010232d
f0100e77:	6a 7f                	push   $0x7f
f0100e79:	68 3a 23 10 f0       	push   $0xf010233a
f0100e7e:	e8 08 f2 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e83:	80 3d 44 84 10 f0 00 	cmpb   $0x0,0xf0108444
f0100e8a:	0f 85 48 01 00 00    	jne    f0100fd8 <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100e90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100e97:	b8 6c 68 10 f0       	mov    $0xf010686c,%eax
f0100e9c:	2d 70 25 10 f0       	sub    $0xf0102570,%eax
f0100ea1:	c1 f8 02             	sar    $0x2,%eax
f0100ea4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100eaa:	83 e8 01             	sub    $0x1,%eax
f0100ead:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100eb0:	83 ec 08             	sub    $0x8,%esp
f0100eb3:	57                   	push   %edi
f0100eb4:	6a 64                	push   $0x64
f0100eb6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100eb9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ebc:	b8 70 25 10 f0       	mov    $0xf0102570,%eax
f0100ec1:	e8 66 fe ff ff       	call   f0100d2c <stab_binsearch>
	if (lfile == 0)
f0100ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ec9:	83 c4 10             	add    $0x10,%esp
f0100ecc:	85 c0                	test   %eax,%eax
f0100ece:	0f 84 0b 01 00 00    	je     f0100fdf <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ed4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ed7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eda:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100edd:	83 ec 08             	sub    $0x8,%esp
f0100ee0:	57                   	push   %edi
f0100ee1:	6a 24                	push   $0x24
f0100ee3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ee6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ee9:	b8 70 25 10 f0       	mov    $0xf0102570,%eax
f0100eee:	e8 39 fe ff ff       	call   f0100d2c <stab_binsearch>

	if (lfun <= rfun) {
f0100ef3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ef6:	83 c4 10             	add    $0x10,%esp
f0100ef9:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100efc:	7f 31                	jg     f0100f2f <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100efe:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f01:	c1 e0 02             	shl    $0x2,%eax
f0100f04:	8d 90 70 25 10 f0    	lea    -0xfefda90(%eax),%edx
f0100f0a:	8b 88 70 25 10 f0    	mov    -0xfefda90(%eax),%ecx
f0100f10:	b8 45 84 10 f0       	mov    $0xf0108445,%eax
f0100f15:	2d 6d 68 10 f0       	sub    $0xf010686d,%eax
f0100f1a:	39 c1                	cmp    %eax,%ecx
f0100f1c:	73 09                	jae    f0100f27 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100f1e:	81 c1 6d 68 10 f0    	add    $0xf010686d,%ecx
f0100f24:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100f27:	8b 42 08             	mov    0x8(%edx),%eax
f0100f2a:	89 46 10             	mov    %eax,0x10(%esi)
f0100f2d:	eb 06                	jmp    f0100f35 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100f2f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100f32:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100f35:	83 ec 08             	sub    $0x8,%esp
f0100f38:	6a 3a                	push   $0x3a
f0100f3a:	ff 76 08             	pushl  0x8(%esi)
f0100f3d:	e8 a3 08 00 00       	call   f01017e5 <strfind>
f0100f42:	2b 46 08             	sub    0x8(%esi),%eax
f0100f45:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100f48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f4b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f4e:	8d 04 85 70 25 10 f0 	lea    -0xfefda90(,%eax,4),%eax
f0100f55:	83 c4 10             	add    $0x10,%esp
f0100f58:	eb 06                	jmp    f0100f60 <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100f5a:	83 eb 01             	sub    $0x1,%ebx
f0100f5d:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100f60:	39 fb                	cmp    %edi,%ebx
f0100f62:	7c 34                	jl     f0100f98 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0100f64:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100f68:	80 fa 84             	cmp    $0x84,%dl
f0100f6b:	74 0b                	je     f0100f78 <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100f6d:	80 fa 64             	cmp    $0x64,%dl
f0100f70:	75 e8                	jne    f0100f5a <debuginfo_eip+0x138>
f0100f72:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100f76:	74 e2                	je     f0100f5a <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f78:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f7b:	8b 14 85 70 25 10 f0 	mov    -0xfefda90(,%eax,4),%edx
f0100f82:	b8 45 84 10 f0       	mov    $0xf0108445,%eax
f0100f87:	2d 6d 68 10 f0       	sub    $0xf010686d,%eax
f0100f8c:	39 c2                	cmp    %eax,%edx
f0100f8e:	73 08                	jae    f0100f98 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100f90:	81 c2 6d 68 10 f0    	add    $0xf010686d,%edx
f0100f96:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f98:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f9b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f9e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100fa3:	39 cb                	cmp    %ecx,%ebx
f0100fa5:	7d 44                	jge    f0100feb <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100fa7:	8d 53 01             	lea    0x1(%ebx),%edx
f0100faa:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100fad:	8d 04 85 70 25 10 f0 	lea    -0xfefda90(,%eax,4),%eax
f0100fb4:	eb 07                	jmp    f0100fbd <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100fb6:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100fba:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100fbd:	39 ca                	cmp    %ecx,%edx
f0100fbf:	74 25                	je     f0100fe6 <debuginfo_eip+0x1c4>
f0100fc1:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100fc4:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100fc8:	74 ec                	je     f0100fb6 <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fcf:	eb 1a                	jmp    f0100feb <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fd6:	eb 13                	jmp    f0100feb <debuginfo_eip+0x1c9>
f0100fd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fdd:	eb 0c                	jmp    f0100feb <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fe4:	eb 05                	jmp    f0100feb <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fe6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fee:	5b                   	pop    %ebx
f0100fef:	5e                   	pop    %esi
f0100ff0:	5f                   	pop    %edi
f0100ff1:	5d                   	pop    %ebp
f0100ff2:	c3                   	ret    

f0100ff3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ff3:	55                   	push   %ebp
f0100ff4:	89 e5                	mov    %esp,%ebp
f0100ff6:	57                   	push   %edi
f0100ff7:	56                   	push   %esi
f0100ff8:	53                   	push   %ebx
f0100ff9:	83 ec 1c             	sub    $0x1c,%esp
f0100ffc:	89 c7                	mov    %eax,%edi
f0100ffe:	89 d6                	mov    %edx,%esi
f0101000:	8b 45 08             	mov    0x8(%ebp),%eax
f0101003:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101006:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101009:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010100c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010100f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101014:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101017:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010101a:	39 d3                	cmp    %edx,%ebx
f010101c:	72 05                	jb     f0101023 <printnum+0x30>
f010101e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101021:	77 45                	ja     f0101068 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101023:	83 ec 0c             	sub    $0xc,%esp
f0101026:	ff 75 18             	pushl  0x18(%ebp)
f0101029:	8b 45 14             	mov    0x14(%ebp),%eax
f010102c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010102f:	53                   	push   %ebx
f0101030:	ff 75 10             	pushl  0x10(%ebp)
f0101033:	83 ec 08             	sub    $0x8,%esp
f0101036:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101039:	ff 75 e0             	pushl  -0x20(%ebp)
f010103c:	ff 75 dc             	pushl  -0x24(%ebp)
f010103f:	ff 75 d8             	pushl  -0x28(%ebp)
f0101042:	e8 c9 09 00 00       	call   f0101a10 <__udivdi3>
f0101047:	83 c4 18             	add    $0x18,%esp
f010104a:	52                   	push   %edx
f010104b:	50                   	push   %eax
f010104c:	89 f2                	mov    %esi,%edx
f010104e:	89 f8                	mov    %edi,%eax
f0101050:	e8 9e ff ff ff       	call   f0100ff3 <printnum>
f0101055:	83 c4 20             	add    $0x20,%esp
f0101058:	eb 18                	jmp    f0101072 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010105a:	83 ec 08             	sub    $0x8,%esp
f010105d:	56                   	push   %esi
f010105e:	ff 75 18             	pushl  0x18(%ebp)
f0101061:	ff d7                	call   *%edi
f0101063:	83 c4 10             	add    $0x10,%esp
f0101066:	eb 03                	jmp    f010106b <printnum+0x78>
f0101068:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010106b:	83 eb 01             	sub    $0x1,%ebx
f010106e:	85 db                	test   %ebx,%ebx
f0101070:	7f e8                	jg     f010105a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101072:	83 ec 08             	sub    $0x8,%esp
f0101075:	56                   	push   %esi
f0101076:	83 ec 04             	sub    $0x4,%esp
f0101079:	ff 75 e4             	pushl  -0x1c(%ebp)
f010107c:	ff 75 e0             	pushl  -0x20(%ebp)
f010107f:	ff 75 dc             	pushl  -0x24(%ebp)
f0101082:	ff 75 d8             	pushl  -0x28(%ebp)
f0101085:	e8 b6 0a 00 00       	call   f0101b40 <__umoddi3>
f010108a:	83 c4 14             	add    $0x14,%esp
f010108d:	0f be 80 48 23 10 f0 	movsbl -0xfefdcb8(%eax),%eax
f0101094:	50                   	push   %eax
f0101095:	ff d7                	call   *%edi
}
f0101097:	83 c4 10             	add    $0x10,%esp
f010109a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010109d:	5b                   	pop    %ebx
f010109e:	5e                   	pop    %esi
f010109f:	5f                   	pop    %edi
f01010a0:	5d                   	pop    %ebp
f01010a1:	c3                   	ret    

f01010a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01010a2:	55                   	push   %ebp
f01010a3:	89 e5                	mov    %esp,%ebp
f01010a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01010a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01010ac:	8b 10                	mov    (%eax),%edx
f01010ae:	3b 50 04             	cmp    0x4(%eax),%edx
f01010b1:	73 0a                	jae    f01010bd <sprintputch+0x1b>
		*b->buf++ = ch;
f01010b3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01010b6:	89 08                	mov    %ecx,(%eax)
f01010b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01010bb:	88 02                	mov    %al,(%edx)
}
f01010bd:	5d                   	pop    %ebp
f01010be:	c3                   	ret    

f01010bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01010bf:	55                   	push   %ebp
f01010c0:	89 e5                	mov    %esp,%ebp
f01010c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01010c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01010c8:	50                   	push   %eax
f01010c9:	ff 75 10             	pushl  0x10(%ebp)
f01010cc:	ff 75 0c             	pushl  0xc(%ebp)
f01010cf:	ff 75 08             	pushl  0x8(%ebp)
f01010d2:	e8 05 00 00 00       	call   f01010dc <vprintfmt>
	va_end(ap);
}
f01010d7:	83 c4 10             	add    $0x10,%esp
f01010da:	c9                   	leave  
f01010db:	c3                   	ret    

f01010dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01010dc:	55                   	push   %ebp
f01010dd:	89 e5                	mov    %esp,%ebp
f01010df:	57                   	push   %edi
f01010e0:	56                   	push   %esi
f01010e1:	53                   	push   %ebx
f01010e2:	83 ec 2c             	sub    $0x2c,%esp
f01010e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01010e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010eb:	8b 7d 10             	mov    0x10(%ebp),%edi
f01010ee:	eb 12                	jmp    f0101102 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01010f0:	85 c0                	test   %eax,%eax
f01010f2:	0f 84 42 04 00 00    	je     f010153a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f01010f8:	83 ec 08             	sub    $0x8,%esp
f01010fb:	53                   	push   %ebx
f01010fc:	50                   	push   %eax
f01010fd:	ff d6                	call   *%esi
f01010ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101102:	83 c7 01             	add    $0x1,%edi
f0101105:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101109:	83 f8 25             	cmp    $0x25,%eax
f010110c:	75 e2                	jne    f01010f0 <vprintfmt+0x14>
f010110e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101112:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101119:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101120:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101127:	b9 00 00 00 00       	mov    $0x0,%ecx
f010112c:	eb 07                	jmp    f0101135 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010112e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101131:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101135:	8d 47 01             	lea    0x1(%edi),%eax
f0101138:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010113b:	0f b6 07             	movzbl (%edi),%eax
f010113e:	0f b6 d0             	movzbl %al,%edx
f0101141:	83 e8 23             	sub    $0x23,%eax
f0101144:	3c 55                	cmp    $0x55,%al
f0101146:	0f 87 d3 03 00 00    	ja     f010151f <vprintfmt+0x443>
f010114c:	0f b6 c0             	movzbl %al,%eax
f010114f:	ff 24 85 e0 23 10 f0 	jmp    *-0xfefdc20(,%eax,4)
f0101156:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101159:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010115d:	eb d6                	jmp    f0101135 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010115f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101162:	b8 00 00 00 00       	mov    $0x0,%eax
f0101167:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010116a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010116d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101171:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101174:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101177:	83 f9 09             	cmp    $0x9,%ecx
f010117a:	77 3f                	ja     f01011bb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010117c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010117f:	eb e9                	jmp    f010116a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101181:	8b 45 14             	mov    0x14(%ebp),%eax
f0101184:	8b 00                	mov    (%eax),%eax
f0101186:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101189:	8b 45 14             	mov    0x14(%ebp),%eax
f010118c:	8d 40 04             	lea    0x4(%eax),%eax
f010118f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101192:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101195:	eb 2a                	jmp    f01011c1 <vprintfmt+0xe5>
f0101197:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119a:	85 c0                	test   %eax,%eax
f010119c:	ba 00 00 00 00       	mov    $0x0,%edx
f01011a1:	0f 49 d0             	cmovns %eax,%edx
f01011a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011aa:	eb 89                	jmp    f0101135 <vprintfmt+0x59>
f01011ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01011af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01011b6:	e9 7a ff ff ff       	jmp    f0101135 <vprintfmt+0x59>
f01011bb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01011be:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01011c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01011c5:	0f 89 6a ff ff ff    	jns    f0101135 <vprintfmt+0x59>
				width = precision, precision = -1;
f01011cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01011ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01011d8:	e9 58 ff ff ff       	jmp    f0101135 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01011dd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01011e3:	e9 4d ff ff ff       	jmp    f0101135 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01011e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011eb:	8d 78 04             	lea    0x4(%eax),%edi
f01011ee:	83 ec 08             	sub    $0x8,%esp
f01011f1:	53                   	push   %ebx
f01011f2:	ff 30                	pushl  (%eax)
f01011f4:	ff d6                	call   *%esi
			break;
f01011f6:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01011f9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01011ff:	e9 fe fe ff ff       	jmp    f0101102 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101204:	8b 45 14             	mov    0x14(%ebp),%eax
f0101207:	8d 78 04             	lea    0x4(%eax),%edi
f010120a:	8b 00                	mov    (%eax),%eax
f010120c:	99                   	cltd   
f010120d:	31 d0                	xor    %edx,%eax
f010120f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101211:	83 f8 07             	cmp    $0x7,%eax
f0101214:	7f 0b                	jg     f0101221 <vprintfmt+0x145>
f0101216:	8b 14 85 40 25 10 f0 	mov    -0xfefdac0(,%eax,4),%edx
f010121d:	85 d2                	test   %edx,%edx
f010121f:	75 1b                	jne    f010123c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0101221:	50                   	push   %eax
f0101222:	68 60 23 10 f0       	push   $0xf0102360
f0101227:	53                   	push   %ebx
f0101228:	56                   	push   %esi
f0101229:	e8 91 fe ff ff       	call   f01010bf <printfmt>
f010122e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101231:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101234:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101237:	e9 c6 fe ff ff       	jmp    f0101102 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010123c:	52                   	push   %edx
f010123d:	68 74 22 10 f0       	push   $0xf0102274
f0101242:	53                   	push   %ebx
f0101243:	56                   	push   %esi
f0101244:	e8 76 fe ff ff       	call   f01010bf <printfmt>
f0101249:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010124c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010124f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101252:	e9 ab fe ff ff       	jmp    f0101102 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101257:	8b 45 14             	mov    0x14(%ebp),%eax
f010125a:	83 c0 04             	add    $0x4,%eax
f010125d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101260:	8b 45 14             	mov    0x14(%ebp),%eax
f0101263:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101265:	85 ff                	test   %edi,%edi
f0101267:	b8 59 23 10 f0       	mov    $0xf0102359,%eax
f010126c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010126f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101273:	0f 8e 94 00 00 00    	jle    f010130d <vprintfmt+0x231>
f0101279:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010127d:	0f 84 98 00 00 00    	je     f010131b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101283:	83 ec 08             	sub    $0x8,%esp
f0101286:	ff 75 d0             	pushl  -0x30(%ebp)
f0101289:	57                   	push   %edi
f010128a:	e8 0c 04 00 00       	call   f010169b <strnlen>
f010128f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101292:	29 c1                	sub    %eax,%ecx
f0101294:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101297:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010129a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010129e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01012a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01012a6:	eb 0f                	jmp    f01012b7 <vprintfmt+0x1db>
					putch(padc, putdat);
f01012a8:	83 ec 08             	sub    $0x8,%esp
f01012ab:	53                   	push   %ebx
f01012ac:	ff 75 e0             	pushl  -0x20(%ebp)
f01012af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01012b1:	83 ef 01             	sub    $0x1,%edi
f01012b4:	83 c4 10             	add    $0x10,%esp
f01012b7:	85 ff                	test   %edi,%edi
f01012b9:	7f ed                	jg     f01012a8 <vprintfmt+0x1cc>
f01012bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01012be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012c1:	85 c9                	test   %ecx,%ecx
f01012c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c8:	0f 49 c1             	cmovns %ecx,%eax
f01012cb:	29 c1                	sub    %eax,%ecx
f01012cd:	89 75 08             	mov    %esi,0x8(%ebp)
f01012d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01012d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01012d6:	89 cb                	mov    %ecx,%ebx
f01012d8:	eb 4d                	jmp    f0101327 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01012da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01012de:	74 1b                	je     f01012fb <vprintfmt+0x21f>
f01012e0:	0f be c0             	movsbl %al,%eax
f01012e3:	83 e8 20             	sub    $0x20,%eax
f01012e6:	83 f8 5e             	cmp    $0x5e,%eax
f01012e9:	76 10                	jbe    f01012fb <vprintfmt+0x21f>
					putch('?', putdat);
f01012eb:	83 ec 08             	sub    $0x8,%esp
f01012ee:	ff 75 0c             	pushl  0xc(%ebp)
f01012f1:	6a 3f                	push   $0x3f
f01012f3:	ff 55 08             	call   *0x8(%ebp)
f01012f6:	83 c4 10             	add    $0x10,%esp
f01012f9:	eb 0d                	jmp    f0101308 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f01012fb:	83 ec 08             	sub    $0x8,%esp
f01012fe:	ff 75 0c             	pushl  0xc(%ebp)
f0101301:	52                   	push   %edx
f0101302:	ff 55 08             	call   *0x8(%ebp)
f0101305:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101308:	83 eb 01             	sub    $0x1,%ebx
f010130b:	eb 1a                	jmp    f0101327 <vprintfmt+0x24b>
f010130d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101310:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101313:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101316:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101319:	eb 0c                	jmp    f0101327 <vprintfmt+0x24b>
f010131b:	89 75 08             	mov    %esi,0x8(%ebp)
f010131e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101321:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101324:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101327:	83 c7 01             	add    $0x1,%edi
f010132a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010132e:	0f be d0             	movsbl %al,%edx
f0101331:	85 d2                	test   %edx,%edx
f0101333:	74 23                	je     f0101358 <vprintfmt+0x27c>
f0101335:	85 f6                	test   %esi,%esi
f0101337:	78 a1                	js     f01012da <vprintfmt+0x1fe>
f0101339:	83 ee 01             	sub    $0x1,%esi
f010133c:	79 9c                	jns    f01012da <vprintfmt+0x1fe>
f010133e:	89 df                	mov    %ebx,%edi
f0101340:	8b 75 08             	mov    0x8(%ebp),%esi
f0101343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101346:	eb 18                	jmp    f0101360 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101348:	83 ec 08             	sub    $0x8,%esp
f010134b:	53                   	push   %ebx
f010134c:	6a 20                	push   $0x20
f010134e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101350:	83 ef 01             	sub    $0x1,%edi
f0101353:	83 c4 10             	add    $0x10,%esp
f0101356:	eb 08                	jmp    f0101360 <vprintfmt+0x284>
f0101358:	89 df                	mov    %ebx,%edi
f010135a:	8b 75 08             	mov    0x8(%ebp),%esi
f010135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101360:	85 ff                	test   %edi,%edi
f0101362:	7f e4                	jg     f0101348 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101364:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101367:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010136a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010136d:	e9 90 fd ff ff       	jmp    f0101102 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101372:	83 f9 01             	cmp    $0x1,%ecx
f0101375:	7e 19                	jle    f0101390 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0101377:	8b 45 14             	mov    0x14(%ebp),%eax
f010137a:	8b 50 04             	mov    0x4(%eax),%edx
f010137d:	8b 00                	mov    (%eax),%eax
f010137f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101382:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101385:	8b 45 14             	mov    0x14(%ebp),%eax
f0101388:	8d 40 08             	lea    0x8(%eax),%eax
f010138b:	89 45 14             	mov    %eax,0x14(%ebp)
f010138e:	eb 38                	jmp    f01013c8 <vprintfmt+0x2ec>
	else if (lflag)
f0101390:	85 c9                	test   %ecx,%ecx
f0101392:	74 1b                	je     f01013af <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0101394:	8b 45 14             	mov    0x14(%ebp),%eax
f0101397:	8b 00                	mov    (%eax),%eax
f0101399:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010139c:	89 c1                	mov    %eax,%ecx
f010139e:	c1 f9 1f             	sar    $0x1f,%ecx
f01013a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01013a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a7:	8d 40 04             	lea    0x4(%eax),%eax
f01013aa:	89 45 14             	mov    %eax,0x14(%ebp)
f01013ad:	eb 19                	jmp    f01013c8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f01013af:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b2:	8b 00                	mov    (%eax),%eax
f01013b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013b7:	89 c1                	mov    %eax,%ecx
f01013b9:	c1 f9 1f             	sar    $0x1f,%ecx
f01013bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01013bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c2:	8d 40 04             	lea    0x4(%eax),%eax
f01013c5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01013c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01013cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01013ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01013d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01013d7:	0f 89 0e 01 00 00    	jns    f01014eb <vprintfmt+0x40f>
				putch('-', putdat);
f01013dd:	83 ec 08             	sub    $0x8,%esp
f01013e0:	53                   	push   %ebx
f01013e1:	6a 2d                	push   $0x2d
f01013e3:	ff d6                	call   *%esi
				num = -(long long) num;
f01013e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01013e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01013eb:	f7 da                	neg    %edx
f01013ed:	83 d1 00             	adc    $0x0,%ecx
f01013f0:	f7 d9                	neg    %ecx
f01013f2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01013f5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01013fa:	e9 ec 00 00 00       	jmp    f01014eb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01013ff:	83 f9 01             	cmp    $0x1,%ecx
f0101402:	7e 18                	jle    f010141c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0101404:	8b 45 14             	mov    0x14(%ebp),%eax
f0101407:	8b 10                	mov    (%eax),%edx
f0101409:	8b 48 04             	mov    0x4(%eax),%ecx
f010140c:	8d 40 08             	lea    0x8(%eax),%eax
f010140f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101412:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101417:	e9 cf 00 00 00       	jmp    f01014eb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010141c:	85 c9                	test   %ecx,%ecx
f010141e:	74 1a                	je     f010143a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0101420:	8b 45 14             	mov    0x14(%ebp),%eax
f0101423:	8b 10                	mov    (%eax),%edx
f0101425:	b9 00 00 00 00       	mov    $0x0,%ecx
f010142a:	8d 40 04             	lea    0x4(%eax),%eax
f010142d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101430:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101435:	e9 b1 00 00 00       	jmp    f01014eb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010143a:	8b 45 14             	mov    0x14(%ebp),%eax
f010143d:	8b 10                	mov    (%eax),%edx
f010143f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101444:	8d 40 04             	lea    0x4(%eax),%eax
f0101447:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010144a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010144f:	e9 97 00 00 00       	jmp    f01014eb <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101454:	83 ec 08             	sub    $0x8,%esp
f0101457:	53                   	push   %ebx
f0101458:	6a 58                	push   $0x58
f010145a:	ff d6                	call   *%esi
			putch('X', putdat);
f010145c:	83 c4 08             	add    $0x8,%esp
f010145f:	53                   	push   %ebx
f0101460:	6a 58                	push   $0x58
f0101462:	ff d6                	call   *%esi
			putch('X', putdat);
f0101464:	83 c4 08             	add    $0x8,%esp
f0101467:	53                   	push   %ebx
f0101468:	6a 58                	push   $0x58
f010146a:	ff d6                	call   *%esi
			break;
f010146c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010146f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101472:	e9 8b fc ff ff       	jmp    f0101102 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0101477:	83 ec 08             	sub    $0x8,%esp
f010147a:	53                   	push   %ebx
f010147b:	6a 30                	push   $0x30
f010147d:	ff d6                	call   *%esi
			putch('x', putdat);
f010147f:	83 c4 08             	add    $0x8,%esp
f0101482:	53                   	push   %ebx
f0101483:	6a 78                	push   $0x78
f0101485:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101487:	8b 45 14             	mov    0x14(%ebp),%eax
f010148a:	8b 10                	mov    (%eax),%edx
f010148c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101491:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101494:	8d 40 04             	lea    0x4(%eax),%eax
f0101497:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010149a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010149f:	eb 4a                	jmp    f01014eb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01014a1:	83 f9 01             	cmp    $0x1,%ecx
f01014a4:	7e 15                	jle    f01014bb <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f01014a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a9:	8b 10                	mov    (%eax),%edx
f01014ab:	8b 48 04             	mov    0x4(%eax),%ecx
f01014ae:	8d 40 08             	lea    0x8(%eax),%eax
f01014b1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01014b4:	b8 10 00 00 00       	mov    $0x10,%eax
f01014b9:	eb 30                	jmp    f01014eb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01014bb:	85 c9                	test   %ecx,%ecx
f01014bd:	74 17                	je     f01014d6 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f01014bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01014c2:	8b 10                	mov    (%eax),%edx
f01014c4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014c9:	8d 40 04             	lea    0x4(%eax),%eax
f01014cc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01014cf:	b8 10 00 00 00       	mov    $0x10,%eax
f01014d4:	eb 15                	jmp    f01014eb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01014d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01014d9:	8b 10                	mov    (%eax),%edx
f01014db:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014e0:	8d 40 04             	lea    0x4(%eax),%eax
f01014e3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01014e6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01014eb:	83 ec 0c             	sub    $0xc,%esp
f01014ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01014f2:	57                   	push   %edi
f01014f3:	ff 75 e0             	pushl  -0x20(%ebp)
f01014f6:	50                   	push   %eax
f01014f7:	51                   	push   %ecx
f01014f8:	52                   	push   %edx
f01014f9:	89 da                	mov    %ebx,%edx
f01014fb:	89 f0                	mov    %esi,%eax
f01014fd:	e8 f1 fa ff ff       	call   f0100ff3 <printnum>
			break;
f0101502:	83 c4 20             	add    $0x20,%esp
f0101505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101508:	e9 f5 fb ff ff       	jmp    f0101102 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010150d:	83 ec 08             	sub    $0x8,%esp
f0101510:	53                   	push   %ebx
f0101511:	52                   	push   %edx
f0101512:	ff d6                	call   *%esi
			break;
f0101514:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010151a:	e9 e3 fb ff ff       	jmp    f0101102 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010151f:	83 ec 08             	sub    $0x8,%esp
f0101522:	53                   	push   %ebx
f0101523:	6a 25                	push   $0x25
f0101525:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101527:	83 c4 10             	add    $0x10,%esp
f010152a:	eb 03                	jmp    f010152f <vprintfmt+0x453>
f010152c:	83 ef 01             	sub    $0x1,%edi
f010152f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101533:	75 f7                	jne    f010152c <vprintfmt+0x450>
f0101535:	e9 c8 fb ff ff       	jmp    f0101102 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010153a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010153d:	5b                   	pop    %ebx
f010153e:	5e                   	pop    %esi
f010153f:	5f                   	pop    %edi
f0101540:	5d                   	pop    %ebp
f0101541:	c3                   	ret    

f0101542 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101542:	55                   	push   %ebp
f0101543:	89 e5                	mov    %esp,%ebp
f0101545:	83 ec 18             	sub    $0x18,%esp
f0101548:	8b 45 08             	mov    0x8(%ebp),%eax
f010154b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010154e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101551:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101555:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101558:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010155f:	85 c0                	test   %eax,%eax
f0101561:	74 26                	je     f0101589 <vsnprintf+0x47>
f0101563:	85 d2                	test   %edx,%edx
f0101565:	7e 22                	jle    f0101589 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101567:	ff 75 14             	pushl  0x14(%ebp)
f010156a:	ff 75 10             	pushl  0x10(%ebp)
f010156d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101570:	50                   	push   %eax
f0101571:	68 a2 10 10 f0       	push   $0xf01010a2
f0101576:	e8 61 fb ff ff       	call   f01010dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010157b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010157e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101581:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101584:	83 c4 10             	add    $0x10,%esp
f0101587:	eb 05                	jmp    f010158e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010158e:	c9                   	leave  
f010158f:	c3                   	ret    

f0101590 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101590:	55                   	push   %ebp
f0101591:	89 e5                	mov    %esp,%ebp
f0101593:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101596:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101599:	50                   	push   %eax
f010159a:	ff 75 10             	pushl  0x10(%ebp)
f010159d:	ff 75 0c             	pushl  0xc(%ebp)
f01015a0:	ff 75 08             	pushl  0x8(%ebp)
f01015a3:	e8 9a ff ff ff       	call   f0101542 <vsnprintf>
	va_end(ap);

	return rc;
}
f01015a8:	c9                   	leave  
f01015a9:	c3                   	ret    

f01015aa <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01015aa:	55                   	push   %ebp
f01015ab:	89 e5                	mov    %esp,%ebp
f01015ad:	57                   	push   %edi
f01015ae:	56                   	push   %esi
f01015af:	53                   	push   %ebx
f01015b0:	83 ec 0c             	sub    $0xc,%esp
f01015b3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01015b6:	85 c0                	test   %eax,%eax
f01015b8:	74 11                	je     f01015cb <readline+0x21>
		cprintf("%s", prompt);
f01015ba:	83 ec 08             	sub    $0x8,%esp
f01015bd:	50                   	push   %eax
f01015be:	68 74 22 10 f0       	push   $0xf0102274
f01015c3:	e8 50 f7 ff ff       	call   f0100d18 <cprintf>
f01015c8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01015cb:	83 ec 0c             	sub    $0xc,%esp
f01015ce:	6a 00                	push   $0x0
f01015d0:	e8 3e f0 ff ff       	call   f0100613 <iscons>
f01015d5:	89 c7                	mov    %eax,%edi
f01015d7:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01015da:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01015df:	e8 1e f0 ff ff       	call   f0100602 <getchar>
f01015e4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01015e6:	85 c0                	test   %eax,%eax
f01015e8:	79 18                	jns    f0101602 <readline+0x58>
			cprintf("read error: %e\n", c);
f01015ea:	83 ec 08             	sub    $0x8,%esp
f01015ed:	50                   	push   %eax
f01015ee:	68 60 25 10 f0       	push   $0xf0102560
f01015f3:	e8 20 f7 ff ff       	call   f0100d18 <cprintf>
			return NULL;
f01015f8:	83 c4 10             	add    $0x10,%esp
f01015fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101600:	eb 79                	jmp    f010167b <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101602:	83 f8 08             	cmp    $0x8,%eax
f0101605:	0f 94 c2             	sete   %dl
f0101608:	83 f8 7f             	cmp    $0x7f,%eax
f010160b:	0f 94 c0             	sete   %al
f010160e:	08 c2                	or     %al,%dl
f0101610:	74 1a                	je     f010162c <readline+0x82>
f0101612:	85 f6                	test   %esi,%esi
f0101614:	7e 16                	jle    f010162c <readline+0x82>
			if (echoing)
f0101616:	85 ff                	test   %edi,%edi
f0101618:	74 0d                	je     f0101627 <readline+0x7d>
				cputchar('\b');
f010161a:	83 ec 0c             	sub    $0xc,%esp
f010161d:	6a 08                	push   $0x8
f010161f:	e8 ce ef ff ff       	call   f01005f2 <cputchar>
f0101624:	83 c4 10             	add    $0x10,%esp
			i--;
f0101627:	83 ee 01             	sub    $0x1,%esi
f010162a:	eb b3                	jmp    f01015df <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010162c:	83 fb 1f             	cmp    $0x1f,%ebx
f010162f:	7e 23                	jle    f0101654 <readline+0xaa>
f0101631:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101637:	7f 1b                	jg     f0101654 <readline+0xaa>
			if (echoing)
f0101639:	85 ff                	test   %edi,%edi
f010163b:	74 0c                	je     f0101649 <readline+0x9f>
				cputchar(c);
f010163d:	83 ec 0c             	sub    $0xc,%esp
f0101640:	53                   	push   %ebx
f0101641:	e8 ac ef ff ff       	call   f01005f2 <cputchar>
f0101646:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101649:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f010164f:	8d 76 01             	lea    0x1(%esi),%esi
f0101652:	eb 8b                	jmp    f01015df <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101654:	83 fb 0a             	cmp    $0xa,%ebx
f0101657:	74 05                	je     f010165e <readline+0xb4>
f0101659:	83 fb 0d             	cmp    $0xd,%ebx
f010165c:	75 81                	jne    f01015df <readline+0x35>
			if (echoing)
f010165e:	85 ff                	test   %edi,%edi
f0101660:	74 0d                	je     f010166f <readline+0xc5>
				cputchar('\n');
f0101662:	83 ec 0c             	sub    $0xc,%esp
f0101665:	6a 0a                	push   $0xa
f0101667:	e8 86 ef ff ff       	call   f01005f2 <cputchar>
f010166c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010166f:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
			return buf;
f0101676:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
		}
	}
}
f010167b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010167e:	5b                   	pop    %ebx
f010167f:	5e                   	pop    %esi
f0101680:	5f                   	pop    %edi
f0101681:	5d                   	pop    %ebp
f0101682:	c3                   	ret    

f0101683 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101683:	55                   	push   %ebp
f0101684:	89 e5                	mov    %esp,%ebp
f0101686:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101689:	b8 00 00 00 00       	mov    $0x0,%eax
f010168e:	eb 03                	jmp    f0101693 <strlen+0x10>
		n++;
f0101690:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101697:	75 f7                	jne    f0101690 <strlen+0xd>
		n++;
	return n;
}
f0101699:	5d                   	pop    %ebp
f010169a:	c3                   	ret    

f010169b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010169b:	55                   	push   %ebp
f010169c:	89 e5                	mov    %esp,%ebp
f010169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01016a9:	eb 03                	jmp    f01016ae <strnlen+0x13>
		n++;
f01016ab:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016ae:	39 c2                	cmp    %eax,%edx
f01016b0:	74 08                	je     f01016ba <strnlen+0x1f>
f01016b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01016b6:	75 f3                	jne    f01016ab <strnlen+0x10>
f01016b8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01016ba:	5d                   	pop    %ebp
f01016bb:	c3                   	ret    

f01016bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01016bc:	55                   	push   %ebp
f01016bd:	89 e5                	mov    %esp,%ebp
f01016bf:	53                   	push   %ebx
f01016c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016c6:	89 c2                	mov    %eax,%edx
f01016c8:	83 c2 01             	add    $0x1,%edx
f01016cb:	83 c1 01             	add    $0x1,%ecx
f01016ce:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01016d2:	88 5a ff             	mov    %bl,-0x1(%edx)
f01016d5:	84 db                	test   %bl,%bl
f01016d7:	75 ef                	jne    f01016c8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01016d9:	5b                   	pop    %ebx
f01016da:	5d                   	pop    %ebp
f01016db:	c3                   	ret    

f01016dc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016dc:	55                   	push   %ebp
f01016dd:	89 e5                	mov    %esp,%ebp
f01016df:	53                   	push   %ebx
f01016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016e3:	53                   	push   %ebx
f01016e4:	e8 9a ff ff ff       	call   f0101683 <strlen>
f01016e9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01016ec:	ff 75 0c             	pushl  0xc(%ebp)
f01016ef:	01 d8                	add    %ebx,%eax
f01016f1:	50                   	push   %eax
f01016f2:	e8 c5 ff ff ff       	call   f01016bc <strcpy>
	return dst;
}
f01016f7:	89 d8                	mov    %ebx,%eax
f01016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016fc:	c9                   	leave  
f01016fd:	c3                   	ret    

f01016fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016fe:	55                   	push   %ebp
f01016ff:	89 e5                	mov    %esp,%ebp
f0101701:	56                   	push   %esi
f0101702:	53                   	push   %ebx
f0101703:	8b 75 08             	mov    0x8(%ebp),%esi
f0101706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101709:	89 f3                	mov    %esi,%ebx
f010170b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010170e:	89 f2                	mov    %esi,%edx
f0101710:	eb 0f                	jmp    f0101721 <strncpy+0x23>
		*dst++ = *src;
f0101712:	83 c2 01             	add    $0x1,%edx
f0101715:	0f b6 01             	movzbl (%ecx),%eax
f0101718:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010171b:	80 39 01             	cmpb   $0x1,(%ecx)
f010171e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101721:	39 da                	cmp    %ebx,%edx
f0101723:	75 ed                	jne    f0101712 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101725:	89 f0                	mov    %esi,%eax
f0101727:	5b                   	pop    %ebx
f0101728:	5e                   	pop    %esi
f0101729:	5d                   	pop    %ebp
f010172a:	c3                   	ret    

f010172b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010172b:	55                   	push   %ebp
f010172c:	89 e5                	mov    %esp,%ebp
f010172e:	56                   	push   %esi
f010172f:	53                   	push   %ebx
f0101730:	8b 75 08             	mov    0x8(%ebp),%esi
f0101733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101736:	8b 55 10             	mov    0x10(%ebp),%edx
f0101739:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010173b:	85 d2                	test   %edx,%edx
f010173d:	74 21                	je     f0101760 <strlcpy+0x35>
f010173f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101743:	89 f2                	mov    %esi,%edx
f0101745:	eb 09                	jmp    f0101750 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101747:	83 c2 01             	add    $0x1,%edx
f010174a:	83 c1 01             	add    $0x1,%ecx
f010174d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101750:	39 c2                	cmp    %eax,%edx
f0101752:	74 09                	je     f010175d <strlcpy+0x32>
f0101754:	0f b6 19             	movzbl (%ecx),%ebx
f0101757:	84 db                	test   %bl,%bl
f0101759:	75 ec                	jne    f0101747 <strlcpy+0x1c>
f010175b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010175d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101760:	29 f0                	sub    %esi,%eax
}
f0101762:	5b                   	pop    %ebx
f0101763:	5e                   	pop    %esi
f0101764:	5d                   	pop    %ebp
f0101765:	c3                   	ret    

f0101766 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101766:	55                   	push   %ebp
f0101767:	89 e5                	mov    %esp,%ebp
f0101769:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010176c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010176f:	eb 06                	jmp    f0101777 <strcmp+0x11>
		p++, q++;
f0101771:	83 c1 01             	add    $0x1,%ecx
f0101774:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101777:	0f b6 01             	movzbl (%ecx),%eax
f010177a:	84 c0                	test   %al,%al
f010177c:	74 04                	je     f0101782 <strcmp+0x1c>
f010177e:	3a 02                	cmp    (%edx),%al
f0101780:	74 ef                	je     f0101771 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101782:	0f b6 c0             	movzbl %al,%eax
f0101785:	0f b6 12             	movzbl (%edx),%edx
f0101788:	29 d0                	sub    %edx,%eax
}
f010178a:	5d                   	pop    %ebp
f010178b:	c3                   	ret    

f010178c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010178c:	55                   	push   %ebp
f010178d:	89 e5                	mov    %esp,%ebp
f010178f:	53                   	push   %ebx
f0101790:	8b 45 08             	mov    0x8(%ebp),%eax
f0101793:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101796:	89 c3                	mov    %eax,%ebx
f0101798:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010179b:	eb 06                	jmp    f01017a3 <strncmp+0x17>
		n--, p++, q++;
f010179d:	83 c0 01             	add    $0x1,%eax
f01017a0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01017a3:	39 d8                	cmp    %ebx,%eax
f01017a5:	74 15                	je     f01017bc <strncmp+0x30>
f01017a7:	0f b6 08             	movzbl (%eax),%ecx
f01017aa:	84 c9                	test   %cl,%cl
f01017ac:	74 04                	je     f01017b2 <strncmp+0x26>
f01017ae:	3a 0a                	cmp    (%edx),%cl
f01017b0:	74 eb                	je     f010179d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017b2:	0f b6 00             	movzbl (%eax),%eax
f01017b5:	0f b6 12             	movzbl (%edx),%edx
f01017b8:	29 d0                	sub    %edx,%eax
f01017ba:	eb 05                	jmp    f01017c1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01017bc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01017c1:	5b                   	pop    %ebx
f01017c2:	5d                   	pop    %ebp
f01017c3:	c3                   	ret    

f01017c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017c4:	55                   	push   %ebp
f01017c5:	89 e5                	mov    %esp,%ebp
f01017c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017ce:	eb 07                	jmp    f01017d7 <strchr+0x13>
		if (*s == c)
f01017d0:	38 ca                	cmp    %cl,%dl
f01017d2:	74 0f                	je     f01017e3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01017d4:	83 c0 01             	add    $0x1,%eax
f01017d7:	0f b6 10             	movzbl (%eax),%edx
f01017da:	84 d2                	test   %dl,%dl
f01017dc:	75 f2                	jne    f01017d0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017e3:	5d                   	pop    %ebp
f01017e4:	c3                   	ret    

f01017e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017e5:	55                   	push   %ebp
f01017e6:	89 e5                	mov    %esp,%ebp
f01017e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01017eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017ef:	eb 03                	jmp    f01017f4 <strfind+0xf>
f01017f1:	83 c0 01             	add    $0x1,%eax
f01017f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017f7:	38 ca                	cmp    %cl,%dl
f01017f9:	74 04                	je     f01017ff <strfind+0x1a>
f01017fb:	84 d2                	test   %dl,%dl
f01017fd:	75 f2                	jne    f01017f1 <strfind+0xc>
			break;
	return (char *) s;
}
f01017ff:	5d                   	pop    %ebp
f0101800:	c3                   	ret    

f0101801 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101801:	55                   	push   %ebp
f0101802:	89 e5                	mov    %esp,%ebp
f0101804:	57                   	push   %edi
f0101805:	56                   	push   %esi
f0101806:	53                   	push   %ebx
f0101807:	8b 7d 08             	mov    0x8(%ebp),%edi
f010180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010180d:	85 c9                	test   %ecx,%ecx
f010180f:	74 36                	je     f0101847 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101811:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101817:	75 28                	jne    f0101841 <memset+0x40>
f0101819:	f6 c1 03             	test   $0x3,%cl
f010181c:	75 23                	jne    f0101841 <memset+0x40>
		c &= 0xFF;
f010181e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101822:	89 d3                	mov    %edx,%ebx
f0101824:	c1 e3 08             	shl    $0x8,%ebx
f0101827:	89 d6                	mov    %edx,%esi
f0101829:	c1 e6 18             	shl    $0x18,%esi
f010182c:	89 d0                	mov    %edx,%eax
f010182e:	c1 e0 10             	shl    $0x10,%eax
f0101831:	09 f0                	or     %esi,%eax
f0101833:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101835:	89 d8                	mov    %ebx,%eax
f0101837:	09 d0                	or     %edx,%eax
f0101839:	c1 e9 02             	shr    $0x2,%ecx
f010183c:	fc                   	cld    
f010183d:	f3 ab                	rep stos %eax,%es:(%edi)
f010183f:	eb 06                	jmp    f0101847 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101841:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101844:	fc                   	cld    
f0101845:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101847:	89 f8                	mov    %edi,%eax
f0101849:	5b                   	pop    %ebx
f010184a:	5e                   	pop    %esi
f010184b:	5f                   	pop    %edi
f010184c:	5d                   	pop    %ebp
f010184d:	c3                   	ret    

f010184e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010184e:	55                   	push   %ebp
f010184f:	89 e5                	mov    %esp,%ebp
f0101851:	57                   	push   %edi
f0101852:	56                   	push   %esi
f0101853:	8b 45 08             	mov    0x8(%ebp),%eax
f0101856:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101859:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010185c:	39 c6                	cmp    %eax,%esi
f010185e:	73 35                	jae    f0101895 <memmove+0x47>
f0101860:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101863:	39 d0                	cmp    %edx,%eax
f0101865:	73 2e                	jae    f0101895 <memmove+0x47>
		s += n;
		d += n;
f0101867:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010186a:	89 d6                	mov    %edx,%esi
f010186c:	09 fe                	or     %edi,%esi
f010186e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101874:	75 13                	jne    f0101889 <memmove+0x3b>
f0101876:	f6 c1 03             	test   $0x3,%cl
f0101879:	75 0e                	jne    f0101889 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010187b:	83 ef 04             	sub    $0x4,%edi
f010187e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101881:	c1 e9 02             	shr    $0x2,%ecx
f0101884:	fd                   	std    
f0101885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101887:	eb 09                	jmp    f0101892 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101889:	83 ef 01             	sub    $0x1,%edi
f010188c:	8d 72 ff             	lea    -0x1(%edx),%esi
f010188f:	fd                   	std    
f0101890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101892:	fc                   	cld    
f0101893:	eb 1d                	jmp    f01018b2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101895:	89 f2                	mov    %esi,%edx
f0101897:	09 c2                	or     %eax,%edx
f0101899:	f6 c2 03             	test   $0x3,%dl
f010189c:	75 0f                	jne    f01018ad <memmove+0x5f>
f010189e:	f6 c1 03             	test   $0x3,%cl
f01018a1:	75 0a                	jne    f01018ad <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01018a3:	c1 e9 02             	shr    $0x2,%ecx
f01018a6:	89 c7                	mov    %eax,%edi
f01018a8:	fc                   	cld    
f01018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01018ab:	eb 05                	jmp    f01018b2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01018ad:	89 c7                	mov    %eax,%edi
f01018af:	fc                   	cld    
f01018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01018b2:	5e                   	pop    %esi
f01018b3:	5f                   	pop    %edi
f01018b4:	5d                   	pop    %ebp
f01018b5:	c3                   	ret    

f01018b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01018b6:	55                   	push   %ebp
f01018b7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01018b9:	ff 75 10             	pushl  0x10(%ebp)
f01018bc:	ff 75 0c             	pushl  0xc(%ebp)
f01018bf:	ff 75 08             	pushl  0x8(%ebp)
f01018c2:	e8 87 ff ff ff       	call   f010184e <memmove>
}
f01018c7:	c9                   	leave  
f01018c8:	c3                   	ret    

f01018c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018c9:	55                   	push   %ebp
f01018ca:	89 e5                	mov    %esp,%ebp
f01018cc:	56                   	push   %esi
f01018cd:	53                   	push   %ebx
f01018ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01018d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018d4:	89 c6                	mov    %eax,%esi
f01018d6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018d9:	eb 1a                	jmp    f01018f5 <memcmp+0x2c>
		if (*s1 != *s2)
f01018db:	0f b6 08             	movzbl (%eax),%ecx
f01018de:	0f b6 1a             	movzbl (%edx),%ebx
f01018e1:	38 d9                	cmp    %bl,%cl
f01018e3:	74 0a                	je     f01018ef <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01018e5:	0f b6 c1             	movzbl %cl,%eax
f01018e8:	0f b6 db             	movzbl %bl,%ebx
f01018eb:	29 d8                	sub    %ebx,%eax
f01018ed:	eb 0f                	jmp    f01018fe <memcmp+0x35>
		s1++, s2++;
f01018ef:	83 c0 01             	add    $0x1,%eax
f01018f2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018f5:	39 f0                	cmp    %esi,%eax
f01018f7:	75 e2                	jne    f01018db <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01018f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018fe:	5b                   	pop    %ebx
f01018ff:	5e                   	pop    %esi
f0101900:	5d                   	pop    %ebp
f0101901:	c3                   	ret    

f0101902 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101902:	55                   	push   %ebp
f0101903:	89 e5                	mov    %esp,%ebp
f0101905:	53                   	push   %ebx
f0101906:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101909:	89 c1                	mov    %eax,%ecx
f010190b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010190e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101912:	eb 0a                	jmp    f010191e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101914:	0f b6 10             	movzbl (%eax),%edx
f0101917:	39 da                	cmp    %ebx,%edx
f0101919:	74 07                	je     f0101922 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010191b:	83 c0 01             	add    $0x1,%eax
f010191e:	39 c8                	cmp    %ecx,%eax
f0101920:	72 f2                	jb     f0101914 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101922:	5b                   	pop    %ebx
f0101923:	5d                   	pop    %ebp
f0101924:	c3                   	ret    

f0101925 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101925:	55                   	push   %ebp
f0101926:	89 e5                	mov    %esp,%ebp
f0101928:	57                   	push   %edi
f0101929:	56                   	push   %esi
f010192a:	53                   	push   %ebx
f010192b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010192e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101931:	eb 03                	jmp    f0101936 <strtol+0x11>
		s++;
f0101933:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101936:	0f b6 01             	movzbl (%ecx),%eax
f0101939:	3c 20                	cmp    $0x20,%al
f010193b:	74 f6                	je     f0101933 <strtol+0xe>
f010193d:	3c 09                	cmp    $0x9,%al
f010193f:	74 f2                	je     f0101933 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101941:	3c 2b                	cmp    $0x2b,%al
f0101943:	75 0a                	jne    f010194f <strtol+0x2a>
		s++;
f0101945:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101948:	bf 00 00 00 00       	mov    $0x0,%edi
f010194d:	eb 11                	jmp    f0101960 <strtol+0x3b>
f010194f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101954:	3c 2d                	cmp    $0x2d,%al
f0101956:	75 08                	jne    f0101960 <strtol+0x3b>
		s++, neg = 1;
f0101958:	83 c1 01             	add    $0x1,%ecx
f010195b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101960:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101966:	75 15                	jne    f010197d <strtol+0x58>
f0101968:	80 39 30             	cmpb   $0x30,(%ecx)
f010196b:	75 10                	jne    f010197d <strtol+0x58>
f010196d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101971:	75 7c                	jne    f01019ef <strtol+0xca>
		s += 2, base = 16;
f0101973:	83 c1 02             	add    $0x2,%ecx
f0101976:	bb 10 00 00 00       	mov    $0x10,%ebx
f010197b:	eb 16                	jmp    f0101993 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010197d:	85 db                	test   %ebx,%ebx
f010197f:	75 12                	jne    f0101993 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101981:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101986:	80 39 30             	cmpb   $0x30,(%ecx)
f0101989:	75 08                	jne    f0101993 <strtol+0x6e>
		s++, base = 8;
f010198b:	83 c1 01             	add    $0x1,%ecx
f010198e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101993:	b8 00 00 00 00       	mov    $0x0,%eax
f0101998:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010199b:	0f b6 11             	movzbl (%ecx),%edx
f010199e:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019a1:	89 f3                	mov    %esi,%ebx
f01019a3:	80 fb 09             	cmp    $0x9,%bl
f01019a6:	77 08                	ja     f01019b0 <strtol+0x8b>
			dig = *s - '0';
f01019a8:	0f be d2             	movsbl %dl,%edx
f01019ab:	83 ea 30             	sub    $0x30,%edx
f01019ae:	eb 22                	jmp    f01019d2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01019b0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019b3:	89 f3                	mov    %esi,%ebx
f01019b5:	80 fb 19             	cmp    $0x19,%bl
f01019b8:	77 08                	ja     f01019c2 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01019ba:	0f be d2             	movsbl %dl,%edx
f01019bd:	83 ea 57             	sub    $0x57,%edx
f01019c0:	eb 10                	jmp    f01019d2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01019c2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019c5:	89 f3                	mov    %esi,%ebx
f01019c7:	80 fb 19             	cmp    $0x19,%bl
f01019ca:	77 16                	ja     f01019e2 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01019cc:	0f be d2             	movsbl %dl,%edx
f01019cf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01019d2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01019d5:	7d 0b                	jge    f01019e2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01019d7:	83 c1 01             	add    $0x1,%ecx
f01019da:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019de:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01019e0:	eb b9                	jmp    f010199b <strtol+0x76>

	if (endptr)
f01019e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019e6:	74 0d                	je     f01019f5 <strtol+0xd0>
		*endptr = (char *) s;
f01019e8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019eb:	89 0e                	mov    %ecx,(%esi)
f01019ed:	eb 06                	jmp    f01019f5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01019ef:	85 db                	test   %ebx,%ebx
f01019f1:	74 98                	je     f010198b <strtol+0x66>
f01019f3:	eb 9e                	jmp    f0101993 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01019f5:	89 c2                	mov    %eax,%edx
f01019f7:	f7 da                	neg    %edx
f01019f9:	85 ff                	test   %edi,%edi
f01019fb:	0f 45 c2             	cmovne %edx,%eax
}
f01019fe:	5b                   	pop    %ebx
f01019ff:	5e                   	pop    %esi
f0101a00:	5f                   	pop    %edi
f0101a01:	5d                   	pop    %ebp
f0101a02:	c3                   	ret    
f0101a03:	66 90                	xchg   %ax,%ax
f0101a05:	66 90                	xchg   %ax,%ax
f0101a07:	66 90                	xchg   %ax,%ax
f0101a09:	66 90                	xchg   %ax,%ax
f0101a0b:	66 90                	xchg   %ax,%ax
f0101a0d:	66 90                	xchg   %ax,%ax
f0101a0f:	90                   	nop

f0101a10 <__udivdi3>:
f0101a10:	55                   	push   %ebp
f0101a11:	57                   	push   %edi
f0101a12:	56                   	push   %esi
f0101a13:	53                   	push   %ebx
f0101a14:	83 ec 1c             	sub    $0x1c,%esp
f0101a17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0101a1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0101a1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101a23:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a27:	85 f6                	test   %esi,%esi
f0101a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101a2d:	89 ca                	mov    %ecx,%edx
f0101a2f:	89 f8                	mov    %edi,%eax
f0101a31:	75 3d                	jne    f0101a70 <__udivdi3+0x60>
f0101a33:	39 cf                	cmp    %ecx,%edi
f0101a35:	0f 87 c5 00 00 00    	ja     f0101b00 <__udivdi3+0xf0>
f0101a3b:	85 ff                	test   %edi,%edi
f0101a3d:	89 fd                	mov    %edi,%ebp
f0101a3f:	75 0b                	jne    f0101a4c <__udivdi3+0x3c>
f0101a41:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a46:	31 d2                	xor    %edx,%edx
f0101a48:	f7 f7                	div    %edi
f0101a4a:	89 c5                	mov    %eax,%ebp
f0101a4c:	89 c8                	mov    %ecx,%eax
f0101a4e:	31 d2                	xor    %edx,%edx
f0101a50:	f7 f5                	div    %ebp
f0101a52:	89 c1                	mov    %eax,%ecx
f0101a54:	89 d8                	mov    %ebx,%eax
f0101a56:	89 cf                	mov    %ecx,%edi
f0101a58:	f7 f5                	div    %ebp
f0101a5a:	89 c3                	mov    %eax,%ebx
f0101a5c:	89 d8                	mov    %ebx,%eax
f0101a5e:	89 fa                	mov    %edi,%edx
f0101a60:	83 c4 1c             	add    $0x1c,%esp
f0101a63:	5b                   	pop    %ebx
f0101a64:	5e                   	pop    %esi
f0101a65:	5f                   	pop    %edi
f0101a66:	5d                   	pop    %ebp
f0101a67:	c3                   	ret    
f0101a68:	90                   	nop
f0101a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a70:	39 ce                	cmp    %ecx,%esi
f0101a72:	77 74                	ja     f0101ae8 <__udivdi3+0xd8>
f0101a74:	0f bd fe             	bsr    %esi,%edi
f0101a77:	83 f7 1f             	xor    $0x1f,%edi
f0101a7a:	0f 84 98 00 00 00    	je     f0101b18 <__udivdi3+0x108>
f0101a80:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101a85:	89 f9                	mov    %edi,%ecx
f0101a87:	89 c5                	mov    %eax,%ebp
f0101a89:	29 fb                	sub    %edi,%ebx
f0101a8b:	d3 e6                	shl    %cl,%esi
f0101a8d:	89 d9                	mov    %ebx,%ecx
f0101a8f:	d3 ed                	shr    %cl,%ebp
f0101a91:	89 f9                	mov    %edi,%ecx
f0101a93:	d3 e0                	shl    %cl,%eax
f0101a95:	09 ee                	or     %ebp,%esi
f0101a97:	89 d9                	mov    %ebx,%ecx
f0101a99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a9d:	89 d5                	mov    %edx,%ebp
f0101a9f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101aa3:	d3 ed                	shr    %cl,%ebp
f0101aa5:	89 f9                	mov    %edi,%ecx
f0101aa7:	d3 e2                	shl    %cl,%edx
f0101aa9:	89 d9                	mov    %ebx,%ecx
f0101aab:	d3 e8                	shr    %cl,%eax
f0101aad:	09 c2                	or     %eax,%edx
f0101aaf:	89 d0                	mov    %edx,%eax
f0101ab1:	89 ea                	mov    %ebp,%edx
f0101ab3:	f7 f6                	div    %esi
f0101ab5:	89 d5                	mov    %edx,%ebp
f0101ab7:	89 c3                	mov    %eax,%ebx
f0101ab9:	f7 64 24 0c          	mull   0xc(%esp)
f0101abd:	39 d5                	cmp    %edx,%ebp
f0101abf:	72 10                	jb     f0101ad1 <__udivdi3+0xc1>
f0101ac1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101ac5:	89 f9                	mov    %edi,%ecx
f0101ac7:	d3 e6                	shl    %cl,%esi
f0101ac9:	39 c6                	cmp    %eax,%esi
f0101acb:	73 07                	jae    f0101ad4 <__udivdi3+0xc4>
f0101acd:	39 d5                	cmp    %edx,%ebp
f0101acf:	75 03                	jne    f0101ad4 <__udivdi3+0xc4>
f0101ad1:	83 eb 01             	sub    $0x1,%ebx
f0101ad4:	31 ff                	xor    %edi,%edi
f0101ad6:	89 d8                	mov    %ebx,%eax
f0101ad8:	89 fa                	mov    %edi,%edx
f0101ada:	83 c4 1c             	add    $0x1c,%esp
f0101add:	5b                   	pop    %ebx
f0101ade:	5e                   	pop    %esi
f0101adf:	5f                   	pop    %edi
f0101ae0:	5d                   	pop    %ebp
f0101ae1:	c3                   	ret    
f0101ae2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ae8:	31 ff                	xor    %edi,%edi
f0101aea:	31 db                	xor    %ebx,%ebx
f0101aec:	89 d8                	mov    %ebx,%eax
f0101aee:	89 fa                	mov    %edi,%edx
f0101af0:	83 c4 1c             	add    $0x1c,%esp
f0101af3:	5b                   	pop    %ebx
f0101af4:	5e                   	pop    %esi
f0101af5:	5f                   	pop    %edi
f0101af6:	5d                   	pop    %ebp
f0101af7:	c3                   	ret    
f0101af8:	90                   	nop
f0101af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b00:	89 d8                	mov    %ebx,%eax
f0101b02:	f7 f7                	div    %edi
f0101b04:	31 ff                	xor    %edi,%edi
f0101b06:	89 c3                	mov    %eax,%ebx
f0101b08:	89 d8                	mov    %ebx,%eax
f0101b0a:	89 fa                	mov    %edi,%edx
f0101b0c:	83 c4 1c             	add    $0x1c,%esp
f0101b0f:	5b                   	pop    %ebx
f0101b10:	5e                   	pop    %esi
f0101b11:	5f                   	pop    %edi
f0101b12:	5d                   	pop    %ebp
f0101b13:	c3                   	ret    
f0101b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b18:	39 ce                	cmp    %ecx,%esi
f0101b1a:	72 0c                	jb     f0101b28 <__udivdi3+0x118>
f0101b1c:	31 db                	xor    %ebx,%ebx
f0101b1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101b22:	0f 87 34 ff ff ff    	ja     f0101a5c <__udivdi3+0x4c>
f0101b28:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101b2d:	e9 2a ff ff ff       	jmp    f0101a5c <__udivdi3+0x4c>
f0101b32:	66 90                	xchg   %ax,%ax
f0101b34:	66 90                	xchg   %ax,%ax
f0101b36:	66 90                	xchg   %ax,%ax
f0101b38:	66 90                	xchg   %ax,%ax
f0101b3a:	66 90                	xchg   %ax,%ax
f0101b3c:	66 90                	xchg   %ax,%ax
f0101b3e:	66 90                	xchg   %ax,%ax

f0101b40 <__umoddi3>:
f0101b40:	55                   	push   %ebp
f0101b41:	57                   	push   %edi
f0101b42:	56                   	push   %esi
f0101b43:	53                   	push   %ebx
f0101b44:	83 ec 1c             	sub    $0x1c,%esp
f0101b47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101b4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101b4f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b57:	85 d2                	test   %edx,%edx
f0101b59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101b5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b61:	89 f3                	mov    %esi,%ebx
f0101b63:	89 3c 24             	mov    %edi,(%esp)
f0101b66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b6a:	75 1c                	jne    f0101b88 <__umoddi3+0x48>
f0101b6c:	39 f7                	cmp    %esi,%edi
f0101b6e:	76 50                	jbe    f0101bc0 <__umoddi3+0x80>
f0101b70:	89 c8                	mov    %ecx,%eax
f0101b72:	89 f2                	mov    %esi,%edx
f0101b74:	f7 f7                	div    %edi
f0101b76:	89 d0                	mov    %edx,%eax
f0101b78:	31 d2                	xor    %edx,%edx
f0101b7a:	83 c4 1c             	add    $0x1c,%esp
f0101b7d:	5b                   	pop    %ebx
f0101b7e:	5e                   	pop    %esi
f0101b7f:	5f                   	pop    %edi
f0101b80:	5d                   	pop    %ebp
f0101b81:	c3                   	ret    
f0101b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b88:	39 f2                	cmp    %esi,%edx
f0101b8a:	89 d0                	mov    %edx,%eax
f0101b8c:	77 52                	ja     f0101be0 <__umoddi3+0xa0>
f0101b8e:	0f bd ea             	bsr    %edx,%ebp
f0101b91:	83 f5 1f             	xor    $0x1f,%ebp
f0101b94:	75 5a                	jne    f0101bf0 <__umoddi3+0xb0>
f0101b96:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101b9a:	0f 82 e0 00 00 00    	jb     f0101c80 <__umoddi3+0x140>
f0101ba0:	39 0c 24             	cmp    %ecx,(%esp)
f0101ba3:	0f 86 d7 00 00 00    	jbe    f0101c80 <__umoddi3+0x140>
f0101ba9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101bad:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bb1:	83 c4 1c             	add    $0x1c,%esp
f0101bb4:	5b                   	pop    %ebx
f0101bb5:	5e                   	pop    %esi
f0101bb6:	5f                   	pop    %edi
f0101bb7:	5d                   	pop    %ebp
f0101bb8:	c3                   	ret    
f0101bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bc0:	85 ff                	test   %edi,%edi
f0101bc2:	89 fd                	mov    %edi,%ebp
f0101bc4:	75 0b                	jne    f0101bd1 <__umoddi3+0x91>
f0101bc6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bcb:	31 d2                	xor    %edx,%edx
f0101bcd:	f7 f7                	div    %edi
f0101bcf:	89 c5                	mov    %eax,%ebp
f0101bd1:	89 f0                	mov    %esi,%eax
f0101bd3:	31 d2                	xor    %edx,%edx
f0101bd5:	f7 f5                	div    %ebp
f0101bd7:	89 c8                	mov    %ecx,%eax
f0101bd9:	f7 f5                	div    %ebp
f0101bdb:	89 d0                	mov    %edx,%eax
f0101bdd:	eb 99                	jmp    f0101b78 <__umoddi3+0x38>
f0101bdf:	90                   	nop
f0101be0:	89 c8                	mov    %ecx,%eax
f0101be2:	89 f2                	mov    %esi,%edx
f0101be4:	83 c4 1c             	add    $0x1c,%esp
f0101be7:	5b                   	pop    %ebx
f0101be8:	5e                   	pop    %esi
f0101be9:	5f                   	pop    %edi
f0101bea:	5d                   	pop    %ebp
f0101beb:	c3                   	ret    
f0101bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bf0:	8b 34 24             	mov    (%esp),%esi
f0101bf3:	bf 20 00 00 00       	mov    $0x20,%edi
f0101bf8:	89 e9                	mov    %ebp,%ecx
f0101bfa:	29 ef                	sub    %ebp,%edi
f0101bfc:	d3 e0                	shl    %cl,%eax
f0101bfe:	89 f9                	mov    %edi,%ecx
f0101c00:	89 f2                	mov    %esi,%edx
f0101c02:	d3 ea                	shr    %cl,%edx
f0101c04:	89 e9                	mov    %ebp,%ecx
f0101c06:	09 c2                	or     %eax,%edx
f0101c08:	89 d8                	mov    %ebx,%eax
f0101c0a:	89 14 24             	mov    %edx,(%esp)
f0101c0d:	89 f2                	mov    %esi,%edx
f0101c0f:	d3 e2                	shl    %cl,%edx
f0101c11:	89 f9                	mov    %edi,%ecx
f0101c13:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101c17:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101c1b:	d3 e8                	shr    %cl,%eax
f0101c1d:	89 e9                	mov    %ebp,%ecx
f0101c1f:	89 c6                	mov    %eax,%esi
f0101c21:	d3 e3                	shl    %cl,%ebx
f0101c23:	89 f9                	mov    %edi,%ecx
f0101c25:	89 d0                	mov    %edx,%eax
f0101c27:	d3 e8                	shr    %cl,%eax
f0101c29:	89 e9                	mov    %ebp,%ecx
f0101c2b:	09 d8                	or     %ebx,%eax
f0101c2d:	89 d3                	mov    %edx,%ebx
f0101c2f:	89 f2                	mov    %esi,%edx
f0101c31:	f7 34 24             	divl   (%esp)
f0101c34:	89 d6                	mov    %edx,%esi
f0101c36:	d3 e3                	shl    %cl,%ebx
f0101c38:	f7 64 24 04          	mull   0x4(%esp)
f0101c3c:	39 d6                	cmp    %edx,%esi
f0101c3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101c42:	89 d1                	mov    %edx,%ecx
f0101c44:	89 c3                	mov    %eax,%ebx
f0101c46:	72 08                	jb     f0101c50 <__umoddi3+0x110>
f0101c48:	75 11                	jne    f0101c5b <__umoddi3+0x11b>
f0101c4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101c4e:	73 0b                	jae    f0101c5b <__umoddi3+0x11b>
f0101c50:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101c54:	1b 14 24             	sbb    (%esp),%edx
f0101c57:	89 d1                	mov    %edx,%ecx
f0101c59:	89 c3                	mov    %eax,%ebx
f0101c5b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101c5f:	29 da                	sub    %ebx,%edx
f0101c61:	19 ce                	sbb    %ecx,%esi
f0101c63:	89 f9                	mov    %edi,%ecx
f0101c65:	89 f0                	mov    %esi,%eax
f0101c67:	d3 e0                	shl    %cl,%eax
f0101c69:	89 e9                	mov    %ebp,%ecx
f0101c6b:	d3 ea                	shr    %cl,%edx
f0101c6d:	89 e9                	mov    %ebp,%ecx
f0101c6f:	d3 ee                	shr    %cl,%esi
f0101c71:	09 d0                	or     %edx,%eax
f0101c73:	89 f2                	mov    %esi,%edx
f0101c75:	83 c4 1c             	add    $0x1c,%esp
f0101c78:	5b                   	pop    %ebx
f0101c79:	5e                   	pop    %esi
f0101c7a:	5f                   	pop    %edi
f0101c7b:	5d                   	pop    %ebp
f0101c7c:	c3                   	ret    
f0101c7d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c80:	29 f9                	sub    %edi,%ecx
f0101c82:	19 d6                	sbb    %edx,%esi
f0101c84:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101c8c:	e9 18 ff ff ff       	jmp    f0101ba9 <__umoddi3+0x69>
