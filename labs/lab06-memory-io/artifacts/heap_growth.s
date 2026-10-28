	.file	"heap_growth.c"
	.text
	.section	.rodata
.LC0:
	.string	"Expected Enter on stdin\n"
	.text
	.type	pause_input, @function
pause_input:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	call	getchar@PLT
	cmpl	$-1, %eax
	jne	.L2
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$24, %edx
	movl	$1, %esi
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	call	fwrite@PLT
	movl	$-1, %eax
	jmp	.L3
.L2:
	movl	$0, %eax
.L3:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	pause_input, .-pause_input
	.section	.rodata
.LC1:
	.string	"malloc"
	.align 8
.LC2:
	.string	"PID: %ld\nAllocated: %zu bytes\nAddress: %p\nPage size: %ld\n"
.LC3:
	.string	"BEFORE_TOUCH: press Enter"
.LC4:
	.string	"AFTER_TOUCH: press Enter"
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
	subq	$48, %rsp
	movq	$104857600, -24(%rbp)
	movl	$30, %edi
	call	sysconf@PLT
	movq	%rax, -16(%rbp)
	cmpq	$0, -16(%rbp)
	jg	.L5
	movl	$1, %eax
	jmp	.L6
.L5:
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L7
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$1, %eax
	jmp	.L6
.L7:
	call	getpid@PLT
	cltq
	movq	-16(%rbp), %rsi
	movq	-8(%rbp), %rcx
	movq	-24(%rbp), %rdx
	movq	%rsi, %r8
	movq	%rax, %rsi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	call	pause_input
	testl	%eax, %eax
	jns	.L8
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	$1, %eax
	jmp	.L6
.L8:
	movq	$0, -32(%rbp)
	jmp	.L9
.L10:
	movq	-8(%rbp), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	movq	-16(%rbp), %rax
	addq	%rax, -32(%rbp)
.L9:
	movq	-32(%rbp), %rax
	cmpq	-24(%rbp), %rax
	jb	.L10
	movq	-24(%rbp), %rax
	leaq	-1(%rax), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	call	pause_input
	testl	%eax, %eax
	setne	%al
	movzbl	%al, %eax
	movl	%eax, -36(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	-36(%rbp), %eax
.L6:
	leave
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
