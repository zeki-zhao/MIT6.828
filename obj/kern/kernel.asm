
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

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
f0100046:	b8 40 29 11 f0       	mov    $0xf0112940,%eax
f010004b:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 23 11 f0       	push   $0xf0112300
f0100058:	e8 8f 14 00 00       	call   f01014ec <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 19 10 f0       	push   $0xf0101980
f010006f:	e8 8f 09 00 00       	call   f0100a03 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 14 08 00 00       	call   f010088d <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 97 06 00 00       	call   f010071d <monitor>
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
f0100093:	83 3d 44 29 11 f0 00 	cmpl   $0x0,0xf0112944
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 44 29 11 f0    	mov    %esi,0xf0112944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 9b 19 10 f0       	push   $0xf010199b
f01000b5:	e8 49 09 00 00       	call   f0100a03 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 19 09 00 00       	call   f01009dd <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 d7 19 10 f0 	movl   $0xf01019d7,(%esp)
f01000cb:	e8 33 09 00 00       	call   f0100a03 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 40 06 00 00       	call   f010071d <monitor>
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
f01000f2:	68 b3 19 10 f0       	push   $0xf01019b3
f01000f7:	e8 07 09 00 00       	call   f0100a03 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 d5 08 00 00       	call   f01009dd <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 d7 19 10 f0 	movl   $0xf01019d7,(%esp)
f010010f:	e8 ef 08 00 00       	call   f0100a03 <cprintf>
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

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
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
f010014a:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f0100159:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
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
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f0100211:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100217:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 00 1a 10 f0 	mov    -0xfefe600(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 cd 19 10 f0       	push   $0xf01019cd
f010026d:	e8 91 07 00 00       	call   f0100a03 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 18 11 00 00       	call   f0101539 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f01004c3:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f01004d4:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 d9 19 10 f0       	push   $0xf01019d9
f01005f0:	e8 0e 04 00 00       	call   f0100a03 <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 20 1c 10 f0       	push   $0xf0101c20
f0100636:	68 3e 1c 10 f0       	push   $0xf0101c3e
f010063b:	68 43 1c 10 f0       	push   $0xf0101c43
f0100640:	e8 be 03 00 00       	call   f0100a03 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 ac 1c 10 f0       	push   $0xf0101cac
f010064d:	68 4c 1c 10 f0       	push   $0xf0101c4c
f0100652:	68 43 1c 10 f0       	push   $0xf0101c43
f0100657:	e8 a7 03 00 00       	call   f0100a03 <cprintf>
	return 0;
}
f010065c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    

f0100663 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100669:	68 55 1c 10 f0       	push   $0xf0101c55
f010066e:	e8 90 03 00 00       	call   f0100a03 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100673:	83 c4 08             	add    $0x8,%esp
f0100676:	68 0c 00 10 00       	push   $0x10000c
f010067b:	68 d4 1c 10 f0       	push   $0xf0101cd4
f0100680:	e8 7e 03 00 00       	call   f0100a03 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100685:	83 c4 0c             	add    $0xc,%esp
f0100688:	68 0c 00 10 00       	push   $0x10000c
f010068d:	68 0c 00 10 f0       	push   $0xf010000c
f0100692:	68 fc 1c 10 f0       	push   $0xf0101cfc
f0100697:	e8 67 03 00 00       	call   f0100a03 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 71 19 10 00       	push   $0x101971
f01006a4:	68 71 19 10 f0       	push   $0xf0101971
f01006a9:	68 20 1d 10 f0       	push   $0xf0101d20
f01006ae:	e8 50 03 00 00       	call   f0100a03 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 00 23 11 00       	push   $0x112300
f01006bb:	68 00 23 11 f0       	push   $0xf0112300
f01006c0:	68 44 1d 10 f0       	push   $0xf0101d44
f01006c5:	e8 39 03 00 00       	call   f0100a03 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 40 29 11 00       	push   $0x112940
f01006d2:	68 40 29 11 f0       	push   $0xf0112940
f01006d7:	68 68 1d 10 f0       	push   $0xf0101d68
f01006dc:	e8 22 03 00 00       	call   f0100a03 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e1:	b8 3f 2d 11 f0       	mov    $0xf0112d3f,%eax
f01006e6:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006eb:	83 c4 08             	add    $0x8,%esp
f01006ee:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	0f 48 c2             	cmovs  %edx,%eax
f01006fe:	c1 f8 0a             	sar    $0xa,%eax
f0100701:	50                   	push   %eax
f0100702:	68 8c 1d 10 f0       	push   $0xf0101d8c
f0100707:	e8 f7 02 00 00       	call   f0100a03 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    

f0100713 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100713:	55                   	push   %ebp
f0100714:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100716:	b8 00 00 00 00       	mov    $0x0,%eax
f010071b:	5d                   	pop    %ebp
f010071c:	c3                   	ret    

f010071d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010071d:	55                   	push   %ebp
f010071e:	89 e5                	mov    %esp,%ebp
f0100720:	57                   	push   %edi
f0100721:	56                   	push   %esi
f0100722:	53                   	push   %ebx
f0100723:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100726:	68 b8 1d 10 f0       	push   $0xf0101db8
f010072b:	e8 d3 02 00 00       	call   f0100a03 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100730:	c7 04 24 dc 1d 10 f0 	movl   $0xf0101ddc,(%esp)
f0100737:	e8 c7 02 00 00       	call   f0100a03 <cprintf>
f010073c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010073f:	83 ec 0c             	sub    $0xc,%esp
f0100742:	68 6e 1c 10 f0       	push   $0xf0101c6e
f0100747:	e8 49 0b 00 00       	call   f0101295 <readline>
f010074c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010074e:	83 c4 10             	add    $0x10,%esp
f0100751:	85 c0                	test   %eax,%eax
f0100753:	74 ea                	je     f010073f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100755:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010075c:	be 00 00 00 00       	mov    $0x0,%esi
f0100761:	eb 0a                	jmp    f010076d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100763:	c6 03 00             	movb   $0x0,(%ebx)
f0100766:	89 f7                	mov    %esi,%edi
f0100768:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010076b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010076d:	0f b6 03             	movzbl (%ebx),%eax
f0100770:	84 c0                	test   %al,%al
f0100772:	74 63                	je     f01007d7 <monitor+0xba>
f0100774:	83 ec 08             	sub    $0x8,%esp
f0100777:	0f be c0             	movsbl %al,%eax
f010077a:	50                   	push   %eax
f010077b:	68 72 1c 10 f0       	push   $0xf0101c72
f0100780:	e8 2a 0d 00 00       	call   f01014af <strchr>
f0100785:	83 c4 10             	add    $0x10,%esp
f0100788:	85 c0                	test   %eax,%eax
f010078a:	75 d7                	jne    f0100763 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010078c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010078f:	74 46                	je     f01007d7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100791:	83 fe 0f             	cmp    $0xf,%esi
f0100794:	75 14                	jne    f01007aa <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100796:	83 ec 08             	sub    $0x8,%esp
f0100799:	6a 10                	push   $0x10
f010079b:	68 77 1c 10 f0       	push   $0xf0101c77
f01007a0:	e8 5e 02 00 00       	call   f0100a03 <cprintf>
f01007a5:	83 c4 10             	add    $0x10,%esp
f01007a8:	eb 95                	jmp    f010073f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01007aa:	8d 7e 01             	lea    0x1(%esi),%edi
f01007ad:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007b1:	eb 03                	jmp    f01007b6 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007b3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007b6:	0f b6 03             	movzbl (%ebx),%eax
f01007b9:	84 c0                	test   %al,%al
f01007bb:	74 ae                	je     f010076b <monitor+0x4e>
f01007bd:	83 ec 08             	sub    $0x8,%esp
f01007c0:	0f be c0             	movsbl %al,%eax
f01007c3:	50                   	push   %eax
f01007c4:	68 72 1c 10 f0       	push   $0xf0101c72
f01007c9:	e8 e1 0c 00 00       	call   f01014af <strchr>
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	85 c0                	test   %eax,%eax
f01007d3:	74 de                	je     f01007b3 <monitor+0x96>
f01007d5:	eb 94                	jmp    f010076b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01007d7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01007de:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01007df:	85 f6                	test   %esi,%esi
f01007e1:	0f 84 58 ff ff ff    	je     f010073f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007e7:	83 ec 08             	sub    $0x8,%esp
f01007ea:	68 3e 1c 10 f0       	push   $0xf0101c3e
f01007ef:	ff 75 a8             	pushl  -0x58(%ebp)
f01007f2:	e8 5a 0c 00 00       	call   f0101451 <strcmp>
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	85 c0                	test   %eax,%eax
f01007fc:	74 1e                	je     f010081c <monitor+0xff>
f01007fe:	83 ec 08             	sub    $0x8,%esp
f0100801:	68 4c 1c 10 f0       	push   $0xf0101c4c
f0100806:	ff 75 a8             	pushl  -0x58(%ebp)
f0100809:	e8 43 0c 00 00       	call   f0101451 <strcmp>
f010080e:	83 c4 10             	add    $0x10,%esp
f0100811:	85 c0                	test   %eax,%eax
f0100813:	75 2f                	jne    f0100844 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100815:	b8 01 00 00 00       	mov    $0x1,%eax
f010081a:	eb 05                	jmp    f0100821 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f010081c:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100821:	83 ec 04             	sub    $0x4,%esp
f0100824:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100827:	01 d0                	add    %edx,%eax
f0100829:	ff 75 08             	pushl  0x8(%ebp)
f010082c:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010082f:	51                   	push   %ecx
f0100830:	56                   	push   %esi
f0100831:	ff 14 85 0c 1e 10 f0 	call   *-0xfefe1f4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100838:	83 c4 10             	add    $0x10,%esp
f010083b:	85 c0                	test   %eax,%eax
f010083d:	78 1d                	js     f010085c <monitor+0x13f>
f010083f:	e9 fb fe ff ff       	jmp    f010073f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100844:	83 ec 08             	sub    $0x8,%esp
f0100847:	ff 75 a8             	pushl  -0x58(%ebp)
f010084a:	68 94 1c 10 f0       	push   $0xf0101c94
f010084f:	e8 af 01 00 00       	call   f0100a03 <cprintf>
f0100854:	83 c4 10             	add    $0x10,%esp
f0100857:	e9 e3 fe ff ff       	jmp    f010073f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010085c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010085f:	5b                   	pop    %ebx
f0100860:	5e                   	pop    %esi
f0100861:	5f                   	pop    %edi
f0100862:	5d                   	pop    %ebp
f0100863:	c3                   	ret    

f0100864 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100864:	55                   	push   %ebp
f0100865:	89 e5                	mov    %esp,%ebp
f0100867:	56                   	push   %esi
f0100868:	53                   	push   %ebx
f0100869:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010086b:	83 ec 0c             	sub    $0xc,%esp
f010086e:	50                   	push   %eax
f010086f:	e8 28 01 00 00       	call   f010099c <mc146818_read>
f0100874:	89 c6                	mov    %eax,%esi
f0100876:	83 c3 01             	add    $0x1,%ebx
f0100879:	89 1c 24             	mov    %ebx,(%esp)
f010087c:	e8 1b 01 00 00       	call   f010099c <mc146818_read>
f0100881:	c1 e0 08             	shl    $0x8,%eax
f0100884:	09 f0                	or     %esi,%eax
}
f0100886:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5d                   	pop    %ebp
f010088c:	c3                   	ret    

