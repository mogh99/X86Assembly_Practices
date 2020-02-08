.686

.Model flat, c

.XMM

includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern scanf_s: proc, printf_s: proc, sin: proc, getchar: proc 

.data
	enterMessage byte "Enter two sides of a triangle in cm and the angle between them in degrees:", 0
	outputMessage byte "The area of the triangle is %lf square cm", 0

	error1 byte "Error: Invalid input.", 0
	error2 byte "Error: Invalid angle.", 0
	error3 byte "Error: Invalid Length", 0

	inputFormat byte "%lf%lf%lf", 0
	printFormat byte "%lf",0

	pi real8 3.14159265359

	two real8 2.0

	limit180 real8 180.0
	limit0 real8 0.0
.data?
	a real8 ?
	b real8 ?
	angle real8 ?

	Area real8 ?

	letterCheck byte ?

.code
main proc
	
	push	offset enterMessage
	call	printf_s
	add		esp,	4

	lea		eax,	angle
	lea		ecx,	b
	lea		ebx,	a
	push	eax
	push	ecx	
	push	ebx
	push	offset inputFormat
	call	scanf_s
	add		esp,	16

	call	getchar
	mov		letterCheck, al
	cmp		letterCheck, 10
	jne		Lerror1

	movsd	xmm0,	angle
	movsd	xmm1,	a
	movsd	xmm2,	b

	comisd	xmm0,	limit180
	jae		Lerror2
	comisd	xmm0,	limit0
	jbe		Lerror2

	comisd	xmm1,	limit0
	jbe		Lerror3
	comisd	xmm2,	limit0
	jbe		Lerror3

	;calculate the radian value of sin("angle")
	movsd		xmm0,	angle
	mulsd		xmm0,	pi
	divsd		xmm0,	limit180
	sub		esp,	8
	movsd	mmword ptr [esp],	xmm0
	call	sin
	add		esp,	8
	fstp	real8 ptr angle

	movsd	xmm0,	angle
	mulsd	xmm0,	a
	mulsd	xmm0,	b
	divsd	xmm0,	two

	sub		esp,	8
	movsd	real8 ptr [esp],	xmm0
	push	offset outputMessage
	call	printf_s
	add		esp,	12
	jmp	EndProgramme

	Lerror1:
	push	offset	error1
	call	printf_s	
	add		esp,	4
	jmp	EndProgramme

	Lerror2:
	push	offset	error2
	call	printf_s
	add		esp,	4
	jmp	EndProgramme

	Lerror3:
	push	offset	error3
	call	printf_s
	add		esp,	4
	

	EndProgramme:

	ret
main endp
END
