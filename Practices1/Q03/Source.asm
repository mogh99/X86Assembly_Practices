
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf_s: proc, scanf_s: proc, getchar: proc

.data
	enterMessage byte "Enter the number of values to consider:", 13, 10, 0
	enterValues byte "Enter a values:", 0

	inputNFormat byte "%lf", 0
	inputFormat byte "%lf", 0

	;message for smallest value
	message1 byte "The samllest value is %lf", 13, 10, 0
	message2 byte "The frequency of the smallest value is %d", 13, 10, 0
	
	;message for negative value
	message3 byte "The average of negative values is %lf", 0
	message4 byte "No negative values entered",0

	error1	byte "Error: Invalid Input.", 0

	zero real8 0.0
	one real8 1.0

	frequency qword 1
	numberOfnegative real8 0.0
.data?
	N real8 ?

	smallest real8 ?
	nValues real8 ?

	averageN real8 ?

	letterCheck	byte ?

.code
main proc

	push	rbp
	mov		rbp,	rsp
	sub		rsp,	32

	lea		rcx,	enterMessage
	call	printf_s

	lea		rdx,	N
	lea		rcx,	inputNFormat
	call	scanf_s

	call	getchar
	mov		letterCheck, al

	cmp		letterCheck, 10
	jne	Lerror1

	movsd	xmm0,	N
	comisd	xmm0,	zero
	jbe		Lerror1

	movsd	xmm0,	N
	subsd	xmm0,	one
	movsd	N,	xmm0

	lea		rcx,	enterValues
	call	printf_s

	lea		rdx,	nValues
	lea		rcx,	inputFormat
	call	scanf_s

	movsd	xmm0,	nValues
	movsd	smallest,	xmm0

	comisd	xmm0,	zero
	jb	firstNegative
	jmp	Loop1

	firstNegative:
	addsd	xmm2,	one
	movsd	numberOfNegative, xmm2
	movsd	averageN,	xmm0

	Loop1:
		
		movsd	xmm0,	N
		subsd	xmm0,	one
		movsd	N,	xmm0
		lea		rcx,	enterValues
		call	printf_s
		lea		rdx,	nValues
		lea		rcx,	inputFormat
		call	scanf_s
		
		movsd	xmm0,	nValues

		comisd	xmm0,	zero
		jb	negativeNumber
		check1:
		comisd	xmm0,	smallest
		je	incFrequency
		check2:
		comisd	xmm0,	smallest
		jb	newSmallest
		check3:
	
	movsd	xmm0,	N
	comisd	xmm0,	zero
	ja	Loop1
	
	mov		rdx,	smallest
	lea		rcx,	message1
	call	printf_s

	mov		rdx,	frequency
	lea		rcx,	message2
	call	printf_s
	
	cmp		numberOfNegative,	0
	ja		displayAverage

	lea		rcx,	message4
	call	printf_s

	jmp endProgram

	negativeNumber:
	movsd	xmm1,	xmm0
	addsd	xmm1,	averageN
	movsd	averageN,	xmm1
	movsd	xmm2,	numberOfNegative
	addsd	xmm2,	one
	movsd	numberOfNegative, xmm2
	jmp	check1

	incFrequency:
	inc	Frequency
	jmp check2

	newSmallest:
	movsd	smallest,	xmm0
	mov		frequency,	1
	jmp check3

	displayAverage:
	movsd	xmm0,	averageN
	movsd	xmm1,	numberOfnegative
	divsd	xmm0,	xmm1
	movsd	averageN,	xmm0
	mov		rdx,	averageN
	lea		rcx,	message3
	call	printf_s
	jmp	endprogram

	Lerror1:
	lea		rcx,	error1
	call	printf_s

	endProgram:

	add		rsp,	32
	mov		rsp,	rbp
	pop		rbp

main endp
END