f010088d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	56                   	push   %esi
f0100891:	53                   	push   %ebx
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100892:	b8 15 00 00 00       	mov    $0x15,%eax
f0100897:	e8 c8 ff ff ff       	call   f0100864 <nvram_read>
f010089c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010089e:	b8 17 00 00 00       	mov    $0x17,%eax
f01008a3:	e8 bc ff ff ff       	call   f0100864 <nvram_read>
f01008a8:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01008aa:	b8 34 00 00 00       	mov    $0x34,%eax
f01008af:	e8 b0 ff ff ff       	call   f0100864 <nvram_read>
f01008b4:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01008b7:	85 c0                	test   %eax,%eax
f01008b9:	74 07                	je     f01008c2 <mem_init+0x35>
		totalmem = 16 * 1024 + ext16mem;
f01008bb:	05 00 40 00 00       	add    $0x4000,%eax
f01008c0:	eb 0b                	jmp    f01008cd <mem_init+0x40>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01008c2:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01008c8:	85 f6                	test   %esi,%esi
f01008ca:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01008cd:	89 c2                	mov    %eax,%edx
f01008cf:	c1 ea 02             	shr    $0x2,%edx
f01008d2:	89 15 48 29 11 f0    	mov    %edx,0xf0112948
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01008d8:	89 c2                	mov    %eax,%edx
f01008da:	29 da                	sub    %ebx,%edx
f01008dc:	52                   	push   %edx
f01008dd:	53                   	push   %ebx
f01008de:	50                   	push   %eax
f01008df:	68 1c 1e 10 f0       	push   $0xf0101e1c
f01008e4:	e8 1a 01 00 00       	call   f0100a03 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f01008e9:	83 c4 0c             	add    $0xc,%esp
f01008ec:	68 58 1e 10 f0       	push   $0xf0101e58
f01008f1:	68 80 00 00 00       	push   $0x80
f01008f6:	68 84 1e 10 f0       	push   $0xf0101e84
f01008fb:	e8 8b f7 ff ff       	call   f010008b <_panic>

f0100900 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100900:	55                   	push   %ebp
f0100901:	89 e5                	mov    %esp,%ebp
f0100903:	53                   	push   %ebx
f0100904:	8b 1d 38 25 11 f0    	mov    0xf0112538,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010090a:	ba 00 00 00 00       	mov    $0x0,%edx
f010090f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100914:	eb 27                	jmp    f010093d <page_init+0x3d>
f0100916:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f010091d:	89 d1                	mov    %edx,%ecx
f010091f:	03 0d 50 29 11 f0    	add    0xf0112950,%ecx
f0100925:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010092b:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010092d:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100930:	89 d3                	mov    %edx,%ebx
f0100932:	03 1d 50 29 11 f0    	add    0xf0112950,%ebx
f0100938:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010093d:	3b 05 48 29 11 f0    	cmp    0xf0112948,%eax
f0100943:	72 d1                	jb     f0100916 <page_init+0x16>
f0100945:	84 d2                	test   %dl,%dl
f0100947:	74 06                	je     f010094f <page_init+0x4f>
f0100949:	89 1d 38 25 11 f0    	mov    %ebx,0xf0112538
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010094f:	5b                   	pop    %ebx
f0100950:	5d                   	pop    %ebp
f0100951:	c3                   	ret    

f0100952 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100952:	55                   	push   %ebp
f0100953:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100955:	b8 00 00 00 00       	mov    $0x0,%eax
f010095a:	5d                   	pop    %ebp
f010095b:	c3                   	ret    

f010095c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010095c:	55                   	push   %ebp
f010095d:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f010095f:	5d                   	pop    %ebp
f0100960:	c3                   	ret    

f0100961 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100961:	55                   	push   %ebp
f0100962:	89 e5                	mov    %esp,%ebp
f0100964:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100967:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f010096c:	5d                   	pop    %ebp
f010096d:	c3                   	ret    

f010096e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010096e:	55                   	push   %ebp
f010096f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100971:	b8 00 00 00 00       	mov    $0x0,%eax
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f010097b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100980:	5d                   	pop    %ebp
f0100981:	c3                   	ret    

f0100982 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100982:	55                   	push   %ebp
f0100983:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100985:	b8 00 00 00 00       	mov    $0x0,%eax
f010098a:	5d                   	pop    %ebp
f010098b:	c3                   	ret    

f010098c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010098c:	55                   	push   %ebp
f010098d:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010098f:	5d                   	pop    %ebp
f0100990:	c3                   	ret    

f0100991 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100991:	55                   	push   %ebp
f0100992:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100994:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100997:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010099a:	5d                   	pop    %ebp
f010099b:	c3                   	ret    

f010099c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010099c:	55                   	push   %ebp
f010099d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010099f:	ba 70 00 00 00       	mov    $0x70,%edx
f01009a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01009a7:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01009a8:	ba 71 00 00 00       	mov    $0x71,%edx
f01009ad:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01009ae:	0f b6 c0             	movzbl %al,%eax
}
f01009b1:	5d                   	pop    %ebp
f01009b2:	c3                   	ret    

f01009b3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01009b3:	55                   	push   %ebp
f01009b4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01009b6:	ba 70 00 00 00       	mov    $0x70,%edx
f01009bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01009be:	ee                   	out    %al,(%dx)
f01009bf:	ba 71 00 00 00       	mov    $0x71,%edx
f01009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009c7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01009c8:	5d                   	pop    %ebp
f01009c9:	c3                   	ret    

f01009ca <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009ca:	55                   	push   %ebp
f01009cb:	89 e5                	mov    %esp,%ebp
f01009cd:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01009d0:	ff 75 08             	pushl  0x8(%ebp)
f01009d3:	e8 28 fc ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f01009d8:	83 c4 10             	add    $0x10,%esp
f01009db:	c9                   	leave  
f01009dc:	c3                   	ret    

f01009dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009dd:	55                   	push   %ebp
f01009de:	89 e5                	mov    %esp,%ebp
f01009e0:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009ea:	ff 75 0c             	pushl  0xc(%ebp)
f01009ed:	ff 75 08             	pushl  0x8(%ebp)
f01009f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009f3:	50                   	push   %eax
f01009f4:	68 ca 09 10 f0       	push   $0xf01009ca
f01009f9:	e8 c9 03 00 00       	call   f0100dc7 <vprintfmt>
	return cnt;
}
f01009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a01:	c9                   	leave  
f0100a02:	c3                   	ret    

f0100a03 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a03:	55                   	push   %ebp
f0100a04:	89 e5                	mov    %esp,%ebp
f0100a06:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a09:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a0c:	50                   	push   %eax
f0100a0d:	ff 75 08             	pushl  0x8(%ebp)
f0100a10:	e8 c8 ff ff ff       	call   f01009dd <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a15:	c9                   	leave  
f0100a16:	c3                   	ret    

f0100a17 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a17:	55                   	push   %ebp
f0100a18:	89 e5                	mov    %esp,%ebp
f0100a1a:	57                   	push   %edi
f0100a1b:	56                   	push   %esi
f0100a1c:	53                   	push   %ebx
f0100a1d:	83 ec 14             	sub    $0x14,%esp
f0100a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a26:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a29:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a2c:	8b 1a                	mov    (%edx),%ebx
f0100a2e:	8b 01                	mov    (%ecx),%eax
f0100a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a33:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a3a:	eb 7f                	jmp    f0100abb <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a3f:	01 d8                	add    %ebx,%eax
f0100a41:	89 c6                	mov    %eax,%esi
f0100a43:	c1 ee 1f             	shr    $0x1f,%esi
f0100a46:	01 c6                	add    %eax,%esi
f0100a48:	d1 fe                	sar    %esi
f0100a4a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a4d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a50:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a53:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a55:	eb 03                	jmp    f0100a5a <stab_binsearch+0x43>
			m--;
f0100a57:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a5a:	39 c3                	cmp    %eax,%ebx
f0100a5c:	7f 0d                	jg     f0100a6b <stab_binsearch+0x54>
f0100a5e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a62:	83 ea 0c             	sub    $0xc,%edx
f0100a65:	39 f9                	cmp    %edi,%ecx
f0100a67:	75 ee                	jne    f0100a57 <stab_binsearch+0x40>
f0100a69:	eb 05                	jmp    f0100a70 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a6b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a6e:	eb 4b                	jmp    f0100abb <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a70:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a73:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a76:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a7a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a7d:	76 11                	jbe    f0100a90 <stab_binsearch+0x79>
			*region_left = m;
f0100a7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a82:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a84:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a87:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a8e:	eb 2b                	jmp    f0100abb <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a90:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a93:	73 14                	jae    f0100aa9 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a95:	83 e8 01             	sub    $0x1,%eax
f0100a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a9b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a9e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100aa0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100aa7:	eb 12                	jmp    f0100abb <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100aa9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aac:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100aae:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100ab2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ab4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100abb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100abe:	0f 8e 78 ff ff ff    	jle    f0100a3c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100ac4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ac8:	75 0f                	jne    f0100ad9 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100aca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100acd:	8b 00                	mov    (%eax),%eax
f0100acf:	83 e8 01             	sub    $0x1,%eax
f0100ad2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ad5:	89 06                	mov    %eax,(%esi)
f0100ad7:	eb 2c                	jmp    f0100b05 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100adc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ade:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ae1:	8b 0e                	mov    (%esi),%ecx
f0100ae3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ae6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ae9:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100aec:	eb 03                	jmp    f0100af1 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100aee:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100af1:	39 c8                	cmp    %ecx,%eax
f0100af3:	7e 0b                	jle    f0100b00 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100af5:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100af9:	83 ea 0c             	sub    $0xc,%edx
f0100afc:	39 df                	cmp    %ebx,%edi
f0100afe:	75 ee                	jne    f0100aee <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b00:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b03:	89 06                	mov    %eax,(%esi)
	}
}
f0100b05:	83 c4 14             	add    $0x14,%esp
f0100b08:	5b                   	pop    %ebx
f0100b09:	5e                   	pop    %esi
f0100b0a:	5f                   	pop    %edi
f0100b0b:	5d                   	pop    %ebp
f0100b0c:	c3                   	ret    

f0100b0d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b0d:	55                   	push   %ebp
f0100b0e:	89 e5                	mov    %esp,%ebp
f0100b10:	57                   	push   %edi
f0100b11:	56                   	push   %esi
f0100b12:	53                   	push   %ebx
f0100b13:	83 ec 1c             	sub    $0x1c,%esp
f0100b16:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b19:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b1c:	c7 06 90 1e 10 f0    	movl   $0xf0101e90,(%esi)
	info->eip_line = 0;
