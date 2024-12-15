.MODEL SMALL
.DATA
    ln            db 80*25 dup(?),'$'  
    ln_2          db 22 dup(?)
    row           db 9
    column        db 0
    currentline   db 2
    currentchar   db 0
    d1            db '|*************************************************|$'
    d2            db '|                   Text Editor                   |$'
    d3            db '|                                                 |$'
    d4            db '|         ESC = Exit || CTRL+S = Save File        |$'
    d5            db '|                                                 |$'
    d6            db '|*************************************************|$'
    FName         db 'File.txt $'
    file          db 128 dup(?),'$'  
    HANDLE        dw ?
    header        db 80 dup('_'),'$'
    headfile      db 'File Name:=>  $'
    newDir        db 'C:\NewDir', 0 
    fullPath      db 'C:\NewDir\File.txt', 0 

.CODE

newline macro
    mov dl, 10     
    mov ah, 2
    int 21h   
    mov dl, 13     
    mov ah, 2
    int 21h
endm

remove macro
    mov dx, 8      
    mov ah, 2
    int 21h
    mov dx, 32     
    int 21h
    mov dx, 8      
    int 21h
endm

goto_pos macro row, col
    mov ah, 02h  
    mov dh, row
    mov dl, col
    int 10h
endm

clrScrn macro
    mov ah, 02h  
    mov dh, 0
    mov dl, 0
    int 10h      
    mov ah, 0Ah  
    mov al, 00h  
    mov cx, 2000 
    int 10h      
endm 

debug macro arg
    mov dx, arg  
    mov ah, 2
    int 21h
endm
 
style proc  
    goto_pos 1, 12
    mov dx, offset d1
    mov ah, 9
    int 21h
    goto_pos 2, 12
    mov dx, offset d2
    mov ah, 9
    int 21h
    goto_pos 3, 12
    mov dx, offset d3
    mov ah, 9
    int 21h
    goto_pos 4, 12
    mov dx, offset d4
    mov ah, 9
    int 21h
    goto_pos 5, 12
    mov dx, offset d5
    mov ah, 9
    int 21h
    goto_pos 6, 12
    mov dx, offset d6
    mov ah, 9
    int 21h  
    goto_pos 7, 22
    mov dx, offset headfile
    mov ah, 9
    int 21h 
    goto_pos 7, 35
    mov dx, offset FName    
    mov ah, 9
    int 21h  
    goto_pos 8, 0
    mov dx, offset header  
    mov ah, 9
    int 21h  
    ret
style endp

upper_bar proc
     call style
    ret            
upper_bar endp

MAIN PROC
    mov ax, @DATA
    mov ds, ax 
    
    mov ah, 01h       
    mov cx, 07h       
    int 10h           
    clrScrn           
    call upper_bar    
    
    goto_pos 9, 0     
    mov si, offset ln 
    mov di, offset ln_2
    MAIN_LOOP:                                   
    mov ah, 00h
    int 16h
    
    cmp ah, 01h            ;escape key
    je EXIT
    cmp al, 13h            ;CTRL+S
    je SAVE
    cmp ah, 48h            ;up 
    je UP
    cmp ah, 50h            ;down
    je DOWN
    cmp ah, 4Bh            ;left
    je LEFT
    cmp ah, 4Dh            ; right 
    je RIGHT                           
    cmp ah, 1Ch            ;enter 
    je ENTER                                 
    cmp ah, 0Eh            ;backspace 
    je BACKSPACE       
    cmp column, 79
    je ENTER
    mov dl, al             
    mov ah, 2
    int 21h        
    mov [si], al           
    inc si
    inc currentchar        
    inc column             
    goto_pos row, column
    jmp MAIN_LOOP
         
    EXIT:
    mov ah, 4ch
    int 21h
        
    SAVE:
    
    mov dx, offset newDir  
    mov ah, 39h            
    int 21h
    jc CREATE_DIR          

    
    jmp OPEN_FILE

    CREATE_DIR:
    
    mov dx, offset newDir
    mov ah, 39h           
    int 21h
       

    OPEN_FILE:
    
    mov dx, offset fullPath 
    mov ah, 3Ch             
    mov cx, 0               
    int 21h                
               

    mov HANDLE, ax        
    mov ah, 40h           
    mov bx, HANDLE        
    mov cx, 2000          
    mov dx, offset ln     
    int 21h               
    mov ah, 3Eh           
    mov bx, HANDLE         
    int 21h              

    jmp MAIN_LOOP    
           
    UP:
    cmp row, 2
    je MAIN_LOOP 
    dec currentline
    dec row
    goto_pos row, column
    jmp MAIN_LOOP
         
    DOWN:
    inc currentline
    inc row
    goto_pos row, column 
    jmp MAIN_LOOP
           
    LEFT:
    dec column
    goto_pos row, column
    jmp MAIN_LOOP
    
    RIGHT:
    inc column
    goto_pos row, column
    jmp MAIN_LOOP
    
    ENTER:      
    newline        
    mov [si], 10   
    inc si
    mov dl, currentchar
    mov [di], dl
    inc di
    inc currentline
    mov currentchar, 0
    inc row           
    mov column, 0     
    goto_pos row, 0   
    jmp MAIN_LOOP
    
    BACKSPACE:
    cmp currentline, 2
    je rmv            
    cmp currentchar, 0
    je goBackLine     
   
    remove
    dec currentchar
    dec column
    dec si
    mov [si], 00h
    jmp MAIN 

    rmv:
    remove
    dec currentchar
    dec column
    dec si             
    mov [si], 00h      
    jmp MAIN_LOOP
    goBackLine:
    dec currentline
    dec row
    dec di
    mov dl, [di]
    mov column, dl
    goto_pos currentline, dl
    mov dl, [di]            
    mov currentchar, dl     
    jmp MAIN_LOOP
        

MAIN ENDP
END MAIN