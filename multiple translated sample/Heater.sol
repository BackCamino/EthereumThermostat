//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.1;

import "./Thermostat.sol";


contract Heater {
    //attributi derivanti dai parametri dei messaggi in entrata
    bool heat;
    int256 status;

    //indirizzi derivanti dai ruoli esterni che comunicano con il componente
    address sensorGW;

    //derivanti dai messaggi in entrata e in uscita (vanno inizializzati nel costruttore)
    Thermostat thermostat;

    //TODO aggiungere modifier per regolare l'accesso
    //setter derivanti dai messaggi in entrata
    function m6_heat(bool _heat) public {
        //si potrebbe fare un unica funzione per i due heat
        //si potrebbe mettere staticamente il valore di heat true o false
        heat = _heat;
    }

    function m7_heat(bool _heat) public {
        //si potrebbe fare un unica funzione per i due heat
        //si potrebbe mettere staticamente il valore di heat true o false
        heat = _heat;
    }

    function m8_setStatus(int256 _status) public {
        status = _status;
    }

    //gateways
    function gwb_parallel() public { //in seguito ad azione thermostat: richiamato
        //TODO attivazione e disattivazione funzioni
        
    }
}
