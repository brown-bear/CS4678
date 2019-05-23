#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv, char **envp) {
   int opt;
   const char *exe = NULL;
   const char *host = NULL;
   struct sockaddr_in sa;
   int useenv = 0;
   char *endptr;
   
   memset(&sa, 0, sizeof(sa));
   sa.sin_family = AF_INET;
   while ((opt = getopt(argc, argv, "+eh:p:")) != -1) {
      switch (opt) {
         case 'e':
            useenv = 1;
            break;
         case 'h':
            if (inet_pton(AF_INET, optarg, &sa.sin_addr) != 1) {
               fprintf(stderr, "invalid ip address: %s\n", optarg);
               exit(1);
            }
            break;
         case 'p':
            sa.sin_port = htons(strtoul(optarg, &endptr, 10));
            if (endptr == optarg || *endptr != 0) {
               fprintf(stderr, "invalid port number: %s\n", optarg);
               exit(1);
            }
            break;
         default: 
            break;
      }
   }

   if (sa.sin_port == 0) {
      fprintf(stderr, "missing port number\n");
      exit(1);
   }
   if (argv[optind] == NULL) {
      fprintf(stderr, "missing executable name\n");
      exit(1);
   }
   
   signal(SIGCHLD, SIG_IGN);
   int ss = socket(AF_INET, SOCK_STREAM, 0);
   if (ss < 0) {
      perror("socket");
      exit(1);      
   }
   opt = 1;
   if (setsockopt(ss, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) != 0) {
      perror("setsockopt");
      exit(1);      
   }
   if (bind(ss, (struct sockaddr*)&sa, sizeof(sa)) != 0) {
      perror("bind");
      exit(1);      
   }
   if (listen(ss, 5) != 0) {
      perror("listen");
      exit(1);
   }
   while (1) {
      int client = accept(ss, NULL, NULL);
      if (client >= 0) {
         if (fork() == 0) {
            const char *env[] = {NULL};
            dup2(client, 2);
            dup2(client, 1);
            dup2(client, 0);
            close(ss);
            execve(argv[optind], (char * const*)&argv[optind], useenv ? envp : (char * const*)env);
            perror("execve");
            exit(1);
         }
         close(client);
      }
   }
}
