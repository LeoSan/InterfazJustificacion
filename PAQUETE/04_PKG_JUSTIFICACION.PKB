create or replace PACKAGE BODY  PENDUPM.PKG_JUSTIFICACION IS
/*
	Interfaz JUSTIFICACION
	Fecha de creacion:    20 - Marzo - 2019
*/

--Procesos OBTENER

	PROCEDURE obtenerAutorizadores(resultDatos IN OUT T_CURSOR, pGASTO INTEGER DEFAULT '') IS

        psErrorD     VARCHAR2(2000) := '';
        qryArma      CLOB := '';
        qryArmaValid CLOB := '';

        BEGIN

			qryArma := 'SELECT * FROM PENDUPM.CTETAPASFACTURACION WHERE TPOAUT IN (SELECT IDTIPOAUTORIZA FROM PENDUPM.FACTURACIONAUT WHERE IDGASTOMAIN = ' || pGASTO || ' AND FDFECAUTORIZA IS NULL GROUP BY IDTIPOAUTORIZA )';

        OPEN resultDatos FOR
            qryArma;

    EXCEPTION WHEN OTHERS THEN
         psErrorD := SUBSTR (SQLERRM, 1, 490);
         OPEN resultDatos FOR
            SELECT  1 "ERROR", '*ERROR* '|| psErrorD "MSG" FROM DUAL ;
    END obtenerAutorizadores;

	PROCEDURE obtenerArregloMasivo(resultDatos IN OUT T_CURSOR, pGASTO INTEGER DEFAULT '', pCONDICION VARCHAR2 DEFAULT '', pINNER VARCHAR2 DEFAULT '', pJUSTIFICACION VARCHAR2 DEFAULT '' ) IS

        psErrorD     VARCHAR2(2000) := '';
        qryArma      CLOB := '';
        qryArmaValid CLOB := '';

        BEGIN

			qryArma := 'SELECT A.IDCONCEPTO
                            , A.FCCREDITOCARTERA
                            , TO_CHAR(A.FDFECREGISTRO, ''DDMMYYYYHH24MISS'') FECHAREGISTRO
                            , A.IDGASTOMAIN
                            , A.IDFACTURAASIGNACION
                            , '|| pJUSTIFICACION ||'
                    FROM PENDUPM.FACTURAASIGNACION A
                        ' || pINNER || '
                    WHERE A.IDGASTOMAIN = ' || pGASTO || ' ' || pCONDICION ;

        OPEN resultDatos FOR
            qryArma;

    EXCEPTION WHEN OTHERS THEN
         psErrorD := SUBSTR (SQLERRM, 1, 490);
         OPEN resultDatos FOR
            SELECT  1 "ERROR", '*ERROR* '|| psErrorD "MSG" FROM DUAL ;
    END obtenerArregloMasivo;

    PROCEDURE obtenerAutorizadoresCasos(resultDatos IN OUT T_CURSOR, pGASTO INTEGER DEFAULT '', pCONDICION VARCHAR2 DEFAULT '', pINNER VARCHAR2 DEFAULT '', pRESULTADO VARCHAR2 DEFAULT '', pJUSTIFICACION VARCHAR2 DEFAULT '', pUSUARIO VARCHAR2 DEFAULT '', pALARMA INTEGER DEFAULT '', pUSUARIOX2X5 VARCHAR2 DEFAULT ''  ) IS

        psErrorD     VARCHAR2(2000) := '';
        qryArma      CLOB := '';
        qryArmaValid CLOB := '';

        BEGIN

			qryArma := 'SELECT A.IDCONCEPTO
                    ,  A.FCCREDITOCARTERA
                    ,  TO_CHAR(A.FDFECREGISTRO, ''DDMMYYYYHH24MISS'') FECHAREGISTRO
                    ,  A.IDGASTOMAIN
                    ,  A.IDFACTURAASIGNACION
                    ,  (SELECT NMCONCEPTO FROM PENDUPM.CTCATALOGOCUENTAS B WHERE B.IDCONCEPTO = A.IDCONCEPTO) CONCEPTO
                    ,  (SELECT NMDESCRIP  FROM PENDUPM.CTCUENTACATEGORIA C WHERE C.IDCUENTACAT = (SELECT IDCATEGORIA FROM PENDUPM.CTCATALOGOCUENTAS H WHERE A.IDCONCEPTO = H.IDCONCEPTO))||'' / ''|| '' ''||(SELECT NMDESCRIP  FROM PENDUPM.CTCUENTACATEGORIA C WHERE C.IDCUENTACAT = (SELECT IDSUBCATEGORIA FROM PENDUPM.CTCATALOGOCUENTAS H WHERE A.IDCONCEPTO = H.IDCONCEPTO)) CATEGSUBCAT
                    ,  A.FCDETALLECREDITO
                    , '|| pJUSTIFICACION ||'
                    , '|| pRESULTADO ||'
                    , '|| pUSUARIO ||'
                    , (  '|| pALARMA ||' ) AS ALARMA
                    , CASE WHEN '|| pALARMA ||' = 6  THEN ''Monto Umbral superado : '' || PENDUPM.PCKCONVENIOS.formatComas(FNIMPORTE)
                           WHEN '|| pALARMA ||' = 66 THEN ''Fecha ejecucion: <br /><b>''||TO_CHAR(FECHA_EJECUCION,''DD-MM-YYYY'')||''</b><br /> menor a fecha solicitud: <br> <b>''||TO_CHAR(A.FDFECREGISTRO,''DD-MM-YYYY'')||''</b>''
                           WHEN '|| pALARMA ||' = 67 THEN ''El proveedor: <br /><b>''||(SELECT NMPROVEEDOR FROM PENDUPM.CTPROVEEDORGASTO PG WHERE PG.IDPROVEEDORGTO IN (SELECT FM.IDPROVEEDORGTO FROM PENDUPM.FACTURACIONMAIN FM WHERE FM.IDGASTOMAIN = ' || pGASTO || ' ))||''</b> <br />no pertenece a la cuenta: <br /><b>''||A.FCCREDITOCARTERA||''</b>''
                           WHEN '|| pALARMA ||' = 68 THEN ''N° Tarea: <br /><b>''|| A.NOTAREA ||''</b> <br />Categoria: <br /><b>''||(SELECT DESCRIPCION  FROM PENDUCRM.CAT_CLASIFICA_TAREA WHERE STATUS  = 1 AND TIPO = ''AB'' AND  ID IN (SELECT CLASIFICA_TAREA  FROM PENDUCRM.TAREA TAR WHERE  ID = A.NOTAREA))||''</b> <br />Estado: <br /><b>''||(SELECT DESC_EDO_TAREA FROM PENDUCRM.CAT_ESTADO_TAREA WHERE ID IN (SELECT ID_ESTADO FROM PENDUCRM.TAREA TAR WHERE  ID = A.NOTAREA))||''</b>''
                           WHEN '|| pALARMA ||' = 8  THEN TO_CHAR(FNPAGODOBLE)
                           WHEN '|| pALARMA ||' = 45 THEN ''ETAPA CRR/VER: ''||A.VERETAPAFIN
                           WHEN '|| pALARMA ||' = 46 THEN CASE WHEN A.FCCREDSTATUS IS NOT NULL THEN ''ESTATUS: ''||NVL(A.FCCREDSTATUS,'''')  END||'' ''|| CASE WHEN A.FCCREDCOLA IS NOT NULL THEN ''COLA: ''||NVL(A.FCCREDCOLA,'''') END
                           WHEN '|| pALARMA ||' = 7  THEN CASE WHEN A.VERETAPACDACHK IS NOT NULL THEN ''ETAPA CRR/VER: ''||A.VERETAPACDACHK END||'' ''|| CASE WHEN A.VERETAPAABIERTA IS NOT NULL THEN ''ETAPA ABR: ''||A.VERETAPAABIERTA END||'' ''|| CASE WHEN A.FCCODACCEXT IS NOT NULL THEN ''CA: ''||A.FCCODACCEXT END||'' ''|| CASE WHEN A.FCCODRESEXT IS NOT NULL THEN ''CR: ''||A.FCCODRESEXT END
                      ELSE ''''
                    END FNIMPORTE
                    , ( SELECT CLCOLLID FROM rcvry.collid where CLIDNUM = '|| pUSUARIOX2X5 ||' and clstatus <> ''3'' ) AS USERS
                        FROM PENDUPM.FACTURAASIGNACION A
                        ' || pINNER || '
                    WHERE A.IDGASTOMAIN = ' || pGASTO || ' ' || pCONDICION ;
        OPEN resultDatos FOR
            qryArma;

    EXCEPTION WHEN OTHERS THEN
         psErrorD := SUBSTR (SQLERRM, 1, 490);
         OPEN resultDatos FOR
            SELECT  1 "ERROR", '*ERROR* '|| psErrorD "MSG" FROM DUAL ;
    END obtenerAutorizadoresCasos;


-- Procesos Upsate

   PROCEDURE setJustificaAlerta (
      arrDetalle       PKG_JUSTIFICACION.TABJUSTIFICAALERTA,
      pnUsuario        INTEGER,
      psError      OUT VARCHAR2)
   IS
      psErrorD   VARCHAR2 (4000) := '';
      liBarre    INTEGER := 0;
   BEGIN
      FOR liBarre IN 1 .. arrDetalle.COUNT
      LOOP
         IF (arrDetalle (liBarre).rAlerta = 6)
         THEN                                                     /* UMBRAL */
            DBMS_OUTPUT.PUT_LINE (
                  '6----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICACIONUMBRAL = arrDetalle (liBarre).rComentario
             WHERE     IDGASTOMAIN = arrDetalle (liBarre).rIdGasto
                   AND IDCONCEPTO = arrDetalle (liBarre).rConcepto
                   AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito
                   AND TO_CHAR(FDFECREGISTRO, 'DDMMYYYYHH24MISS') =  arrDetalle (liBarre).rFechaRegistro AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 7)
         THEN                                                     /* ETAPAS */
            DBMS_OUTPUT.PUT_LINE (
                  '7----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICAETAPA = arrDetalle (liBarre).rComentario
             WHERE     IDGASTOMAIN = arrDetalle (liBarre).rIdGasto
                   AND IDCONCEPTO = arrDetalle (liBarre).rConcepto
                   AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito
                   AND TO_CHAR(FDFECREGISTRO, 'DDMMYYYYHH24MISS') =  arrDetalle (liBarre).rFechaRegistro;
         ELSIF (arrDetalle (liBarre).rAlerta = 8)
         THEN                                                 /* PAGO DOBLE */
            DBMS_OUTPUT.PUT_LINE (
                  '8----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICAPAGODBL = arrDetalle (liBarre).rComentario
             WHERE     IDGASTOMAIN = arrDetalle (liBarre).rIdGasto
                   AND IDCONCEPTO = arrDetalle (liBarre).rConcepto
                   AND TO_CHAR(FDFECREGISTRO, 'DDMMYYYYHH24MISS') =  arrDetalle (liBarre).rFechaRegistro AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 10)
         THEN                                                     /* EMPRESA*/
            DBMS_OUTPUT.PUT_LINE (
                  '10----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICAEMPRESA = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle (liBarre).rIdGasto AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito AND IDCONCEPTO = arrDetalle (liBarre).rConcepto AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 34)
         THEN                                                    /* URGENTE */
            DBMS_OUTPUT.PUT_LINE (
                  '34----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICAURGENTE = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle (liBarre).rIdGasto AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito AND IDCONCEPTO = arrDetalle (liBarre).rConcepto AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 44)
         THEN                                  /* EXCEPCION DE COMPROBACION */
            DBMS_OUTPUT.PUT_LINE (
                  '44----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICAEXCGASTO = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle (liBarre).rIdGasto AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito AND IDCONCEPTO = arrDetalle (liBarre).rConcepto AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 45)
         THEN                                   /* ETAPA FINAL COMPROBACION */
            DBMS_OUTPUT.PUT_LINE (
                  '45----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICETAFINAL = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle (liBarre).rIdGasto;
         ELSIF (arrDetalle (liBarre).rAlerta = 68)
         THEN                                   /* ALERTA TAREA */
            DBMS_OUTPUT.PUT_LINE (
                  '68----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFIACIONTAREA = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle (liBarre).rIdGasto AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito AND IDCONCEPTO = arrDetalle (liBarre).rConcepto AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         ELSIF (arrDetalle (liBarre).rAlerta = 46)
         THEN                                 /* CREDITOS LIQ  EXCEPCIONA?ES*/
            DBMS_OUTPUT.PUT_LINE (
                  '46----'
               || arrDetalle (liBarre).rIdGasto
               || '-'
               || arrDetalle (liBarre).rConcepto
               || '-'
               || arrDetalle (liBarre).rCredito
               || '-'
               || arrDetalle (liBarre).rComentario);

            UPDATE FACTURAASIGNACION
               SET FCJUSTIFICALIQ = arrDetalle (liBarre).rComentario
             WHERE IDGASTOMAIN = arrDetalle(liBarre).rIdGasto AND FCCREDITOCARTERA = arrDetalle (liBarre).rCredito AND IDCONCEPTO = arrDetalle (liBarre).rConcepto AND IDFACTURAASIGNACION = arrDetalle (liBarre).rIdfacturacion;
         END IF;

         -- Insert Bitacora
         INSERT INTO PENDUPM.GAS_BITACORA_JUSTI (ID_GAS_BITACORA, ID_GASTO, ID_GASTOASIGNACION, CVETRA, ID_ALARMA, ID_CREDITO, COMENTARIO_OLD, COMENTARIO_NEW, FECHA_MOVIMIENTO, NOM_TIPO )
             VALUES (PENDUPM.SEQ_GAS_BITACORA_JUSTI.nextval, arrDetalle(liBarre).rIdGasto, arrDetalle(liBarre).rIdfacturacion, pnUsuario, arrDetalle(liBarre).rAlerta, arrDetalle(liBarre).rCredito, arrDetalle(liBarre).rComentarioOld, arrDetalle(liBarre).rComentario, SYSDATE, 'JUSTIFICACIONES');

      END LOOP;

      psError := '0';
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         psErrorD := SUBSTR (SQLERRM, 1, 490);
         psError := '*ERROR* ' || psErrorD;
   END setJustificaAlerta;


END PKG_JUSTIFICACION;
