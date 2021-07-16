DATA SEGMENT
      tree_str    db "the edge of the tree is:","$"
         error    db "the num of nodes can not be zero or one","$"
   ins_nodeNum    db "please input the num of the nodes:","$"
 ins_listOfNum    db "the list of the edges for node ","$"
          buff    dw 1 dup(?)
            pt    dw 0
       nodeNum    dw 0
          list    dw 256 dup(?)
         edges    dw 256 dup(?)
        parent    db 256 dup(?)
    union_arg1    dw 1 dup(?)
    union_arg2    dw 1 dup(?)
        node_1    dw 1 dup(?)
        node_2    dw 1 dup(?)
       ans_ptr    dw 1 dup(?)
           ans    dw 256 dup(?)
         
DATA ENDS

unionNode  MACRO index1,index2
             mov   di,index1
      findParent   di,parent
             mov   [union_arg1],di
             mov   di,index2
      findParent   di,parent
             mov   [union_arg2],di
             mov   di,[union_arg1]
             mov   ax,[union_arg2]
             mov   [parent+di],al
             mov   [union_arg1],0
             mov   [union_arg2],0
     ENDM

 isConnect  MACRO index1,index2
           local   return_
            push   di
            push   ax
            push   bx
             mov   di,index1
      findParent   di,parent
             mov   ax,di
             mov   di,index2
      findParent   di,parent
             mov   bx,di
             mov   di,0
             cmp   ax,bx
             jne   return_
             mov   di,01h       ;di:1 connect di:0 not connect
     return_:
             pop   bx
             pop   ax
     ENDM

findParent  MACRO index,parent           
         local    While_,return
          push    ax
          push    bx
          push    dx
          push    si
          mov     ax,0
  While_:
           mov    bx,index
           cmp    [parent+index],bl
            je    return
           mov    al,[parent+index]
           mov    si,ax
           mov    dl,[parent+si]
           mov    [parent+index],dl
           mov    al,[parent+index]
           mov    index,ax
           jmp    While_
  return:  
           pop    si
           pop    dx
           pop    bx
           pop    ax
ENDM

initParent  MACRO nodeNum,parent
       local    lop
        push    si
        push    cx
        push    ax
         mov    si,0  
         mov    ax,0
         mov    cx,[nodeNum]
    lop:             
         mov    [parent+si],al
         add    si,1
         add    ax,1
        loop    lop
         pop    ax
         pop    cx
         pop    si
ENDM

sout_char  MACRO params
    mov    dl,params
    mov    ah,02h
    int    21h
ENDM

sout  MACRO str
  sout_char    10
        mov    dx, offset str
        mov    ah, 09h
        int    21h
ENDM

clean MACRO
    mov    ax,03h
    int    10h
ENDM

  cin MACRO param
    mov    ah,01h
    int    21h
    sub    al,48
    mov    ah,0
    mov    [param],ax
ENDM

quit MACRO 
    mov    ah,4ch
    int    21h
ENDM

sort MACRO addr,len          ;选择排序
    
    push    si
    push    di
    push    ax
    push    bx
    push    dx

     mov    si,4
     mov    dx,len

 begin:
     cmp    si,dx
     jae    quit_              ;si大于等于总长,说明排序完成
     mov    di,si
     mov    ax,0FFFFH

choose:
     cmp    di,dx
     jnb    outChoose         ;si大于等于总长，说明已找出目前最小权值块
     cmp    [addr+di],ax
      jb    assign
  back:     
     add    di,6
     jmp    choose


outChoose:
         cmp    ax,0FFFFH
          je    add_si
        push    di
         mov    di,bx
 changeBlock    addr+si-4,addr+di
         pop    di
   add_si:
         add    si,6      ;si取值累加，si之前为已排好序部分   
         jmp    begin
assign:
     mov    ax,[addr+di]    ;保存当前最小值
     mov    bx,di      ;存储当前最小值所在块地址
     sub    bx,4
     jmp    back

  quit_:
     pop    dx
     pop    bx
     pop    ax
     pop    di
     pop    si
ENDM

changeBlock MACRO addr1,addr2
  changeEle  addr1,addr2
  changeEle  addr1+2,addr2+2
  changeEle  addr1+4,addr2+4
