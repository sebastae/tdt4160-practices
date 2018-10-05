.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO

.text
	.global Start

Start:

	// Komponenter:
	// 	LED0: Port E, Pin 2
	//	PB0 : Port B, Pin 9


	// Set LED_DOUTSET and LED_DOUTCLR
	LDR R0, =GPIO_BASE
	LDR R1, =PORT_SIZE
	LDR R2, =LED_PORT
	MUL R2, R2, R1
	ADD R2, R2, R0
	LDR R1, =GPIO_PORT_DOUTSET
	LDR R0, =GPIO_PORT_DOUTCLR
	ADD R12, R2, R1
	ADD R11, R2, R0

	// Set BUTTON_DIN
	LDR R0, =GPIO_BASE
	LDR R1, =PORT_SIZE
	LDR R2, =BUTTON_PORT
	MUL R1, R1, R2
	ADD R1, R1, R0
	LDR R0, =GPIO_PORT_DIN
	ADD R10, R1, R0


	// Set values
	MOV R9, #4
	MOV R1, #1
	LSL R8, R1, #9

	// Registers:
	//	R8: Button-pin pos
	//	R9: Led-pin select
	//	R10: BUTTON_DIN address
	//	R11: LED_DOUTCLR address
	//	R12: LED_DOUTSET address

	// Setup done, turn LED off
	B store_off

// Av en eller annen grunn skrur R12 Av og R11 på?
store_on:
	STR R9, [R11]	// Set LED-pin i LED_DOUTSET til høy (skru på LED), fortsetter så til neste instruksjon (test_on_state)

test_on_state:
	LDR R5, [R10]	// Les alle verdier i BUTTON_PORT
	AND R6, R5, R8	// Velg bare verdi på button pin
	CMP R6, #0		// Sjekk om verdi er 0 -> Knapp er ikke trykket ned
	BEQ	store_off	// Knappen er ikke trykket ned, skru av LED og gå til av-sjekk
	B test_on_state	// Knappen er trykket ned, start ny sjekk

store_off:
	STR R9, [R12]	// Set LED-pin på i LED_DOUTCLR (skru av LED)

test_off_state:
	LDR R5, [R10]	// Les BUTTON_PORT
	AND R6,	R5, R8	// Velg button-pin
	CMP R6, #0		// Sammenligne button-pin og 0
	BNE store_on	// Om de ikke er like (0) er knappen trykket ned, skru på LED
	B test_off_state// Fortsett å sjekke til knappen blir trykket ned


NOP // Behold denne pÃ¥ bunnen av fila

