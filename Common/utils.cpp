#include "utils.h"

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <stdarg.h>
#include <assert.h>

void log(const char *format, ...) {
    va_list argp;
    const size_t buf_size = 200;
    char buf[buf_size];
    va_start(argp, format);
    i32 written = vsprintf_s(buf, buf_size, format, argp);
    va_end(argp);

    if(written < 0 || written >= buf_size - 1) {
        assert(false);
    }

    buf[written] = '\n';
    buf[written + 1] = '\0';
    OutputDebugStringA(buf);
}
