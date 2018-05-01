;--LOGICA DE COMUNICACION CON EL CONTROLADOR--

;void iniciarFormateo(unidad)
@Modelo.Logica.iniciarFormateo:
push ebp
mov ebp,esp
    sub esp,0xff
    push dword[ebp+8]
    lea eax,dword[ebp-0xff]
    push eax
    call @Modelo.Logica.setUnidadString
    lea eax,dword[ebp-0xff]
    push eax
    call @Modelo.Logica.setHandleUnidad
    xor edx,edx
    test eax,eax
    cmovs eax,edx
    js ^Modelo.Logica.iniciarFormateo.fin
	mov dword[%Variables.hDispositivo],eax
	pxor xmm0,xmm0
	movq qword[%Variables.sectorActual],xmm0
	movq qword[%Variables.sectorAnterior],xmm0
	xor al,al
	mov byte[%Variables.contadorPasadas],al
	xor eax,eax
	push eax
	push eax
	push eax ;parametro
	push @Modelo.Logica.hiloFormateo
	push eax
	push eax
	call[CreateThread]
	mov dword[%Variables.hHilo],eax
    ^Modelo.Logica.iniciarFormateo.fin:
mov esp,ebp
pop ebp
ret 4

;void detenerFormateo()
@Modelo.Logica.detenerFormateo:
push ebp
mov ebp,esp
    sub esp,4
    xor eax,eax
    xchg eax,dword[%Variables.hDispositivo]
    mov dword[ebp-4],eax
    xor ax,ax
    not ax
    movzx eax,ax
    push eax ;INFINITE
    push dword[%Variables.hHilo]
    call[WaitForSingleObject]
    push dword[ebp-4]
    call[CloseHandle]
    push dword[%Variables.hHilo]
    call[CloseHandle]
mov esp,ebp
pop ebp
ret

;--HILO DEL MODELO--

;void hiloFormateo(*estructura)
@Modelo.Logica.hiloFormateo:
push ebp
mov ebp,esp
    sub esp,4
    xor eax,eax
    mov dword[ebp-4],eax
    push dword[%Variables.hDispositivo]
    push %Variables.numeroSectores
    call @Modelo.Logica.getSectoresUnidad
    not dword[ebp-4]
    test eax,eax
    je ^Modelo.Logica.hiloFormateo.finExcepcion
	mov dword[%Variables.bytesSector],eax
	push eax
	call @Modelo.Logica.reservarMemoriaDispositivo
	mov dword[%Variables.datos],eax
	not dword[ebp-4]
	^Modelo.Logica.hiloFormateo.bucle:
	    mov ecx,dword[%Variables.hDispositivo]
	    test ecx,ecx
	    je ^Modelo.Logica.hiloFormateo.finForzado
	    movq xmm0,qword[%Variables.sectorActual]
	    call @Funciones.incXmm0
	    movq xmm1,qword[%Variables.numeroSectores]
	    call @Funciones.distinto64bitsXmm0Xmm1
	    test eax,eax
	    je ^Modelo.Logica.hiloFormateo.noIncrementarPasada
		pxor xmm0,xmm0
		mov al,byte[%Variables.contadorPasadas]
		inc al
		mov ah,byte[%Variables.numeroPasadas]
		cmp al,ah
		jne ^Modelo.Logica.hiloFormateo.incrementarPasada
		    xor edx,edx
		    mov dword[ebp-4],edx
		    jmp ^Modelo.Logica.hiloFormateo.finExcepcion
		^Modelo.Logica.hiloFormateo.incrementarPasada:
		mov byte[%Variables.contadorPasadas],al
	    ^Modelo.Logica.hiloFormateo.noIncrementarPasada:
	    movq qword[%Variables.sectorActual],xmm0
	    call @Funciones.decXmm0
	    call @Modelo.Logica.formatearSector
	jmp ^Modelo.Logica.hiloFormateo.bucle
    ^Modelo.Logica.hiloFormateo.finExcepcion:
    call[GetLastError]
    push eax ;indica el valor del error
    push dword[ebp-4] ;indica si se muestra el mensaje de error
    push EV_FIN
    movzx eax,word[%Variables.hwndVentana]
    push eax
    call[PostMessage]
    ^Modelo.Logica.hiloFormateo.finForzado:
    push %Variables.datos
    call @Modelo.Logica.liberarMemoriaDispositivo
mov esp,ebp
pop ebp
ret 4

