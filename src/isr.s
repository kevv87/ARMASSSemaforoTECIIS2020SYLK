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
	ADD 	R10, R10, #1 ; Contador de tiempo de los carros
	ADD		R1, R1, #1 ; tiempo de espera del carril contrario
	
	; Comparaciones y saltos
	CMP 	R4, #1 ; Estado 1?
	BEQ 	E1
	CMP 	R4, #2 ; Estado 2?
	BEQ 	E2
	CMP 	R4, #3 ; Estado 3?
	BEQ 	E3
	CMP 	R4, #4 ; Estado 4?
	BEQ 	E4
	; Default
	BEQ.W 	Done
	
E1 ; Estado 1
	; Seteando semaforos
	MOV 	R5, #2 ; Verde
	STR 	R5, [R3, #0] ; Semaforo 1 a verde
	STR 	R5, [R3, #8] ;  Semáforo 3 a verde
	STR 	R5, [R3, #20] ; Peatonal 2 a verde
	STR 	R5, [R3, #28] ; Peatonal 4 a verde
	
	MOV 	R5, #0 ; Rojo
	STR 	R5, [R3, #4] ; Semaforo 2 a rojo
	STR 	R5, [R3, #12] ; Semaforo 4 a rojo
	STR 	R5, [R3, #16] ; Peatonal 1 a rojo
	STR 	R5, [R3, #24] ; Peatonal 3 a rojo
	
	; Revisando si se deja pasar un carro
	CMP 	R10, #10 ; Los carros se dejan pasar cada 10 segundos
	MOV		R11, LR ; Para no perder el link a la ejecucion original
	BLGE 	Pasar_Carro  ; Branch with link, para volver a aqui.
	
	; Computando el movimiento al siguiente estado
	
	; Cargando desde memoria
	LDR 	R5, [R3, #64] ; Primer carro calle 2
	LDR 	R6, [R3, #132] ; Primer carro calle 4
	LDR 	R7, [R3, #32];  Primer carro calle 1
	LDR 	R8, [R3, #96] ; Primer carro calle 3
	
	CMP 	R2, #60 ; El carril opuesto ha esperado un minuto?
	BLT 	E1_No_Minuto ; Si no, branch a no minuto 
E1_Minuto ; Si el carril opuesto ha esperado un minuto...
	ORR 	R5, R5, R6 ; Carro en 2 o carro en 4
	ORR 	R7, R7, R8 ; Carro en 1 o carro en 3
	CMP 	R5, #1 ; Carro24
	CMPNE 	R7, #0 ; OR ~Carro13
	BNE 	E1_No_Minuto
	MOV		R4, #2 ; Pasa al estado 2 si carro24 or ~carro13
	B 		Done

E1_No_Minuto ; Si el carril opuesto no ha esperado un minuto...
	CMP 	R5, #1 ; Carro24
	CMPEQ 	R7, #0 ; AND ~Carro13
	BNE 	Done ; Continua en el mismo estado si no se cumple la igualdad
	MOV 	R4, #2 ; Pasa al estado 2 si carro24 AND ~Carro13
	
	B		Done  ; Finalmente branch a done
	
	
E2 ; Estado 2
	
E3 ; Estado 3

E4 ; Estado 4
	

; Funcion para mover un carro
Pasar_Carro
	MOV 	R10, #0 ; Resetea el contador de tiempo de carros
	CMP 	R4, #3 ; Si es estado 3, pasan los carros de C2 y C4
	BEQ 	Pasar_Carro_2
	
Pasar_Carro_1
	STR		R5, [R3, #32] ; Limpia el primer campo de la fila de carros de la calle 1
	STR 	R5, [R3, #96] ; Igual con la calle 3
; Aqui vamos a hacer un for loop, para iterar la lista de carros de la calle 1 de manera descendente
; lo que se quiere lograr es mover el ultimo carro, de haber, al inicio del array
	MOV 	R7, #0 ; Reiniciando R7
	ADD		R7, R3, #32 ; Base para calle 1
	MOV 	R6, #7 ; i = 7 (vamos a hacer una cuenta atras)
	MOV 	R8, #4 ; R8 = 4 (Para efectos de la multiplicacion y acceso de memoria)
Pasar_Carro_1_loopA
	MUL		R9, R8, R6 ; R9 = R8 x R6, para poner bien la direccion de memoria
	LDR 	R5, [R7, R9] ; R5 = carros[i], a R5 se le asigna el valor en R7+R9
	
	SUB 	R6, R6, #1 ; i -= 1
	CMP		R6, #0;
	CMPGE 	R5, #1;
	BNE 	Pasar_Carro_1_loopA
	; Fin del ciclo
	MOV 	R6, #0 ; Para guardar un 0
	STR 	R5, [R7, #0] ; Guarde R5 en la primera posicion de la linea de carros
	STR 	R6, [R7, R9] ; Guarde 0 en la direccion donde se encontro el 1
	MOV 	R5, #0 ; Reseteando R5
	
; Aqui vamos a hacer un for loop, para iterar la lista de carros de la calle 3 de manera descendente
; lo que se quiere lograr es mover el ultimo carro, de haber, al inicio del array
	MOV 	R7, #0 ; Reiniciando R7
	ADD		R7, R3, #96 ; Base para calle 3
	MOV 	R6, #7 ; i = 7 (vamos a hacer una cuenta atras)
Pasar_Carro_1_loopB
	MUL		R9, R8, R6 ; R9 = R8 x R6, para poner bien la direccion de memoria
	LDR 	R5, [R7, R9] ; R5 = carros[i], a R5 se le asigna el valor en R7+R9
	
	SUB 	R6, R6, #1 ; i -= 1
	CMP		R6, #0;
	CMPGE 	R5, #1;
	BNE 	Pasar_Carro_1_loopB
	; Fin del ciclo
	MOV 	R6, #0 ; Reinicia R10, que es la condicion de salida 
	STR 	R5, [R7, #0] ; Guarde R5 en la primera posicion de la linea de carros
	STR 	R6, [R7, R9]; Guarde 0 en la direccion donde se encontro el 1
	
	BX		LR;  ; Devuelvase a donde estabamos

Pasar_Carro_2
	STR		R5, [R3, #64] ; Limpia el primer campo de la fila de carros de la calle 2
	STR 	R5, [R3, #132] ; Igual con la calle 4
; Aqui vamos a hacer un for loop, para iterar la lista de carros de la calle 2 de manera descendente
; lo que se quiere lograr es mover el ultimo carro, de haber, al inicio del array
	MOV 	R7, #0 ; Reiniciando R7
	ADD		R7, R3, #64 ; Base para calle 2
	MOV 	R6, #7 ; i = 7 (vamos a hacer una cuenta atras)
	MOV 	R8, #4 ; R8 = 4 (Para efectos de la multiplicacion y acceso de memoria)
Pasar_Carro_2_loopA
	MUL		R9, R8, R6 ; R9 = R8 x R6, para poner bien la direccion de memoria
	LDR 	R5, [R7, R9] ; R5 = carros[i], a R5 se le asigna el valor en R7+R9
	
	SUB 	R6, R6, #1 ; i -= 1
	CMP		R6, #0;
	CMPGE 	R5, #1;
	BNE 	Pasar_Carro_2_loopA
	; Fin del ciclo
	MOV 	R6, #0 ; Para guardar un 0
	STR 	R5, [R7, #0] ; Guarde R5 en la primera posicion de la linea de carros
	STR 	R6, [R7, R9] ; Guarde 0 en la direccion donde se encontro el 1
	MOV 	R5, #0 ; Reseteando R5
	
; Aqui vamos a hacer un for loop, para iterar la lista de carros de la calle 4 de manera descendente
; lo que se quiere lograr es mover el ultimo carro, de haber, al inicio del array
	MOV 	R7, #0 ; Reiniciando R7
	ADD		R7, R3, #132 ; Base para calle 4
	MOV 	R6, #7 ; i = 7 (vamos a hacer una cuenta atras)
Pasar_Carro_2_loopB
	MUL		R9, R8, R6 ; R9 = R8 x R6, para poner bien la direccion de memoria
	LDR 	R5, [R7, R9] ; R5 = carros[i], a R5 se le asigna el valor en R7+R9
	
	SUB 	R6, R6, #1 ; i -= 1
	CMP		R6, #0;
	CMPGE 	R5, #1;
	BNE 	Pasar_Carro_2_loopB
	; Fin del ciclo
	MOV 	R6, #0 ; Reinicia R10, que es la condicion de salida 
	STR 	R5, [R7, #0] ; Guarde R5 en la primera posicion de la linea de carros
	STR 	R6, [R7, R9]; Guarde 0 en la direccion donde se encontro el 1
	
	BX		LR;  ; Devuelvase a donde estabamos
	
	
	
	
Done ; Branch de finalizacion
	
	BX	R11 ; Necesario al ser una excepcion.

	ENDP
		
	ALIGN 4
LEDs_ON		EQU	0x0000F000
LEDs_OFF	EQU	0xF0000000
	
	
	END
