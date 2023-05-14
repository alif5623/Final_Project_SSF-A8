;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;=================================================================
main:
RCALL init_serial
;------------
LDI R17, 0xFF
OUT DDRC, R17 ;set port C for o/p
OUT DDRD, R17 ;set port D for o/p
;-----------------------------------------------------------------
agn:RCALL delay_2s ;wait 2s for DHT11 to get ready
;-----------------------------------------------------------------
;send start signal
;------------
SBI DDRB, 1 ;pin PB0 as o/p
CBI PORTB, 1 ;first, send low pulse
RCALL delay_20ms ;for 20ms
SBI PORTB, 1 ;then send high pulse
;-----------------------------------------------------------------
;wait for response signal
;---------------
CBI DDRB, 1 ;pin PB0 as i/p
w1: SBIC PINB, 1
RJMP w1 ;wait for DHT11 low pulse
w2: SBIS PINB, 1
RJMP w2 ;wait for DHT11 high pulse
w3: SBIC PINB, 1
RJMP w3 ;wait for DHT11 low pulse
;-----------------------------------------------------------------
RCALL DHT11_reading ;read humidity (1st byte of 40-bit data)
MOV R19, R18
RCALL DHT11_reading
RCALL DHT11_reading ;read temp (3rd byte of 40-bit data)
;-----------------------------------------------------------------
;OUT PORTD, R18 ;o/p temp byte to port D
MOV R16, R18
RCALL LCD_buffer
MOV R16, R18
RCALL ASCII_MSD
STS UDR0, R16
RCALL LCD_buffer
RCALL ASCII_LSD
STS UDR0, R16
RCALL checkTemp

RJMP agn ;go back & get another sensor reading
;=================================================================
DHT11_reading:
LDI R17, 8 ;set counter for receiving 8 bits
CLR R18 ;clear data register
;-------------------------------------------------------
w4: SBIS PINB, 1
RJMP w4 ;detect data bit (high pulse)
RCALL delay_timer0 ;wait 50us & then check bit value
;-------------------------------------------------------
SBIS PINB, 1 ;if received bit=1, skip next inst
RJMP skp ;else, received bit=0, jump to skp
SEC ;set carry flag (C=1)
ROL R18 ;shift in 1 into LSB data register
RJMP w5 ;jump & wait for low pulse
skp:LSL R18 ;shift in 0 into LSB data register
;-------------------------------------------------------
w5: SBIC PINB, 1
RJMP w5 ;wait for DHT11 low pulse
;-------------------------------------------------------
DEC R17 ;decrement counter
BRNE w4 ;go back & detect next bit
RET ;return to calling subroutine
;=================================================================
;delay subroutines
;=================================================================
delay_20ms: ;delay 20ms
LDI R21, 255
l3: LDI R22, 210
l4: LDI R23, 2
l5: DEC R23
BRNE l5
DEC R22
BRNE l4
DEC R21
BRNE l3
RET
;-----------------------------------------------------------------
delay_2s: ;delay 2s
LDI R21, 255
l6: LDI R22, 255
l7: LDI R23, 164
l8: DEC R23
BRNE l8
DEC R22
BRNE l7
DEC R21
BRNE l6
RET
;===============================================================
delay_timer0: ;50 usec delay via Timer 0
;---------------------------------------------------------
CLR R20
OUT TCNT0, R20 ;initialize timer0 with count=0
LDI R20, 100
OUT OCR0A, R20 ;OCR0 = 100
LDI R20, 0b00001010
OUT TCCR0B, R20 ;timer0: CTC mode, prescaler 8
;---------------------------------------------------------
LOOP2: IN R20, TIFR0 ;get TIFR0 byte & check
SBRS R20, OCF0A ;if OCF0=1, skip next instruction
RJMP LOOP2 ;else, loop back & check OCF0 flag
;---------------------------------------------------------
CLR R20
OUT TCCR0B, R20 ;stop timer0
;---------------------------------------------------------
LDI R20, (1<<OCF0A)
OUT TIFR0, R20 ;clear OCF0 flag
RET

init_serial:
  CLR R24
  STS UCSR0A, R24 ;clear UCSR0A register
  STS UBRR0H, R24 ;clear UBRR0H register
  LDI R24, 103 ;& store in UBRR0L 103 value
  STS UBRR0L, R24 ;to set baud rate 9600
  LDI R24, 1<<RXEN0 | 1<<TXEN0 ;enable RXB & TXB
  STS UCSR0B, R24
  LDI R24, 1<<UCSZ00 | 1<<UCSZ01;asynch, no parity, 1 stop, 8 bits
  STS UCSR0C, R24
  RET
;---------------------------------------------------------------
agn_buffer:
  LPM R18, Z+ ;load char of string onto R18
  CPI R18, 0 ;check if R18=0 (end of string)
  BRNE buffer ;if yes, exit
  RET
buffer:
  RCALL LCD_buffer
  STS UDR0, R18 ;send char in R18 to serial monitor
  RJMP agn_buffer ;loop back & get next character
ASCII_MSD:
  MOV R23, R16 ;save copy of result
  ANDI R16, 0xF0 ;extract & swap high-nibble
  SWAP R16
  SUBI R16, -48 ;R16 = R16 - (48) = R16 + 48
  MOV R20, R16 ;save a copy of high-byte result
  SUBI R20, 58 ;if +ve
  BRPL A_F_D1 ;branch & add 7 to get ASCII A to F
  RET
A_F_D1:
  SUBI R16, -7 ;R16 = R16 - (7) = R16 + 7
  RET
ASCII_LSD:
  MOV R16, R23 ;restore copy of result
  ANDI R16, 0x0F ;extract low-nibble
  SUBI R16, -48 ;R16 = R16 - (48) = R16 + 48
  MOV R20, R16 ;save a copy of high-byte result
  SUBI R20, 58 ;if +ve
  BRPL A_F_D0 ;branch & add 7 to get ASCII A to F]
  RET
A_F_D0:
  SUBI R16, -7 ;R16 = R16 - (7) = R16 + 7
  RET
LCD_buffer:
  LDS R27, UCSR0A
  SBRS R27, UDRE0 ;test data buffer if data can be sent
  RJMP LCD_buffer
  RET

checkTemp: 
  LDI R30,0x30
  CP R18, R30
  BRSH fireDetected
  BRLT noFire
  RET

fireDetected:
SBI PORTD, 6
RCALL myDelay ;Memanggil delay untuk pergantian nyala lampu
CBI PORTD, 5
RCALL myDelay ;Memanggil delay untuk pergantian nyala lampu
SBI PORTD, 5
;----------------------------------------------------------------
myDelay: ;3-level nested loop delay
LDI R20, 255 ;outer loop counter
c1: LDI R21, 255 ;mid loop counter
c2: LDI R22, 20 ;inner loop counter 
;1s delay = 255 * 255 * 82 * 3 = 15.996.150 cycle = 1 s
c3: DEC R22 ;decrement inner loop
BRNE c3 ;Branch ke l3 jika R22 != 0
DEC R21 ;decrement mid loop
BRNE c2 ;Branch ke l2 jika R21 != 0 
DEC R20 ;decrement outer loop
BRNE c1 ;`Branch ke l1 jika R20 != 0
RET ;return

noFire: 
  CBI PORTD, 6
  CBI PORTD, 5
  RET
print_msg_divide:
  LDI R30, lo8(message_Divide)
  LDI R31, hi8(message_Divide)
  JMP agn_buffer
;---------------------------------------------------------------
message_Divide:
  .ascii "Temperature:"
  .byte 10,13,0
