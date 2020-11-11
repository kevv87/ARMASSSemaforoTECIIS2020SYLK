;******************** (C) COPYRIGHT 2018 IoTality ********************
;* File Name          : LED.s
;* Author             : Gopal
;* Date               : 07-Feb-2018
;* Description        : A simple code to blink LEDs on STM32F4 discovery board
;*                      - The functions are called from startup code
;*                      - Initialization carried out for GPIO-D pins PD12 to PD15 (connected to LEDs)
;*                      - Blink interval delay implemented in software
;*******************************************************************************

	GET reg_stm32f407xx.inc

; Export functions so they can be called from other file

	EXPORT SystemInit
	EXPORT __main

	AREA	MYCODE, CODE, READONLY
		
; ******* Function SystemInit *******
; * Called from startup code
; * Calls - None
; * Enables GPIO clock 
; * Configures GPIO-D Pins 12 to 15 as:
; ** Output
; ** Push-pull (Default configuration)
; ** High speed
; ** Pull-up enabled
; **************************

SystemInit FUNCTION

	; Enable GPIO clock
	LDR		R1, =RCC_AHB1ENR	;Pseudo-load address in R1
	LDR		R0, [R1]			;Copy contents at address in R1 to R0
	ORR.W 	R0, #0x08			;Bitwise OR entire word in R0, result in R0
	STR		R0, [R1]			;Store R0 contents to address in R1
	
	; Configuracion de SysTick
	LDR		R1, =SYSTICK_RELOADR ; En este registro se guarda cada cuanto se quiere que systick lance una excepcion
	LDR		R2,	=SYST_RELOAD_500MS
	STR		R2, [R1]

	LDR		R1, =SYSTICK_CONTROLR
	LDR 	R0, [R1]
	ORR.W	R0, #ENABLE_SYSTICK
	STR		R0, [R1]
	
	; Inicializando semaforos
	MOV		R1, #2 ; Verde
	MOV		R2, #0 ; Rojo
	
	MOV 	R3, #536870912 ; Direccion base
	
	; Vehiculares
	STR		R1, [R3, #0]
	STR 	R2, [R3, #4]
	STR 	R1, [R3, #8]
	STR 	R2, [R3, # 12]
	
	; Peatonales
	STR		R2, [R3, #16]
	STR 	R1, [R3, #20]
	STR 	R2, [R3, #24]
	STR 	R1, [R3, #28]
	
	
	; Inicializando carros
	; Se harán 4 filas de 8 carros(32 posiciones de memoria) para demostrar el funcionamiento del sistema
	ADD 	R3, R3, #28 ; Seguiremos escribiendo en #(536870912+28)
	MOV 	R1, #1 ; Representa que hay un carro

	MOV		R2, #1  ; i = 1
	MOV 	R5, #4
Loops_Calle
	MUL 	R4, R2, R5  ; R4 = R2*R5
	STR 	R1, [R3, R4] ; Guarda R1 en la posicion de memoria (R3+R4)
	
	ADD 	R2, R2, #1 ; i += 1
	CMP		R2, #33 ; R2-8==0? Z=1 : Z=0
	BNE		Loops_Calle ; Si no es igual, salte a Loops_Calle, si es igual, rompa el ciclo
	
	MOV 	R3, #536870912 ; Direccion base
	
	MOV 	R4, #1 ; Estado inicial
	; Reseteando registros de timer
	MOV		R10, #0
	
	MOV 	R0, #0
	STR 	R0, [R3, #164] ; Guardando el timer de espera
	
	BX		LR					;Return from function
	
	ENDFUNC
	

; ******* Function SystemInit *******
; * Called from startup code
; * Calls - None
; * Infinite loop, never returns

; * Turns on / off GPIO-D Pins 12 to 15
; * Implements blinking delay 
; ** A single loop of delay uses total 6 clock cycles
; ** One cycle each for CBZ and SUBS instructions
; ** 3 cycles for B instruction
; ** B instruction takes 1+p cycles where p=pipeline refil cycles
; **************************

__main FUNCTION
	
	
	B	. ; Loop infinito

	ENDFUNC
	
	ALIGN 4
SYST_RELOAD_500MS	EQU 0x00B71B03 ; Cada segundo lance una excepcion.
ENABLE_SYSTICK		EQU	0x07		
	
	END