f0100b22:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100b29:	c7 46 08 90 1e 10 f0 	movl   $0xf0101e90,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100b30:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100b37:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100b3a:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b41:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100b47:	76 11                	jbe    f0100b5a <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b49:	b8 47 7c 10 f0       	mov    $0xf0107c47,%eax
f0100b4e:	3d dd 60 10 f0       	cmp    $0xf01060dd,%eax
f0100b53:	77 19                	ja     f0100b6e <debuginfo_eip+0x61>
f0100b55:	e9 62 01 00 00       	jmp    f0100cbc <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b5a:	83 ec 04             	sub    $0x4,%esp
f0100b5d:	68 9a 1e 10 f0       	push   $0xf0101e9a
f0100b62:	6a 7f                	push   $0x7f
f0100b64:	68 a7 1e 10 f0       	push   $0xf0101ea7
f0100b69:	e8 1d f5 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b6e:	80 3d 46 7c 10 f0 00 	cmpb   $0x0,0xf0107c46
f0100b75:	0f 85 48 01 00 00    	jne    f0100cc3 <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b82:	b8 dc 60 10 f0       	mov    $0xf01060dc,%eax
f0100b87:	2d c8 20 10 f0       	sub    $0xf01020c8,%eax
f0100b8c:	c1 f8 02             	sar    $0x2,%eax
f0100b8f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b95:	83 e8 01             	sub    $0x1,%eax
f0100b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b9b:	83 ec 08             	sub    $0x8,%esp
f0100b9e:	57                   	push   %edi
f0100b9f:	6a 64                	push   $0x64
f0100ba1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ba4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ba7:	b8 c8 20 10 f0       	mov    $0xf01020c8,%eax
f0100bac:	e8 66 fe ff ff       	call   f0100a17 <stab_binsearch>
	if (lfile == 0)
f0100bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bb4:	83 c4 10             	add    $0x10,%esp
f0100bb7:	85 c0                	test   %eax,%eax
f0100bb9:	0f 84 0b 01 00 00    	je     f0100cca <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bbf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bc8:	83 ec 08             	sub    $0x8,%esp
f0100bcb:	57                   	push   %edi
f0100bcc:	6a 24                	push   $0x24
f0100bce:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bd1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bd4:	b8 c8 20 10 f0       	mov    $0xf01020c8,%eax
f0100bd9:	e8 39 fe ff ff       	call   f0100a17 <stab_binsearch>

	if (lfun <= rfun) {
f0100bde:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100be1:	83 c4 10             	add    $0x10,%esp
f0100be4:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100be7:	7f 31                	jg     f0100c1a <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100be9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bec:	c1 e0 02             	shl    $0x2,%eax
f0100bef:	8d 90 c8 20 10 f0    	lea    -0xfefdf38(%eax),%edx
f0100bf5:	8b 88 c8 20 10 f0    	mov    -0xfefdf38(%eax),%ecx
f0100bfb:	b8 47 7c 10 f0       	mov    $0xf0107c47,%eax
f0100c00:	2d dd 60 10 f0       	sub    $0xf01060dd,%eax
f0100c05:	39 c1                	cmp    %eax,%ecx
f0100c07:	73 09                	jae    f0100c12 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c09:	81 c1 dd 60 10 f0    	add    $0xf01060dd,%ecx
f0100c0f:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c12:	8b 42 08             	mov    0x8(%edx),%eax
f0100c15:	89 46 10             	mov    %eax,0x10(%esi)
f0100c18:	eb 06                	jmp    f0100c20 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c1a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100c1d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c20:	83 ec 08             	sub    $0x8,%esp
f0100c23:	6a 3a                	push   $0x3a
f0100c25:	ff 76 08             	pushl  0x8(%esi)
f0100c28:	e8 a3 08 00 00       	call   f01014d0 <strfind>
f0100c2d:	2b 46 08             	sub    0x8(%esi),%eax
f0100c30:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c36:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c39:	8d 04 85 c8 20 10 f0 	lea    -0xfefdf38(,%eax,4),%eax
f0100c40:	83 c4 10             	add    $0x10,%esp
f0100c43:	eb 06                	jmp    f0100c4b <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100c45:	83 eb 01             	sub    $0x1,%ebx
f0100c48:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c4b:	39 fb                	cmp    %edi,%ebx
f0100c4d:	7c 34                	jl     f0100c83 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0100c4f:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100c53:	80 fa 84             	cmp    $0x84,%dl
f0100c56:	74 0b                	je     f0100c63 <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c58:	80 fa 64             	cmp    $0x64,%dl
f0100c5b:	75 e8                	jne    f0100c45 <debuginfo_eip+0x138>
f0100c5d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c61:	74 e2                	je     f0100c45 <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c63:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c66:	8b 14 85 c8 20 10 f0 	mov    -0xfefdf38(,%eax,4),%edx
f0100c6d:	b8 47 7c 10 f0       	mov    $0xf0107c47,%eax
f0100c72:	2d dd 60 10 f0       	sub    $0xf01060dd,%eax
f0100c77:	39 c2                	cmp    %eax,%edx
f0100c79:	73 08                	jae    f0100c83 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c7b:	81 c2 dd 60 10 f0    	add    $0xf01060dd,%edx
f0100c81:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c83:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100c86:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c89:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c8e:	39 cb                	cmp    %ecx,%ebx
f0100c90:	7d 44                	jge    f0100cd6 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100c92:	8d 53 01             	lea    0x1(%ebx),%edx
f0100c95:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c98:	8d 04 85 c8 20 10 f0 	lea    -0xfefdf38(,%eax,4),%eax
f0100c9f:	eb 07                	jmp    f0100ca8 <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100ca1:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100ca5:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100ca8:	39 ca                	cmp    %ecx,%edx
f0100caa:	74 25                	je     f0100cd1 <debuginfo_eip+0x1c4>
f0100cac:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100caf:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100cb3:	74 ec                	je     f0100ca1 <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cba:	eb 1a                	jmp    f0100cd6 <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc1:	eb 13                	jmp    f0100cd6 <debuginfo_eip+0x1c9>
f0100cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc8:	eb 0c                	jmp    f0100cd6 <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ccf:	eb 05                	jmp    f0100cd6 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cd9:	5b                   	pop    %ebx
f0100cda:	5e                   	pop    %esi
f0100cdb:	5f                   	pop    %edi
f0100cdc:	5d                   	pop    %ebp
f0100cdd:	c3                   	ret    

f0100cde <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cde:	55                   	push   %ebp
f0100cdf:	89 e5                	mov    %esp,%ebp
f0100ce1:	57                   	push   %edi
f0100ce2:	56                   	push   %esi
f0100ce3:	53                   	push   %ebx
f0100ce4:	83 ec 1c             	sub    $0x1c,%esp
f0100ce7:	89 c7                	mov    %eax,%edi
f0100ce9:	89 d6                	mov    %edx,%esi
f0100ceb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cee:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cf1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cf4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d02:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d05:	39 d3                	cmp    %edx,%ebx
f0100d07:	72 05                	jb     f0100d0e <printnum+0x30>
f0100d09:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d0c:	77 45                	ja     f0100d53 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d0e:	83 ec 0c             	sub    $0xc,%esp
f0100d11:	ff 75 18             	pushl  0x18(%ebp)
f0100d14:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d17:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d1a:	53                   	push   %ebx
f0100d1b:	ff 75 10             	pushl  0x10(%ebp)
f0100d1e:	83 ec 08             	sub    $0x8,%esp
f0100d21:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d24:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d27:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d2a:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d2d:	e8 be 09 00 00       	call   f01016f0 <__udivdi3>
f0100d32:	83 c4 18             	add    $0x18,%esp
f0100d35:	52                   	push   %edx
f0100d36:	50                   	push   %eax
f0100d37:	89 f2                	mov    %esi,%edx
f0100d39:	89 f8                	mov    %edi,%eax
f0100d3b:	e8 9e ff ff ff       	call   f0100cde <printnum>
f0100d40:	83 c4 20             	add    $0x20,%esp
f0100d43:	eb 18                	jmp    f0100d5d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d45:	83 ec 08             	sub    $0x8,%esp
f0100d48:	56                   	push   %esi
f0100d49:	ff 75 18             	pushl  0x18(%ebp)
f0100d4c:	ff d7                	call   *%edi
f0100d4e:	83 c4 10             	add    $0x10,%esp
f0100d51:	eb 03                	jmp    f0100d56 <printnum+0x78>
f0100d53:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d56:	83 eb 01             	sub    $0x1,%ebx
f0100d59:	85 db                	test   %ebx,%ebx
f0100d5b:	7f e8                	jg     f0100d45 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d5d:	83 ec 08             	sub    $0x8,%esp
f0100d60:	56                   	push   %esi
f0100d61:	83 ec 04             	sub    $0x4,%esp
f0100d64:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d67:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d6a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d6d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d70:	e8 ab 0a 00 00       	call   f0101820 <__umoddi3>
f0100d75:	83 c4 14             	add    $0x14,%esp
f0100d78:	0f be 80 b5 1e 10 f0 	movsbl -0xfefe14b(%eax),%eax
f0100d7f:	50                   	push   %eax
f0100d80:	ff d7                	call   *%edi
}
f0100d82:	83 c4 10             	add    $0x10,%esp
f0100d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d88:	5b                   	pop    %ebx
f0100d89:	5e                   	pop    %esi
f0100d8a:	5f                   	pop    %edi
f0100d8b:	5d                   	pop    %ebp
f0100d8c:	c3                   	ret    

f0100d8d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d8d:	55                   	push   %ebp
f0100d8e:	89 e5                	mov    %esp,%ebp
f0100d90:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d93:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d97:	8b 10                	mov    (%eax),%edx
f0100d99:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d9c:	73 0a                	jae    f0100da8 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d9e:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100da1:	89 08                	mov    %ecx,(%eax)
f0100da3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da6:	88 02                	mov    %al,(%edx)
}
f0100da8:	5d                   	pop    %ebp
f0100da9:	c3                   	ret    

f0100daa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100daa:	55                   	push   %ebp
f0100dab:	89 e5                	mov    %esp,%ebp
f0100dad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100db0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100db3:	50                   	push   %eax
f0100db4:	ff 75 10             	pushl  0x10(%ebp)
f0100db7:	ff 75 0c             	pushl  0xc(%ebp)
f0100dba:	ff 75 08             	pushl  0x8(%ebp)
f0100dbd:	e8 05 00 00 00       	call   f0100dc7 <vprintfmt>
	va_end(ap);
}
f0100dc2:	83 c4 10             	add    $0x10,%esp
f0100dc5:	c9                   	leave  
f0100dc6:	c3                   	ret    

