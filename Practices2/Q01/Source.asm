
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf_s: proc, scanf_s: proc, getchar: proc


.data
	enterMessage byte "Enter the number of hours and minutes [integers]:", 0
	errorMessage byte "Error: Invalid Input!", 0

	inputFormat byte "%lld", 0

	resultMessage1 byte "The charge for %d hours", 0
	resultMessage2 byte " and %d minutes is", 0
	resultMessage3 byte " %.2lf Saudi Riyals", 0
	riyalPerHour real8 5.5
	zero real8 0.0

.data?
	hours sqword ?
	minutes sqword ?
	result real8 ?

.code
main proc
	push	rbp
	mov		rbp,	rsp
	sub		rsp,	32

	lea		rcx,	enterMessage
	call	printf_s

	lea		rdx,	hours
	lea		rcx,	inputFormat
	call	scanf_s

	lea		rdx,	minutes
	lea		rcx,	inputFormat
	call	scanf_s

	call	getchar
	cmp		al,		10
	jne		Lerror
	cmp		minutes,	60
	jge		Lerror
	cmp		minutes,	0
	jl		Lerror
	cmp		hours,	0
	jl		Lerror

	lea		rcx,	hours
	lea		rdx,	minutes
	call	computeCharge
	
	lea		rcx,	resultMessage1
	mov		rdx,	hours
	call	printf_s

	lea		rcx,	resultMessage2
	mov		rdx,	minutes
	call	printf_s

	lea		rcx,	resultMessage3
	mov	    rdx,	result
	call	printf_s
	
	jmp		Lend
	Lerror:
	lea		rcx,	errorMessage
	call	printf_s

	Lend:

	add		rsp,	32
	mov		rsp,	rbp
	pop		rbp
	
	ret
main endp

computeCharge proc 
	push	rbp
	mov		rbp,	rsp
	sub		rsp,	32

	cvtsi2sd	xmm0,	sqword ptr [rcx]	;hours
	cvtsi2sd	xmm1,	sqword ptr [rdx]	;minutes

	mulsd		xmm0,	riyalPerHour

	comisd		xmm1,	zero
	jne		add1
	movsd		result,	xmm0
	jmp		Lend
	
	add1:
	addsd		xmm0,	riyalPerHour

	movsd		result,	xmm0
	Lend:

	add		rsp,	32
	mov		rsp,	rbp
	pop		rbp

	ret
computeCharge endp
END
