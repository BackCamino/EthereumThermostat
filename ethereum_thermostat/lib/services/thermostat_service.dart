import 'package:ethereumthermostat/models/contracts/thermostat.dart';
import 'package:flutter/material.dart';

class ThermostatService with ChangeNotifier {
  Set<ThermostatContract> thermostats;

  //TODO create thermostat

  //TODO deploy thermostat

  //TODO add existing thermostat

  
  //TODO proxy provider?
  //TODO trovare il modo di avere questo insieme di termostati e intercettare comunque i cambiamenti in un singolo termostato. I termostati possono essere aggiunti dinamicamente, quindi alla dichiarazione del provider non si hanno tutti i termostati noti
}