;void formatearSector(sector[xmm0])
@Modelo.Logica.formatearSector:
push ebp
mov ebp,esp
    pxor xmm1,xmm1
    movq qword[%Variables.overlapped.internal],xmm1
    movq qword[%Variables.overlapped.offset],xmm0
    push dword[%Variables.bytesSector]
    push %Variables.overlapped.offset
    call @Funciones.mul64x32Bits
    push dword[%Variables.bytesSector]
    push dword[%Variables.datos]
    call @Modelo.Logica.setArrayRandom
    xor eax,eax
    push %Variables.overlapped
    push eax
    push dword[%Variables.bytesSector]
    push dword[%Variables.datos]
    push dword[%Variables.hDispositivo]
    ;call[ReadFile]
    call[WriteFile]
    xor ax,ax
    not ax
    movzx eax,ax
    push eax ;INFINITE
    push dword[%Variables.overlapped.hEvent]
    call[WaitForSingleObject]
    push dword[%Variables.overlapped.hEvent]
    call[ResetEvent]
mov esp,ebp
pop ebp
ret

;--LOGICA INTERNA DEL MODELO--

;void setHandleUnidad(*strUnidad)
@Modelo.Logica.setHandleUnidad:
push ebp
mov ebp,esp
    xor eax,eax
    push eax
    push FILE_FLAG_NO_BUFFERING or FILE_FLAG_OVERLAPPED
    push OPEN_EXISTING
    push eax
    push FILE_SHARE_READ or FILE_SHARE_WRITE
    push GENERIC_READ or GENERIC_WRITE
    push dword[ebp+8]
    call[CreateFile]
mov esp,ebp
pop ebp
ret 4

;int getSectoresUnidad(handle,*numSectores)
@Modelo.Logica.getSectoresUnidad:
push ebp
mov ebp,esp
    sub esp,4*6 ;reserbo estructura DISK_GEOMETRY
    xor eax,eax
    push eax
    lea edx,dword[ebp+12]
    push edx
    mov dl,4*6
    movzx edx,dl
    push edx ;tamaño DISK_GEOMETRY
    lea edx,dword[ebp-4*6]
    push edx ;*DISK_GEOMETRY
    push eax
    push eax
    push IOCTL_DISK_GET_DRIVE_GEOMETRY
    push dword[ebp+12]
    call[DeviceIoControl]
    test eax,eax
    je ^Modelo.Logica.getSectoresUnidad.fin
	push dword[ebp-4*3] ;TracksPerCylinder
	lea eax,dword[ebp-4*6] ;Cylinders
	push eax
	call @Funciones.mul64x32Bits
	push dword[ebp-4*2] ;SectorsPerTrack
	lea eax,dword[ebp-4*6] ;Cylinders*TracksPerCylinder
	push eax
	call @Funciones.mul64x32Bits
	movq xmm0,qword[ebp-4*6] ;Cylinders*TracksPerCylinder*SectorsPerTrack
	mov eax,dword[ebp+8]
	movq qword[eax],xmm0
	mov eax,dword[ebp-4] ;BytesPerSector
    ^Modelo.Logica.getSectoresUnidad.fin:
mov esp,ebp
pop ebp
ret 4

;void setUnidadString(*strUnidad,unidad)
@Modelo.Logica.setUnidadString:
push ebp
mov ebp,esp
    push dword[ebp+12]
    push %Constantes.UNIDAD_MODELO
    push dword[ebp+8]
    call[sprintf]
mov esp,ebp
pop ebp
ret 4*2

;void setArrayRandom(*array,tamano)
@Modelo.Logica.setArrayRandom:
pushad
mov ebp,esp
    mov edi,dword[ebp+36]
    mov ecx,dword[ebp+40]
    shr ecx,2
    ^Modelo.Logica.setArrayRandom.bucle:
	jecxz ^Modelo.Logica.setArrayRandom.fin
	sub ecx,4
	rdtsc
	add ebx,eax
	movnti dword[edi+ecx],ebx
    jmp ^Modelo.Logica.setArrayRandom.bucle
    ^Modelo.Logica.setArrayRandom.fin:
popad
ret 4*2

;void* reservarMemoriaDispositivo(tamano)
@Modelo.Logica.reservarMemoriaDispositivo:
push ebp
mov ebp,esp
    xor eax,eax
    push PAGE_READWRITE or PAGE_NOCACHE
    push MEM_COMMIT
    push dword[ebp+8]
    push eax
    call[VirtualAlloc]
pop ebp
ret 4

;void liberarMemoriaDispositivo(void*)
@Modelo.Logica.liberarMemoriaDispositivo:
push ebp
mov ebp,esp
    xor eax,eax
    push MEM_RELEASE
    push eax
    push dword[ebp+8]
    call[VirtualFree]
pop ebp
ret 4