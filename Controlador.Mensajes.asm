;void bucleMensajes(){
;    MSG mensaje;
;    while(GetMessage(&mensaje,0,0,0)>0){
;        if(!IsDialogMessage(hVentana,&mensaje)){
;             TranslateMessage(&mensaje);
;             DispatchMessage(&mensaje);
;        }
;    }
;}
@Controlador.Mensajes.bucleMensajes:
push ebp
mov ebp,esp
    sub esp,28 ;reserbo estructura MSG(28 bytes)
    ^Controlador.Mensajes.bucleMensajes.bucle:
	xor eax,eax
	push eax
	push eax
	push eax
	lea ecx,dword[ebp-28] ;puntero MSG
	push ecx
	call[GetMessage]
	test eax,eax
	jp ^Controlador.Mensajes.bucleMensajes.finBucle
	lea ecx,dword[ebp-28] ;puntero MSG
	push ecx
	xor eax,eax
	push eax
	call[IsDialogMessage]
	test eax,eax
	jne ^Controlador.Mensajes.bucleMensajes.bucle
	    lea ecx,dword[ebp-28] ;puntero MSG
	    push ecx
	    call[TranslateMessage]
	    lea ecx,dword[ebp-28] ;puntero MSG
	    push ecx
	    call[DispatchMessage]
    jmp ^Controlador.Mensajes.bucleMensajes.bucle
    ^Controlador.Mensajes.bucleMensajes.finBucle:
leave
ret 4

