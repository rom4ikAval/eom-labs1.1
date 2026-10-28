	.file	"shared_data.c"
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
	.globl	value
	.bss
	.align 4
	.type	value, @object
	.size	value, 4
value:
	.zero	4
	.section	.rodata
	.align 8
.LC1:
	.string	"Thread %d: value=%d, address=%p\n"
	.text
	.globl	worker
	.type	worker, @function
worker:
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
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	imull	$100, %eax, %eax
	movl	%eax, value(%rip)
	movl	value(%rip), %edx
	movl	-4(%rbp), %eax
	leaq	value(%rip), %rcx
	movl	%eax, %esi
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	worker, .-worker
	.section	.rodata
	.align 8
.LC2:
	.string	"pthread_create(&threads[i], NULL, worker, &ids[i])"
	.align 8
.LC3:
	.string	"pthread_join(threads[i], NULL)"
.LC4:
	.string	"Main: value=%d, address=%p\n"
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
	subq	$48, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -48(%rbp)
	jmp	.L7
.L8:
	movl	-48(%rbp), %eax
	leal	1(%rax), %edx
	movl	-48(%rbp), %eax
	cltq
	movl	%edx, -40(%rbp,%rax,4)
	leaq	-40(%rbp), %rax
	movl	-48(%rbp), %edx
	movslq	%edx, %rdx
	salq	$2, %rdx
	addq	%rax, %rdx
	leaq	-32(%rbp), %rax
	movl	-48(%rbp), %ecx
	movslq	%ecx, %rcx
	salq	$3, %rcx
	addq	%rcx, %rax
	movq	%rdx, %rcx
	leaq	worker(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -48(%rbp)
.L7:
	cmpl	$1, -48(%rbp)
	jle	.L8
	movl	$0, -44(%rbp)
	jmp	.L9
.L10:
	movl	-44(%rbp), %eax
	cltq
	movq	-32(%rbp,%rax,8), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	movl	%eax, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rsi
	movl	%edx, %edi
	call	check_thread
	addl	$1, -44(%rbp)
.L9:
	cmpl	$1, -44(%rbp)
	jle	.L10
	movl	value(%rip), %eax
	leaq	value(%rip), %rdx
	movl	%eax, %esi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L12
	call	__stack_chk_fail@PLT
.L12:
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
