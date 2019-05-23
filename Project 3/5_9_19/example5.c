#include <stdio.h>
void dummy(int x) {
   fprintf(stderr, "Hello World!\n");
}

int main(int argc, char **argv) {
   char buf[256];
   fgets(buf, 256, stdin);
   printf(buf);
   exit(0);
}

