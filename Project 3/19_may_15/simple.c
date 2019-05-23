#include <stdio.h>

int main() {
   char buf[256];
   fgets(buf, 256, stdin);
   printf(buf);
   exit(1);
}


