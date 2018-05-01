;--LOGICA DE LA VENTANA

;void repintarVentana(hwndVentana,hwndHijo)
@Vista.Logica.repintarVentana:
push ebp
mov ebp,esp
    sub esp,8*4 ;reservo espacio para rect
    mov edx,dword[ebp+12]
    test edx,edx
    je ^Vista.Logica.repintarVentana.todaVentana
	push edx ;hwndHijo
	push dword[ebp+8] ;hwndVentana
	lea edx,dword[ebp-8*4] ;*rect
	push edx
	call @Vista.Logica.getRect
	lea edx,dword[ebp-8*4] ;*rect
    ^Vista.Logica.repintarVentana.todaVentana:
    xor eax,eax
    not eax
    push eax
    push edx
    push dword[ebp+8]  ;hwndVentana
    call[InvalidateRect]
mov esp,ebp
pop ebp
ret 4*2

;void getRect(*rect,hwndVentana,hwndHijo)
@Vista.Logica.getRect:
push ebp
mov ebp,esp
    push dword[ebp+8] ;*rect
    push dword[ebp+16] ;hwndHijo
    call[GetClientRect]
    mov al,2
    movzx eax,al
    push eax
    push dword[ebp+8] ;*rect
    push dword[ebp+12] ;hwndVentana
    push dword[ebp+16] ;hwndHijo
    call[MapWindowPoints]
pop ebp
ret 4*3

;void setEstadoEjecucion(ejecucion)
@Vista.Logica.setEstadoEjecucion:
push ebp
mov ebp,esp
    mov eax,dword[ebp+8]
    xor edx,edx
    not edx
    test eax,eax
    cmovne eax,edx
    push eax
    not eax
    mov dword[ebp+8],eax
    movzx eax,word[%Variables.hwndBotonDetener]
    push eax
    call[EnableWindow]
    push dword[ebp+8]
    movzx eax,word[%Variables.hwndComboBox]
    push eax
    call[EnableWindow]
    push dword[ebp+8]
    movzx eax,word[%Variables.hwndBotonIniciar]
    push eax
    call[EnableWindow]
    push dword[ebp+8]
    movzx eax,word[%Variables.hwndBotonIncrementar]
    push eax
    call[EnableWindow]
    push dword[ebp+8]
    movzx eax,word[%Variables.hwndBotonDecrementar]
    push eax
    call[EnableWindow]
    push dword[ebp+8]
    call @Vista.Logica.setHabilitarX
pop ebp
ret 4

;void setHabilitarX(ejecucion)
@Vista.Logica.setHabilitarX:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call[GetSystemMenu]
    mov edx,dword[ebp+8]
    test edx,edx
    mov edx,MF_ENABLED
    mov ecx,MF_DISABLED or MF_GRAYED
    cmove edx,ecx
    push edx
    push SC_CLOSE
    push eax
    call[EnableMenuItem]
pop ebp
ret 4

;--LOGICA DEL COMBOBOX--

;void actualizarCombobox()
@Vista.Logica.actualizarCombobox:
pushad
mov ebp,esp
    ;optenemos una mascara de bits de las unidades
    call[GetLogicalDrives]
    mov edi,eax
    mov esi,eax
    xor esi,dword[%Variables.dispositivos] ;optenemos la mascara de dispositivos cambiados
    mov dword[%Variables.dispositivos],edi
    mov bl,'A'
    movzx edx,dl
    ^Vista.Logica.actualizarCombobox.bucle:
	test esi,esi
	je ^Vista.Logica.actualizarCombobox.fin
	shr edi,1
	lahf
	jnc ^Vista.Logica.actualizarCombobox.noSiUnidad
	   inc bh
	^Vista.Logica.actualizarCombobox.noSiUnidad:
	shr esi,1
	jnc ^Vista.Logica.actualizarCombobox.noCambioUnidad
	    test ah,1
	    je ^Vista.Logica.actualizarCombobox.noEliminarUnidad
		movzx ecx,bh
		dec ecx
		push ecx
		movzx ecx,bl
		push ecx
		call @Vista.Logica.agregarCombobox
	    ^Vista.Logica.actualizarCombobox.noEliminarUnidad:
		movzx ecx,bh
		push ecx
		call @Vista.Logica.eliminarCombobox
	    ^Vista.Logica.actualizarCombobox.noFinUnidad:
	^Vista.Logica.actualizarCombobox.noCambioUnidad:
	inc bl
    jmp ^Vista.Logica.actualizarCombobox.bucle
    ^Vista.Logica.actualizarCombobox.fin:
popad
ret

;void agregarCombobox(unidad,posicion)
@Vista.Logica.agregarCombobox:
push ebp
mov ebp,esp
    lea eax,dword[ebp+8]
    mov word[eax+1],':'
    push eax
    push dword[ebp+12]
    push CB_INSERTSTRING
    movzx eax,word[%Variables.hwndComboBox]
    push eax
    call[SendMessage]
pop ebp
ret 4*2

;void eliminarCombobox(posicion)
@Vista.Logica.eliminarCombobox:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push dword[ebp+8]
    push CB_DELETESTRING
    movzx eax,word[%Variables.hwndComboBox]
    push eax
    call[SendMessage]
pop ebp
ret 4

;int getPoscionCombobox()
@Vista.Logica.getPoscionCombobox:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push eax
    push CB_GETCURSEL
    movzx eax,word[%Variables.hwndComboBox]
    push eax
    call[SendMessage]
pop ebp
ret

;char getUnidadCombobox()
@Vista.Logica.getUnidadCombobox:
push ebp
mov ebp,esp
    call @Vista.Logica.getPoscionCombobox
    inc al
    mov ah,'A'
    mov edx,dword[%Variables.dispositivos]
    ^Vista.Logica.getUnidadCombobox.bucle:
	test al,al
	je ^Vista.Logica.getUnidadCombobox.fin
	inc ah
	shr edx,1
	jnc ^Vista.Logica.getUnidadCombobox.bucle
	dec al
    jmp ^Vista.Logica.getUnidadCombobox.bucle
    ^Vista.Logica.getUnidadCombobox.fin:
    dec ah
    movzx eax,ah
pop ebp
ret

;void setPoscionInicialCombobox()
@Vista.Logica.setPoscionInicialCombobox:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push eax
    push CB_SETCURSEL
    movzx eax,word[%Variables.hwndComboBox]
    push eax
    call[SendMessage]
pop ebp
ret

;--LOGICA DE LAS LABELS--

;void setLabelPasada(pasada)
@Vista.Logica.setLabelPasada:
push ebp
mov ebp,esp
    sub esp,0xff
    push dword[ebp+8]
    push %Constantes.PASADA
    lea eax,dword[ebp-0xff]
    push eax
    call[sprintf]
    add esp,4*3
    lea eax,dword[ebp-0xff]
    push eax
    movzx eax,word[%Variables.hwndLabelPasada]
    push eax
    call[SetWindowText]
    movzx eax,word[%Variables.hwndLabelPasada]
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call @Vista.Logica.repintarVentana
mov esp,ebp
pop ebp
ret 4

;void setLabelPorcentaje(porcentaje(xmm0 double))
@Vista.Logica.setLabelPorcentajeXmm0:
push ebp
mov ebp,esp
    sub esp,0xff+8
    movq qword[esp],xmm0
    push %Constantes.PORCENTAJE
    lea eax,dword[ebp-0xff]
    push eax
    call[sprintf]
    add esp,4*2+8
    lea eax,dword[ebp-0xff]
    push eax
    movzx eax,word[%Variables.hwndLabelPorcentaje]
    push eax
    call[SetWindowText]
    movzx eax,word[%Variables.hwndLabelPorcentaje]
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call @Vista.Logica.repintarVentana
mov esp,ebp
pop ebp
ret

