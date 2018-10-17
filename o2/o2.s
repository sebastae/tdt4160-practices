.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start
	
Start:

	LDR R12, =tenths
	LDR R11, =seconds
	LDR R10, =minutes
	LDR R1, =GPIO_BASE
	LDR R2, =PORT_SIZE
	LDR R3, =LED_PORT
	LDR R4, =GPIO_PORT_DOUTTGL
	MUL R2, R2, R3
	ADD R1, R1, R2
	ADD R9, R1, R4

	MOV R8, #4

	// Set up SysTic
	LDR R0, =SYSTICK_BASE
	LDR R5, =FREQUENCY/10
	LDR R1, =SYSTICK_CTRL
	LDR R2, =SYSTICK_LOAD
	LDR R3, =SYSTICK_VAL

	ADD R1, R0, R1
	ADD R2, R0, R2
	ADD R3, R0, R3

	MOV R4, 0b110

	STR R4, [R1]
	STR R5, [R2]
	STR R5, [R3]

	// Set up PB0 with interrupt
	LDR R0, =GPIO_BASE
	LDR R1, =GPIO_EXTIPSELH
	ADD R0, R0, R1

	MOV R1, 0b1111
	LSL R2, R1, #4
	MVN R3, R2
	LDR R4, [R0]
	AND R5, R4, R3
	LDR R6, =PORT_B
	LSL R6, R6, #4
	ORR R7, R5, R6
	STR R7, [R0]

	LDR R0, =GPIO_BASE
	LDR R1, =GPIO_EXTIFALL
	ADD R1, R0, R1
	LDR R2, [R1]
	MOV R3, #1
	LSL R3, R3, #9
	ORR R4, R3, R2
	STR R4, [R1]

	LDR R1, =GPIO_IFC
	ADD R1, R0, R1

	MOV R5, #1
	LSL R5, R5, #9

	STR R5, [R1]

	LDR R1, =GPIO_IEN
	ADD R1, R1, R0
	LDR R2, [R1]
	ORR R4, R3, R2
	STR R4, [R1]



// Keep the program alive and wait for interrupts
loop:
	B loop

.global SysTick_Handler
.thumb_func
SysTick_Handler:
	LDR R0, [R12]
	MOV R2, #9
	CMP R0, R2
	BEQ reach_ten

	MOV R1, #1
	ADD R0, R0, R1
	STR R0, [R12]

	B done

	reach_ten:
		// Toggle LED
		STR R8, [R9]

		// Set tenths-variable to 0
		MOV R3, #0
		STR R3, [R12]

		// Update seconds
		LDR R1, [R11]
		MOV R2, #59
		CMP R1, R2
		BEQ reach_seconds

		MOV R0, #1
		ADD R0, R0, R1
		STR R0, [R11]

		B done

		reach_seconds:
			// Set seconds to 0
			MOV R3, #0
			STR R3, [R11]

			// Update minutes
			LDR R3, [R10]
			MOV R4, #59
			CMP R3, R4
			BEQ reach_minutes

			MOV R0, #1
			ADD R0, R0, R3
			STR R0, [R10]
			B done

			reach_minutes:
				// Set minutes to 0
				MOV R0, #0
				STR R0, [R10]


	done:
		BX LR

.global GPIO_ODD_IRQHandler
.thumb_func
GPIO_ODD_IRQHandler:

	// Toggle SysTick enable
	LDR R0, =SYSTICK_BASE
	LDR R1, =SYSTICK_CTRL
	ADD R1, R0, R1

	LDR R2, [R1]
	MOV R3, #1
	AND R2, R2, R3
	CMP R2, R3
	BEQ off

	MOV R4, 0b111
	B cont
	off:
		MOV R4, 0b110
	cont:
		STR R4, [R1]

	// Clear IF
	LDR R0, =GPIO_BASE
	LDR R1, =GPIO_IFC
	ADD R1, R0, R1

	MOV R2, #1
	LSL R2, R2, #9

	STR R2, [R1]


	BX LR



NOP // Behold denne på bunnen av fila