f0100dc7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dc7:	55                   	push   %ebp
f0100dc8:	89 e5                	mov    %esp,%ebp
f0100dca:	57                   	push   %edi
f0100dcb:	56                   	push   %esi
f0100dcc:	53                   	push   %ebx
f0100dcd:	83 ec 2c             	sub    $0x2c,%esp
f0100dd0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dd6:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dd9:	eb 12                	jmp    f0100ded <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100ddb:	85 c0                	test   %eax,%eax
f0100ddd:	0f 84 42 04 00 00    	je     f0101225 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0100de3:	83 ec 08             	sub    $0x8,%esp
f0100de6:	53                   	push   %ebx
f0100de7:	50                   	push   %eax
f0100de8:	ff d6                	call   *%esi
f0100dea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ded:	83 c7 01             	add    $0x1,%edi
f0100df0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100df4:	83 f8 25             	cmp    $0x25,%eax
f0100df7:	75 e2                	jne    f0100ddb <vprintfmt+0x14>
f0100df9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100dfd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e04:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e0b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e12:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e17:	eb 07                	jmp    f0100e20 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e19:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e1c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e20:	8d 47 01             	lea    0x1(%edi),%eax
f0100e23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e26:	0f b6 07             	movzbl (%edi),%eax
f0100e29:	0f b6 d0             	movzbl %al,%edx
f0100e2c:	83 e8 23             	sub    $0x23,%eax
f0100e2f:	3c 55                	cmp    $0x55,%al
f0100e31:	0f 87 d3 03 00 00    	ja     f010120a <vprintfmt+0x443>
f0100e37:	0f b6 c0             	movzbl %al,%eax
f0100e3a:	ff 24 85 44 1f 10 f0 	jmp    *-0xfefe0bc(,%eax,4)
f0100e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e44:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e48:	eb d6                	jmp    f0100e20 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e55:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e58:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100e5c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100e5f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100e62:	83 f9 09             	cmp    $0x9,%ecx
f0100e65:	77 3f                	ja     f0100ea6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e67:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e6a:	eb e9                	jmp    f0100e55 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e6f:	8b 00                	mov    (%eax),%eax
f0100e71:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e77:	8d 40 04             	lea    0x4(%eax),%eax
f0100e7a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e80:	eb 2a                	jmp    f0100eac <vprintfmt+0xe5>
f0100e82:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e85:	85 c0                	test   %eax,%eax
f0100e87:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e8c:	0f 49 d0             	cmovns %eax,%edx
f0100e8f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e95:	eb 89                	jmp    f0100e20 <vprintfmt+0x59>
f0100e97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e9a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100ea1:	e9 7a ff ff ff       	jmp    f0100e20 <vprintfmt+0x59>
f0100ea6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100ea9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100eac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100eb0:	0f 89 6a ff ff ff    	jns    f0100e20 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100eb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ebc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ec3:	e9 58 ff ff ff       	jmp    f0100e20 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ec8:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ece:	e9 4d ff ff ff       	jmp    f0100e20 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ed3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ed6:	8d 78 04             	lea    0x4(%eax),%edi
f0100ed9:	83 ec 08             	sub    $0x8,%esp
f0100edc:	53                   	push   %ebx
f0100edd:	ff 30                	pushl  (%eax)
f0100edf:	ff d6                	call   *%esi
			break;
f0100ee1:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ee4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100eea:	e9 fe fe ff ff       	jmp    f0100ded <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100eef:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef2:	8d 78 04             	lea    0x4(%eax),%edi
f0100ef5:	8b 00                	mov    (%eax),%eax
f0100ef7:	99                   	cltd   
f0100ef8:	31 d0                	xor    %edx,%eax
f0100efa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100efc:	83 f8 06             	cmp    $0x6,%eax
f0100eff:	7f 0b                	jg     f0100f0c <vprintfmt+0x145>
f0100f01:	8b 14 85 9c 20 10 f0 	mov    -0xfefdf64(,%eax,4),%edx
f0100f08:	85 d2                	test   %edx,%edx
f0100f0a:	75 1b                	jne    f0100f27 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0100f0c:	50                   	push   %eax
f0100f0d:	68 cd 1e 10 f0       	push   $0xf0101ecd
f0100f12:	53                   	push   %ebx
f0100f13:	56                   	push   %esi
f0100f14:	e8 91 fe ff ff       	call   f0100daa <printfmt>
f0100f19:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f1c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f22:	e9 c6 fe ff ff       	jmp    f0100ded <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f27:	52                   	push   %edx
f0100f28:	68 d6 1e 10 f0       	push   $0xf0101ed6
f0100f2d:	53                   	push   %ebx
f0100f2e:	56                   	push   %esi
f0100f2f:	e8 76 fe ff ff       	call   f0100daa <printfmt>
f0100f34:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f37:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f3d:	e9 ab fe ff ff       	jmp    f0100ded <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f42:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f45:	83 c0 04             	add    $0x4,%eax
f0100f48:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f4b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f4e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f50:	85 ff                	test   %edi,%edi
f0100f52:	b8 c6 1e 10 f0       	mov    $0xf0101ec6,%eax
f0100f57:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f5a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f5e:	0f 8e 94 00 00 00    	jle    f0100ff8 <vprintfmt+0x231>
f0100f64:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f68:	0f 84 98 00 00 00    	je     f0101006 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f6e:	83 ec 08             	sub    $0x8,%esp
f0100f71:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f74:	57                   	push   %edi
f0100f75:	e8 0c 04 00 00       	call   f0101386 <strnlen>
f0100f7a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f7d:	29 c1                	sub    %eax,%ecx
f0100f7f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f82:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f85:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f89:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f8c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f8f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f91:	eb 0f                	jmp    f0100fa2 <vprintfmt+0x1db>
					putch(padc, putdat);
f0100f93:	83 ec 08             	sub    $0x8,%esp
f0100f96:	53                   	push   %ebx
f0100f97:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f9a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f9c:	83 ef 01             	sub    $0x1,%edi
f0100f9f:	83 c4 10             	add    $0x10,%esp
f0100fa2:	85 ff                	test   %edi,%edi
f0100fa4:	7f ed                	jg     f0100f93 <vprintfmt+0x1cc>
f0100fa6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fa9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100fac:	85 c9                	test   %ecx,%ecx
f0100fae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb3:	0f 49 c1             	cmovns %ecx,%eax
f0100fb6:	29 c1                	sub    %eax,%ecx
f0100fb8:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fbb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fbe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fc1:	89 cb                	mov    %ecx,%ebx
f0100fc3:	eb 4d                	jmp    f0101012 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fc5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fc9:	74 1b                	je     f0100fe6 <vprintfmt+0x21f>
f0100fcb:	0f be c0             	movsbl %al,%eax
f0100fce:	83 e8 20             	sub    $0x20,%eax
f0100fd1:	83 f8 5e             	cmp    $0x5e,%eax
f0100fd4:	76 10                	jbe    f0100fe6 <vprintfmt+0x21f>
					putch('?', putdat);
f0100fd6:	83 ec 08             	sub    $0x8,%esp
f0100fd9:	ff 75 0c             	pushl  0xc(%ebp)
f0100fdc:	6a 3f                	push   $0x3f
f0100fde:	ff 55 08             	call   *0x8(%ebp)
f0100fe1:	83 c4 10             	add    $0x10,%esp
f0100fe4:	eb 0d                	jmp    f0100ff3 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0100fe6:	83 ec 08             	sub    $0x8,%esp
f0100fe9:	ff 75 0c             	pushl  0xc(%ebp)
f0100fec:	52                   	push   %edx
f0100fed:	ff 55 08             	call   *0x8(%ebp)
f0100ff0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ff3:	83 eb 01             	sub    $0x1,%ebx
f0100ff6:	eb 1a                	jmp    f0101012 <vprintfmt+0x24b>
f0100ff8:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ffb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ffe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101001:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101004:	eb 0c                	jmp    f0101012 <vprintfmt+0x24b>
f0101006:	89 75 08             	mov    %esi,0x8(%ebp)
f0101009:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010100c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010100f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101012:	83 c7 01             	add    $0x1,%edi
f0101015:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101019:	0f be d0             	movsbl %al,%edx
f010101c:	85 d2                	test   %edx,%edx
f010101e:	74 23                	je     f0101043 <vprintfmt+0x27c>
f0101020:	85 f6                	test   %esi,%esi
f0101022:	78 a1                	js     f0100fc5 <vprintfmt+0x1fe>
f0101024:	83 ee 01             	sub    $0x1,%esi
f0101027:	79 9c                	jns    f0100fc5 <vprintfmt+0x1fe>
f0101029:	89 df                	mov    %ebx,%edi
f010102b:	8b 75 08             	mov    0x8(%ebp),%esi
f010102e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101031:	eb 18                	jmp    f010104b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101033:	83 ec 08             	sub    $0x8,%esp
f0101036:	53                   	push   %ebx
f0101037:	6a 20                	push   $0x20
f0101039:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010103b:	83 ef 01             	sub    $0x1,%edi
f010103e:	83 c4 10             	add    $0x10,%esp
f0101041:	eb 08                	jmp    f010104b <vprintfmt+0x284>
f0101043:	89 df                	mov    %ebx,%edi
f0101045:	8b 75 08             	mov    0x8(%ebp),%esi
f0101048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010104b:	85 ff                	test   %edi,%edi
f010104d:	7f e4                	jg     f0101033 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010104f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101052:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101055:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101058:	e9 90 fd ff ff       	jmp    f0100ded <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010105d:	83 f9 01             	cmp    $0x1,%ecx
f0101060:	7e 19                	jle    f010107b <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0101062:	8b 45 14             	mov    0x14(%ebp),%eax
f0101065:	8b 50 04             	mov    0x4(%eax),%edx
f0101068:	8b 00                	mov    (%eax),%eax
f010106a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010106d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101070:	8b 45 14             	mov    0x14(%ebp),%eax
f0101073:	8d 40 08             	lea    0x8(%eax),%eax
f0101076:	89 45 14             	mov    %eax,0x14(%ebp)
f0101079:	eb 38                	jmp    f01010b3 <vprintfmt+0x2ec>
	else if (lflag)
f010107b:	85 c9                	test   %ecx,%ecx
f010107d:	74 1b                	je     f010109a <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f010107f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101082:	8b 00                	mov    (%eax),%eax
f0101084:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101087:	89 c1                	mov    %eax,%ecx
f0101089:	c1 f9 1f             	sar    $0x1f,%ecx
f010108c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010108f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101092:	8d 40 04             	lea    0x4(%eax),%eax
f0101095:	89 45 14             	mov    %eax,0x14(%ebp)
f0101098:	eb 19                	jmp    f01010b3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f010109a:	8b 45 14             	mov    0x14(%ebp),%eax
f010109d:	8b 00                	mov    (%eax),%eax
f010109f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a2:	89 c1                	mov    %eax,%ecx
f01010a4:	c1 f9 1f             	sar    $0x1f,%ecx
f01010a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ad:	8d 40 04             	lea    0x4(%eax),%eax
f01010b0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010c2:	0f 89 0e 01 00 00    	jns    f01011d6 <vprintfmt+0x40f>
				putch('-', putdat);
f01010c8:	83 ec 08             	sub    $0x8,%esp
f01010cb:	53                   	push   %ebx
f01010cc:	6a 2d                	push   $0x2d
f01010ce:	ff d6                	call   *%esi
				num = -(long long) num;
