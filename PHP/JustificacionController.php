<?php
class Gastos_JustificacionController extends Zend_Controller_Action
{

    public function init()
    {
        /* Initialize action controller here */
        $this->view->baseUrl = $this->getRequest()->getBaseUrl();
    }
    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Este Metodo permite formar la interfaz para capturar justificaciones
     * @access public
     *
     */
    public function viewJustificacionAction() {
        $this->_helper->layout->setLayout('quantum_cotizacion');
        $params              = $this->getRequest()->getParams();
        $ObjJustificacion   = new Gastos_Model_Justificacion();
        $this->view->ObjAutorizadores = $ObjJustificacion->getTipoAutorizadoresGasto( $params );
        $this->view->idgasto = $params['caso'];
        $this->view->cvetra = $params['cvetra'];

        foreach ($this->view->ObjAutorizadores as $key => $value) {
            $params['idGasto']  = $params['caso'];
            $params['idAlarma'] = $value['TPOAUT'];
            $params['hidUsuario'] = $params['cvetra'];
            $this->view->ObjAutorizadores[$key]['totalRegistros'] = count( $ObjJustificacion->getCasosPorAutorizador( $params ) );
        }
    }

    /**
     * @author  Leonard Cuenca <ljcuenca@pendulum.com>
     * @company Pendulum C.V
     * @Description Este Metodo permite formar la interfaz para capturar justificaciones
     * @access public
     *
     */
    public function viewJustificacionCasoAction() {
    try{
            $this->_helper->layout->disableLayout();
            $params              = $this->getRequest()->getParams();
            $ObjJustificacion   = new Gastos_Model_Justificacion();
            if ($params['tipo'] == 'Masivo'){
                $this->view->ObjCasos = $ObjJustificacion->procesarJustificacionMasiva( $params );
            }
            if ($params['tipo'] == 'Individual'){
                $this->view->ObjCasos = $ObjJustificacion->procesarJustificacion( $params );
            }

            $this->view->ObjCasos = $ObjJustificacion->getCasosPorAutorizador( $params );
        } catch( Exception $e) {
            $this->view->valida = 'false';
            $this->view->msg = "Excepción: " . $e->getMessage();
        }
    }

}
