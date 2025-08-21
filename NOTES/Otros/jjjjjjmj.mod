MODULE MainModule
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
    CONST robtarget posListoRosca:=[[385.08,247.32,-1148.47],[0,1,-0.000213889,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !Variables de velocidad.
	CONST speeddata VRoscado := [50, 8000, 5000, 1000]; !Aumento de velocidad en el segundo parametro.
    
    !Variables
    PERS num rapid:=0;
    VAR num tor;
    
!---------------------------------------------------------------------------------
                                                                                !--------------------------------------------------------------------------------
    
    PROC main()
        MoveL HomePrueba, v2500, z50, tool0;
        AgarrarTapa;
        DejarTapa;
!        MoveJ homeIv, v2500, z50, tool0;
!        RoscarTapas;
!        MoveJ homeIv, v2500, z50, tool0;
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
        RoscarTapas;
        WaitRob \Inpos;
        MoveL llegada, v2500, z50, tool0;
    ENDPROC
    
    PROC calcularTorque()
        !Lectura de torque, revisar con herramienta.
        tor := GetMotorTorque(4); !Se revisa torque de eje 4.
    ENDPROC
    
    PROC RoscarTapas()
        VAR jointtarget jpos;
    
        ! Obtener posición actual de ejes
        jpos := CJointT();
    
        ! Modificar sólo el eje 4 (ajusta el valor en grados)
        jpos.robax.rax_4 := jpos.robax.rax_4 + 270;  ! Giro de 360 grados
    
        !Mover con velocidad alta (v1000 = 100% de velocidad)
        MoveAbsJ jpos, VRoscado, z50, tool0; !V5000
        
        WaitTime 3;
    ENDPROC

ENDMODULE