f01010d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01010d6:	f7 da                	neg    %edx
f01010d8:	83 d1 00             	adc    $0x0,%ecx
f01010db:	f7 d9                	neg    %ecx
f01010dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010e0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010e5:	e9 ec 00 00 00       	jmp    f01011d6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010ea:	83 f9 01             	cmp    $0x1,%ecx
f01010ed:	7e 18                	jle    f0101107 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01010ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f2:	8b 10                	mov    (%eax),%edx
f01010f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01010f7:	8d 40 08             	lea    0x8(%eax),%eax
f01010fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01010fd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101102:	e9 cf 00 00 00       	jmp    f01011d6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0101107:	85 c9                	test   %ecx,%ecx
f0101109:	74 1a                	je     f0101125 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f010110b:	8b 45 14             	mov    0x14(%ebp),%eax
f010110e:	8b 10                	mov    (%eax),%edx
f0101110:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101115:	8d 40 04             	lea    0x4(%eax),%eax
f0101118:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010111b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101120:	e9 b1 00 00 00       	jmp    f01011d6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0101125:	8b 45 14             	mov    0x14(%ebp),%eax
f0101128:	8b 10                	mov    (%eax),%edx
f010112a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010112f:	8d 40 04             	lea    0x4(%eax),%eax
f0101132:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101135:	b8 0a 00 00 00       	mov    $0xa,%eax
f010113a:	e9 97 00 00 00       	jmp    f01011d6 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010113f:	83 ec 08             	sub    $0x8,%esp
f0101142:	53                   	push   %ebx
f0101143:	6a 58                	push   $0x58
f0101145:	ff d6                	call   *%esi
			putch('X', putdat);
f0101147:	83 c4 08             	add    $0x8,%esp
f010114a:	53                   	push   %ebx
f010114b:	6a 58                	push   $0x58
f010114d:	ff d6                	call   *%esi
			putch('X', putdat);
f010114f:	83 c4 08             	add    $0x8,%esp
f0101152:	53                   	push   %ebx
f0101153:	6a 58                	push   $0x58
f0101155:	ff d6                	call   *%esi
			break;
f0101157:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010115a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010115d:	e9 8b fc ff ff       	jmp    f0100ded <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0101162:	83 ec 08             	sub    $0x8,%esp
f0101165:	53                   	push   %ebx
f0101166:	6a 30                	push   $0x30
f0101168:	ff d6                	call   *%esi
			putch('x', putdat);
f010116a:	83 c4 08             	add    $0x8,%esp
f010116d:	53                   	push   %ebx
f010116e:	6a 78                	push   $0x78
f0101170:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101172:	8b 45 14             	mov    0x14(%ebp),%eax
f0101175:	8b 10                	mov    (%eax),%edx
f0101177:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010117c:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010117f:	8d 40 04             	lea    0x4(%eax),%eax
f0101182:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101185:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010118a:	eb 4a                	jmp    f01011d6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010118c:	83 f9 01             	cmp    $0x1,%ecx
f010118f:	7e 15                	jle    f01011a6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0101191:	8b 45 14             	mov    0x14(%ebp),%eax
f0101194:	8b 10                	mov    (%eax),%edx
f0101196:	8b 48 04             	mov    0x4(%eax),%ecx
f0101199:	8d 40 08             	lea    0x8(%eax),%eax
f010119c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010119f:	b8 10 00 00 00       	mov    $0x10,%eax
f01011a4:	eb 30                	jmp    f01011d6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01011a6:	85 c9                	test   %ecx,%ecx
f01011a8:	74 17                	je     f01011c1 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f01011aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ad:	8b 10                	mov    (%eax),%edx
f01011af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011b4:	8d 40 04             	lea    0x4(%eax),%eax
f01011b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01011ba:	b8 10 00 00 00       	mov    $0x10,%eax
f01011bf:	eb 15                	jmp    f01011d6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01011c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011c4:	8b 10                	mov    (%eax),%edx
f01011c6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011cb:	8d 40 04             	lea    0x4(%eax),%eax
f01011ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01011d1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011d6:	83 ec 0c             	sub    $0xc,%esp
f01011d9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011dd:	57                   	push   %edi
f01011de:	ff 75 e0             	pushl  -0x20(%ebp)
f01011e1:	50                   	push   %eax
f01011e2:	51                   	push   %ecx
f01011e3:	52                   	push   %edx
f01011e4:	89 da                	mov    %ebx,%edx
f01011e6:	89 f0                	mov    %esi,%eax
f01011e8:	e8 f1 fa ff ff       	call   f0100cde <printnum>
			break;
f01011ed:	83 c4 20             	add    $0x20,%esp
f01011f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011f3:	e9 f5 fb ff ff       	jmp    f0100ded <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011f8:	83 ec 08             	sub    $0x8,%esp
f01011fb:	53                   	push   %ebx
f01011fc:	52                   	push   %edx
f01011fd:	ff d6                	call   *%esi
			break;
f01011ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101202:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101205:	e9 e3 fb ff ff       	jmp    f0100ded <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010120a:	83 ec 08             	sub    $0x8,%esp
f010120d:	53                   	push   %ebx
f010120e:	6a 25                	push   $0x25
f0101210:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101212:	83 c4 10             	add    $0x10,%esp
f0101215:	eb 03                	jmp    f010121a <vprintfmt+0x453>
f0101217:	83 ef 01             	sub    $0x1,%edi
f010121a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010121e:	75 f7                	jne    f0101217 <vprintfmt+0x450>
f0101220:	e9 c8 fb ff ff       	jmp    f0100ded <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101225:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101228:	5b                   	pop    %ebx
f0101229:	5e                   	pop    %esi
f010122a:	5f                   	pop    %edi
f010122b:	5d                   	pop    %ebp
f010122c:	c3                   	ret    

f010122d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010122d:	55                   	push   %ebp
f010122e:	89 e5                	mov    %esp,%ebp
f0101230:	83 ec 18             	sub    $0x18,%esp
f0101233:	8b 45 08             	mov    0x8(%ebp),%eax
f0101236:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101239:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010123c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101240:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101243:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010124a:	85 c0                	test   %eax,%eax
f010124c:	74 26                	je     f0101274 <vsnprintf+0x47>
f010124e:	85 d2                	test   %edx,%edx
f0101250:	7e 22                	jle    f0101274 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101252:	ff 75 14             	pushl  0x14(%ebp)
f0101255:	ff 75 10             	pushl  0x10(%ebp)
f0101258:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010125b:	50                   	push   %eax
f010125c:	68 8d 0d 10 f0       	push   $0xf0100d8d
f0101261:	e8 61 fb ff ff       	call   f0100dc7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101266:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101269:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010126c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	eb 05                	jmp    f0101279 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101279:	c9                   	leave  
f010127a:	c3                   	ret    

f010127b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101281:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101284:	50                   	push   %eax
f0101285:	ff 75 10             	pushl  0x10(%ebp)
f0101288:	ff 75 0c             	pushl  0xc(%ebp)
f010128b:	ff 75 08             	pushl  0x8(%ebp)
f010128e:	e8 9a ff ff ff       	call   f010122d <vsnprintf>
	va_end(ap);

	return rc;
}
f0101293:	c9                   	leave  
f0101294:	c3                   	ret    

f0101295 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101295:	55                   	push   %ebp
f0101296:	89 e5                	mov    %esp,%ebp
f0101298:	57                   	push   %edi
f0101299:	56                   	push   %esi
f010129a:	53                   	push   %ebx
f010129b:	83 ec 0c             	sub    $0xc,%esp
f010129e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 11                	je     f01012b6 <readline+0x21>
		cprintf("%s", prompt);
f01012a5:	83 ec 08             	sub    $0x8,%esp
f01012a8:	50                   	push   %eax
f01012a9:	68 d6 1e 10 f0       	push   $0xf0101ed6
f01012ae:	e8 50 f7 ff ff       	call   f0100a03 <cprintf>
f01012b3:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01012b6:	83 ec 0c             	sub    $0xc,%esp
f01012b9:	6a 00                	push   $0x0
f01012bb:	e8 61 f3 ff ff       	call   f0100621 <iscons>
f01012c0:	89 c7                	mov    %eax,%edi
f01012c2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01012c5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012ca:	e8 41 f3 ff ff       	call   f0100610 <getchar>
f01012cf:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012d1:	85 c0                	test   %eax,%eax
f01012d3:	79 18                	jns    f01012ed <readline+0x58>
			cprintf("read error: %e\n", c);
f01012d5:	83 ec 08             	sub    $0x8,%esp
f01012d8:	50                   	push   %eax
f01012d9:	68 b8 20 10 f0       	push   $0xf01020b8
f01012de:	e8 20 f7 ff ff       	call   f0100a03 <cprintf>
			return NULL;
f01012e3:	83 c4 10             	add    $0x10,%esp
f01012e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012eb:	eb 79                	jmp    f0101366 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012ed:	83 f8 08             	cmp    $0x8,%eax
f01012f0:	0f 94 c2             	sete   %dl
f01012f3:	83 f8 7f             	cmp    $0x7f,%eax
f01012f6:	0f 94 c0             	sete   %al
f01012f9:	08 c2                	or     %al,%dl
f01012fb:	74 1a                	je     f0101317 <readline+0x82>
f01012fd:	85 f6                	test   %esi,%esi
f01012ff:	7e 16                	jle    f0101317 <readline+0x82>
			if (echoing)
f0101301:	85 ff                	test   %edi,%edi
f0101303:	74 0d                	je     f0101312 <readline+0x7d>
				cputchar('\b');
f0101305:	83 ec 0c             	sub    $0xc,%esp
f0101308:	6a 08                	push   $0x8
f010130a:	e8 f1 f2 ff ff       	call   f0100600 <cputchar>
f010130f:	83 c4 10             	add    $0x10,%esp
			i--;
f0101312:	83 ee 01             	sub    $0x1,%esi
f0101315:	eb b3                	jmp    f01012ca <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101317:	83 fb 1f             	cmp    $0x1f,%ebx
f010131a:	7e 23                	jle    f010133f <readline+0xaa>
f010131c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101322:	7f 1b                	jg     f010133f <readline+0xaa>
			if (echoing)
f0101324:	85 ff                	test   %edi,%edi
f0101326:	74 0c                	je     f0101334 <readline+0x9f>
				cputchar(c);
f0101328:	83 ec 0c             	sub    $0xc,%esp
f010132b:	53                   	push   %ebx
f010132c:	e8 cf f2 ff ff       	call   f0100600 <cputchar>
f0101331:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101334:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010133a:	8d 76 01             	lea    0x1(%esi),%esi
f010133d:	eb 8b                	jmp    f01012ca <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010133f:	83 fb 0a             	cmp    $0xa,%ebx
f0101342:	74 05                	je     f0101349 <readline+0xb4>
f0101344:	83 fb 0d             	cmp    $0xd,%ebx
f0101347:	75 81                	jne    f01012ca <readline+0x35>
			if (echoing)
f0101349:	85 ff                	test   %edi,%edi
f010134b:	74 0d                	je     f010135a <readline+0xc5>
				cputchar('\n');
f010134d:	83 ec 0c             	sub    $0xc,%esp
f0101350:	6a 0a                	push   $0xa
f0101352:	e8 a9 f2 ff ff       	call   f0100600 <cputchar>
f0101357:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010135a:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101361:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101366:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101369:	5b                   	pop    %ebx
f010136a:	5e                   	pop    %esi
f010136b:	5f                   	pop    %edi
f010136c:	5d                   	pop    %ebp
f010136d:	c3                   	ret    

f010136e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010136e:	55                   	push   %ebp
f010136f:	89 e5                	mov    %esp,%ebp
f0101371:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101374:	b8 00 00 00 00       	mov    $0x0,%eax
f0101379:	eb 03                	jmp    f010137e <strlen+0x10>
		n++;
