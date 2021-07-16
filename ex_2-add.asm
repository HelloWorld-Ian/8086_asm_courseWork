DATA SEGMENT
   notice1 db "please input the first numvber:","$"
   notice2 db "please input the second number:","$"
   notice3 db "the res is:","$"
      buff dw 2 dup(?)
      len1 dw 0
      num1 dw 1024 dup(?)
      len2 dw 0
      num2 dw 1024 dup(?)
     carry dw 0
   out_ptr dw -2
  outStack dw 255 dup(?)
DATA ENDS

  addNum MACRO
     local over
     begin:         
           mov   ax,0
           mov   bx,0
           mov   cx,0
           mov   dx,0

           mov   si,[len1]
           mov   di,[len2]
           sub   si,2
           sub   di,2
           mov   [len1],si
           mov   [len2],di

           cmp   si,0
            jl   skip1
           mov   ax,[num1+si]
        
     skip1:
           cmp   di,0
            jl   skip2
           mov   bx,[num2+di]
     
     skip2:
           add   ax,bx
           mov   cx,[carry]
           add   ax,cx
           mov   cx,0

           mov   [carry],0
           cmp   ax,10
            jb   skip3
           mov   [carry],1
    
    skip3:
           mov   bx,10
           div   bx

           mov   si,[out_ptr]
           add   si,2
           mov   [outStack+si],dx
           mov   [out_ptr],si
           
           cmp   [len1],0
            jg   begin
           cmp   [len2],0
            jg   begin

           cmp   [carry],0
            je   over
            mov   si,[out_ptr]
            add   si,2
            mov   [outStack+si],1
            mov   [out_ptr],si

     over:

  ENDM


sout  MACRO str
    mov    dx, offset str
    mov    ah, 09h
    int    21h
ENDM


  outPutAns  MACRO
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
             jne   outPrint
       over:
       ENDM


sout  MACRO str
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

input MACRO addr,len
       local   start,quit 
         mov   bx,0

   start:    
         mov   ah,01h
         int   21h
         cmp   al,0dh		
          je   quit
 
         mov   ah,0
         sub   al,30h	
        	
         mov   si,[len]
         mov   [addr+si],ax
         add   si,2
         mov   [len],si
         mov   si,0
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
		  clean    
		   sout    notice1
          input    num1,len1
      sout_char    13
	       sout    notice2
          input    num2,len2
      sout_char    13
         addNum
      outPutAns
            mov    ah,4ch
            int    21h
code ENDS
            end    start1 