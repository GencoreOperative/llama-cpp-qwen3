#!/usr/bin/env python3
import sys

PATTERN = b"[end of text]"
plen = len(PATTERN)
buf = b""

inb = sys.stdin.buffer
outb = sys.stdout.buffer

while True:
    chunk = inb.read(1)   # read one byte at a time for immediate streaming
    if not chunk:
        break
    buf += chunk

    # Look for the pattern
    i = buf.find(PATTERN)
    if i != -1:
        # Write everything before the match
        outb.write(buf[:i])
        outb.flush()
        # Drop the matched pattern
        buf = buf[i + plen:]
        continue

    # Keep only enough trailing bytes to possibly match a future pattern
    keep = plen - 1
    if len(buf) > keep:
        outb.write(buf[:-keep])
        outb.flush()
        buf = buf[-keep:]

# Flush anything left that wasn't part of the pattern
if buf:
    outb.write(buf)
    outb.flush()
