DATA SEGMENT
    maxlen db "the max len is 10","$"
    error db "index out of range!!","$"
    instruction  db "press 1 to add, press 2 to delete, press 3 to display:","$"
 addAndDel_ins_index db "input the index:","$"
   add_ins_val db "input the value:","$"
   display_ins db "the linkedList :","$"            
      len dw 0
    empty dw 2
     list dw 4
     list_body dw 1024 dup(?)                          
DATA ENDS



print  MACRO c
     push dx
     push ax
     mov  dl,c
     mov  ah,02h
     int  21h  
     pop  ax 
     pop  dx
ENDM

addVal MACRO val,index
    local   move,mov_jmp,no_error
      mov   bx,index
      mov   ax,[len]
      cmp   bx,ax
      jbe   no_error
      mov   dx,offset error
      mov   ah,09h
      int   21h
      mov   ah,4ch
      int   21h

no_error:
      mov   ax,[len]     
      cmp   ax,10
      jne   no_too_long
      sout  maxlen
      mov   ah,4ch
      int   21h
no_too_long:    
      mov   di,0
      mov   bx,index
      cmp   bx,0
       je   mov_jmp   
      mov   cx,index 
      
 move:
      mov   di,[list+di]
     loop   move
 mov_jmp:
      mov   si,empty
      mov   [list+si],val
      mov   dx,[list+di]
      add   si,2
      mov   [list+di],si
      mov   [list+si],dx
      add   si,2  
      mov   [empty],si
      mov   ax,[len]
      add   ax,1
      mov   [len],ax
ENDM

 del MACRO index
    local   move,jump,no_error
      mov   bx,index
      sub   bx,48
      mov   ax,[len]
      cmp   bx,ax
       jb   no_error
      mov   dx,offset error
      mov   ah,09h
      int   21h
      mov   ah,4ch
      int   21h
no_error:      
      mov   di,0
      mov   bx,index
      cmp   bx,0
       je   jump   
      mov   cx,bx
    move:
      mov   di,[list+di]
     loop   move
    jump:
      mov   si,[list+di]
      mov   ax,[list+si]
      mov   [list+di],ax
      mov   ax,[len]
      sub   ax,1
      mov   [len],ax
ENDM

 get MACRO index
    local   move,get_jmp
      mov   di,0
      mov   bx,index
      cmp   bx,0
       je   get_jmp
      mov   cx,index
 move:
      mov   di,[list+di]
     loop   move
 get_jmp:
      push  si
      mov   si,[list+di]
      mov   ax,[list+si-2]
      pop   si   
ENDM

display_list  MACRO 
    local   break,lop,print_digit,print_sign
      mov   si,0
 lop: 
      mov   cx,[len]
      cmp   si,cx
      jae   break
      get   si
print_digit:
      mov   dl,al
      add   dl,48
    print   dl
print_sign:
      add   si,1
      cmp   si,[len]
       je   lop
    print   45
    print   62
      mov   dl,0
      jmp   lop
break:
ENDM

clean  MACRO 
          mov   ax,03h			
	     int   10h 
ENDM

sout   MACRO str
       mov     dx,offset str
       mov     ah,09h
       int     21h
ENDM

getParam  MACRO num
       mov     al,07h
       mov     ah,0ch
       int     21h
ENDM


code SEGMENT 
    ASSUME CS:CODE, DS:DATA
    start:
         push   cs
          mov   ax,DATA
          mov   ds,ax
    clear: 
         clean
          sout    instruction
  process:
     getParam     choose
          
          cmp     al,13
           je     clear
          
          cmp     al,49
           je     add_val_interval

          cmp     al,50
           je     del_val

          cmp     al,51
           je     display_val

           jmp    clear

  del_val:
        clean
         sout     addAndDel_ins_index
     getParam     index
          mov     bl,al
          del     bx
          jmp     clear

add_val_interval:
          jmp     add_val

clear_interval:
           jmp    clear

   

display_val:
          clean
           sout  display_ins
   display_list
      getParam   refresh
           cmp   al,13
            je   clear_interval
           jmp   display_val

  add_val:
         clean
          sout    addAndDel_ins_index
     getParam     index
          mov     ah,0
          mov     bl,al
          sub     bl,48 
        clean
         sout     add_ins_val
     getParam     val
          mov     ah,0
          mov     dl,al
          sub     dl,48
       addVal     dx,bx
          jmp     clear

code ENDS
          end     start 