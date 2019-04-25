//SIN VINCULAR CON PRODUCCION #SINVINCULAR
var procesoJustificacion = {
    //Declaracion Variables
    EstruturaMesajeExito:    '<div class="alert alert-success has-icon" role="alert"><div class="alert-icon"><span class="fa fa-bullhorn"></span></div> <span class="spParrafo"> i_mensaje </span></div>',
    EstruturaMesajeInfo:      '<div class="alert alert-info has-icon" role="alert"><div class="alert-icon"><span class="fa fa-bullhorn"></span></div> <span class="spParrafo"> i_mensaje </span></div>',
    EstruturaMesajePeligro:  '<div class="alert alert-danger has-icon" role="alert"><div class="alert-icon"><span class="fa fa-bullhorn"></span></div> <span class="spParrafo"> i_mensaje </span></div>',
    EstruturaMesajeAdvertencia: '<div class="alert alert-warning has-icon" role="alert"><div class="alert-icon"><span class="fa fa-bullhorn"></span></div> <span class="spParrafo"> i_mensaje </span></div>',
    mensajeLoad:  '<div class="loading"><div class="loader loader-lg"></div> Cargando datos.</div>',
    mensajeExito01:  '! Almacenamiento exitoso de Datos ¡',
    mensajePeligro01:  '! Falla en el almacenamiento, intente mas tarde ¡',
    mensajeAdvertencia01:'Disculpe, debe seleccionar los campos fecha, hora y almenos una cuenta.',
    mensajeAdvertencia02:'! Por favor espere mientras se agregan los datos ¡',
    mensajeAdvertencia03:'! El credito no existe ¡',
    mensajeAdvertencia04:'! Disculpe, debe ingresar un número de credito valido ¡',
    mensajeAdvertencia05:'! Se estan eliminando los registro. ¡',
    mensajeAdvertencia06:'! Disculpe,  almenos debe seleccionar una cuenta. ¡',
    mensajeAdvertencia07:'! Disculpe, Debe ingresar un numero de cedito y cartera valido. ¡',
    mensajeError1: 'No hay conexión, verifique la red.',
    mensajeError2: 'Pagina no encontrada, Error [404].',
    mensajeError3: 'Internal Server Error [500].',
    mensajeError4: 'Error de respuesta,  JSON failed.',
    mensajeError5: 'El tiempo expiro, valide el archivo es muy extenso para la red, [Time out error].',
    mensajeError6: 'Ajax request aborted.',
    mensajeError7: 'Error capturado -> ',
    urlViewJustifiCasos : "/gastos/justificacion/view-justificacion-caso",
    urlProcesoMasivo : "/gastos/justificacion/proceso-masivo",
    //Metodo Inicial
    init: function () {
        //Carga
        procesoJustificacion.validaTeclado();
        procesoJustificacion.customAniamtionLoader(2, '#pendulum-loader' );

        //Eventos
        procesoJustificacion.btnJustificacionMasivo();
        procesoJustificacion.btnJustificacion();
        //Proceso
        procesoJustificacion.btnConsultaCasosAutorizador();

    },// fin init
    /****************** /js/loading-actions ***********************************/
        disableConatinerLoading:function(){
            loadingActions.disableLoading(procesoActivo.idLoadingMain);
        },
        enableConatinerLoading:function(){
            loadingActions.enableLoading(procesoActivo.idLoadingMain);
        },
        customAniamtionLoader:function(timeDelay, idContenido){
            loadingActions.customAniamtionLoader(timeDelay,idContenido);
        },
        disableConatinerLoadingListaAsignaciones:function(){
            loadingActions.disableLoading(procesoActivo.idLoadingListaAsignaciones);
        },
        enableConatinerLoadingListaAsignaciones:function(){
            loadingActions.enableLoading(procesoActivo.idLoadingListaAsignaciones);
        },
/*********************************************************************/
    btnConsultaCasosAutorizador:function () {
        $(document).on("click", ".btnRecargaCategoria", function () {
            var idTipo = $(this).attr('data-id_etapa');
            var hidGasto = $("#hidGasto").val();
            var hidUsuario = $("#hidUsuario").val();
            var tipoAutorizador = $(this).attr('data-id_tipoaut');
			
			var caracter = $("#contenedorCasos_" + tipoAutorizador).html();
			
			console.log("prueba " + caracter.length);

			if( caracter.length <= 51){//Esto es para que no vuelva a consultar en caso que el layout ya tenga una información previa
	            $.ajax({
                   type: "POST",
                   url: baseUrl + procesoJustificacion.urlViewJustifiCasos,
                   processData: true,
                   data: {'idGasto':hidGasto, 'hidUsuario':hidUsuario, 'idAlarma':tipoAutorizador, 'idTipo':idTipo, 'tipo':'false' },
                   dataType:'html',
                   beforeSend:function(){
                        $("#contenedorCasos_" + tipoAutorizador).html( procesoJustificacion.mensajeLoad );
                     }, success: function (data) {
                         $("#contenedorCasos_" + tipoAutorizador).html(data );
                    }, error: function (jqXHR, textStatus, errorThrown) {
                         procesoJustificacion.validarErrror(jqXHR, textStatus, errorThrown);
                    }
				});
			}
			

        });
    },
    validaTeclado: function () {
            $(document).on("keypress", ".soloLetrasNumeros", function (e) {
                procesoJustificacion.metodoTeclado(e, "soloLetrasNumeros", this);
            });
    },
    metodoTeclado: function (e, permitidos, fieldObj, upperCase) {

        if (fieldObj.readOnly) return false;
        upperCase = typeof(upperCase) != 'undefined' ? upperCase : true;
        e = e || event;

        charCode = e.keyCode; // || e.keyCode;

        if ((procesoJustificacion.is_nonChar(charCode)) && e.shiftKey == 0)
            return true;
        else if (charCode == '')
            charCode = e.charCode;

        if (fieldObj.value.length == fieldObj.maxLength) return false;

        var caracter = String.fromCharCode(charCode);

        // Variables que definen los caracteres permitidos
        var numeros = "0123456789";
        var float = "0123456789.";
        var caracteres = "  abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZáéíóúÁÉÍÓÚ";
        var car_especiales = ".-_()'\"/&";
        var anticipo = numeros + caracteres;


        //Los valores de las llaves del array representan los posibles valores permitidos
        var selectArray = new Array();
        selectArray['all']   = '';
        selectArray['num']   = numeros;
        selectArray['float'] = float;
        selectArray['anticipo'] = anticipo;
        selectArray['soloLetrasNumeros'] = caracteres + numeros +', .';

        // Comprobar si la tecla pulsada se encuentra en los caracteres permitidos
        if ((selectArray[permitidos].indexOf(caracter) != -1) || (permitidos == 'all')) {
            return (true);
        }
        else {
            if (e.preventDefault)
                e.preventDefault();
            else
                e.returnValue = false;
        }
    },
    is_nonChar: function (charCode) {

        // 8 = BackSpace, 9 = tabulador, 13 = enter, 35 = fin, 36 = inicio, 37 = flecha izquierda, 38 = flecha arriba,
        // 39 = flecha derecha, 37 = flecha izquierda, 40 = flecha abajo 46 = delete.

        var teclas_especiales = [8, 9, 13, 35, 36, 37, 38, 39, 40, 46];
        for (var i in teclas_especiales) {

            if (charCode == teclas_especiales[i]) {
                return (true);
            }
        }
    },
    validarErrror: function ( jqXHR, textStatus, errorThrown ) {
            if (jqXHR.status === 0) {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError1);
                $("#validarErrror").html(respHtml);
            } else if (jqXHR.status == 404) {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError2);
                $("#validarErrror").html(respHtml);
            } else if (jqXHR.status == 500) {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError3);
                $("#validarErrror").html(respHtml);
            } else if (textStatus === 'parsererror') {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError4);
                $("#validarErrror").html(respHtml);
            } else if (textStatus === 'timeout') {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError5);
                $("#validarErrror").html(respHtml);
            } else if (textStatus === 'abort') {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError6);
                $("#validarErrror").html(respHtml);
            } else {
                var str = procesoJustificacion.EstruturaMesajePeligro;
                var respHtml = str.replace("i_mensaje", procesoJustificacion.mensajeError7  + jqXHR.responseText);
                $("#validarErrror").html(respHtml);
            }

    },
    btnJustificacionMasivo:function () {
        $(document).on("click", ".btnCheckMasivo", function () {

            var idTipo              = $(this).attr('data-id_etapa');
            var tipoAutorizador = $(this).attr('data-id_tipoaut');
            var hidGasto          = $("#hidGasto").val();
            var hidUsuario       = $("#hidUsuario").val();
            var justiValor         = $( "#inpJustiMasivo_"+idTipo+"_"+tipoAutorizador ).val();

                if ( justiValor.length > 1 ){
                    $.ajax({
                           type: "POST",
                           url: baseUrl + procesoJustificacion.urlViewJustifiCasos,
                           processData: true,
                           data: {'idGasto':hidGasto, 'hidUsuario':hidUsuario, 'idAlarma':tipoAutorizador, 'idTipo':idTipo, 'justiValor':justiValor, 'tipo':'Masivo' },
                           dataType:'html',
                           beforeSend:function(){
                                $("#contenedorCasos_" + tipoAutorizador).html( procesoJustificacion.mensajeLoad );
                                $("#check_masivo_"+idTipo+"_" + tipoAutorizador).html( 'Procesando...' );
                                $("#check_masivo_"+idTipo+"_" + tipoAutorizador).prop( 'disabled', true );
                             }, success: function (data) {
                                 $("#contenedorCasos_" + tipoAutorizador).html(data );
                                 $("#check_masivo_"+idTipo+"_" + tipoAutorizador).html( 'Guardar' );
                                 $("#check_masivo_"+idTipo+"_" + tipoAutorizador).prop( 'disabled', false );
                            }, error: function (jqXHR, textStatus, errorThrown) {
                                 procesoJustificacion.validarErrror(jqXHR, textStatus, errorThrown);
                            }
                   });

                }else{
                    alert("Debe indicar justificación.");
                }

        });
    },
    btnJustificacion:function () {
        $(document).on("change", ".btnJustificacion", function () {
            var idGasto      = $(this).attr('data-IDGASTOMAIN');
            var idAlarma    = $(this).attr('data-IDALARMA');
            var idConcepto = $(this).attr('data-IDCONCEPTO');
            var idCredito    = $(this).attr('data-CREDITO');
            var campoJusti = $(this).val();
            var hidUsuario = $("#hidUsuario").val();
            var fechaRegistro    = $(this).attr('data-FECHAREGISTRO');
            var idFacturacion    = $(this).attr('data-IDFACTURAASIGNACION');
            var comentario_old = $(this).attr('data-COMENTARIO_OLD');

            $.ajax({
                   type: "POST",
                   url: baseUrl + procesoJustificacion.urlViewJustifiCasos,
                   processData: true,
                   data: {'idGasto':idGasto, 'idAlarma':idAlarma, 'idConcepto':idConcepto, 'idCredito':idCredito, 'campoJusti':campoJusti, 'hidUsuario':hidUsuario,'fechaRegistro':fechaRegistro, 'idFacturacion':idFacturacion,  'tipo':'Individual', 'comentario_old':comentario_old, },
                   dataType:'html',
                   beforeSend:function(){
                      //    $("#contenedorCasos_" + idAlarma).html( procesoJustificacion.mensajeLoad );
                     }, success: function (data) {
                        // $("#contenedorCasos_" + idAlarma).html(data );
                        $("#inpJus_"+idAlarma+"_"+idCredito).addClass('is-valid');
                    }, error: function (jqXHR, textStatus, errorThrown) {
                         procesoJustificacion.validarErrror(jqXHR, textStatus, errorThrown);
                    }
           });

        });
    },
};

setTimeout(function () {
    procesoJustificacion.init();

/* SCRIPT PARA SCROLL INICIO */
        $('.be-scroll-top').click(function(){
        	$('html, body').animate({
        		scrollTop: 0
        	}, 1800);
        });

        $('.be-scroll-down').click(function(){
        	$('html, body').animate({
        		scrollTop: $('.app').height()
        	}, 1800);
        });

        $(window).scroll(function() {
        	if( $("html").scrollTop() > 120 ) {
        		$(".be-scroll-top").fadeIn(300);
        	} else {
        		$(".be-scroll-top").fadeOut(300);
        	}
        	if( $("html").scrollTop() < $('.app').height() - 1000 ) {
        		$(".be-scroll-down").fadeIn(300);
        	} else {
        		$(".be-scroll-down").fadeOut(300);
        	}
        });
/* SCRIPT PARA SCROLL FIN */

}, 1000);
