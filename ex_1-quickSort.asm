DATA SEGMENT
    buff dw 2 dup(?)
     len dw 0
   array dw 255 dup(?)
    top dw -2
   stack_ dw 255 dup(?)
  topEle dw 0
   right dw 0
    left dw 0
   starts dw 0
     end_ dw 0
   out_ptr dw -2
  outStack dw 255 dup(?)
DATA ENDS


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

pushEle MACRO num
        push   ax 
         mov   si,[top]
         add   si,2
         mov   [top],si  
         mov   ax,num
         mov   [stack_+si],ax 
         pop   ax
ENDM

popEle  MACRO params
        push   dx
         mov   si,[top]
         mov   dx,[stack_+si]
         mov   [stack_+si],0
         mov   [topEle],dx
         sub   si,2
         mov   [top],si
         pop   dx
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


quickSort  macro
          local start,while_,while1_,while2_,changePart,outWhile,skip1,skip2,over
          pushEle 0
              mov ax,[len]
              sub ax,2
          pushEle ax
          
    start:
              cmp   [top],-2
               je   over_interval
           popEle
           assign   end_,[topEle]
           popEle   
           assign   starts,[topEle]
           assign   left,[starts]
           assign   right,[end_]
              
              mov   ax,[starts]
              mov   si,ax
              mov   ax,[array+si]
              jmp   while_
  over_interval:
              jmp   over_interval2
    while_:     
             push   ax
             push   bx
              mov   ax,[left]
              mov   bx,[right]
              cmp   ax,bx
              pop   bx
              pop   ax
              jae   outWhile
                                           
      while1_ :
             push   ax
             push   bx
              mov   ax,[left]
              mov   bx,[right]
              cmp   ax,bx
              pop   bx
              pop   ax                      ;while(left<right&&nums[right]>nums[start])
              jae   while2_
              
             push   ax
             push   bx
             push   si
              mov   si,[starts]
              mov   ax,[array+si]
              mov   si,[right]
              mov   bx,[array+si]
              cmp   ax,bx
              jnb   while2_
              sub   si,2
              mov   [right],si
              jmp   while1_
              
      while2_: 
             push   ax
             push   bx
              mov   ax,[left]
              mov   bx,[right]
              cmp   ax,bx
              pop   bx
              pop   ax                      ;while(left<right&&nums[left]<=nums[start])
              jae   changePart
              
             push   ax
             push   bx
             push   si
              mov   si,[starts]
              mov   ax,[array+si]
              mov   si,[left]
              mov   bx,[array+si]
              cmp   ax,bx
               jb   changePart
              add   si,2
              mov   [left],si
              jmp   while2_
over_interval2:
              jmp   over
   changePart:
              mov   si,[left]
              mov   di,[right]   
        changeEle   array+si,array+di
              jmp   while_

     outWhile:
              mov   si,[starts]
              mov   di,[left]   
        changeEle   array+si,array+di

              mov   bx,[starts]
              mov   cx,[left]
              sub   cx,2
              cmp   bx,cx
              jnl   skip1
          pushEle   bx
          pushEle   cx

         skip1:
              mov   bx,[left]
              mov   cx,[end_]
              add   bx,2
              cmp   bx,cx
              jnl   skip2
          pushEle   bx
          pushEle   cx

          skip2:
              jmp   start
        over:
    ENDM


code SEGMENT 
    ASSUME CS:CODE, DS:DATA
    start1:
            mov    ax,DATA
            mov    ds,ax
          input    array
      quickSort
      outPutAns
            mov    ah,4ch
            int    21h
code ENDS
            end    start1 