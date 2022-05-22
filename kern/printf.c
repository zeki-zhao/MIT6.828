// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>


static void	//改变屏幕上的光标位置
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

int	//针对格式化符号处理的
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt); //处理可变参数
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}