;void setLabelVelocidad(velocidad)
@Vista.Logica.setLabelVelocidad:
push ebp
mov ebp,esp
    sub esp,0xff
    xor eax,eax
    mov ecx,dword[ebp+8]
    ^Vista.Logica.setLabelVelocidad.bucle:
	cmp ecx,1024
	jl ^Vista.Logica.setLabelVelocidad.unidadMinima
	shr ecx,10
	inc eax
    jmp ^Vista.Logica.setLabelVelocidad.bucle
    ^Vista.Logica.setLabelVelocidad.unidadMinima:
    push dword[eax+%Constantes.UNIDAD_MEDIDA]
    push ecx
    push %Constantes.VELOCIDAD
    lea eax,dword[ebp-0xff]
    push eax
    call[sprintf]
    add esp,4*4
    lea eax,dword[ebp-0xff]
    push eax
    movzx eax,word[%Variables.hwndLabelVelocidad]
    push eax
    call[SetWindowText]
    movzx eax,word[%Variables.hwndLabelVelocidad]
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call @Vista.Logica.repintarVentana
mov esp,ebp
pop ebp
ret 4

;void setLabelTiempo(tiempo)
@Vista.Logica.setLabelTiempo:
push ebp
mov ebp,esp
    sub esp,0xff
    mov edx,%Constantes.UNIDAD_TIEMPO
    movd xmm0,edx
    mov eax,dword[ebp+8]
    ^Vista.Logica.setLabelTiempo.bucle:
	movd edx,xmm0
	add edx,8
	mov ecx,dword[edx]
	test ecx,ecx
	je ^Vista.Logica.setLabelTiempo.unidadMinima
	cmp eax,ecx
	jng ^Vista.Logica.setLabelTiempo.unidadMinima
	movd xmm0,edx
	xor edx,edx
	div ecx
    jmp ^Vista.Logica.setLabelTiempo.bucle
    ^Vista.Logica.setLabelTiempo.unidadMinima:
    movd edx,xmm0
    add edx,4
    push dword[edx]
    push eax
    push %Constantes.TIEMPO
    lea eax,dword[ebp-0xff]
    push eax
    call[sprintf]
    add esp,4*4
    lea eax,dword[ebp-0xff]
    push eax
    movzx eax,word[%Variables.hwndLabelTiempo]
    push eax
    call[SetWindowText]
    movzx eax,word[%Variables.hwndLabelTiempo]
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call @Vista.Logica.repintarVentana
mov esp,ebp
pop ebp
ret 4

;void setLabelPasadas(pasadas)
@Vista.Logica.setLabelPasadas:
push ebp
mov ebp,esp
    sub esp,0xff
    push dword[ebp+8]
    push %Constantes.PASADAS
    lea eax,dword[ebp-0xff]
    push eax
    call[sprintf]
    add esp,4*3
    lea eax,dword[ebp-0xff]
    push eax
    movzx eax,word[%Variables.hwndLabelPasadas]
    push eax
    call[SetWindowText]
    movzx eax,word[%Variables.hwndLabelPasadas]
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call @Vista.Logica.repintarVentana
mov esp,ebp
pop ebp
ret 4

;--LOGICA DE LA PROGRESS BAR--

;void setTamanoPreogessBar()
;entre 0x0 y 0xffff
@Vista.Logica.setTamanoPreogessBar:
push ebp
mov ebp,esp
    xor ax,ax
    not ax
    movzx eax,ax
    push eax
    xor eax,eax
    push eax
    push PBM_SETRANGE32
    movzx eax,word[%Variables.hwndProgressBar]
    push eax
    call[SendMessage]
mov esp,ebp
pop ebp
ret

;void setPosicionPreogessBar(posicion)
@Vista.Logica.setPosicionPreogessBar:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push dword[ebp+8]
    push PBM_SETPOS
    movzx eax,word[%Variables.hwndProgressBar]
    push eax
    call[SendMessage]
mov esp,ebp
pop ebp
ret 4

;--LOGICA DE MENSAJES DE ERROR--

;void mensajeError(*mensaje)
@Vista.Logica.mensajeError:
push ebp
mov ebp,esp
    xor eax,eax
    push MB_OK
    push eax
    push dword[ebp+8]
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call[MessageBox]
mov esp,ebp
pop ebp
ret 4
