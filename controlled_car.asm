; ProyectoFinal2.asm
.INCLUDE "m16adef.inc"
.DEF row = R17
.DEF col = R19
.DEF Velocidad = R22
.DEF cont = R23
.ORG 0x00
RJMP main
.ORG 0x02 ;INT0. (PD2)
RJMP Velocidad_Normal
.ORG 0x04 ;INT1. (PD3)
RJMP Velocidad_Maxima
.ORG 0x24 ;INT2. (PB2)
RJMP STOP
/*
Puertos.
Puerto A: Botones de Velocidad (PA0 -PA3)
Puerto B: INT2 STOP (PB2)
Puerto C: Puerto LCD (PC0-PC7)
Puerto D: Tx (PD1). INT0 (PD2). INT1
(PD3)
*/
main:
//Pila
LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16
//Definir Salidas
SER R16
OUT DDRC, R16
SBI DDRD, 1 ;Bit de
Tx
;Pull-Ups
OUT PORTA, R16
SBI PORTB, 2

SBI PORTD, 2
SBI PORTD, 3
//Interrupción
LDI R16, 0b11100000
OUT GICR, R16 ;Habilitamos
INT0, INT1, INT2
LDI R16, 0b00001010 ;Habilitar activo
en Flanco de bajada, INT0 e INT1
OUT MCUCR, R16
CLR R16
OUT MCUCSR, R16
;Habilitar activo en Flanco de bajada, INT2
//Serial
LDI R16, 0b10000110 ;Asíncrono (6).
Disable (5 4). 1 stop bit (3). 8 character size (2 1). No
Polaridad (0)
OUT UCSRC, R16
LDI R16, 0b00001000 ;Enable Tx
OUT UCSRB, R16
LDI R16, 51
OUT UBRRL, R16 ;9600
baud rate
//Inicialización
CALL init_LCD
//Código//
//Escribir mensaje de bienvenida
LDI Velocidad, 40 ;Lo colocamos en 3 por que es el
numero que se le asigno al stop
;Apuntador
LDI ZH,HIGH(0x100<<1)
LDI ZL,LOW(0x100<<1)
;Bienvenido
LDI row,0x80
LDI col,0x03
CALL gotoXY_LCD
LDI cont, 10 ;Numero de caracteres
que s evana desplegar
cicloBienvenido:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloBienvenido
Polling_Botenes:
LDI row,0xC0
LDI col,0x10
CALL gotoXY_LCD
LDI ZH,HIGH(0x600<<1)
LDI ZL,LOW(0x600<<1)
LDI cont, 10
IN R16, PINA
COM R16
CPI R16, 1
BREQ ADELANTE
CPI R16, 2
BREQ ATRAS
CPI R16, 4

BREQ izquierda1
CPI R16, 8
BREQ derecha1
RJMP Polling_Botenes
ADELANTE:
STS 0x60, R16
LDI row,0x80
LDI col,0x03
CALL gotoXY_LCD
cicloDireccion1:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloDireccion1
CALL delay10ms
SBIC PINA, 0
RJMP Polling_Botenes
wait: SBIS PINA, 0
RJMP wait
CALL envioTx
;Apuntador
LDI ZH,HIGH(0x200<<1)
LDI ZL,LOW(0x200<<1)
;Posición de Palabra
LDI row,0xC0
LDI col,0x03
CALL gotoXY_LCD
LDI cont, 9
cicloAdelante:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloAdelante
LDI row,0xC0
LDI col,0x10
CALL gotoXY_LCD
RJMP Polling_Botenes
izquierda1: JMP IZQUIERDA
derecha1: JMP DERECHA
ATRAS:
STS 0x60, R16
LDI row,0x80
LDI col,0x03
CALL gotoXY_LCD
cicloDireccion2:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloDireccion2
CALL delay10ms
SBIC PINA, 1
RJMP Polling_Botenes
wait2: SBIS PINA, 1
RJMP wait2
CALL envioTx
LDI ZH,HIGH(0x300<<1)
LDI ZL,LOW(0x300<<1)
;Posición de Palabra
LDI row,0xC0
LDI col,0x03
CALL gotoXY_LCD
LDI cont, 9 ;Numero de caracteres que s evana desplegar
cicloAtras:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloAtras
RJMP Polling_Botenes
IZQUIERDA:
STS 0x60, R16
LDI row,0x80
LDI col,0x03
CALL gotoXY_LCD
cicloDireccion3:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloDireccion3
CALL delay10ms
SBIC PINA, 2
RJMP Polling_Botenes
wait3: SBIS PINA, 2
RJMP wait3
CALL envioTx
;Apuntador
LDI ZH,HIGH(0x400<<1)
LDI ZL,LOW(0x400<<1)
;Posición de Palabra
LDI row,0xC0
LDI col,0x03
CALL gotoXY_LCD
LDI cont, 9 ;Numero de caracteres que s evana desplegar
cicloIzquierda:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloIzquierda
RJMP Polling_Botenes
DERECHA:
STS 0x60, R16
LDI row,0x80
LDI col,0x03
CALL gotoXY_LCD
cicloDireccion4:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloDireccion4
CALL delay10ms
SBIC PINA, 3
RJMP Polling_Botenes
wait4: SBIS PINA, 3
RJMP wait4
CALL envioTx
;Apuntador
LDI ZH,HIGH(0x500<<1)
LDI ZL,LOW(0x500<<1)
;Posición de Palabra
LDI row,0xC0
LDI col,0x03
CALL gotoXY_LCD
LDI cont, 9 ;Numero de caracteres que s evana desplegar
cicloDerecha:
LPM R25, Z+
CALL send4bits_LCD
DEC cont
BRNE cicloDerecha
RJMP Polling_Botenes
envioTx:
LDS R20, 0x60
ADD R20, Velocidad
OUT UDR, R20
enviandoTx: SBIS UCSRA, UDRE ;Buffer Tx vacío
RJMP enviandoTx
RET
Velocidad_Normal:
;Salvar entorno
IN R16, SREG
PUSH R16
LDI Velocidad,20
RJMP Salir
Velocidad_Maxima:
;Salvar entorno
IN R16, SREG
PUSH R16
LDI Velocidad,30

