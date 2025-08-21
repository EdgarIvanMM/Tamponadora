MODULE MainModule
    ! Proyecto: Tamponadora CATOEX | TIA ROBOTICS.

    ! Historial de modificaciones:
    ! Fecha       | Ingeniero          | Descripción
    ! ------------|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------
    ! 2025-08-13  | Ivan Martinez      | Primera version sin coordenadas de camara.
    ! 2025-08-13  | Ivan Martinez      | Se agrego y probo el proc -pruebaRoscarconTorque- que verifica el torque en movimientos de 30 grados, al pasar el umbral, deja de roscar.   
    ! 2025-08-20  | Ivan Martinez      | Se agregaron coordenadas de camara, proc definitivo de roscado, falta encontrar el umbral del torque.  
    ! 2025-08-21  | Ivan Martinez      | Se limpio codigo y se comento. Se agrego un inicio seguro, se agrego salida rapida despues de roscado.
    ! -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    !
    ! Proyecto en GitGub: https://github.com/EdgarIvanMM/Tamponadora.git
    !
    ! NOTA: REGISTRAR TODO CAMBIO REALIZADO PARA MANTENER TRAZABILIDAD.
    
    !Wobj 
	TASK PERS wobjdata wobjConveyor:=[FALSE,TRUE,"",[[370.426,498.747,-1420.71],[7.50996E-05,0.891233,-0.453547,4.57222E-05]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[681.732,-61.6146,-1482.79],[0.438166,0.00385433,0.00836821,0.898847]],[[0,0,0],[1,0,0,0]]];!(primera version girada en simulador)

	!TOOLDATA
    TASK PERS tooldata SpinCap:=[TRUE, [[0,0,150],[1,0,0,0]],[0.70,[-0.00011,0.0,-0.08554],[1,0,0,0], 0.00142127, 0.00143746, 0.00177555]];
	
    !robtargets
    !Guardado con tool0
        CONST robtarget HomePrueba:=[[414.85,-218.35,-1107.22],[0,0.707176,-0.707038,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        CONST robtarget puntofinal:=[[197.10,-435.02,-1196.82],[0,0.641937,-0.766757,0],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        CONST robtarget llegadaPruebaTOR:=[[197.11,-435.02,-1107.15],[0,0.636569,-0.77122,0],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        CONST robtarget listoPruebaTOR:=[[197.10,-435.02,-1194.40],[0,0.641947,-0.766749,0],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !CON TOOL SPINCAP
        CONST robtarget tomarTapa:=[[0,0,-32.06],[0.00399958,0.41422,0.91013,-0.00829977],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        CONST robtarget SalidatomarTapa:=[[72.69,77.30,223.51],[0.00319209,0.325783,0.9454,-0.00864253],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        
        VAR jointtarget jposTomar;
        VAR robtarget  pos_actualTomar;
    
    !Variables de velocidad.
	CONST speeddata VRoscado := [50, 8000, 5000, 1000];         !Velocidad de roscado (giros). Actualmente en 8000, modificar el segundo parametro para este valor de giro de ejes.
    CONST speeddata VMovimientos := [8000, 500, 5000, 1000];    !Velocidad de movimientos cuando no hay riesgos, traslados sin tapa, etc.
    
    !Variables de Z
    VAR zonedata ZMovimientos := z50; !Z CON caja.
    
    !Variables
    VAR num tomarPosicionX; !Variable que almacena posicion en X, dada por camara.
    VAR num tomarPosicionY; !Variable que almacena posicion en Y, dada por camara.
    VAR num gradosTapa;     !Variable que almacena los grados para tomar frasco, dada por camara.
    VAR num alturaTapa;     !Variable que almacena la altura de tapa. 
    VAR num alturaFrasco;   !Variable que almacena la altura de frasco.
    VAR clock myClock;      !Variable de tiempo ciclo.
    VAR num tTotal;         !Variable para almacenar tiempo total de ciclo. 
    
    !Banderas de estado, para inicio de programa.
    VAR bool primerCiclo   := TRUE;
    PERS bool adentroFrasco := FALSE;
!---------------------------------------------------------------------------------
                                                                                  !--------------------------------------------------------------------------------
    PROC Main()   
        !Si es la primera ejecucion, se manda a home y se toma la foto
        IF primerCiclo THEN
            primerCiclo := FALSE;  !Reinicia variable de primer ciclo.
            Inicializacion;        !PROC de instrucciones de inicio de programa, movimiento a home, toma de foto, llamado a parametros iniciales.
        ENDIF
               
        !Ciclo principal
        WHILE TRUE DO
            CicloProduccion;   !Ir por tapa, roscar tapa.
        ENDWHILE
    ENDPROC
    
    PROC Inicializacion()
        !Resetea e inicia las variables para tomar el tiempo de ciclo.
        ClkReset myClock; !Reset
        ClkStart myClock; !Start
        
        SafeStart; !Ejecuta proc de inicio seguro. (Si el robot se quedo con el frasco cerca)
        
        MoveL HomePrueba, VMovimientos, z50, tool0;
        WaitRob \Inpos;
        ParametrosInicio; !LLamado a parametros iniciales, configuracion de servo suave, reinicio de variables, etc.
    ENDPROC
    
    PROC SafeStart() !Se encarga de salir en Z si se quedo el robot cerca del frasco, evitando colisiones con el frasco.
        IF adentroFrasco = TRUE THEN
            MoveL llegadaPruebaTOR, V100, z50, tool0\WObj:= wobj0;
            WaitRob\Inpos;
            adentroFrasco := FALSE; !Reiniciar variable cuando este en zona sin riesgo de colision.
        ENDIF
    ENDPROC
    
    PROC ParametrosInicio()
        ReiniciarVariables;
        TomarFoto;  
        alturaTapa   := GInput(REM_Z_TAPA);       !Recibe la altura de la tapa.
        alturaFrasco := GInput(REM_Z_BOTELLA);    !Recibe la altura del frasco.
        SoftAct 4, 0;  !Rigidez del servo -4- completa
    ENDPROC
    
    PROC CicloProduccion()
        !Proceso tamponadora --------------------------------------------------------------------------
        AgarrarTapa;
        DejarTapa;
        TomarFoto;
        
        ! Monitoreo de tiempos -------------------------------------------------------------------------
        ClkStop myClock;                 !Para contador de tiempo de ciclo.
        tTotal := ClkRead(myClock);      !Se guarda el tiempo de ciclo en la variables tTotal.
        TPWrite "Ciclo: "\Num:=tTotal;   !Se escribe el tiempo de ciclo en el TeachPendant.
        
        ClkReset myClock; !Reset de tiempo.
        ClkStart myClock; !Iniciio de tiempo.
    ENDPROC
    
    PROC LeerPosiciones()
        tomarPosicionX  := GInput (REM_POSICION_Y);         !Recibe la posicion de X de la tapa.
        tomarPosicionY  := GInput (REM_POSICION_X);         !Recibe la posicion de Y de la tapa.
        gradosTapa      := GInput (REM_POSICION_GRADOS);    !Recibe la posicon de giro de la herramienta, (eje 4). 
    ENDPROC
    
    PROC TomarFoto()
        WaitDI REM_BOOL_CAMARA_READY, 1;                !Esperar a camara.
        IF REM_BOOL_FRASCO_NUEVO = 0 THEN               !Señal que avisa si cambiaron las coordenadas (Que hay frasco nuevo) !Cambiar condicion a 1 en proceso real con la señal puesta en PLC.
            PulseDO ABB_BOOL_CAPTURAR_FOTO;             !Si se detecto frasco nuevo, tomar foto.
        ELSE
            MoveL llegadaPruebaTOR, v2500, z50, tool0;  !Si no se detecto frasco nuevo, ir a posicion segura de tomado de foto.
            WaitDI REM_BOOL_FRASCO_NUEVO, 1;            !Esperar que haya frasco nuevo.
            PulseDO ABB_BOOL_CAPTURAR_FOTO;             !Tomar foto.
        ENDIF 
    ENDPROC
    
    PROC AgarrarTapa()
        LeerPosiciones;   !Leer posiciones de -x-, -y- y -giro para la toma de tapa.
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, + 250), VMovimientos, ZMovimientos, SpinCap, \WObj:= wobjMesaTapas; !Ir 25cm arriba de la posicion de tomado. LLegada a tomar tapa.
        PulseDO ABB_BOOL_ACTIVAR_VACIO; !Activar vacio
        WaitRob \Inpos;
    
        !Obtener posición actual de ejes
        !jposTomar := CJointT();
    
        ! Modificar sólo el eje 4 (Gira los grados recibidos de camara)
        !jposTomar.robax.rax_4 := jposTomar.robax.rax_4 + gradosTapa;  ! Giro dependiendo valor recibido por camara.
    
        !MoveAbsJ jposTomar, VRoscado, z50, SpinCap\WObj:= wobjMesaTapas; !V5000
        !WaitRob \Inpos;  !NECESARIO
        
        !Bajar por tapa.
        pos_actualTomar := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actualTomar.trans.z := pos_actualTomar.trans.z - 250;  ! Baja la misma distancia en la que llego en Z. (250). Verificar cantidad en linea 136.
        MoveL pos_actualTomar, VMovimientos, fine, SpinCap\WObj:= wobjMesaTapas; !Va al punto calculado en linea anterior.
        WaitRob \Inpos;
        !WaitTime 0.5;
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, + 250), VMovimientos, ZMovimientos, SpinCap, \WObj:= wobjMesaTapas; !Va al mismo punto de llegada. (250mm arriba de la posicion de tapa. (Dada por camara.)
        WaitRob \Inpos;
    ENDPROC
 
    PROC DejarTapa()
        MoveL llegadaPruebaTOR, VMovimientos, z50, tool0; !Se posiciona encima del frasco.
        MoveL listoPruebaTOR, VMovimientos, z50, tool0; !Se posiciona en posicion para roscar.
        adentroFrasco := TRUE; !Bandera que indica que el robot esta en posicion riesgosa, cerca de frasco. (Para un posible incio de ciclo desde este punto).
        WaitRob \Inpos;
        RoscarTapas; !Llamado a PROC encargado de poner y roscar tapa de frasco. 
        MoveL llegadaPruebaTOR, VMovimientos, z50, tool0; !Salida despues de poner y roscar tapa.
        WaitRob \Inpos;
        adentroFrasco := FALSE; !Bandera indicando que ya esta en posicion segura para un posible inicio de ciclo desde este punto.
    ENDPROC

    PROC RoscarTapas ()
        !Variables utilizadas en roscado.
        VAR jointtarget jpos; !Jointtarget que almacena posiciones en ciertos momentos del ciclo.
        VAR num torque_umbral := 10; !Valor en el que el eje 4 llega al torque (Roscado completo de tapa).
        VAR num angulo_inicial; !Almacena el grado en el que se quedo el eje 4.
        VAR num paso_grado := 30; !Cantidad de grados en la que va girando el eje 4 para roscar tapa.  |  Paso de 5 para velocidad minima (manual) | Velocidad de 15 ultima 200825
        VAR robtarget pos_actual; !Robtarget que almacena posiciones en ciertos momentos del ciclo.
        VAR num giro := 360; !Variable que indica el giro total en el bucle.
        !----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
        SoftAct 4, 50 \Ramp:=200;  ! Eje 4, 20% suavidad
        AccSet 85, 100;
        
        jpos := CJointT(); ! Obtiene posición actual de ejes
    
        jpos.robax.rax_4 := jpos.robax.rax_4 - 90;  ! Indicacion de giro negativo de 90 para agarrar cuerda. 
        MoveAbsJ jpos, VRoscado, z50, tool0; ! Giro negativo de 90 para agarrar cuerda.
        
        WaitRob \Inpos;
        PulseDO ABB_BOOL_DESACTIVAR_VACIO;
        MoveJ puntofinal, V100, z50, tool0; !Movimiento pequeño hacia abajo mientras gira tapa ya en movimiento positivo. (Ejerce presion hacia abajo mientras gira el eje 4)
        WaitRob \Inpos;
        
        ! --- Inicio de roscado en el punto fijo ---
        jpos := CJointT(); !Obtener posición inicial
        angulo_inicial := jpos.robax.rax_4; !Obtiene angulo actual.
        
        ! --- Movimiento rápido con chequeo cada 30° hasta 360° ---
        FOR i FROM 1 TO giro STEP paso_grado DO
            jpos.robax.rax_4 := angulo_inicial + i;
            MoveAbsJ jpos, VRoscado, z1, tool0;
            TPWrite "Torque: " \Num:=GetMotorTorque(4); !Se muestra el valor de torque N/m. 
            
!           IF GetMotorTorque(4) > torque_umbral THEN
!               TPWrite "¡Tapa ajustada! Torque: " \Num:=GetMotorTorque(4);
!               EXIT;  ! Detiene el enroscado
!           ENDIF
        ENDFOR
        
        WaitRob \Inpos;
        AccSet 100, 100; !Reestablecer aceleracion.
        
        pos_actual := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actual.trans.z := pos_actual.trans.z + 20; ! Suma 20 mm en Z a la posicion actual.
        MoveL pos_actual, VMovimientos, fine, tool0;   ! Sube a punto indicado.

        SoftAct 4, 0;  ! Vuelve a rigidez completa
    ENDPROC
    
    PROC ReiniciarVariables ()
        tTotal := 0;
        TPErase;
    ENDPROC
    
ENDMODULE