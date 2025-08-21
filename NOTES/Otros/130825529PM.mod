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
    
	!TOOLDATA
    TASK PERS tooldata tr:=[TRUE,[[0,0,140],[1,0,0,0]],[5,[0,0,0],[1,0,0,0],0,0,0]];
	
    !robtargets
    CONST robtarget homeIv:=[[0.21,0.04,-1130.82],[0,1,-4.16494E-06,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget inicioRosca:=[[0.21,0.04,-1230.82],[0,1,-4.16494E-06,0],[0,8,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget tomarTapa:=[[235.88,-663.81,-1286.45],[0,1,-0.000261826,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget SalidatomarTapa:=[[235.93,-663.85,-1107.57],[0,1,0.000217543,0],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget llegada:=[[385.07,247.33,-1107.57],[0,1,-0.000124007,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget HomePrueba:=[[262.74,-273.09,-1107.04],[0,1,-0.000171944,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget posListoRosca:=[[385.06,247.32,-1142.35],[0,1,-0.000153968,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !Variables de velocidad.
	CONST speeddata VRoscado := [50, 8000, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    
    !Variables
    VAR num tor;
    VAR num giro := 360;
    
!---------------------------------------------------------------------------------
                                                                                !--------------------------------------------------------------------------------
    
    PROC main()
        MoveL HomePrueba, v2500, z50, tool0;
        AgarrarTapa;
        DejarTapa;
	ENDPROC
    
    PROC AgarrarTapa()
        MoveL SalidatomarTapa, v2500, z50, tool0;
        MoveJ tomarTapa, v500, z50, tool0;
        WaitRob \Inpos;
        WaitTime 1;
        MoveL SalidatomarTapa, v2500, z50, tool0;
    ENDPROC
    
    PROC DejarTapa()
        MoveL llegada, v2500, z50, tool0;
        MoveL posListoRosca, v50, z50, tool0;
        WaitRob \Inpos;
        !RoscarTapas;
        pruebaRoscarconTorque;
    ENDPROC
    
    PROC calcularTorque()
        !Lectura de torque, revisar con herramienta.
        tor := GetMotorTorque(4); !Se revisa torque de eje 4.
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
        VAR num torque_umbral := 10;  ! Ajustar según pruebas (ej. 10 Nm)
        VAR num angulo_inicial;
        VAR num paso_grado := 30;     ! Paso de 30° (equilibrio velocidad/precisión)
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

ENDMODULE