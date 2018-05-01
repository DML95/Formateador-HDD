;   a:b =  a:b * 0:d
;       ||
;   w:b =  d*b
;   x:y =  d*a
;     w += x
;     a =  w

;void mul64x32Bits(*long,int)
@Funciones.mul64x32Bits:
push ebp
mov ebp,esp
    xchg edi,dword[ebp+8]
    mov eax,dword[ebp+12]   ;d
    movd xmm0,eax
    mul dword[edi]	   ;w:b = d*b
    mov dword[edi],eax	   ;b
    mov ecx,edx 	   ;w
    add edi,4
    movd eax,xmm0
    mul dword[edi]	   ;x:y = d*a
    add ecx,edx 	   ;w += x
    mov dword[edi],ecx	   ;a =  w
    mov edi,dword[ebp+8]
mov esp,ebp
pop ebp
ret 4

;void div64Bits(*long,*long)
@Funciones.div64Bits:
push ebp
mov ebp,esp
    mov eax,dword[edi+4]
    xor edx,edx
    div ecx
    mov eax,dword[edi]
    div ecx
pop ebp
ret 4

;void incXmm0(xmm0)
@Funciones.incXmm0:
    pxor xmm1,xmm1
    xor eax,eax
    inc eax
    movd xmm1,eax
    paddq xmm0,xmm1
ret

;void decXmm0(xmm0)
@Funciones.decXmm0:
    pxor xmm1,xmm1
    xor eax,eax
    inc eax
    movd xmm1,eax
    psubq xmm0,xmm1
ret

;bool distinto64bitsXmm0Xmm1(xmm0,xmm1)
@Funciones.distinto64bitsXmm0Xmm1:
    xor eax,eax
    pextrw ecx,xmm0,0
    pextrw edx,xmm1,0
    cmp ecx,edx
    jne ^Funciones.igual64bitsXmm0Xmm1.no
    pextrw ecx,xmm0,1
    pextrw edx,xmm1,1
    cmp ecx,edx
    jne ^Funciones.igual64bitsXmm0Xmm1.no
    pextrw ecx,xmm0,2
    pextrw edx,xmm1,2
    cmp ecx,edx
    jne ^Funciones.igual64bitsXmm0Xmm1.no
    pextrw ecx,xmm0,3
    pextrw edx,xmm1,3
    cmp ecx,edx
    jne ^Funciones.igual64bitsXmm0Xmm1.no
    not eax
    ^Funciones.igual64bitsXmm0Xmm1.no:
ret

;void memQwordADoubleEnXmm0(*mem)
@Funciones.memQwordADoubleEnXmm0:
push ebp
mov ebp,esp
    pxor xmm0,xmm0
    mov eax,dword[ebp+8]
    xor edx,edx
    not dx
    inc edx
    cvtsi2sd xmm2,edx
    movzx ecx,word[eax+6]
    cvtsi2sd xmm1,ecx
    addsd xmm0,xmm1
    mulsd xmm0,xmm2
    movzx ecx,word[eax+4]
    cvtsi2sd xmm1,ecx
    addsd xmm0,xmm1
    mulsd xmm0,xmm2
    movzx ecx,word[eax+2]
    cvtsi2sd xmm1,ecx
    addsd xmm0,xmm1
    mulsd xmm0,xmm2
    movzx ecx,word[eax]
    cvtsi2sd xmm1,ecx
    addsd xmm0,xmm1
pop ebp
ret 4