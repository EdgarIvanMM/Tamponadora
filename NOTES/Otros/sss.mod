MODULE MainModule
    ! Proyecto: Tamponadora CATOEX | TIA ROBOTICS.

    ! Historial de modificaciones:
    ! Fecha       | Ingeniero          | Descripción
    ! ------------|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------
    ! 2025-08-13  | Ivan Martinez      | Primera version sin coordenadas de camara.
    ! 2025-08-13  | Ivan Martinez      | Se agrego y probo el proc -pruebaRoscarconTorque- que verifica el torque en movimientos de 30 grados, al pasar el umbral, deja de roscar.   
    ! 0000-00-00  | ?????????          | 
    ! 0000-00-00  | ?????????          | 
    ! -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    !
    ! Proyecto en GitGub: https://github.com/EdgarIvanMM/Tamponadora.git
    !
    ! NOTA: REGISTRAR TODO CAMBIO REALIZADO PARA MANTENER TRAZABILIDAD.
    
    !Wobj 
	TASK PERS wobjdata wobjConveyor:=[FALSE,TRUE,"",[[370.426,498.747,-1420.71],[7.50996E-05,0.891233,-0.453547,4.57222E-05]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[681.52,19.0308,-1324.58],[0.00933603,0.709064097,-0.705079651,0.001905459]],[[0,0,0],[1,0,0,0]]];!(primera version girada en simulador)
    
    !TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[681.52,19.0308,-1324.58],[0.00921313,0.322974,-0.94636,-0.00243115]],[[0,0,0],[1,0,0,0]]]; !(utlima antes de girarlo en simulacion)
    !TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[681.52,-60.9692,-1324.58],[0.00921313,0.322974,-0.94636,-0.00243115]],[[0,0,0],[1,0,0,0]]]; !anterior
    !TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[796.216,-70.6991,-1298.56],[0.440353,1.50213E-05,0.00987408,0.897771]],[[0,0,0],[1,0,0,0]]];
	!TOOLDATA
    TASK PERS tooldata tr:=[TRUE,[[0,0,140],[1,0,0,0]],[5,[0,0,0],[1,0,0,0],0,0,0]];
    TASK PERS tooldata SpinCap:=[TRUE, [[0,0,150],[1,0,0,0]],[0.70,[-0.00011,0.0,-0.08554],[1,0,0,0], 0.00142127, 0.00143746, 0.00177555]];
	
    !robtargets
    CONST robtarget homeIv:=[[0.21,0.04,-1130.82],[0,1,-4.16494E-06,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget inicioRosca:=[[0.21,0.04,-1230.82],[0,1,-4.16494E-06,0],[0,8,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !Guardado con tool0
    !CONST robtarget tomarTapa:=[[0,0,23.86],[0.327601,0.00922492,0.00238603,-0.944768],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    !CONST robtarget SalidatomarTapa:=[[123.57,-26.24,-215.85],[0.327647,0.00922503,0.00238559,-0.944752],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget llegada:=[[385.07,247.33,-1107.57],[0,1,-0.000124007,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget HomePrueba:=[[414.85,-218.35,-1107.22],[0,0.999989,-0.00459411,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget posListoRosca:=[[385.06,247.32,-1142.35],[0,1,-0.000153968,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget puntofinal:=[[197.10,-435.00,-1160.81],[0,0.999944,-0.01061,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !CON TOOL SPINCAP
    CONST robtarget tomarTapa:=[[0,0,178.15],[0.709059,0.00933605,-0.00190539,-0.705085],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget SalidatomarTapa:=[[-7.15,138.41,-65.99],[0.709059,0.00933605,-0.00190539,-0.705085],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    CONST robtarget llegadaPruebaTOR:=[[197.11,-435.03,-1107.14],[0,0.999982,-0.00594831,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget listoPruebaTOR:=[[197.10,-435.01,-1158.49],[0,0.999944,-0.010598,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    VAR robtarget p1 := [[197.10,-435.00,-1160.81],[0,0.999944,-0.01061,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    VAR robtarget p2;
    VAR robtarget p12:=[[414.85,-218.34,-1107.23],[0,0.999982,-0.00606815,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    VAR robtarget p13:=[[373.00,-233.73,-1169.27],[0,0.841433,-0.540362,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    VAR jointtarget jposTomar;
    VAR robtarget  pos_actualTomar;
    
    !Variables de velocidad.
	CONST speeddata VRoscado := [50, 8000, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    CONST speeddata VMovimientos := [8000, 500, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    VAR zonedata ZGiros       := z1; !Z SIN caja.
    VAR zonedata ZMovimientos := z50; !Z CON caja.
    
    !Variables
    VAR num tor;
    VAR num giro := 360;
    VAR num tomarPosicionX;
    VAR num tomarPosicionY;
    VAR num gradosTapa;
    VAR num alturaTapa;
    VAR num alturaFrasco;
    VAR clock myClock; 
    VAR num tTotal;    
    
!---------------------------------------------------------------------------------
                                                                                !--------------------------------------------------------------------------------
    PROC main()
        !PruebasDeTorque; !Solo para pruebas de roscado, comentar en proceso real.
        
        !MAIN
        ! Reiniciamos y arrancamos el cronómetro
        ClkReset myClock;
        ClkStart myClock;
        
        MoveL HomePrueba, v2500, z50, tool0;
        WaitRob \Inpos;
        ParametrosInicio;
        AgarrarTapa;
        DejarTapa;
        
        ! Detenemos y leemos cronómetro
        ClkStop myClock;
        tTotal := ClkRead(myClock);

        ! Mostramos en el FlexPendant
        TPWrite "Tiempo transcurrido: "\Num:=tTotal;
	ENDPROC
    
    PROC ParametrosInicio()
        ReiniciarVariables;
        TomarFoto;
        alturaTapa      := GInput(REM_Z_TAPA);       !Recibe la altura de la tapa.
        alturaFrasco    := GInput(REM_Z_BOTELLA);    !Recibe la altura del frasco.
    ENDPROC
    
    PROC LeerPosiciones()
        tomarPosicionX  := GInput (REM_POSICION_X)/10;         !Recibe la posicion de X de la tapa.
        !tomarPosicionX := tomarPosicionX*(-1);
        tomarPosicionY  := GInput (REM_POSICION_Y)/10;         !Recibe la posicion de Y de la tapa.
        !tomarPosicionY  := tomarPosicionY*(-1);
        gradosTapa      := GInput (REM_POSICION_GRADOS);    !Recibe la posicon de giro de la herramienta, (eje 4).
    ENDPROC
    
    PROC TomarFoto()
        WaitDI REM_BOOL_CAMARA_READY, 1;                !Esperar a camara.
        IF REM_BOOL_FRASCO_NUEVO = 0 THEN               !Señal que avisa si cambiaron las coordenadas (Que hay frasco nuevo)
            PulseDO ABB_BOOL_CAPTURAR_FOTO;             !Si se detecto frasco nuevo, tomar foto.
        ELSE
            MoveL SalidatomarTapa, v2500, z50, tool0\WObj:= wobjMesaTapas;   !Si no se detecto frasco nuevo, ir a posicion segura de tomado de foto.
            WaitDI REM_BOOL_FRASCO_NUEVO, 1;                                 !Esperar que haya frasco nuevo.
            PulseDO ABB_BOOL_CAPTURAR_FOTO;                                  !Tomar foto.
        ENDIF 
    ENDPROC
    
    PROC AgarrarTapa()
        LeerPosiciones;   !Leer posiciones de -x-, -y- y -giro para la toma de tapa.
        MoveL SalidatomarTapa, v2500, z50, SpinCap, \WObj:= wobjMesaTapas; !Posicionarse en la salida segura de tomar tapa
        PulseDO ABB_BOOL_ACTIVAR_VACIO; !Activar vacio
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, -100), VMovimientos, ZMovimientos, SpinCap, \WObj:= wobjMesaTapas; !Ir 10cm arriba de la posicion de tomado. (ya con coordenadas de camara).
        WaitRob \Inpos;
        
        !Gira dependiendo grados recibidos de camara
        !Obtener posición actual de ejes
        jposTomar := CJointT();
    
        ! Modificar sólo el eje 4 (ajusta el valor en grados)
        jposTomar.robax.rax_4 := jposTomar.robax.rax_4 + gradosTapa;  ! Giro dependiendo valor recibido por camara.
    
        !Mover con velocidad alta (v1000 = 100% de velocidad)
        MoveAbsJ jposTomar, VRoscado, z50, SpinCap\WObj:= wobjMesaTapas; !V5000
        WaitRob \Inpos;
        
        !Bajar por tapa.
        pos_actualTomar := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actualTomar.trans.z := pos_actualTomar.trans.z - 50;  ! Baja -Altura Tapa- en Z.
        MoveL pos_actualTomar, VMovimientos, fine, SpinCap\WObj:= wobjMesaTapas;
        WaitRob \Inpos;
        WaitTime 1;
        MoveL SalidatomarTapa, v2500, z50, SpinCap, \WObj:= wobjMesaTapas; !Posicionarse en la salida segura de tomar tapa.
    ENDPROC
    
    PROC DejarTapa()
        MoveL HomePrueba, v2500, z50, tool0;            !Pasar por zona segura. 
        MoveL llegadaPruebaTOR, v2500, z50, tool0;      !Se posiciona encima del frasco.
        MoveL listoPruebaTOR, v2500, z50, tool0;        !Se posiciona en posicion pra roscar.
        !WaitRob \Inpos;
        RoscarTapas;
    ENDPROC

    PROC RoscarTapas ()
        VAR jointtarget jpos;
        VAR num torque_umbral := 10;  ! Ajustar según pruebas
        VAR num angulo_inicial;
        VAR num paso_grado := 15;     ! Paso de 5 para velocidad minima (manual)
        VAR robtarget pos_actual;
        
        ! --- Configurar servo suave en eje 4 ---
        SoftAct 4, 20 \Ramp:=200;  ! Eje 4, 20% suavidad
        AccSet 85, 100;
        
        ! Obtener posición actual de ejes
        jpos := CJointT();
    
        ! Modificar sólo el eje 4 (ajusta el valor en grados)
        jpos.robax.rax_4 := jpos.robax.rax_4 - 90;  ! Giro de 360 grados
    
        !Mover con velocidad alta (v1000 = 100% de velocidad)
        MoveAbsJ jpos, VRoscado, z50, tool0; !V5000
        WaitRob \Inpos;
        PulseDO ABB_BOOL_DESACTIVAR_VACIO;
        MoveJ puntofinal, V100, z50, tool0;
        WaitRob \Inpos;
        
        ! --- Obtener posición inicial ---
        jpos := CJointT();
        angulo_inicial := jpos.robax.rax_4;
        
        ! --- Movimiento rápido con chequeo cada 30° ---
        FOR i FROM 1 TO 450 STEP paso_grado DO !430 inicial.
            jpos.robax.rax_4 := angulo_inicial + i;
            MoveAbsJ jpos, VRoscado, z1, tool0;  ! z1 para minimizar pausas
            TPWrite "Torque: " \Num:=GetMotorTorque(4); !N/m
            
!           IF GetMotorTorque(4) > torque_umbral THEN
!               TPWrite "¡Tapa ajustada! Torque: " \Num:=GetMotorTorque(4);
!               EXIT;  ! Detiene el enroscado
!           ENDIF
        ENDFOR
        
        WaitRob \Inpos;
        !WaitTime 2;
        AccSet 100, 100;
        
        pos_actual := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actual.trans.z := pos_actual.trans.z + 32;  ! Sube 32 mm en Z.
        MoveL pos_actual, VMovimientos, fine, tool0;  ! Sube con orientación actual
    
        ! --- Volver a 0 grados ---
        jpos := CJointT();
        jpos.robax.rax_4 := jpos.robax.rax_4 - giro;  ! Giro de 360°
        MoveAbsJ jpos, VRoscado, z50, tool0;          ! Usa speeddata VRoscado
        
        ! --- Restaurar servos normales ---
        SoftAct 4, 0;  ! Vuelve a rigidez completa
        
        !TomarFoto;
    ENDPROC
    
    PROC ReiniciarVariables ()
        tTotal := 0;
        TPErase;
    ENDPROC
    
    PROC PruebasDeTorque()
        ! Reiniciamos y arrancamos el cronómetro
        ClkReset myClock;
        ClkStart myClock;
        
        MoveL HomePrueba, VMovimientos, z50, tool0; !2500
        PulseDO ABB_BOOL_ACTIVAR_VACIO;
        AccSet 100, 30;  !100,30
        MoveL llegadaPruebaTOR, V7000, z50, tool0; !v2500
        MoveL listoPruebaTOR, v7000, z50, tool0; !V1000
        !MoveLDO listoPruebaTOR, v2500, z30, tool0, ABB_BOOL_DESACTIVAR_VACIO,1; !PROBAR CON SEÑAL DE DESACTIVAR VACIO.
        WaitRob \Inpos;
        !WaitTime 1;
        AccSet 100, 100;  !Este es el problema.
        RoscarTapas;
        !SetDO ABB_BOOL_DESACTIVAR_VACIO,0;
        MoveL HomePrueba, VMovimientos, z50, tool0;
        WaitRob \Inpos;
        
        ! Detenemos y leemos cronómetro
        ClkStop myClock;
        tTotal := ClkRead(myClock);

        ! Mostramos en el FlexPendant
        TPWrite "Tiempo transcurrido: "\Num:=tTotal;
        EXIT;
    ENDPROC

ENDMODULE