f010137b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010137e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101382:	75 f7                	jne    f010137b <strlen+0xd>
		n++;
	return n;
}
f0101384:	5d                   	pop    %ebp
f0101385:	c3                   	ret    

f0101386 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010138c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010138f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101394:	eb 03                	jmp    f0101399 <strnlen+0x13>
		n++;
f0101396:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101399:	39 c2                	cmp    %eax,%edx
f010139b:	74 08                	je     f01013a5 <strnlen+0x1f>
f010139d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01013a1:	75 f3                	jne    f0101396 <strnlen+0x10>
f01013a3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01013a5:	5d                   	pop    %ebp
f01013a6:	c3                   	ret    

f01013a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013a7:	55                   	push   %ebp
f01013a8:	89 e5                	mov    %esp,%ebp
f01013aa:	53                   	push   %ebx
f01013ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01013b1:	89 c2                	mov    %eax,%edx
f01013b3:	83 c2 01             	add    $0x1,%edx
f01013b6:	83 c1 01             	add    $0x1,%ecx
f01013b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01013bd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01013c0:	84 db                	test   %bl,%bl
f01013c2:	75 ef                	jne    f01013b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01013c4:	5b                   	pop    %ebx
f01013c5:	5d                   	pop    %ebp
f01013c6:	c3                   	ret    

f01013c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013c7:	55                   	push   %ebp
f01013c8:	89 e5                	mov    %esp,%ebp
f01013ca:	53                   	push   %ebx
f01013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013ce:	53                   	push   %ebx
f01013cf:	e8 9a ff ff ff       	call   f010136e <strlen>
f01013d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01013d7:	ff 75 0c             	pushl  0xc(%ebp)
f01013da:	01 d8                	add    %ebx,%eax
f01013dc:	50                   	push   %eax
f01013dd:	e8 c5 ff ff ff       	call   f01013a7 <strcpy>
	return dst;
}
f01013e2:	89 d8                	mov    %ebx,%eax
f01013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013e7:	c9                   	leave  
f01013e8:	c3                   	ret    

f01013e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013e9:	55                   	push   %ebp
f01013ea:	89 e5                	mov    %esp,%ebp
f01013ec:	56                   	push   %esi
f01013ed:	53                   	push   %ebx
f01013ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013f4:	89 f3                	mov    %esi,%ebx
f01013f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013f9:	89 f2                	mov    %esi,%edx
f01013fb:	eb 0f                	jmp    f010140c <strncpy+0x23>
		*dst++ = *src;
f01013fd:	83 c2 01             	add    $0x1,%edx
f0101400:	0f b6 01             	movzbl (%ecx),%eax
f0101403:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101406:	80 39 01             	cmpb   $0x1,(%ecx)
f0101409:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010140c:	39 da                	cmp    %ebx,%edx
f010140e:	75 ed                	jne    f01013fd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101410:	89 f0                	mov    %esi,%eax
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5d                   	pop    %ebp
f0101415:	c3                   	ret    

f0101416 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	56                   	push   %esi
f010141a:	53                   	push   %ebx
f010141b:	8b 75 08             	mov    0x8(%ebp),%esi
f010141e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101421:	8b 55 10             	mov    0x10(%ebp),%edx
f0101424:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101426:	85 d2                	test   %edx,%edx
f0101428:	74 21                	je     f010144b <strlcpy+0x35>
f010142a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010142e:	89 f2                	mov    %esi,%edx
f0101430:	eb 09                	jmp    f010143b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101432:	83 c2 01             	add    $0x1,%edx
f0101435:	83 c1 01             	add    $0x1,%ecx
f0101438:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010143b:	39 c2                	cmp    %eax,%edx
f010143d:	74 09                	je     f0101448 <strlcpy+0x32>
f010143f:	0f b6 19             	movzbl (%ecx),%ebx
f0101442:	84 db                	test   %bl,%bl
f0101444:	75 ec                	jne    f0101432 <strlcpy+0x1c>
f0101446:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101448:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010144b:	29 f0                	sub    %esi,%eax
}
f010144d:	5b                   	pop    %ebx
f010144e:	5e                   	pop    %esi
f010144f:	5d                   	pop    %ebp
f0101450:	c3                   	ret    

f0101451 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101451:	55                   	push   %ebp
f0101452:	89 e5                	mov    %esp,%ebp
f0101454:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101457:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010145a:	eb 06                	jmp    f0101462 <strcmp+0x11>
		p++, q++;
f010145c:	83 c1 01             	add    $0x1,%ecx
f010145f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101462:	0f b6 01             	movzbl (%ecx),%eax
f0101465:	84 c0                	test   %al,%al
f0101467:	74 04                	je     f010146d <strcmp+0x1c>
f0101469:	3a 02                	cmp    (%edx),%al
f010146b:	74 ef                	je     f010145c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010146d:	0f b6 c0             	movzbl %al,%eax
f0101470:	0f b6 12             	movzbl (%edx),%edx
f0101473:	29 d0                	sub    %edx,%eax
}
f0101475:	5d                   	pop    %ebp
f0101476:	c3                   	ret    

f0101477 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101477:	55                   	push   %ebp
f0101478:	89 e5                	mov    %esp,%ebp
f010147a:	53                   	push   %ebx
f010147b:	8b 45 08             	mov    0x8(%ebp),%eax
f010147e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101481:	89 c3                	mov    %eax,%ebx
f0101483:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101486:	eb 06                	jmp    f010148e <strncmp+0x17>
		n--, p++, q++;
f0101488:	83 c0 01             	add    $0x1,%eax
f010148b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010148e:	39 d8                	cmp    %ebx,%eax
f0101490:	74 15                	je     f01014a7 <strncmp+0x30>
f0101492:	0f b6 08             	movzbl (%eax),%ecx
f0101495:	84 c9                	test   %cl,%cl
f0101497:	74 04                	je     f010149d <strncmp+0x26>
f0101499:	3a 0a                	cmp    (%edx),%cl
f010149b:	74 eb                	je     f0101488 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010149d:	0f b6 00             	movzbl (%eax),%eax
f01014a0:	0f b6 12             	movzbl (%edx),%edx
f01014a3:	29 d0                	sub    %edx,%eax
f01014a5:	eb 05                	jmp    f01014ac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01014a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01014ac:	5b                   	pop    %ebx
f01014ad:	5d                   	pop    %ebp
f01014ae:	c3                   	ret    

f01014af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014af:	55                   	push   %ebp
f01014b0:	89 e5                	mov    %esp,%ebp
f01014b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014b9:	eb 07                	jmp    f01014c2 <strchr+0x13>
		if (*s == c)
f01014bb:	38 ca                	cmp    %cl,%dl
f01014bd:	74 0f                	je     f01014ce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01014bf:	83 c0 01             	add    $0x1,%eax
f01014c2:	0f b6 10             	movzbl (%eax),%edx
f01014c5:	84 d2                	test   %dl,%dl
f01014c7:	75 f2                	jne    f01014bb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01014c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014ce:	5d                   	pop    %ebp
f01014cf:	c3                   	ret    

f01014d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014d0:	55                   	push   %ebp
f01014d1:	89 e5                	mov    %esp,%ebp
f01014d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014da:	eb 03                	jmp    f01014df <strfind+0xf>
f01014dc:	83 c0 01             	add    $0x1,%eax
f01014df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01014e2:	38 ca                	cmp    %cl,%dl
f01014e4:	74 04                	je     f01014ea <strfind+0x1a>
f01014e6:	84 d2                	test   %dl,%dl
f01014e8:	75 f2                	jne    f01014dc <strfind+0xc>
			break;
	return (char *) s;
}
f01014ea:	5d                   	pop    %ebp
f01014eb:	c3                   	ret    

f01014ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014ec:	55                   	push   %ebp
f01014ed:	89 e5                	mov    %esp,%ebp
f01014ef:	57                   	push   %edi
f01014f0:	56                   	push   %esi
f01014f1:	53                   	push   %ebx
f01014f2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014f8:	85 c9                	test   %ecx,%ecx
f01014fa:	74 36                	je     f0101532 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101502:	75 28                	jne    f010152c <memset+0x40>
f0101504:	f6 c1 03             	test   $0x3,%cl
f0101507:	75 23                	jne    f010152c <memset+0x40>
		c &= 0xFF;
f0101509:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010150d:	89 d3                	mov    %edx,%ebx
f010150f:	c1 e3 08             	shl    $0x8,%ebx
f0101512:	89 d6                	mov    %edx,%esi
f0101514:	c1 e6 18             	shl    $0x18,%esi
f0101517:	89 d0                	mov    %edx,%eax
f0101519:	c1 e0 10             	shl    $0x10,%eax
f010151c:	09 f0                	or     %esi,%eax
f010151e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101520:	89 d8                	mov    %ebx,%eax
f0101522:	09 d0                	or     %edx,%eax
f0101524:	c1 e9 02             	shr    $0x2,%ecx
f0101527:	fc                   	cld    
f0101528:	f3 ab                	rep stos %eax,%es:(%edi)
f010152a:	eb 06                	jmp    f0101532 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010152c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010152f:	fc                   	cld    
f0101530:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101532:	89 f8                	mov    %edi,%eax
f0101534:	5b                   	pop    %ebx
f0101535:	5e                   	pop    %esi
f0101536:	5f                   	pop    %edi
f0101537:	5d                   	pop    %ebp
f0101538:	c3                   	ret    

f0101539 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101539:	55                   	push   %ebp
f010153a:	89 e5                	mov    %esp,%ebp
f010153c:	57                   	push   %edi
f010153d:	56                   	push   %esi
f010153e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101541:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101544:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101547:	39 c6                	cmp    %eax,%esi
f0101549:	73 35                	jae    f0101580 <memmove+0x47>
f010154b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010154e:	39 d0                	cmp    %edx,%eax
f0101550:	73 2e                	jae    f0101580 <memmove+0x47>
		s += n;
		d += n;
f0101552:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101555:	89 d6                	mov    %edx,%esi
f0101557:	09 fe                	or     %edi,%esi
f0101559:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010155f:	75 13                	jne    f0101574 <memmove+0x3b>
f0101561:	f6 c1 03             	test   $0x3,%cl
f0101564:	75 0e                	jne    f0101574 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101566:	83 ef 04             	sub    $0x4,%edi
f0101569:	8d 72 fc             	lea    -0x4(%edx),%esi
f010156c:	c1 e9 02             	shr    $0x2,%ecx
f010156f:	fd                   	std    
f0101570:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101572:	eb 09                	jmp    f010157d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101574:	83 ef 01             	sub    $0x1,%edi
f0101577:	8d 72 ff             	lea    -0x1(%edx),%esi
f010157a:	fd                   	std    
f010157b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010157d:	fc                   	cld    
f010157e:	eb 1d                	jmp    f010159d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101580:	89 f2                	mov    %esi,%edx
f0101582:	09 c2                	or     %eax,%edx
f0101584:	f6 c2 03             	test   $0x3,%dl
f0101587:	75 0f                	jne    f0101598 <memmove+0x5f>
f0101589:	f6 c1 03             	test   $0x3,%cl
f010158c:	75 0a                	jne    f0101598 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010158e:	c1 e9 02             	shr    $0x2,%ecx
f0101591:	89 c7                	mov    %eax,%edi
f0101593:	fc                   	cld    
f0101594:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101596:	eb 05                	jmp    f010159d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101598:	89 c7                	mov    %eax,%edi
f010159a:	fc                   	cld    
f010159b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010159d:	5e                   	pop    %esi
f010159e:	5f                   	pop    %edi
f010159f:	5d                   	pop    %ebp
f01015a0:	c3                   	ret    

