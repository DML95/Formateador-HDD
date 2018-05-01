;--LOGICA DE PASADAS--

;void incDecPasada(incDec)
@Controlador.Logica.incDecPasada:
push ebp
mov ebp,esp
    mov eax,dword[ebp+8]
    mov cl,byte[%Variables.numeroPasadas]
    test eax,eax
    je ^Controlador.Mensajes.agregarPasada.decrementar
	^Controlador.Mensajes.agregarPasada.incrementar:
	inc cl
	test cl,cl
	je ^Controlador.Mensajes.agregarPasada.incrementar
	jmp ^Controlador.Mensajes.agregarPasada.fin
	^Controlador.Mensajes.agregarPasada.decrementar:
	dec cl
	test cl,cl
	je ^Controlador.Mensajes.agregarPasada.decrementar
    ^Controlador.Mensajes.agregarPasada.fin:
    mov byte[%Variables.numeroPasadas],cl
    movzx ecx,cl
    push ecx
    call @Vista.Logica.setLabelPasadas
pop ebp
ret 4

;--LOGICA DE TIMER--

;void crearTimer()
@Controlador.Logica.crearTimer:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push 1000
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call[SetTimer]
pop ebp
ret

;void destruirTimer()
@Controlador.Logica.destruirTimer:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call[KillTimer]
pop ebp
ret

;--CALCULOS DE OPERACION--

;void calcularOperacion()
@Controlador.Logica.calcularOperacion:
push ebp
mov ebp,esp
    sub esp,8+4
    movq xmm0,qword[%Variables.sectorActual]
    movq xmm1,qword[%Variables.sectorAnterior]
    movq qword[ebp-8],xmm0
    movq qword[%Variables.sectorAnterior],xmm0
    psubq xmm0,xmm1
    movd dword[ebp-(8+4)],xmm0
    call @Controlador.Logica.calcularPasada
    lea eax,dword[ebp-8]
    push eax
    call @Controlador.Logica.calcularPorcentajePasada
    push dword[ebp-(8+4)]
    call @Controlador.Logica.calcularVelocidad
    lea eax,dword[ebp-8]
    push eax
    push dword[ebp-(8+4)]
    call @Controlador.Logica.calcularTiempo
    lea eax,dword[ebp-8]
    push eax
    call @Controlador.Logica.calcularPreogessBar
mov esp,ebp
pop ebp
ret

;void calcularPasada()
@Controlador.Logica.calcularPasada:
push ebp
mov ebp,esp
    movzx eax,byte[%Variables.contadorPasadas]
    inc eax
    push eax
    call @Vista.Logica.setLabelPasada
mov esp,ebp
pop ebp
ret

;void calcularPorcentajePasada(*sectorActual)
@Controlador.Logica.calcularPorcentajePasada:
push ebp
mov ebp,esp
    push %Variables.numeroSectores
    call @Funciones.memQwordADoubleEnXmm0
    movq xmm7,xmm0
    push dword[ebp+8]
    call @Funciones.memQwordADoubleEnXmm0
    divsd xmm0,xmm7
    mov al,100
    movzx eax,al
    cvtsi2sd xmm7,eax
    mulsd xmm0,xmm7
    call @Vista.Logica.setLabelPorcentajeXmm0
mov esp,ebp
pop ebp
ret 4


;void calcularVelocidad(sectores/segundo)
@Controlador.Logica.calcularVelocidad:
push ebp
mov ebp,esp
    mov eax,dword[ebp+8]
    imul eax,dword[%Variables.bytesSector]
    push eax
    call @Vista.Logica.setLabelVelocidad
mov esp,ebp
pop ebp
ret 4

;void calcularVelocidad(sectores/segundo,*sectorActual)
@Controlador.Logica.calcularTiempo:
push ebp
mov ebp,esp
    call @Controlador.Logica.calcularSectoresTotalesXmm0
    movq xmm7,xmm0
    push dword[ebp+12]
    call @Controlador.Logica.calcularSectoresEscritosXmm0
    subsd xmm7,xmm0
    cvtsi2sd xmm1,dword[ebp+8]
    divsd xmm7,xmm1
    cvtsd2si eax,xmm7
    push eax
    call @Vista.Logica.setLabelTiempo
mov esp,ebp
pop ebp
ret 4*2

;void calcularVelocidad(*sectorActual)
@Controlador.Logica.calcularPreogessBar:
push ebp
mov ebp,esp
    call @Controlador.Logica.calcularSectoresTotalesXmm0
    movq xmm7,xmm0
    push dword[ebp+8]
    call @Controlador.Logica.calcularSectoresEscritosXmm0
    xor ax,ax
    not ax
    movzx eax,ax
    divsd xmm0,xmm7
    cvtsi2sd xmm1,eax
    mulsd xmm0,xmm1
    cvtsd2si eax,xmm0
    push eax
    call @Vista.Logica.setPosicionPreogessBar
mov esp,ebp
pop ebp
ret 4

;void calcularSectoresTotalesXmm0()
@Controlador.Logica.calcularSectoresTotalesXmm0:
    push %Variables.numeroSectores
    call @Funciones.memQwordADoubleEnXmm0
    movzx eax,byte[%Variables.numeroPasadas]
    cvtsi2sd xmm1,eax
    mulsd xmm0,xmm1
ret

;void calcularSectoresEscritosXmm0(*sectorActual)
@Controlador.Logica.calcularSectoresEscritosXmm0:
push ebp
mov ebp,esp
    push %Variables.numeroSectores
    call @Funciones.memQwordADoubleEnXmm0
    movzx eax,byte[%Variables.contadorPasadas]
    cvtsi2sd xmm1,eax
    mulsd xmm0,xmm1
    movq xmm6,xmm0
    push dword[ebp+8]
    call @Funciones.memQwordADoubleEnXmm0
    addsd xmm6,xmm0
    movq xmm0,xmm6
pop ebp
ret 4

;--LOGICA DE FRONT--

;void resetFront()
@Controlador.Logica.resetFront:
push ebp
mov ebp,esp
    xor eax,eax
    push eax ;0
    call @Vista.Logica.setLabelPasada
    pxor xmm0,xmm0
    call @Vista.Logica.setLabelPorcentajeXmm0
    xor eax,eax
    push eax ;0
    call @Vista.Logica.setLabelVelocidad
    xor eax,eax
    push eax ;0
    call @Vista.Logica.setLabelTiempo
    call @Vista.Logica.setTamanoPreogessBar
    xor eax,eax
    push eax ;0
    call @Vista.Logica.setPosicionPreogessBar
pop ebp
ret

;--CALCULOS DE ERROR--

;void mostrarError(numError)
@Controlador.Logica.mostrarError:
push ebp
mov ebp,esp
    mov ecx,dword[ebp+8]
    mov eax,%Constantes.ERROR_DEFECTO
    mov edx,%Constantes.ERROR_NO_LISTO
    cmp ecx,ERROR_NOT_READY
    cmove eax,edx
    mov edx,%Constantes.ERROR_ACCESO_DENEGADO
    cmp ecx,ERROR_ACCESS_DENIED
    cmove eax,edx
    push eax
    call @Vista.Logica.mensajeError
pop ebp
ret 4