RJMP Salir
Stop:
;Salvar entorno
IN R16, SREG
PUSH R16
LDI Velocidad,40
LDI R16, 1
STS 0x60, R16
CALL envioTx
RJMP Salir
Salir:
POP R16
OUT SREG, R16
RETI
//Tabla en Flash
.ORG 0x100
.DB "Bienvenido"
.ORG 0x200
.DB "Adelante "
.ORG 0x300
.DB "Atras "
.ORG 0x400
.DB "Izquierda"
.ORG 0x500
.DB "Derecha "
.ORG 0x600
.DB "Direccion:"
//Rutinas
send4bits_LCD:
CLI
LDI R18,2 ;Dos nibbles en un byte. Primero se envía nibble superior y luego nibble inferior
MOV R24,R25
ciclo:
ANDI R24,0xF0
;Nibble superior únicamente
SUBI R24,-4
;Activar enable E-RW-RS (100)
BRTS dato ;Si es un dato, deberá send4bits_LCDse
como dato
instruccion: ;En caso contrario, es instrucción
OUT PORTC,R24
;Datos salen por Puerto D
NOP
NOP
NOP
;3 ciclos de máquina
CBI PORTC,2
;CLR pin. Flanco de bajada

DEC R18
;Decrementar contador
BREQ final
MOV R24,R25
SWAP R24
RJMP ciclo
dato:
SUBI R24,4
;sumo bits E-RW-RS (000)
SUBI R24,-5
;sumo bits E-RW-RS (101)
RJMP instruccion
final:
CALL delay500us
CALL busy_LCD
SEI
RET
busy_LCD:
;Para leer BF se debe cumplir:
CLR R0
OUT PORTC, R0 ;RS = 0
SBI PORTC, 1 ;RW = 1
CBI DDRC, 7 ;Habilidar PD7 para lectura
pollingFlag:
SBIC PINC, 7 ;Polling del pin del PB7
RJMP pollingFlag
SBI DDRC, 7 ;Habilitar PD7 para escritura
RET
init_LCD:
CALL delay10ms
LDI R25,0x28 ;Font 5x7, 2 lineas, 4 bits
CALL send4bits_LCD
CALL delay10ms
LDI R25,0x06 ;incrementar el cursor y apagar “shift”
CALL send4bits_LCD
CALL delay10ms
LDI R25,0x0F ;Blinkea el cursor y enciende el
display
CALL send4bits_LCD
CALL delay10ms
LDI R25,0x01 ;limpia el display
CALL send4bits_LCD
CALL delay10ms
RET
gotoXY_LCD:
CLT
ADD row,col
MOV R25,row
CALL send4bits_LCD
CALL busy_LCD
SET
RET
delay10ms:
PUSH R20
PUSH R21
LDI R20, 104
loop1:
LDI R21 ,255
loop2:
DEC R21
BRNE loop2
DEC R20
BRNE loop1
POP R21
POP R20
RET
delay500us:
PUSH R20
LDI R20, 5
loop3:
LDI R21 ,255
loop4:
DEC R21
BRNE loop4
DEC R20
BRNE loop3
POP R20
RET
CÓDIGO PARA AUTOMÓVIL
;
; FinalProyecto3.asm
.include "m16adef.inc"
.org 0
RJMP main
.org 0x16
RJMP Rx ; Interrupcion de recepcion
.def dato_recibido = R17
.def vel_motorA = R18
.def vel_motorB = R19
main:
;Pila
LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16
;salidas
SBI DDRD, 4 ;salida OC1B
SBI DDRD, 5 ;salida 0C1A
SER R16
OUT DDRA, R16 ;salida puerto A (direcciones)
; Programar tope (ESTE TOPE FUNCIONA)
LDI R16, HIGH(300)
OUT ICR1H, R16
LDI R16, LOW(300)
OUT ICR1L, R16
CLR dato_recibido
;Inicializar recepción de serial (interrupcion)
LDI R16, 0b10000110 ;Asíncrono (6). Disable (5
4). 1 stop bit (3). 8 character size (2 1). No Polaridad (0)
OUT UCSRC, R16
LDI R16, 0b10010000 ;Habilita Interrupción cuando Buffer de Recepción lleno, habitlita recepcion
OUT UCSRB, R16
LDI R16, 51
OUT UBRRL, R16 ;9600 baud rate
SEI
FIN : RJMP FIN
Rx:
IN R16, SREG
PUSH R16
IN dato_recibido, UDR ; en UDR se guarda lo que se
recibioo
direccionSeleccionada: ; Pregunto la direccion seleccionada y la velocidad que fue recibida por serial
CPI dato_recibido, 21
BREQ norm_Adelante
CPI dato_recibido, 22
BREQ norm_Atras
CPI dato_recibido, 24
BREQ norm_Izquierda
CPI dato_recibido, 28
BREQ norm_Derecha
CPI dato_recibido, 31
BREQ max_Adelante
CPI dato_recibido, 32
BREQ max_Atras
CPI dato_recibido, 34
BREQ max_Izquierda
CPI dato_recibido, 38
BREQ max_Derecha
CPI dato_recibido, 40
BRSH stop
RJMP salir ; s no es ninguna de estas opciones salte
norm_Adelante: ; Genera PWM con velocidad normal hacia delante
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 193
LDI vel_motorB, 193

