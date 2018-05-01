;ensamblado en FASM

format PE GUI 4.0
include "win32a.inc"
entry @Main.main

DBT_DEVICEARRIVAL=0x8000
DBT_DEVICEREMOVECOMPLETE=0x8004

ERROR_NOT_READY=21
ERROR_ACCESS_DENIED=5

PBS_SMOOTH=0x01
EV_FIN=WM_USER

IOCTL_DISK_GET_DRIVE_GEOMETRY=0x70000

;estructura de ficheros

;[@^][Modelo,Vista,Controlador].[Bloque].[Funcion].[Salto]
;%[Variable,Constante].[Nombre]

;@ -> funcion
;^ -> salto
;% -> puntero/valor

section '.test' code readable executable ;codigo

include 'Vista.Carga.asm'
include 'Vista.Logica.asm'
include 'Controlador.Mensajes.asm'
include 'Controlador.Logica.asm'
include 'Modelo.Logica.asm'
include 'Funciones.asm'

;PINSRB/PINSRD/PINSRQ

;int main()
@Main.main:
push ebp
mov ebp,esp
    push %Constantes.COMMON_CONTROLS
    call @Vista.Carga.commonControls
    push %Constantes.CLASE
    call[RegisterClass]
    xor eax,eax
    push eax
    push %Constantes.VENTANA
    call @Vista.Carga.ventanas
    push eax
    call @Controlador.Mensajes.bucleMensajes
    xor eax,eax
    push eax
    call[ExitProcess]
pop ebp
ret

section '.data' data readable writeable ;valiables glovales

    ;identificadores de ventanas
    %Variables.hwndVentana	       dw 0

    %Variables.hwndComboBox	       dw 0

    %Variables.hwndLabelPasadas        dw 0
    %Variables.hwndLabelPasada	       dw 0
    %Variables.hwndLabelPorcentaje     dw 0
    %Variables.hwndLabelVelocidad      dw 0
    %Variables.hwndLabelTiempo	       dw 0

    %Variables.hwndProgressBar	       dw 0

    %Variables.hwndBotonIniciar        dw 0
    %Variables.hwndBotonDetener        dw 0
    %Variables.hwndBotonIncrementar    dw 0
    %Variables.hwndBotonDecrementar    dw 0

    ;identificadores de unidad
    %Variables.hDispositivo	       dd 0
    %Variables.hHilo		       dd 0
    %Variables.hTimer		       dd 0

    ;datos de la aplicacion
    %Variables.dispositivos	       dd 0
    %Variables.contadorPasadas	       db 0
    %Variables.numeroPasadas	       db 1
    %Variables.numeroSectores	       dq 0
    %Variables.sectorAnterior	       dq 0
    %Variables.sectorActual	       dq 0
    %Variables.bytesSector	       dd 0

    %Variables.datos		       dd 0

    %Variables.overlapped:
    %Variables.overlapped.internal     dq 0
    %Variables.overlapped.offset       dq 0
    %Variables.overlapped.hEvent       dd 0

