; myprgrms.asm, programs written in Assembly
; (C) 2020 Toni Helminen <GPLv3>
; %s/\s\+$//e

;;;

; Helper functions
extern printf
extern scanf

;;;

KERNEL:  equ 80h
SYSEXIT: equ 1h

;;;

section .data
  format0:      db "# Salvete, omnes!", 0Ah, "=================", 0Ah, "(1): Factorial ?", 0Ah, "(2): Fibonacci ?", 0Ah, 0
  format1:      db "Enter a number: ", 0
  format2:      db "=================", 0Ah, "%d! = %d", 0Ah, 0
  format3:      db "Enter a program: ", 0
  format4:      db "=================", 0Ah, "F(%d) = %d", 0Ah, 0
  badInputMsg:  db "Bad input :(", 0Ah, 0
  goodbyeMsg:   db "Goodbye !", 0Ah, 0
  formatIn:     db "%d", 0

  fiboNum:      times 4 db 0
  programNum:   times 4 db 0
  inputNum:     times 4 db 0
  factorialNum: times 4 db 0

section .text
  global main

;;;

nthFactorial:
  push      eax
  push      ebx
  push      ecx
  push      edx

  mov       eax, 1
  mov       ebx, 0
  mov       ecx, 0
  mov       edx, 0

.nextNumber:
  cmp       ecx, dword [inputNum]
  jge       .finished
  inc       ecx
  mov       ebx, ecx
  mul       ebx
  jmp       .nextNumber

.finished:
  mov       dword [factorialNum], eax

  pop       edx
  pop       ecx
  pop       ebx
  pop       eax

  ret

;;;

initialize:
  mov       eax, 0
  mov       ebx, 0
  mov       ecx, 0
  mov       edx, 0
  ret

;;;

calculateFactorial:
  call      initialize

  push      esp

  push      format1
  call      printf
  add esp,  1 * 4

  push      dword inputNum
  push      dword formatIn
  call      scanf
  add esp,  2 * 4

  call      goodFactorialInput
  call      nthFactorial

  push      dword [factorialNum]
  push      dword [inputNum]
  push      dword format2
  call      printf

  add       esp,  4 * 4 ; clean up the stack

  ret

;;;

nthFibonacci:
  push      eax
  push      ebx
  push      ecx
  push      edx

  mov       eax, 0
  mov       ebx, 1
  mov       ecx, 0
  mov       edx, 1

.nextNumber:
  inc       ecx
  cmp       ecx, dword [inputNum]
  jge       .finished

  push      ecx
  mov       ecx, edx
  add       edx, ebx
  mov       ebx, ecx
  pop       ecx
  push      eax
  push      ebx
  push      ecx
  push      edx
  mov       eax, edx
  mov       edx, 0
  mov       ebx, 2
  div       ebx
  cmp       edx, 0
  jne       .L1
  pop       edx
  pop       ecx
  pop       ebx
  pop       eax
  add       eax, edx
  jmp       .nextNumber

.L1:
  pop       edx
  pop       ecx
  pop       ebx
  pop       eax
  jmp       .nextNumber

.finished:
  mov       dword [fiboNum], edx
  pop       edx
  pop       ecx
  pop       ebx
  pop       eax
  ret

;;;

initRegisters:
  mov       eax, 0
  mov       ebx, 0
  mov       ecx, 0
  mov       edx, 0
  ret

;;;

fiboRoutine:
  call      initRegisters

  push      format1
  call      printf
  add       esp, 4

  push      inputNum
  push      formatIn
  call      scanf
  add       esp, 8

  mov       eax, dword [inputNum]
  mov       ebx, dword [inputNum]
  mul       eax

  call      goodFactorialInput
  call      nthFibonacci

  push      dword [fiboNum]
  push      dword [inputNum]
  push      format4
  call      printf
  add       esp, 12

  ret

;;;

goodFibonacciInput:
  mov       eax, 47
  cmp       dword [inputNum], eax
  jg        badInput

  mov       eax, 0
  cmp       dword [inputNum], eax
  jl        badInput

  ret

;;;

goodFactorialInput:
  mov       eax, 15
  cmp       dword [inputNum], eax
  jg        badInput

  mov       eax, 0
  cmp       dword [inputNum], eax
  jl        badInput

  ret

;;;

badInput:
  push      badInputMsg
  call      printf
  add       esp,  1 * 4
  jmp       quit

;;;

program:
  push esp

  push      format0
  call      printf
  add       esp, 1 * 4

  push      format3
  call      printf
  add       esp, 1 * 4

  push      dword programNum
  push      dword formatIn
  call      scanf
  add       esp, 2 * 4

  mov       eax, 1
  cmp       eax, dword [programNum]
  je        .L1

  mov       eax, 2
  cmp       eax, dword [programNum]
  je        .L2

  jmp       .L3

.L1:
  call calculateFactorial
  jmp       .OUT

.L2:
  call fiboRoutine
  jmp       .OUT

.L3:
  push      goodbyeMsg
  call      printf
  add       esp, 1 * 4

.OUT:
  add       esp, 1 * 4
  ret

;;;

quit:
  mov       ebx, 0
  mov       eax, SYSEXIT
  int       KERNEL
  ret

;;;

; "Vincit qui se vincit."
main:
  call      initRegisters
  call      program
  call      quit
  ret
