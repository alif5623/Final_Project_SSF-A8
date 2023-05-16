;-----------------------
; MASTER CODE 
;-----------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main
.global again


main:
  .equ SCK, 5
  .equ MOSI, 3
  .equ SS, 2

  LDI R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
  OUT DDRB, R17       ; set MOSI, SCK, SS as o/p
  LDI R17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
  OUT SPCR, R17       ; enable SPI as master, fsck=fosc/16, mode 0

  ;--------------------------------------------------------------
  RCALL I2C_init      ;initialize TWI module
  ;--------------------------------------------------------------
  LDI R26, 0xA0       ;inital byte to be transmitted (on LED in slave PD)


again:
 ;--------------------------------------------------------------
  ;Sensor Read
  ;--------------------------------------------------------------
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
  OUT PORTD, R18 ;o/p temp byte to port D
  ;--------------------------------------------------------
  ; I2C for Button
  ;--------------------------------------------------------
  RCALL I2C_start     ;transmit START condition
  LDI R27, 0b10010000 ;SLA(1001000) + W(0)
  RCALL I2C_write     ;write slave address SLA+W
  RCALL I2C_write2    ;write data byte
  RCALL I2C_stop      ;transmit STOP condition

  ;--------------------------------------------------------

  CBI PORTB, SS       ;enable slave device
  ;LDI R18, 0X00       ;data to be transmitted
  OUT SPDR, R18       ;transmit byte to slave
  loop: 
    IN R18, SPSR
    SBRS R18, SPIF    ;wait for byte transmission
    RJMP loop         ;to complete
  SBI PORTB, SS       ;disable slave device
  ;--------------------------------------------------------

  RCALL delay_50usec    ;delay 50usec second
  RJMP again          ;repeat transmission
  ;==============================================================

delay_timer0: ;50 usec delay via Timer 0
  ;---------------------------------------------------------
  CLR R20
  OUT TCNT0, R20 ;initialize timer0 with count=0
  LDI R20, 100
  OUT OCR0A, R20 ;OCR0 = 100
  LDI R20, 0b00001010
  OUT TCCR0B, R20 ;timer0: CTC mode, prescaler 8
  ;---------------------------------------------------------
  lo2: IN R20, TIFR0 ;get TIFR0 byte & check
  SBRS R20, OCF0A ;if OCF0=1, skip next instruction
  RJMP lo2 ;else, loop back & check OCF0 flag
  ;---------------------------------------------------------
  CLR R20
  OUT TCCR0B, R20 ;stop timer0
  ;---------------------------------------------------------
  LDI R20, (1<<OCF0A)
  OUT TIFR0, R20 ;clear OCF0 flag
  RET

delay_50usec: ;50 usec delay via timer1
  ;-------------------------------------------------------
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

I2C_init:
  LDI R21, 0
  STS TWSR, R21   ;prescaler 1
  LDI R21, 35     ;division factor = 35
  STS TWBR, R21   ;
  LDI R21, (1<<TWEN)
  STS TWCR, R21   ;enable TWI
  RET
  
I2C_start:
  LDI R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
  STS TWCR, R21         ;transmit START condition
  wt1:
    LDS R21, TWCR
    SBRS R21, TWINT     ;TWI interrupt = 1?
    RJMP wt1            ;no, wait for end of transmission
  RET

I2C_write:
  STS TWDR, R27         ;copy SLA+W into data register
  LDI R21, (1<<TWINT)|(1<<TWEN)
  STS TWCR, R21         ;transmit SLA+W
  wt2:
    LDS R21, TWCR
    SBRS R21, TWINT
    RJMP wt2            ;wait for end of transmission
  RET

I2C_write2:
  STS TWDR, R26         ;copy data into data register
  LDI R20, (1<<TWINT)|(1<<TWEN)
  STS TWCR, R20         ;transmit data
  wt22:
    LDS R20, TWCR
    SBRS R20, TWINT
    RJMP wt22            ;wait for end of transmission
  RET

I2C_stop:
  LDI R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
  STS TWCR, R21         ;transmit STOP condition
  RET
  
DHT11_reading:
  LDI R17, 8 ;set counter for receiving 8 bits
  CLR R18 ;clear data register
;-------------------------------------------------------
w4: 
  SBIS PINB, 1
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