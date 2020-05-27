//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.1;

import "./Heater.sol";
import "./Sensor.sol";


//TODO definire le visibilità
contract Thermostat {
    //attributi derivanti dai parametri dei messaggi in entrata
    int256 threshold;
    int256 actualTemp;
    bool shutDown;
    int256 actualStatus;

    //indirizzi derivanti dai ruoli esterni che comunicano con il componente (vanno inizializzati nel costruttore)
    address user;

    //attributi derivanti dai messaggi in entrata e in uscita (vanno inizializzati nel costruttore) (non solo gli indirizzi perché si hanno anche dei messaggi in uscita; se si avessero avuto solo messaggi in entrata allora bastavano gli indirizzi per i controlli ma per semplicità si hanno sempre i riferimenti ai contratti)
    Heater heater;
    Sensor sensor;

    //TODO aggiungere modifier per regolare l'accesso
    //setter derivanti dai messaggi in entrata
    function m1_initialize(int256 _threshold) public {
        threshold = _threshold;

        //chiama i gateway successivi al task
        gwb_parallel();
    }

    function m3_communicateTemp(int256 _actualTemp) public {
        actualTemp = _actualTemp;
    }

    function m4_setThreshold(int256 _threshold) public {
        threshold = _threshold;
    }

    function m5_shutDown(bool _shutDown) public {
        shutDown = _shutDown;

        //chiama i gateway successivi al task
        gwd_conditional();
    }

    function m9_communicateHeaterStatus(int256 _actualStatus) public {
        actualStatus = _actualStatus;
    }

    //gateways
    function gwb_parallel() public { //in seguito ad azione thermostat: attivato direttamente
        heater.gwb_parallel();
        sensor.gwb_parallel();

        //TODO attivazione e disattivazione funzioni
    }

    function gwe_parallel_close() public {
        
    }

    function gwc_conditional_close() public {

    }

    function gwd_conditional() public {
        if(threshold > actualTemp){

        } else if(threshold <= actualTemp){

        }
    }
}
