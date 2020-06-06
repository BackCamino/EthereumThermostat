//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.1;

import "./Heater.sol";
import "./Sensor.sol";
import "./State.sol";


//TODO definire le visibilità
//TODO la gestione degli states potrebbe essere un contratto da estendere
//TODO aggiungere controllo che le funzioni vengano chiamate dai componenti o da chi ne ha l'autorizzazione
contract Thermostat {
    //gestione degli stati delle operazioni
    /*
    non bisonga inizializzare il mapping:
    mappings can be seen as hash tables which are virtually initialized such that every possible key exists and is mapped to a value whose byte-representation are all zeros
    */
    mapping(string => State) states;

    modifier enabled(string memory name) {
        require(states[name] == State.ENABLED, "Operation not enabled");
        _;
    }

    //attributi derivanti dai parametri dei messaggi in entrata
    int256 threshold;
    int256 actualTemp;
    bool shutDown;
    int256 actualStatus;

    //indirizzi derivanti dai ruoli esterni che comunicano con il componente (vanno inizializzati nel costruttore)
    address user;

    //attributi derivanti dai messaggi in entrata e in uscita (vanno inizializzati nel costruttore) (non solo gli indirizzi perché si hanno anche dei messaggi in uscita; se si avessero avuto solo messaggi in entrata allora bastavano gli indirizzi per i controlli ma per semplicità si hanno sempre i riferimenti ai contratti)
    //non possono essere inizializzati solo nel costruttore. Meccanismo che non fa parire niente se non sono stati inizializzati
    Heater heater;
    Sensor sensor;

    //indirizzi dei ruoli esterni che comunicano e ...? TODO
    constructor(address _user) public {
        user = _user;
    }

    //start function per abilitare la prima operazione dopo le inizializzazioni
    function start() private {
        //controllo che gli indirizzi di tutti i componenti siano inizializzati
        if (address(heater) != address(0) && address(sensor) != address(0)) {
            //abilitazione primo task. Se fosse iniziato con un gateway, sarebbe stato richiamato questo
            states["m1_initialize"] = State.ENABLED;
        }
    }

    //inizializzazioni degli altri ruoli. Ogni volta si controlla se i ruoli siano stati impostati tutti per poter iniziare
    function setHeater(address _address) public {
        heater = Heater(_address);
        start();
    }

    function setSensor(address _address) public {
        sensor = Sensor(_address);
        start();
    }

    //TODO aggiungere modifier (enabled) per regolare l'accesso
    //setter derivanti dai messaggi in entrata
    function m1_initialize(int256 _threshold) public enabled("m1_initialize") {
        threshold = _threshold;

        //si auto disabilita perché completato
        states["m1_initialize"] = State.DISABLED;

        //chiama i gateway successivi al task
        gwa_conditional_close();
    }

    function m3_communicateTemp(int256 _actualTemp)
        public
        enabled("m3_communicateTemp") //può essere rimosso perché non riguarda un messaggio esterno ed è coordinato dagli altri contratti
    {
        actualTemp = _actualTemp;
    }

    function m4_setThreshold(int256 _threshold) public {
        threshold = _threshold;

        states["m4_setThreshold"] = State.DISABLED;

        gwe_parallel_close();
    }

    function m5_shutDown(bool _shutDown) public {
        shutDown = _shutDown;

        states["m5_shutDown"] = State.DISABLED;

        //chiama i gateway successivi al task
        gwd_conditional();
    }

    function m9_communicateHeaterStatus(int256 _actualStatus) public {
        actualStatus = _actualStatus;
    }

    //gateways
    //potrebbe essere rimosso perché ha solo una funzione. Verificare i gateway di chiusura e chiamare l'unico task/gateway uscente
    function gwa_conditional_close() public {
        gwb_parallel();
    }

    function gwb_parallel() public {
        //in seguito ad azione thermostat: attivato direttamente. Il thermostat chiama gli altri
        heater.gwb_parallel(); //si può rimuovere perché l'heater non è interessato. Non è compreso tra l'apertura e la chiusura del gateway
        sensor.gwb_parallel();

        //attivazione e disattivazione funzioni
        states["m4_setThreshold"] = State.ENABLED;
        gwc_conditional_close(); //states["m5_shutDown"] = State.ENABLED;
    }

    function gwe_parallel_close() public {
        //questo gateway può essere chiuso solo dal thermostat ma cosa accadrebbe se potesse essere chiuso anche da altri componenti?
        //TODO richiamare sensor
        //TODO disabilitare tutte le funzioni del thermostat comprese tra l'apertura e la chiusura(?)

        gwf_conditional();
    }

    function gwd_conditional() public {
        if (shutDown == true) {
            gwe_parallel_close();
        } else if (shutDown == false) {
            gwc_conditional_close();
        }
    }

    function gwc_conditional_close() public {
        states["m5_shutDown"] = State.ENABLED;
    }

    function gwf_conditional() public {
        if (threshold > actualTemp) {
            //TODO attivare ricezione messaggi nell'heater? Oppure basta richiamare questo
            heater.m6_heat(true);
        } else if (threshold <= actualTemp) {
            heater.m7_heat(false); //si potrebbe accorpare nello stesso messaggio
        }
    }

    function gwh_conditional_close() public {
        if (shutDown == true) {
            //TODO comunicare a tutti i componenti la terminazione
        } else if (shutDown == false) {
            gwa_conditional_close();
        }
    }
}
