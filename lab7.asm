IDEAL
MODEL SMALL 
STACK 256

DATASEG
string db	254		;максимальна довжина введення 
db 254 dup ('*')	;буфер.

system_message_1 db "Input something\ " ,'$' 
display_message_0 db "----menu begin	", 13, 10, '$'
display_message_1 db "a - for count", 13, 10, '$' 
display_message_2 db "S - for beep",	13, 10, '$'
display_message_3 db "e - for smallest",	13, 10, '$'
display_message_4 db "d - for exit",	13, 10, '$'
display_message_5 db "----programm for lab is END !!! - for exit", 13, 10, '$' 
a1 dw 0FFh
a2 dw 2h
a3 dw 1h
a4 dw 2h
a5 dw 3h
array_smallest db 14, 6, 9, 10, 15, 4, 7, 2, 5, 12
delay dw 3900

CODESEG
Start:
mov ax, @data 
mov ds, ax

main_cусl:
 
call disp 		; викликаємо функцію відображення дисплею
call input_foo		; викликаємо функцію введення символу
cmp ax, 061h ; a ascii =61h 
je Count   	 ; якщо натиснули a переходимо до мітки з обчисленнями
cmp ax, 053h ; S ascii =71h 
je Beep		; якщо натиснули S переходимо до мітки з відтворенням звуку
cmp ax, 065h ; e ascii =71h 
je Find_smallest	; якщо натиснули e переходимо до мітки з обчисленням найменшого едемента масива
cmp ax, 064h ; d ascii =71h 
je Exit		; якщо натиснули d переходимо до мітки з виходом
jmp main_cусl	; якщо натиснули не те що треба - повторюємо цей цикл

Beep:
call sound	; викликаємо функцію відтворення звуку 
jmp main_cусl	; переходимо до основного меню

Count:
mov ax, [a1]	; додаємо а1
sub ax, [a2]	; віднімаємо а2
mul [a3]	; множимо на а3
mul [a4]	; множимо на а4
add ax, [a5]	; додаємо а5
not ax			; алгоритм переведення з додаткового коду в звичайний
				; інверсуємо біти ax
inc ax		; додаємо 1

and ax, 0Fh		; очищуємо старший регістр ax
;налаштовуємося на вивід
		xor	cx,cx
		mov	bx,10		; основа системи числення в яку переводимо
;отримуємо останню цифру числа і запам'ятовуємо в циклі
isDiv:		xor	dx,dx
		div	bx
		push dx
		inc	cx	;рахуємо кількість цифр
		or	ax,ax	;повторюємо цикл, доки не 0
		jnz	isDiv
;виводимо число в потрібному порядку в циклі
isOut:		pop	ax
		or	al,30h
		int	29h
		loop	isOut

jmp main_cусl	; переходимо до основного меню

Find_smallest:
mov al, [array_smallest]	; перше значення масиву кладемо в регістр al
xor di, di			; очищуємо di
inc di				; збільшуємо di
mov cx, 10			; лічильник циклу - кількість елементів масиву

smallest:
cmp al, [array_smallest + di]	; порівнюємо кожний елемент масиву з на той момент найменшим елементом масиву
jle common					; якщо al більше за елемент масиву - це найменший на цей момент елемент масиву
mov al, [array_smallest + di] 
common:
inc di		; збільшуємо di
loop smallest
;налаштовуємося на вивід
		xor	cx,cx
		mov	bx,10		; основа системи числення в яку переводимо
;отримуємо останню цифру числа і запам'ятовуємо в циклі
isDiv2:		xor	dx,dx
		div	bx
		push dx
		inc	cx	;рахуємо кількість цифр
		or	ax,ax	;повторюємо цикл, доки не 0
		jnz	isDiv2
;виводимо число в потрібному порядку в циклі
isOut2:		pop	ax
		or	al,30h
		int	29h
		loop	isOut2
jmp main_cусl	; переходимо до основного меню

Exit:
mov dx, offset display_message_5 ; виводимо повідомлення на екран
call display_foo
mov ax,04C00h	;
int 21h	; переривання DOS

PROC disp	; виводимо всі повідомлення з меню на екран
mov dx, offset display_message_0 
call display_foo
mov dx, offset display_message_1 
call display_foo
mov dx, offset display_message_2 
call display_foo
mov dx, offset display_message_3 
call display_foo
mov dx, offset display_message_4 
call display_foo
mov dx, offset system_message_1 
call display_foo
ret
ENDP disp

PROC display_foo	; dx - зміщення, функція виводу на екран
mov ah,9 
int 21h 
xor dx, dx 
ret
ENDP display_foo;		 

PROC input_foo	; введення символів, результат - ax
mov ah, 0ah		; код для введення символа 
mov dx, offset string	; dx <- зміщення string
int 21h	; викликаємо 0ah функцію DOS int 21h
xor ax, ax
mov bx, offset string 
mov ax, [bx+1]
shr ax, 8 
ret
ENDP input_foo 

PROC sound
in   al,  61h       ;отримуємо стан динаміка
push ax             ;і зберігаємо його
or   al,  00000011b ;встановлюємо 2 молодших біта
out  61h, al        ;включаємо динамік 
mov  al,  0B6h        ;висота звука (частота)
out  42h, al        ;включаємо таймер, який
	              ;буде видавати імпульси на 
	              ;динамік із заданою частотою
mov  cx,  [delay]     ;встановдюємо тривалість звука

zvuk:             	  ; подвійний цикл для довшої затримки
push cx	             
mov  cx,  [delay]
cicle:
   loop cicle
pop  cx
loop zvuk

pop  ax             ;отримуємо вихідний стан
and  al,  11111100b ;скидуємо два молодших біта
out  61h, al	      ;виключаємо динамік 
ret
ENDP sound

END Start
