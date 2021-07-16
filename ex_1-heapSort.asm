DATA SEGMENT
      buff dw 2 dup(?)
       min dw 0
       len dw 0
       pos dw 0
    center dw 0
      left dw 0
     right dw 0
center_val dw 0
  left_val dw 0
 right_val dw 0
   realLen dw 0
     array dw 255 dup(?)
   out_ptr dw -2
  outStack dw 255 dup(?)
DATA ENDS

   getTopMin  MACRO
       local  lop,over
         mov  ax,len    ;ax:pos
         mov  bx,2
         mov  dx,0
         div  bx
         mov  [realLen],ax

         div  bx
         sub  ax,1
         mov  [pos],ax

     lop:
         mov  cx,[pos]
into_lop:
         cmp  cx,-1
          je  over_interval
          
         mov  ax,cx
         mul  bx
         add  ax,1
         cmp  ax,[realLen]
          jb  skip1
         mov  ax,cx

   skip1:
         mul  bx
         mov  [left],ax

         mov  ax,cx
         mul  bx
         add  ax,2
         cmp  ax,[realLen]
          jb  skip2
         mov  ax,cx

   skip2:
         mul  bx
         mov  [right],ax 

         mov  ax,cx
         mul  bx
         mov  si,ax
         mov  ax,[array+si]
         mov  [center],si
         mov  [center_val],ax

         mov  si,[left]
         mov  ax,[array+si]
         mov  [left_val],ax

         mov  si,[right]
         mov  ax,[array+si]
         mov  [right_val],ax

        push  ax
        push  bx
        push  cx

         mov  ax,[left_val]
         mov  bx,[center_val]
         mov  cx,[right_val]

         cmp  bx,ax
          ja  chgVal

         cmp  bx,cx
          ja  chgVal

         pop  cx
         pop  bx
         pop  ax
         sub  cx,1
         jmp  into_lop

over_interval:
         jmp  over
  chgVal:
         cmp  ax,cx
         jnb  chgR
         mov  si,[left]
         jmp  chgPart
    chgR:
         mov  si,[right]
  
 chgPart:
         pop  cx
         pop  bx
         pop  ax
         mov  di,[center]
   changeEle  array+di,array+si
         mov  ax,si
         mov  dx,0
         mov  bx,2
         div  bx
         mov  cx,ax
         jmp  into_lop
   over:
  ENDM

  outPutAns  MACRO
          local    lop,skip
            mov    si,-2
            mov    bx,10
        lop:
            add    si,2
            cmp    si,[len]
            jnb    over
            mov    ax,[array+si]
   outStore:
            mov    dx,0
            div    bx
           push    ax
            mov    ax,0
            mov    al,dl
            mov    di,[out_ptr]
            add    di,2
            mov    [outStack+di],ax
            mov    [out_ptr],di
            pop    ax
            cmp    ax,0
             je    outPrint
            jmp    outStore
   outPrint:
            mov    di,[out_ptr]
            mov    ax,0
            mov    ax,[outStack+di]
            mov    [outStack+di],0
            add    al,48
      sout_char    al
            sub    di,2
            mov    [out_ptr],di

           

            cmp    di,-2
             je    out_comma
             
            jmp    outPrint

  out_comma:
           push    ax
            mov    ax,[len]
            sub    ax,2
            cmp    si,ax
            pop    ax
             je    skip
      sout_char    2ch

       skip:
            jmp    lop
       over:
       ENDM


sout  MACRO str
  clean
    mov    dx, offset str
    mov    ah, 09h
    int    21h
ENDM

sout_char  MACRO params
    mov    dl,params
    mov    ah,02h
    int    21h
ENDM

clean MACRO
    mov    ax,03h
    int    10h
ENDM

input MACRO addr
       local   start,quit 
         mov   bx,0
   start:    
         mov   ah,01h
         int   21h
         cmp   al,0dh		
          je   store
         cmp   al,02Ch
          je   store

        push   ax
        push   cx
         mov   cx,10
         mov   ax,bx
         mul   cx
         mov   bx,ax
         pop   cx
         pop   ax

 
         mov   ah,0
         sub   al,30h	
         add   bx,ax
         jmp   start
         
        	
   store:
         mov   si,[len]
         mov   [addr+si],bx
         mov   bx,0
         add   si,2
         mov   [len],si
         mov   si,0
         cmp   al,0dh		
          je   quit
         jmp   start
    quit:  

ENDM


changeEle  MACRO x,y
          mov  ax,[x]
          mov  bx,[y]
          mov  [y],ax
          mov  [x],bx
ENDM

assign  MACRO var,val
         push  ax
          mov  ax,val
          mov  [var],ax  
          pop  ax 
ENDM



code SEGMENT 
    ASSUME CS:CODE, DS:DATA
    start1:
            mov    ax,DATA
            mov    ds,ax
          input    array
      getTopMin
      outPutAns
            mov    ah,4ch
            int    21h
code ENDS
            end    start1 