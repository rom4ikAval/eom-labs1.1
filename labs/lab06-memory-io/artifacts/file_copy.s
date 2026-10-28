	.file	"file_copy.c"
	.text
	.type	read_retry, @function
read_retry:
.LFB0:
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
.L3:
	movq	-40(%rbp), %rdx
	movq	-32(%rbp), %rcx
	movl	-20(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read@PLT
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jns	.L2
	call	__errno_location@PLT
	movl	(%rax), %eax
	cmpl	$4, %eax
	je	.L3
.L2:
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	read_retry, .-read_retry
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
	jmp	.L6
.L12:
	movq	-40(%rbp), %rdx
	movq	-16(%rbp), %rcx
	movl	-20(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write@PLT
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jns	.L7
	call	__errno_location@PLT
	movl	(%rax), %eax
	cmpl	$4, %eax
	je	.L13
	movl	$-1, %eax
	jmp	.L10
.L7:
	cmpq	$0, -8(%rbp)
	jne	.L11
	call	__errno_location@PLT
	movl	$5, (%rax)
	movl	$-1, %eax
	jmp	.L10
.L11:
	movq	-8(%rbp), %rax
	addq	%rax, -16(%rbp)
	movq	-8(%rbp), %rax
	subq	%rax, -40(%rbp)
	jmp	.L6
.L13:
	nop
.L6:
	cmpq	$0, -40(%rbp)
	jne	.L12
	movl	$0, %eax
.L10:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	write_all, .-write_all
	.section	.rodata
.LC0:
	.string	"close"
	.text
	.type	finish, @function
finish:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, %edi
	call	close@PLT
	cmpl	$-1, %eax
	jne	.L15
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$1, %eax
	jmp	.L16
.L15:
	movl	-8(%rbp), %eax
.L16:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	finish, .-finish
	.section	.rodata
	.align 8
.LC1:
	.string	"Usage: %s <source> <destination>\n"
.LC2:
	.string	"open source"
.LC3:
	.string	"open destination"
.LC4:
	.string	"fstat"
	.align 8
.LC5:
	.string	"Source and destination are the same file\n"
.LC6:
	.string	"ftruncate"
.LC7:
	.string	"write"
.LC8:
	.string	"read"
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
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$352, %rsp
	movl	%edi, -4436(%rbp)
	movq	%rsi, -4448(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	cmpl	$3, -4436(%rbp)
	je	.L18
	movq	-4448(%rbp), %rax
	movq	(%rax), %rdx
	movq	stderr(%rip), %rax
	leaq	.LC1(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$1, %eax
	jmp	.L30
.L18:
	movq	-4448(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open@PLT
	movl	%eax, -4416(%rbp)
	cmpl	$0, -4416(%rbp)
	jns	.L20
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	$1, %eax
	jmp	.L30
.L20:
	movq	-4448(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	movl	$420, %edx
	movl	$65, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open@PLT
	movl	%eax, -4412(%rbp)
	cmpl	$0, -4412(%rbp)
	jns	.L21
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	movl	-4416(%rbp), %eax
	movl	$1, %esi
	movl	%eax, %edi
	call	finish
	jmp	.L30
.L21:
	movl	$1, -4420(%rbp)
	leaq	-4400(%rbp), %rdx
	movl	-4416(%rbp), %eax
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	fstat@PLT
	testl	%eax, %eax
	js	.L22
	leaq	-4256(%rbp), %rdx
	movl	-4412(%rbp), %eax
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	fstat@PLT
	testl	%eax, %eax
	jns	.L23
.L22:
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	jmp	.L24
.L23:
	movq	-4400(%rbp), %rdx
	movq	-4256(%rbp), %rax
	cmpq	%rax, %rdx
	jne	.L25
	movq	-4392(%rbp), %rdx
	movq	-4248(%rbp), %rax
	cmpq	%rax, %rdx
	jne	.L25
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$41, %edx
	movl	$1, %esi
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	call	fwrite@PLT
	jmp	.L24
.L25:
	movl	-4232(%rbp), %eax
	andl	$61440, %eax
	cmpl	$32768, %eax
	jne	.L27
	movl	-4412(%rbp), %eax
	movl	$0, %esi
	movl	%eax, %edi
	call	ftruncate@PLT
	testl	%eax, %eax
	jns	.L27
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	jmp	.L24
.L28:
	movq	-4408(%rbp), %rdx
	leaq	-4112(%rbp), %rcx
	movl	-4412(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write_all
	testl	%eax, %eax
	jns	.L27
	leaq	.LC7(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	jmp	.L24
.L27:
	leaq	-4112(%rbp), %rcx
	movl	-4416(%rbp), %eax
	movl	$4096, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read_retry
	movq	%rax, -4408(%rbp)
	cmpq	$0, -4408(%rbp)
	jg	.L28
	cmpq	$0, -4408(%rbp)
	jns	.L29
	leaq	.LC8(%rip), %rax
	movq	%rax, %rdi
	call	perror@PLT
	jmp	.L24
.L29:
	movl	$0, -4420(%rbp)
.L24:
	movl	-4420(%rbp), %edx
	movl	-4412(%rbp), %eax
	movl	%edx, %esi
	movl	%eax, %edi
	call	finish
	movl	%eax, -4420(%rbp)
	movl	-4420(%rbp), %edx
	movl	-4416(%rbp), %eax
	movl	%edx, %esi
	movl	%eax, %edi
	call	finish
.L30:
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L31
	call	__stack_chk_fail@PLT
.L31:
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
