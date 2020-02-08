.686

.Model flat, c

includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf_s: proc, scanf_s: proc

findMaxSum macro  array, offsetArraySums
	
	lea		edi,	array
	mov		edx,	0		; edx = i
	
	.While edx < 6
		xor		eax,	eax
		mov		ebx,	0		; ebx = j
		mov		ebp,	0
		.While ebx < 4
			add		eax,	[edi + ebp]
			add		ebp,	24
			inc		ebx
		.Endw
		mov		[offsetArraySums + edx * 4], eax
		add		edi,	 4
		inc		edx
	.Endw

	xor		edx,	edx
	mov		eax,	arraySums		;max value

	.While	edx < 6
		cmp		eax,	[arraySums + edx * 4]
		jb		newMax
		insideWhile:
		inc		edx
	.Endw

	jmp		Lend
	newMax:
	mov		eax,	[arraySums + edx * 4]
	mov		result,		edx
	jmp		insideWhile

	Lend:
	
endm

.data
	enterMessage byte "Enter The Elements Of a 4*6 Integer Array Row-Wise:", 13, 10, 0

	outputMessage byte "The index of the first column with maximum sum is: %d", 0

	;array dword 1, 100, 2, 0, 5, 0,
	;			7, 3, 5, 4, 8, 0,
	;			5, 4, 1, 1, 3, 2,
	;			3, 6, 8, 5, 4, 5

	inputFormat byte "%d", 0

	count dword 0
.data?
	array dword 24 dup(?)
	result dword ?
	arraySums dword 6 dup(?)
	maxRow dword ?

.code
main proc
	
	lea		eax,	enterMessage
	push	eax
	call	printf_s
	add		esp,	4
	xor		ebx,	ebx

	
	.While count < 24

		lea		eax,	array
		add		eax,	ebx
		push	eax
		push	offset inputFormat
		call	scanf_s
		add		esp,	8

		add		ebx,	4
		inc		count
	.EndW
	
	findMaxSum array, offset arraySums
	
	push	result
	push	offset outputMessage
	call	printf_s
	add		esp,	8

	ret
main endp
END