section '.rdata' data readable ;constantes

    ;Datos de clase de ventana
    %Constantes.CLASE:
    dd 0
    dd @Controlador.Mensajes.mensajes
    dd 0
    dd 0
    dd 0
    dd 0
    dd 0
    dd COLOR_BTNFACE+1
    dd 0
    dd %Constantes.NOMBRE_CLASE

    ;array de controles comunes a iniciar
    %Constantes.COMMON_CONTROLS dd ICC_PROGRESS_CLASS,0

    ;tabla para el calculo de las unidades de tiempo
    %Constantes.UNIDAD_TIEMPO:
    ;  valor maximo ,string unidades
    dd 60	    ,%Constantes.SEGUNDOS
    dd 60	    ,%Constantes.MINUTOS
    dd 60	    ,%Constantes.HORAS
    dd 0


    ;tabla ventana
    %Constantes.VENTANA:
    ;  *clase                       ,*texto(no obligatorio)   ,*hwndVentana(no obligatorio)    ,*hwndPadre(no obligatorio) ,estilo                                                                   ,estiloEx                              ,x             ,y             ,ancho ,alto
    dd %Constantes.NOMBRE_CLASE     ,%Constantes.NOMBRE_CLASE ,%Variables.hwndVentana	       ,0			   ,WS_VISIBLE or WS_DLGFRAME or WS_SYSMENU or WS_MINIMIZEBOX		     ,0 				    ,CW_USEDEFAULT ,CW_USEDEFAULT ,300	 ,275
    dd 0
    ;tabla sub elemntos ventana
    %Constantes.ELEMENTOS:
    dd %Constantes.COMBOBOX	    ,0			      ,%Variables.hwndComboBox	       ,0			   ,WS_VISIBLE or WS_CHILD or WS_VSCROLL or WS_TABSTOP or CBS_DROPDOWNLIST   ,WS_EX_CLIENTEDGE			    ,10 	   ,10		  ,45	,250
    dd %Constantes.STATIC	    ,%Constantes.UNIDAD_LABEL ,0			       ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE				     ,WS_EX_TRANSPARENT 		    ,60 	   ,10		  ,50	,24
    dd %Constantes.BUTTON	    ,%Constantes.DECREMENTAR  ,%Variables.hwndBotonDecrementar ,0			   ,WS_VISIBLE or WS_CHILD						     ,WS_EX_TRANSPARENT 		    ,120	   ,10		  ,20	,24
    dd %Constantes.STATIC	    ,0			      ,%Variables.hwndLabelPasadas     ,0			   ,WS_VISIBLE or WS_CHILD or WS_BORDER or SS_CENTERIMAGE or SS_CENTER	     ,WS_EX_TRANSPARENT 		    ,142	   ,10		  ,30	,24
    dd %Constantes.BUTTON	    ,%Constantes.INCREMENTAR  ,%Variables.hwndBotonIncrementar ,0			   ,WS_VISIBLE or WS_CHILD						     ,WS_EX_TRANSPARENT 		    ,174	   ,10		  ,20	,24
    dd %Constantes.STATIC	    ,%Constantes.PASADAS_LABEL,0			       ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE or SS_LEFT 		     ,WS_EX_TRANSPARENT 		    ,200	   ,10		  ,80	,24
    dd %Constantes.STATIC	    ,0			      ,%Variables.hwndLabelPasada      ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE				     ,WS_EX_TRANSPARENT or WS_EX_STATICEDGE ,10 	   ,40		  ,275	,24
    dd %Constantes.STATIC	    ,0			      ,%Variables.hwndLabelPorcentaje  ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE				     ,WS_EX_TRANSPARENT or WS_EX_STATICEDGE ,10 	   ,70		  ,275	,24
    dd %Constantes.STATIC	    ,0			      ,%Variables.hwndLabelVelocidad   ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE				     ,WS_EX_TRANSPARENT or WS_EX_STATICEDGE ,10 	   ,100 	  ,275	,24
    dd %Constantes.STATIC	    ,0			      ,%Variables.hwndLabelTiempo      ,0			   ,WS_VISIBLE or WS_CHILD or SS_CENTERIMAGE				     ,WS_EX_TRANSPARENT or WS_EX_STATICEDGE ,10 	   ,130 	  ,275	,24
    dd %Constantes.PROGRESS_BAR     ,0			      ,%Variables.hwndProgressBar      ,0			   ,WS_VISIBLE or WS_CHILD or PBS_SMOOTH				     ,0 				    ,10 	   ,160 	  ,275	,24
    dd %Constantes.BUTTON	    ,%Constantes.INICIAR      ,%Variables.hwndBotonIniciar     ,0			   ,WS_VISIBLE or WS_CHILD or WS_TABSTOP				     ,0 				    ,33 	   ,200 	  ,100	,30
    dd %Constantes.BUTTON	    ,%Constantes.DETENER      ,%Variables.hwndBotonDetener     ,0			   ,WS_VISIBLE or WS_CHILD or WS_TABSTOP or WS_DISABLED 		     ,0 				    ,166	   ,200 	  ,100	,30
    dd 0

    ;String clases vista
    %Constantes.NOMBRE_CLASE	      db 'Formateador',0
    %Constantes.STATIC		      db 'STATIC',0
    %Constantes.COMBOBOX	      db 'COMBOBOX',0
    %Constantes.BUTTON		      db 'BUTTON',0
    %Constantes.PROGRESS_BAR	      db PROGRESS_CLASS,0

    ;String texto vista
    %Constantes.UNIDAD_LABEL	      db 'Unidad',0
    %Constantes.UNIDAD		      db '%c:',0
    %Constantes.PASADA		      db ' Pasada:',9,'%i',0
    %Constantes.PORCENTAJE	      db ' Porcentaje:',9,'%.2lf %%',0
    %Constantes.UNIDAD_MEDIDA	      db ' KMGT'
    %Constantes.VELOCIDAD	      db ' Velocidad:',9,'%i %cB/s',0
    %Constantes.TIEMPO		      db ' Tiempo:',9,'%i %s',0
    %Constantes.SEGUNDOS	      db 'Segundos',0
    %Constantes.MINUTOS 	      db 'Minutos',0
    %Constantes.HORAS		      db 'Horas',0
    %Constantes.PASADAS_LABEL	      db 'Pasadas',0
    %Constantes.INICIAR 	      db 'Iniciar',0
    %Constantes.DETENER 	      db 'Detener',0
    %Constantes.PASADAS 	      db '%i',0
    %Constantes.INCREMENTAR	      db '+',0
    %Constantes.DECREMENTAR	      db '-',0

    ;String texto modelo
    %Constantes.UNIDAD_MODELO	      db '\\.\%c:',0

    ;String mensaje error
    %Constantes.ERROR_DEFECTO	      db 'Error al iniciar la unidad',0
    %Constantes.ERROR_NO_LISTO	      db 'El dispositivo no está listo',0
    %Constantes.ERROR_ACCESO_DENEGADO db 'Acceso denegado',0

section '.idata' import data readable ;importacion de funciones dll

    library msvcrt,'msvcrt.dll',user32,'user32',kernel32,'kernel32',gdi32,'gdi32.dll',comctl32,'comctl32.dll'
    import msvcrt,sprintf,'sprintf',printf,'_cprintf',getchar,'_fgetchar'
    import comctl32,InitCommonControlsEx,'InitCommonControlsEx'
    include 'api\kernel32.inc'
    include 'api\user32.inc'
    include 'api\gdi32.inc'

section '.reloc' fixups readable discardable ;relocalizacion