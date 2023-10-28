
.option norvc

.section .data

_loading:      .ascii "Booting on hart % ...\n\0"
_active_heart: .ascii "Active core : % \n\0"
_mode_message: .ascii "Now running in % mode\n\0"
_exception   : .ascii "Exception % found\n\0"
_stack:
   .skip 4096*4

_lock:
   .skip 256,0

.section .bss

.section .text.init

.global _start
_start:
   la t0,_exception_handler
   csrw mepc,t0
   #Initialise stack for each harts
   la t0,_stack       #load stack start address
   csrr t1,mhartid    #Read hart id
   addi a0,t1,1       
   la t2,4096         
   mul t2,a0,t2   
   add sp,t0,t2       #laod sp with stack address per hart
   #select hart0 and put make other harts wait
   bne t1,zero, _halt   
   #display selected core boot message
   addi a1,tp,0x30
   la a0,_loading
   call _printline
   csrr a1,mstatus
   li t0,0x1800
   and a1,a1,t0
   addi a1,a1,0x30
   la a0,_mode_message
   call _printline
   #disable paging
   csrw satp,x0
   #configure pmp to allow access to all regions
   li t0,0x7fffffffffffffff
   csrw pmpcfg0,t0
   csrw pmpaddr0,t0
   
   
   
   



_idle:
   call _sched
   wfi
   j _idle

_halt:
   call _sched
    wfi
    j _halt


.macro push
   addi sp,sp,-64
   sd ra,56(sp)
.endm
.macro pop
   ld ra,56(sp)
   addi sp,sp,64
.endm
.macro wruart
    li t3,0x10000000
    sb t2,0(t3) 
.endm

_check_privilage:
   push
   csrr t0,mstatus
   #sll t0,51
   #srl t0,11

   pop

_sched:
   push
_locked:
   csrr t0,mhartid
   la t1,_lock
   ld t1,0(t1)
   bne t0,t1,_locked
   la a0,_active_heart
   addi a1,t0,0x30
   sd t0,40(sp)
   call _printline
   ld t0,40(sp)
   li a2,3
   beq t0,a2,_last_core
   addi t0,t0,1
   j _sched_continue
_last_core:
   li t0,0
   la a0,_active_heart
_sched_continue:
   la t1,_lock
   sd t0,0(t1)
   pop
   ret


_exception_handler:

mret

_test:
   push
   sd a0,48(sp)
   li t1,8
_test_start:
   addi t1,t1,-1
   ld a0,48(sp)
   call _printline
   #addi t2,t1,0x30
   #wruart
   bne t1,x0,_test_start

_test_end:
   pop
   ret


_printline:
   push
   li t3,0x10000000
_printline_start:
   lb t2,0(a0)
   sd t3,48(sp)
   beq t2,x0,_printline_end
   ld t3,48(sp)
   li s0,0x25
   beq t2,s0,_insert_char
   sb t2,0(t3)
   j _print_continue
_insert_char:
   sb a1,0(t3) 
_print_continue:
   addi a0,a0,1
   j _printline_start
_printline_end:
   pop
   ret
   

