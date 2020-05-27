//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.1;

import "./Thermostat.sol";


contract Sensor {
    //attributi derivanti dai parametri dei messaggi in entrata
    int256 temp;

    //indirizzi derivanti dai ruoli esterni che comunicano con il componente
    address heaterGW;

    //derivanti dai messaggi in entrata e in uscita (vanno inizializzati nel costruttore)
    Thermostat thermostat;

    //TODO aggiungere modifier per regolare l'accesso
    //setter derivanti dai messaggi in entrata
    function m2_setTemp(int256 _temp) public {
        temp = _temp;
    }

    //gateways
    function gwb_parallel() public { //in seguito ad azione thermostat: richiamato
        //TODO attivazione e disattivazione funzioni
        
    }
}
