#!/usr/bin/env python3
import sys

OPEN = b"<think>"
CLOSE = b"</think>"
state = "OUT"
buf = b""

# Unbuffered stdin/stdout for true streaming
inb = sys.stdin.buffer
outb = sys.stdout.buffer

while True:
    chunk = inb.read(1)
    if not chunk:
        break
    buf += chunk

    if state == "OUT":
        i = buf.find(OPEN)
        if i != -1:
            # print everything before tag, drop tag, enter think
            outb.write(buf[:i])
            outb.flush()
            buf = buf[i + len(OPEN):]
            state = "IN"
        else:
            # keep only enough tail to match a future OPEN
            keep = len(OPEN) - 1
            if len(buf) > keep:
                outb.write(buf[:-keep])
                outb.flush()
                buf = buf[-keep:]
    else:  # state == "IN"
        j = buf.find(CLOSE)
        if j != -1:
            # drop through close tag, then go OUT
            buf = buf[j + len(CLOSE):]
            state = "OUT"
        else:
            # keep only enough tail to match a future CLOSE
            keep = len(CLOSE) - 1
            if len(buf) > keep:
                buf = buf[-keep:]

# flush remaining visible bytes
if state == "OUT" and buf:
    outb.write(buf)
    outb.flush()
