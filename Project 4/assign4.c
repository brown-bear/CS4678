#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <sys/types.h>
#include <string.h>
#include <signal.h>
#include <stdint.h>

typedef struct _book {
   struct _book *next;
   struct _book *prev;
   char data[0];
} book;   

book *books;

char WELCOME[] = "Welcome to the simple inventory manager (0.1)!\n";

void menu() {
   fprintf(stderr, "1) Add book\n");
   fprintf(stderr, "2) Edit book\n");
   fprintf(stderr, "3) Remove book\n");
   fprintf(stderr, "4) List books\n");
   fprintf(stderr, "5) Save books\n");
   fprintf(stderr, "6) Load books\n");
   fprintf(stderr, "7) Quit\n");
}

char *input(char *line, int f) {
   char ch;
   int count = 0;
   line--;
   while ((read(f, &ch, 1)) == 1) {
      count++;
      if (ch == '\n') {
         break;
      }
      line[count] = ch;
   }
   if (count) {
      line[count] = 0;
   }
   line++;
   return count ? line : NULL;
}

void add() {
   char data[256];
   size_t size;
   char ch;
   fprintf(stderr, "How long is the book info? ");
   fgets(data, sizeof(data), stdin);
   size = strtoull(data, NULL, 10);
   book *temp = (book*)malloc(sizeof(book) + size);
   fprintf(stderr, "Enter new book (isbn,title,author,publisher,year)\n");
   fgets(temp->data, size, stdin);
   temp->next = temp->prev = NULL;
   book *n, *p = NULL;
   for (n = books; n; n = n->next) {
      if (strcmp(temp->data, n->data) <= 0) {
         temp->next = n;
         n->prev = temp;
         break;
      }
      p = n;
   }
   if (p == NULL) {
      books = temp;
   }
   else {
      p->next = temp;
      temp->prev = p;
   }
}

void edit() {
   char data[256];
   book *n;
   fprintf(stderr, "Enter isbn to edit\n");
   if (fgets(data, sizeof(data), stdin)) {
      char *lf = strchr(data, '\n');
      if (lf) {
         *lf = 0;
      }
      for (n = books; n; n = n->next) {
         if (strncmp(n->data, data, strlen(data)) == 0) {
            fprintf(stderr, "Enter new book info (isbn,title,author,publisher,year)\n");
            fgets(n->data, sizeof(data), stdin);
            break;
         }
      }
      if (n == NULL) {
         fprintf(stderr, "Failed to find book\n");
      }            
   }
}

void delete() {
   char data[256];
   book *n;
   fprintf(stderr, "Enter isbn to delete\n");
   if (fgets(data, sizeof(data), stdin)) {
      char *lf = strchr(data, '\n');
      if (lf) {
         *lf = 0;
      }
      for (n = books; n; n = n->next) {
         if (strncmp(n->data, data, strlen(data)) == 0) {
            if (n == books) {
               books = n->next;
               if (books) {
                  if (books->prev != n) {
                     fprintf(stderr, "Corruption detected, quitting\n");
                     exit(1);
                  }
                  books->prev = NULL;
               }
            }
            else {
               if (n->prev) {
                  if (n->prev->next != n) {
                     fprintf(stderr, "Corruption detected, quitting\n");
                     exit(1);
                  }
                  n->prev->next = n->next;
               }
               if (n->next) {
                  if (n->next->prev != n) {
                     fprintf(stderr, "Corruption detected, quitting\n");
                     exit(1);
                  }
                  n->next->prev = n->prev;
               }
            }
            free(n);
            break;
         }
      }
   }
}

void display() {
   book *n;
   for (n = books; n; n = n->next) {
      fprintf(stderr, "%s\n", n->data);
   }
}

void save() {
   char data[256];
   book *n;
   fprintf(stderr, "Enter save file name\n");
   if (fgets(data, sizeof(data), stdin)) {
      char *lf = strchr(data, '\n');
      if (lf) {
         *lf = 0;
      }
      FILE *of = fopen(data, "w");
      if (of) {
         for (n = books; n; n = n->next) {
            fprintf(of, "%s\n", n->data);
         }
         fclose(of);
      }
      else {
         fprintf(stderr, "Failed to open file %s\n", data);
      }
   }
}

void load() {
   char data[256];
   size_t sz;
   char *line;
   book *n, *temp, *p;
   fprintf(stderr, "Enter load file name\n");
   if (fgets(data, sizeof(data), stdin)) {
      char *lf = strchr(data, '\n');
      if (lf) {
         *lf = 0;
      }
      FILE *of = fopen(data, "r");
      if (of) {
         //free the old book list
         for (n = books; n; n = p) {
            p = n->next;
            free(n);
         }
         books = NULL;
         while (getline(&line, &sz, of) > 0) {
            temp = (book*)malloc(sizeof(book) + sz);
            strcpy(temp->data, line);
            free(line);
            temp->prev = NULL;
            temp->next = NULL;
            if (books == NULL) {
               books = n = temp;
            }
            else {
               n->next = temp;
               temp->prev = n;
               n = temp;
            }
            line = NULL;
            sz = 0;
         }
         fclose(of);
      }
      else {
         fprintf(stderr, "Failed to open file %s\n", data);
      }
   }
}

void _main() {
   char data[256];
   book *p, *n;
   book *temp;

   fprintf(stderr, "%s\n", WELCOME);
   
   while (1) {
      menu();
      if (fgets(data, sizeof(data), stdin) == 0) {
         break;
      }
      switch (*data) {
         case '7':
            exit(0);
            break;
         case '1': //add
            add();
            break;
         case '2': //replace / edit
            edit();
            break;
         case '3': //delete
            delete();
            break;
         case '4':  //list / print
            display();
            break;
         case '5': //save
            save();
            break;
         case '6': //load
            load();
            break;
      }
   }
   
   //lets free everything up
   for (n = books; n; n = p) {
      p = n->next;
      free(n);
   }
}

int main(int argc, char **argv) {
   setvbuf(stdin, NULL, _IONBF, 0);
   setvbuf(stdout, NULL, _IONBF, 0);
   setvbuf(stderr, NULL, _IONBF, 0);
   _main();
}
