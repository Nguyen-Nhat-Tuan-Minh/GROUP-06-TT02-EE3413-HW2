; CHIP_MASTER.asm
;
; Created: 11/15/2023 8:08:24 PM
; Author : tuan minh
;


; Replace with your application code
.ORG $0000
		RJMP MAIN

.ORG $0002 ; EXTERNAL INTERRUPT REQUEST 0 ADDRESS FOR ATMEGA324PA (LAB)
		RJMP INT0_HANDLER

.EQU PIN_SS = 4
.EQU PIN_MOSI = 5
.EQU PIN_MISO = 6
.EQU PIN_SCK = 7
.EQU SPI_DDR = DDRB
.EQU SPI_PORT = PORTB
.EQU LCD_PORT = PORTA ; LCD DATA PORT
.EQU LCD_DDR = DDRA  ; LCD DATA DDR
.EQU LCD_PIN = PINA  ; LCD DATA PIN
.EQU LCD_RS = 0		  ; LCD RS
.EQU LCD_RW = 1       ; LCD RW
.EQU LCD_EN = 2       ; LCD EN
.EQU REQ = 0 ; COMMUNICATION REQUEST AFTER DONE SETUP DONE
.DEF TEMP = R16
.DEF DATA_TEMP = R19
.DEF OCRL = R22
.DEF OCRH = R23

MAIN:
		RCALL INIT_PORT
		RCALL INIT_LCD
		RCALL INIT_MSPI ; INITIALIZE MASTER SPI
		RCALL INIT_UART0
		RCALL INIT_INT0

LOOP:
		CBI PORTB, REQ
		RJMP LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_PORT:
		LDI TEMP, (1 << PIN_MOSI) | (1 << PIN_SCK) | (1 << PIN_SS) | (1 << REQ)
		OUT SPI_DDR, TEMP
		SBI SPI_PORT, REQ
		LDI TEMP, 0b11110111
		OUT LCD_DDR, TEMP ; SET OUTPUT PORT TO LCD (DATA PA4 - PA7, RS = PA0, RW = PA1, EN = PA2)
		RCALL DELAY_20ms ; WAIT FOR POWER UP
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_LCD:
		LDI TEMP, 0x02 ; RETURN HOME
		CALL CMDWRITE
		LDI TEMP, 0x28 ; FUCNTION SET: 4-BIT, 2 LINES, 5x7 DOTS
		CALL CMDWRITE
		LDI TEMP, 0x0E ; DISPLAY ON, CURSOR ON
		CALL CMDWRITE
		LDI TEMP, 0x01 ; CLEAR DISPLAY SCREEN
		CALL CMDWRITE
		LDI TEMP, 0x80 ; FORCE CURSOR TO BEGIN OF 1ST ROW
		CALL CMDWRITE
		LDI R31, HIGH(LAB_MSG0 << 1)
		LDI R30, LOW(LAB_MSG0 << 1)

STRING0: 
		LPM TEMP, Z+
		CPI TEMP, 0
		BREQ NEXT_LINE
		RCALL DATAWRITE
		RJMP STRING0

NEXT_LINE: 
		LDI TEMP, 0xC0 ; FORCE CURSOR TO BEGIN OF 2ND ROW
		RCALL CMDWRITE
		RET

LAB_MSG0: .DB "KEY PRESSED: ", 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_MSPI:
		; ENABLE SPI MASTER, RATE FCK/16
		LDI TEMP, (1 << SPE0) | (1 << MSTR0) | (1 << SPR00)
		OUT SPCR0, TEMP
		SBI SPI_PORT, PIN_SS
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MSPI_TRANSMIT:
		CBI SPI_PORT, PIN_SS
		OUT SPDR0, DATA_TEMP

