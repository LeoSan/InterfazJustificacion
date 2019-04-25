<?php
class Gastos_Model_Justificacion{
    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Permite obtener los valores de los autorizadores
     * @access public
     *
     */
    public function getTipoAutorizadoresGasto( $params ) {
        $query = "BEGIN PENDUPM.PKG_JUSTIFICACION.obtenerAutorizadores(:RESDATA, " . $params['caso'] . "); END;";
        $Oracle = Pendum_Db_DbFactory::factory('oracle');
        $items = $Oracle->getAll($query);
        return $items;
    }

    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description permite obtener los casos
     * @access public
     *
     */
    public function getCasosPorAutorizador( $params ){
        $id_alarma  = $params['idAlarma'];
        $hidUsuario  = $params['hidUsuario'];
        //Nota: Compongo las reglas segun el tipo de alarma
        $reglas =  $this->reglasAutorizacion($params);
        $query = "BEGIN PENDUPM.PKG_JUSTIFICACION.obtenerAutorizadoresCasos(:RESDATA, " . $params['idGasto'] . ", '" . $reglas['condicion'] . "',  '" . $reglas['inner']  . "',  '" . $reglas['campo_resultado']  . "',  '" . $reglas['campo_justificacion']  . "',  '" . $reglas['campo_usuario']  . "', ".$id_alarma.", '".$hidUsuario."'  ); END;";
        $Oracle = Pendum_Db_DbFactory::factory('oracle');
        $items = $Oracle->getAll($query);
        return $items;
    }

    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Permite obtener los valores de los autorizadores
     * @access public
     *
     */
    public function procesarJustificacionMasiva( $params ) {
        $queryMasivo = "DECLARE psError VARCHAR(1000); ARRJUSTIFICACION PENDUPM.PKG_JUSTIFICACION.TABJUSTIFICAALERTA;	BEGIN";
        $indice = 1;
        $reglas =  $this->reglasAutorizacion($params);
        $query = "BEGIN PENDUPM.PKG_JUSTIFICACION.obtenerArregloMasivo(:RESDATA, " . $params['idGasto'] . ", '" . $reglas['condicion'] . "',  '" . $reglas['inner']  . "',  '" . $reglas['campo_justificacion']  . "' ); END;";
        $Oracle = Pendum_Db_DbFactory::factory('oracle');
        $items = $Oracle->getAll($query);

        //Nota: Compongo el arreglo masivo para editar los casos de manera masiva
        foreach ($items as $key => $filas) {
            $queryMasivo .= "
            			ARRJUSTIFICACION($indice).rIdGasto      := '".$filas['IDGASTOMAIN']."';
            			ARRJUSTIFICACION($indice).rConcepto    := ".$filas['IDCONCEPTO'].";
            			ARRJUSTIFICACION($indice).rAlerta         := ".$params['idAlarma'].";
            			ARRJUSTIFICACION($indice).rCredito       := '".$filas['FCCREDITOCARTERA']."';
            			ARRJUSTIFICACION($indice).rComentario := '".utf8_decode($params['justiValor'])."';
                        ARRJUSTIFICACION($indice).rFechaRegistro :='".$filas['FECHAREGISTRO']."';
                        ARRJUSTIFICACION($indice).rIdfacturacion :=".$filas['IDFACTURAASIGNACION'].";
                        ARRJUSTIFICACION($indice).rComentarioOld :='".$filas['CAMPOJUSTI']."';";
            $indice++;
        }
        $queryMasivo.=" PENDUPM.PKG_JUSTIFICACION.setJustificaAlerta(ARRJUSTIFICACION, ".$params['hidUsuario'].", :psError);END;";
        $Oracle = Pendum_Db_DbFactory::factory('oracle');
        $Oracle->set($queryMasivo);

    }


    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Permite obtener los valores de los autorizadores
     * @access public
     *
     */
    public function procesarJustificacion( $params ) {
        $queryIndi = "DECLARE psError VARCHAR(1000); ARRJUSTIFICACION PENDUPM.PKG_JUSTIFICACION.TABJUSTIFICAALERTA;	BEGIN";
        //Nota: Compongo el arreglo para un cambio individual
            $indice = 1;
            $queryIndi .= "
            			ARRJUSTIFICACION($indice).rIdGasto      := '".$params['idGasto']."';
            			ARRJUSTIFICACION($indice).rConcepto    := ".$params['idConcepto'].";
            			ARRJUSTIFICACION($indice).rAlerta         := ".$params['idAlarma'].";
            			ARRJUSTIFICACION($indice).rCredito       := '".$params['idCredito']."';
            			ARRJUSTIFICACION($indice).rComentario := '".utf8_decode($params['campoJusti'])."';
                        ARRJUSTIFICACION($indice).rFechaRegistro :='".$params['fechaRegistro']."';
                        ARRJUSTIFICACION($indice).rIdfacturacion :=".$params['idFacturacion'].";
                        ARRJUSTIFICACION($indice).rComentarioOld :='".$params['comentario_old']."';";
        $queryIndi.=" PENDUPM.PKG_JUSTIFICACION.setJustificaAlerta(ARRJUSTIFICACION, ".$params['hidUsuario'].", :psError);END;";
        $Oracle = Pendum_Db_DbFactory::factory('oracle');
        $Oracle->set($queryIndi);
    }

/**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Permite obtener los valores de los autorizadores
     * @access public
     *
     */
    public function reglasAutorizacion( $params ) {
            /*
                Nota:  Tipos de alarmas
                6: UMBRAL
				7: ETAPAS
				8: PAGO DOBLE
				10: EMPRESA
				34: URGENTE
                44: EXCEDENTE COMPROBCION
                45: ETAPAS FINALES
                46: STATUS COLAS CREDITOS
				68: ALERTA TAREAS
			*/

            $CONDICIONES  = array();
            switch($params['idAlarma'])
                            {
                                case '6': 	$condicion = "AND FCQUEUMBRAL > 0 ";
                                            $campo_justificacion = "fcjustificacionumbral  AS CAMPOJUSTI";
                                            $campo_resultado = "fcresumbral03,fcresumbral04,fcresumbral05";
                                            $campo_usuario = "fcusuumbral03,fcusuumbral04,fcusuumbral05";
                                            $inner="";
                                            $nameCheck="6";
                                            $nameClassJusti="justi_check6";
                                            break;
                                case '8': 	$condicion = "AND FNPAGODOBLE > 0 ";
                                            $campo_justificacion = "fcjustificapagodbl  AS CAMPOJUSTI";
                                            $campo_resultado = "fcrespgodbl01,fcrespgodbl02";
                                            $campo_usuario = "fcusupgodbl01,fcusupgodbl02";
                                            $inner="";
                                            $nameCheck="8";
                                            $nameClassJusti="justi_check8";
                                            break;
                                case '7': 	$condicion = "AND (VERETAPACDACHKNO IS NOT NULL OR VERETAPAABIERTANO IS NOT NULL OR FCCODACCEXTNO IS NOT NULL OR FCCODRESEXTNO IS NOT NULL)";
                                            $campo_justificacion = "fcjustificaetapa  AS CAMPOJUSTI";
                                            $campo_resultado = "fcresetapa01,fcresetapa02";
                                            $campo_usuario = "fcusuetapa01,fcusuetapa02";
                                            $inner="";
                                            $nameCheck="7";
                                            $nameClassJusti="justi_check7";
                                            break;
                                case '9': 	$condicion = "AND FCUSUJFEINMED IS NOT NULL ";
                                            $campo_justificacion = "A.IDCONCEPTO AS CAMPOJUSTI";
                                            $campo_resultado = "fcresultjfeinmed";
                                            $campo_usuario = "fcusujfeinmed";
                                            $inner="";
                                            $nameCheck="9";
                                            $nameClassJusti="justi_check9";
                                            break;
                                case '10': 	$condicion = "";
                                            $campo_justificacion = "fcjustificaempresa  AS CAMPOJUSTI";
                                            $campo_resultado = "fcresempresa";
                                            $campo_usuario = "fcusuempresa";
                                            $inner="";
                                            $nameCheck="10";
                                            $nameClassJusti="justi_check10";
                                            break;
                                case '34': 	$condicion = "";
                                            $campo_justificacion = "fcjustificaurgente  AS CAMPOJUSTI";
                                            $campo_resultado = "fcresurgente";
                                            $campo_usuario = "fcusuurgente";
                                            $inner="";
                                            $nameCheck="34";
                                            $nameClassJusti="justi_check34";
                                            break;
                                case '44': 	$condicion = "";
                                            $campo_justificacion = "fcjustificaexcgasto  AS CAMPOJUSTI";
                                            $campo_resultado = "fcresexcgasto01,fcresexcgasto02";
                                            $campo_usuario = "fcusuexcgasto01,fcusuexcgasto02";
                                            $inner="";
                                            $nameCheck="44";
                                            $nameClassJusti="justi_check44";
                                            break;
                                case '45': 	$condicion = "";
                                            $campo_justificacion = "fcjustificetafinal AS CAMPOJUSTI";
                                            $campo_resultado = "fcresetafinal01,fcresetafinal02";
                                            $campo_usuario = "fcusuetafinal01,fcusuetafinal02";
                                            $inner="";
                                            $nameCheck="45";
                                            $nameClassJusti="justi_check45";
                                            break;
                                case '46': 	$condicion = "AND (FCCREDSTATUS IS NOT NULL OR FCCREDCOLA IS NOT NULL)";
                                            $campo_justificacion = "fcjustificaliq AS CAMPOJUSTI";
                                            $campo_resultado = "fcresliq01,fcresliq02";
                                            $campo_usuario = "fcusuliquidado01,fcusuliquidado02";
                                            $inner="";
                                            $nameCheck="46";
                                            $nameClassJusti="justi_check46";
                                            break;
                                case '64': 	$condicion = "AND FCUSUPM IS NOT NULL AND FCESFACTURABLE = ''N'' ";
                                            $campo_justificacion = "FCJUSTIFICAPM  AS CAMPOJUSTI";
                                            $campo_resultado = "FCRESULTPM";
                                            $campo_usuario = "FCUSUPM";
                                            $inner="";
                                            $nameCheck="64";
                                            $nameClassJusti="justi_check64";
                                            break;
                                case '65': 	$condicion = "AND FCUSUNOFACT IS NOT NULL AND FCESFACTURABLE = ''N'' ";
                                            $campo_justificacion = "FCJUSTIFICANOFACT  AS CAMPOJUSTI";
                                            $campo_resultado = "FCRESULTNOFACT";
                                            $campo_usuario = "FCUSUNOFACT";
                                            $inner="";
                                            $nameCheck="65";
                                            $nameClassJusti="justi_check65";
                                            break;
                                case '66': 	$condicion = "";
                                            $campo_justificacion = "ALERTAFECHAEJECCOMENTARIO  AS CAMPOJUSTI";
                                            $campo_resultado = "";
                                            $campo_usuario = "";
                                            $inner="INNER JOIN PENDUPM.FACTURACIONAUT FAUT ON FAUT.IDGASTOMAIN = A.IDGASTOMAIN AND FAUT.FCCREDITOCARTERA = A.FCCREDITOCARTERA AND FAUT.FDFECAUTORIZA IS NULL AND FAUT.IDTIPOAUTORIZA = 66";
                                            $nameCheck="66";
                                            $nameClassJusti="justi_check66";
                                            break;
                                case '67': 	$condicion = " AND IDTIPOAUTORIZA = 67 AND C.FCREQALERTAASIGNA = ''S'' ";
                                            $campo_justificacion = "ALERTASIGNACOMENTARIO  AS CAMPOJUSTI";
                                            $campo_resultado = "";
                                            $campo_usuario = "";
                                            $inner=" INNER JOIN PENDUPM.FACTURACIONAUT B ON A.IDGASTOMAIN = B.IDGASTOMAIN  AND B.FCCREDITOCARTERA = A.FCCREDITOCARTERA INNER JOIN PENDUPM.CTCATALOGOCUENTAS C ON A.IDCONCEPTO = C.IDCONCEPTO";
                                            $nameCheck="67";
                                            $nameClassJusti="justi_check67";
                                            break;
                                case '68': 	$condicion = " AND IDTIPOAUTORIZA = 68";
                                            $campo_justificacion = "fcjustifiaciontarea  AS CAMPOJUSTI";
                                            $campo_resultado = "";
                                            $campo_usuario = "";
                                            $inner=" INNER JOIN PENDUPM.FACTURACIONAUT B ON A.IDGASTOMAIN = B.IDGASTOMAIN  AND B.FCCREDITOCARTERA = A.FCCREDITOCARTERA INNER JOIN PENDUPM.CTCATALOGOCUENTAS C ON A.IDCONCEPTO = C.IDCONCEPTO AND B.IDTASK_AUTORIZA > 0 ";
                                            $nameCheck="68";
                                            $nameClassJusti="justi_check68";
                                            break;

                                default: $condicion = ""; break;
                            }

                $CONDICIONES['inner'] = $inner;
                $CONDICIONES['condicion']  = $condicion ;
                $CONDICIONES['campo_justificacion']  = $campo_justificacion ;
                $CONDICIONES['campo_resultado']  = $campo_resultado ;
                $CONDICIONES['campo_usuario']  = $campo_usuario ;

                return $CONDICIONES;
    }

}