CALL PWM
RJMP salir
norm_Atras: ; Genera PWM con velocidad normal hacia atras
LDI R16, 0B00000101
OUT PORTA, R16
LDI vel_motorA, 193
LDI vel_motorB, 193
CALL PWM
RJMP salir
norm_Izquierda: ;Genera PWM con velocidad normal hacia laizquierda
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 96 ; minimo
LDI vel_motorB, 193 ; medio
CALL PWM
RJMP salir
norm_Derecha: ;Genera PWM con velocidad normal hacia la derecha
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 193 ; medio
LDI vel_motorB, 96 ; min
CALL PWM
RJMP salir
max_Adelante: ;Genera PWM con velocidad normal hacia delante
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 255 ; max
LDI vel_motorB, 255 ; max
CALL PWM
RJMP salir
max_Atras: ;Genera PWM con velocidad máxima hacia Atras
LDI R16, 
OUT PORTA, R16
LDI vel_motorA, 255 ;max
LDI vel_motorB, 255 ;max
CALL PWM

RJMP salir
max_Izquierda: ;Genera PWM con velocidad máxima izquierda
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 193 ; medio
LDI vel_motorB, 255 ; maximo
CALL PWM
RJMP salir
max_Derecha: ;Genera PWM con velocidad normal hacia la
izquierda
LDI R16, 0B00001010
OUT PORTA, R16
LDI vel_motorA, 255 ;
LDI vel_motorB, 193 ;
CALL PWM
RJMP salir
stop:
CLR R16
OUT PORTA, R16
LDI vel_motorA, 0 ;
LDI vel_motorB, 0 ;
CALL PWM
RJMP salir
PWM:
STS 0X60, vel_motorA
STS 0X61, vel_motorB
LDS R16, HIGH(0X60);LÍMITE SUPERIOR
OUT OCR1AH, R16
LDS R16, LOW(0X60)
OUT OCR1AL, R16
LDS R16, HIGH(0X61);LIMITE INFERIOR
OUT OCR1BH, R16
LDS R16, LOW(0X61)
OUT OCR1BL, R16
LDI R16, 0B10100010 ; palabra de control timer1,no invertido, modo 14 fast PWM
OUT TCCR1A, R16
LDI R16, 0B00011101 ; palabra de control timer1,modo 14 fast PWM, sin preescaler
OUT TCCR1B, R16
RET
salir:
POP R16
OUT SREG, R16
RETI
Automóvil