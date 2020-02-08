includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern fopen_s: proc, fprintf_s: proc, fprintf: proc, fscanf_s: proc, fclose: proc, exit: proc, printf: proc, pow: proc

complex struct
	real real8 ?
	imaginary real8 ?
complex ends

.data
	reciprocalBoolean qword 0
	negativeOne real8 -1.0

	readFormat byte "%lf%lf%lf%lf", 0

	writeFormat1 byte "complex1 = (%.2lf + %.2lfi), complex2 = (%.2lf + %.2lfi)", 13, 10, 0
	writeFormat2 byte "Multiplication (complex1 * complex2) = (%.2lf + %.2lfi)", 13, 10, 0
	writeFormat3 byte "Division (complex1 / complex2) = (%.2lf + %.2lfi)", 13, 10, 0
	writeFormat4 byte "Reciprocal (1 / complex1) = (%.2lf + (%.2lf)i)", 13, 10, 0
	writeFormat5 byte "Reciprocal (1 / complex2) = (%.2lf + (%.2lf)i)", 0

	readFile byte "complexes.txt", 0
	writeFile byte "results.txt", 0

	readMode byte "r", 0
	writeMode byte "w", 0

	errorMessage1 byte "The file complexes.txt wasn't opened successfully", 0
	successMessage byte "The process done successfully", 0

.data?
	array complex 2 dup(<>)			;the two elements will initialized by reading from a file "complexes.txt"
	readPointer qword ?				;pointer for the file "complexes.txt"
	writePointer qword ?			;pointer for the file "results.txt"

	
callProcedure macro procedureName
	lea		rdi,	array
	lea		r9,		[rdi].complex.imaginary		;call the procedure procedureName
	lea		r8,		[rdi].complex.real
	add		rdi,	TYPE complex				;move the pointer rdi to the next element in the array
	lea		rdx,	[rdi].complex.imaginary
	lea		rcx,	[rdi].complex.real
	call	procedureName
endm

writeResult macro format
	movq	r9,		xmm1
	movq	r8,		xmm0
	lea		rdx,	format
	mov		rcx,	writePointer
	call	fprintf_s							;print the result in the file results.txt
endm

.code
multiplyComplex proc
	;real8 ptr [rcx] = array[0].real
	;real8 ptr [rdx] = array[0].imaginary
	;real8 ptr [r8] = array[1].real
	;real8 ptr [r9] = array[1].imaginary
	
	movsd	xmm0,	real8 ptr [rcx]
	mulsd	xmm0,	real8 ptr [r8]		;xmm0 = (array[0].real * array[1].real)
	movsd	xmm1,	real8 ptr [rdx]
	mulsd	xmm1,	real8 ptr [r9]		;xmm1 = (array[0].imaginary * array[1].imaginary)

	subsd	xmm0,	xmm1				;real part = xmm0

	movsd	xmm1,	real8 ptr [rcx]		
	mulsd	xmm1,	real8 ptr [r9]		;xmm1 = (array[0].real * array[1].imaginary)
	movsd	xmm2,	real8 ptr [r8]
	mulsd	xmm2,	real8 ptr [rdx]		;xmm2 = (array[1].real * array[0].imaginary)

	addsd	xmm1,	xmm2				;imaginary part = xmm1
	ret
multiplyComplex endp

divideComplex proc
	;real8 ptr [rcx] = array[0].real
	;real8 ptr [rdx] = array[0].imaginary
	;real8 ptr [r8] = array[1].real
	;real8 ptr [r9] = array[1].imaginary

	movsd	xmm5,	real8 ptr [r8]
	mulsd	xmm5,	xmm5				;xmm5^2 = (array[1].real)^2
	movsd	xmm6,	real8 ptr [r9]
	mulsd	xmm6,	xmm6				;xmm6^2 = (array[1].imaginary)^2
	addsd	xmm6,	xmm5				

	movsd	xmm0,	real8 ptr [rcx]	
	mulsd	xmm0,	real8 ptr [r8]		;xmm0 = (array[0].real * array[1].real)
	movsd	xmm1,	real8 ptr [rdx]		
	mulsd	xmm1,	real8 ptr [r9]		;xmm1 = (array[0].imaginary * array[0].imaginary)
	addsd	xmm0,	xmm1				

	divsd	xmm0,	xmm6				;real part = xmm0

	movsd	xmm1,	real8 ptr [r8]
	mulsd	xmm1,	real8 ptr [rdx]		;xmm1 = (array[1].real * array[0].imaginary)
	movsd	xmm2,	real8 ptr [rcx]		
	mulsd	xmm2,	real8 ptr [r9]		;xmm2 = (array[0].real * array[0].imaginary)
	subsd	xmm1,	xmm2

	divsd	xmm1,	xmm6				;imaginary part = xmm1
	ret
divideComplex endp

