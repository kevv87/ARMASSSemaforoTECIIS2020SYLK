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

	AREA	ISRCODE, CODE, READONLY
		
SysTick_Handler PROC  ; Aqui definimos lo que se ejecuta en la excepcion
	EXPORT  SysTick_Handler
	
; Codigo aqui

	; Sumando 1s a los registros que llevan el tiempo, el del semaforo amarillo no 
	; se toma en cuenta.
	ADD R2, R2, #1 ; Contador de tiempo de los carros
	ADD R4, R4, #1 ; tiempo de espera del carril contrario
	
	; Comparaciones y saltos
	CMP R13, #1 ; Estado 1?
	BEQ E1
	CMP R13, #2 ; Estado 2?
	BEQ E2
	CMP R13, #3 ; Estado 3?
	BEQ E3
	CMP R13, #4 ; Estado 4?
	BEQ E4
	; Default
	BEQ Done
	
E1 ; Estado 1
	
E2 ; Estado 2
	
E3 ; Estado 3

E4 ; Estado 4
	
Done ; Branch de finalizacion
	
	BX	LR ; Necesario al ser una excepcion.

	ENDP
		
	ALIGN 4
LEDs_ON		EQU	0x0000F000
LEDs_OFF	EQU	0xF0000000
	
	
	END
