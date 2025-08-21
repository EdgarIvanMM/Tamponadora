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
    !TASK PERS wobjdata wobjConveyor:=[FALSE,TRUE,"",[[-142.767,103.657,-1415.01],[0.00864339,0.901113,-0.433479,-0.00414332]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata wobjMesaTapas:=[FALSE,TRUE,"",[[796.216,-70.6991,-1298.56],[0.440353,1.50213E-05,0.00987408,0.897771]],[[0,0,0],[1,0,0,0]]];
    
	!TOOLDATA
    TASK PERS tooldata tr:=[TRUE,[[0,0,140],[1,0,0,0]],[5,[0,0,0],[1,0,0,0],0,0,0]];
    TASK PERS tooldata SpinCap:=[TRUE, [[0,0,0],[1,0,0,0]],[0.70,[-0.00011,0.0,-0.08554],[1,0,0,0], 0.00142127, 0.00143746, 0.00177555]];
	
    !robtargets
    CONST robtarget homeIv:=[[0.21,0.04,-1130.82],[0,1,-4.16494E-06,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget inicioRosca:=[[0.21,0.04,-1230.82],[0,1,-4.16494E-06,0],[0,8,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget tomarTapa:=[[82.72,103.53,0.64],[7.16612E-05,0.445495,-0.89523,0.00987383],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    !CONST robtarget tomarTapa:=[[235.88,-663.81,-1286.45],[0,1,-0.000261826,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]; !CON WOBJ0
    CONST robtarget SalidatomarTapa:=[[81.07,106.87,190.25],[6.4088E-05,0.444809,-0.895571,0.00987388],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    !CONST robtarget SalidatomarTapa:=[[235.93,-663.85,-1107.57],[0,1,0.000217543,0],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]; !CON WOBJ0
    CONST robtarget llegada:=[[385.07,247.33,-1107.57],[0,1,-0.000124007,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget HomePrueba:=[[414.85,-218.35,-1107.22],[0,0.999989,-0.00459411,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget posListoRosca:=[[385.06,247.32,-1142.35],[0,1,-0.000153968,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    CONST robtarget llegadaPruebaTOR:=[[197.11,-435.03,-1107.14],[0,0.999982,-0.00594831,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    !CONST robtarget llegadaPruebaTOR:=[[193.44,-443.70,-1107.06],[0,1,-0.000201905,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget listoPruebaTOR:=[[197.11,-435.03,-1149.17],[0,0.999938,-0.0111612,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    !CONST robtarget listoPruebaTOR:=[[193.44,-443.70,-1146.97],[0,0.999999,0.00114033,0],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !Variables de velocidad.
	CONST speeddata VRoscado := [50, 8000, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    CONST speeddata VMovimientos := [50, 5000, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    
    VAR zonedata ZGiros       := z1; !Z SIN caja.
    VAR zonedata ZMovimientos := z50; !Z CON caja.
    
    !Variables
    VAR num tor;
    VAR num giro := 360;
    VAR num tomarPosicionX;
    VAR num tomarPosicionY;
    VAR num alturaTapa;
    VAR num alturaFrasco;
    
!---------------------------------------------------------------------------------
                                                                                !--------------------------------------------------------------------------------
    
    PROC main()
        MoveL HomePrueba, v2500, z50, tool0;
        MoveL llegadaPruebaTOR, v2500, z50, tool0;
        MoveL listoPruebaTOR, v2500, z50, tool0;
        !MoveLDO listoPruebaTOR, v2500, z30, tool0, ABB_BOOL_DESACTIVAR_VACIO,1; !PROBAR CON SEÑAL DE DESACTIVAR VACIO.
        WaitRob \Inpos;
        PruebaTorque;
        MoveL HomePrueba, v2500, z50, tool0;
        
        !MAIN REAL
        !MoveL HomePrueba, v2500, z50, tool0;
        !Parametros inicio
        !AgarrarTapa;
        !DejarTapa;
	ENDPROC
    
    PROC ParametrosInicio()
        ReiniciarVariables;
        TomarFoto;
        alturaTapa      := GInput(REM_Z_TAPA);       !Recibe la altura de la tapa.
        alturaFrasco    := GInput(REM_Z_BOTELLA);    !Recibe la altura del frasco.
    ENDPROC
    
    PROC LeerPosiciones()
        tomarPosicionX  := GInput (REM_POSICION_X);  !Recibe la posicion de X de la tapa.
        tomarPosicionY  := GInput (REM_POSICION_Y);  !Recibe la posicion de Y de la tapa.
        alturaTapa      := GInput(REM_Z_TAPA);       !Recibe la altura de la tapa.
        alturaFrasco    := GInput(REM_Z_BOTELLA);    !Recibe la altura del frasco.
    ENDPROC
    
    PROC TomarFoto()
        WaitDI REM_BOOL_CAMARA_READY, 1; !Esperar a camara.
        PulseDO ABB_BOOL_CAPTURAR_FOTO;
    ENDPROC
    
    PROC AgarrarTapa()
        LeerPosiciones;
        MoveL SalidatomarTapa, v2500, z50, tool0;
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, 250 + alturaTapa), VMovimientos, ZMovimientos, tool0, \WObj:= wobjMesaTapas;
        PulseDO ABB_BOOL_ACTIVAR_VACIO;
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, alturaTapa), VMovimientos, ZMovimientos, tool0, \WObj:= wobjMesaTapas;
        WaitRob \Inpos;
        WaitTime 1;
        MoveL Offs(tomarTapa, tomarPosicionX, tomarPosicionY, 250 + alturaTapa), VMovimientos, ZMovimientos, tool0, \WObj:= wobjMesaTapas;
    ENDPROC
    
    PROC DejarTapa()
        MoveL HomePrueba, v2500, z50, tool0;
        MoveL llegadaPruebaTOR, v2500, z50, tool0;
        MoveL listoPruebaTOR, v2500, z50, tool0;
        !PulseDO ABB_BOOL_ACTIVAR_VACIO;
        MoveLDO listoPruebaTOR, v2500, z30, tool0, ABB_BOOL_DESACTIVAR_VACIO,1; !PROBAR CON SEÑAL DE DESACTIVAR VACIO.
        WaitRob \Inpos;
        PruebaTorque;
    ENDPROC

    PROC RoscarTapas ()
        VAR jointtarget jpos;
        VAR robtarget pos_actual;
    
        !Girar 180 antes de la rosca. 
    
        ! --- Girar el eje 4 ---
        jpos := CJointT();
        jpos.robax.rax_4 := jpos.robax.rax_4 + giro;  ! Giro de 360°
        MoveAbsJ jpos, VRoscado, z50, tool0;          ! Usa speeddata VRoscado
        WaitRob \Inpos;
        WaitTime 2;
    
        pos_actual := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actual.trans.z := pos_actual.trans.z + 32;  ! Sube 32 mm en Z.
        MoveJ pos_actual, v500, fine, tool0;  ! Sube con orientación actual
    
        ! --- Volver a 0 grados ---
        jpos := CJointT();
        jpos.robax.rax_4 := jpos.robax.rax_4 - giro;  ! Giro de 360°
        MoveAbsJ jpos, VRoscado, z50, tool0;          ! Usa speeddata VRoscado
    ENDPROC
    
    PROC pruebaRoscarconTorque ()
        VAR jointtarget jpos;
        VAR num torque_umbral := 10;  ! Ajustar según pruebas.
        VAR num angulo_inicial;
        VAR num paso_grado := 15;     ! Paso de 30° (equilibrio velocidad/precisión)
        VAR robtarget pos_actual;
        
        ! --- Configurar servo suave en eje 4 ---
        SoftAct 4, 30 \Ramp:=150;  ! Solo eje 4, 30% suavidad
        
        ! --- Obtener posición inicial ---
        jpos := CJointT();
        angulo_inicial := jpos.robax.rax_4;
        
        ! --- Movimiento rápido con chequeo cada 30° ---
        FOR i FROM 1 TO giro STEP paso_grado DO
            jpos.robax.rax_4 := angulo_inicial + i;
            MoveAbsJ jpos, VRoscado, z1, tool0;  ! z1 para minimizar pausas
            TPWrite "¡Verificar! Torque: " \Num:=GetMotorTorque(4);
            
            IF GetMotorTorque(4) > torque_umbral THEN
                TPWrite "¡Tapa ajustada! Torque: " \Num:=GetMotorTorque(4);
                EXIT;  ! Detiene el enroscado
            ENDIF
        ENDFOR
        
        WaitRob \Inpos;
        WaitTime 2;
        
        pos_actual := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actual.trans.z := pos_actual.trans.z + 32;  ! Sube 32 mm en Z.
        MoveJ pos_actual, v500, fine, tool0;  ! Sube con orientación actual
    
        ! --- Volver a 0 grados ---
        jpos := CJointT();
        jpos.robax.rax_4 := jpos.robax.rax_4 - giro;  ! Giro de 360°
        MoveAbsJ jpos, VRoscado, z50, tool0;          ! Usa speeddata VRoscado
        
        ! --- Restaurar servos normales ---
        SoftAct 4, 0;  ! Vuelve a rigidez completa
    ENDPROC
    
    PROC PruebaTorque() !F140825
        VAR jointtarget jpos;
        VAR num torque_umbral := 10;  ! Ajustar según pruebas (ej. 10 Nm)
        VAR num angulo_inicial;
        VAR num paso_grado := 10;     ! Paso de 5 para velocidad minima (manual)
        VAR robtarget pos_actual;
        
        ! --- Configurar servo suave en eje 4 ---
        SoftAct 4, 20 \Ramp:=150;  ! Eje 4, 20% suavidad
        
        ! Obtener posición actual de ejes
        jpos := CJointT();
    
        ! Modificar sólo el eje 4 (ajusta el valor en grados)
        jpos.robax.rax_4 := jpos.robax.rax_4 - 90;  ! Giro de 360 grados
    
        !Mover con velocidad alta (v1000 = 100% de velocidad)
        MoveAbsJ jpos, VRoscado, z50, tool0; !V5000
        
        
        ! --- Obtener posición inicial ---
        jpos := CJointT();
        angulo_inicial := jpos.robax.rax_4;
        
        ! --- Movimiento rápido con chequeo cada 30° ---
        FOR i FROM 1 TO 390 STEP paso_grado DO !430 inicial.
            jpos.robax.rax_4 := angulo_inicial + i;
            MoveAbsJ jpos, VRoscado, z1, tool0;  ! z1 para minimizar pausas
            TPWrite "Torque: " \Num:=GetMotorTorque(4); !N/m
            
!            IF GetMotorTorque(4) > torque_umbral THEN
!                TPWrite "¡Tapa ajustada! Torque: " \Num:=GetMotorTorque(4);
!                EXIT;  ! Detiene el enroscado
!            ENDIF
        ENDFOR
        
        WaitRob \Inpos;
        WaitTime 2;
        
        pos_actual := CRobT();  ! Captura la posición actual, incluyendo la rotación del eje 4.
        pos_actual.trans.z := pos_actual.trans.z + 32;  ! Sube 32 mm en Z.
        MoveJ pos_actual, v500, fine, tool0;  ! Sube con orientación actual
    
        ! --- Volver a 0 grados ---
        jpos := CJointT();
        jpos.robax.rax_4 := jpos.robax.rax_4 - giro;  ! Giro de 360°
        MoveAbsJ jpos, VRoscado, z50, tool0;          ! Usa speeddata VRoscado
        TomarFoto;
        
        ! --- Restaurar servos normales ---
        SoftAct 4, 0;  ! Vuelve a rigidez completa
    ENDPROC
    
    PROC ReiniciarVariables ()
    ENDPROC

ENDMODULE