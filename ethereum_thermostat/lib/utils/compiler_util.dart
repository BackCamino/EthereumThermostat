
import 'dart:convert';

import 'package:http/http.dart' as http;

class CompilerUtil {

  static final Map<String, String> headers = {
    "Content-type": "application/json",
    "accept": "application/json"
  };

  static final CompilerUtil _compilerUtil = CompilerUtil._internal();

  factory CompilerUtil() => _compilerUtil;

  CompilerUtil._internal();

  Future<Map<String, String>> getData(int rooms) async {
    http.Response response;
    response = await http.get(
      'https://bpmn2sol-server.herokuapp.com/predefined/thermostat/compiled?rooms=$rooms',
      headers: headers,
    );
    if(response != null) {
      Map<String, dynamic> result = json.decode(response.body);
      return {
        'abi': json.encode(result['contracts']['Translated_BPMN_Model.sol']['Thermostat']['abi']),
        'bytecode': result['contracts']['Translated_BPMN_Model.sol']['Thermostat']['evm']['bytecode']['object'].toString()
      };
    }
    return null;
  }

}