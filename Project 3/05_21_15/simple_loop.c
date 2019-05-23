#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
   char buf[256];
   setvbuf(stdin, NULL, _IONBF, 0);
   setvbuf(stdout, NULL, _IONBF, 0);
   while (fgets(buf, 256, stdin) != NULL) {
      printf(buf);
      if (strncmp(buf, "quit", 4) == 0) {
         break;
      }
   }
   exit(1);
}