;int mensajes(hwnd,msg,wParam,lParam)
@Controlador.Mensajes.mensajes:
push ebp
mov ebp,esp
    xor eax,eax
    mov ecx,dword[ebp+12] ;mensaje
    cmp ecx,WM_TIMER
    je ^Controlador.Mensajes.mensajes.timer
    cmp ecx,WM_DEVICECHANGE
    je ^Controlador.Mensajes.mensajes.deviceChange
    cmp ecx,WM_COMMAND
    je ^Controlador.Mensajes.mensajes.command
    cmp ecx,EV_FIN ;evento de usuario
    je ^Controlador.Mensajes.mensajes.finFormateo
    cmp ecx,WM_CTLCOLORSTATIC
    je ^Controlador.Mensajes.mensajes.colorStatic
    cmp ecx,WM_CREATE
    je ^Controlador.Mensajes.mensajes.create
    cmp ecx,WM_CLOSE
    je ^Controlador.Mensajes.mensajes.close
    cmp ecx,WM_DESTROY
    je ^Controlador.Mensajes.mensajes.detroy
    jmp ^Controlador.Mensajes.mensajes.defecto

    ^Controlador.Mensajes.mensajes.timer:
	call @Controlador.Logica.calcularOperacion
	jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.deviceChange:
	mov ecx,dword[ebp+16] ;wParam
	cmp ecx,DBT_DEVICEARRIVAL
	je ^Controlador.Mensajes.mensajes.arrivalRemove
	cmp ecx,DBT_DEVICEREMOVECOMPLETE
	je ^Controlador.Mensajes.mensajes.arrivalRemove
	jmp ^Controlador.Mensajes.mensajes.fin

	    ^Controlador.Mensajes.mensajes.arrivalRemove:
		call @Vista.Logica.actualizarCombobox
		jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.command: ;evento de recepcepcion de mensajes de los controles
	mov cx,word[ebp+18]
	cmp cx,BN_CLICKED
	je ^Controlador.Mensajes.mensajes.click
	cmp cx,CBN_SELCHANGE
	je ^Controlador.Mensajes.mensajes.selChange
	jmp ^Controlador.Mensajes.mensajes.fin

	    ^Controlador.Mensajes.mensajes.click: ;sub evento al hacer click en un boton
		mov cx,word[ebp+20] ;hwnd del boton
		cmp cx,word[%Variables.hwndBotonIncrementar]
		je ^Controlador.Mensajes.mensajes.incrementar
		cmp cx,word[%Variables.hwndBotonDecrementar]
		je ^Controlador.Mensajes.mensajes.decrementar
		cmp cx,word[%Variables.hwndBotonIniciar]
		je ^Controlador.Mensajes.mensajes.iniciar
		cmp cx,word[%Variables.hwndBotonDetener]
		je ^Controlador.Mensajes.mensajes.detener
		jmp ^Controlador.Mensajes.mensajes.fin

		    ^Controlador.Mensajes.mensajes.incrementar:
			not eax
			push eax
			call @Controlador.Logica.incDecPasada
			movzx ecx,word[%Variables.hwndLabelPasadas]
			push ecx ;hwndHija
			push dword[ebp+8] ;hwndVentana
			call @Vista.Logica.repintarVentana
			jmp ^Controlador.Mensajes.mensajes.fin

		    ^Controlador.Mensajes.mensajes.decrementar:
			push dword[%Variables.hDispositivo]
			call @Controlador.Logica.incDecPasada
			jmp ^Controlador.Mensajes.mensajes.fin

		    ^Controlador.Mensajes.mensajes.iniciar:
			call @Vista.Logica.getUnidadCombobox
			push eax
			call @Modelo.Logica.iniciarFormateo
			test eax,eax
			jne ^Controlador.Mensajes.mensajes.iniciar.ok
			call[GetLastError]
			push eax
			call @Controlador.Logica.mostrarError
			jmp ^Controlador.Mensajes.mensajes.fin

			    ^Controlador.Mensajes.mensajes.iniciar.ok:
				push eax
				call @Vista.Logica.setEstadoEjecucion
				call @Controlador.Logica.crearTimer
				jmp ^Controlador.Mensajes.mensajes.fin

		    ^Controlador.Mensajes.mensajes.detener:
			call @Modelo.Logica.detenerFormateo
			xor eax,eax
			push eax
			call @Vista.Logica.setEstadoEjecucion
			call @Controlador.Logica.destruirTimer
			jmp ^Controlador.Mensajes.mensajes.fin

	    ^Controlador.Mensajes.mensajes.selChange: ;sub evento al cambiar un combobox
		call @Vista.Logica.getPoscionCombobox
		cmp eax,CB_ERR
		jne ^Controlador.Mensajes.mensajes.fin
		call @Vista.Logica.setPoscionInicialCombobox
		jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.finFormateo: ;evento producido por finalizacion natural del formateo (error o fin del mismo)
	call @Modelo.Logica.detenerFormateo
	call @Controlador.Logica.destruirTimer
	call @Controlador.Logica.calcularOperacion
	push dword[%Variables.hDispositivo]
	call @Vista.Logica.setEstadoEjecucion
	mov eax,dword[ebp+16] ;wParam
	test eax,eax
	je ^Controlador.Mensajes.mensajes.fin

	    call @Controlador.Logica.resetFront
	    push dword[ebp+20]
	    call @Controlador.Logica.mostrarError
	    jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.colorStatic: ;evento de color de las label
	push TRANSPARENT
	push dword[ebp+16] ;wParam
	call[SetBkMode]
	push NULL_BRUSH
	call[GetStockObject]
	jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.create: ;evento de inicio del programa
	push dword[ebp+8] ;hwnd
	push %Constantes.ELEMENTOS
	call @Vista.Carga.ventanas
	call @Vista.Logica.actualizarCombobox
	call @Controlador.Logica.resetFront
	movzx eax,word[%Variables.numeroPasadas]
	push eax
	call @Vista.Logica.setLabelPasadas
	call @Vista.Logica.setPoscionInicialCombobox
	xor eax,eax
	push eax
	mov edx,eax
	not edx
	push edx
	push edx
	push eax
	call[CreateEvent]
	mov dword[%Variables.overlapped.hEvent],eax
	jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.close: ;evento de pulsar la x de la ventana
	mov eax,dword[%Variables.hDispositivo]
	test eax,eax
	je ^Controlador.Mensajes.mensajes.defecto
	jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.detroy: ;evento de destruir la ventana
	push dword[%Variables.overlapped.hEvent]
	call[CloseHandle]
	xor eax,eax
	push eax ;0
	call[PostQuitMessage]
	jmp ^Controlador.Mensajes.mensajes.fin

    ^Controlador.Mensajes.mensajes.defecto: ;evento por defecto (no procesado por mi codigo)
	push dword[ebp+20] ;lParam
	push dword[ebp+16] ;wParam
	push dword[ebp+12] ;mensaje
	push dword[ebp+8]  ;hwnd
	call[DefWindowProc]

    ^Controlador.Mensajes.mensajes.fin:
pop ebp
ret 4*4
