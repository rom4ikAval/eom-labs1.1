	.file	"mutex_four.c"
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
	.globl	counter
	.bss
	.align 8
	.type	counter, @object
	.size	counter, 8
counter:
	.zero	8
	.globl	mutex
	.align 32
	.type	mutex, @object
	.size	mutex, 40
mutex:
	.zero	40
	.section	.rodata
.LC1:
	.string	"pthread_mutex_lock(&mutex)"
.LC2:
	.string	"pthread_mutex_unlock(&mutex)"
	.text
	.globl	increment
	.type	increment, @function
increment:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L5
.L6:
	leaq	mutex(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movl	%eax, %edx
	leaq	.LC1(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movq	counter(%rip), %rax
	addq	$1, %rax
	movq	%rax, counter(%rip)
	leaq	mutex(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -4(%rbp)
.L5:
	cmpl	$499999, -4(%rbp)
	jle	.L6
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	increment, .-increment
	.section	.rodata
	.align 8
.LC3:
	.string	"pthread_create(&threads[i], NULL, increment, NULL)"
	.align 8
.LC4:
	.string	"pthread_join(threads[i], NULL)"
	.align 8
.LC5:
	.string	"Threads=%d Iterations=%d Expected=%ld Actual=%ld\n"
.LC6:
	.string	"pthread_mutex_destroy(&mutex)"
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -56(%rbp)
	jmp	.L9
.L10:
	leaq	-48(%rbp), %rax
	movl	-56(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movl	$0, %ecx
	leaq	increment(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -56(%rbp)
.L9:
	cmpl	$3, -56(%rbp)
	jle	.L10
	movl	$0, -52(%rbp)
	jmp	.L11
.L12:
	movl	-52(%rbp), %eax
	cltq
	movq	-48(%rbp,%rax,8), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	movl	%eax, %edx
	leaq	.LC4(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -52(%rbp)
.L11:
	cmpl	$3, -52(%rbp)
	jle	.L12
	movq	counter(%rip), %rax
	movq	%rax, %r8
	movl	$2000000, %ecx
	movl	$500000, %edx
	movl	$4, %esi
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	mutex(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_destroy@PLT
	movl	%eax, %edx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L14
	call	__stack_chk_fail@PLT
.L14:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
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
