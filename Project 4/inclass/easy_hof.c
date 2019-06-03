#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int main(int argc, char **argv) {
   setvbuf(stdin, NULL, _IONBF, 0);
   setvbuf(stdout, NULL, _IONBF, 0);
   setvbuf(stderr, NULL, _IONBF, 0);
   while (1) {
      size_t mem, data;
      char ch;
      void *buf;
      printf("How much memory? ");
      //for House of Force we need to control the size of an allocation AFTER
      //we have overwritten the size of the top chunk. Once top chunk has been
      //overwritten with ~MAX_INT, we can request a very large chunk so that the
      //end of the very large chunk is adjacent to a region we want to overwrite
      //In the second pass we request this very alrge chunk such that the size of 
      //the allocated chunk wraps all the way around to the got
      scanf("%llx%c", &mem, &ch);
      buf = malloc(mem);
      printf("Allocated at %p\n", buf);
      printf("How much data? ");
      //we can always specify a number larger than mem above so can have 
      //a buffer overflow in the fread below any time we want
      scanf("%llx%c", &data, &ch);
      //in the first pass only we will overflow to take control of the top chunk size
      //to make the top chunk seem very large
      fread(buf, 1, data, stdin);
   }
   exit(0);
}
