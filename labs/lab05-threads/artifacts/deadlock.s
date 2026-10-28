	.file	"deadlock.c"
	.text
	.section	.rodata
.LC0:
	.string	"%s: %s\n"
	.text
	.type	check_thread, @function
check_thread:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	cmpl	$0, -4(%rbp)
	je	.L3
	movl	-4(%rbp), %eax
	movl	%eax, %edi
	call	strerror@PLT
	movq	%rax, %rcx
	movq	stderr(%rip), %rax
	movq	-16(%rbp), %rdx
	leaq	.LC0(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$1, %edi
	call	exit@PLT
.L3:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	check_thread, .-check_thread
	.globl	mutex1
	.bss
	.align 32
	.type	mutex1, @object
	.size	mutex1, 40
mutex1:
	.zero	40
	.globl	mutex2
	.align 32
	.type	mutex2, @object
	.size	mutex2, 40
mutex2:
	.zero	40
	.section	.rodata
.LC1:
	.string	"Thread 1: locking mutex1"
.LC2:
	.string	"pthread_mutex_lock(&mutex1)"
.LC3:
	.string	"Thread 1: acquired mutex1"
.LC4:
	.string	"Thread 1: locking mutex2"
.LC5:
	.string	"pthread_mutex_lock(&mutex2)"
.LC6:
	.string	"Thread 1: critical section"
.LC7:
	.string	"pthread_mutex_unlock(&mutex2)"
.LC8:
	.string	"pthread_mutex_unlock(&mutex1)"
	.text
	.globl	worker1
	.type	worker1, @function
worker1:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex1(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$1, %edi
	call	sleep@PLT
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex2(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movl	%eax, %edx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex2(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	%eax, %edx
	leaq	.LC7(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	mutex1(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	%eax, %edx
	leaq	.LC8(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	worker1, .-worker1
	.section	.rodata
.LC9:
	.string	"Thread 2: locking mutex2"
.LC10:
	.string	"Thread 2: acquired mutex2"
.LC11:
	.string	"Thread 2: locking mutex1"
.LC12:
	.string	"Thread 2: critical section"
	.text
	.globl	worker2
	.type	worker2, @function
worker2:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	leaq	.LC9(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex2(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movl	%eax, %edx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	.LC10(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$1, %edi
	call	sleep@PLT
	leaq	.LC11(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex1(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	.LC12(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	leaq	mutex1(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	%eax, %edx
	leaq	.LC8(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	mutex2(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	%eax, %edx
	leaq	.LC7(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	worker2, .-worker2
	.section	.rodata
	.align 8
.LC13:
	.string	"pthread_create(&thread1, NULL, worker1, NULL)"
	.align 8
.LC14:
	.string	"pthread_create(&thread2, NULL, worker2, NULL)"
.LC15:
	.string	"pthread_join(thread1, NULL)"
.LC16:
	.string	"pthread_join(thread2, NULL)"
	.align 8
.LC17:
	.string	"pthread_mutex_destroy(&mutex1)"
	.align 8
.LC18:
	.string	"pthread_mutex_destroy(&mutex2)"
.LC19:
	.string	"Main: both workers finished"
	.text
	.globl	main
	.type	main, @function
main:
.LFB3:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	stdout(%rip), %rax
	movl	$0, %ecx
	movl	$2, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	setvbuf@PLT
	leaq	-24(%rbp), %rax
	movl	$0, %ecx
	leaq	worker1(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, %edx
	leaq	.LC13(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	-16(%rbp), %rax
	movl	$0, %ecx
	leaq	worker2(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, %edx
	leaq	.LC14(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movq	-24(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	movl	%eax, %edx
	leaq	.LC15(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movq	-16(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	movl	%eax, %edx
	leaq	.LC16(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	mutex1(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_destroy@PLT
	movl	%eax, %edx
	leaq	.LC17(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	mutex2(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_destroy@PLT
	movl	%eax, %edx
	leaq	.LC18(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	leaq	.LC19(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L10
	call	__stack_chk_fail@PLT
.L10:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
