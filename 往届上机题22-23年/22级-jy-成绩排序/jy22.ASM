dataseg segment
    prompt_in   db  'Input: ', '$'
    prompt_out  db  'Output: ', '$'

    input_num           dw ?
    input_buffer        db 30
    input_buffer_len    db ?
    input_buffer_data   db 30 dup(?)

    output_num      dw  ?

    nums_len    dw  0
    nums        dw  30 dup (?)

dataseg ends

codeseg segment
    assume cs:codeseg, ds:dataseg, es:dataseg
main proc far
    push ds
    xor ax, ax
    push ax
    mov ax, dataseg
    mov ds, ax
    mov es, ax

    lea si, nums
main_loop:

    mov ah, 09h
    lea dx, prompt_in
    int 21h

    call read_num

    mov ah, 09h
    lea dx, prompt_out
    int 21h

    mov ax, input_num

    lea di, nums
    mov cx, nums_len
    cmp cx, 0
    je main_ok

    update_loop:        ; 搜索前面的，看看有没有比ax小的，就交换，来保证ax是最小的
        cmp ax, [di]
        jb next
        
        xchg ax, [di]

        next:
        mov bx, [di]
        mov output_num, bx
        call write_num        
        
        add di, 2
        loop update_loop

    main_ok:
    mov [si], ax        ; 把最小的数插在后面
    mov output_num, ax
    call write_num
    add si, 2
    inc nums_len

    call newline 

    jmp main_loop

    pop ax
    pop ds
    mov ax, 4C00h
    int 21h
main endp


; 输入一个整数，存入input_num
read_num proc near
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    call newline
    
    xor ch, ch
    mov cl, input_buffer_len
    mov ax, 0
    lea si, input_buffer_data
    mov bx, 10
    xor dx, dx

    read_loop:
        mul bx
        mov dl, [si]
        and dl, 0Fh
        add ax, dx
        inc si
        loop read_loop

    mov input_num, ax

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
read_num endp

; 输出一个整数output_num
write_num proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, output_num  ; 被除数
    mov bx, 10          ; 除数
    mov cx, 0           ; 个数

    stk_loop:
        xor dx, dx      ; 清空余数
        div bx          ; /10
        push dx         ; 余数入栈
        inc cx
        cmp ax, 0
        jnz stk_loop

    mov ah, 02h
    write_loop:
        pop dx
        add dl, '0'
        int 21h
        loop write_loop
    
    mov dl, ' '
    int 21h

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
write_num endp

; 换行
newline proc near
    push ax
    push dx
    mov ah, 02h

    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    pop dx
    pop ax
    ret
newline endp

codeseg ends

end main
