/* Lucas Burke
* 11 April 2019
* CS4678 - Assignment 1
* Assembly: nasm -f bin -g assn1.asm
* Compiler: gcc -z execstack -g -o assn1_harness assn1_harness.c 
* Comments: checked stack/heap pointers against stack/heap addresses using pidof and cat /proc/<pid>/maps -- they were correct on my system.
*/	

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

typedef void(*func)();

int *heap_code = NULL;  
FILE *binary;

int main(int argc, char** argv){

  int code_size;
  
  binary = fopen(argv[2], "rb");	
  
  fseek(binary, 0L, SEEK_END);
  code_size = ftell(binary);
  fseek(binary, 0L, SEEK_SET);
  
  char shell_code[code_size]; //read binary into shell_code
  
	fread(shell_code, 1, sizeof(shell_code), binary);
	
	// This is for stack-based binary execution
  if(strcmp(argv[1], "-s") == 0){
 		func f = (func)shell_code;
		//printf("Stack Addr: %p \n", f); //for troubleshooting
    (*f)();
  } 
  
  // This is for heap-based binary execution
  else if(strcmp(argv[1], "-h") == 0){	 
	  heap_code = malloc(code_size);	//malloc to get heap 
	  //printf("Heap address: %p \n", heap_code); //for troubleshooting

	  if(heap_code == NULL){
	  	printf("Error with malloc.");
	  	exit(-1);
	  	}

	  // Used memmove for ease.	
	  memmove(heap_code, shell_code, sizeof(shell_code));

	  func f = (func)heap_code;
	  (*f)();
	  free(heap_code);
  } 
  
  else {
	  printf("You didn't pass a valid s or h.\n");
	  exit(-1);
  }
  
  return 0;
}
