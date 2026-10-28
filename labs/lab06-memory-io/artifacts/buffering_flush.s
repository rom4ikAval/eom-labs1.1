	.file	"buffering_flush.c"
	.text
	.type	write_all, @function
write_all:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, -16(%rbp)
	jmp	.L2
.L8:
	movq	-40(%rbp), %rdx
	movq	-16(%rbp), %rcx
	movl	-20(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write@PLT
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jns	.L3
	call	__errno_location@PLT
	movl	(%rax), %eax
	cmpl	$4, %eax
	je	.L9
	movl	$-1, %eax
	jmp	.L6
.L3:
	cmpq	$0, -8(%rbp)
	jne	.L7
	call	__errno_location@PLT
	movl	$5, (%rax)
	movl	$-1, %eax
	jmp	.L6
.L7:
	movq	-8(%rbp), %rax
	addq	%rax, -16(%rbp)
	movq	-8(%rbp), %rax
	subq	%rax, -40(%rbp)
	jmp	.L2
.L9:
	nop
.L2:
	cmpq	$0, -40(%rbp)
	jne	.L8
	movl	$0, %eax
.L6:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	write_all, .-write_all
	.section	.rodata
.LC0:
	.string	"A"
.LC1:
	.string	"B"
.LC2:
	.string	"C"
.LC3:
	.string	"fflush"
.LC4:
	.string	"D"
.LC5:
	.string	"write"
	.text
	.globl	main
	.type	main, @function
main:
.LFB4:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	testl	%eax, %eax
	js	.L11
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	testl	%eax, %eax
	js	.L11
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	testl	%eax, %eax
	jns	.L12
.L11:
	movl	$1, %eax
	jmp	.L13
.L12:
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	cmpl	$-1, %eax
	jne	.L14
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$1, %eax
	jmp	.L13
.L14:
	movl	$1, %edx
	leaq	.LC4(%rip), %rax
	movq	%rax, %rsi
	movl	$1, %edi
	call	write_all
	testl	%eax, %eax
	jns	.L15
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$1, %eax
	jmp	.L13
.L15:
	movl	$0, %eax
.L13:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
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