WAIT_TRANSMIT:
		; WAIT TRANSMISSION COMPLETE
		IN TEMP, SPSR0
		SBRS TEMP, SPIF0
		RJMP WAIT_TRANSMIT
		SBI SPI_PORT, REQ
		IN DATA_TEMP, SPDR0
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_UART0:
		CLR TEMP
		STS UBRR0H, TEMP
		LDI TEMP, 12
		STS UBRR0L, TEMP
		LDI TEMP, (1 << U2X0)
		STS UCSR0A, TEMP
		LDI TEMP, (1 << TXEN0) ; ENABLE TRANSMISSION
		STS UCSR0B, TEMP
		LDI TEMP, (1 << UCSZ01) | (1 << UCSZ00) ; ASYNC, 1 STOP-BIT, 1-BYTE DATA
		STS UCSR0C, TEMP
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DATA_TRANSMIT:
		LDS TEMP, UCSR0A 
		SBRS TEMP, UDRE0
		RJMP DATA_TRANSMIT
		STS UDR0, DATA_TEMP
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_INT0:
		SEI
		LDI TEMP, (1 << ISC01) ; INT 0 FALLING EDGE 
		STS EICRA, TEMP
		LDI TEMP, (1 << INT0)
		OUT EIMSK, TEMP
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CMDWRITE:
		RCALL DELAY_20ms
		MOV R18, TEMP
		ANDI R18, 0xF0 ; MASK LOW NIBBLE
		OUT LCD_PORT, R18    ; SEND HIGH NIBBLE
		SBI LCD_PORT, LCD_EN ; EN = 1 HIGH PULSE
		RCALL SDELAY          ; EXTEND EN PULSE
		CBI LCD_PORT, LCD_EN ; EN=0 FOR H-to-L PULSE
		RCALL DELAY_100us     

		SWAP TEMP
		ANDI TEMP, 0xF0 ; MASK HIGH NIBBLE
		OUT LCD_PORT, TEMP    ; SEND LOW NIBBLE
		SBI LCD_PORT, LCD_EN ; EN = 1 FOR HIGH PULSE
		RCALL SDELAY          ; EXTEND EN PULSE
		CBI LCD_PORT, LCD_EN ; EN=0 FOR H-to-L PULSE
		RCALL DELAY_100us
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DATAWRITE:
		RCALL DELAY_20ms
		MOV R18, TEMP
		ANDI R18, 0xF0 ; MASK LOW NIBBLE
		OUT LCD_PORT, R18    ; SEND HIGH NIBBLE
		SBI LCD_PORT, LCD_RS ; RS = 1 TO DATA
		SBI LCD_PORT, LCD_EN ; EN = 1 HIGH PULSE
		RCALL SDELAY          ; EXTEND EN PULSE
		CBI LCD_PORT, LCD_EN ; EN=0 FOR H-to-L PULSE
		RCALL DELAY_100us 

		SWAP TEMP
		ANDI TEMP, 0xF0 ; MASK HIGH NIBBLE
		OUT LCD_PORT, TEMP    ; SEND LOW NIBBLE
		SBI LCD_PORT, LCD_RS ; RS = 1 TO DATA
		SBI LCD_PORT, LCD_EN ; EN = 1 HIGH PULSE
		RCALL SDELAY          ; EXTEND EN PULSE
		CBI LCD_PORT, LCD_EN ; EN=0 FOR H-to-L PULSE
		RCALL DELAY_100us   
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SDELAY:
		NOP
		NOP
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY_100us:
		PUSH R17
		LDI R17, 62
DR0: 
		CALL SDELAY
		DEC R17
		BRNE DR0
		POP R17
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY_2ms:
		PUSH R17
		LDI R17,20
LDR0: 
		CALL DELAY_100us
		DEC R17
		BRNE LDR0
		POP R17
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY_20ms:
		PUSH R17
		LDI R17, 10
POWERUP:
		CALL DELAY_2ms
		DEC R17
		BRNE POWERUP
		POP R17
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;EXTERNAL INTERRUPT 0 REQUEST HANDLER;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT0_HANDLER:
		LDI DATA_TEMP, '0' ; RANDOM DATA	
		RCALL MSPI_TRANSMIT
		SBI SPI_PORT, REQ ; PAUSE SLAVE
		CPI DATA_TEMP, 0xFF
		BREQ CLEAR
		MOV TEMP, DATA_TEMP 
		RCALL DATAWRITE ; DISPLAY KEY CODE TO LCD
		LDI TEMP, 0xC0 ; FORCE CURSOR TO BEGINNING OF 2ND LINE
		RCALL CMDWRITE
		RJMP NEXT

CLEAR:
		LDI TEMP, 0x20 ; ASCII CODE OF SPACE CHAR
		RCALL DATAWRITE
		LDI TEMP, 0xC0 ; FORCE CURSOR TO BEGINNING OF 2ND LINE 
		RCALL CMDWRITE
		RJMP END

NEXT:
		RCALL DATA_TRANSMIT

END:
		LDI TEMP, (1 << INTF0)
		OUT EIFR, TEMP ; CLEAR INT0 INTERRUPT MANUALLY
		RETI
