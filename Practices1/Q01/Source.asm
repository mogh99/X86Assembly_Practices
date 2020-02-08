
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf_s: proc, scanf_s: proc, getchar: proc

.data
	enterMessage byte "Enter the three sides of a triangle in cm: ", 0
	outputMessage byte "The area of the triangle is %lf sqaure cm", 0

	error1 byte "Error: Invalid Input", 0
	error2 byte "Error: at least one of the inputs is <= 0", 0
	error3 byte "Error: The sides don't form a triangle", 0

	enterFormat byte "%lf",0
	printFormat byte "%lf",0

	two real8 2.0
	zero real8 0.0

.data?
	a real8 ?
	b real8 ?
	c real8 ?
	s real8 ?
	area real8 ?

	letterCheck byte ?

.code 
main proc
	
	push	rbp
	mov		rbp,	rsp
	sub		rsp,	32

	lea		rcx,	enterMessage
	call	printf_s

	lea		rdx,	a
	lea		rcx,	enterFormat
	call	scanf_s
	lea		rdx,	b
	lea		rcx,	enterFormat
	call	scanf_s
	lea		rdx,	c
	lea		rcx,	enterFormat
	call	scanf_s
	
	call	getchar
	mov		letterCheck, al
	
	cmp		letterCheck,	10
	jne		Lerror1
	
	movsd	xmm0,	zero
	movsd	xmm1,	a 
	movsd	xmm2,	b 
	movsd	xmm3,	c 

	comisd	xmm1,	xmm0
	jbe	Lerror2
	comisd	xmm2,	xmm0
	jbe Lerror2
	comisd	xmm3,	xmm0
	jbe	Lerror2

	addsd	xmm1,	xmm2 ;a+b
	addsd	xmm2,	xmm3 ;b+c
	addsd	xmm3,	a	 ;c+a

	comisd	xmm1,	c
	jbe	Lerror3
	comisd	xmm2,	a
	jbe	Lerror3
	comisd	xmm3,	b
	jbe Lerror3

	movsd	xmm0,	a
	addsd	xmm0,	b
	addsd	xmm0,	c
	divsd	xmm0,	two

	movsd	s,		xmm0
	
	subsd	xmm0,	a
	
	movsd	xmm1,	s
	subsd	xmm1,	b

	movsd	xmm2,	s
	subsd	xmm2,	c

	mulsd	xmm0,	xmm1
	mulsd	xmm0,	xmm2
	mulsd	xmm0,	s

	sqrtsd	xmm1,	xmm0

	movsd	area,	xmm1

	mov		rdx,	area
	lea		rcx,	outputMessage
	call	printf_s
	jmp EndProgramme

	Lerror1:
	lea		rcx,	error1
	call	printf_s
	jmp EndProgramme

	Lerror2:
	lea		rcx,	error2
	call	printf_s
	jmp		EndProgramme

	Lerror3:
	lea		rcx,	error3
	call	printf_s

	EndProgramme:

	add		rsp,	32
	mov		rsp,	rbp
	pop		rbp
	
	ret
main endp
END
