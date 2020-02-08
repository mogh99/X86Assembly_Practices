includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern fopen_s: proc, fscanf_s: proc, fprintf_s: proc, fprintf: proc, printf: proc, exit: proc, fclose: proc

student struct
	name1 byte 40 dup(?)
	name2 byte 40 dup(?)
	ID qword ?
	quizGrades real8 3 dup(?)
	average real8 ?
student ends

.data
	errorMessage byte "The file QuizGrades.txt wasn't opened successfully", 0
	successfullMessage byte "Results are written to QuizResults.txt", 0

	header byte "Name						ID			Average", 13, 10 , 0

	writeMode byte "w", 0
	readMode byte "r", 0

	readFile byte "QuizGrades.txt", 0
	writeFile byte "QuizResults.txt", 0

	readFormat byte "%s%s%ld%lf%lf%lf", 0

	writeFormat1 byte "%s%15s%30d%30.2lf", 13, 10, 0		;write the information for every student.
	writeFormat2 byte "Class Average:   %.2lf", 0			;write class average at the end of the file.

	threeQuizes real8 3.0

	studentsTotal real8 0.0

.data?
	readPointer	qword ?
	writePointer qword ?

	studentInfo student <>

	numberOfQuizes real8 ?
	classAverage real8 ?

.code
main proc
	Enter	32,	0

	lea		r8,		readMode				;open file QuizGrades.txt for read using fopen_s function
	lea		rdx,	readFile
	lea		rcx,	readPointer
	call	fopen_s							;fopen_s(&readPointer, readFile, readMode);

	cmp		rax,	0						;Jump to L1 if the file was opened successfully
	JE		L1

	lea		rcx,	offset errorMessage
	call	printf

	mov		rcx,	1
	call	exit							;Terminate if the file wasn't opened successfully.
	L1:

	lea		r8,		writeMode				;open the file QuizResults.txt for write using fopen_s function
	lea		rdx,	writeFile
	lea		rcx,	writePointer
	call	fopen_s

	lea		rdx,		header					;write the header (Name ID Average) in the file QuizResults.txt
	mov		rcx,	writePointer
	call	fprintf

	sub		rsp,	48							;creat space in the stack to pass the last 6 parameters of fscanf_s function

	;loop1 will (read students infromation from QuizGrades.txt, calculate each student average, calculate total quizes, calculate total grades, and write students information to QuizResults.txt file)
	loop1:
	

	lea		rdi,	studentInfo.quizGrades[16]				;studentInfo.quizGrades[16] = studentInfo.quizGrades[2]
	mov		[rsp + 72],		rdi

	lea		rdi,	studentInfo.quizGrades[8]				;studentInfo.quizGrades[16] = studentInfo.quizGrades[1]
	mov		[rsp + 64],		rdi

	lea		rdi,	studentInfo.quizGrades[0]				;studentInfo.quizGrades[16] = studentInfo.quizGrades[0]
	mov		[rsp + 56],		rdi

	lea		rsi,	studentInfo.ID
	mov		[rsp + 48],		rsi

	mov		qword	ptr [rsp + 40],		39					;Size of studentInfo.name2

	lea		rsi,	studentInfo.name2
	mov		[rsp + 32],		rsi

	mov		qword ptr r9,	39								;Size of studentInfo.name1
	lea		r8,		studentInfo.name1
	lea		rdx,	readFormat
	mov		rcx,	readPointer
	call	fscanf_s							;fscanf_s(readPointer, readFormat, studentInfo.name1, size, studentInfo.name2, size, 
																;studentInfo.ID, studentInfo.quizGrades[0], studentInfo.quizGrades[1], studentInfo.quizGrades[2]);

	cmp		eax,	0FFFFFFFFH					;check when fscanf_s reach the end of file (EOF)
	je		Lend

	xor		rax,	rax
	mov		studentInfo.average,	rax

	movsd	xmm0,	studentInfo.quizGrades[0]
	addsd	xmm0,	studentInfo.quizGrades[8]
	addsd	xmm0,	studentInfo.quizGrades[16]			;student total grades
	
	movsd	xmm1,	studentsTotal
	addsd	xmm1,	xmm0								;calculate class total
	movsd	studentsTotal,	xmm1

	divsd	xmm0,	threeQuizes							
	movsd	studentInfo.average,	xmm0				;calculate student average
	
	movsd	xmm0,	numberOfQuizes
	addsd	xmm0,	threeQuizes
	movsd	numberOfQuizes,		xmm0					;calculate total number of quizes

	
	mov		rsi,	studentInfo.average
	mov		[rsp + 40],		rsi

	mov		rsi,	studentInfo.ID
	mov		[rsp + 32],		rsi

	lea		r9,		studentInfo.name2
	lea		r8,		studentInfo.name1
	lea		rdx,	writeFormat1
	mov		rcx,	writePointer
	call	fprintf_s									;write student name, ID, and average using fprintf_s function
														;fprintf_s(writePointer, writeFormat1, studentInfo.name1, studentInfo.name2, studentInfo.ID, studentInfo.average);
	jmp		loop1
	Lend:

	movsd	xmm0,	studentsTotal
	divsd	xmm0,	numberOfQuizes
	movsd	classAverage,	xmm0						;calculate class average


	mov		r8,		classAverage
	lea		rdx,	writeFormat2
	mov		rcx,	writePointer
	call	fprintf_s	

	add		rsp,	48							;clear the stack

	mov		rcx,	readPointer
	call	fclose

	mov		rcx,	writePointer
	call	fclose

	lea		rcx,	successfullMessage
	call	printf

	Leave
	ret
main endp
END