f01015a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015a1:	55                   	push   %ebp
f01015a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01015a4:	ff 75 10             	pushl  0x10(%ebp)
f01015a7:	ff 75 0c             	pushl  0xc(%ebp)
f01015aa:	ff 75 08             	pushl  0x8(%ebp)
f01015ad:	e8 87 ff ff ff       	call   f0101539 <memmove>
}
f01015b2:	c9                   	leave  
f01015b3:	c3                   	ret    

f01015b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015b4:	55                   	push   %ebp
f01015b5:	89 e5                	mov    %esp,%ebp
f01015b7:	56                   	push   %esi
f01015b8:	53                   	push   %ebx
f01015b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01015bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015bf:	89 c6                	mov    %eax,%esi
f01015c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015c4:	eb 1a                	jmp    f01015e0 <memcmp+0x2c>
		if (*s1 != *s2)
f01015c6:	0f b6 08             	movzbl (%eax),%ecx
f01015c9:	0f b6 1a             	movzbl (%edx),%ebx
f01015cc:	38 d9                	cmp    %bl,%cl
f01015ce:	74 0a                	je     f01015da <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01015d0:	0f b6 c1             	movzbl %cl,%eax
f01015d3:	0f b6 db             	movzbl %bl,%ebx
f01015d6:	29 d8                	sub    %ebx,%eax
f01015d8:	eb 0f                	jmp    f01015e9 <memcmp+0x35>
		s1++, s2++;
f01015da:	83 c0 01             	add    $0x1,%eax
f01015dd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015e0:	39 f0                	cmp    %esi,%eax
f01015e2:	75 e2                	jne    f01015c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015e9:	5b                   	pop    %ebx
f01015ea:	5e                   	pop    %esi
f01015eb:	5d                   	pop    %ebp
f01015ec:	c3                   	ret    

f01015ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015ed:	55                   	push   %ebp
f01015ee:	89 e5                	mov    %esp,%ebp
f01015f0:	53                   	push   %ebx
f01015f1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01015f4:	89 c1                	mov    %eax,%ecx
f01015f6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01015f9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015fd:	eb 0a                	jmp    f0101609 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015ff:	0f b6 10             	movzbl (%eax),%edx
f0101602:	39 da                	cmp    %ebx,%edx
f0101604:	74 07                	je     f010160d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101606:	83 c0 01             	add    $0x1,%eax
f0101609:	39 c8                	cmp    %ecx,%eax
f010160b:	72 f2                	jb     f01015ff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010160d:	5b                   	pop    %ebx
f010160e:	5d                   	pop    %ebp
f010160f:	c3                   	ret    

f0101610 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101610:	55                   	push   %ebp
f0101611:	89 e5                	mov    %esp,%ebp
f0101613:	57                   	push   %edi
f0101614:	56                   	push   %esi
f0101615:	53                   	push   %ebx
f0101616:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101619:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010161c:	eb 03                	jmp    f0101621 <strtol+0x11>
		s++;
f010161e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101621:	0f b6 01             	movzbl (%ecx),%eax
f0101624:	3c 20                	cmp    $0x20,%al
f0101626:	74 f6                	je     f010161e <strtol+0xe>
f0101628:	3c 09                	cmp    $0x9,%al
f010162a:	74 f2                	je     f010161e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010162c:	3c 2b                	cmp    $0x2b,%al
f010162e:	75 0a                	jne    f010163a <strtol+0x2a>
		s++;
f0101630:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101633:	bf 00 00 00 00       	mov    $0x0,%edi
f0101638:	eb 11                	jmp    f010164b <strtol+0x3b>
f010163a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010163f:	3c 2d                	cmp    $0x2d,%al
f0101641:	75 08                	jne    f010164b <strtol+0x3b>
		s++, neg = 1;
f0101643:	83 c1 01             	add    $0x1,%ecx
f0101646:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010164b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101651:	75 15                	jne    f0101668 <strtol+0x58>
f0101653:	80 39 30             	cmpb   $0x30,(%ecx)
f0101656:	75 10                	jne    f0101668 <strtol+0x58>
f0101658:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010165c:	75 7c                	jne    f01016da <strtol+0xca>
		s += 2, base = 16;
f010165e:	83 c1 02             	add    $0x2,%ecx
f0101661:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101666:	eb 16                	jmp    f010167e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101668:	85 db                	test   %ebx,%ebx
f010166a:	75 12                	jne    f010167e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010166c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101671:	80 39 30             	cmpb   $0x30,(%ecx)
f0101674:	75 08                	jne    f010167e <strtol+0x6e>
		s++, base = 8;
f0101676:	83 c1 01             	add    $0x1,%ecx
f0101679:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010167e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101683:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101686:	0f b6 11             	movzbl (%ecx),%edx
f0101689:	8d 72 d0             	lea    -0x30(%edx),%esi
f010168c:	89 f3                	mov    %esi,%ebx
f010168e:	80 fb 09             	cmp    $0x9,%bl
f0101691:	77 08                	ja     f010169b <strtol+0x8b>
			dig = *s - '0';
f0101693:	0f be d2             	movsbl %dl,%edx
f0101696:	83 ea 30             	sub    $0x30,%edx
f0101699:	eb 22                	jmp    f01016bd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010169b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010169e:	89 f3                	mov    %esi,%ebx
f01016a0:	80 fb 19             	cmp    $0x19,%bl
f01016a3:	77 08                	ja     f01016ad <strtol+0x9d>
			dig = *s - 'a' + 10;
f01016a5:	0f be d2             	movsbl %dl,%edx
f01016a8:	83 ea 57             	sub    $0x57,%edx
f01016ab:	eb 10                	jmp    f01016bd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01016ad:	8d 72 bf             	lea    -0x41(%edx),%esi
f01016b0:	89 f3                	mov    %esi,%ebx
f01016b2:	80 fb 19             	cmp    $0x19,%bl
f01016b5:	77 16                	ja     f01016cd <strtol+0xbd>
			dig = *s - 'A' + 10;
f01016b7:	0f be d2             	movsbl %dl,%edx
f01016ba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01016bd:	3b 55 10             	cmp    0x10(%ebp),%edx
f01016c0:	7d 0b                	jge    f01016cd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01016c2:	83 c1 01             	add    $0x1,%ecx
f01016c5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01016c9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01016cb:	eb b9                	jmp    f0101686 <strtol+0x76>

	if (endptr)
f01016cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016d1:	74 0d                	je     f01016e0 <strtol+0xd0>
		*endptr = (char *) s;
f01016d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016d6:	89 0e                	mov    %ecx,(%esi)
f01016d8:	eb 06                	jmp    f01016e0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016da:	85 db                	test   %ebx,%ebx
f01016dc:	74 98                	je     f0101676 <strtol+0x66>
f01016de:	eb 9e                	jmp    f010167e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01016e0:	89 c2                	mov    %eax,%edx
f01016e2:	f7 da                	neg    %edx
f01016e4:	85 ff                	test   %edi,%edi
f01016e6:	0f 45 c2             	cmovne %edx,%eax
}
f01016e9:	5b                   	pop    %ebx
f01016ea:	5e                   	pop    %esi
f01016eb:	5f                   	pop    %edi
f01016ec:	5d                   	pop    %ebp
f01016ed:	c3                   	ret    
f01016ee:	66 90                	xchg   %ax,%ax

