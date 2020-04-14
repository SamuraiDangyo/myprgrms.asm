# Use gcc do the linking
rm -f myprgrms myprgrms.o
nasm -f elf32 myprgrms.asm
gcc -m32 myprgrms.o -o myprgrms
./myprgrms