ENDM

changeEle  MACRO addr1,addr2
      push   ax
      push   bx
       mov   ax,[addr1]
       mov   bx,[addr2]
       mov   [addr1],bx
       mov   [addr2],ax
       pop   bx
       pop   ax
ENDM



code SEGMENT 
    ASSUME CS:CODE, DS:DATA
    start:
          clean
            mov    ax,DATA
            mov    ds,ax
           sout    ins_nodeNum
            cin    nodeNum
            cmp    [nodeNum],1

            mov    bx,0

             ja    continue
           sout    error
           quit

            mov    si,[pt]
 continue:          
            cmp    bx,[nodeNum]
             je    ToCollet
           sout    ins_listOfNum
           push    bx
            add    bx,48
      sout_char    bl
            pop    bx
           
      sout_char    58
      sout_char    32

            mov    ax,0
   While_:  
            cmp    ax,bx
             je    coutZero
           push    ax
            cin    [list+si]
           push    ax
      sout_char    44
            pop    ax
            pop    ax
            jmp    lop
 coutZero: 
           push    ax
      sout_char    48
      sout_char    44
            pop    ax
      
      lop:
            add    ax,1
            add    si,2
            cmp    ax,[nodeNum]
            jne    While_
    break:  
            add    bl,1
            jmp    continue

 ToCollet:
            mov    ax,0
            mov    bx,0
            mov    cx,0
            mov    dx,0
            mov    di,0
            mov    si,0

  collect:
            mov    ax,0
            mov    cx,[nodeNum]
    colop:  
            mov    dx,[list+si]
            cmp    dx,0
             je    out_colop

            mov    [edges+di],bx             ;edges块赋值，说明边为有效边（权值不为零），块结构：结点A，结点B，边权值
            mov    [edges+di+2],ax
           push    ax
            mov    ax,[list+si]
            mov    [edges+di+4],ax
            pop    ax

            add    di,6
           push    ax
            mov    ax,[pt]
            add    ax,6
            mov    [pt],ax                  ;[pt]:记录edges块长度，（len*3）
            pop    ax
 
out_colop:   
            add    si,2
            add    ax,1
           loop    colop  
            add    bx,1
            cmp    bx,[nodeNum]
            jne    collect

            mov    ax,[nodeNum]
            sub    ax,1
            mov    bx,[nodeNum]
            mul    bx

            mov    cx,5
            mov    si,0
            
           sort    edges,[pt]
     initParent    nodeNum,parent
            
            mov    ax,0
            mov    bx,0
            mov    cx,0
            mov    dx,0
            mov    si,0
            mov    di,0

            mov    cx,[pt]
            mov    si,0

   getEdges:
            cmp    si,[pt]
            jae    quits_interval
            mov    ax,[edges+si]
            mov    [node_1],ax
            mov    ax,[edges+si+2]
            mov    [node_2],ax
      isConnect    [node_1],[node_2]
            jmp    continue1
      
quits_interval:
            jmp    quits_

      continue1:
            cmp    di,01h
             je    AnsLop_interval
            
           push    di
            mov    ax,[node_1]
            mov    di,[ans_ptr]
            mov    [ans+di],ax
            mov    ax,[node_2]

            mov    [ans+di+2],ax
            mov    ax,[edges+si+4]
            mov    [ans+di+4],ax
            add    di,6
            mov    [ans_ptr],di
            pop    di
            jmp    continue2

AnsLop_interval:
            jmp    AnsLop

   continue2:
      unionNode    [node_1],[node_2]

      AnsLop:
            add    si,6
            jmp    getEdges

      quits_:


            mov    cx,[nodeNum] 
            sub    cx,1
            mov    si,0
            
            sout_char    10
                 sout  tree_str
            sout_char  10
      tests:
            sout_char  40
                  mov  ax,[ans+si]
                  add  al,48
            sout_char  al
            sout_char  44
                  mov  ax,[ans+si+2]
                  add  ax,48
            sout_char  al
            sout_char  44
                  mov  ax,[ans+si+4]
                  add  ax,48
            sout_char  al
            sout_char  41
                  add  si,6
                 loop  tests
           
             mov  ah,4ch
             int  21h    
            
            
            

code ENDS
            end    start 