f01016f0 <__udivdi3>:
f01016f0:	55                   	push   %ebp
f01016f1:	57                   	push   %edi
f01016f2:	56                   	push   %esi
f01016f3:	53                   	push   %ebx
f01016f4:	83 ec 1c             	sub    $0x1c,%esp
f01016f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01016fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01016ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101703:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101707:	85 f6                	test   %esi,%esi
f0101709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010170d:	89 ca                	mov    %ecx,%edx
f010170f:	89 f8                	mov    %edi,%eax
f0101711:	75 3d                	jne    f0101750 <__udivdi3+0x60>
f0101713:	39 cf                	cmp    %ecx,%edi
f0101715:	0f 87 c5 00 00 00    	ja     f01017e0 <__udivdi3+0xf0>
f010171b:	85 ff                	test   %edi,%edi
f010171d:	89 fd                	mov    %edi,%ebp
f010171f:	75 0b                	jne    f010172c <__udivdi3+0x3c>
f0101721:	b8 01 00 00 00       	mov    $0x1,%eax
f0101726:	31 d2                	xor    %edx,%edx
f0101728:	f7 f7                	div    %edi
f010172a:	89 c5                	mov    %eax,%ebp
f010172c:	89 c8                	mov    %ecx,%eax
f010172e:	31 d2                	xor    %edx,%edx
f0101730:	f7 f5                	div    %ebp
f0101732:	89 c1                	mov    %eax,%ecx
f0101734:	89 d8                	mov    %ebx,%eax
f0101736:	89 cf                	mov    %ecx,%edi
f0101738:	f7 f5                	div    %ebp
f010173a:	89 c3                	mov    %eax,%ebx
f010173c:	89 d8                	mov    %ebx,%eax
f010173e:	89 fa                	mov    %edi,%edx
f0101740:	83 c4 1c             	add    $0x1c,%esp
f0101743:	5b                   	pop    %ebx
f0101744:	5e                   	pop    %esi
f0101745:	5f                   	pop    %edi
f0101746:	5d                   	pop    %ebp
f0101747:	c3                   	ret    
f0101748:	90                   	nop
f0101749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101750:	39 ce                	cmp    %ecx,%esi
f0101752:	77 74                	ja     f01017c8 <__udivdi3+0xd8>
f0101754:	0f bd fe             	bsr    %esi,%edi
f0101757:	83 f7 1f             	xor    $0x1f,%edi
f010175a:	0f 84 98 00 00 00    	je     f01017f8 <__udivdi3+0x108>
f0101760:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101765:	89 f9                	mov    %edi,%ecx
f0101767:	89 c5                	mov    %eax,%ebp
f0101769:	29 fb                	sub    %edi,%ebx
f010176b:	d3 e6                	shl    %cl,%esi
f010176d:	89 d9                	mov    %ebx,%ecx
f010176f:	d3 ed                	shr    %cl,%ebp
f0101771:	89 f9                	mov    %edi,%ecx
f0101773:	d3 e0                	shl    %cl,%eax
f0101775:	09 ee                	or     %ebp,%esi
f0101777:	89 d9                	mov    %ebx,%ecx
f0101779:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010177d:	89 d5                	mov    %edx,%ebp
f010177f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101783:	d3 ed                	shr    %cl,%ebp
f0101785:	89 f9                	mov    %edi,%ecx
f0101787:	d3 e2                	shl    %cl,%edx
f0101789:	89 d9                	mov    %ebx,%ecx
f010178b:	d3 e8                	shr    %cl,%eax
f010178d:	09 c2                	or     %eax,%edx
f010178f:	89 d0                	mov    %edx,%eax
f0101791:	89 ea                	mov    %ebp,%edx
f0101793:	f7 f6                	div    %esi
f0101795:	89 d5                	mov    %edx,%ebp
f0101797:	89 c3                	mov    %eax,%ebx
f0101799:	f7 64 24 0c          	mull   0xc(%esp)
f010179d:	39 d5                	cmp    %edx,%ebp
f010179f:	72 10                	jb     f01017b1 <__udivdi3+0xc1>
f01017a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01017a5:	89 f9                	mov    %edi,%ecx
f01017a7:	d3 e6                	shl    %cl,%esi
f01017a9:	39 c6                	cmp    %eax,%esi
f01017ab:	73 07                	jae    f01017b4 <__udivdi3+0xc4>
f01017ad:	39 d5                	cmp    %edx,%ebp
f01017af:	75 03                	jne    f01017b4 <__udivdi3+0xc4>
f01017b1:	83 eb 01             	sub    $0x1,%ebx
f01017b4:	31 ff                	xor    %edi,%edi
f01017b6:	89 d8                	mov    %ebx,%eax
f01017b8:	89 fa                	mov    %edi,%edx
f01017ba:	83 c4 1c             	add    $0x1c,%esp
f01017bd:	5b                   	pop    %ebx
f01017be:	5e                   	pop    %esi
f01017bf:	5f                   	pop    %edi
f01017c0:	5d                   	pop    %ebp
f01017c1:	c3                   	ret    
f01017c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017c8:	31 ff                	xor    %edi,%edi
f01017ca:	31 db                	xor    %ebx,%ebx
f01017cc:	89 d8                	mov    %ebx,%eax
f01017ce:	89 fa                	mov    %edi,%edx
f01017d0:	83 c4 1c             	add    $0x1c,%esp
f01017d3:	5b                   	pop    %ebx
f01017d4:	5e                   	pop    %esi
f01017d5:	5f                   	pop    %edi
f01017d6:	5d                   	pop    %ebp
f01017d7:	c3                   	ret    
f01017d8:	90                   	nop
f01017d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017e0:	89 d8                	mov    %ebx,%eax
f01017e2:	f7 f7                	div    %edi
f01017e4:	31 ff                	xor    %edi,%edi
f01017e6:	89 c3                	mov    %eax,%ebx
f01017e8:	89 d8                	mov    %ebx,%eax
f01017ea:	89 fa                	mov    %edi,%edx
f01017ec:	83 c4 1c             	add    $0x1c,%esp
f01017ef:	5b                   	pop    %ebx
f01017f0:	5e                   	pop    %esi
f01017f1:	5f                   	pop    %edi
f01017f2:	5d                   	pop    %ebp
f01017f3:	c3                   	ret    
f01017f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017f8:	39 ce                	cmp    %ecx,%esi
f01017fa:	72 0c                	jb     f0101808 <__udivdi3+0x118>
f01017fc:	31 db                	xor    %ebx,%ebx
f01017fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101802:	0f 87 34 ff ff ff    	ja     f010173c <__udivdi3+0x4c>
f0101808:	bb 01 00 00 00       	mov    $0x1,%ebx
f010180d:	e9 2a ff ff ff       	jmp    f010173c <__udivdi3+0x4c>
f0101812:	66 90                	xchg   %ax,%ax
f0101814:	66 90                	xchg   %ax,%ax
f0101816:	66 90                	xchg   %ax,%ax
f0101818:	66 90                	xchg   %ax,%ax
f010181a:	66 90                	xchg   %ax,%ax
f010181c:	66 90                	xchg   %ax,%ax
f010181e:	66 90                	xchg   %ax,%ax

f0101820 <__umoddi3>:
f0101820:	55                   	push   %ebp
f0101821:	57                   	push   %edi
f0101822:	56                   	push   %esi
f0101823:	53                   	push   %ebx
f0101824:	83 ec 1c             	sub    $0x1c,%esp
f0101827:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010182b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010182f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101833:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101837:	85 d2                	test   %edx,%edx
f0101839:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010183d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101841:	89 f3                	mov    %esi,%ebx
f0101843:	89 3c 24             	mov    %edi,(%esp)
f0101846:	89 74 24 04          	mov    %esi,0x4(%esp)
f010184a:	75 1c                	jne    f0101868 <__umoddi3+0x48>
f010184c:	39 f7                	cmp    %esi,%edi
f010184e:	76 50                	jbe    f01018a0 <__umoddi3+0x80>
f0101850:	89 c8                	mov    %ecx,%eax
f0101852:	89 f2                	mov    %esi,%edx
f0101854:	f7 f7                	div    %edi
f0101856:	89 d0                	mov    %edx,%eax
f0101858:	31 d2                	xor    %edx,%edx
f010185a:	83 c4 1c             	add    $0x1c,%esp
f010185d:	5b                   	pop    %ebx
f010185e:	5e                   	pop    %esi
f010185f:	5f                   	pop    %edi
f0101860:	5d                   	pop    %ebp
f0101861:	c3                   	ret    
f0101862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101868:	39 f2                	cmp    %esi,%edx
f010186a:	89 d0                	mov    %edx,%eax
f010186c:	77 52                	ja     f01018c0 <__umoddi3+0xa0>
f010186e:	0f bd ea             	bsr    %edx,%ebp
f0101871:	83 f5 1f             	xor    $0x1f,%ebp
f0101874:	75 5a                	jne    f01018d0 <__umoddi3+0xb0>
f0101876:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010187a:	0f 82 e0 00 00 00    	jb     f0101960 <__umoddi3+0x140>
f0101880:	39 0c 24             	cmp    %ecx,(%esp)
f0101883:	0f 86 d7 00 00 00    	jbe    f0101960 <__umoddi3+0x140>
f0101889:	8b 44 24 08          	mov    0x8(%esp),%eax
f010188d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101891:	83 c4 1c             	add    $0x1c,%esp
f0101894:	5b                   	pop    %ebx
f0101895:	5e                   	pop    %esi
f0101896:	5f                   	pop    %edi
f0101897:	5d                   	pop    %ebp
f0101898:	c3                   	ret    
f0101899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018a0:	85 ff                	test   %edi,%edi
f01018a2:	89 fd                	mov    %edi,%ebp
f01018a4:	75 0b                	jne    f01018b1 <__umoddi3+0x91>
f01018a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01018ab:	31 d2                	xor    %edx,%edx
f01018ad:	f7 f7                	div    %edi
f01018af:	89 c5                	mov    %eax,%ebp
f01018b1:	89 f0                	mov    %esi,%eax
f01018b3:	31 d2                	xor    %edx,%edx
f01018b5:	f7 f5                	div    %ebp
f01018b7:	89 c8                	mov    %ecx,%eax
f01018b9:	f7 f5                	div    %ebp
f01018bb:	89 d0                	mov    %edx,%eax
f01018bd:	eb 99                	jmp    f0101858 <__umoddi3+0x38>
f01018bf:	90                   	nop
f01018c0:	89 c8                	mov    %ecx,%eax
f01018c2:	89 f2                	mov    %esi,%edx
f01018c4:	83 c4 1c             	add    $0x1c,%esp
f01018c7:	5b                   	pop    %ebx
f01018c8:	5e                   	pop    %esi
f01018c9:	5f                   	pop    %edi
f01018ca:	5d                   	pop    %ebp
f01018cb:	c3                   	ret    
f01018cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	8b 34 24             	mov    (%esp),%esi
f01018d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01018d8:	89 e9                	mov    %ebp,%ecx
f01018da:	29 ef                	sub    %ebp,%edi
f01018dc:	d3 e0                	shl    %cl,%eax
f01018de:	89 f9                	mov    %edi,%ecx
f01018e0:	89 f2                	mov    %esi,%edx
f01018e2:	d3 ea                	shr    %cl,%edx
f01018e4:	89 e9                	mov    %ebp,%ecx
f01018e6:	09 c2                	or     %eax,%edx
f01018e8:	89 d8                	mov    %ebx,%eax
f01018ea:	89 14 24             	mov    %edx,(%esp)
f01018ed:	89 f2                	mov    %esi,%edx
f01018ef:	d3 e2                	shl    %cl,%edx
f01018f1:	89 f9                	mov    %edi,%ecx
f01018f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01018f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01018fb:	d3 e8                	shr    %cl,%eax
f01018fd:	89 e9                	mov    %ebp,%ecx
f01018ff:	89 c6                	mov    %eax,%esi
f0101901:	d3 e3                	shl    %cl,%ebx
f0101903:	89 f9                	mov    %edi,%ecx
f0101905:	89 d0                	mov    %edx,%eax
f0101907:	d3 e8                	shr    %cl,%eax
f0101909:	89 e9                	mov    %ebp,%ecx
f010190b:	09 d8                	or     %ebx,%eax
f010190d:	89 d3                	mov    %edx,%ebx
f010190f:	89 f2                	mov    %esi,%edx
f0101911:	f7 34 24             	divl   (%esp)
f0101914:	89 d6                	mov    %edx,%esi
f0101916:	d3 e3                	shl    %cl,%ebx
f0101918:	f7 64 24 04          	mull   0x4(%esp)
f010191c:	39 d6                	cmp    %edx,%esi
f010191e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101922:	89 d1                	mov    %edx,%ecx
f0101924:	89 c3                	mov    %eax,%ebx
f0101926:	72 08                	jb     f0101930 <__umoddi3+0x110>
f0101928:	75 11                	jne    f010193b <__umoddi3+0x11b>
f010192a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010192e:	73 0b                	jae    f010193b <__umoddi3+0x11b>
f0101930:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101934:	1b 14 24             	sbb    (%esp),%edx
f0101937:	89 d1                	mov    %edx,%ecx
f0101939:	89 c3                	mov    %eax,%ebx
f010193b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010193f:	29 da                	sub    %ebx,%edx
f0101941:	19 ce                	sbb    %ecx,%esi
f0101943:	89 f9                	mov    %edi,%ecx
f0101945:	89 f0                	mov    %esi,%eax
f0101947:	d3 e0                	shl    %cl,%eax
f0101949:	89 e9                	mov    %ebp,%ecx
f010194b:	d3 ea                	shr    %cl,%edx
f010194d:	89 e9                	mov    %ebp,%ecx
f010194f:	d3 ee                	shr    %cl,%esi
f0101951:	09 d0                	or     %edx,%eax
f0101953:	89 f2                	mov    %esi,%edx
f0101955:	83 c4 1c             	add    $0x1c,%esp
f0101958:	5b                   	pop    %ebx
f0101959:	5e                   	pop    %esi
f010195a:	5f                   	pop    %edi
f010195b:	5d                   	pop    %ebp
f010195c:	c3                   	ret    
f010195d:	8d 76 00             	lea    0x0(%esi),%esi
f0101960:	29 f9                	sub    %edi,%ecx
f0101962:	19 d6                	sbb    %edx,%esi
f0101964:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010196c:	e9 18 ff ff ff       	jmp    f0101889 <__umoddi3+0x69>
