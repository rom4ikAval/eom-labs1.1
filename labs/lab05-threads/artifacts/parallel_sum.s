	.file	"parallel_sum.c"
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
	.globl	calculate_sum
	.type	calculate_sum, @function
calculate_sum:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -40(%rbp)
	movq	-40(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	$0, -24(%rbp)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	jmp	.L5
.L6:
	movq	-16(%rbp), %rax
	addq	%rax, -24(%rbp)
	addq	$1, -16(%rbp)
.L5:
	movq	-8(%rbp), %rax
	movq	8(%rax), %rax
	cmpq	%rax, -16(%rbp)
	jle	.L6
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rdx
	movq	%rdx, 16(%rax)
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	calculate_sum, .-calculate_sum
	.section	.rodata
	.align 8
.LC1:
	.string	"pthread_create(&threads[i], NULL, calculate_sum, &tasks[i])"
	.align 8
.LC2:
	.string	"pthread_join(threads[i], NULL)"
	.align 8
.LC3:
	.string	"Thread %d: [%lld..%lld] sum=%lld\n"
.LC4:
	.string	"YES"
.LC5:
	.string	"NO"
	.align 8
.LC6:
	.string	"Parallel result: %lld\nExpected result: %lld\nCorrect: %s\n"
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
	subq	$176, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -168(%rbp)
	jmp	.L9
.L10:
	movl	-168(%rbp), %eax
	cltq
	imulq	$250000, %rax, %rax
	leaq	1(%rax), %rcx
	movl	-168(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$112, %rax
	movq	%rcx, (%rax)
	movl	-168(%rbp), %eax
	addl	$1, %eax
	cltq
	imulq	$250000, %rax, %rcx
	movl	-168(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$104, %rax
	movq	%rcx, (%rax)
	movl	-168(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$96, %rax
	movq	$0, (%rax)
	leaq	-112(%rbp), %rcx
	movl	-168(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	(%rcx,%rax), %rdx
	leaq	-144(%rbp), %rax
	movl	-168(%rbp), %ecx
	movslq	%ecx, %rcx
	salq	$3, %rcx
	addq	%rcx, %rax
	movq	%rdx, %rcx
	leaq	calculate_sum(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, %edx
	leaq	.LC1(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -168(%rbp)
.L9:
	cmpl	$3, -168(%rbp)
	jle	.L10
	movq	$0, -160(%rbp)
	movl	$0, -164(%rbp)
	jmp	.L11
.L12:
	movl	-164(%rbp), %eax
	cltq
	movq	-144(%rbp,%rax,8), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	movl	-164(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$96, %rax
	movq	(%rax), %rdi
	movl	-164(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$104, %rax
	movq	(%rax), %rcx
	movl	-164(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$112, %rax
	movq	(%rax), %rax
	movl	-164(%rbp), %edx
	leal	1(%rdx), %esi
	movq	%rdi, %r8
	movq	%rax, %rdx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-164(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rbp, %rax
	subq	$96, %rax
	movq	(%rax), %rax
	addq	%rax, -160(%rbp)
	addl	$1, -164(%rbp)
.L11:
	cmpl	$3, -164(%rbp)
	jle	.L12
	movabsq	$500000500000, %rax
	movq	%rax, -152(%rbp)
	movq	-160(%rbp), %rax
	cmpq	-152(%rbp), %rax
	jne	.L13
	leaq	.LC4(%rip), %rax
	jmp	.L14
.L13:
	leaq	.LC5(%rip), %rax
.L14:
	movq	-152(%rbp), %rdx
	movq	-160(%rbp), %rsi
	movq	%rax, %rcx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-160(%rbp), %rax
	cmpq	-152(%rbp), %rax
	setne	%al
	movzbl	%al, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L16
	call	__stack_chk_fail@PLT
.L16:
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
