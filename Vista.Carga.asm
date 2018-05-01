;hwnd ventanas(*estructura,hwndDefecto)
@Vista.Carga.ventanas:
push ebp
mov ebp,esp
    xchg edi,dword[ebp+8]
    ^Vista.Carga.crearVentanas.bucle:
	mov eax,dword[edi] ;*clase
	test eax,eax
	je ^Vista.Carga.crearVentanas.fin
	xor edx,edx
	push edx
	push edx
	push edx
	mov edx,dword[edi+12] ;hwndPadre
	lea ecx,dword[ebp+12] ;hwndDefecto
	test edx,edx
	cmove edx,ecx
	push dword[edx]
	push dword[edi+36] ;alto
	push dword[edi+32] ;ancho
	push dword[edi+28] ;y
	push dword[edi+24] ;x
	push dword[edi+16] ;estilo
	push dword[edi+4] ;*testo(no obligatorio)
	push eax
	push dword[edi+20] ;estiloEx
	call[CreateWindowExA]
	mov edx,dword[edi+8] ;*hwndVentana(no obligatorio)
	test edx,edx
	je ^Vista.Carga.crearVentanas.hwndVentana
	    mov word[edx],ax
	^Vista.Carga.crearVentanas.hwndVentana:
	add edi,40
    jmp ^Vista.Carga.crearVentanas.bucle
    ^Vista.Carga.crearVentanas.fin:
    mov edi,dword[ebp+8]
pop ebp
ret 4*2

;void commonControls(*estructura)
@Vista.Carga.commonControls:
push ebp
mov ebp,esp
    sub esp,8 ;reservo la estructura INITCOMMONCONTROLSEX
    xchg edi,dword[ebp+8]
    mov dword[ebp-8],8
    ^Vista.Carga.cargarCommonControls.bucle:
	mov eax,dword[edi]
	test eax,eax
	je ^Vista.Carga.cargarCommonControls.fin
	lea edx,dword[ebp-4]
	mov dword[edx],eax
	sub edx,4
	push edx
	call[InitCommonControlsEx]
	add edi,4
    jmp ^Vista.Carga.cargarCommonControls.bucle
    ^Vista.Carga.cargarCommonControls.fin:
    mov dword[ebp+8],edi
mov esp,ebp
pop ebp
ret 4