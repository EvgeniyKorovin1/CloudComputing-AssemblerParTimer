.device ATmega8

; Константы
.equ F_CPU = 8000000
.equ BAUD = 9600
.equ UBRR_VALUE = ((F_CPU/(16*BAUD))-1)

; Интервалы таймеров
.equ TIMER1_INTERVAL = 7811   ; около 1 сек при F_CPU = 8МГц и предделителе = 1024
.equ TIMER2_INTERVAL = 124    ; Примерно 4мс при определенном предделителе

; Длины строк
.equ PING_LEN = 6 ; "ping\r\n" ('p', 'i', 'n', 'g', '\r', '\n' - 6 символов)
.equ PONG_LEN = 6 ; "pong\r\n"

; Адреса регистров для ATmega8
.equ r_SPL    = 0x3d
.equ r_SPH    = 0x3e

; Регистры UART
.equ r_UBRRL  = 0x09
.equ r_UBRRH_UCSRC = 0x20
.equ r_UCSRB  = 0x0a
.equ r_UCSRA  = 0x0b
.equ r_UDR    = 0x0c

; Таймеры
.equ r_TCCR1B = 0x2e
.equ r_OCR1AH = 0x2b
.equ r_OCR1AL = 0x2a

.equ r_TCCR2  = 0x25
.equ r_OCR2   = 0x23

; TIMSK – регистр разрешения прерываний
.equ r_TIMSK  = 0x39

; Биты UART
.equ RXEN   = 4
.equ TXEN   = 3
.equ UDRE   = 5
.equ URSEL  = 7
.equ UCSZ1  = 2
.equ UCSZ0  = 1

; Биты Timer1
.equ WGM12  = 3
.equ CS12   = 2
.equ CS10   = 0
.equ OCIE1A = 4

; Биты Timer2
.equ WGM21  = 1
.equ CS22   = 2
.equ CS21   = 1
.equ CS20   = 0
.equ OCIE2  = 7

.equ RAMEND = 0x45F

; Векторы прерываний
.cseg
.org 0x0000
    rjmp init

.org 0x000E
    rjmp TIMER2_COMP_ISR     ; Timer2 Compare Match
.org 0x0014
    rjmp TIMER1_COMPA_ISR    ; Timer1 Compare Match 

.org 0x0002
    reti
.org 0x0004
    reti
.org 0x0006
    reti
.org 0x0008
    reti
.org 0x000A
    reti
.org 0x000C
    reti
; 0x000E занято под TIMER2_COMP_ISR
.org 0x0010
    reti
.org 0x0012
    reti
; 0x0014 занято под TIMER1_COMPA_ISR
.org 0x0016
    reti
.org 0x0018
    reti
.org 0x001A
    reti
.org 0x001C
    reti
.org 0x001E
    reti
.org 0x0020
    reti
.org 0x0022
    reti
.org 0x0024
    reti
.org 0x0026
    reti
.org 0x0028
    reti
.org 0x002A
    reti
.org 0x002C
    reti

.org 0x0100

; Сегмент данных
.dseg
ping_str: .byte PING_LEN
pong_str: .byte PONG_LEN

; Код 
.cseg

init:
    ldi r16, high(RAMEND)
    out r_SPH, r16
    ldi r16, low(RAMEND)
    out r_SPL, r16

    ldi r30, low(ping_str)
    ldi r31, high(ping_str)
    ldi r16, 'p'
    st Z+, r16
    ldi r16, 'i'
    st Z+, r16
    ldi r16, 'n'
    st Z+, r16
    ldi r16, 'g'
    st Z+, r16
    ldi r16, 0x0D ; '\r'
    st Z+, r16
    ldi r16, 0x0A ; '\n'
    st Z+, r16

    ldi r30, low(pong_str)
    ldi r31, high(pong_str)
    ldi r16, 'p'
    st Z+, r16
    ldi r16, 'o'
    st Z+, r16
    ldi r16, 'n'
    st Z+, r16
    ldi r16, 'g'
    st Z+, r16
    ldi r16, 0x0D 
    st Z+, r16
    ldi r16, 0x0A 
    st Z+, r16

    ldi r16, high(UBRR_VALUE)
    out r_UBRRH_UCSRC, r16
    ldi r16, low(UBRR_VALUE)
    out r_UBRRL, r16
    ldi r16, (1<<RXEN)|(1<<TXEN)
    out r_UCSRB, r16
    ldi r16, (1<<URSEL)|(1<<UCSZ1)|(1<<UCSZ0)
    out r_UBRRH_UCSRC, r16

    ; Настройка Timer1 (CTC)
    ldi r16, low(TIMER1_INTERVAL)
    out r_OCR1AL, r16
    ldi r16, high(TIMER1_INTERVAL)
    out r_OCR1AH, r16
	
    ; CTC + предделитель 1024
    ldi r16, (1<<WGM12)|(1<<CS12)|(1<<CS10)
    out r_TCCR1B, r16
    ; Разрешаем прерывание Timer1 Compare
    ldi r16, (1<<OCIE1A)
    out r_TIMSK, r16

    ; Настройка Timer2 (CTC)
    ldi r16, TIMER2_INTERVAL
    out r_OCR2, r16
	
    ; CTC + предделитель 256: (CS22=1,CS21=1)
    ldi r16, (1<<WGM21)|(1<<CS22)|(1<<CS21)
    out r_TCCR2, r16
    ; Разрешаем прерывание Timer2 Compare
    in r16, r_TIMSK
    ori r16, (1<<OCIE2)
    out r_TIMSK, r16

    ; Глобально разрешаем прерывания
    sei

main_loop:
    rjmp main_loop

; Подпрограммы
;-----------------------------------------
uart_send_char:
    sbis r_UCSRA, UDRE
    rjmp uart_send_char
    out r_UDR, r16
    ret

uart_send_string:
send_char_loop:
    ld r16, Z+
    rcall uart_send_char
    dec r17
    brne send_char_loop
    ret


; Обработчики прерываний
;-----------------------------------------
TIMER1_COMPA_ISR:
    push r24
    push r25
    push r16
    push r17
    push r30
    push r31

    ldi r30, low(ping_str)
    ldi r31, high(ping_str)
    ldi r17, PING_LEN
    rcall uart_send_string

    pop r31
    pop r30
    pop r17
    pop r16
    pop r25
    pop r24
    reti

TIMER2_COMP_ISR:
    push r24
    push r25
    push r16
    push r17
    push r30
    push r31

    ldi r30, low(pong_str)
    ldi r31, high(pong_str)
    ldi r17, PONG_LEN
    rcall uart_send_string

    pop r31
    pop r30
    pop r17
    pop r16
    pop r25
    pop r24
    reti
