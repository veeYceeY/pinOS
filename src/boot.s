
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
   ecall
   
   
   



_idle:
   call _sched
   wfi
   j _idle

_halt:
   call _sched
    wfi
    j _halt


.macro push rname
   addi sp,sp,-8
   sd \rname,0(sp)
.endm
.macro pop rname
   ld \rname,0(sp)
   addi sp,sp,8
.endm
.macro wruart
    li t3,0x10000000
    sb t2,0(t3) 
.endm

_check_privilage:
   push ra
   csrr t0,mstatus
   #sll t0,51
   #srl t0,11

   pop ra

_sched:
   push ra
_locked:
   csrr t0,mhartid
   la t1,_lock
   ld t1,0(t1)
   bne t0,t1,_locked
   la a0,_active_heart
   addi a1,t0,0x30
   #sd t0,40(sp)
   push t0
   call _printline
   pop t0
   #ld t0,40(sp)
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
   pop ra
   ret


_exception_handler:
   push ra
   push gp
   push tp
   push t0
   push t1
   push t2
   push fp
   push s1
   push a0
   push a1
   push a2
   push a3
   push a4
   push a5
   push a6
   push a7
   push s2
   push s3
   push s4
   push s5
   push s6
   push s7
   push s8
   push s9
   push s10
   push s11
   push t3
   push t4
   push t5
   push t6

   



   pop ra
   pop gp
   pop tp
   pop t0
   pop t1
   pop t2
   pop fp
   pop s1
   pop a0
   pop a1
   pop a2
   pop a3
   pop a4
   pop a5
   pop a6
   pop a7
   pop s2
   pop s3
   pop s4
   pop s5
   pop s6
   pop s7
   pop s8
   pop s9
   pop s10
   pop s11
   pop t3
   pop t4
   pop t5
   pop t6
mret

_test:
   push ra
   #sd a0,48(sp)
   #push a0
   li t1,8
_test_start:
   addi t1,t1,-1
   #ld a0,48(sp)
   push a0
   call _printline
   pop a0
   #addi t2,t1,0x30
   #wruart
   bne t1,x0,_test_start

_test_end:
   pop ra
   ret


_printline:
   push ra
   li t3,0x10000000
_printline_start:
   lb t2,0(a0)
   #sd t3,48(sp)
   beq t2,x0,_printline_end
   #ld t3,48(sp)
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
   pop ra
   ret
   

