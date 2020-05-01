pragma solidity ^0.6.1;


/*
Contratto unico.
Inizializzazione dei componenti centralizzata da un amministratore.
Simula la logica di un modello di coreografia.
*/

contract Thermostat {
    mapping(string => bool) functionEnabled;

    address private admin;
    address private sensor;
    address private heater;
    address private user;

    int16 currentTemp;
    int16 thresholdTemp;

    string[] functionsName = ["setThreshold", "setTemp", "updateHeater"];

    enum ThermostatState {Running, Stopped}

    struct Sensor {
        address sensorAddress;
        int16 currentTemp;
    }

    enum HeaterState {Running, Stopped}

    struct Heater {
        address heaterAddress;
        HeaterState heaterStatus;
    }

    function initFuncionsName() private {
        for (uint256 i = 0; i < functionsName.length; i++) {
            functionEnabled[functionsName[i]] = false;
        }
    }

    function enable(uint256 index) private {
        functionEnabled[functionsName[index]] = true;
    }

    function disable(uint256 index) private {
        functionEnabled[functionsName[index]] = true;
    }

    constructor() public {
        admin = msg.sender;

        initFuncionsName();
        enable(0);
    }

    function getCurrentTemp() public view returns (int16) {
        return currentTemp;
    }

    function getThresholdTemp() public view returns (int16) {
        return thresholdTemp;
    }

    modifier onlyAddress(address ad) {
        require(msg.sender == ad, "User not allowed");
        _;
    }

    modifier allSubscribed() {
        require(sensor != address(0), "Sensor not initialized");
        require(heater != address(0), "Heater not initialized");
        require(user != address(0), "User not initialized");
        _;
    }

    event HeaterActivation(bool on);

    function updateHeater() private enabling(2) {
        emit HeaterActivation(heaterOn());

        disable(2);
        enable(0);
        enable(1);
    }

    function setSensor(address ad) external onlyAddress(admin) {
        sensor = ad;
    }

    function setHeater(address ad) external onlyAddress(admin) {
        heater = ad;
    }

    function setUser(address ad) external onlyAddress(admin) {
        user = ad;
    }

    function heaterOn() public view allSubscribed returns (bool) {
        return currentTemp < thresholdTemp;
    }

    function setThreshold(int16 temp)
        external
        onlyAddress(user)
        allSubscribed
        enabling(0)
    {
        thresholdTemp = temp;

        enable(1);
        disable(0);
    }

    function setTemp(int16 temp)
        external
        onlyAddress(sensor)
        allSubscribed
        enabling(1)
    {
        disable(0);

        currentTemp = temp;

        enable(2);
        disable(1);
    }

    modifier enabling(uint256 index) {
        require(functionEnabled[functionsName[index]], "Not enabled");
        _;
    }
}