reciprocalComplex proc
	;real8 ptr [rcx] = array[0].real
	;real8 ptr [rdx] = array[0].imaginary
	;real8 ptr [r8] = array[1].real
	;real8 ptr [r9] = array[1].imaginary

	mov		rbx,	reciprocalBoolean
	cmp		rbx,	0
	jne		complex2
	
	;calculate the reciprocal for the complex 1 (array[0])

	movsd	xmm5,	real8 ptr [rcx]
	mulsd	xmm5,	xmm5				;xmm5^2 = (array[0].real)^2
	movsd	xmm6,	real8 ptr [rdx]		
	mulsd	xmm6,	xmm6				;xmm6^2 = (array[0].imaginary)^2
	addsd	xmm5,	xmm6

	movsd	xmm0,	real8 ptr [rcx]		;xmm0 = array[0].real
	divsd	xmm0,	xmm5				;real part = xmm0
	
	movsd	xmm1,	real8 ptr [rdx]		;xmm1 = array[0].imaginary
	mulsd	xmm1,	negativeOne
	divsd	xmm1,	xmm5				;imaginary part = xmm1

	inc		reciprocalBoolean
	jmp		Lend

	complex2:
	
	;calculate the reciprocal for the complex 2 (array[1])
	movsd	xmm5,	real8 ptr [r8]
	mulsd	xmm5,	xmm5				;xmm5^2 = (array[1].real)^2
	movsd	xmm6,	real8 ptr [r9]		
	mulsd	xmm6,	xmm6				;xmm6^2 = (array[1].imaginary)^2
	addsd	xmm5,	xmm6

	movsd	xmm0,	real8 ptr [r8]		;xmm0 = array[1].real
	divsd	xmm0,	xmm5				;real part = xmm0
	
	movsd	xmm1,	real8 ptr [r9]		;xmm1 = array[1].imaginary
	mulsd	xmm1,	negativeOne
	divsd	xmm1,	xmm5				;imaginary part = xmm1

	Lend:
	ret
reciprocalComplex endp

main proc
	push	rbp
	sub		rsp,	32
	
	lea		r8,		readMode		;opne complexes.txt for read by fopen_s function fopen(readPointer, readFile, readMode);
	lea		rdx,	readFile
	lea		rcx,	readPointer
	call	fopen_s

	cmp		rax,	0				;if rax == 0, then the file open successfully
	je		L1

	lea		rcx,	errorMessage1	
	call	printf

	mov		rcx,	1				;terminate the programm if the file wasn't opend successfully.
	call	exit

	L1:				
	
	sub		rsp,	8							;creat space in the stack to pass the parameters to fscanf_s function
	lea		rdi,	array

	lea		rcx,	[rdi].complex.imaginary			
	mov		[rsp + 40],		rcx					;initialize array[1], and array[2] by reading the number from complexes.txt
												;read from the file using 
	lea		rcx,	[rdi].complex.real			;fscanf_s(readPointer, readFromat, array[0].real, array[0].imaginary, array[1].real, array[1].imaginary);
	mov		[rsp + 32],		rcx					
							
	add		rdi,	TYPE complex				;move the pointer rdi to the next element in the array
							
	lea		r9,		[rdi].complex.imaginary	
	lea		r8,		[rdi].complex.real	
	lea		rdx,	readFormat
	mov		rcx,	readPointer
	call	fscanf_s

	add		rsp,	8							;clear the space in the stack

	lea		r8,		writeMode					;opne results.txt for write by fopen_s function fopen_s(writePointer, writeFile, writeMode);
	lea		rdx,	writeFile
	lea		rcx,	writePointer
	call	fopen_s

	sub		rsp,	16							;creat space in the stack to pass the parameters to fprintf_s function
	lea		rdi,	array								
	
	mov		rcx,	[rdi].complex.imaginary		;write the first message (writeFormat1) to results.txt file
	mov		[rsp + 40],		rcx					;fprintf_s(writePointer, writeFormat1, array[0].real, array[0].imaginary, array[1].real, array[1].imaginary)

	mov		rcx,	[rdi].complex.real
	mov		[rsp + 32],		rcx

	add		rdi,	TYPE complex				;move the pointer rdi to the next element in the array

	mov		r9,		[rdi].complex.imaginary
	mov		r8,		[rdi].complex.real
	lea		rdx,	writeFormat1
	mov		rcx,	writePointer
	call	fprintf_s

	add		rsp,	16							;clear the space in the stack								
	
	;all the procedures (multiplyComplex, divideComplex, and reciprocalComplex) are called throw (callProcedure) macro
	;all the results of the procedures are written by (writeResult) macro

	callProcedure	multiplyComplex

	writeResult		writeFormat2					

	callProcedure	divideComplex

	writeResult		writeFormat3

	callProcedure	reciprocalComplex

	writeResult		writeFormat4

	callProcedure	reciprocalComplex

	writeResult		writeFormat5

	mov		rcx,	readPointer
	call	fclose

	mov		rcx,	writePointer
	call	fclose

	lea		rcx,	successMessage
	call	printf

	add		rsp,	32
	pop		rbp
	ret
main endp
END